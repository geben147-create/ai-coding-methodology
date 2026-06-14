# 원본 추적 기록

## 추적 방법

1. 기사나 검색 결과에서 직접 TikTok 게시물 링크를 추출했다.
2. 게시물 URL을 `yt-dlp`로 다시 열어 게시자, 날짜, 길이, 조회수, 좋아요,
   댓글, 공유 수치를 확인했다.
3. 워터마크 계정명과 URL 계정명이 일치하는지 접촉 시트로 확인했다.
4. 동일 문구와 계정명으로 YouTube 검색 결과 상위 5개를 대조했다.

## 선정 소스

| ID | 원본 | 최초 게시 근거 | 보조 근거 | 판정 |
|---|---|---|---|---|
| C01 | https://www.tiktok.com/@mariamsilver/video/7582341708541709598 | TikTok URL, @mariamsilver 워터마크, 원본 음원 메타데이터 | `evidence/metadata/unexpected_reaction_tiktok_meta.ndjson` | likely-original |
| C06 | https://www.tiktok.com/@liviwalker/video/7446418529995312415 | TikTok URL, @liviwalker 워터마크, 원본 음원 메타데이터 | `evidence/contact_sheets/7446418529995312415.jpg` | likely-original |
| C09 | https://www.tiktok.com/@shelbywold/video/7585689673687698701 | TikTok URL, @shelbywold 워터마크, 원본 음원 메타데이터 | `evidence/contact_sheets/7585689673687698701.jpg` | likely-original |
| C02 | https://www.tiktok.com/@keely1123/video/7452398830911229227 | TikTok URL, @keely1123 워터마크 | https://people.com/woman-secretly-films-fiance-insulting-her-to-see-his-moms-reaction-exclusive-8769088 | likely-original |
| C13 | https://www.tiktok.com/@phoebeadams112/video/7551907106681539853 | TikTok URL, @phoebeadams112 워터마크 | https://people.com/woman-pranks-boyfriend-with-rock-from-anthropologie-exclusive-11816222 | likely-original |
| C10 | https://www.tiktok.com/@quianacreates/video/7553290452938640670 | TikTok URL, @quianacreates 워터마크, 원본 음원 메타데이터 | `evidence/contact_sheets/7553290452938640670.jpg` | likely-original |
| C07 | https://www.tiktok.com/@kaylee.marina/video/7451355930031033646 | TikTok URL, @kaylee.marina 워터마크 | https://people.com/family-pranks-grandma-but-all-the-items-they-borrowed-from-their-grandma-exclusive-8766713 | likely-original |

`likely-original`은 최초 게시 가능성이 높다는 뜻이며 재사용 라이선스를 뜻하지
않는다. 일곱 소스 모두 공개 업로드 전 별도 허가가 필요하다.
