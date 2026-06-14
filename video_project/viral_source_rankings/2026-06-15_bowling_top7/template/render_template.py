#!/usr/bin/env python3
"""Render the reusable bowling Shorts template to a PNG preview."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


FONT_DIR = Path("C:/Windows/Fonts")


def font(size: int, bold: bool = False):
    name = "malgunbd.ttf" if bold else "malgun.ttf"
    path = FONT_DIR / name
    return ImageFont.truetype(str(path), size) if path.is_file() else ImageFont.load_default()


def render_template(config_path: Path, output_path: Path) -> None:
    config = json.loads(config_path.read_text(encoding="utf-8"))
    width = int(config["canvas"]["width"])
    height = int(config["canvas"]["height"])
    image = Image.new("RGB", (width, height), "#090b0c")
    draw = ImageDraw.Draw(image)
    for y in range(height):
        shade = 22 - round(14 * y / height)
        draw.line((0, y, width, y), fill=(shade, shade + 2, shade + 3))

    draw.text((540, 82), config["title"]["text"], font=font(68, True), fill="#ffd735", anchor="mm")
    draw.text((540, 158), config["ranking_label"]["text"], font=font(42, True), fill="white", anchor="mm")
    frame = config["video_frame"]
    box = (frame["x"], frame["y"], frame["x"] + frame["width"], frame["y"] + frame["height"])
    draw.rounded_rectangle(box, radius=frame["corner_radius"], fill="#202727", outline="#4b5555", width=3)
    draw.text((540, 800), "BOWLING VIDEO FRAME", font=font(42, True), fill="#7f8989", anchor="mm")

    rank = config["rank_stack"]
    draw.rounded_rectangle((45, 365, 132, 955), radius=28, fill="#050707", outline="#394040")
    for index, value in enumerate(rank["values"]):
        y = rank["y"] + index * rank["gap"]
        color = "#ff3b30" if value == rank["current_rank"] else "white"
        draw.text((rank["x"], y), str(value), font=font(38 if value != rank["current_rank"] else 52, True), fill=color, anchor="mm")

    caption = config["reaction_caption"]
    draw.rounded_rectangle((100, 1380, 980, 1545), radius=30, fill="#050606")
    draw.text((540, 1462), caption["text"], font=font(caption["font_size"], True), fill="white", anchor="mm")
    draw.text((70, 1780), "source attribution safe zone", font=font(26, True), fill="#b8b9b4")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    image.save(output_path, "PNG")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("config", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    render_template(args.config, args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
