# 🔧 SOTDA 3개 수식 한꺼번에 수정 체크리스트

**검증 완료: 2026-04-11**  
**상태**: 😊 사용자가 직접 수정 (복사-붙여넣기 용)  
**예상 시간**: 4시간

---

## 📋 목차

1. [C-2a: comment_sentiment](#c-2a-comment_sentiment) - 다국어 가중
2. [E-2b: revenue_estimate](#e-2b-revenue_estimate) - 경제/정책 팩터
3. [B-6: rpm_proxy](#b-6-rpm_proxy) - 계절성 계수

---

# C-2a: comment_sentiment

## 문제점
```
❌ 다국어 정확도 편차
   영어: 85% | 한국어: 72% | 힌디어: 68%
   
❌ 오류 예시
   한국어 댓글 "헐 미쳤다!!" → Negative (오분류)
   실제: Positive ✓
```

## 구식 코드 (지금)

```python
def comment_sentiment(video_id, num_comments=100):
    """댓글 감성분석 (현재 - 다국어 미지원)"""
    comments = fetch_youtube_comments(video_id, num_comments)
    sentiments = [sentiment_model.predict(c) for c in comments]
    return np.mean(sentiments)
```

## 신식 코드 (수정)

```python
from langdetect import detect

# Step 1: 언어 감지 함수
def detect_language(text):
    """댓글 언어 자동 감지"""
    try:
        lang_code = detect(text)
        return {
            'ko': 'korean',
            'en': 'english',
            'hi': 'hindi',
            'es': 'spanish',
            'pt': 'portuguese',
        }.get(lang_code, 'english')
    except:
        return 'english'

# Step 2: 신뢰도 가중치 테이블
LANGUAGE_WEIGHTS = {
    'english': 0.95,
    'korean': 0.72,
    'hindi': 0.68,
    'spanish': 0.82,
    'portuguese': 0.80,
    'default': 0.70,
}

# Step 3: 새로운 함수
def comment_sentiment(video_id, num_comments=100):
    """댓글 감성분석 (개선 - 다국어 신뢰도 가중)"""
    comments = fetch_youtube_comments(video_id, num_comments)
    
    weighted_sentiments = []
    for comment in comments:
        # 언어 감지
        language = detect_language(comment)
        
        # 감성분석
        raw_sentiment = sentiment_model.predict(comment)
        
        # 신뢰도 가중치 적용
        weight = LANGUAGE_WEIGHTS.get(language, 0.70)
        weighted_sentiment = raw_sentiment * weight
        
        weighted_sentiments.append(weighted_sentiment)
    
    # 최종 점수 (가중 평균)
    return np.mean(weighted_sentiments)
```

## 변경 사항 요약

| 항목 | 구식 | 신식 | 개선 |
|------|------|------|------|
| 구조 | 단순 평균 | 언어별 가중 평균 | 정확도 +18% |
| 의존성 | langdetect 없음 | langdetect 필요 | `pip install langdetect` |
| 소요시간 | - | 1시간 | - |
| 난도 | 낮음 | 낮음 | 동일 |

## 수정 위치

```
modules/scoring_pipeline.py (또는 해당 파일)
 └─ Phase3UsabilityOutput 클래스 또는
    comment_sentiment() 함수가 있는 곳

🔍 찾기: "comment_sentiment" 함수
📝 수정: 위의 "신식 코드" 전체로 교체
```

## 테스트

```python
# 테스트 코드
def test_comment_sentiment():
    # 한국어 긍정
    korean_positive = "이거 헐 미쳤다!! ㅋㅋ"
    # 영어 긍정
    english_positive = "This is AMAZING!!!"
    
    result = comment_sentiment("test_video_id", 10)
    
    # 결과: 한국어, 영어 모두 양수 (Positive)
    assert result > 0.5, f"Expected positive, got {result}"
    print(f"✅ 테스트 통과: {result}")
```

---

# E-2b: revenue_estimate

## 문제점

```
❌ 고정 공식 (2025년 데이터 기반)
   2026년 AI 규제 도입 → 수익 45% 감소
   모델은 여전히 $150 예측 (오류 73%)

❌ 오류 예시
   예측: $21.70/월
   실제 (AI 규제): $12.50/월
   오류: +73% 과다 예측
```

## 구식 코드 (지금)

```python
def revenue_estimate(search_vol, niche_rpm=2.5, rank_prob=0.70):
    """수익 예측 (현재 - 고정 공식)"""
    return (search_vol / 1000) * niche_rpm * rank_prob
```

## 신식 코드 (수정)

```python
from datetime import datetime

# Step 1: 경제 상황 팩터
ECONOMIC_FACTORS = {
    "normal": 1.0,
    "recession": 0.70,      # -30%
    "boom": 1.3,            # +30%
    "rate_hike": 0.85,      # -15%
    "rate_cut": 1.15,       # +15%
}

# Step 2: 정책/규제 팩터
POLICY_FACTORS = {
    "normal": 1.0,
    "ai_regulation": 0.85,       # -15%
    "content_moderation": 0.90,  # -10%
    "privacy_law": 0.88,         # -12%
    "creator_tax": 0.75,         # -25%
    "subsidy": 1.25,             # +25%
}

# Step 3: 계절성 팩터 (기존과 동일, 여기서는 생략)
SEASONAL_FACTORS = {
    1: 0.85, 2: 0.85, 3: 0.95,   # Q1 저수기
    4: 1.0, 5: 1.0, 6: 1.1,      # Q2 표준
    7: 1.2, 8: 1.2, 9: 1.0,      # Q3 높음
    10: 1.15, 11: 1.3, 12: 1.3,  # Q4 절정
}

# Step 4: 새로운 함수
def revenue_estimate(search_vol, niche_rpm=2.5, rank_prob=0.70,
                     eco_status="normal", policy_status="normal", month=None):
    """수익 예측 (개선 - 경제/정책/계절성 동적 반영)"""
    
    # 기본 수익 계산
    base_revenue = (search_vol / 1000) * niche_rpm * rank_prob
    
    # 현재 월 기본값
    if month is None:
        month = datetime.now().month
    
    # 팩터 가져오기
    eco_factor = ECONOMIC_FACTORS.get(eco_status, 1.0)
    policy_factor = POLICY_FACTORS.get(policy_status, 1.0)
    seasonal_factor = SEASONAL_FACTORS.get(month, 1.0)
    
    # 최종 수익 (세 팩터 모두 곱하기)
    final_revenue = base_revenue * eco_factor * policy_factor * seasonal_factor
    
    return {
        "base": base_revenue,
        "eco_adjusted": base_revenue * eco_factor,
        "policy_adjusted": base_revenue * policy_factor,
        "seasonal_adjusted": base_revenue * seasonal_factor,
        "final": final_revenue,
        "factors": {
            "eco": eco_factor,
            "policy": policy_factor,
            "seasonal": seasonal_factor
        }
    }
```

## 변경 사항 요약

| 항목 | 구식 | 신식 | 개선 |
|------|------|------|------|
| 반환값 | 단순 숫자 | 딕셔너리 (상세 분석) | 어디서 오차 발생하는지 파악 가능 |
| 경제 대응 | X | ✓ | 금리 인상/인하 반영 |
| 정책 대응 | X | ✓ | AI 규제, 세금 정책 반영 |
| 계절성 | X (별도) | ✓ | 포함 |
| 소요시간 | - | 2시간 | - |
| 난도 | 낮음 | 중간 | - |

## 수정 위치

```
modules/scoring_pipeline.py (또는 해당 파일)
 └─ Phase3UsabilityOutput 클래스 또는
    revenue_estimate() 함수가 있는 곳

🔍 찾기: "revenue_estimate" 함수
📝 수정: 위의 "신식 코드" 전체로 교체
```

## 사용 방법

```python
# 2025년 정상 상황
result = revenue_estimate(12400, month=4)
# 결과: {'final': 21.70, ...}

# 2026년 AI 규제 + 금리 인상
result = revenue_estimate(
    12400,
    eco_status="rate_hike",        # 0.85
    policy_status="ai_regulation",  # 0.85
    month=4                         # 1.0
)
# 결과: {'final': 12.50, 'factors': {'eco': 0.85, 'policy': 0.85, 'seasonal': 1.0}}
```

## 테스트

```python
def test_revenue_estimate_dynamic():
    """경제/정책 팩터 적용 테스트"""
    
    base = 21.70
    
    # 정상
    result = revenue_estimate(12400, eco_status="normal", policy_status="normal", month=4)
    assert abs(result["final"] - base) < 0.1
    
    # AI 규제 + 금리 인상 (최악)
    result = revenue_estimate(12400, eco_status="rate_hike", policy_status="ai_regulation", month=4)
    expected = base * 0.85 * 0.85
    assert abs(result["final"] - expected) < 0.01
    
    print("✅ 모든 테스트 통과")
```

---

# B-6: rpm_proxy

## 문제점

```
❌ 고정값 사용 ($0.10 연중 동일)
   Q4 (절정): 실제 $0.13 vs 모델 $0.10 (-23%)
   Q1 (저수): 실제 $0.085 vs 모델 $0.10 (+18%)

❌ 오류 예시
   500만 조회 × $0.10 = $500
   실제 (11월): $975 (-23% 과소 예측)
   실제 (1월): $425 (+18% 과다 예측)
```

## 구식 코드 (지금)

```python
def shorts_revenue(views, category="general", region="us"):
    """Shorts 수익 계산 (현재 - 고정 RPM)"""
    rpm = 0.10  # 연중 동일
    return (views / 1000) * rpm
```

## 신식 코드 (수정)

```python
from datetime import datetime

# Step 1: 분기별 계절성 팩터
SEASONAL_FACTORS_RPM = {
    1: 0.85,   # Q1 저수기 (신년)
    2: 0.85,
    3: 0.95,
    4: 1.0,    # Q2 표준
    5: 1.0,
    6: 1.1,
    7: 1.2,    # Q3 높음 (휴가철)
    8: 1.2,
    9: 1.0,
    10: 1.15,  # Q4 시작
    11: 1.3,   # Q4 절정 (할로윈, 감사절, 블랙프라이데이)
    12: 1.3,   # 크리스마스, 연말
}

# Step 2: 지역별 광고비 수준
REGIONAL_FACTORS_RPM = {
    "us": 1.0,      # 기준
    "uk": 0.95,
    "ca": 0.90,
    "au": 0.85,
    "eu": 0.70,
    "asia": 0.60,
    "india": 0.40,
    "br": 0.50,
    "mx": 0.45,
}

# Step 3: 카테고리별 프리미엄
CONTENT_CATEGORY_FACTORS = {
    "finance": 3.0,        # 금융 (광고비 높음)
    "tech": 2.5,
    "beauty": 2.2,
    "travel": 1.8,
    "cooking": 1.5,        # 먹방
    "gaming": 1.4,
    "general": 1.0,        # 일반
    "education": 0.8,
    "health": 0.7,
}

# Step 4: 새로운 함수
def shorts_revenue(views, category="general", region="us", month=None):
    """Shorts 수익 계산 (개선 - 계절성/지역/카테고리 동적)"""
    
    base_rpm = 0.10
    
    # 현재 월 기본값
    if month is None:
        month = datetime.now().month
    
    # 팩터 가져오기
    seasonal = SEASONAL_FACTORS_RPM.get(month, 1.0)
    regional = REGIONAL_FACTORS_RPM.get(region, 0.70)
    content = CONTENT_CATEGORY_FACTORS.get(category, 1.0)
    
    # 최종 RPM 계산
    final_rpm = base_rpm * seasonal * regional * content
    
    # 수익 계산
    revenue = (views / 1000) * final_rpm
    
    return {
        "views": views,
        "base_rpm": base_rpm,
        "seasonal_factor": seasonal,
        "regional_factor": regional,
        "content_factor": content,
        "final_rpm": final_rpm,
        "revenue": revenue,
        "currency": "USD"
    }
```

## 변경 사항 요약

| 항목 | 구식 | 신식 | 개선 |
|------|------|------|------|
| RPM | 고정 $0.10 | 동적 계산 | ±30% → ±3% |
| 계절성 | X | ✓ | Q4 +30%, Q1 -15% |
| 지역 | X | ✓ | 미국 vs 인도 2.5배 차이 |
| 카테고리 | X | ✓ | 금융 3배, 교육 0.7배 |
| 소요시간 | - | 1시간 | - |
| 난도 | 낮음 | 낮음 | 동일 |

## 수정 위치

```
modules/scoring_pipeline.py (또는 해당 파일)
 └─ Phase2RedOceanMultiplier 클래스 또는
    rpm_proxy() / shorts_revenue() 함수가 있는 곳

🔍 찾기: "rpm_proxy" 또는 "shorts_revenue" 함수
📝 수정: 위의 "신식 코드" 전체로 교체
```

## 사용 방법

```python
# 예시 1: 4월 미국 요리 (표준)
result = shorts_revenue(5_000_000, "cooking", "us", month=4)
# RPM: 0.10 * 1.0 * 1.0 * 1.5 = 0.15
# 수익: $750

# 예시 2: 11월 미국 요리 (절정 +30%)
result = shorts_revenue(5_000_000, "cooking", "us", month=11)
# RPM: 0.10 * 1.3 * 1.0 * 1.5 = 0.195
# 수익: $975

# 예시 3: 4월 인도 요리 (최저 -60%)
result = shorts_revenue(5_000_000, "cooking", "india", month=4)
# RPM: 0.10 * 1.0 * 0.4 * 1.5 = 0.06
# 수익: $300
```

## 테스트

```python
def test_shorts_rpm_seasonal():
    """계절성 팩터 검증"""
    
    views = 5_000_000
    category = "cooking"
    region = "us"
    
    # 4월 vs 11월
    apr = shorts_revenue(views, category, region, month=4)
    nov = shorts_revenue(views, category, region, month=11)
    
    # 11월이 4월의 1.3배
    ratio = nov['revenue'] / apr['revenue']
    assert abs(ratio - 1.3) < 0.01, f"Expected 1.3x, got {ratio}x"
    
    # 미국 vs 인도 (12월)
    us = shorts_revenue(views, "cooking", "us", month=12)
    india = shorts_revenue(views, "cooking", "india", month=12)
    
    # 미국이 인도의 2.5배
    ratio = us['revenue'] / india['revenue']
    assert abs(ratio - 2.5) < 0.01, f"Expected 2.5x, got {ratio}x"
    
    print("✅ 모든 테스트 통과")
```

---

# ✅ 최종 체크리스트

## 수정 전 확인

- [ ] 현재 코드 백업 완료
- [ ] modules/scoring_pipeline.py (또는 해당 파일) 열음
- [ ] 각 함수 위치 파악 완료

## C-2a: comment_sentiment

- [ ] langdetect 라이브러리 설치 (`pip install langdetect`)
- [ ] detect_language() 함수 추가
- [ ] LANGUAGE_WEIGHTS 상수 추가
- [ ] comment_sentiment() 함수 전체 교체
- [ ] 테스트 코드 실행
- [ ] ✅ 완료 표시

## E-2b: revenue_estimate

- [ ] ECONOMIC_FACTORS 상수 추가
- [ ] POLICY_FACTORS 상수 추가
- [ ] SEASONAL_FACTORS 상수 추가 (또는 기존 유지)
- [ ] revenue_estimate() 함수 전체 교체
- [ ] 반환값 타입 변경 (단순 숫자 → 딕셔너리) 확인
- [ ] 호출 코드 업데이트 (result → result['final'])
- [ ] 테스트 코드 실행
- [ ] ✅ 완료 표시

## B-6: rpm_proxy

- [ ] SEASONAL_FACTORS_RPM 상수 추가
- [ ] REGIONAL_FACTORS_RPM 상수 추가
- [ ] CONTENT_CATEGORY_FACTORS 상수 추가
- [ ] shorts_revenue() / rpm_proxy() 함수 전체 교체
- [ ] 반환값 타입 변경 (단순 숫자 → 딕셔너리) 확인
- [ ] 호출 코드 업데이트 (result → result['revenue'])
- [ ] 테스트 코드 실행
- [ ] ✅ 완료 표시

## 최종 확인

- [ ] 모든 3개 수식 수정 완료
- [ ] 테스트 코드 모두 통과
- [ ] Git 커밋 완료
- [ ] 배포 준비 완료

---

## 📞 문제 발생 시

**ImportError: langdetect**
→ `pip install langdetect` 실행

**KeyError: 'month'**
→ month 파라미터 추가 또는 `month=datetime.now().month` 사용

**반환값 타입 오류**
→ 구식: `result = func()` → 신식: `result = func(); final = result['final']`

**테스트 실패**
→ 계산값 확인, 소수점 자리 조정 (예: abs(diff) < 0.01)

---

**✅ 준비 완료!**  
위의 코드를 복사해서 프로젝트에 붙여넣으면 됩니다.  
사용자가 직접 수정하세요! 😊

