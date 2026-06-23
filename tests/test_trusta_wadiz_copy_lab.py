from pathlib import Path
import re


LAB = Path(__file__).parents[1] / "trusta-medical-growth" / "wadiz-copy-lab"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_dashboard_and_ten_standalone_variants_exist() -> None:
    assert (LAB / "index.html").is_file()
    variants = sorted((LAB / "variants").glob("hm-*.html"))
    assert len(variants) == 10
    assert [path.stem for path in variants] == [f"hm-{index:02d}" for index in range(1, 11)]


def test_dashboard_exposes_twenty_reference_patterns_and_five_flows() -> None:
    html = read(LAB / "index.html")
    assert len(re.findall(r'data-pattern-id="\d{2}"', html)) == 20
    assert len(re.findall(r'data-flow-id="flow-[a-e]"', html)) == 5
    assert "5단 근거 검증 파이프라인" in html
    for stage in ("출처 확인", "Vault 지식 대조", "Graphify 관계 검증", "법률·현지 검색", "사람 최종 승인"):
        assert stage in html


def test_variants_are_responsive_and_contain_priority_evidence() -> None:
    required = (
        "세계로 뻗는 성장 기회",
        "국내와 세계 시장 비교",
        "해외 진출 전후",
        "현지화 Before / After",
        "하나의 콘텐츠, 모든 채널로",
        "성과가 다시 기획으로 돌아오는 루프",
    )
    for path in sorted((LAB / "variants").glob("hm-*.html")):
        html = read(path)
        assert '<meta name="viewport"' in html
        assert '<main' in html
        for copy in required:
            assert copy in html


def test_claims_have_source_and_verification_metadata() -> None:
    html_files = [LAB / "index.html", *sorted((LAB / "variants").glob("hm-*.html"))]
    claim_pattern = re.compile(r'<[^>]+data-claim-status="(?:verified|context|unverified)"[^>]*>')
    for path in html_files:
        html = read(path)
        claims = claim_pattern.findall(html)
        assert claims, path
        for claim in claims:
            assert "data-source-url=" in claim
    combined = "\n".join(read(path) for path in html_files)
    assert "1인당 800만 원" not in combined
    assert "1인당 700만 원" not in combined


def test_shared_css_matches_layout_contract() -> None:
    css = read(LAB / "assets" / "styles.css")
    assert "max-width: 1200px" in css
    assert "padding: 96px 0" in css
    assert "gap: 24px" in css
    assert "aspect-ratio: 16 / 9" in css
    assert "aspect-ratio: 4 / 3" in css
    assert "@media (max-width: 760px)" in css
    assert "padding: 56px 0" in css


def test_no_marketing_claim_is_presented_as_a_legal_guarantee() -> None:
    combined = "\n".join(
        read(path)
        for path in [LAB / "index.html", *sorted((LAB / "variants").glob("hm-*.html"))]
    )
    forbidden = ("법적으로 완벽", "100% 안전", "매출 보장", "해외 진출 보장", "무조건 성장")
    for phrase in forbidden:
        assert phrase not in combined
