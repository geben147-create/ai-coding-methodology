from __future__ import annotations

import argparse
import json
import os
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlsplit


REMOVABLE_MIME_PREFIXES = ("image/", "font/")
REMOVABLE_EXTENSIONS = {
    ".avif",
    ".bmp",
    ".eot",
    ".gif",
    ".ico",
    ".jpeg",
    ".jpg",
    ".otf",
    ".png",
    ".svg",
    ".tif",
    ".tiff",
    ".ttc",
    ".ttf",
    ".webp",
    ".woff",
    ".woff2",
}


@dataclass(frozen=True)
class SlimResult:
    source: Path
    destination: Path
    entry_count: int
    removed_body_count: int
    removed_character_count: int
    source_size: int
    destination_size: int


def _is_removable_content(mime_type: object, url: object) -> bool:
    normalized_mime = mime_type.lower().split(";", 1)[0].strip() if isinstance(
        mime_type, str
    ) else ""
    if normalized_mime.startswith(REMOVABLE_MIME_PREFIXES):
        return True
    if not isinstance(url, str):
        return False
    extension = Path(urlsplit(url).path).suffix.lower()
    return extension in REMOVABLE_EXTENSIONS


def slim_har(source: Path, destination: Path) -> SlimResult:
    source = source.resolve()
    destination = destination.resolve()
    if source == destination:
        raise ValueError("Source and destination must be different files.")

    with source.open("r", encoding="utf-8-sig") as source_file:
        document = json.load(source_file)

    entries = document.get("log", {}).get("entries", [])
    if not isinstance(entries, list):
        raise ValueError("Invalid HAR: log.entries must be a list.")

    removed_body_count = 0
    removed_character_count = 0
    for entry in entries:
        if not isinstance(entry, dict):
            continue
        response = entry.get("response")
        request = entry.get("request")
        if not isinstance(response, dict):
            continue
        content = response.get("content")
        if not isinstance(content, dict):
            continue
        url = request.get("url") if isinstance(request, dict) else None
        if not _is_removable_content(content.get("mimeType"), url):
            continue
        body = content.pop("text", None)
        if isinstance(body, str):
            removed_body_count += 1
            removed_character_count += len(body)
        content.pop("encoding", None)

    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = destination.with_name(f"{destination.name}.tmp")
    try:
        with temporary.open("w", encoding="utf-8", newline="\n") as output_file:
            json.dump(
                document,
                output_file,
                ensure_ascii=False,
                separators=(",", ":"),
            )
        with temporary.open("r", encoding="utf-8") as validation_file:
            validated = json.load(validation_file)
        validated_entries = validated.get("log", {}).get("entries", [])
        if not isinstance(validated_entries, list) or len(validated_entries) != len(
            entries
        ):
            raise ValueError("Output validation failed: entry count changed.")
        os.replace(temporary, destination)
    finally:
        if temporary.exists():
            temporary.unlink()

    return SlimResult(
        source=source,
        destination=destination,
        entry_count=len(entries),
        removed_body_count=removed_body_count,
        removed_character_count=removed_character_count,
        source_size=source.stat().st_size,
        destination_size=destination.stat().st_size,
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Create layout-analysis HAR copies without image/font bodies."
    )
    parser.add_argument(
        "pairs",
        nargs="+",
        metavar="SOURCE=DESTINATION",
        help="A source and destination path separated by '='.",
    )
    arguments = parser.parse_args()

    for pair in arguments.pairs:
        source_text, separator, destination_text = pair.partition("=")
        if not separator:
            parser.error(f"Invalid pair: {pair}")
        result = slim_har(Path(source_text), Path(destination_text))
        print(
            json.dumps(
                {
                    "source": str(result.source),
                    "destination": str(result.destination),
                    "entries": result.entry_count,
                    "removed_bodies": result.removed_body_count,
                    "removed_characters": result.removed_character_count,
                    "source_bytes": result.source_size,
                    "destination_bytes": result.destination_size,
                },
                ensure_ascii=False,
            )
        )


if __name__ == "__main__":
    main()
