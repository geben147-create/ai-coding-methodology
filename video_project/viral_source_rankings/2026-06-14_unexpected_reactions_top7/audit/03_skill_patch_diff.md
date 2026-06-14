# Skills 패치 내역

## 패치 원칙

- 새 Skill을 만들지 않았다.
- 기존 `viral-source-highlight-editor`의 원문 234줄을 삭제하거나 수정하지 않았다.
- 기존 `video-editing-compliance-skill`은 이미 수치·권리·정지 프레임·화살표·
  제작 로그 규칙을 보유하므로 수정하지 않았다.
- 중복을 피하기 위해 누락된 감사 계약과 템플릿 계약만 기존 Skill에 추가했다.

## 원본 보존 확인

| 파일 | 패치 전 | 패치 후 | 결과 |
|---|---:|---:|---|
| `viral-source-highlight-editor/SKILL.md` | 234줄 / `F4DEBFF0...A9418` | 267줄 / `314F44D4...66ADD` | 기존 원문 보존, 하위 섹션만 추가 |
| `video-editing-compliance-skill/SKILL.md` | 770줄 / `1F9CC801...3A7D` | 변경 없음 | 수정하지 않음 |

## 추가된 항목

### 추가 001

추가 위치:

- `viral-source-highlight-editor/SKILL.md`
- `9. Verify` 다음, 기존 `Rights Boundary` 앞

추가 이유:

- 컷 시작·종료·앞뒤 제거 이유와 적용하지 않은 효과의 근거 규칙이 없었음.
- 댓글 상위 반응, 다중 YouTube 검색, 역검색 프레임, 강조 그래픽,
  좌우반전 판단, 채널 템플릿 규칙이 없거나 불충분했음.

추가 내용:

"""
## 10. Audit Editing Decisions And Build The Channel Template

For a finished or review render, create an evidence audit before describing
the package as complete. Record why each source, start point, end point, front
trim, back trim, caption, visual emphasis, audio cue, watermark decision, zoom,
and flip decision was used or intentionally omitted.

Do not infer audience reactions. When comments are accessible, retain the top
two or three relevant comments with visible like counts and map their emotion
or question to the script. Keep learned tone separate from factual structure.

Run more than one YouTube query class per selected clip and save three to five
representative frames for manual Google Lens or reverse-image review. Never
remove third-party logos, watermarks, or attribution to conceal the source.

Use red arrows, red circles, varied zoom patterns, SFX, and horizontal flips
only when the scene benefits and the rights and accuracy rules permit them.
Log every non-application reason. Flip only owned or licensed footage, and do
not flip readable text, logos, directional information, accuracy-sensitive
content, or footage where flipping could look like source concealment.

Build reusable 1080x1920 channel templates as HTML, PNG, and JSON. Accept a
user- or image-tool-created transparent character PNG, keep its opacity within
72-88%, and place it without covering captions, faces, or the payoff.

Read [edit-audit-and-template.md](references/edit-audit-and-template.md) for
the evidence schema, SFX filename contract, emphasis rules, duplicate-search
package, and template contract. Validate with:

```powershell
python scripts/validate_audit_package.py path\to\project
```
"""

### 추가 002

추가 위치:

- `viral-source-highlight-editor/references/edit-audit-and-template.md`

추가 이유:

- `SKILL.md`를 500줄 이하로 유지하면서 상세 스키마를 중복 없이 제공하기 위함.

추가 내용 범위:

- 감사 산출물과 판정값 계약
- 컷별 소스·시작·종료·앞뒤 제거·자막·Skill 조항 기록
- 상위 댓글 2~3개와 좋아요·감정·궁금증·반영 방식 기록
- 말투와 사실 구조 분리
- SFX 폴더 매칭 및
  `[emotion]_[purpose]_[intensity]_[duration]_[version].wav` 규칙
- 로고·워터마크·원본 자막·화면 글씨 결정표
- 다중 YouTube 검색과 대표 프레임 3~5장 역검색 패키지
- 빨간 화살표·빨간 원형·장면별 줌 패턴
- 권리 확인 소스에 한정한 좌우반전과 예외
- 기존 Skills 수치의 설정값·실측값·판정·미적용 이유 기록
- 1080x1920 HTML·PNG·JSON 템플릿과 캐릭터 불투명도 72~88%

### 추가 003

추가 위치:

- `viral-source-highlight-editor/scripts/validate_audit_package.py`
- `viral-source-highlight-editor/scripts/test_validate_audit_package.py`

추가 이유:

- 감사 보고서와 템플릿이 빠진 채 완료 처리되는 것을 막기 위함.

검사 항목:

- 감사 보고서 4개
- 허용된 최종 판정
- 역검색 프레임 클립당 최소 3장
- 템플릿 HTML·PNG·JSON
- PNG 1080x1920
- JSON 캔버스 1080x1920
- 캐릭터 불투명도 0.72~0.88

### 추가 004

추가 위치:

- `viral-source-highlight-editor/scripts/process_character.py`
- `viral-source-highlight-editor/scripts/test_process_character.py`

추가 이유:

- 사람이 만든 캐릭터 이미지를 템플릿에 넣기 전 단색 배경을 투명화하고
  크기를 정규화할 재사용 도구가 없었음.

안전 범위:

- 코너 평균색과 가까운 픽셀만 투명화한다.
- 복잡한 배경에 대한 완전한 AI 누끼를 주장하지 않는다.
- 원본 캐릭터를 새로 생성하지 않는다.

## 수정하지 않은 이유

- `video-editing-compliance-skill`의 108~112% 줌, X/Y 오프셋, 1.05배속,
  ±3% 색상, J/L-cut, 정지 프레임, 화살표, 제작 로그 조항은 이미 존재한다.
- 같은 규칙을 다시 추가하면 Skill 간 중복과 충돌이 생기므로 원문을 유지했다.
- 현재 TOP7 영상 자체는 이번 태스크에서 재렌더하지 않았다. 감사 결과와
  권리 상태를 먼저 확정한 뒤 별도 승인된 편집 수정에서 반영해야 한다.
