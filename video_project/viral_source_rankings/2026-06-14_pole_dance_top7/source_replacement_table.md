# 기존 7개 소스 권리 교체표

확인일: 2026-06-14

기존 영상은 조회수가 높거나 원본 가능성이 높아도 재사용 허가가 확인되지 않았다. 새 버전은 바이럴 원본을 그대로 쓰지 않고, 개별 자산 페이지에서 상업적 이용이 명시된 Mixkit 스톡 영상으로 교체한다.

| 순서 | 기존 소스 (차단) | 교체 소스 (사용) | 교체 이유 |
|---|---|---|---|
| 1 | [Pilipinas Got Talent - Spiral Pole Dancing](https://www.youtube.com/watch?v=ZHhePoJhs8g) | [Woman doing a dance with a fire sword](https://mixkit.co/free-stock-video/woman-doing-a-dance-with-a-fire-sword-43666/) | 재사용 허가 불명확 → 상업적 사용이 명시된 강한 첫 장면 |
| 2 | [EXOTIC REVOLUTION X - Karina Kovaleva](https://www.youtube.com/watch?v=oawEi97c65w) | [Man and woman doing aerial aerobics](https://mixkit.co/free-stock-video/man-and-woman-doing-aerial-aerobics-949/) | 재사용 허가 불명확 → 공중 회전이 선명한 라이선스 영상 |
| 3 | [EXOTIC MOON 2023 - Kseniya Getman](https://www.youtube.com/watch?v=iU7vnUh2eaI) | [Couple performing on circus ropes](https://mixkit.co/free-stock-video/couple-performing-on-circus-ropes-952/) | 재사용 허가 불명확 → 에어리얼 실크 기술 장면 |
| 4 | [Australia's Got Talent - Pole Dancer](https://www.youtube.com/watch?v=wgsbpMrFjAE) | [Circus performers on ropes](https://mixkit.co/free-stock-video/circus-performers-on-ropes-951/) | 방송사 영상 재사용 권리 불명확 → 공중 퍼포먼스 라이선스 영상 |
| 5 | [Amanati x Anastasia Sokolova](https://www.youtube.com/watch?v=awcrkc_0cKo) | [Neon spotlight and a dancer](https://mixkit.co/free-stock-video/neon-spotlight-and-a-dancer-50432/) | 재사용 허가 불명확 → 아름다운 네온 바닥 안무 |
| 6 | [monnika_n TikTok](https://www.tiktok.com/@monnika_n/video/7630820577996967200) | [Silhouettes of two dancers during a performance](https://mixkit.co/free-stock-video/silhouettes-of-two-dancers-during-a-performance-41414/) | 공개 게시물은 재배포 허가가 아님 → 실루엣 퍼포먼스 라이선스 영상 |
| 7 | [stephbuntt TikTok](https://www.tiktok.com/@stephbuntt/video/7577612168657521938) | [Contemporary dance in an abandoned place](https://mixkit.co/free-stock-video/contemporary-dance-in-an-abandoned-place-43207/) | 공개 게시물은 재배포 허가가 아님 → 공간감 있는 라이선스 영상 |

## 공통 라이선스

- [Mixkit License](https://mixkit.co/license/#videoFree)
- 각 교체 자산 페이지에는 `commercial or personal use`와 `Mixkit Stock Video Free License`가 함께 표시된다.
- 개인용 전용인 `Mixkit Restricted License` 자산은 후보에서 제외했다.

## 오디오 교체

- 기존 외부 BGM 대신 FFmpeg의 사인파와 노이즈 소스로 56초 전자 펄스 BGM을 직접 생성한다.
- 내레이션은 [Qwen3-TTS 0.6B CustomVoice](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice)의 내장 `Sohee` 음성을 사용한다.
- 모델 라이선스: [Apache License 2.0](https://github.com/QwenLM/Qwen3-TTS/blob/main/LICENSE)
- 실제 인물의 목소리를 복제하지 않는다.
