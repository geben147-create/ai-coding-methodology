from __future__ import annotations

import json
from pathlib import Path

from build_video import build_ass, resolve_voicebox_url


PROJECT_DIR = Path(__file__).resolve().parent


def load_plan() -> dict:
    return json.loads((PROJECT_DIR / "render_plan.json").read_text(encoding="utf-8"))


def test_plan_has_seven_clips_sorted_by_views() -> None:
    clips = load_plan()["clips"]

    assert len(clips) == 7
    assert [clip["views"] for clip in clips] == sorted(
        (clip["views"] for clip in clips), reverse=True
    )
    assert all(clip["duration"] == 7.0 for clip in clips)
    assert all(clip["handle_out"] - clip["handle_in"] == 9.0 for clip in clips)


def test_plan_uses_sohee_without_creator_voice_cloning() -> None:
    plan = load_plan()

    assert plan["narration"]["voice"] == "Sohee"
    assert plan["narration"]["voice_cloning"] is False
    assert plan["narration"]["engine"] == "voicebox-qwen-customvoice"


def test_ass_contains_korean_title_rank_stack_and_source_credit() -> None:
    plan = load_plan()
    ass = build_ass(plan, plan["clips"][0])

    assert "전설의 볼링 기술;;" in ass
    assert "조회수 TOP7" in ass
    assert "@overtime" in ass
    assert "private review" in ass
    assert "\\c&H3030FF&" in ass


def test_voicebox_resolution_prefers_healthy_local_endpoint(monkeypatch) -> None:
    def fake_health(url: str) -> bool:
        return url.endswith(":8000")

    monkeypatch.setattr("build_video.voicebox_is_healthy", fake_health)

    assert resolve_voicebox_url() == "http://127.0.0.1:8000"
