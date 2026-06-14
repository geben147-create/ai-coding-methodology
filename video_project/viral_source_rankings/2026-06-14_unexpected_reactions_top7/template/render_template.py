#!/usr/bin/env python3
"""Render the reusable Shorts template JSON to a 1080x1920 PNG preview."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


FONT_DIR = Path("C:/Windows/Fonts")


def load_font(
    size: int,
    *,
    bold: bool = False,
) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = (
        ("malgunbd.ttf", "malgun.ttf")
        if bold
        else ("malgun.ttf", "malgunbd.ttf")
    )
    for name in candidates:
        path = FONT_DIR / name
        if path.is_file():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default(size=size)


def interpolate_color(
    start: tuple[int, int, int],
    end: tuple[int, int, int],
    ratio: float,
) -> tuple[int, int, int]:
    return (
        round(start[0] + ((end[0] - start[0]) * ratio)),
        round(start[1] + ((end[1] - start[1]) * ratio)),
        round(start[2] + ((end[2] - start[2]) * ratio)),
    )


def draw_dashed_box(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    *,
    fill: tuple[int, int, int, int],
    outline: tuple[int, int, int, int],
    dash: int = 18,
    gap: int = 12,
) -> None:
    draw.rounded_rectangle(box, radius=48, fill=fill)
    left, top, right, bottom = box
    for x in range(left + 30, right - 30, dash + gap):
        draw.line((x, top, min(x + dash, right - 30), top), fill=outline, width=4)
        draw.line(
            (x, bottom, min(x + dash, right - 30), bottom),
            fill=outline,
            width=4,
        )
    for y in range(top + 30, bottom - 30, dash + gap):
        draw.line((left, y, left, min(y + dash, bottom - 30)), fill=outline, width=4)
        draw.line(
            (right, y, right, min(y + dash, bottom - 30)),
            fill=outline,
            width=4,
        )


def render_template(config_path: Path, output_path: Path) -> None:
    config = json.loads(config_path.read_text(encoding="utf-8"))
    width = int(config["canvas"]["width"])
    height = int(config["canvas"]["height"])

    image = Image.new("RGB", (width, height), "#070909")
    base_draw = ImageDraw.Draw(image)
    top_color = (19, 25, 25)
    bottom_color = (7, 8, 8)
    for y in range(height):
        color = interpolate_color(top_color, bottom_color, y / (height - 1))
        base_draw.line((0, y, width, y), fill=color)

    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    yellow = (255, 215, 53, 255)
    white = (255, 253, 246, 255)
    red = (255, 59, 48, 255)
    muted = (184, 185, 180, 255)

    for x in range(0, width, 48):
        draw.line((x, 0, x, 1180), fill=(255, 255, 255, 9), width=1)
    for y in range(0, 1180, 48):
        draw.line((0, y, width, y), fill=(255, 255, 255, 9), width=1)

    draw.ellipse((750, -130, 1230, 350), fill=(255, 215, 53, 20))
    draw.ellipse((-170, 1240, 330, 1740), fill=(255, 59, 48, 18))

    draw.text(
        (72, 58),
        "UNEXPECTED MOMENT ARCHIVE",
        font=load_font(24, bold=True),
        fill=muted,
    )
    draw.text(
        (72, 98),
        config["title"]["text"],
        font=load_font(int(config["title"]["font_size"]), bold=True),
        fill=yellow,
        stroke_width=2,
        stroke_fill=(0, 0, 0, 130),
    )
    draw.rounded_rectangle(
        (764, 82, 1008, 156),
        radius=37,
        fill=(4, 6, 6, 200),
        outline=(255, 255, 255, 120),
        width=2,
    )
    draw.text(
        (886, 119),
        config["ranking_label"]["text"],
        font=load_font(34, bold=True),
        fill=white,
        anchor="mm",
    )

    frame = config["video_frame"]
    frame_box = (
        int(frame["x"]),
        int(frame["y"]),
        int(frame["x"] + frame["width"]),
        int(frame["y"] + frame["height"]),
    )
    draw.rounded_rectangle(
        frame_box,
        radius=int(frame["corner_radius"]),
        fill=(20, 29, 28, 255),
        outline=(255, 255, 255, 48),
        width=3,
    )
    draw.ellipse((520, 470, 1030, 980), fill=(255, 244, 198, 26))
    draw.text(
        (540, 880),
        "VIDEO / IMAGE FRAME",
        font=load_font(42, bold=True),
        fill=(255, 255, 255, 95),
        anchor="mm",
    )

    rank = config["rank_stack"]
    stack_x = int(rank["x"])
    stack_y = int(rank["y"])
    gap = int(rank["gap"])
    draw.rounded_rectangle(
        (44, stack_y - 28, 132, stack_y + (gap * 6) + 74),
        radius=26,
        fill=(5, 7, 7, 190),
        outline=(255, 255, 255, 38),
        width=2,
    )
    for value in range(1, 8):
        center_y = stack_y + ((value - 1) * gap)
        if value == int(rank["current_rank"]):
            draw.ellipse(
                (stack_x - 26, center_y - 26, stack_x + 26, center_y + 26),
                fill=red,
            )
            rank_color = white
        else:
            rank_color = (255, 255, 255, 185)
        draw.text(
            (stack_x, center_y),
            str(value),
            font=load_font(34, bold=True),
            fill=rank_color,
            anchor="mm",
        )

    character = config["character"]
    char_box = (
        int(character["x"]),
        int(character["y"]),
        int(character["x"] + character["width"]),
        int(character["y"] + character["height"]),
    )
    draw_dashed_box(
        draw,
        char_box,
        fill=(255, 215, 53, 13),
        outline=(255, 215, 53, 155),
    )
    draw.multiline_text(
        (
            int(character["x"] + (character["width"] / 2)),
            int(character["y"] + (character["height"] / 2)),
        ),
        "CHARACTER PNG\nSAFE AREA\nopacity 80%",
        font=load_font(26, bold=True),
        fill=yellow,
        anchor="mm",
        align="center",
        spacing=12,
    )

    caption = config["reaction_caption"]
    caption_y = int(caption["y"])
    draw.rounded_rectangle(
        (130, caption_y - 28, 950, caption_y + 112),
        radius=28,
        fill=(3, 5, 5, 220),
    )
    draw.text(
        (540, caption_y + 40),
        caption["text"],
        font=load_font(int(caption["font_size"]), bold=True),
        fill=white,
        anchor="mm",
    )

    draw.line((72, 1732, 1008, 1732), fill=(255, 255, 255, 45), width=2)
    draw.text(
        (72, 1776),
        "source attribution safe zone",
        font=load_font(28, bold=True),
        fill=muted,
    )
    draw.text(
        (1008, 1776),
        config["footer"]["text"],
        font=load_font(30, bold=True),
        fill=white,
        anchor="ra",
    )

    image = Image.alpha_composite(image.convert("RGBA"), overlay).convert("RGB")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    image.save(output_path, format="PNG", optimize=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("config", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    render_template(args.config, args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
