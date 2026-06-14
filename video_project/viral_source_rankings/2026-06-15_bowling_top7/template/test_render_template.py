from pathlib import Path

from PIL import Image

from render_template import render_template


def test_renders_1080x1920_png(tmp_path: Path) -> None:
    root = Path(__file__).resolve().parent
    output = tmp_path / "preview.png"

    render_template(root / "template_config.json", output)

    with Image.open(output) as image:
        assert image.size == (1080, 1920)
