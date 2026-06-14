# 기존 Skills 원문 추출

감사 대상 원본:

- `C:\Users\llorr\.codex\skills\viral-source-highlight-editor\SKILL.md`
- `C:\Users\llorr\.codex\skills\video-editing-compliance-skill\SKILL.md`

원본 기준:

- `viral-source-highlight-editor/SKILL.md` 패치 전 SHA-256:
  `F4DEBFF0B6B2F1BF0C548C798740FCEED455D4C06AC4D8FBBB1674AE3EBA9418`
- `video-editing-compliance-skill/SKILL.md` SHA-256:
  `1F9CC801968FFC81C6FCBE24681D2916F54DA9775CCBC603D38DA279A8CB3A7D`

## 조항 001

파일: `viral-source-highlight-editor/SKILL.md`
위치: `Mode Gate`

원문:

"""
Private-review approval is not public-upload permission. Never remove
watermarks, conceal attribution, evade copyright matching, or describe
unknown-rights footage as publish-safe.
"""

분류:

- 로고/워터마크
- 권리

## 조항 002

파일: `viral-source-highlight-editor/SKILL.md`
위치: `2. Research Real Viral Sources`

원문:

"""
Record every candidate in `source_candidates.md`:

- Exact direct source URL, platform, creator, and current visible metrics.
- Whole source duration, upload date, and checked date.
- Originality and reupload evidence.
- Candidate range, proposed transition time, and acquisition route.
- YouTube duplicate-check status.
- Rights status and risk.
"""

분류:

- 소스 선택
- 컷 편집
- 중복 검증
- 권리

## 조항 003

파일: `viral-source-highlight-editor/SKILL.md`
위치: `3. Trace Originals And Check YouTube`

원문:

"""
For every selected clip, search YouTube with at least the creator handle,
caption keywords, event description, and visible watermark. Save queries,
checked date, and result URLs in `youtube_duplicate_report.md`.
"""

분류:

- 중복 검증
- 로고/워터마크

## 조항 004

파일: `viral-source-highlight-editor/SKILL.md`
위치: `3. Trace Originals And Check YouTube`

원문:

"""
Never claim a clip is absent from all of YouTube. When no matching upload is
found, write `검색한 범위에서 일치본 미발견`.
"""

분류:

- 중복 검증

## 조항 005

파일: `viral-source-highlight-editor/SKILL.md`
위치: `5. Define Exact Cuts`

원문:

"""
For each selected item, record:

- Whole source duration.
- Core cut of 7-9 seconds.
- Handle cut with exactly one extra second before and after the core.
- Exact `transition_at`, normally equal to `core_out`.
- Setup, action, reaction, and tail beats.
- Acquisition method and timing confidence.
"""

분류:

- 컷 편집
- 수치 규칙

## 조항 006

파일: `viral-source-highlight-editor/SKILL.md`
위치: `5. Define Exact Cuts`

원문:

"""
Keep enough setup to understand the event, but move the strongest readable
information into the first 1-2 seconds. A reaction without its cause, or a
setup without its payoff, is not a complete selection.
"""

분류:

- 컷 편집
- 훅

## 조항 007

파일: `viral-source-highlight-editor/SKILL.md`
위치: `6. Edit Vertical Ranking Selects`

원문:

"""
Render 1080x1920 H.264.

- Put a yellow topic title and white `랭킹 TOP7` at the top.
- Put the rank list on the left and highlight the current rank in red.
- Put large, scene-specific Korean reaction or translation captions near the
  visual center without covering faces or the payoff.
- Keep the action subject centered.
- For horizontal sources, keep the full source centered over a blurred
  full-frame background.
- Use mild crops, zooms, or tracking only when they improve readability.
- Use motion-matched hard cuts, pushes, or whips at recorded transition times.
- Preserve useful source audio.
"""

분류:

- 자막
- 줌인
- 레이아웃
- 전환
- 오디오

## 조항 008

파일: `viral-source-highlight-editor/SKILL.md`
위치: `7. Plan Music And Effects`

원문:

"""
For YouTube Audio Library BGM or SFX, record in `audio_plan.md`:

- Exact title and artist.
- Official library page or captured library evidence.
- Download date.
- License and attribution requirement.
- Intended timeline range and mix level.
"""

분류:

- 효과음
- 음악
- 권리

## 조항 009

파일: `viral-source-highlight-editor/SKILL.md`
위치: `9. Verify`

원문:

"""
Verify every MP4 with `ffprobe`, inspect the QA montage, decode Korean files
as UTF-8, and reject replacement characters or mojibake. Do not claim
completion if the promised event is absent from any selected range.
"""

분류:

- 검증
- 한국어

## 조항 010

파일: `video-editing-compliance-skill/SKILL.md`
위치: `1-1 / 1. 동적 가변 확장`

원문:

"""
입력 비디오의 화면 배율을 고정하지 않고, 재생 타임라인 `t`에 따라 기본 크기 대비 **108%에서 112% 범위** 내에서 미세하게 유동하는 동적 가변 연산 스케일을 적용한다.
"""

분류:

- 줌인
- 수치 규칙

## 조항 011

파일: `video-editing-compliance-skill/SKILL.md`
위치: `1-1 / 2. 좌표 오프셋 및 중심축 다변화`

원문:

"""
영상의 기하학적 중심 좌표를 출력 레이아웃에 맞게 조정하기 위해 **X축 방향 +3%, Y축 방향 -2%** 정밀 이동 배치를 지원한다.
"""

분류:

- 위치
- 수치 규칙

## 조항 012

파일: `video-editing-compliance-skill/SKILL.md`
위치: `1-1 / 4. 재생 속도 최적화 및 렌더링 프로파일 조정`

원문:

"""
비디오의 기본 타임라인 속도를 **1.05배속**으로 미세 조정할 수 있다.

화면 색상 값은 **±3% 범위 내**에서 자동 보정할 수 있다.
"""

분류:

- 속도
- 색상
- 수치 규칙

## 조항 013

파일: `video-editing-compliance-skill/SKILL.md`
위치: `1-2 / 1. 장면 분할 및 정밀 컷 구조화`

원문:

"""
비디오 소스를 장시간 연속 재생하지 않고, 타임라인 분석을 통해 **9초 미만**, 권장 **3~5초 단위**의 컷 단위로 분할하여 재조합할 수 있다.
"""

분류:

- 컷 편집
- 수치 규칙

## 조항 014

파일: `video-editing-compliance-skill/SKILL.md`
위치: `1-2 / 2. 비동기식 오디오/비디오 오프셋 가공`

원문:

"""
* 이전 장면 사운드가 다음 화면으로 **0.5초 오버랩되는 L-cut**
* 다음 장면 사운드가 이전 비디오 종료 전에 **0.5초 선출력되는 J-cut**
"""

분류:

- 전환
- 오디오
- 수치 규칙

## 조항 015

파일: `video-editing-compliance-skill/SKILL.md`
위치: `2-2. 구조 분석을 위한 정지 프레임 배치`

원문:

"""
영상의 극적 전개나 연출적 특징이 드러나는 최적의 클라이맥스 구간 직전에 화면을 **1~2초간 일시 정지**시킨다.

이 정지된 화면 위에 다음 요소를 덧씌워 분석적 의도를 명확히 표현한다.

* 단서 자막
* 시각적 화살표
* 그래픽 효과
* 키워드 라벨
* 분석 포인트 박스
* 장면 구조 설명
* 비교 프레임
"""

분류:

- 화살표 강조
- 정지 프레임
- 수치 규칙

## 조항 016

파일: `video-editing-compliance-skill/SKILL.md`
위치: `2-4. 제작 프로세스 증빙 로그 구축 및 데이터 아카이빙`

원문:

"""
다음 데이터를 기록한다.

* 대본 텍스트 파일
* 개별 음성 트랙
* 컷 분할 좌표
* 특수효과 레이어 사양
* 사용 소스 목록
* 라이선스 문서 경로
* 편집 타임라인 구조
* 생성형 AI 사용 로그
* 인간 검수 체크리스트
* 최종 승인자
* 발행 설명란 문구
* 원본 소스 공식 출처
"""

분류:

- 제작 로그
- 컷 편집
- 효과음
- 권리
