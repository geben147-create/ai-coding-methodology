#!/usr/bin/env python3
"""Build the audited bowling TOP7 private-review package."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import time
import urllib.error
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parent


def run(command: list[str]) -> None:
    subprocess.run(command, check=True)


def request_json(url: str, method: str = "GET", payload: dict | None = None) -> object:
    data = None if payload is None else json.dumps(payload, ensure_ascii=False).encode()
    request = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={"Content-Type": "application/json; charset=utf-8"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def voicebox_is_healthy(url: str) -> bool:
    try:
        result = request_json(f"{url}/health")
    except (OSError, urllib.error.URLError, ValueError):
        return False
    return isinstance(result, dict) and result.get("status") == "healthy"


def resolve_voicebox_url() -> str:
    for url in ("http://127.0.0.1:17493", "http://127.0.0.1:8000"):
        if voicebox_is_healthy(url):
            return url
    raise RuntimeError("VoiceBox is not healthy on ports 17493 or 8000")


def resolve_sohee_profile(base_url: str) -> str:
    profiles = request_json(f"{base_url}/profiles")
    assert isinstance(profiles, list)
    for profile in profiles:
        if (
            isinstance(profile, dict)
            and profile.get("voice_type") == "preset"
            and profile.get("preset_engine") == "qwen_custom_voice"
            and profile.get("preset_voice_id") == "Sohee"
        ):
            return str(profile["id"])
    created = request_json(
        f"{base_url}/profiles",
        "POST",
        {
            "name": "Sohee Korean Narration",
            "description": "Built-in Qwen CustomVoice Sohee preset",
            "language": "ko",
            "voice_type": "preset",
            "preset_engine": "qwen_custom_voice",
            "preset_voice_id": "Sohee",
            "default_engine": "qwen_custom_voice",
        },
    )
    assert isinstance(created, dict)
    return str(created["id"])


def generate_voice(base_url: str, profile_id: str, text: str, output: Path) -> None:
    if output.is_file():
        return
    generation = request_json(
        f"{base_url}/generate",
        "POST",
        {
            "profile_id": profile_id,
            "text": text,
            "language": "ko",
            "engine": "qwen_custom_voice",
            "model_size": "0.6B",
            "normalize": True,
        },
    )
    assert isinstance(generation, dict)
    generation_id = str(generation["id"])
    deadline = time.time() + 900
    while time.time() < deadline:
        history = request_json(f"{base_url}/history/{generation_id}")
        assert isinstance(history, dict)
        if history.get("status") == "completed":
            with urllib.request.urlopen(
                f"{base_url}/audio/{generation_id}", timeout=60
            ) as response:
                output.write_bytes(response.read())
            return
        if history.get("status") == "failed":
            raise RuntimeError(f"VoiceBox generation failed: {history}")
        time.sleep(2)
    raise TimeoutError(f"VoiceBox generation timed out: {generation_id}")


def ass_time(seconds: float) -> str:
    centiseconds = round(seconds * 100)
    hours, remainder = divmod(centiseconds, 360_000)
    minutes, remainder = divmod(remainder, 6_000)
    whole_seconds, fraction = divmod(remainder, 100)
    return f"{hours}:{minutes:02d}:{whole_seconds:02d}.{fraction:02d}"


def srt_time(seconds: float) -> str:
    milliseconds = round(seconds * 1000)
    hours, remainder = divmod(milliseconds, 3_600_000)
    minutes, remainder = divmod(remainder, 60_000)
    whole_seconds, fraction = divmod(remainder, 1000)
    return f"{hours:02d}:{minutes:02d}:{whole_seconds:02d},{fraction:03d}"


def escape_ass(text: str) -> str:
    return text.replace("\\", "\\\\").replace("{", "\\{").replace("}", "\\}")


def build_ass(plan: dict, clip: dict) -> str:
    end = ass_time(float(clip["duration"]))
    events = [
        f"Dialogue: 0,0:00:00.00,{end},Title,,0,0,0,,{escape_ass(plan['topic'])}",
        f"Dialogue: 0,0:00:00.00,{end},Subtitle,,0,0,0,,{escape_ass(plan['subtitle'])}",
    ]
    for index, rank in enumerate(range(1, 8)):
        y = 410 + index * 68
        if rank == int(clip["rank"]):
            text = f"{{\\pos(70,{y})\\an5\\c&H3030FF&\\bord6}}{rank}"
            style = "Current"
        else:
            text = f"{{\\pos(70,{y})\\an5}}{rank}"
            style = "Rank"
        events.append(f"Dialogue: 0,0:00:00.00,{end},{style},,0,0,0,,{text}")
    events.extend(
        [
            f"Dialogue: 0,0:00:00.20,{end},Reaction,,0,0,0,,"
            f"{{\\fad(120,160)}}{escape_ass(clip['caption'])}",
            f"Dialogue: 0,0:00:00.00,{end},Source,,0,0,0,,"
            f"@{escape_ass(clip['creator'])} · private review",
        ]
    )
    header = """[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920
ScaledBorderAndShadow: yes
WrapStyle: 2

[V4+ Styles]
Format: Name,Fontname,Fontsize,PrimaryColour,SecondaryColour,OutlineColour,BackColour,Bold,Italic,Underline,StrikeOut,ScaleX,ScaleY,Spacing,Angle,BorderStyle,Outline,Shadow,Alignment,MarginL,MarginR,MarginV,Encoding
Style: Title,Malgun Gothic,70,&H0000FFFF,&H0000FFFF,&H00101010,&HA0000000,-1,0,0,0,100,100,-1,0,1,6,1,8,30,30,45,1
Style: Subtitle,Malgun Gothic,48,&H00FFFFFF,&H00FFFFFF,&H00101010,&HA0000000,-1,0,0,0,100,100,0,0,1,5,1,8,30,30,128,1
Style: Rank,Malgun Gothic,42,&H00F2F2F2,&H00F2F2F2,&H00101010,&H70000000,-1,0,0,0,100,100,0,0,1,5,1,7,0,0,0,1
Style: Current,Malgun Gothic,54,&H003030FF,&H003030FF,&H00FFFFFF,&H90000000,-1,0,0,0,100,100,0,0,1,6,1,7,0,0,0,1
Style: Reaction,Malgun Gothic,66,&H00FFFFFF,&H00FFFFFF,&H00101010,&HC0000000,-1,0,0,0,100,100,-1,0,3,12,0,2,90,90,285,1
Style: Source,Malgun Gothic,24,&H00EEEEEE,&H00EEEEEE,&H00101010,&H70000000,0,0,0,0,100,100,0,0,1,3,0,1,32,32,24,1

[Events]
Format: Layer,Start,End,Style,Name,MarginL,MarginR,MarginV,Effect,Text
"""
    return header + "\n".join(events) + "\n"


def ffmpeg_subtitle_path(path: Path) -> str:
    return path.resolve().as_posix().replace(":", "\\:")


def has_audio(path: Path) -> bool:
    result = subprocess.run(
        [
            "ffprobe",
            "-v",
            "error",
            "-select_streams",
            "a",
            "-show_entries",
            "stream=index",
            "-of",
            "csv=p=0",
            str(path),
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return bool(result.stdout.strip())


def render_clip(
    source: Path,
    output: Path,
    clip: dict,
    narration: Path | None,
    ass_path: Path | None,
    *,
    start: float,
    duration: float,
) -> None:
    frames = round(duration * 30)
    zoom_start = float(clip["zoom_start"])
    zoom_end = float(clip["zoom_end"])
    zoom = f"{zoom_start:.4f}+({zoom_end - zoom_start:.4f})*on/{frames}"
    filters = (
        "[0:v]split=2[bg][fg];"
        "[bg]scale=1080:1920:force_original_aspect_ratio=increase,"
        "crop=1080:1920,gblur=sigma=34,eq=brightness=-0.20:saturation=0.9[back];"
        "[fg]scale=1080:1920:force_original_aspect_ratio=decrease[front];"
        "[back][front]overlay=(W-w)/2:(H-h)/2,setsar=1,"
        f"zoompan=z='{zoom}':x='iw/2-(iw/zoom/2)':"
        "y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=30,"
        "drawbox=x=0:y=0:w=iw:h=220:color=black@0.36:t=fill,"
        "drawbox=x=18:y=365:w=105:h=490:color=black@0.25:t=fill"
    )
    if clip.get("emphasis") in {"circle", "focus-box"}:
        filters += (
            ",drawbox=x=690:y=560:w=250:h=250:color=red@0.85:t=7:"
            "enable='between(t,3.0,5.3)'"
        )
    if ass_path is not None:
        filters += f",subtitles='{ffmpeg_subtitle_path(ass_path)}'"
    filters += "[v]"

    source_has_audio = has_audio(source)
    command = [
        "ffmpeg",
        "-y",
        "-hide_banner",
        "-loglevel",
        "warning",
        "-ss",
        f"{start:.3f}",
        "-i",
        str(source),
    ]
    if narration is not None:
        command += ["-i", str(narration)]
    elif not source_has_audio:
        command += [
            "-f",
            "lavfi",
            "-t",
            f"{duration:.3f}",
            "-i",
            "anullsrc=channel_layout=stereo:sample_rate=48000",
        ]
    if narration is not None:
        if source_has_audio:
            filters += (
                ";[0:a]volume=0.22,aresample=48000[src];"
                f"[1:a]volume=1.15,apad,atrim=0:{duration:.3f}[voice];"
                "[src][voice]amix=inputs=2:duration=longest:normalize=0[a]"
            )
        else:
            filters += f";[1:a]volume=1.15,apad,atrim=0:{duration:.3f}[a]"
    command += ["-filter_complex", filters, "-map", "[v]"]
    if narration is not None:
        command += ["-map", "[a]"]
    elif source_has_audio:
        command += ["-map", "0:a?"]
    else:
        command += ["-map", "1:a"]
    command += [
        "-t",
        f"{duration:.3f}",
        "-c:v",
        "h264_nvenc",
        "-preset",
        "p5",
        "-cq",
        "20",
        "-b:v",
        "0",
        "-r",
        "30",
        "-pix_fmt",
        "yuv420p",
        "-c:a",
        "aac",
        "-b:a",
        "160k",
        "-ar",
        "48000",
        "-movflags",
        "+faststart",
        str(output),
    ]
    run(command)


def write_srt(plan: dict, output: Path) -> None:
    blocks = []
    cursor = 0.0
    for index, clip in enumerate(plan["clips"], start=1):
        blocks.append(
            f"{index}\n{srt_time(cursor + 0.15)} --> {srt_time(cursor + 6.85)}\n"
            f"{clip['narration']}\n"
        )
        cursor += 7.0
    output.write_text("\n".join(blocks), encoding="utf-8")


def build(project_dir: Path) -> Path:
    plan = json.loads((project_dir / "render_plan.json").read_text(encoding="utf-8"))
    source_dir = project_dir / "source_media"
    audio_dir = project_dir / "audio"
    caption_dir = project_dir / "captions"
    core_dir = project_dir / "selects" / "core"
    handle_dir = project_dir / "selects" / "handles"
    work_dir = project_dir / "work"
    output_dir = project_dir / "output"
    qa_dir = project_dir / "qa"
    for directory in (
        audio_dir,
        caption_dir,
        core_dir,
        handle_dir,
        work_dir,
        output_dir,
        qa_dir,
    ):
        directory.mkdir(parents=True, exist_ok=True)

    base_url = resolve_voicebox_url()
    profile_id = resolve_sohee_profile(base_url)
    concat_lines = []
    mid_frames = []
    for clip in plan["clips"]:
        number = int(clip["sequence"])
        slug = str(clip["slug"])
        source = source_dir / str(clip["source"])
        voice = audio_dir / f"{number:02d}_{slug}_sohee.wav"
        generate_voice(base_url, profile_id, str(clip["narration"]), voice)
        ass_path = caption_dir / f"{number:02d}_{slug}.ass"
        ass_path.write_text(build_ass(plan, clip), encoding="utf-8")
        core_path = core_dir / f"{number:02d}_{slug}.mp4"
        render_clip(
            source,
            core_path,
            clip,
            voice,
            ass_path,
            start=float(clip["start"]),
            duration=7.0,
        )
        handle_path = handle_dir / f"{number:02d}_{slug}_handles.mp4"
        render_clip(
            source,
            handle_path,
            clip,
            None,
            None,
            start=float(clip["handle_in"]),
            duration=9.0,
        )
        concat_lines.append(f"file '{core_path.resolve().as_posix()}'")
        frame = qa_dir / f"{number:02d}_{slug}_mid.jpg"
        run(
            [
                "ffmpeg",
                "-y",
                "-hide_banner",
                "-loglevel",
                "error",
                "-ss",
                "3.5",
                "-i",
                str(core_path),
                "-frames:v",
                "1",
                "-vf",
                "scale=270:480",
                str(frame),
            ]
        )
        mid_frames.append(frame)

    concat_path = work_dir / "concat.txt"
    concat_path.write_text("\n".join(concat_lines) + "\n", encoding="utf-8")
    final_path = output_dir / "bowling_top7_private_review.mp4"
    run(
        [
            "ffmpeg",
            "-y",
            "-hide_banner",
            "-loglevel",
            "warning",
            "-f",
            "concat",
            "-safe",
            "0",
            "-i",
            str(concat_path),
            "-c:v",
            "copy",
            "-c:a",
            "aac",
            "-b:a",
            "160k",
            "-ar",
            "48000",
            "-af",
            "aresample=async=1:first_pts=0",
            "-movflags",
            "+faststart",
            str(final_path),
        ]
    )
    srt_path = caption_dir / "bowling_top7_private_review.srt"
    write_srt(plan, srt_path)
    combined = project_dir / "combined"
    combined.mkdir(exist_ok=True)
    shutil.copy2(final_path, combined / "selects_combined.mp4")
    shutil.copy2(final_path, project_dir / "private_review.mp4")

    montage = qa_dir / "core_mid_montage.jpg"
    command = ["ffmpeg", "-y", "-hide_banner", "-loglevel", "error"]
    for frame in mid_frames:
        command += ["-i", str(frame)]
    command += [
        "-filter_complex",
        "xstack=inputs=7:layout=0_0|270_0|540_0|810_0|135_480|405_480|675_480:fill=black",
        "-frames:v",
        "1",
        str(montage),
    ]
    run(command)

    capcut = project_dir / "capcut_import"
    for directory in (capcut / "media", capcut / "audio", capcut / "captions"):
        directory.mkdir(parents=True, exist_ok=True)
    for path in core_dir.glob("*.mp4"):
        shutil.copy2(path, capcut / "media" / path.name)
    for path in audio_dir.glob("*.wav"):
        shutil.copy2(path, capcut / "audio" / path.name)
    shutil.copy2(srt_path, capcut / "captions" / srt_path.name)
    return final_path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-dir", type=Path, default=ROOT)
    args = parser.parse_args()
    print(build(args.project_dir.resolve()))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
