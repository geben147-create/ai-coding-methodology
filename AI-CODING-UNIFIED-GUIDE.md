# AI 코딩 전담 통합 방법론 (Unified Guide)

> **검증**: Claude Opus 4.6 + GPT-5.2-pro + Gemini 3 Pro 교차검증  
> **기준일**: 2026-04-11  
> **출처**: GitHub Spec Kit, BMAD v6, Karpathy autoresearch, HumanLayer, Anthropic Best Practices, AAIF AGENTS.md

---

## 한눈에 보기 — 모드 비교표

| 항목 | Mode A (소형) | Mode B (중대형) | Mode C (대형) |
|------|:---:|:---:|:---:|
| **규모** | 스크립트, 도구, 실험 | 기능 5+, 상용 | 6개월+, 엔터프라이즈 |
| **기간** | 30분 ~ 1일 | 며칠 ~ 몇주 | 몇달 ~ 1년+ |
| **Spec Kit** | - | O | O |
| **BMAD** | - | - | O |
| **내 템플릿** | 7개 | 10개 | 전체 + BMAD |
| **워크플로우** | 자유 프롬프트 | speckit 스킬 체인 | speckit + BMAD 에이전트 |
| **복잡도** | 낮음 | 중간 | 높음 |
| **브랜치** | 자유 | feat/xxx-date | feat/xxx-date |
| **교차검증** | 선택 | 권장 | 필수 |

---

## 파일 역할 맵 (무엇이 무엇인가)

```
                    ┌─────────────────────────────────────────────┐
                    │           프로젝트 루트 (/)                   │
                    ├─────────────────────────────────────────────┤
   TIER S           │  AGENTS.md      ← 모든 AI 도구 baseline    │
   (Day 1 필수)     │  CLAUDE.md      ← Claude 전용 규칙         │
                    │  LEARN.md       ← 오답노트                  │
                    │  scratchpad.md  ← 활성 작업 (.gitignore)    │
                    │  specs/_template/feature.md ← 기능 합본     │
                    ├─────────────────────────────────────────────┤
   TIER A           │  constitution.md ← 불변 원칙 (NFR)          │
   (병목시 추가)    │  ARCHITECTURE.md ← 시스템 구조               │
                    │  DECISIONS.md    ← 왜 X를 선택했나 (ADR)    │
                    ├─────────────────────────────────────────────┤
   TIER B           │  README.md       ← 공개 시                  │
   (대형/공개만)    │  ROADMAP.md      ← 분기 마일스톤             │
                    │  SECURITY.md     ← 보안 정책                 │
                    │  RELEASE.md      ← 버저닝/마이그레이션       │
                    └─────────────────────────────────────────────┘
```

---

## 폴더 구조 (Z님 환경)

```
C:\Users\llorr\dev\
├── kit-templates\          <- 마스터 템플릿 (읽기 전용)
│   ├── AGENTS.md, CLAUDE.md, LEARN.md, scratchpad.md
│   ├── constitution.md, ARCHITECTURE.md, DECISIONS.md
│   ├── README.md, ROADMAP.md, SECURITY.md, RELEASE.md
│   ├── 00-METHODOLOGY.md, infographic.html
│   └── specs\_template\feature.md
│
├── refs\                   <- 세계 표준 원본 (참고용)
│   ├── spec-kit\           ← github/spec-kit
│   ├── BMAD-METHOD\        ← bmad-code-org/BMAD-METHOD
│   ├── autoresearch\       ← karpathy/autoresearch
│   └── claude-code-best-practice\
│
├── repos\                  <- 실제 작업 (모든 프로젝트)
│   ├── project-a\
│   └── project-b\
│
└── worktrees\              <- git worktree (병렬 브랜치)

D:\2026airesult_byclaude\
└── outputs\                <- 결과물 (zip/log/png)
```

---

# MODE A: 소형 프로젝트

> **대상**: 스크립트, 도구, 1인 토이, 해커톤  
> **세팅 시간**: 1분  
> **특징**: Spec Kit 없음, 내 템플릿만

## A-1. 프로젝트 생성

```powershell
# PowerShell 함수 등록 완료 시:
ai-new my-tool

# 또는 수동:
cd C:\Users\llorr\dev\repos
mkdir my-tool && cd my-tool
git init

$kit = 'C:\Users\llorr\dev\kit-templates'
Copy-Item "$kit\AGENTS.md", "$kit\CLAUDE.md", "$kit\LEARN.md", `
          "$kit\scratchpad.md", "$kit\ARCHITECTURE.md", `
          "$kit\DECISIONS.md", "$kit\README.md" .
New-Item -ItemType Directory -Force 'specs\_template' | Out-Null
Copy-Item "$kit\specs\_template\feature.md" 'specs\_template\'
```

## A-2. .gitignore 세팅

```powershell
@"
scratchpad.md
.env
.env.local
node_modules/
dist/
build/
__pycache__/
.venv/
*.log
"@ | Out-File .gitignore -Encoding UTF8
```

## A-3. 첫 커밋

```powershell
git add -A
git commit -m "chore: initial setup with ai-coding-kit"
git branch -M main
```

## A-4. GitHub 레포 생성 (선택)

```powershell
gh repo create my-tool --private --source=. --push
```

## A-5. 작업 시작

```powershell
ai-start feature-name     # 또는: git switch -c feat/feature-20260411
claude                     # Claude Code 시작
```

Claude Code 안에서 자유 프롬프트:
```
"로그인 기능 만들어줘"
"테스트 먼저 작성하고 구현해줘"
```

## A-6. 마감

```powershell
ai-done "feat: add login" -Merge
# 또는 수동:
git add -A && git commit -m "feat: add login" && git push -u origin HEAD
```

## A 워크플로우 순서도

```
[프로젝트 생성] -> [AGENTS.md 편집] -> [브랜치 생성]
       |                                    |
       v                                    v
  [git init]                         [claude 실행]
  [템플릿 복사]                       [자유 프롬프트]
  [첫 커밋]                           [TDD: 테스트 -> 구현]
                                          |
                                          v
                               [검증: lint + test + typecheck]
                                          |
                                          v
                               [ai-done "feat: xxx" -Merge]
```

---

# MODE B: 중대형 프로젝트 (Spec Kit)

> **대상**: 기능 5+, 상용 제품, 구조화 필요  
> **세팅 시간**: 5분  
> **특징**: Spec Kit + 내 템플릿 (추천 기본 모드)

## B-1. 프로젝트 생성

```powershell
# PowerShell 함수:
ai-new my-saas -Mode B

# 또는 수동:
cd C:\Users\llorr\dev\repos
$env:PYTHONUTF8 = '1'
uvx --from git+https://github.com/github/spec-kit.git `
    specify init my-saas --ai claude
cd my-saas
```

## B-2. 내 템플릿 덮기

```powershell
$kit = 'C:\Users\llorr\dev\kit-templates'
Copy-Item "$kit\AGENTS.md", "$kit\CLAUDE.md", "$kit\LEARN.md", `
          "$kit\scratchpad.md", "$kit\ARCHITECTURE.md", `
          "$kit\DECISIONS.md", "$kit\README.md", `
          "$kit\ROADMAP.md", "$kit\RELEASE.md" . -Force
```

## B-3. .gitignore + 커밋

```powershell
@"
scratchpad.md
.env
.env.local
node_modules/
dist/
build/
__pycache__/
.venv/
*.log
"@ | Out-File .gitignore -Encoding UTF8

git add -A
git commit -m "chore: spec-kit + ai-coding-kit setup"
git branch -M main
gh repo create my-saas --private --source=. --push
```

## B-4. 헌법 작성 (1회만)

```powershell
claude
```

Claude Code 안에서:
```
/speckit.constitution

  NFR 정의:
  - 기술 스택: Next.js 15 + FastAPI + PostgreSQL
  - 보안: OWASP Top 10
  - 성능: p95 < 200ms
  - 접근성: WCAG 2.1 AA
  - 테스트: TDD 필수, 커버리지 80%+
  - 금지: legacy React class components
```

## B-5. 기능 명세 (기능마다 반복)

```
/speckit.specify 사용자 로그인 (이메일+패스워드, JWT 24h, rate limit 5/min)
/speckit.clarify         <- 모호함 제거
/speckit.plan            <- 아키텍처 계획
/speckit.tasks           <- DAG 작업 분해
/speckit.analyze         <- constitution 위반 체크
/speckit.implement       <- 실제 코딩
```

## B-6. 교차검증 (PAL MCP, 권장)

```
pal:consensus 명세 교차검증 (gpt-5.2-pro for, gemini-3-pro against)
pal:codereview 최신 변경사항
pal:secaudit 인증 로직
pal:precommit 커밋 전 최종
```

## B-7. 커밋 + 마감

```powershell
ai-start login
# ... claude 작업 ...
ai-done "feat(auth): add email+password login with JWT"
# 리뷰 후:
ai-done "feat(auth): complete login" -Merge
```

## B 워크플로우 순서도

```
[Spec Kit init] -> [내 템플릿 덮기] -> [헌법 작성 (1회)]
                                              |
                                              v
                              ┌─── 기능 루프 (반복) ───┐
                              │                         │
                              v                         │
                    [/speckit.specify]                   │
                    [/speckit.clarify]                   │
                    [/speckit.plan]                      │
                    [/speckit.tasks]                     │
                    [/speckit.analyze]                   │
                              |                         │
                              v                         │
                 [PAL consensus 교차검증]                │
                              |                         │
                              v                         │
                    [/speckit.implement]                 │
                              |                         │
                              v                         │
                    [PAL codereview]                     │
                    [PAL secaudit]                       │
                    [PAL precommit]                      │
                              |                         │
                              v                         │
                    [ai-done + LEARN.md]                 │
                              |                         │
                              └─────────────────────────┘
```

---

# MODE C: 대형 프로젝트 (하이브리드)

> **대상**: 6개월+, 멀티 모듈, PM/아키텍트/개발자 역할 분리  
> **세팅 시간**: 10분  
> **특징**: Spec Kit + BMAD 12+ 에이전트 + 내 템플릿 전체

## C-1. 프로젝트 생성

```powershell
# PowerShell 함수:
ai-new huge-app -Mode C

# 또는 수동:
cd C:\Users\llorr\dev\repos
$env:PYTHONUTF8 = '1'
uvx --from git+https://github.com/github/spec-kit.git `
    specify init huge-app --ai claude
cd huge-app
```

## C-2. 내 템플릿 전체 + BMAD

```powershell
$kit = 'C:\Users\llorr\dev\kit-templates'
Copy-Item "$kit\AGENTS.md", "$kit\CLAUDE.md", "$kit\LEARN.md", `
          "$kit\scratchpad.md", "$kit\ARCHITECTURE.md", `
          "$kit\DECISIONS.md", "$kit\README.md", "$kit\RELEASE.md", `
          "$kit\ROADMAP.md", "$kit\SECURITY.md" . -Force

# BMAD 설치 (12+ 에이전트, 워크플로우)
npx bmad-method install
```

## C-3. .gitignore + 커밋

```powershell
@"
scratchpad.md
.env
.env.local
node_modules/
dist/
build/
__pycache__/
.venv/
*.log
_bmad/_memory/temp/
"@ | Out-File .gitignore -Encoding UTF8

git add -A
git commit -m "chore: spec-kit + bmad + ai-coding-kit hybrid setup"
git branch -M main
gh repo create huge-app --private --source=. --push
```

## C-4. BMAD + Spec Kit 초기화

```powershell
claude
```

Claude Code 안에서:
```
bmad-help                      <- BMAD가 다음 단계 안내
/speckit.constitution          <- 헌법 작성
```

BMAD 자동 역할:
| 에이전트 | 역할 |
|---------|------|
| PM Agent | PRD 생성 |
| Architect Agent | 아키텍처 설계 |
| Dev Agent | 구현 |
| QA Agent | 테스트 |
| Security Agent | 보안 감사 |

## C-5. 병렬 작업 (독립적일 때만!)

```bash
# WSL tmux
tmux new -s work
# 창 1: Claude Code - 메인 feature (sequential)
# 창 2 (Ctrl+B, c): 테스트 작성 (다른 feature)
# 창 3 (Ctrl+B, c): 문서 생성
# 창 4 (Ctrl+B, c): PAL secaudit
```

> **금지**: 같은 feature를 프론트/백 분리해서 병렬 -> 머지 지옥

## C 워크플로우 순서도

```
[Spec Kit + BMAD + 템플릿] -> [헌법] -> [bmad-help]
                                              |
                     ┌────────────────────────┼────────────────────────┐
                     v                        v                        v
              [PM: PRD 생성]        [Architect: 설계]          [QA: 테스트계획]
                     |                        |                        |
                     └────────────┬───────────┘                        |
                                  v                                    |
                       [/speckit.specify -> implement]                 |
                                  |                                    |
                                  v                                    v
                       [Dev: 구현 (sequential)]          [QA: 테스트 실행]
                                  |                                    |
                                  └─────────────┬──────────────────────┘
                                                v
                                    [PAL 3중 검증]
                                    [codereview + secaudit + precommit]
                                                |
                                                v
                                    [ai-done + LEARN.md + DECISIONS.md]
```

---

# 공통: Feature 작업 루프

모든 모드에서 기능 개발할 때 반복하는 루틴:

## Step 1. 브랜치 생성

```powershell
cd C:\Users\llorr\dev\repos\my-project
git switch main && git pull --ff-only
ai-start login              # feat/login-20260411
```

## Step 2. Claude Code 시작

```powershell
claude
```

## Step 3. 명세 -> 구현 (모드별)

| Mode | Claude 안에서 |
|------|--------------|
| A | 자유 프롬프트: "로그인 만들어줘" |
| B | `/speckit.specify` -> `/speckit.implement` 체인 |
| C | `bmad-help` -> speckit 체인 + BMAD 에이전트 |

## Step 4. 검증

```bash
# 프로젝트에 맞게:
npm run lint        # 또는 ruff check .
npm run typecheck   # 또는 mypy .
npm test            # 또는 pytest -xvs
```

## Step 5. 커밋 + 푸시

```powershell
ai-done "feat(auth): add email login with JWT"
# 완료 시:
ai-done "feat(auth): complete" -Merge
```

## Step 6. 회고

```
LEARN.md에 항목 추가 (있으면)
scratchpad.md 비우기
```

---

# PowerShell 함수 요약

| 명령어 | 기능 |
|--------|------|
| `ai-new <이름>` | Mode A 프로젝트 생성 |
| `ai-new <이름> -Mode B` | Mode B (Spec Kit) |
| `ai-new <이름> -Mode C` | Mode C (하이브리드) |
| `ai-start <기능명>` | feat 브랜치 생성 |
| `ai-done "msg"` | 커밋 + 푸시 |
| `ai-done "msg" -Merge` | 커밋 + 푸시 + main 병합 |
| `cd-repo <이름>` | 프로젝트 이동 |
| `cd-out` | 결과물 폴더 이동 |
| `ai-check` | 키트 상태 점검 |

---

# 핵심 GitHub 링크 (좋은 순)

| # | 레포 | 용도 |
|---|------|------|
| 1 | [github/spec-kit](https://github.com/github/spec-kit) | constitution/spec/plan/tasks 표준 |
| 2 | [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) | Claude Code 패턴 모음 |
| 3 | [karpathy/autoresearch](https://github.com/karpathy/autoresearch) | Karpathy 워크플로우 |
| 4 | [agents.md](https://agents.md) | AGENTS.md 표준 |
| 5 | [bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | BMAD v6 (대형 참고) |
| 6 | [Anthropic 공식](https://code.claude.com/docs/en/best-practices) | Claude Code 공식 |
| 7 | [HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md) | CLAUDE.md lean 가이드 |

---

# 핵심 리스크 & 대응

| 리스크 | 대응 |
|--------|------|
| spec/plan/tasks 드리프트 | scratchpad.md를 SSOT, feature.md는 완료시 freeze |
| tmux 병렬 머지 충돌 | 같은 코드 동시 수정 금지, 독립 작업만 병렬 |
| 검증 없이 완료 주장 | PAL precommit + 실행 결과 붙여넣기 강제 |
| LEARN.md 비대화 | 50개 넘으면 카테고리 분리 |
| Spec Kit lock-in | 산출물은 plain markdown, CLI 떼도 사용 가능 |

---

# 비추 (3모델 합의 경고)

- ~~BMAD 풀 적용 (1인 초반에 12+ 에이전트)~~ -> 4개로 시작
- ~~markdown 동기화 강제 CI 훅~~ -> 메타작업 루프 빠짐
- ~~tmux로 같은 feature 분할~~ -> 머지 지옥
- ~~CLAUDE.md에 코드베이스 구조 설명~~ -> 시스템 리마인더가 무시

---

# 환경 추천

| 순위 | 환경 | 적합한 상황 |
|------|------|------------|
| 1 | **Claude Code CLI (WSL) + Spec Kit** | 대부분의 작업. PAL MCP 통합, 1M context |
| 2 | **Antigravity (VS Code)** | 풀스택 웹 프로토타이핑, GUI 필요시 |
| 3 | **tmux 그리드** | 독립 검증/문서/테스트 병렬 |

---

# 하면 vs 안하면

| | 하면 | 안하면 |
|---|---|---|
| AI가 프로젝트 맥락 파악 | 즉시 | 매번 설명 반복 |
| 결정 기록 | DECISIONS.md 자동 누적 | 까먹음 |
| 스펙 -> 코드 흐름 | speckit 스킬로 일관 | 즉흥적 |
| 새 세션 인수인계 | LEARN.md 보면 됨 | 다시 설명 |
| 같은 실수 방지 | LEARN.md가 자동 차단 | 반복 |

---

*Last updated: 2026-04-11*
