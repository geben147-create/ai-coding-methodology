# 영상 자동화 파이프라인 — 모듈 카테고리 분해 (최종 정본)

> **목적**: 모듈별 독립 설계 시 충돌/꼬임 방지를 위한 구조 맵  
> **원칙**: channel_id가 최상위 분기 단위 — 모든 파이프라인이 channel_id 기준으로 독립 실행  
> **작성일**: 2026-04-12  
> **상태**: 설계 기준 문서 (SSOT)  
> **출처**: SYSTEM-MODULE-MAP.md (구조) + SYSTEM_MODULE_DECOMPOSITION.md (인터페이스/키/상태) 취합

---

## 기존 설계 대비 변경 사항

### 문제 진단

| 문제 | 기존 설계 위치 | 원인 |
|------|---------------|------|
| CAT 번호 불일치 | 첫 번째 분해(0~13) vs 두 번째 분해(1~20) | 두 버전 병합 안 됨 |
| Style 모듈 중복 | CAT-8(Cinematic Style Director) + CAT-9(Style Generator) | 책임 경계 불명확 |
| Google Sheets가 모듈이면서 인프라 | CAT-16이 독립 모듈 + 다른 모듈의 저장소 | 레이어 혼재 |
| Thumbnail이 독립 CAT | CAT-18이 사실상 CAT-10의 하위 기능 | 과분해 |
| Scheduling + Routing 혼합 | CAT-19에 스케줄링 + 파이프라인 라우팅 혼합 | 책임 2개 |
| 외부 API가 독립 모듈 | CAT-17이 모듈이 아니라 인프라 의존성 | 레이어 오류 |

### 해결 방향

1. **중복 병합**: Style Director + Style Generator → 하나의 STYLE 모듈 (CAT-7)
2. **인프라 분리**: Google Sheets, 외부 API, FFmpeg는 모듈이 아닌 **인프라 레이어**로 격리
3. **과분해 흡수**: Thumbnail → MEDIA GENERATION (CAT-9) 하위로 흡수
4. **동시 실행 가능 모듈 통합**: Structure + Vision → CAT-4 통합 (항상 동시 실행)
5. **책임 분리**: Scheduling과 Pipeline Routing 분리
6. **번호 재정렬**: 0부터 단일 체계로 통일 (INFRA 3개 + CAT 14개)

---

## 확정 모듈 목록 (INFRA 3 + CAT 14)

```
INFRA-A: Google Sheets 제어 계층
INFRA-B: 외부 API 레지스트리
INFRA-C: FFmpeg 런타임

CAT-0:  CHANNEL ROUTER              (최상위 분기)
CAT-1:  MULTI-SOURCE INPUT          (원시 데이터 수집)
CAT-2:  SCORING ENGINE              (YouTube V3 전용)
CAT-3:  LIBRARY_RESULT              (단일 정본, SSOT)
CAT-4:  STRUCTURE & VISION          (아웃라인 + 시각 추출)
CAT-5:  WRITING CORE                (N-Step 스크립트)
CAT-6:  CHARACTER RESOLVER          (캐릭터/음성 할당)
CAT-7:  STYLE DIRECTOR              (시각 스타일 + 프롬프트)
CAT-8:  PROMPT ASSEMBLY             (최종 프롬프트 조립)
CAT-9:  MEDIA GENERATION            (이미지/음성/썸네일)
CAT-10: SCENE ORCHESTRATOR          (장면 제어)
CAT-11: VIDEO ASSEMBLY              (최종 합성)
CAT-12: SCHEDULING & DISTRIBUTION   (배포)
CAT-13: VERIFICATION & QUALITY GATE (검증)
```

---

## INFRA: 인프라 레이어 (모듈이 아님)

> 모든 CAT가 공유하는 기반 서비스. 독립 설계 대상 아님, 인터페이스 규약만 정의.

### INFRA-A: Google Sheets 제어 계층

```
역할: 설정 저장소 + 수동 제어판

사용처:
  - 스코어링 로직 가중치/필터 (CAT-2)
  - 채널별 스타일 프롬프트 (CAT-7)
  - 외부 이미지 매핑 테이블 (CAT-9)
  - 캐릭터 slot map (CAT-6)
  - 라우팅 규칙 (동적 브랜칭 없음, 시트 제어)

규칙:
  - 읽기: 모든 CAT 허용
  - 쓰기: LIBRARY_RESULT(CAT-3)만 프로그래밍 방식 쓰기
  - 나머지 탭은 사용자 수동 편집 전용
  - 탭 이름 = 모듈 이름 prefix 권장 (예: CAT2_scoring, CAT7_style)

인터페이스:
  sheets_read(tab_name, range) → data[]
  sheets_write(tab_name, range, data) → void  # CAT-3 전용
  sheets_get_config(tab_name) → config_object
```

### INFRA-B: 외부 API 레지스트리

```
역할: 외부 서비스 연결 관리 (단일 진입점)

목록:
  - Google Drive API
  - Google Sheets API
  - YouTube Data API V3
  - NotebookLM API
  - Gemini API
  - Perplexity API
  - OpenAI API (대체용)
  - Z-Image API (오픈소스 이미지 생성)
  - VibeVoice API (감정 TTS)
  - Index TTS API (일반 내레이션)
  - GenSpark / YG (이미지 생성 안정성 테스트 대상)

규칙:
  ❌ 각 CAT가 API를 직접 호출 금지
  ✅ INFRA-B 어댑터를 통해서만 접근
  ✅ API 장애 시 대체 경로 명시 필수
  ✅ API key 관리는 .env 기반 (하드코딩 금지)
  ✅ Rate limit 핸들링 + Retry 로직 내장

인터페이스:
  api_call(service_name, endpoint, params) → response
  api_health(service_name) → status
```

### INFRA-C: FFmpeg 런타임

```
역할: 미디어 처리 엔진 (공유 런타임)

사용처:
  - Scene detect + Keyframe extraction (CAT-4)
  - 슬라이드쇼 → 영상 변환 (CAT-11)
  - 클립 병합, 자막 삽입, 배경음악 (CAT-11)

규칙:
  ✅ 버전/설치 의존성은 이 레이어에서 단일 관리
  ✅ CAT-4, CAT-11은 INFRA-C 래퍼를 통해서만 FFmpeg 호출

인터페이스:
  ffmpeg_run(command_args[]) → output_file
  ffmpeg_probe(input_file) → metadata
```

---

## CAT-0: CHANNEL ROUTER (최상위 분기 레이어)

```
책임: 채널 식별 + 전체 파이프라인 설정 주입
의존: 없음 (최상위)
소비자: 모든 하위 CAT

입력:
  - channel_id (사용자 선택 또는 자동 감지)

출력:
  - channel_config 객체 (불변)
    ├─ character_set_id  → CAT-6 전달
    ├─ style_prompt_id   → CAT-7 전달
    ├─ scoring_weights   → CAT-2 전달
    ├─ category_rules    → CAT-2 전달 (주식 ≠ 암호화폐 등)
    ├─ output_sheet_tab  → INFRA-A 탭 지정
    └─ distribution_target → CAT-12 전달

인터페이스:
  get_channel_config(channel_id) → ChannelConfig  # 불변 객체
  list_channels() → [channel_id, ...]

규칙:
  ❌ channel_config는 파이프라인 실행 중 변경 불가
  ❌ 채널 간 데이터 공유 금지
  ✅ channel_config는 불변(immutable) 객체로 전달
```

---

## CAT-1: MULTI-SOURCE INPUT (원시 데이터 수집)

```
책임: 원시 데이터 수집 + 정규화
의존: CAT-0 (channel_config)
소비자: CAT-2, CAT-3

하위 모듈:
  1-A. YouTube V3 수집기
       입력: 키워드 / 플레이리스트 URL
       처리: 검색 → ~50개 결과 / 자막 추출 / 23개 카테고리 분류
       출력: raw_video_list[]

  1-B. URL / PDF / 텍스트 입력
       입력: 수동 URL, PDF 파일, 텍스트
       처리: 파싱 + 정규화
       출력: raw_document_list[]

  1-C. Instagram 크롤러
       입력: Instagram URL
       처리: placeholder → 실제 URL 크롤링
       출력: raw_instagram_list[]
       상태: placeholder (미구현)

  1-D. Research API 보강
       입력: raw_*_list에서 보강 필요 항목
       처리: NotebookLM / Gemini / Perplexity 호출 (INFRA-B 경유)
       출력: enriched_content[]

  1-E. Source Merger + Text Normalizer
       입력: 위 모든 raw/enriched 데이터
       처리: 통합 정규화 + Hook/Title/Thumbnail 자동 추출
       출력: normalized_content[] → CAT-3(LIBRARY_RESULT)에 기록

인터페이스 계약:
  ✅ 출력은 반드시 CAT-3(LIBRARY_RESULT) 경유
  ❌ 직접 다른 CAT로 전달 금지
  ✅ 채널별 카테고리 분류 규칙은 CAT-0에서 주입
```

---

## CAT-2: SCORING ENGINE (YouTube V3 전용)

```
책임: 수집된 데이터 평가 + Top-N 선정
의존: CAT-1 (수집 결과), CAT-0 (scoring_weights)
소비자: CAT-3

하위 모듈:
  2-A. 21개 로직 컴포넌트
       위치: Google Sheets 내 존재 (기존 ~80% 작동)
       구조: 그룹화된 하위 카테고리
       포함: z-VPH, Red Ocean Multiplier, Usability Flag 등

  2-B. 스코어 결합기
       입력: 로직별 개별 점수
       처리: 가중치 적용 + 결합
       설정: 가중치/정렬/필터 (INFRA-A에서 로드)

  2-C. Top-N 선택기
       입력: 결합 점수 리스트
       처리: 상위 N개 선정
       출력: selected_content_ids[] → CAT-3 상태 업데이트
       트리거: 선정된 항목에 대해 자막 추출 시작

  2-D. 제어 옵션 패널
       위치: Google Sheets
       기능: 로직 선택 토글 / 가중치 슬라이더 / 정렬·필터 설정
       접근: 사용자 수동 편집 전용

인터페이스 계약:
  ✅ 출력 = selected_content_ids[] → CAT-3 상태 업데이트
  ❌ YouTube V3 외 소스에는 적용하지 않음
  ✅ 비-YouTube 소스는 CAT-1에서 직접 CAT-3에 기록 (스코어링 건너뜀)
```

---

## CAT-3: LIBRARY_RESULT (단일 정본, System of Record)

```
책임: 모든 파이프라인의 SSOT (Single Source of Truth)
의존: CAT-1, CAT-2 (쓰기)
소비자: CAT-4 ~ CAT-12 (읽기)

구조 (필드):

  식별자:
    - content_id        (고유 콘텐츠 ID)
    - library_id        (라이브러리 내 위치)
    - channel_id        (채널 분기 키)
    - character_id      (할당된 캐릭터)

  상태 머신:
    COLLECTED → SCORED → SELECTED → OUTLINED → SCRIPTED
    → STYLED → PROMPTED → GENERATED → ASSEMBLED → RENDERED → DISTRIBUTED

  데이터 필드 (각 CAT의 출력 매핑):
    - outline_*         (CAT-4 출력)
    - vision_*          (CAT-4 출력)
    - hook_*            (CAT-5 출력)
    - final_*           (CAT-5 출력)
    - character_*       (CAT-6 출력)
    - style_*           (CAT-7 출력)
    - prompt_*          (CAT-8 출력)
    - media_*           (CAT-9 출력)
    - scene_*           (CAT-10 출력)
    - video_*           (CAT-11 출력)

규칙:
  ❌ 외부 URL 재조회 금지 (캐시된 데이터만 사용)
  ❌ 다른 탭/모듈에서 직접 수정 금지
  ✅ 각 CAT의 정해진 출력 필드에만 쓰기 허용
  ✅ 상태 전이는 순방향만 가능 (역행 불가)

인터페이스:
  read(content_id, fields[]) → Record
  write(content_id, field, value) → void       # 상태 머신 검증 포함
  list_by_status(status) → content_id[]
  lock_field(content_id, field) → void          # LOCK 이후 write 거부
  get_status(content_id) → status_enum
  transition(content_id, new_status) → void     # 순방향만 허용
```

---

## CAT-4: STRUCTURE & VISION (아웃라인 + 시각 추출)

```
책임: 콘텐츠 뼈대 설계 + 소스 영상에서 시각 자산 추출
의존: CAT-3 (LIBRARY_RESULT)
소비자: CAT-5, CAT-8

하위 모듈:
  4-A. n_steps 결정기
       입력: content 길이/복잡도
       처리: Section_1 ~ Section_N 분할 결정
       출력: n_steps 값

  4-B. 스토리 뼈대 생성기
       입력: content + n_steps
       처리: 구조만 생성 (전체 스크립트 아님)
       출력: outline_structure
       LOCK: outline_structure 확정 후 변경 불가

  4-C. FFmpeg Scene Detect
       입력: 소스 영상 참조 (CAT-3)
       처리: 장면 전환 감지 (INFRA-C 경유)
       출력: scene_boundaries[]

  4-D. Keyframe Extraction
       입력: scene_boundaries[]
       처리: 대표 프레임 추출 (INFRA-C 경유)
       출력: vision_prompt_raw
       규칙: READ-ONLY — 생성 아님, 추출만

인터페이스 계약:
  LOCK POINT #1: outline_structure
  ❌ LOCK 이후 구조 변경 시 전체 파이프라인 재실행 필요
  ✅ vision_prompt_raw는 참조용 (생성 지시가 아님)
  ✅ 4-A/4-B와 4-C/4-D는 병렬 실행 가능 (서로 의존 없음)
```

---

## CAT-5: WRITING CORE (N-Step Script)

```
책임: 실제 스크립트 텍스트 생성
의존: CAT-4 (outline_structure), CAT-3 (LIBRARY_RESULT)
소비자: CAT-6, CAT-8

하위 모듈:
  5-A. Outline → 실제 글 Outline 생성
       입력: outline_structure (CAT-4)
       출력: writing_outline

  5-B. Hook Draft
       입력: writing_outline + content 데이터
       출력: hook_draft

  5-C. Final Hook / Title 확정
       입력: hook_draft
       출력: final_hook, final_title

  5-D. Step-by-Step 스크립트 생성
       입력: writing_outline + 각 Step별 개별 프롬프트
       출력: step_scripts[]

  5-E. Final Merge
       입력: step_scripts[] + final_hook
       출력: final_merged_text
       LOCK: 수정 불가

  5-F. Translation Side-Car (선택)
       입력: final_merged_text
       출력: translated_texts{lang → text}

  5-G. Variant Row Generator (선택)
       입력: final_merged_text
       출력: variant_rows[] (변형 버전, A/B 테스트용)

인터페이스 계약:
  LOCK POINT #2: final_merged_text
  ✅ 프롬프트 입력 위치 = 각 Step별 개별 프롬프트 (5-D)
  ❌ LOCK 이후 텍스트 수정 시 CAT-8 이후 전체 재실행 필요
```

---

## CAT-6: CHARACTER RESOLVER

```
책임: 장면별 캐릭터/음성 고정 할당
의존: CAT-0 (character_set_id), CAT-5 (스크립트)
소비자: CAT-8

하위 모듈:
  6-A. Slot Map (미리 정의)
       위치: Google Sheets (INFRA-A)
       구조: channel_id → character_set 매핑
       예시:
         금융 채널 → {narrator: 곰아빠, expert: 곰엄마, guest: 곰아들}
         건강 채널 → {narrator: 토끼아빠, expert: 토끼엄마, guest: 토끼딸}

  6-B. Scene별 character_id 할당
       입력: 스크립트 scene 목록 + slot_map
       처리: 규칙 기반 매칭 (AI 추론 없음)
       출력: scene_character_map{scene_id → character_id}

  6-C. Scene별 voice_id 할당
       입력: scene_character_map{}
       처리: character_id → voice_id 룩업 (고정 테이블)
       출력: scene_voice_map{scene_id → voice_id}

인터페이스 계약:
  ❌ 자동 추론 금지 — slot map 기반 명시적 할당만
  ❌ 런타임에 캐릭터 동적 생성 금지
  ✅ character_set은 CAT-0에서 주입 (파이프라인 중 변경 불가)
  ✅ 모든 캐릭터는 사전 등록 필수
  ✅ 출력: {scene_id → (character_id, voice_id)} 매핑
```

---

## CAT-7: STYLE DIRECTOR (시각적 일관성)

```
책임: 시각적 일관성 보장 + 채널별 스타일 프롬프트 관리
의존: CAT-0 (style_prompt_id)
소비자: CAT-8

※ 기존 CAT-8(Cinematic Style Director) + CAT-9(Style Generator) 병합

하위 모듈:
  7-A. Style Profile 정의
       포함 요소:
         - 분위기 (mood)
         - 카메라 동작 (camera behavior)
         - 조명 (lighting)
         - B-roll 비율
         - 색감 / 컬러 그레이딩
         - 비주얼 스타일
         - 샷 구성

  7-B. 채널별 고정 스타일 프롬프트
       위치: Google Sheets (INFRA-A)
       동작: 이미지/영상 프롬프트 앞에 자동 삽입
       규칙: AI 자동 생성 아님 — 사전 정의된 텍스트 프롬프트

  7-C. Reference Image 시스템 (선택)
       입력: 5장 내외 레퍼런스 이미지
       처리: 스타일 고정용 (Midjourney 방식 일관성)
       출력: reference_anchors[]

인터페이스 계약:
  ❌ 스타일을 "생성"하지 않음 — "규칙을 주입"만 한다
  ❌ AI가 스타일 자동 결정 금지
  ✅ 모든 스타일은 시트에 사전 정의
  ✅ 출력: style_prompt_text + reference_anchors (선택)
  ✅ CAT-8(Prompt Assembly)에서 소비
```

---

## CAT-8: PROMPT ASSEMBLY (최종 프롬프트 조립)

```
책임: TEXT / IMAGE / VIDEO 최종 프롬프트 조립
의존: CAT-5 (스크립트), CAT-6 (캐릭터), CAT-7 (스타일), CAT-4 (vision)
소비자: CAT-9

하위 모듈:
  8-A. 프롬프트 템플릿 엔진
       입력: [스타일 프롬프트] + [장면 설명] + [캐릭터 지시] + [vision 참조]
       처리: 템플릿 기반 조합 (TEXT/IMAGE/VIDEO 타입별 분기)
       출력: assembled_prompts[]

  8-B. Hash 생성기
       입력: assembled_prompts[]
       처리: 프롬프트 텍스트 → SHA256 hashId 생성
       출력: prompt_hash_map{scene_id → hashId}
       목적: 재현성 보장 (동일 프롬프트 → 동일 해시)

  8-C. Hash 검증 게이트키퍼
       입력: prompt_hash_map{}
       처리: 생성 직전 프롬프트 재해싱 → 저장된 hashId와 비교
       출력: PASS / FAIL
       FAIL 시 → 프로세스 즉시 중단 (무시 불가)

인터페이스 계약:
  LOCK POINT #3: hashId
  ❌ 동적 브랜칭 없음 — 모든 라우팅은 시트 제어
  ❌ 프롬프트 자동 수정 금지 (수동 수정 → 재해싱 필요)
  ❌ hashId 불일치 = 파이프라인 실패
```

---

## CAT-9: MEDIA GENERATION (이미지/음성/썸네일 생성)

```
책임: 이미지 + 음성 + 썸네일 생성
의존: CAT-8 (조립된 프롬프트), CAT-5 (final_merged_text), CAT-6 (scene_voice_map)
소비자: CAT-10

※ 기존 Image(CAT-10) + Audio(CAT-13) + Thumbnail(CAT-18) 병합
※ 하위 모듈 9-A/9-B/9-C는 내부 병렬 실행 가능 (서로 의존 없음)

하위 모듈:
  9-A. Image Generation
       도구: Z-Image (오픈소스) — scene 단위
       입력: assembled_prompts[] (이미지용)
       처리:
         - scene별 이미지 생성
         - 스크립트 문장별 이미지 생성
         - 레퍼런스 이미지 삽입 가능
       출력: generated_images{scene_id → image_url}
       보조: 외부 이미지 벌크 업로드 (Chrome Extension)
             └ scene_id + image_sequence + image_url
       기능: 개별 이미지 수정 / 범위 수정 (예: 2~10번 교체)
       상태: 퀄리티 이슈 존재 — 파이프라인 안정화 후 개선

  9-B. Audio Generation
       도구:
         - VibeVoice (INFRA-B 경유) — 감정 표현 구간
         - Index TTS (INFRA-B 경유) — 일반 내레이션 (감정 강도 낮음)
       입력: final_merged_text + scene_voice_map{scene_id → voice_id}
       처리: scene 메타데이터 기반 VibeVoice vs Index TTS 자동 라우팅
       출력: audio_files{scene_id → audio_url}

  9-C. Thumbnail Generation
       입력: final_hook + final_title
       처리: Hook/Title 기반 자동 생성
       출력: thumbnail_url
       저장: 전용 썸네일 탭 (INFRA-A)
       우선순위: 후순위 (핵심 파이프라인 안정화 이후)

인터페이스 계약:
  ✅ 생성 결과 = scene_id 기준 저장
  ✅ 9-A, 9-B, 9-C 병렬 실행 가능 (내부 독립)
  ✅ 이미지 퀄리티 이슈 → 후순위 개선
```

---

## CAT-10: SCENE ORCHESTRATOR (장면 제어)

```
책임: 장면별 시각 소스 라우팅 + 클립 준비
의존: CAT-9 (생성된 미디어)
소비자: CAT-11

하위 모듈:
  10-A. Scene Mode 선택기
        모드: AI / SLIDE / MIXED (scene_id 단위)
        입력: scene 설정 (INFRA-A)
        출력: scene_mode_map{scene_id → mode}

  10-B. Scene Duration 제어
        입력: scene별 설정
        처리: 각 scene N초 할당
        출력: scene_duration_map{scene_id → seconds}

  10-C. 외부 이미지 → Scene 매핑
        입력: 업로드된 외부 이미지 목록
        처리: scene_id 기준 그룹화 + sequence order 정렬
        구조: scene_id | image_sequence | image_url

  10-D. 부분 장면 재생성
        입력: 특정 scene_id + 수정 요청
        처리: 해당 scene만 CAT-9로 재생성 요청
        출력: 업데이트된 scene 클립

인터페이스 계약:
  ❌ 기존 워크플로(R47 Image Gen, R40 Audio Engine, R48 Video Assembly) 수정 금지
  ✅ 라우팅 + 클립 준비만 담당
  ✅ R48(Video Assembly) 전송 전 scene 단위 영상 클립 준비
```

---

## CAT-11: VIDEO ASSEMBLY (최종 합성)

```
책임: 최종 영상 합성
의존: CAT-10 (준비된 클립), CAT-9 (오디오)
소비자: CAT-12

하위 모듈:
  11-A. FFmpeg 슬라이드쇼 → 영상 클립 변환
        입력: SLIDE 모드 이미지 시퀀스
        처리: 이미지 → 영상 클립 (INFRA-C 경유)
        출력: video_clips[]

  11-B. 클립 병합
        입력: 모든 scene 클립 (AI + SLIDE + MIXED)
        처리: 순서대로 병합 (INFRA-C 경유)
        출력: merged_video

  11-C. 자막 삽입
        입력: merged_video + final_merged_text + 타이밍 정보
        처리: 자막 오버레이 (INFRA-C 경유)
        출력: subtitled_video

  11-D. 배경 음악 삽입
        입력: subtitled_video + BGM 파일
        처리: 배경 음악 믹싱 (INFRA-C 경유)
        출력: mixed_video

  11-E. 최종 렌더링
        입력: mixed_video
        처리: 최종 인코딩 (해상도, 코덱, 비트레이트)
        출력: final_video_url

인터페이스 계약:
  ✅ scene_id가 마스터 단위
  ✅ scene_id → 스크립트 + 오디오 + 자막 + 비주얼 자동 연결
  ✅ 렌더링 실패 시 해당 scene_id 로그 기록
  ❌ 콘텐츠 수정 금지 (그건 CAT-5/CAT-9)
```

---

## CAT-12: SCHEDULING & DISTRIBUTION (배포)

```
책임: 생성된 콘텐츠 스케줄링 + 채널별 배포
의존: CAT-11 (최종 영상), CAT-9 (썸네일)
소비자: 없음 (최종 출력)

하위 모듈:
  12-A. 스케줄러
        입력: final_video_url + 배포 일정
        처리: 예약 게시 관리 + 큐

  12-B. 채널별 배포 라우팅
        입력: channel_config (CAT-0)
        처리:
          - channel_id 기준 플랫폼 선택
          - 메타데이터(제목, 설명, 태그) 첨부
          - 썸네일 첨부
        출력: distribution_result

인터페이스 계약:
  ✅ channel_id 기준 독립 배포
  ✅ 배포 실패 시 재시도 로직 포함
  ❌ 콘텐츠 수정/재생성 금지
```

---

## CAT-13: VERIFICATION & QUALITY GATE (검증)

```
책임: 파이프라인 전체 품질 검증
의존: 모든 CAT (검증 대상)
소비자: 운영자 (사람)

하위 모듈:
  13-A. hashId 무결성 검증
        대상: CAT-8 → CAT-9 전달 시점
        방법: 프롬프트 재해싱 → 저장된 hashId 비교
        결과: PASS / FAIL

  13-B. 배치 테스트
        대상: GenSpark 100회 배치
        방법: 오류 영상/스크린샷/로그 수집
        결과: 품질 리포트

  13-C. Contract Test
        대상: 모듈 간 인터페이스
        방법: 입출력 스키마 검증
        결과: 인터페이스 호환성 리포트

  13-D. Staging 검증
        대상: 최종 영상
        방법: 실제 재생 + 자막/오디오 동기화 확인 + 수동 체크리스트
        결과: QA 리포트

인터페이스 계약:
  ✅ 검증만 — 수정 권한 없음
  ✅ FAIL 시 해당 CAT에 재처리 요청
  ❌ 검증 결과 무시 불가
```

---

## 모듈 간 의존성 흐름

```
INFRA-A (Sheets) ←── 횡단 ──→ 모든 CAT (설정 읽기)
INFRA-B (API)    ←── 횡단 ──→ CAT-1, CAT-9 (외부 서비스)
INFRA-C (FFmpeg) ←── 횡단 ──→ CAT-4, CAT-11 (미디어 처리)

CAT-0 (Channel Router) ─── channel_config ──────────────────────────┐
    │                                                                │
CAT-1 (Input) ──→ CAT-2 (Scoring) ──→ CAT-3 (LIBRARY_RESULT)      │
                                          │                          │
                                     CAT-4 (Structure + Vision)      │
                                          │                          │
                                     CAT-5 (Writing Core)            │
                                          │                          │
                                     CAT-6 (Character) ◄────────────┤
                                          │                          │
                                     CAT-7 (Style) ◄────────────────┘
                                          │
                                     CAT-8 (Prompt Assembly)
                                          │
                                     CAT-9 (Media Generation)
                                          ├─ 9-A Image  ┐
                                          ├─ 9-B Audio  ├ 내부 병렬
                                          └─ 9-C Thumb  ┘
                                          │
                                     CAT-10 (Scene Orchestrator)
                                          │
                                     CAT-11 (Video Assembly)
                                          │
                                     CAT-12 (Distribution)

CAT-13 (Verification) ◄────── 전 구간 검증 ─────────────────────────┘
```

---

## LOCK 포인트 요약

| # | LOCK 대상 | 생성 모듈 | LOCK 이후 효과 |
|---|-----------|-----------|----------------|
| 1 | `outline_structure` | CAT-4 | 구조 변경 불가. 변경 시 전체 파이프라인 재실행 |
| 2 | `final_merged_text` | CAT-5 | 스크립트 수정 불가. 변경 시 CAT-8 이후 재실행 |
| 3 | `hashId` | CAT-8 | 프롬프트 변경 불가. 불일치 시 생성 차단 |

---

## 마스터 키 정의

| 키 | 역할 | 생성 시점 | 범위 |
|----|------|-----------|------|
| `channel_id` | 최상위 분기 | CAT-0 | 채널 간 데이터/설정 절대 격리 |
| `content_id` | 콘텐츠 추적 | CAT-1 | LIBRARY_RESULT 내 유일 식별자 |
| `scene_id` | 장면 단위 자산 연결 | CAT-4 | 스크립트 + 오디오 + 이미지 + 자막 |
| `character_id` | 캐릭터 고정 | CAT-6 | 채널 내 slot map 기반 |
| `voice_id` | 음성 고정 | CAT-6 | character_id → voice_id 매핑 |
| `hashId` | 프롬프트 무결성 | CAT-8 | 재현성 + 변조 방지 |

---

## 모듈별 키 매핑

| CAT | 입력 키 | 출력 키 | LOCK |
|-----|---------|---------|------|
| 0 | — | channel_config | — |
| 1 | channel_id | content_id | — |
| 2 | content_id | selected_content_ids | — |
| 3 | content_id | * (SSOT) | — |
| 4 | content_id | outline_structure, vision_prompt_raw | outline_structure |
| 5 | content_id, outline_structure | final_merged_text | final_merged_text |
| 6 | channel_id, scene_id | (character_id, voice_id) | — |
| 7 | channel_id | style_prompt_text | — |
| 8 | scene_id | assembled_prompts, hashId | hashId |
| 9 | scene_id, hashId | image/audio/thumbnail URLs | — |
| 10 | scene_id | scene_clips | — |
| 11 | scene_id | final_video_url | — |
| 12 | channel_id | distribution_result | — |
| 13 | * | verification_report | — |

---

## 충돌 방지 핵심 규칙

| 규칙 | 설명 |
|------|------|
| `scene_id` = 마스터 키 | 모든 자산(스크립트, 오디오, 이미지, 자막)은 scene_id로만 연결 |
| `channel_id` = 분기 키 | 채널 간 데이터/설정 절대 공유 안 함 |
| `content_id` = 콘텐츠 키 | LIBRARY_RESULT 내 콘텐츠 식별 |
| LIBRARY_RESULT = SSOT | 모든 읽기/쓰기의 단일 진입점 |
| LOCK 3개 | outline_structure, final_merged_text, hashId — LOCK 이후 수정 불가 |
| 기존 워크플로 불변 | R47, R40, R48 수정 금지 — 새 레이어만 추가 |
| 명시적 할당만 | 캐릭터/이미지 매핑에 AI 자동 추론 금지 |
| 인프라 ≠ 모듈 | Google Sheets, 외부 API, FFmpeg는 인프라 레이어 (독립 설계 대상 아님) |
| 단방향 의존 | CAT-N은 CAT-(N+k)만 소비 (역방향 금지, CAT-3 SSOT 예외) |
| 병렬 가능 표시 | CAT-9 내부 (9-A/9-B/9-C), CAT-4 내부 (4-A~B와 4-C~D) |

---

## 설계 우선순위 (권장 순서)

```
Phase 1 — 기반 (CAT-0, CAT-3, INFRA-A/B/C)
  채널 라우터 + LIBRARY_RESULT 스키마 + 인프라 인터페이스
  → 나머지 모든 모듈의 기반

Phase 2 — 입력+스코어링 (CAT-1, CAT-2)
  데이터 수집 + 평가 파이프라인
  → 기존 21개 로직 연결 (~80% 작동 중)

Phase 3 — 콘텐츠 생성 (CAT-4, CAT-5, CAT-6, CAT-7)
  구조 설계 + 스크립트 작성 + 캐릭터/스타일 할당
  → 텍스트 파이프라인 완성

Phase 4 — 미디어 생성 (CAT-8, CAT-9, CAT-10)
  프롬프트 조립 + 이미지/음성 생성 + 장면 제어
  → 이미지 퀄리티는 이 단계에서 반복 개선

Phase 5 — 합성+배포 (CAT-11, CAT-12)
  최종 영상 렌더링 + 스케줄링
  → 기존 R47/R40/R48 워크플로 연결

Phase 6 — 검증 (CAT-13)
  전 구간 품질 게이트
  → 파이프라인 안정화 후 도입
```

---

## 이전 문서와의 관계

| 문서 | 상태 |
|------|------|
| `SYSTEM-MODULE-MAP.md` | 이 문서의 기반 구조 (14모듈, 6Phase). **보관용** |
| `SYSTEM_MODULE_DECOMPOSITION.md` | 인터페이스/키/상태 머신 보강 출처. **보관용** |
| `SYSTEM-MODULE-MAP-FINAL.md` | **정본 (SSOT)** — 두 문서 취합 최종본 |

---

*최종 업데이트: 2026-04-12*  
*구조: INFRA 3 + CAT 14 (CAT-0 ~ CAT-13)*
