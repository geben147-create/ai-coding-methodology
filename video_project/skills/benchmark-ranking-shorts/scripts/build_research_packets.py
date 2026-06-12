#!/usr/bin/env python3
"""Build metadata packets and visual contact sheets for Shorts research."""

from __future__ import annotations

import argparse
import csv
import json
import math
import statistics
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageStat


@dataclass
class CaptionMetrics:
    language: str = "none"
    events: int = 0
    words: int = 0
    characters: int = 0
    covered_seconds: float = 0.0


@dataclass
class FrameSample:
    time_seconds: float
    image: Image.Image
    difference: float = 0.0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--metadata-dir", required=True, type=Path)
    parser.add_argument("--captions-dir", required=True, type=Path)
    parser.add_argument("--storyboards-dir", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def caption_metrics(captions_dir: Path, video_id: str) -> CaptionMetrics:
    files = sorted(captions_dir.glob(f"{video_id}.*-orig.json3"))
    if not files:
        return CaptionMetrics()

    path = files[0]
    language = path.name.removeprefix(f"{video_id}.").removesuffix(".json3")
    data = load_json(path)
    metrics = CaptionMetrics(language=language)
    intervals: list[tuple[float, float]] = []

    for event in data.get("events", []):
        text = "".join(
            segment.get("utf8", "") for segment in event.get("segs", [])
        ).strip()
        if not text:
            continue
        start = float(event.get("tStartMs", 0)) / 1000
        duration = float(event.get("dDurationMs", 0)) / 1000
        metrics.events += 1
        metrics.words += len(text.split())
        metrics.characters += len(text.replace(" ", ""))
        intervals.append((start, start + duration))

    merged: list[list[float]] = []
    for start, end in sorted(intervals):
        if not merged or start > merged[-1][1]:
            merged.append([start, end])
        else:
            merged[-1][1] = max(merged[-1][1], end)
    metrics.covered_seconds = sum(end - start for start, end in merged)
    return metrics


def storyboard_format(metadata: dict[str, Any]) -> dict[str, Any] | None:
    formats = metadata.get("formats", [])
    preferred = next(
        (item for item in formats if item.get("format_id") == "sb0"), None
    )
    if preferred:
        return preferred
    storyboards = [
        item for item in formats if item.get("format_note") == "storyboard"
    ]
    if not storyboards:
        return None
    return max(
        storyboards,
        key=lambda item: int(item.get("width") or 0) * int(item.get("height") or 0),
    )


def extract_frames(
    metadata: dict[str, Any], storyboards_dir: Path
) -> list[FrameSample]:
    video_id = metadata["id"]
    format_info = storyboard_format(metadata)
    if not format_info:
        return []

    width = int(format_info.get("width") or 0)
    height = int(format_info.get("height") or 0)
    rows = int(format_info.get("rows") or 0)
    columns = int(format_info.get("columns") or 0)
    if min(width, height, rows, columns) <= 0:
        return []

    sheet_files = sorted((storyboards_dir / video_id).glob("sheet_*.jpg"))
    fragments = format_info.get("fragments", [])
    total_duration = float(metadata.get("duration") or 0)
    current_time = 0.0
    frames: list[FrameSample] = []

    for sheet_index, sheet_path in enumerate(sheet_files):
        fragment = fragments[sheet_index] if sheet_index < len(fragments) else {}
        fragment_duration = float(
            fragment.get("duration") or total_duration / max(len(sheet_files), 1)
        )
        cell_count = rows * columns
        step = fragment_duration / cell_count
        with Image.open(sheet_path) as sheet:
            sheet = sheet.convert("RGB")
            for cell_index in range(cell_count):
                timestamp = current_time + cell_index * step
                if total_duration and timestamp >= total_duration:
                    break
                x = (cell_index % columns) * width
                y = (cell_index // columns) * height
                tile = sheet.crop((x, y, x + width, y + height)).copy()
                frames.append(FrameSample(timestamp, tile))
        current_time += fragment_duration

    previous: Image.Image | None = None
    for frame in frames:
        reduced = frame.image.convert("L").resize((48, 48))
        if previous is not None:
            difference = ImageStat.Stat(
                ImageChops.difference(reduced, previous)
            ).mean[0]
            frame.difference = difference / 255
        previous = reduced
    return frames


def change_candidates(frames: list[FrameSample]) -> list[FrameSample]:
    candidates = [frame for frame in frames[1:] if frame.difference > 0]
    if not candidates:
        return []
    scores = [frame.difference for frame in candidates]
    threshold = max(0.16, statistics.quantiles(scores, n=4)[2])
    selected = [frame for frame in candidates if frame.difference >= threshold]
    return sorted(selected, key=lambda frame: frame.time_seconds)


def save_contact_sheets(
    video_id: str, frames: list[FrameSample], output_dir: Path
) -> list[Path]:
    if not frames:
        return []

    output_dir.mkdir(parents=True, exist_ok=True)
    scale = 3
    columns = 4
    rows = 4
    label_height = 34
    tile_width = frames[0].image.width * scale
    tile_height = frames[0].image.height * scale
    cell_height = tile_height + label_height
    per_page = columns * rows
    font = ImageFont.load_default()
    paths: list[Path] = []

    for page_index in range(math.ceil(len(frames) / per_page)):
        page_frames = frames[
            page_index * per_page : (page_index + 1) * per_page
        ]
        canvas = Image.new(
            "RGB", (tile_width * columns, cell_height * rows), "white"
        )
        draw = ImageDraw.Draw(canvas)
        for index, frame in enumerate(page_frames):
            x = (index % columns) * tile_width
            y = (index // columns) * cell_height
            enlarged = frame.image.resize(
                (tile_width, tile_height), Image.Resampling.LANCZOS
            )
            canvas.paste(enlarged, (x, y + label_height))
            label = (
                f"{frame.time_seconds:05.1f}s"
                f"  delta={frame.difference:.2f}"
            )
            draw.text((x + 8, y + 9), label, fill="black", font=font)

        path = output_dir / f"{video_id}_{page_index + 1:02}.jpg"
        canvas.save(path, quality=92)
        paths.append(path)
    return paths


def safe_rate(numerator: int | None, denominator: int | None) -> float:
    if not numerator or not denominator:
        return 0.0
    return numerator / denominator


def metric_row(
    metadata: dict[str, Any],
    captions: CaptionMetrics,
    changes: list[FrameSample],
) -> dict[str, Any]:
    duration = float(metadata.get("duration") or 0)
    views = int(metadata.get("view_count") or 0)
    likes = int(metadata.get("like_count") or 0)
    comments = int(metadata.get("comment_count") or 0)
    intervals = [
        right.time_seconds - left.time_seconds
        for left, right in zip(changes, changes[1:])
    ]
    return {
        "id": metadata.get("id", ""),
        "title": metadata.get("title", ""),
        "upload_date": metadata.get("upload_date", ""),
        "duration_seconds": duration,
        "views": views,
        "likes": likes,
        "comments": comments,
        "like_rate": round(safe_rate(likes, views), 6),
        "comment_rate": round(safe_rate(comments, views), 6),
        "caption_language": captions.language,
        "caption_events": captions.events,
        "caption_words": captions.words,
        "caption_characters": captions.characters,
        "speech_coverage": round(
            captions.covered_seconds / duration if duration else 0, 4
        ),
        "visual_change_candidates": len(changes),
        "median_change_interval": round(statistics.median(intervals), 2)
        if intervals
        else 0,
        "url": metadata.get("webpage_url", ""),
    }


def write_packet(
    output_dir: Path,
    metadata: dict[str, Any],
    row: dict[str, Any],
    changes: list[FrameSample],
    contact_paths: list[Path],
) -> None:
    change_text = ", ".join(
        f"{frame.time_seconds:.1f}s ({frame.difference:.2f})"
        for frame in changes
    )
    if not change_text:
        change_text = "No candidates detected"
    contacts = "\n".join(f"- `{path.as_posix()}`" for path in contact_paths)
    if not contacts:
        contacts = "- No storyboard available"

    text = f"""# {metadata.get("title", metadata.get("id", "Untitled"))}

## Public Metadata

- Video ID: `{row["id"]}`
- URL: {row["url"]}
- Upload date: {row["upload_date"]}
- Duration: {row["duration_seconds"]:.1f} seconds
- Views: {row["views"]:,}
- Likes: {row["likes"]:,} ({row["like_rate"]:.2%} of views)
- Comments: {row["comments"]:,} ({row["comment_rate"]:.3%} of views)
- Detected source language: `{metadata.get("language") or "unknown"}`

## Timing Signals

- Original automatic-caption track: `{row["caption_language"]}`
- Caption events: {row["caption_events"]}
- Approximate caption words: {row["caption_words"]}
- Approximate caption characters: {row["caption_characters"]}
- Speech coverage: {row["speech_coverage"]:.1%}
- Visual change candidates: {change_text}
- Median candidate interval: {row["median_change_interval"]:.2f} seconds

These timings are research aids, not definitive edit points. Verify all claims
against visible playback before publishing an analysis.

## Contact Sheets

{contacts}

## Rights Status

`research-only / reuse-rights-unknown`

Do not download or republish the underlying footage as an edit source without
permission or a compatible license.
"""
    (output_dir / f"{metadata['id']}.md").write_text(text, encoding="utf-8")


def main() -> int:
    args = parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    contact_dir = args.output_dir / "contact_sheets"
    rows: list[dict[str, Any]] = []

    for metadata_path in sorted(args.metadata_dir.glob("*.info.json")):
        metadata = load_json(metadata_path)
        captions = caption_metrics(args.captions_dir, metadata["id"])
        frames = extract_frames(metadata, args.storyboards_dir)
        changes = change_candidates(frames)
        contacts = save_contact_sheets(
            metadata["id"], frames, contact_dir
        )
        row = metric_row(metadata, captions, changes)
        rows.append(row)
        write_packet(args.output_dir, metadata, row, changes, contacts)

    if rows:
        with (args.output_dir / "metrics.csv").open(
            "w", encoding="utf-8-sig", newline=""
        ) as handle:
            writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
            writer.writeheader()
            writer.writerows(sorted(rows, key=lambda row: row["views"], reverse=True))

    print(f"Built {len(rows)} research packets in {args.output_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
