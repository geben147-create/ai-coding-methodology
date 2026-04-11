# AI 코딩 전담 통합 방법론 v3.0

> **검증**: Claude Opus 4.6 + GPT-5.2-pro + Gemini 3 Pro 교차검증 완료
> **기준일**: 2026-04-11
> **대상**: 1인 개발자, 소형~대형 프로젝트 전체 커버

---

## 목차

- [1. 모드 선택 가이드](#1-모드-선택-가이드)
- [2. 폴더 구조 전체 지도](#2-폴더-구조-전체-지도)
- [3. Mode A — 소형 프로젝트](#3-mode-a--소형-프로젝트)
- [4. Mode B — 중대형 프로젝트](#4-mode-b--중대형-프로젝트)
- [5. Mode C — 대형 하이브리드](#5-mode-c--대형-하이브리드)
- [6. 공통 Feature 작업 루프](#6-공통-feature-작업-루프)
- [7. 대형 프로젝트 단계별 워크플로우](#7-대형-프로젝트-단계별-워크플로우)
- [8. 파일 역할 총정리](#8-파일-역할-총정리)
- [9. 검증 체크리스트](#9-검증-체크리스트)
- [10. 평생 명령어 치트시트](#10-평생-명령어-치트시트)
- [11. 핵심 링크](#11-핵심-링크)

---

## 1. 모드 선택 가이드

```
┌─────────────────────────────────────────────────────────────┐
│                    프로젝트 규모 판단                        │
│                                                             │
│   기능 < 5개?  ─── Yes ──→  ⬛ Mode A (소형)               │
│       │                                                     │
│       No                                                    │
│       │                                                     │
│   기능 5~15개? ─── Yes ──→  🟦 Mode B (중대형)             │
│       │                                                     │
│       No                                                    │
│       │                                                     │
│   기능 15개+   ──────────→  🟥 Mode C (대형 하이브리드)    │
└─────────────────────────────────────────────────────────────┘
```

| 상황 | 모드 | 이유 |
|------|:----:|------|
| 혼자 쓸 스크립트, 도구 | **A** | Spec Kit 오버헤드 불필요 |
| 토이 프로젝트, 실험 | **A** | 빠른 시작 (1분) |
| 해커톤 (시간 촉박) | **A** | 설치 최소화 |
| 기능 5~15개, 1~3개월 | **B** | Spec Kit이 구조 잡아줌 |
| 상용 제품, NFR 중요 | **B** | constitution으로 NFR 강제 |
| 6개월+ 프로젝트 | **C** | BMAD 에이전트가 역할 분리 |
| 멀티 모듈 시스템 | **C** | 12+ 에이전트 필요 |

### 두 방법론 비교

| 항목 | 🔴 GSD + speckit (현재) | 🟡 kit-templates (이 키트) |
|------|:---:|:---:|
| 워크플로우 엔진 | `/gsd:*` 명령어 | 없음 (Claude에게 직접) |
| 계획 파일 | `.planning/` 자동 생성 | 없음 |
| 명세서 | `specs/001-xxx/` (speckit) | `specs/_template/feature.md` |
| AI 지시 파일 | `CLAUDE.md` (프로젝트용) | `CLAUDE.md` + `AGENTS.md` + `00-METHODOLOGY.md` |
| 학습 기록 | `LessonsLearned.md` | `LEARN.md` + `DECISIONS.md` |
| 복잡도 | 높음 (phase/plan 구조) | 낮음 (파일만 있음) |
| 적합한 프로젝트 | 대형 (5+ 페이즈) | 소형~중형 |
| 브랜치 전략 | `speckit/001-xxx` | 자유 |

> **통합 결론**: Mode A = kit-templates만, Mode B = spec-kit + kit-templates, Mode C = spec-kit + BMAD + kit-templates

---

## 2. 폴더 구조 전체 지도

```
C:\Users\llorr\dev\
├── kit-templates\          📘 마스터 템플릿 (읽기용, 안 건드림)
│   ├── 00-METHODOLOGY.md   ← 방법론 상세
│   ├── AGENTS.md            ← AI 행동 규칙 (universal)
│   ├── CLAUDE.md            ← Claude 전용 규칙
│   ├── LEARN.md             ← 오답노트 템플릿
│   ├── scratchpad.md        ← 활성 작업 (transient)
│   ├── constitution.md      ← Spec Kit 9 Articles
│   ├── ARCHITECTURE.md      ← 시스템 구조
│   ├── DECISIONS.md         ← ADR
│   ├── README.md            ← 프로젝트 소개
│   ├── ROADMAP.md           ← 로드맵
│   ├── SECURITY.md          ← 보안 정책
│   ├── RELEASE.md           ← 릴리즈 절차
│   ├── infographic.html     ← 시각화
│   └── specs\_template\
│       └── feature.md       ← 기능 명세 합본
│
├── refs\                   📚 세계 표준 원본 (참고용)
│   ├── spec-kit\            ← GitHub 공식
│   ├── BMAD-METHOD\         ← 대형 시 참고
│   ├── autoresearch\        ← Karpathy
│   └── claude-code-best-practice\
│
├── repos\                  🔧 실제 작업 (모든 git repo 여기)
│   ├── project-a\
│   └── project-b\
│
└── worktrees\              🌿 git worktree (병렬 브랜치)

D:\2026airesult_byclaude\
└── outputs\                📦 결과물 (zip/log/png/json)
```

---

## 3. Mode A — 소형 프로젝트

> **대상**: 기능 < 5개, 스크립트, 도구, 실험, 해커톤
> **세팅 시간**: ~1분
> **사용 도구**: kit-templates만

### 3.1 세팅 (PowerShell)

```powershell
# ─── 방법 1: ai-new 함수 (프로필에 등록된 경우) ───
ai-new my-tool

# ─── 방법 2: 수동 ───
$projectName = 'my-tool'
cd C:\Users\llorr\dev\repos
mkdir $projectName; cd $projectName
git init

$kit = 'C:\Users\llorr\dev\kit-templates'
Copy-Item "$kit\AGENTS.md",`
          "$kit\CLAUDE.md",`
          "$kit\LEARN.md",`
          "$kit\scratchpad.md",`
          "$kit\ARCHITECTURE.md",`
          "$kit\DECISIONS.md",`
          "$kit\README.md" .

New-Item -ItemType Directory -Force 'specs\_template' | Out-Null
Copy-Item "$kit\specs\_template\feature.md" 'specs\_template\'

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
git commit -m "chore: initial setup with ai-coding-kit"
git branch -M main
```

### 3.2 GitHub 연결 (선택)

```powershell
gh repo create $projectName --private --source=. --push
```

### 3.3 복사되는 파일 (7개)

| 파일 | 역할 | 필수? |
|------|------|:-----:|
| `AGENTS.md` | 모든 AI 도구 행동 규칙 (universal) | **필수** |
| `CLAUDE.md` | Claude 전용 추가 규칙 | **필수** |
| `LEARN.md` | 오답노트 | **필수** |
| `scratchpad.md` | 현재 작업 추적 (transient, gitignore) | **필수** |
| `ARCHITECTURE.md` | 시스템 구조 | 권장 |
| `DECISIONS.md` | 결정 기록 (ADR) | 권장 |
| `README.md` | 프로젝트 소개 | 공개 시 |

### 3.4 작업 시작

```powershell
cd C:\Users\llorr\dev\repos\my-tool
claude    # Claude Code 시작
```

Claude Code에서 한국어로:
```
"AGENTS.md 읽고, 로그인 기능 만들어줘"
```

---

## 4. Mode B — 중대형 프로젝트

> **대상**: 기능 5~15개, 1~3개월, 상용 제품
> **세팅 시간**: ~3분
> **사용 도구**: Spec Kit + kit-templates

### 4.1 세팅 (PowerShell)

```powershell
# ─── 방법 1: ai-new 함수 ───
ai-new my-saas -Mode B

# ─── 방법 2: 수동 ───
$projectName = 'my-saas'
cd C:\Users\llorr\dev\repos
$env:PYTHONUTF8 = '1'
uvx --from git+https://github.com/github/spec-kit.git `
    specify init $projectName --ai claude --offline
cd $projectName

$kit = 'C:\Users\llorr\dev\kit-templates'
Copy-Item "$kit\AGENTS.md",`
          "$kit\CLAUDE.md",`
          "$kit\LEARN.md",`
          "$kit\scratchpad.md",`
          "$kit\ARCHITECTURE.md",`
          "$kit\DECISIONS.md",`
          "$kit\README.md",`
          "$kit\ROADMAP.md" . -Force

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
git commit -m "chore: spec-kit + ai-coding-kit initial setup"
git branch -M main
gh repo create $projectName --private --source=. --push
```

### 4.2 복사되는 파일 (8개 + Spec Kit 자동 생성)

| 파일 | 출처 | 역할 |
|------|------|------|
| `.specify/` | Spec Kit 자동 | 명세 엔진 디렉토리 |
| `AGENTS.md` | kit-templates | AI 행동 규칙 |
| `CLAUDE.md` | kit-templates | Claude 전용 |
| `LEARN.md` | kit-templates | 오답노트 |
| `scratchpad.md` | kit-templates | 활성 작업 |
| `ARCHITECTURE.md` | kit-templates | 시스템 구조 |
| `DECISIONS.md` | kit-templates | ADR |
| `README.md` | kit-templates | 프로젝트 소개 |
| `ROADMAP.md` | kit-templates | 분기별 마일스톤 |

### 4.3 최초 1회: 헌법 작성

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

### 4.4 기능마다 반복 (Spec Kit 워크플로우)

```
┌──────────────────────────────────────────────────────┐
│                   Spec Kit 기능 루프                  │
│                                                      │
│  /speckit.specify "기능 설명"  ──→  spec.md 생성     │
│           │                                          │
│  /speckit.clarify             ──→  모호함 제거       │
│           │                                          │
│  /speckit.plan                ──→  아키텍처 계획     │
│           │                                          │
│  /speckit.tasks               ──→  DAG 작업 분해     │
│           │                                          │
│  /speckit.analyze             ──→  헌법 위반 체크    │
│           │                                          │
│  /speckit.implement           ──→  코드 작성         │
└──────────────────────────────────────────────────────┘
```

---

## 5. Mode C — 대형 하이브리드

> **대상**: 6개월+, 멀티 모듈, 엔터프라이즈급
> **세팅 시간**: ~5분
> **사용 도구**: Spec Kit + BMAD + kit-templates 전체

### 5.1 세팅 (PowerShell)

```powershell
# ─── 방법 1: ai-new 함수 ───
ai-new huge-app -Mode C

# ─── 방법 2: 수동 ───
$projectName = 'huge-app'
cd C:\Users\llorr\dev\repos
$env:PYTHONUTF8 = '1'
uvx --from git+https://github.com/github/spec-kit.git `
    specify init $projectName --ai claude --offline
cd $projectName

$kit = 'C:\Users\llorr\dev\kit-templates'
Copy-Item "$kit\AGENTS.md",`
          "$kit\CLAUDE.md",`
          "$kit\LEARN.md",`
          "$kit\scratchpad.md",`
          "$kit\ARCHITECTURE.md",`
          "$kit\DECISIONS.md",`
          "$kit\README.md",`
          "$kit\RELEASE.md",`
          "$kit\ROADMAP.md",`
          "$kit\SECURITY.md" . -Force

# BMAD 에이전트 설치 (12+ 에이전트)
npx bmad-method install

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
gh repo create $projectName --private --source=. --push
```

### 5.2 복사되는 파일 (10개 + Spec Kit + BMAD)

| 파일 | 출처 | Mode A | Mode B | Mode C |
|------|------|:------:|:------:|:------:|
| `AGENTS.md` | kit-templates | ✅ | ✅ | ✅ |
| `CLAUDE.md` | kit-templates | ✅ | ✅ | ✅ |
| `LEARN.md` | kit-templates | ✅ | ✅ | ✅ |
| `scratchpad.md` | kit-templates | ✅ | ✅ | ✅ |
| `ARCHITECTURE.md` | kit-templates | ✅ | ✅ | ✅ |
| `DECISIONS.md` | kit-templates | ✅ | ✅ | ✅ |
| `README.md` | kit-templates | ✅ | ✅ | ✅ |
| `ROADMAP.md` | kit-templates | — | ✅ | ✅ |
| `SECURITY.md` | kit-templates | — | — | ✅ |
| `RELEASE.md` | kit-templates | — | — | ✅ |
| `.specify/` | Spec Kit | — | ✅ | ✅ |
| `_bmad/` | BMAD | — | — | ✅ |

### 5.3 BMAD 에이전트 역할

```
┌────────────────────────────────────────────────────────┐
│                BMAD 12+ 에이전트 구조                   │
│                                                        │
│  🧑‍💼 PM Agent        ──→  PRD 생성, 요구사항 관리     │
│  🏗️ Architect Agent  ──→  시스템 설계, 패턴 결정       │
│  👨‍💻 Dev Agent        ──→  코드 구현                   │
│  🧪 QA Agent         ──→  테스트 작성/실행             │
│  📝 Doc Agent        ──→  문서 자동 생성               │
│  🔒 Security Agent   ──→  보안 감사                    │
│  📊 Analytics Agent  ──→  성능 분석                    │
│  ... (역할별 추가)                                     │
│                                                        │
│  시작: claude → bmad-help                              │
└────────────────────────────────────────────────────────┘
```

---

## 6. 공통 Feature 작업 루프

> 모든 모드에서 **기능 하나를 개발할 때** 반복하는 루틴

### 6.1 PowerShell — 브랜치 생성

```powershell
cd C:\Users\llorr\dev\repos\my-project
git switch main
git pull --ff-only

$feature = 'login'
$date = Get-Date -Format 'yyyyMMdd'
git switch -c "feat/$feature-$date"

# 또는 ai-start 함수:
ai-start login
```

### 6.2 Claude Code — 작업

```powershell
claude
```

**Mode A** (자유 프롬프트):
```
"AGENTS.md 읽고, 이메일+JWT 로그인 기능 만들어줘"
```

**Mode B/C** (Spec Kit 워크플로우):
```
/speckit.specify 사용자 로그인 (이메일+패스워드, JWT 24h, rate limit 5/min)
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.implement
```

### 6.3 검증

```powershell
# 프로젝트 맞게 교체
npm run lint          # 또는: ruff check .
npm run typecheck     # 또는: mypy .
npm test              # 또는: pytest -xvs
```

### 6.4 커밋 + 푸시

```powershell
# 방법 1: ai-done 함수
ai-done "feat(auth): add email+password login with JWT"

# 방법 2: 수동
git add -A
git diff --cached --name-only    # 뭐 커밋하는지 확인
git commit -m "feat(auth): add email+password login with JWT"
git push -u origin HEAD
```

### 6.5 병합

```powershell
# 방법 1: ai-done -Merge
ai-done "feat(auth): add email login" -Merge

# 방법 2: 수동
git switch main
git pull --ff-only
git merge --no-ff feat/login-20260411 -m "Merge feat/login"
git push
git branch -d feat/login-20260411
```

### 6.6 회고

문제 있었으면 `LEARN.md`에 항목 추가:
```markdown
### 2026-04-11: JWT 만료 시간 하드코딩

- **증상**: 토큰 24h 만료가 코드에 하드코딩
- **원인**: .env에 변수 안 만듦
- **방지 규칙**: 모든 시간 값은 환경변수
- **자동화 가능?**: Yes — lint rule
- **AGENTS.md 반영?**: Yes (Section 6에 추가)
```

---

## 7. 대형 프로젝트 단계별 워크플로우

### Phase 0: 환경 세팅 (1회)

```
┌─────────────────────────────────────────────────────┐
│ Day 0: 세팅                                         │
│                                                     │
│ 1. ai-new project-x -Mode B    (또는 C)            │
│ 2. AGENTS.md 편집 (프로젝트 맞게)                   │
│ 3. gh repo create                                   │
│ 4. claude 실행                                      │
└─────────────────────────────────────────────────────┘
```

### Phase 1: 헌법 작성 (1회)

```
/speckit.constitution
  → 기술 스택, 보안, 성능, 접근성, 테스트 규칙 정의
  → .specify/memory/constitution.md 생성
```

### Phase 2: 기능 명세 (기능마다)

```
/speckit.specify "기능 설명"
  → specs/001-feature/spec.md 생성

/speckit.clarify
  → 인터랙티브 Q&A로 모호함 제거
```

### Phase 3: 아키텍처 계획 (기능마다)

```
/speckit.plan
  → plan.md + research + data-model + contracts

(선택) PAL MCP 교차검증:
  → pal:consensus 아키텍처 검증
  → gpt-5.2-pro for + gemini-3-pro against
```

### Phase 4: 작업 분해 (기능마다)

```
/speckit.tasks
  → tasks.md (DAG, T### 의존성)

/speckit.analyze
  → constitution 위반 자동 체크
```

### Phase 5: 구현

```
/speckit.implement
  → Claude Code가 sequential 실행

병렬은 *독립 작업만*:
  tmux 창 1: 메인 feature (sequential)
  tmux 창 2: 테스트 작성 (독립)
  tmux 창 3: 문서 생성 (독립)

⚠️ 같은 feature 코드는 단일 에이전트 sequential
```

### Phase 6: 검증 + 커밋

```
검증:
  1. npm test / pytest (전체 통과)
  2. npm run lint (0 errors)
  3. npm run typecheck (0 errors)
  4. (선택) PAL codereview / secaudit

커밋:
  git add -A
  git commit -m "feat(xxx): description"
  git push -u origin HEAD

회고:
  LEARN.md에 학습 항목 추가
```

### 전체 흐름도

```
Day 0          Day 1          Day N (기능마다 반복)
  │              │              │
  ▼              ▼              ▼
┌──────┐    ┌──────────┐    ┌──────────────────────────┐
│ 세팅 │───→│  헌법    │───→│ specify → clarify → plan │
│      │    │ (1회만) │    │ → tasks → implement      │
└──────┘    └──────────┘    │ → 검증 → 커밋 → 회고     │
                            └──────────────────────────┘
                                       │
                                       ▼
                              다음 기능 반복 ↺
```

---

## 8. 파일 역할 총정리

### TIER S — 절대 필수 (Day 1)

| # | 파일 | 역할 | 크기 목표 |
|---|------|------|-----------|
| 1 | **AGENTS.md** | 모든 AI 도구 baseline. 명령어/스타일/금지/검증 | 100~200줄 |
| 2 | **CLAUDE.md** | Claude 전용 행동 규칙 (`See @AGENTS.md` + 추가) | 50~100줄 |
| 3 | **LEARN.md** | 오답노트. 같은 실수 반복 방지 | 무제한 |
| 4 | **scratchpad.md** | 현재 활성 작업 (transient, gitignore) | ~100줄 |
| 5 | **feature.md** | 기능별 WHAT+HOW+TASKS 합본 | 200~500줄 |

### TIER A — 병목 보이면 추가 (Week 2-4)

| # | 파일 | 트리거 |
|---|------|--------|
| 6 | `constitution.md` | NFR 손실 발생 시 |
| 7 | `ARCHITECTURE.md` | 모듈 5개+ / AI가 패턴 모방 실패 |
| 8 | `DECISIONS.md` | "왜 X 선택?" 반복 질문 |
| 9 | `.claude/skills/` | 같은 워크플로우 3회+ 반복 |
| 10 | `.claude/agents/` | architect/implementer/reviewer/researcher |

### TIER B — 대형/공개 프로젝트만

| # | 파일 | 시점 |
|---|------|------|
| 11 | `README.md` | 공개 시 |
| 12 | `ROADMAP.md` | 분기별 마일스톤 필요 시 |
| 13 | `SECURITY.md` | 보안 정책 필요 시 |
| 14 | `RELEASE.md` | 버저닝/마이그레이션 필요 시 |

### 비추 (3-모델 합의 경고)

| 비추 | 이유 |
|------|------|
| BMAD 풀 적용 (12+ 에이전트) | 1인에게 과부하 |
| markdown 동기화 강제 CI 훅 | 에이전트가 메타작업 루프 빠짐 |
| tmux 병렬로 같은 feature 분할 | 머지 지옥 |
| CLAUDE.md에 코드베이스 구조 설명 | 시스템 리마인더가 무시 |

---

## 9. 검증 체크리스트

### 작업 전

- [ ] AGENTS.md 읽었음
- [ ] LEARN.md 훑었음 (같은 실수 회피)
- [ ] scratchpad.md에 현재 작업 기록

### 작업 완료 시

- [ ] 테스트 전체 통과 (실행 결과 첨부)
- [ ] 린트 0 errors
- [ ] 타입체크 0 errors
- [ ] 새 함수 → 새 테스트
- [ ] 검증 흔적이 scratchpad.md에 있음
- [ ] LEARN.md에 새 학습 추가 (있으면)
- [ ] scratchpad.md 비우기 또는 아카이브

### 커밋 전

- [ ] `git diff --cached --name-only` 확인
- [ ] .env, secrets 포함 안 됨
- [ ] 커밋 메시지 형식: `type(scope): description`

---

## 10. 평생 명령어 치트시트

### 프로젝트 생성

| 규모 | 명령어 |
|------|--------|
| 소형 | `ai-new my-tool` |
| 중대형 | `ai-new my-saas -Mode B` |
| 대형 | `ai-new huge-app -Mode C` |

### 일상 작업

| 명령어 | 기능 |
|--------|------|
| `cd-repo my-tool` | 프로젝트 이동 (status 자동) |
| `ai-start login` | `feat/login-20260411` 브랜치 생성 |
| `claude` | Claude Code 시작 |
| `ai-done "feat: xxx"` | 커밋 + 푸시 |
| `ai-done "feat: xxx" -Merge` | 커밋 + 푸시 + main 병합 |
| `ai-check` | 키트 전체 상태 점검 |
| `cd-out` | 결과물 저장소 이동 |

### Claude Code 안에서 (Mode B/C)

| 명령어 | 기능 |
|--------|------|
| `/speckit.constitution` | 헌법 작성 (1회) |
| `/speckit.specify "기능"` | 명세 작성 |
| `/speckit.clarify` | 모호함 제거 |
| `/speckit.plan` | 아키텍처 계획 |
| `/speckit.tasks` | DAG 작업 분해 |
| `/speckit.analyze` | 헌법 위반 체크 |
| `/speckit.implement` | 코드 구현 |

### Git 커밋 형식

```
feat: 새 기능
fix: 버그 수정
refactor: 리팩토링
test: 테스트 추가/수정
docs: 문서
chore: 빌드/설정
perf: 성능 개선
```

---

## 11. 핵심 링크

| 순위 | 이름 | URL | 용도 |
|:----:|------|-----|------|
| 1 | GitHub Spec Kit | https://github.com/github/spec-kit | 명세 엔진 본체 |
| 2 | Claude Code Best Practice | https://github.com/shanraisshan/claude-code-best-practice | 패턴 모음 |
| 3 | Karpathy autoresearch | https://github.com/karpathy/autoresearch | 단일 markdown 워크플로우 |
| 4 | AGENTS.md 표준 | https://agents.md | AI 행동 규칙 표준 사이트 |
| 5 | BMAD METHOD | https://github.com/bmad-code-org/BMAD-METHOD | 대형 시 에이전트 구조 |
| 6 | Anthropic 공식 | https://code.claude.com/docs/en/best-practices | Claude Code 문서 |
| 7 | HumanLayer 가이드 | https://www.humanlayer.dev/blog/writing-a-good-claude-md | CLAUDE.md 작성법 |

---

## 하면 vs 안하면

| | 하면 ✅ | 안하면 ❌ |
|---|---|---|
| AI가 프로젝트 맥락 파악 | 즉시 | 매번 설명 반복 |
| 결정 기록 | DECISIONS.md 자동 누적 | 까먹음 |
| 스펙→코드 흐름 | speckit 스킬로 일관됨 | 즉흥적 |
| 새 세션 인수인계 | LEARN.md 보면 됨 | 다시 설명 |
| 같은 실수 반복 | LEARN.md가 방지 | 3번째 실수에 발견 |

---

*최종 업데이트: 2026-04-11*
*검증: Claude Opus 4.6 + GPT-5.2-pro + Gemini 3 Pro*
