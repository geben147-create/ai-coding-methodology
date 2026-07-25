import json
from pathlib import Path

from tools.slim_har import slim_har


def test_slim_har_removes_only_image_and_font_bodies(tmp_path: Path) -> None:
    source = tmp_path / "source.har"
    destination = tmp_path / "source-slim.har"
    document = {
        "log": {
            "entries": [
                {
                    "request": {"url": "https://example.com/page"},
                    "response": {
                        "content": {
                            "mimeType": "text/html",
                            "text": "<main>layout</main>",
                        }
                    },
                },
                {
                    "request": {"url": "https://example.com/hero.gif"},
                    "response": {
                        "content": {
                            "mimeType": "image/gif",
                            "encoding": "base64",
                            "text": "R0lGODlh",
                        }
                    },
                },
                {
                    "request": {"url": "https://example.com/font.woff2"},
                    "response": {
                        "content": {
                            "mimeType": "font/woff2",
                            "encoding": "base64",
                            "text": "d09GMgAB",
                        }
                    },
                },
                {
                    "request": {"url": "https://example.com/app.js"},
                    "response": {
                        "content": {
                            "mimeType": "application/javascript",
                            "text": "window.ready = true;",
                        }
                    },
                },
            ]
        }
    }
    source.write_text(json.dumps(document), encoding="utf-8")

    result = slim_har(source, destination)

    slimmed = json.loads(destination.read_text(encoding="utf-8"))
    contents = [
        entry["response"]["content"] for entry in slimmed["log"]["entries"]
    ]
    assert contents[0]["text"] == "<main>layout</main>"
    assert "text" not in contents[1]
    assert "text" not in contents[2]
    assert contents[3]["text"] == "window.ready = true;"
    assert result.entry_count == 4
    assert result.removed_body_count == 2
    assert result.removed_character_count == 16
    assert json.loads(source.read_text(encoding="utf-8")) == document


def test_slim_har_treats_woff_octet_stream_url_as_font(tmp_path: Path) -> None:
    source = tmp_path / "source.har"
    destination = tmp_path / "source-slim.har"
    document = {
        "log": {
            "entries": [
                {
                    "request": {"url": "https://example.com/fonts/site.woff2?v=1"},
                    "response": {
                        "content": {
                            "mimeType": "application/octet-stream",
                            "text": "large-font-body",
                        }
                    },
                }
            ]
        }
    }
    source.write_text(json.dumps(document), encoding="utf-8")

    result = slim_har(source, destination)

    content = json.loads(destination.read_text(encoding="utf-8"))["log"][
        "entries"
    ][0]["response"]["content"]
    assert "text" not in content
    assert result.removed_body_count == 1
