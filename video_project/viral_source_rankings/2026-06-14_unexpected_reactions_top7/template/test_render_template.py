from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from PIL import Image

from render_template import render_template


class RenderTemplateTests(unittest.TestCase):
    def test_renders_1080x1920_png_from_config(self) -> None:
        root = Path(__file__).resolve().parent
        output = Path(tempfile.mkdtemp()) / "preview.png"

        render_template(root / "template_config.json", output)

        image = Image.open(output)
        self.assertEqual((1080, 1920), image.size)
        self.assertEqual("RGB", image.mode)


if __name__ == "__main__":
    unittest.main()
