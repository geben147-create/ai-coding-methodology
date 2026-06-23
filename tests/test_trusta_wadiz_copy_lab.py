from pathlib import Path
from collections import Counter
from html.parser import HTMLParser
import re


LAB = Path(__file__).parents[1] / "trusta-medical-growth" / "wadiz-copy-lab"


REFERENCE_NON_WS = [
    156, 308, 302, 321, 244, 167, 343, 257, 219, 274,
    263, 302, 266, 368, 263, 112, 256, 333, 330, 370,
    213, 408, 364, 229, 212, 132, 212, 275, 184, 144,
    184, 393, 397, 52, 4,
]


class BlockCopyParser(HTMLParser):
    VOID_TAGS = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"}

    def __init__(self) -> None:
        super().__init__()
        self.active = False
        self.depth = 0
        self.current: list[str] = []
        self.blocks: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        classes = dict(attrs).get("class", "") or ""
        if not self.active and "block-copy" in classes.split():
            self.active = True
            self.depth = 1
            self.current = []
        elif self.active and tag not in self.VOID_TAGS:
            self.depth += 1

    def handle_endtag(self, tag: str) -> None:
        if not self.active:
            return
        self.depth -= 1
        if self.depth == 0:
            self.blocks.append("".join(self.current))
            self.active = False

    def handle_data(self, data: str) -> None:
        if self.active:
            self.current.append(data)


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
        expected = required
        if path.name == "hm-06.html":
            expected = (
                "세계로 확장하는 경로",
                "국내와 세계 시장 비교",
                "현지화 Before / After",
                "하나의 콘텐츠, 모든 채널로",
                "성과가 다시 기획으로 돌아오는 루프",
            )
        for copy in expected:
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


def test_hm06_rebuild_matches_japan_reference_contract() -> None:
    html = read(LAB / "variants" / "hm-06.html")
    css = read(LAB / "assets" / "hm-06-white.css")
    assert len(re.findall(r'<section[^>]+data-block="\d{2}"', html)) == 35
    roles = re.findall(r'data-role="([A-Za-z_]+)"', html)
    assert Counter(roles) == Counter(
        {
            "Hook": 2,
            "Agitation": 2,
            "Solution": 5,
            "Evidence": 7,
            "FAQ": 3,
            "Brand_Story": 3,
            "Feature": 2,
            "Price": 6,
            "Mixed": 3,
            "Visual_Only": 2,
        }
    )

    parser = BlockCopyParser()
    parser.feed(html)
    assert len(parser.blocks) == 35
    actual = [len(re.sub(r"\s+", "", block)) for block in parser.blocks]
    for index, (target, value) in enumerate(zip(REFERENCE_NON_WS, actual), start=1):
        assert abs(value - target) / target <= 0.10, (index, target, value)
    assert abs(sum(actual) - sum(REFERENCE_NON_WS)) / sum(REFERENCE_NON_WS) <= 0.02

    assert "background: #ffffff" in css
    assert "max-width: 1200px" in css
    assert "padding: 96px 0" in css
    assert "padding: 56px 0" in css
    assert "grid-template-columns: 45fr 55fr" in css
    assert "aspect-ratio: 16 / 9" in css
    assert "aspect-ratio: 4 / 3" in css


def test_hm06_contains_real_visual_evidence_and_disclosures() -> None:
    html = read(LAB / "variants" / "hm-06.html")
    assert len(re.findall(r'<svg[^>]+data-chart=', html)) >= 4
    assert "세계로 확장하는 경로" in html
    assert "현지화 Before / After" in html
    assert "TRUSTA 직접 수행 성과가 아닌 해외 파트너 운영 데이터" in html
    assert "내부 목표·가정" in html
    assert "경영학석사(MBA)" in html
    assert "김 연 하" not in html
    assert "1987 . 4 . 22" not in html
    assert "XDC9-6F10-04FF-2AFE" not in html
