# 기존 Skills 적용 여부 체크리스트

감사일: 2026-06-15
감사 대상: `private_review.mp4`, 7개 코어 컷, 7개 핸들 컷, 제작 문서,
렌더 스크립트, QA 몽타주

## 전체 체크리스트

| 번호 | 기존 Skills 원문 위치 | 원문 요약 | 실제 적용 여부 | 근거 파일 | 근거 타임코드 | 판정 |
|---:|---|---|---|---|---|---|
| 001 | Viral / §2 | 실제 TikTok 우선 소스와 지표 기록 | 적용됨 | `source_candidates.md`, `selection_manifest.md` | 전체 | PASS |
| 002 | Viral / §5 | 원본 길이와 정확한 코어·핸들 구간 | 적용됨 | `cut_manifest.json` | 소스별 표 참조 | PASS |
| 003 | Viral / §5 | setup-action-reaction-tail 기록 | 적용됨 | `cut_manifest.json` | 각 8초 | PASS |
| 004 | 신규 요구 | 소스를 선택한 이유 | 적용됨 | `selection_manifest.md` Hook reason | 전체 | PASS |
| 005 | 신규 요구 | 시작점을 선택한 이유 | 강한 장면 설명은 있으나 시작점별 문장 없음 | `edit_plan.md`, `selection_manifest.md` | 전체 | PARTIAL |
| 006 | 신규 요구 | 종료점을 선택한 이유 | reaction/tail 수치만 있고 종료 이유 문장 없음 | `cut_manifest.json` | 전체 | PARTIAL |
| 007 | 신규 요구 | 앞부분을 자른 이유 | 근거 없음 | 없음 | 없음 | FAIL |
| 008 | 신규 요구 | 뒷부분을 자른 이유 | 근거 없음 | 없음 | 없음 | FAIL |
| 009 | 신규 요구 | 컷과 대본·자막 문장 연결 | 순서상 연결되지만 명시적 링크 없음 | `render_plan.json`, `text_options.md` | 각 0-4초, 4-8초 | PARTIAL |
| 010 | 신규 요구 | 컷별 적용 Skill 조항 | 근거 없음 | 없음 | 없음 | FAIL |
| 011 | 신규 요구 | 댓글 좋아요 상위 2~3개 원문·수치 | 댓글 총수만 있으며 댓글 원문과 좋아요 없음 | `cut_manifest.json` | 없음 | FAIL |
| 012 | 신규 요구 | 댓글 감정·궁금증을 대본에 반영 | 근거 없음 | 없음 | 없음 | FAIL |
| 013 | 신규 요구 | 말투와 사실 구조 분리 | 근거 없음 | 없음 | 없음 | FAIL |
| 014 | Viral / §7 | BGM 제목·아티스트·라이선스·믹스 | 적용됨 | `audio_plan.md`, `evidence/youtube_audio_library_evidence.md` | 00:00-00:56 | PASS |
| 015 | 신규 요구 | 효과음 폴더 인벤토리 및 장면 자동 매칭 | SFX를 쓰지 않은 이유만 기록 | `audio_plan.md` | 전체 | PARTIAL |
| 016 | 신규 요구 | SFX 파일명 규칙 | 기존 Skills에 없었음 | 패치 전 없음 | 없음 | MISSING_IN_SKILL |
| 017 | Viral / Mode Gate | 워터마크·출처 은폐 금지 | 제거 동작 없음, 출처 링크 유지 | `source_trace.md`, QA 몽타주 | 전체 | PASS |
| 018 | 신규 요구 | 로고·워터마크·원본 자막·화면 글씨별 판정표 | 워터마크 존재 근거만 있고 소스별 유지/교체 이유 없음 | `source_trace.md`, QA 몽타주 | 전체 | PARTIAL |
| 019 | Viral / §3 | YouTube 검색어·URL·일시·결과 | 클립당 검색 1회 기록 | `youtube_duplicate_report.md` | 없음 | PARTIAL |
| 020 | 신규 요구 | 키워드·핵심 문장·워터마크 등 다중 검색 | 단일 결합 검색어만 사용 | `youtube_duplicate_report.md` | 없음 | FAIL |
| 021 | 신규 요구 | 대표 프레임 3~5장 역검색 패키지 | 이번 감사에서 3장씩 생성, 수동 확인은 대기 | `audit/reverse_search_frames/` | 코어 1초·4초·7초 | NEEDS_HUMAN_REVIEW |
| 022 | Compliance / §2-2 | 빨간 화살표 강조 | 기존 Skill에는 선택지가 있으나 영상에는 없음 | `build_private_review.ps1`, QA 몽타주 | 전체 | FAIL |
| 023 | 신규 요구 | 빨간 원형 강조 | 기존 Skills에 없었고 영상에도 없음 | 패치 전 없음 | 전체 | MISSING_IN_SKILL |
| 024 | Viral / §6 | 읽기 개선용 줌·트래킹 | 전 장면 동일한 약 1.06배와 10px 이동 | `build_private_review.ps1` | 전체 | PARTIAL |
| 025 | 신규 요구 | 표정·물체·반전별 다양한 줌 패턴 | 장면별 차등 없음 | `build_private_review.ps1` | 전체 | FAIL |
| 026 | 신규 요구 | 좌우반전 판단 | 적용 안 됨; 권리 미확정·텍스트·워터마크 때문에 결과는 적절하나 사유 로그 없음 | QA 몽타주, `rights_report.md` | 전체 | PARTIAL |
| 027 | Compliance / §1-1 | 108-112% 동적 줌 | 약 106%로 렌더 | `scale=1166:2074` | 전체 | FAIL |
| 028 | Compliance / §1-1 | X +3%, Y -2% 오프셋 | 중앙 기준 ±10px 사인 이동, 지정 오프셋 아님 | `build_private_review.ps1` | 전체 | FAIL |
| 029 | Compliance / §1-1 | 1.05배속 | 적용 또는 미적용 이유 없음 | `build_private_review.ps1` | 전체 | FAIL |
| 030 | Compliance / §1-1 | 색상 ±3% | contrast +2.5%, saturation +4% | `build_private_review.ps1` | 전체 | PARTIAL |
| 031 | Compliance / §1-1 | 출력 fps | 프로젝트 권장 30fps로 정규화 | `build_private_review.ps1`, `qa/verification_report.md` | 전체 | PASS |
| 032 | Compliance / §1-2 | 9초 미만 컷 | 모든 코어 8초 | `qa/verification_report.md` | 항목당 8초 | PASS |
| 033 | Compliance / §1-2 | J/L-cut 0.5초 | 하드 컷 사용 이유는 있으나 오디오 오프셋 미적용 이유 없음 | `edit_plan.md` | 8초 간격 | PARTIAL |
| 034 | Compliance / §2-2 | 1~2초 정지 프레임 | 분석형이 아닌 랭킹형이라 미적용했으나 사유 문서 없음 | `cut_manifest.json` format_type | 전체 | PARTIAL |
| 035 | Viral / §6 | 제목·TOP7·좌측 순위·빨간 현재 순위 | 적용됨 | QA 몽타주 | 전체 | PASS |
| 036 | Viral / §6 | 큰 한국어 장면 자막 | 적용됨, 얼굴·핵심 반응을 대체로 피함 | `captions/*.ass`, QA 몽타주 | 각 0-4초, 4-8초 | PASS |
| 037 | 신규 요구 | 원본 화면 글씨와 새 자막 충돌 판단 | 영어 원문이 다수 남아 정보가 겹치지만 결정 로그 없음 | QA 몽타주 | 1~6위 | PARTIAL |
| 038 | Viral / §9 | MP4·UTF-8·QA 검증 | 적용됨 | `qa/verification_report.md` | 전체 | PASS |
| 039 | 신규 요구 | 반복 가능한 HTML·PNG·JSON 템플릿 | 패치 전 기존 Skills에 없었음 | 패치 전 없음 | 없음 | MISSING_IN_SKILL |
| 040 | Rights Boundary | 공개 업로드 권리 구분 | 7개 모두 permission-required로 명확히 기록 | `rights_report.md` | 전체 | SOURCE_RIGHTS_RISK |

## 컷별 편집 근거 감사

아래 표의 `시작·종료 이유`는 기존 산출물에서 직접 확인 가능한 비트와 화면을
바탕으로 이번 감사에서 복원한 편집 해석이다. 기존 제작 당시 기록이 아니므로
`복원 감사`로 표시하며, 향후에는 렌더 전에 작성해야 한다.

| 순위 | 소스 | 원본 범위 | 기존 선택 이유 | 복원된 시작 이유 | 복원된 종료 이유 | 앞·뒤 제거 이유 기록 | 연결 자막 | 판정 |
|---:|---|---|---|---|---|---|---|---|
| 1 | C01 | 10.5-18.5 | 엄마를 찾고 표정이 풀리는 감정 훅 | 시선 탐색이 읽히기 시작하는 지점 | 미소와 안도 반응 뒤 1초 여운 확보 | 기존 기록 없음 | `엄마 찾은 순간` → `표정이 한 번에 풀렸다` | PARTIAL |
| 2 | C06 | 6.0-14.0 | 소식을 읽고 두 사람이 주저앉는 큰 동작 | 케이크 문구 인지 직전 | 주저앉는 동작과 놀람 표정이 완성된 뒤 | 기존 기록 없음 | `아기 온대요` → `그 자리에서 주저앉음` | PARTIAL |
| 3 | C09 | 8.0-16.0 | 뽀뽀 후 신생아 미소 | 오빠가 접근해 원인이 읽히는 지점 | 아기 미소가 충분히 유지된 뒤 | 기존 기록 없음 | `뽀뽀 한 번에` → `표정이 사르르` | PARTIAL |
| 4 | C02 | 5.5-13.5 | 무례한 말 뒤 시어머니 개입 | 약혼자의 발언이 시작되는 지점 | 시어머니의 즉각적 편들기 반응 뒤 | 기존 기록 없음 | `누가 그렇게 키웠어?` → `시어머니가 바로 편들었다` | PARTIAL |
| 5 | C13 | 10.0-18.0 | 돌 가격에 대한 전신 반응 | 가격·상황 인지가 가능한 지점 | 몸을 돌리며 황당함을 드러낸 뒤 | 기존 기록 없음 | `이 돌을 돈 주고 샀다고?` → `표정으로 이미 대답함` | PARTIAL |
| 6 | C10 | 16.0-24.0 | 졸린 표정과 거부 몸짓 | 아이의 아침 상태가 한눈에 보이는 지점 | 거부 반응과 표정이 반복 확인된 뒤 | 기존 기록 없음 | `나한테 아침 인사하지 마` → `아침형 인간은 아님` | PARTIAL |
| 7 | C07 | 176.0-184.0 | 자기 물건을 알아보는 인지 반응 | 선물을 확인해 의문이 시작되는 지점 | 정체를 알아챈 질문과 주변 반응 뒤 | 기존 기록 없음 | `잠깐, 그거 내 건데?` → `선물의 정체를 알아챘다` | PARTIAL |

## 원본 글씨·워터마크 관찰

- QA 몽타주에서 1~6위 원본 영어 문구가 새 한국어 자막과 함께 보인다.
- 새 그래픽이 출처 표시를 숨기기 위한 용도로 배치된 근거는 없다.
- `source_trace.md`에는 워터마크 계정명 확인이 기록되어 있다.
- 그러나 각 소스별 `keep / replace-clean-source / hold` 결정표가 없어
  편집 의도를 사후에 증명하기 어렵다.
- 권리 미확정 상태이므로 워터마크 제거, 좌우반전, 클린업은 허용하지 않는다.

## 역검색 프레임 상태

- 각 코어 컷의 1초, 4초, 7초 지점에서 3장씩 총 21장을 생성했다.
- 경로: `audit/reverse_search_frames/`
- 이 파일은 Google Lens 또는 다른 이미지 역검색의 수동 입력용이다.
- 이번 자동 감사는 외부 이미지 업로드를 수행하지 않았으므로 실제 역검색 결과는
  `NEEDS_HUMAN_REVIEW`다.
