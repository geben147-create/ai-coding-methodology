# 종합 디자인 시스템 및 구현 가이드

---

## 1️⃣ 문제점 분석

### **문제 1: 아이콘이 기본 이모티콘만 나온다**

**현재 Style F 코드 (05-editor.html 예):**

```html
<div class="ni"><span class="ni-ico">✏️</span>에디터</div>
<div class="ni"><span class="ni-ico">⚙️</span>설정</div>
```

**원인:**

- `design-system.md`에 **아이콘 시스템이 정의되지 않음**
- 모든 아이콘이 Unicode 이모티콘으로 하드코딩됨
- 실제 아이콘 가이드 없음

---

### **문제 2: 오른쪽에 여백이 많다**

**현재 Style F 레이아웃 (06-settings.html):**

```css
.main { margin-left:260px; padding:32px 42px; flex:1; max-width:880px; }
```

**원인:**

- `design-system.md`는 **max-width 제한 규정 없음**
- Style F는 `max-width:880px`로 고정 → 큰 화면에서 오른쪽 여백 발생
- 콘텐츠가 narrow하게 제한됨

---

### **문제 3: 박스/라인이 고정되어 있다**

**현재 값 (Style F CSS):**

```
border-radius: 28px-48px (통일)
border-bottom: 2px solid var(--cream)
```

**원인:**

- Style F의 극단적 Claymorphism 규격이 모든 곳에 같음
- `design-system.md`와는 별개 시스템
- 유연성이 없음

---

## 2️⃣ design-system.md에서 해당 부분 원문

### **현재 design-system.md의 아이콘 섹션:**

```
❌ 없음 — 아이콘 정의 자체가 없습니다
```

### **현재 design-system.md의 레이아웃 규칙 (3.1):**

```
### 3.1 공통 규칙
- **모서리**: 직각 (border-radius: 0) — 프리미엄/컨설팅 느낌
- **그림자**: 없음 또는 최소 (`0 1px 3px rgba(0,0,0,0.04)`)
- **구분선**: 얇은 회색 (`#E5E7EB`) 1px solid
- **여백**: 컴팩트하되 답답하지 않게 (padding 16~24px)
```

→ **이것이 Style A/B/C 기준이고, Style F는 다르게 정의됨**

---

## 3️⃣ 두 가지 수정 접근법

| 방법 | 설명 | 장점 | 단점 |
| --- | --- | --- | --- |
| **Approach A: design-system.md 업데이트** | 디자인 시스템에 아이콘+레이아웃 섹션 추가 | 모든 스타일에 통일된 기준 적용 | Style A/B/C도 리팩토링 필요할 수 있음 |
| **Approach B: 명령어로 Style F만 수정** | sed/awk로 Style F 파일들만 일괄 변경 | 빠른 수정, 다른 스타일 안전 | 설계 문서와 코드 불일치 |

---

## 4️⃣ 권장안 (3단계)

### **Step 1: design-system.md에 아이콘 + 레이아웃 섹션 추가 (권장)**

사용자가 직접 edit하거나, 내가 템플릿 제공:

```markdown
## 7. 아이콘 시스템

### 7.1 아이콘 정의 방식
각 UI 요소는 아래 프롬프트 기반 아이콘 정의:
- data-icon-prompt="[설명]" 속성으로 마크업
- 나중에 SVG/Figma 자동 생성 연동 가능
```

### **Step 2: 여백 규칙 추가**

```markdown
### 3.4 콘텐츠 너비
- 모바일: 100%
- 데스크톱: max-width 1200px (여백 허용)
- 극단적 Claymorphism: max-width 1000px
```

### **Step 3: 아이콘 명령어로 일괄 변경**

```bash
# 모든 이모티콘 → 프롬프트 기반 마크업으로 변환
find mockups/style-E-1-grok-4-reasoning-41126-test/ -name "*.html" -exec sed -i \
  's/<span class="ni-ico">.*<\/span>/data-icon-prompt="TODO"/g' {} \;
```

---

## 5️⃣ 아이콘 프롬프트 시스템 제안

```html
<!-- Before (이모티콘) -->
<div class="ni"><span class="ni-ico">📊</span>대시보드</div>

<!-- After (프롬프트 기반) -->
<div class="ni" data-icon-prompt="dashboard metrics in line icon style">
  <span class="ni-ico" role="img" aria-label="dashboard"></span>
  대시보드
</div>
```

### **프롬프트 예시 (PRD에 추가할 내용):**

```markdown
아이콘 프롬프트 라이브러리:

**네비게이션:**
- 대시보드: "bar chart and metrics in minimalist line icon"
- 콘텐츠: "document or page outline icon"
- 에디터: "pencil or edit icon with minimal stroke"
- 규제 현황: "balance scale or law icon"
- 감사 로그: "checklist or timeline icon"

**액션:**
- 추가/생성: "plus sign in circle"
- 삭제: "trash can outline"
- 수정: "pencil icon"
- 승인: "checkmark icon"
```

---

## 6️⃣ 다음 단계 (사용자 결정)

### **선택지:**

```
A) design-system.md 업데이트 + 명령어 수정
   → 통일된 설계 문서 구축 (장기 관점)
   → 내가 템플릿 제공, 당신이 최종 결정

B) Style F만 빠르게 수정
   → 명령어로 여백/아이콘 일괄 변경
   → design-system.md는 나중에

C) 하이브리드
   → design-system.md에 아이콘 섹션만 추가
   → Style F 여백은 별도 --style-f-layout 변수 추가
```

어느 방식으로 진행할까요? 또는 아이콘 프롬프트 예시를 더 구체적으로 보고싶으신가요?

---

## 7️⃣ PRD vs 디자인 시스템 역할 분리

### **PRD에 넣으면 안 되는 이유**

| 문서 | 역할 | 예시 |
| --- | --- | --- |
| PRD | "무엇을 만들 것인가" (기능 요구사항) | "금칙어 감지 시 사용자에게 표시해야 한다" |
| 디자인 시스템 | "어떻게 보여줄 것인가" (시각 규칙) | "CRITICAL은 빨간 배경 + 좌측 보더" |

PRD에 색상/보더/폰트 같은 걸 넣으면 기능 스펙과 디자인 스펙이 섞여서 나중에 둘 다 수정하기 어려워집니다.

---

### **현재 실제로 벌어지고 있는 문제**

지금 목업마다 스타일이 다른 이유:

- Style A → 자체 CSS (스큐어모피즘)
- Style B → 자체 CSS (프리미엄, 여백 많음)
- Style C → 자체 CSS (TRUSTA, 컴팩트)
- → 각각 독립적이라 색상 체계가 통일 안 됨

---

### **해결책: 별도 디자인 시스템 문서 1개**

PRD를 건드리지 않고, **디자인 시스템 문서 하나만 만들면** 모든 목업이 이걸 참조합니다.

**위치**: `docs/design-system.md`

**이 파일에 들어갈 내용:**

- 컴플라이언스 색상 체계 (빨강/노랑/초록/파랑/보라)
- 폰트 규칙
- 각 화면별 필수 UI 요소 목록
- 카피라이팅 톤 (개발자 언어 → 고객 언어)

이렇게 하면 새 목업(Style D, E...)을 만들 때도 **색상 체계와 필수 기능이 빠지지 않습니다.**

---

## 8️⃣ 생성 완료 내용

### **파일 위치**: `docs/design-system.md`

### **포함된 내용:**

- ✅ 색상 시스템 — 브랜드 색상 + 컴플라이언스 7단계 색상 체계 (CRITICAL~판례) + CSS 코드
- ✅ 타이포그래피 — 폰트, 굵기, 크기 기준 전부
- ✅ 레이아웃 — 직각 모서리, 사이드바, 카드 규칙
- ✅ 화면별 필수 UI 요소 — 6개 화면 각각 체크리스트
- ✅ 카피라이팅 톤 — 기술 용어 → 고객 언어 변환표
- ✅ 금지 사항 — 미인증 마크, 고객사명 노출 등

이제 새 목업을 만들 때 이 문서를 참조하면 빠지는 기능이나 색상 불일치가 없습니다.

---

## 9️⃣ 컴플라이언스 시각 강화

### **CRITICAL 플래그**: 빨간 배경 + 빨간 좌측 보더 + 키워드 빨간색 하이라이트
### **WARNING 플래그**: 노란 배경 + 노란 좌측 보더
### **법률 조문**: 파란색 배경 박스 + 법조문 번호 굵게
### **판례**: 보라색 배경 박스로 구분
### **수정 제안**: 초록색 배경 + 취소선(before) → 초록(after) 형태
### **"자동 수정 적용" 버튼 추가**

---

## 🔟 추가된 기능/시각화 (화면별)

| 화면 | 추가된 요소 |
| --- | --- |
| **01-login** | 기능 카드 4개, Trusted By 고객사, 4칸 지표 바 |
| **02-signup** | 가격 플랜 3개, 고객 추천사, 비밀번호 강도 표시, 직책 선택 |
| **03-dashboard** | CSS 바 차트(주간 검증), SVG 도넛 차트(상태 분포), 스파크라인, 국가별 컴플라이언스 바, 규제 업데이트, Quick Actions 4칸, 배포 채널 컬럼, 사이드바에 배포 메뉴 |
| **04-content-detail** | SVG 게이지 차트, 자동 수정 제안 박스, 활동 타임라인 5건, 배포 정보 패널, SHA-256 해시 표시, 판례 번호 |
| **05-editor** | 폰트 통일 (기능은 이전 버전 유지) |
| **06-settings** | 폰트 통일 (기능은 이전 버전 유지) |

---

## 1️⃣1️⃣ Style D: Soft Neumorphic 완성

### **폴더**: `C:\Users\llorr\dev\repos\LEXlogicThread\mockups\style-D-test\`

```
mockups/
├── style-A-skeuomorphic/     ← 하드웨어 UI, 블루 LED
├── style-B-test/             ← 프리미엄 컨설팅, 직각, 여유
├── style-C-trusta/           ← TRUSTA 컴팩트, 직각, 네이비+골드
└── style-D-test/             ← 소프트 뉴모피즘, 둥근, 파스텔 ✅ NEW
```

---

### **Style D 디자인 DNA**

| 항목 | 값 |
| --- | --- |
| 배경 | 소프트 그레이 `#EEF0F5` |
| 표면 | 밝은 그레이 `#F0F2F7` |
| 그림자 | 뉴모피즘 (볼록: 밝+어둠 / 오목: inset) |
| 모서리 | **둥근** (12~24px border-radius) |
| 주색 | 소프트 퍼플 `#5B6ABF` |
| 포인트 | 워밍 피치 `#E8A87C` |
| 폰트 | Plus Jakarta Sans + Noto Sans KR |
| 컴플라이언스 색상 | 디자인 시스템 그대로 적용 |
| 전체 느낌 | 부드럽고 촉감 있는, 물리적 깊이감 |

---

### **4개 스타일 비교**

|  | Style A | Style B | Style C | Style D |
| --- | --- | --- | --- | --- |
| 느낌 | 하드웨어 | 컨설팅 | 컴팩트 | **소프트** |
| 모서리 | 둥근 | 직각 | 직각 | **둥근** |
| 그림자 | 강한 | 없음 | 없음 | **뉴모피즘** |
| 배경 | 연보라 | 화이트 | 화이트 | **소프트 그레이** |
| 톤 | 차가운 | 차가운 | 차가운 | **따뜻한** |

브라우저에서 확인해 주세요.

---

## 1️⃣2️⃣ 수동으로 폰트/크기/로고 바꾸는 방법

### **파일 열기**

VS Code에서 파일 열기: `Ctrl + O` → 아래 폴더로 이동

```
C:\Users\llorr\dev\repos\LEXlogicThread\mockups\style-C-trusta\
```

아무 `.html` 파일이나 열면 됩니다.

---

### **찾기/바꾸기 단축키**

`Ctrl + H` (VS Code에서 찾아 바꾸기)

---

### **A. 폰트 바꾸기**

모든 6개 파일의 상단 `<style>` 안에 아래 코드가 있습니다.

#### **현재 원문 (찾을 내용):**

```css
* { font-family:"Inter","Noto Sans KR",sans-serif; margin:0; padding:0; box-sizing:border-box; }
h1,h2 { font-family:"Cormorant Garamond","Noto Serif KR",serif; font-weight:600; }
```

#### **바꿀 내용 (이걸로 대체):**

```css
* { font-family:"Noto Sans KR","Inter",sans-serif; margin:0; padding:0; box-sizing:border-box; font-weight:400; }
h1,h2 { font-family:"Noto Serif KR","Merriweather",Georgia,serif; font-weight:700; }
h3 { font-family:"Noto Sans KR","Inter",sans-serif; font-weight:500; }
```

---

### **Google Fonts 링크도 바꿔야 합니다.**

#### **현재 원문:**

```html
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@500;600;700&family=Inter:wght@300;400;500;600&family=Noto+Sans+KR:wght@300;400;500;600&family=Noto+Serif+KR:wght@500;700&display=swap" rel="stylesheet">
```

#### **바꿀 내용:**

```html
<link href="https://fonts.googleapis.com/css2?family=Merriweather:wght@400;700&family=Inter:wght@300;400;500;600&family=Noto+Sans+KR:wght@300;400;500;600&family=Noto+Serif+KR:wght@400;500;700&display=swap" rel="stylesheet">
```

---

### **B. 글자 크기 바꾸기**

각 파일에서 `Ctrl + H`로 찾아 바꿀 수 있는 주요 크기들:

| 요소 | 현재 크기 | 찾을 코드 | 바꿀 코드 |
| --- | --- | --- | --- |
| 페이지 제목 | `font-size:24px` | `font-size:24px` | `font-size:28px` |
| 통계 숫자 | `font-size:28px` | `font-size:28px` | `font-size:32px` |
| 카드 제목 | `font-size:13px` | `font-size:13px` (card-hd 안) | `font-size:15px` |
| 본문 텍스트 | `font-size:12px` | `font-size:12px` | `font-size:13px` |
| 라벨 | `font-size:10px` | `font-size:10px` | `font-size:11px` |
| 사이드바 메뉴 | `font-size:12px` | `.ni` 안 `font-size:12px` | `font-size:13px` |

**주의**: `font-size:12px`는 여러 곳에 있으니, 한꺼번에 바꾸지 말고 하나씩 확인하면서 바꾸세요.

---

### **C. 로고(브랜드명) 바꾸기**

#### **사이드바 로고 (03~06 파일):**

**현재 원문:**

```html
<div class="s-logo"><div class="ico">&#9878;</div><span>TRUSTA</span></div>
```

**바꿀 내용 (예: 이름을 "MyBrand"로, 아이콘을 다른 걸로):**

```html
<div class="s-logo"><div class="ico">&#9733;</div><span>MyBrand</span></div>
```

---

#### **로그인/회원가입 로고 (01, 02 파일):**

**현재 원문:**

```html
<div class="logo-icon">&#9878;</div>
<div class="logo-name">TRUSTA</div>
```

**바꿀 내용:**

```html
<div class="logo-icon">&#9733;</div>
<div class="logo-name">MyBrand</div>
```

---

#### **사용 가능한 아이콘 (HTML 특수문자):**

| 코드 | 결과 | 의미 |
| --- | --- | --- |
| `&#9878;` | ⚖ | 저울 (법률) |
| `&#9733;` | ★ | 별 |
| `&#9830;` | ♦ | 다이아몬드 |
| `&#9670;` | ◆ | 검은 다이아몬드 |
| `&#10004;` | ✔ | 체크 |
| `&#9827;` | ♣ | 클로버 |
| `&#10070;` | ❖ | 사각별 |

---

### **D. 색상 바꾸기 (참고)**

모든 파일 상단 `:root` 안에 있습니다:

```css
--navy:#112240;     /* 메인 진한 색 → 바꾸면 사이드바, 버튼 전부 변경 */
--gold:#C5A869;     /* 포인트 골드 → 바꾸면 악센트 전부 변경 */
--border:#E5E7EB;   /* 구분선 색 */
```

---

## 1️⃣3️⃣ 기능/시각화 부족 문제

맞습니다. 현재 Style C에는 Style A에 있는 기능들이 빠져 있습니다:

| 누락된 기능 | Style A에는 있음 | Style C에는 없음 |
| --- | --- | --- |
| 차트/그래프 | 바 차트, 도넛 차트 | 없음 |
| 시각화 패널 | 컴플라이언스 게이지 | 숫자만 표시 |
| 상세 기능 | Threads 배포, 예약 | 없음 |
| 감사 로그 테이블 | 이력 표시 | 없음 |
| 규제 현황 패널 | 국가별 현황 | 없음 |

**차트/그래프는 HTML만으로도 가능합니다** (CSS로 바 차트, SVG로 도넛 차트). 구현 단계가 아니어도 목업에 넣을 수 있습니다.

Style C에 이런 시각화 요소들과 누락된 기능들을 추가해서 업그레이드할까요?

---

## 1️⃣4️⃣ 파일 접근 방법

### **폴더 경로 (복사해서 탐색기 주소창에 붙여넣기):**

```
C:\Users\llorr\dev\repos\LEXlogicThread\mockups\style-C-trusta\
```

**파일들을 탐색기에서 찾기:**

탐색기에서 아무 HTML 파일이나 **더블클릭**하면 크롬에서 바로 열립니다.

---

## 1️⃣5️⃣ 디자인을 빠르게 확인하는 방법

### **1. Antigravity 안에서 바로 비주얼(디자인)을 볼 수 있나요?**

Antigravity 채팅창 우측에 디자인 UI를 띄워주는 기능(Artifact 기능)이 있기는 합니다. 하지만 이 기능은 **'AI가 방금 작성한 코드'를 임시로 확인**할 때 쓰이는 기능입니다. 지금처럼 이미 내 컴퓨터(C 드라이브 폴더)에 저장되어 있는 여러 개의 HTML 파일들을 동시에 웹사이트처럼 로드해서 띄워주는 명령어는 없습니다.

VS Code 자체도 기본적으로 '텍스트 편집기'이기 때문에, VS Code 안에서 HTML 파일을 클릭하면 디자인 뷰가 아니라 글자(코드)만 보이는 것이 정상입니다. 디자인을 보시려면 **무조건 외부 브라우저(크롬 등)**를 통해야 합니다.

---

### **2. 지금 코드가 아닌 "디자인"을 바로 확인하는 가장 확실한 방법 (드래그 앤 드롭)**

명령어가 먹히지 않는다면, 명령어 치고 에러와 씨름할 필요 없이 100% 무조건 열리는 **물리적 방법**을 쓰시는 게 최고입니다.

1. 먼저 크롬 브라우저를 하나 켭니다.
2. VS Code 왼쪽 파일 트리에 있는 `01-login.html` 파일에 **오른쪽 클릭 → `Reveal in File Explorer` (파일 탐색기에서 표시)**를 선택합니다.
3. 노란색 윈도우 기본 폴더 창이 열리면, 거기에 있는 `01-login.html` 파일을 마우스로 꾹 누른 채로 **열어둔 크롬 브라우저 창 한가운데로 끌어다 떨어뜨립니다 (드래그 앤 드롭)**.
4. 짜잔! 코드가 아닌 완성된 웹 디자인 화면이 크롬에 바로 뜹니다.

---

### **3. 앞으로 코드를 수정할 때마다 자동으로 편하게 보는 방법 (Live Server 추천)**

방금처럼 매번 드래그하기 귀찮으시죠? 가장 대중적이고 압도적으로 편리한 방법은 **'Live Server'**라는 확장 프로그램을 까는 것입니다. (어려운 명령어를 외울 필요가 없습니다)

1. VS Code 제일 왼쪽 메뉴판에서 5번째에 있는 **블록 모양 아이콘 (Extensions/확장)**을 클릭합니다.
2. 검색창에 **`Live Server`** 라고 검색합니다. (보라색 와이파이 안테나 모양 아이콘, 만든이: Ritwick Dey)
3. 파란색 **[Install (설치)]** 버튼을 누릅니다.
4. 설치가 끝난 후, 아까 그 `01-login.html` 코드 화면 아무 곳에나 마우스 오른쪽 버튼을 누릅니다.
5. 메뉴 하단에 **`Open with Live Server`** 라는 버튼이 새로 생겼을 겁니다. 이걸 누루면 알아서 크롬 창이 열리면서 해당 페이지의 '디자인'을 예쁘게 보여줍니다. (심지어 코드를 수정하고 저장하면 새로고침을 안 해도 디자인이 알아서 자동으로 바뀝니다!)

---

### **4. 굳이 꼭 '명령어'를 터미널에 쳐서 크롬으로 열고 싶으시다면?**

터미널 명령어(CLI)를 선호하신다면, 아래 명령어를 복사해서 VS Code 터미널 창에 붙여넣고 엔터를 치시면 크롬 브라우저가 특정 HTML 파일을 물고 열리게 됩니다. (이전 AI가 썼던 명령어보다 윈도우 파워셸에서 좀 더 확실한 방법입니다.)

```powershell
Start-Process "chrome.exe" "C:\Users\llorr\dev\repos\LEXlogicThread\mockups\style-A-skeuomorphic\01-login.html"
```

하지만 장기적으로 개발 작업을 하실 때는, 위에서 설명해 드린 **3번(Live Server 설치) 방법이 백만 배 편하실 겁니다.** 한 번만 설치해 두시면 모든 스트레스가 사라지니 꼭 3번 방법을 추천합니다.

---

## 1️⃣6️⃣ 역할 설명: AI Master (프롬프트 제조기)

```
[저의 정확한 역할과 작업 프로세스]

어떤 사진(기능)이 주어지든, 그 기능을 최고의 스큐어모프 스타일로 디자인하게 만드는 
'최상급 프롬프트 제조기(AI Master)' 역할을 수행
```

---

### **사진 분석**

올려주신 사진을 보고 "아, 이건 어떤 기능(예: 볼륨 조절, 스마트폼 제어 등)을 하는 앱이구나" 하고 핵심 기능과 맥락만 추출합니다.

---

### **스타일 이식**

사진 속 원래 디자인이 어떻든 상관없이, 앞서 제공해주신 **[프리미엄 스큐어모피즘 (매트 플라스틱, LED 이너 글로우, 모던 산세리프체 등)]** 스타일 규칙을 그 기능에 덮어씌웁니다.

---

### **마스터 프롬프트 생성**

최종적으로 어떤 AI든 이 템플릿을 입력받았을 때, 사진 속 기능들을 프리미엄 스큐어모프 톤앤매너로 똑같이 디자인해 낼 수 있도록 "완벽하게 세팅된 AI 마스터 프롬프트(명령어)" 자체를 출력해 드리는 것입니다.

---

*문서 생성 완료 — 2026-04-11*
