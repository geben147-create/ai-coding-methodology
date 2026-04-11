# Solo AI Coding Master Guide v2.0

> **4개 방법론 통합 + 18분 자막 핵심 반영 | 2026.04.12 최종판**
> 검증: Claude Opus 4.6 + PAL MCP (gpt-5.2-pro + gemini-3-pro-preview)

---

## 목차

1. [단계별 방법론 반영 비율](#1-단계별-방법론-반영-비율)
2. [Module A: 환경 구축 + GitHub 연동](#module-a-환경-구축--github-연동)
3. [Module B: 명세 + 설계 + AI 교차검증](#module-b-명세--설계--ai-교차검증)
4. [Module C: 구현 + 검증 + 배포](#module-c-구현--검증--배포)
5. [PowerShell 함수 (평생 루틴)](#powershell-함수-평생-루틴)
6. [핵심 MD 파일 목록](#핵심-md-파일-목록)
7. [Anti-Patterns + 실패 모드](#anti-patterns--실패-모드)

---

## 1. 단계별 방법론 반영 비율

| 단계 | 방1 (명세/보안/TDD) 5단계 Beck | 방2 (UDM 전체구조) 8단계 PAL | 방3 (AI프롬프트) 18분 자막 1위 | 방4 (CLI 자동화) MD+스크립트 | 해석 |
|------|:---:|:---:|:---:|:---:|------|
| **1. 환경/저장소 구축** | 0% | 20% | 0% | **80%** | `ai-new`, `cd-repo` 등 방4의 쉘 스크립트 기반 물리적 통제 |
| **2. 명세 및 위협 설계** | **60%** | 20% | 20% | 0% | 위협 모델링, Control Matrix 등 방1의 리스크 주도 설계 |
| **3. 다중 AI 교차 검증** | 0% | 30% | **70%** | 0% | 여러 모델 충돌시켜 약점 찾는 프롬프트 엔지니어링 |
| **4. 마이크로 분해/브랜치** | **40%** | 10% | 10% | **40%** | `PLAN.md` 2~5분 단위 + `ai-start` 브랜치 분리 결합 |
| **5. TDD 기반 정밀 구현** | **60%** | 10% | 30% | 0% | RED-GREEN 강제 + 100줄 제한 원칙 |
| **6. 검증 및 단위 커밋** | 30% | 10% | 10% | **50%** | `ai-done` + Control Matrix 검증 조건 |
| **7. 문서 동기화 및 병합** | 20% | 10% | 30% | **40%** | `-Merge` 옵션 + 문서 자동화 프롬프트 결합 |

---

## Module A: 환경 구축 + GitHub 연동

> **방법론 4 (CLI 자동화) 80% 반영**

### A-1. 사전 준비 (최초 1회)

```powershell
# 1) Claude Code 설치 확인
claude --version    # v2.1.0+ 필요

# 2) Git SSH 설정 확인
ssh -T git@github.com    # "Hi username!" 나와야 함

# 3) 필수 도구
node --version       # v20+
python --version     # 3.11+
uv --version         # Python 패키지 매니저
```

### A-2. 디렉토리 구조 (권장)

```
C:\Users\{사용자}\dev\
  ├── kit-templates\    ← MD 템플릿 13개 (한 번만 세팅)
  ├── repos\            ← 모든 프로젝트 (여기서 작업)
  ├── refs\             ← 참고 레포 (spec-kit, bmad 등)
  └── outputs\          ← 결과물 전용
```

### A-3. kit-templates 세팅 (최초 1회)

```powershell
# 이미 있으면 스킵
cd C:\Users\llorr\dev
git clone git@github.com:geben147-create/ai-coding-methodology.git kit-templates-ref
```

### A-4. GitHub 연동 (새 프로젝트마다)

```powershell
# PowerShell 함수로 한 줄 실행
ai-new my-project -Mode B

# 수동으로 할 경우:
mkdir my-project && cd my-project
git init
gh repo create geben147-create/my-project --private --source=. --push
```

### A-5. 프로젝트 모드 선택

| 모드 | 명령어 | 용도 | 포함 파일 |
|------|--------|------|-----------|
| **A** (소형) | `ai-new my-tool` | 스크립트, 유틸리티 | CLAUDE.md, AGENTS.md, LEARN.md, DECISIONS.md |
| **B** (중형) | `ai-new my-saas -Mode B` | SaaS, API 서버 | Mode A + Spec Kit + ROADMAP.md |
| **C** (대형) | `ai-new huge-app -Mode C` | 엔터프라이즈 | Mode B + BMAD + SECURITY.md + RELEASE.md |

---

## Module B: 명세 + 설계 + AI 교차검증

> **방법론 1 (Beck TDD) 60% + 방법론 3 (AI 프롬프트) 70% 반영**

### B-1. Phase 1 — INTENT (명세 작성)

```
# Claude Code 실행 후
claude

# 1) 프로젝트 헌법 설정 (Mode B/C만)
/speckit.constitution
  스택: Python FastAPI / PostgreSQL
  보안: OWASP Top10
  테스트: TDD 80%+
  금지: class component, 하드코딩 시크릿

# 2) 기능 명세
/speckit.specify "사용자 인증 시스템 구현"

# 3) 모호한 점 정리
/speckit.clarify
```

**핵심 산출물**: `spec.md` (Goals + Non-goals + Acceptance Criteria)

### B-2. Phase 2 — DESIGN (설계 + 교차검증)

```
# 설계 계획 생성
/speckit.plan
```

**교차 검증 (매번 안 해도 됨 - 중요 설계 결정 시만)**:

```
# PAL MCP 교차검증 (찬성 vs 반대)
pal:consensus "이 아키텍처 plan을 평가해줘. NFR, 보안, 1인개발 지속가능성 초점"
  models=[
    {model:"gpt-5.2-pro", stance:"for"},
    {model:"gemini-3-pro-preview", stance:"against"}
  ]
```

> 18분 자막 핵심: **6명 만장일치는 연극**. 1 for + 1 against 1라운드면 충분.

### B-3. Phase 3 — DECOMPOSE (작업 분해)

```
# 자동 task 분해
/speckit.tasks

# constitution 위반 자동 체크
/speckit.analyze
```

**결과**: `plan.md`에 각 task = 2~5분 크기, DoD 명시

---

## Module C: 구현 + 검증 + 배포

> **방법론 1 (TDD) 60% + 방법론 4 (CLI) 50% 반영**

### C-1. Phase 4 — BUILD (TDD 구현)

```powershell
# 기능 브랜치 생성
ai-start login    # → feat/login-20260412 브랜치 자동 생성

# Claude Code 실행
claude
```

Claude 안에서 반복:

```
# "go" 한 마디 → 자동 TDD 루프
go

# 각 task별 흐름:
# 1. RED   — 실패하는 테스트 먼저 작성
# 2. GREEN — 테스트 통과하는 최소 코드
# 3. REFACTOR — 리팩토링 (테스트 통과 유지)
# 4. COMMIT — atomic commit (100줄 이하)
# 5. CHECK — plan.md [x] 체크 + 메모

# Drift 감지 시: STOP → spec.md 업데이트 PR
# 어려운 알고리즘: pal:chat model=gpt-5.1-codex thinking_mode=high
# 외부 SDK 확인: pal:apilookup "<SDK명> latest 2026"
```

### C-2. Phase 5 — VERIFY (검증)

```
# 보안 검증 (auth/data 경로만)
pal:secaudit

# 코드 리뷰
pal:codereview

# 반박 테스트 (선택)
pal:challenge "이 PR이 보안적으로 안전하다는 주장을 비판해라"

# 커밋 직전 게이트
pal:precommit
```

**Control Matrix 검증** (컴플라이언스 SaaS일 때):

| ID | 요구사항 | 통제 | 구현 표면 | 증거/로그 | 테스트 |
|----|----------|------|-----------|-----------|--------|
| C01 | 인증 필수 | OAuth+JWT | `/api/*` middleware | `audit_log` | `test_unauth_blocked` |
| C02 | 90일 보존 | retention cron | DB job | rotation log | `test_retention` |

### C-3. Phase 6 — SHIP (배포)

```powershell
# 커밋 + 푸시 (브랜치 유지)
ai-done "feat(auth): implement JWT login"

# 커밋 + 푸시 + main 병합 + 브랜치 삭제
ai-done "feat(auth): implement JWT login" -Merge
```

### C-4. Phase 7 — EVOLVE (회고)

```
# 5분 post-ship 회고
# 1. DECISIONS.md 업데이트
# 2. LEARN.md에 새로운 교훈 기록
# 3. CONTROL-MAP drift 점검
# 4. plan.md 다음 세션용 메모 추가
```

---

## PowerShell 함수 (평생 루틴)

> `notepad $PROFILE` → 맨 아래에 붙여넣기 → PowerShell 재시작

```powershell
# ═══════════════════════════════════════════════════════
#   AI 코딩 키트 - 평생 루틴 함수 (2026.04)
# ═══════════════════════════════════════════════════════

$global:KIT     = 'C:\Users\llorr\dev\kit-templates'
$global:REPOS   = 'C:\Users\llorr\dev\repos'
$global:OUTPUTS = 'D:\2026airesult_byclaude\outputs'
$global:REFS    = 'C:\Users\llorr\dev\refs'

# --- 프로젝트 생성 ---
# ai-new my-tool           → 소형 (A)
# ai-new my-saas -Mode B   → 중형 (Spec Kit)
# ai-new huge -Mode C      → 대형 (Spec Kit + BMAD)
function New-AIProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)][string]$Name,
        [ValidateSet('A','B','C')][string]$Mode = 'A'
    )
    Set-Location $global:REPOS
    switch ($Mode) {
        'A' {
            New-Item -ItemType Directory -Force $Name | Out-Null
            Set-Location $Name; git init -q
            Copy-Item "$global:KIT\AGENTS.md","$global:KIT\CLAUDE.md",
                      "$global:KIT\LEARN.md","$global:KIT\DECISIONS.md",
                      "$global:KIT\README.md" . -ErrorAction SilentlyContinue
        }
        'B' {
            uvx --from git+https://github.com/github/spec-kit.git specify init $Name --ai claude
            Set-Location $Name
            Copy-Item "$global:KIT\AGENTS.md","$global:KIT\CLAUDE.md",
                      "$global:KIT\LEARN.md","$global:KIT\DECISIONS.md",
                      "$global:KIT\ROADMAP.md" . -Force -ErrorAction SilentlyContinue
        }
        'C' {
            uvx --from git+https://github.com/github/spec-kit.git specify init $Name --ai claude
            Set-Location $Name
            Copy-Item "$global:KIT\AGENTS.md","$global:KIT\CLAUDE.md",
                      "$global:KIT\LEARN.md","$global:KIT\DECISIONS.md",
                      "$global:KIT\README.md","$global:KIT\RELEASE.md",
                      "$global:KIT\ROADMAP.md","$global:KIT\SECURITY.md" . -Force
            npx bmad-method install
        }
    }
    @"
scratchpad.md
.env
node_modules/
dist/
__pycache__/
.venv/
*.log
"@ | Out-File .gitignore -Encoding UTF8
    $h = git rev-parse HEAD 2>$null
    if (-not $h) { git add -A; git commit -q -m "chore: init (Mode $Mode)"; git branch -M main 2>$null }
    Write-Host "`n[OK] $Name (Mode $Mode) -> $(Get-Location)" -ForegroundColor Green
}

# --- 기능 브랜치 시작 ---
# ai-start login
function Start-AIFeature {
    param([Parameter(Mandatory, Position=0)][string]$Name)
    git switch main; git pull --ff-only
    $d = Get-Date -Format 'yyyyMMdd'
    git switch -c "feat/$Name-$d"
    Write-Host "[OK] feat/$Name-$d" -ForegroundColor Green
}

# --- 기능 마감 ---
# ai-done "feat: login"          -> commit + push
# ai-done "feat: login" -Merge   -> + main 병합
function Complete-AIFeature {
    param(
        [Parameter(Mandatory, Position=0)][string]$Message,
        [switch]$Merge
    )
    $cur = git branch --show-current
    if ($cur -eq 'main') { Write-Host "main 직접 커밋 금지" -ForegroundColor Red; return }
    git add -A; git commit -m $Message
    git push -u origin HEAD
    if ($Merge) {
        git switch main; git pull --ff-only
        git merge --no-ff $cur -m "Merge $cur"; git push
        git branch -d $cur
        Write-Host "[OK] 병합 완료" -ForegroundColor Green
    }
}

# --- 프로젝트 이동 ---
function Enter-Repo {
    param([Parameter(Mandatory, Position=0)][string]$Name)
    $p = Join-Path $global:REPOS $Name
    if (Test-Path $p) { Set-Location $p; git status -s }
    else { Write-Host "없음: $p" -ForegroundColor Red }
}

# --- 상태 점검 ---
function Test-AIKit {
    Write-Host "KIT:     $(if(Test-Path $global:KIT){'OK'}else{'X'}) $global:KIT"
    Write-Host "REPOS:   $(if(Test-Path $global:REPOS){'OK'}else{'X'}) $global:REPOS"
    Write-Host "OUTPUTS: $(if(Test-Path $global:OUTPUTS){'OK'}else{'X'}) $global:OUTPUTS"
}

Set-Alias ai-new   New-AIProject
Set-Alias ai-start Start-AIFeature
Set-Alias ai-done  Complete-AIFeature
Set-Alias cd-repo  Enter-Repo
Set-Alias ai-check Test-AIKit
```

---

## 핵심 MD 파일 목록

### Tier 0 - 필수 (3개)

| 파일 | 역할 | 분량 |
|------|------|------|
| **CLAUDE.md** | AI 행동 규칙 (시스템 프롬프트) | **200줄 이하** |
| **spec.md** | 정답지 (Goals + Non-goals + AC) | 기능당 1개 |
| **plan.md** | 할 일 순서 (체크박스) | task당 2~5분 |

### Tier 1 - 강력 추천 (3개)

| 파일 | 역할 |
|------|------|
| **DECISIONS.md** | 왜 이렇게 결정했는지 (ADR) |
| **LEARN.md** | 오답노트 (같은 실수 반복 방지) |
| **CONTROL-MAP.md** | 컴플라이언스 매트릭스 (SaaS 필수) |

### Tier 2 - 선택

| 파일 | 조건 |
|------|------|
| SECURITY.md | 인증/PII 다루는 프로젝트 |
| ROADMAP.md | 3+ 마일스톤 |
| ARCHITECTURE.md | 시스템 복잡도 높을 때 |

---

## 참고 GitHub 레포 (좋은 순)

| 순위 | 레포 | 링크 | 용도 |
|------|------|------|------|
| 1 | shanraisshan/claude-code-best-practice | https://github.com/shanraisshan/claude-code-best-practice | 실전 노하우 모음 |
| 2 | KentBeck/BPlusTree3 | https://github.com/KentBeck/BPlusTree3 | TDD CLAUDE.md 원본 |
| 3 | github/spec-kit | https://github.com/github/spec-kit | SDD 공식 도구 |
| 4 | bmadcode/BMAD-METHOD | https://github.com/bmadcode/BMAD-METHOD | 대형 프로젝트 Spec |
| 5 | obra/superpowers | https://github.com/obra/superpowers | Enforced gates |

---

## Anti-Patterns + 실패 모드

### 절대 하지 마라

| 패턴 | 이유 |
|------|------|
| 6명 AI 만장일치 | 연극. 훈련 데이터 비슷해서 가짜 동의 |
| spec 없이 코딩 | "무엇을 만들지" 모르고 "어떻게"부터 하면 망함 |
| 테스트 나중에 | 나중 = 안 함. TDD는 30초면 시작 |
| 100줄 초과 커밋 | 리뷰 불가능. atomic commit 강제 |
| CLAUDE.md 200줄 초과 | AI가 무시하기 시작함 |
| AGENTS.md + CLAUDE.md 동시 | 권한 충돌. 하나만 선택 |

### 알려진 실패 모드

1. **얕은 테스트 가짜 통과**: over-mock → contract test 강제
2. **Integration 회귀**: 결제/이메일 TDD 못 잡음 → staging 검증
3. **Security-by-doc**: md만 있고 CI 게이트 없음 → trufflehog, semgrep 필수
4. **Drift silent fail**: Claude가 추측하고 진행 → "BLOCKED" 외치기 강제

---

## Drift Control (CLAUDE.md에 반드시 추가)

```markdown
# DRIFT CONTROL
If implementation diverges from spec.md:
  a) Update spec.md AND DECISIONS.md in the SAME commit, OR
  b) STOP and ask human. NEVER silently drift.

# UNCERTAINTY
If ambiguous, output "BLOCKED: <질문>" - NEVER guess.
```

---

## 빠른 시작 체크리스트

```
[ ] 1. PowerShell 프로필에 함수 붙여넣기 (최초 1회)
[ ] 2. ai-check 으로 환경 확인
[ ] 3. ai-new my-project -Mode B
[ ] 4. claude 실행
[ ] 5. /speckit.constitution (헌법 설정)
[ ] 6. /speckit.specify "기능 한 문장"
[ ] 7. /speckit.plan (설계)
[ ] 8. ai-start feature-name (브랜치)
[ ] 9. go (TDD 루프 시작)
[ ] 10. ai-done "feat: 완료" -Merge
```

---

*v2.0 | 2026-04-12 | Claude Opus 4.6 + PAL MCP 교차검증*
*4개 방법론 통합: Beck TDD + UDM + 18분자막 1위개발자 + CLI 자동화*
