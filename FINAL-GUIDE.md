# Solo AI 코딩 전담 — 최종 실행 가이드 v4.0

> **작성**: Claude Opus 4.6 (교차검증 미실시 — 기존 Solo AI 전략 문서 기반 재구성)  
> **기준일**: 2026-04-12  
> **GitHub Pages**: [https://geben147-create.github.io/ai-coding-methodology/final-guide.html](https://geben147-create.github.io/ai-coding-methodology/final-guide.html)

---

## 📊 단계별 방법론 반영 비율 (%)

> 18분 자막 핵심 기반 — 4가지 방법론의 단계별 지분율

| 단계 | 방1 (명세/보안/TDD) 5단계 1위개발자 | 방2 (UDM 전체구조) 8단계 by palmcp | 방3 (AI프롬프트) 18분 자막 다중AI협업 | 방4 (CLI 자동화) md파일+by palmcp | 지분율 해석 |
|:---:|:---:|:---:|:---:|:---:|---|
| **1. 환경/저장소 구축** | 0% | ~~20%~~ | 0% | **80%** | `ai-new`, `cd-repo` 등 방4의 쉘 스크립트 기반 물리적 통제 |
| **2. 명세 및 위협 설계** | **60%** | ~~20%~~ | 20% | 0% | 위협 모델링, Control Matrix 등 방1의 리스크 주도 설계(SSOT) |
| **3. 다중 AI 교차 검증** | 0% | 30% | **70%** | 0% | 여러 모델 충돌시켜 약점 찾는 프롬프트 엔지니어링(방3) |
| **4. 마이크로 분해/브랜치** | **40%** | ~~10%~~ | 10% | **40%** | 방1 `PLAN.md`(2~5분 분해) + 방4 `ai-start` 브랜치 분리 결합 |
| **5. TDD 기반 정밀 구현** | **60%** | ~~10%~~ | 30% | 0% | 방1 RED-GREEN 강제 + 100줄 제한 원칙 비중 최고 |
| **6. 검증 및 단위 커밋** | 30% | ~~10%~~ | 10% | **50%** | 방4 `ai-done` + 방1 Control Matrix 검증 조건 |
| **7. 문서 동기화 및 병합** | 20% | ~~10%~~ | 30% | **40%** | 방4 `-Merge` 옵션 + 방3 문서 자동화 프롬프트 결합 |

---

## 🏗 PART 0 — 최초 1회 환경 세팅 (한 번만 하면 평생)

### 0.1 필수 도구 확인

```powershell
# 이미 설치된 것 확인
claude --version         # Claude Code CLI
git --version            # Git
gh --version             # GitHub CLI
node --version           # Node.js (npx용)
python --version         # Python (uvx용)
```

### 0.2 GitHub SSH 확인

```powershell
ssh -T git@github-147     # "successfully authenticated" 나오면 OK
```

### 0.3 PowerShell 프로필에 함수 등록 (1회)

```powershell
notepad $PROFILE
```

맨 아래에 아래 전체 붙여넣기 후 저장:

```powershell
# ═══════════════════════════════════════════════════════
#   AI 코딩 키트 — 평생 루틴 함수 (2026.04)
# ═══════════════════════════════════════════════════════

$global:KIT    = 'C:\Users\llorr\dev\kit-templates'
$global:REPOS  = 'C:\Users\llorr\dev\repos'
$global:OUTPUTS = 'D:\2026airesult_byclaude\outputs'
$global:REFS   = 'C:\Users\llorr\dev\refs'

function New-AIProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)][string]$Name,
        [ValidateSet('A','B','C')][string]$Mode = 'A'
    )
    Set-Location $global:REPOS
    switch ($Mode) {
        'A' {
            Write-Host "`n▶ Mode A: 소형 프로젝트 생성..." -ForegroundColor Cyan
            New-Item -ItemType Directory -Force $Name | Out-Null
            Set-Location $Name; git init -q
            Copy-Item "$global:KIT\AGENTS.md","$global:KIT\CLAUDE.md","$global:KIT\LEARN.md","$global:KIT\scratchpad.md","$global:KIT\ARCHITECTURE.md","$global:KIT\DECISIONS.md","$global:KIT\README.md" . -ErrorAction SilentlyContinue
            New-Item -ItemType Directory -Force 'specs\_template' | Out-Null
            Copy-Item "$global:KIT\specs\_template\feature.md" 'specs\_template\' -ErrorAction SilentlyContinue
        }
        'B' {
            Write-Host "`n▶ Mode B: Spec Kit 초기화..." -ForegroundColor Cyan
            uvx --from git+https://github.com/github/spec-kit.git specify init $Name --ai claude
            Set-Location $Name
            Copy-Item "$global:KIT\AGENTS.md","$global:KIT\CLAUDE.md","$global:KIT\LEARN.md","$global:KIT\scratchpad.md","$global:KIT\ARCHITECTURE.md","$global:KIT\DECISIONS.md","$global:KIT\ROADMAP.md" . -Force -ErrorAction SilentlyContinue
        }
        'C' {
            Write-Host "`n▶ Mode C: 하이브리드 (Spec Kit + BMAD)..." -ForegroundColor Cyan
            uvx --from git+https://github.com/github/spec-kit.git specify init $Name --ai claude
            Set-Location $Name
            Copy-Item "$global:KIT\AGENTS.md","$global:KIT\CLAUDE.md","$global:KIT\LEARN.md","$global:KIT\scratchpad.md","$global:KIT\ARCHITECTURE.md","$global:KIT\DECISIONS.md","$global:KIT\README.md","$global:KIT\RELEASE.md","$global:KIT\ROADMAP.md","$global:KIT\SECURITY.md" . -Force -ErrorAction SilentlyContinue
            npx bmad-method install
        }
    }
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
    $hasCommit = git rev-parse HEAD 2>$null
    if (-not $hasCommit) {
        git add -A; git commit -q -m "chore: initial setup (Mode $Mode)"
        git branch -M main 2>$null
    }
    Write-Host "`n✅ 완료: $(Get-Location)" -ForegroundColor Green
}

function Enter-Repo {
    param([Parameter(Mandatory, Position=0)][string]$Name)
    $path = Join-Path $global:REPOS $Name
    if (Test-Path $path) { Set-Location $path; git status -s }
    else { Write-Host "❌ 없음: $path" -ForegroundColor Red }
}

function Start-AIFeature {
    param([Parameter(Mandatory, Position=0)][string]$Name)
    git switch main; git pull --ff-only
    $date = Get-Date -Format 'yyyyMMdd'
    git switch -c "feat/$Name-$date"
    Write-Host "✅ 브랜치: feat/$Name-$date" -ForegroundColor Green
}

function Complete-AIFeature {
    param(
        [Parameter(Mandatory, Position=0)][string]$Message,
        [switch]$Merge
    )
    $current = git branch --show-current
    if ($current -eq 'main') { Write-Host "❌ main 직접 커밋 금지" -ForegroundColor Red; return }
    git add -A; git commit -m $Message
    git push -u origin HEAD
    if ($Merge) {
        git switch main; git pull --ff-only
        git merge --no-ff $current -m "Merge $current"
        git push; git branch -d $current
        Write-Host "✅ 병합 완료" -ForegroundColor Green
    } else {
        Write-Host "✅ 푸시 완료 (브랜치 유지)" -ForegroundColor Green
    }
}

function Open-Outputs {
    if (-not (Test-Path $global:OUTPUTS)) { New-Item -ItemType Directory -Force $global:OUTPUTS | Out-Null }
    Set-Location $global:OUTPUTS
}

function Test-AIKit {
    Write-Host "`n═══ AI 코딩 키트 상태 ═══" -ForegroundColor Cyan
    Write-Host "KIT   : $(if(Test-Path $global:KIT){'✅'}else{'❌'}) $global:KIT"
    Write-Host "REPOS : $(if(Test-Path $global:REPOS){'✅'}else{'❌'}) $global:REPOS"
    Write-Host "OUT   : $(if(Test-Path $global:OUTPUTS){'✅'}else{'❌'}) $global:OUTPUTS"
    Write-Host "REFS  : $(if(Test-Path $global:REFS){'✅'}else{'❌'}) $global:REFS"
}

Set-Alias -Name ai-new   -Value New-AIProject
Set-Alias -Name ai-start -Value Start-AIFeature
Set-Alias -Name ai-done  -Value Complete-AIFeature
Set-Alias -Name cd-repo  -Value Enter-Repo
Set-Alias -Name cd-out   -Value Open-Outputs
Set-Alias -Name ai-check -Value Test-AIKit
```

저장 후 PowerShell 재시작, 확인:

```powershell
ai-check
```

---

## 🎯 PART 1 — 모드별 프로젝트 시작 (따라하기)

### Mode A — 소형 (스크립트, 도구, 실험)

```powershell
ai-new my-tool                    # 1분 세팅
cd-repo my-tool
# AGENTS.md 열어서 기술스택 채우기
ai-start feature-name             # 브랜치 생성
claude                            # Claude Code 시작
# → "AGENTS.md 읽고, OOO 기능 만들어줘"
ai-done "feat: xxx" -Merge        # 커밋+병합
```

복사 파일: `AGENTS.md`, `CLAUDE.md`, `LEARN.md`, `scratchpad.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `README.md` (7개)

### Mode B — 중대형 (기능 5+, 상용)

```powershell
ai-new my-saas -Mode B            # Spec Kit + 템플릿
cd-repo my-saas
claude
```

Claude Code 안에서 (최초 1회):
```
/speckit.constitution
  → 기술 스택: Next.js 15 + FastAPI + PostgreSQL
  → 보안: OWASP Top 10
  → 성능: p95 < 200ms
  → 테스트: TDD, 커버리지 80%+
```

기능마다 반복:
```
/speckit.specify "사용자 로그인 (이메일+JWT, rate limit 5/min)"
/speckit.clarify      ← 모호함 제거
/speckit.plan         ← 아키텍처 계획
/speckit.tasks        ← DAG 작업 분해
/speckit.analyze      ← 헌법 위반 체크
/speckit.implement    ← 코드 작성
```

PowerShell에서:
```powershell
ai-done "feat(auth): login with JWT" -Merge
```

### Mode C — 대형 (6개월+, 엔터프라이즈)

```powershell
ai-new huge-app -Mode C           # Spec Kit + BMAD + 풀셋
cd-repo huge-app
claude
```

Claude Code 안에서:
```
bmad-help                         ← BMAD 가이드 확인
/speckit.constitution             ← NFR 정의
```

BMAD가 자동으로 12+ 에이전트 분배:
- PM → PRD 생성
- Architect → 시스템 설계
- Dev → 코드 구현
- QA → 테스트

---

## 🔗 PART 2 — GitHub 연동 (프로젝트별 1회)

### 2.1 새 리포 생성 + 연결

```powershell
cd-repo my-project

# Private 리포 생성 + push
gh repo create my-project --private --source=. --push

# 또는 수동:
gh repo create my-project --private
git remote add origin git@github-147:dohadoha/my-project.git
git push -u origin main
```

### 2.2 GitHub Pages 활성화 (공개 사이트 필요시)

```powershell
# Settings → Pages → Source: Deploy from branch → main → /docs
# 또는 CLI:
gh api repos/{owner}/{repo}/pages -X POST -f source.branch=main -f source.path=/docs
```

### 2.3 기존 리포에 키트 추가 (이미 있는 프로젝트)

```powershell
cd-repo existing-project
$kit = 'C:\Users\llorr\dev\kit-templates'
Copy-Item "$kit\AGENTS.md","$kit\CLAUDE.md","$kit\LEARN.md","$kit\scratchpad.md" . -Force
git add -A
git commit -m "chore: add ai-coding-kit templates"
git push
```

---

## 🔄 PART 3 — 일상 작업 루프 (매일 반복)

### Step 1: 브랜치 생성

```powershell
cd-repo my-project
ai-start login                   # feat/login-20260412 생성
```

### Step 2: Claude Code에서 작업

```powershell
claude
```

Mode A: `"AGENTS.md 읽고, 이메일+JWT 로그인 만들어줘"`

Mode B/C:
```
/speckit.specify "이메일 로그인"
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.implement
```

### Step 3: 검증

```powershell
npm test          # 또는: pytest -xvs
npm run lint      # 또는: ruff check .
npm run typecheck # 또는: mypy .
```

### Step 4: 커밋 + 푸시 + 병합

```powershell
# 옵션 A: 커밋만 (브랜치 유지, PR 준비)
ai-done "feat(auth): add email login with JWT"

# 옵션 B: main에 바로 합치기
ai-done "feat(auth): add email login with JWT" -Merge

# 옵션 C: 여러 커밋 후 나중에 병합
ai-done "wip: first attempt"
# ... 더 작업 ...
ai-done "feat: complete login" -Merge
```

### Step 5: 회고

문제 있었으면 `LEARN.md`에 추가:
```markdown
### 2026-04-12: JWT 만료 시간 하드코딩
- **증상**: 토큰 24h가 코드에 하드코딩
- **원인**: .env에 변수 안 만듦
- **방지**: 모든 시간 값은 환경변수
- **AGENTS.md 반영**: Yes
```

---

## 📋 PART 4 — 대형 프로젝트 5단계 파이프라인

> 18분 자막 핵심: BMAD spec + Beck TDD execution + CONTROL-MAP compliance

```
[Phase 1 — SPEC, ~3hr]
  ├─ BMAD brainstorming (1hr) → user flow 발굴
  ├─ Claude Code drafts spec.md (Goals/Non-goals/AcceptanceCriteria)
  ├─ PAL consensus (gpt-5.2-pro for + against, 1 round)
  ├─ CONTROL-MAP.md v0 작성
  └─ 사용자 최종 승인

[Phase 2 — PLAN, ~1hr]
  ├─ Claude Code가 spec → plan.md 분해 (각 task 2~5분)
  ├─ 각 task에 DoD 명시 (test/lint/checkbox/commit)
  └─ 사용자 검토

[Phase 3 — BUILD (세션 루프)]
  ├─ "go" → CLAUDE.md 룰 자동 적용
  ├─ next unmarked test → RED → GREEN → REFACTOR
  ├─ atomic commit (structural OR behavioral, 절대 mixed 금지)
  ├─ plan.md [x] 체크 + 다음 세션용 메모
  ├─ Drift 감지 시 → spec.md/DECISIONS.md 업데이트 or STOP
  └─ 반복

[Phase 4 — VERIFY]
  ├─ Tests + lint + secret scan
  ├─ PAL codereview (L3 변경: auth/data/security)
  ├─ CONTROL-MAP.md 통제별 evidence 검증
  └─ 머지

[Phase 5 — EVOLVE]
  ├─ 5분 post-ship 회고
  ├─ DECISIONS.md 업데이트
  └─ CONTROL-MAP drift 점검
```

---

## 📂 PART 5 — 파일 역할 총정리

### Tier S — 절대 필수 (Day 1)

| 파일 | 역할 | 크기 |
|------|------|------|
| **AGENTS.md** | 모든 AI 행동 baseline | 100~200줄 |
| **CLAUDE.md** | Claude 전용 규칙 | 50~100줄 |
| **LEARN.md** | 오답노트 | 무제한 |
| **scratchpad.md** | 활성 작업 (gitignore) | ~100줄 |
| **spec.md / feature.md** | 기능 정답지 | 200~500줄 |

### Tier A — 병목 보이면 (Week 2+)

| 파일 | 트리거 |
|------|--------|
| `constitution.md` | NFR 손실 발생 시 |
| `ARCHITECTURE.md` | 모듈 5개+ |
| `DECISIONS.md` | "왜 X 선택?" 반복 |
| `CONTROL-MAP.md` | 컴플라이언스 SaaS |

### Tier B — 대형/공개 프로젝트만

| 파일 | 시점 |
|------|------|
| `README.md` | 공개 시 |
| `ROADMAP.md` | 분기 마일스톤 필요 |
| `SECURITY.md` | 보안 정책 필요 |
| `RELEASE.md` | 버저닝 필요 |

---

## 🏆 PART 6 — 평생 명령어 치트시트

### 프로젝트 생성

| 규모 | 명령어 |
|------|--------|
| 소형 | `ai-new my-tool` |
| 중대형 | `ai-new my-saas -Mode B` |
| 대형 | `ai-new huge-app -Mode C` |

### 일상 루틴

| 명령어 | 기능 |
|--------|------|
| `cd-repo my-tool` | 프로젝트 이동 |
| `ai-start login` | 브랜치 생성 |
| `claude` | Claude Code 시작 |
| `ai-done "feat: xxx"` | 커밋 + 푸시 |
| `ai-done "feat: xxx" -Merge` | 커밋 + 푸시 + main 병합 |
| `ai-check` | 키트 상태 점검 |
| `cd-out` | 결과물 폴더 이동 |

### Claude Code 안에서 (Mode B/C)

| 명령어 | 기능 |
|--------|------|
| `/speckit.constitution` | 헌법 작성 (1회) |
| `/speckit.specify "기능"` | 명세 작성 |
| `/speckit.clarify` | 모호함 제거 |
| `/speckit.plan` | 아키텍처 계획 |
| `/speckit.tasks` | 작업 분해 |
| `/speckit.analyze` | 헌법 위반 체크 |
| `/speckit.implement` | 코드 구현 |

### 다중 AI 교차 검증 (매번 안 해도 됨)

```
PAL MCP (Claude Code 안에서):
  pal:thinkdeep "분석해줘" model=gpt-5.2-pro
  pal:consensus "평가해줘" models=[{model:gpt-5.2-pro,stance:for},{model:gpt-5.2,stance:against}]
```

### Git 커밋 형식

```
feat: 새 기능       fix: 버그 수정
refactor: 리팩토링  test: 테스트
docs: 문서          chore: 설정
perf: 성능 개선     ci: CI/CD
```

---

## 🔗 PART 7 — 핵심 링크

| 순위 | 이름 | URL |
|:----:|------|-----|
| 1 | GitHub Spec Kit | https://github.com/github/spec-kit |
| 2 | Claude Code Best Practice | https://github.com/shanraisshan/claude-code-best-practice |
| 3 | Kent Beck BPlusTree3 | https://github.com/KentBeck/BPlusTree3 |
| 4 | BMAD METHOD | https://github.com/bmad-code-org/BMAD-METHOD |
| 5 | Karpathy autoresearch | https://github.com/karpathy/autoresearch |
| 6 | AGENTS.md 표준 | https://agents.md |
| 7 | Anthropic 공식 | https://code.claude.com/docs/en/best-practices |

---

## ⚠️ 알려진 실패 모드

| 실패 | 대응 |
|------|------|
| 얕은 테스트 가짜 통과 | contract test, 의미 있는 assertion 강제 |
| Integration boundary 회귀 | contract test + staging 검증 |
| Security-by-doc만 | trufflehog, npm audit, semgrep CI에 추가 |
| Plan checkbox 관료주의 | DoD를 measurable하게 |
| Drift control silent fail | CLAUDE.md에 "추측 금지" 명시 |

---

## 📁 폴더 구조 전체 지도

```
C:\Users\llorr\dev\
├── kit-templates\          📘 마스터 템플릿 (읽기용)
├── refs\                   📚 세계 표준 원본 (참고용)
│   ├── spec-kit\
│   ├── BMAD-METHOD\
│   ├── autoresearch\
│   └── claude-code-best-practice\
├── repos\                  🔧 실제 작업 (모든 repo 여기)
└── worktrees\              🌿 git worktree (병렬)

D:\2026airesult_byclaude\
└── outputs\                📦 결과물
```

---

*최종 업데이트: 2026-04-12*  
*작성: Claude Opus 4.6 (교차검증 미실시)*
