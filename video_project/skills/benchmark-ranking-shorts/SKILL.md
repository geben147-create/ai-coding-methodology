---
name: benchmark-ranking-shorts
description: Analyze ten or more ranking-style Shorts from one channel, extract evidence-backed hook, caption, character, gesture, edit, audio, and performance patterns, then design original multilingual scripts and rights-safe source briefs. Use for YouTube Shorts, TikTok, Douyin, Xiaohongshu, Reels, OCR-led video study, Japanese localization, viral-format benchmarking, source scoring, or timestamped short-form production plans.
---

# Benchmark Ranking Shorts

Build an original short-form format from observable patterns without copying a
creator's script or reusing footage whose rights are unknown.

## Workflow

### 1. Define The Study

Set:

- Target channel and required reference URLs.
- At least ten videos, including the supplied references.
- A winner group and at least two recent or low-view controls.
- Analysis date, because views and comments change.
- Target language, runtime, topic, audience, and output format.

Do not label a newly uploaded control a failure. Compare publication dates,
view velocity, like rate, comment rate, and creative structure separately.

### 2. Apply The Rights Boundary

Treat public videos as research references only. Do not turn them into edit
sources unless the creator grants permission or a compatible license exists.

Accept production footage only when its status is `owned`,
`permission-granted`, `licensed`, `cc-by`, `cc-by-sa`, or `public-domain`.
Reject unknown rights, repost accounts, platform-only availability, and
watermark removal.

Read [source-selection-and-rights.md](references/source-selection-and-rights.md)
before finding footage.

### 3. Build Evidence Packets

Collect public metadata, automatic-caption timing, and platform-visible
storyboard frames. Do not save the source video when reuse rights are unknown.

Run:

```powershell
python scripts/build_research_packets.py `
  --metadata-dir path\to\metadata `
  --captions-dir path\to\captions `
  --storyboards-dir path\to\storyboards `
  --output-dir path\to\packets
```

Inspect every contact sheet with vision. Use OCR to distinguish:

- Persistent title banner.
- Rank labels and scoreboard.
- Source subtitles.
- Added dialogue translations.
- Editor reaction text.
- CTA text.

Mark every conclusion as `observed`, `metadata`, or `inference`.

### 4. Analyze Each Video

Record:

- Exact runtime, publication date, views, likes, comments, and rates.
- Hook in the first 0.0-2.0 seconds.
- Approximate rank boundaries and seconds per story.
- Setup, action, reaction, reveal, and tail.
- Face, gaze, posture, hand movement, body movement, and reaction intensity.
- Crop, zoom, camera movement, animation, effect, and transition cadence.
- Caption placement, color, line count, and change interval.
- Original dialogue coverage, music identity when publicly labeled, added
  sound effects, and voice characteristics.
- Why the footage is understandable without prior context.
- Plausible popularity drivers and alternative explanations.

Never invent an exact sound-effect count from silent frames. Label unverified
audio details and require an audible playback pass.

### 5. Extract The Format, Not The Expression

Generalize:

- Number of ranked stories.
- Duration distribution.
- Curiosity mechanism.
- Emotional progression.
- Caption hierarchy.
- Reaction timing.
- Audio density.
- Ending and CTA behavior.

Do not reproduce distinctive wording, jokes, captions, or story order.

The analyzed reference channel primarily uses source dialogue, music, and
Korean on-screen text rather than a consistent narrator. Preserve that
distinction when benchmarking it.

Read [willie-ranking-analysis.md](references/willie-ranking-analysis.md) for
the twelve-video study that produced this skill.

### 6. Localize Deliberately

Translate the function of each line, not its literal wording. Rebuild jokes and
reaction phrasing for the target culture while preserving observable facts.

For Japanese:

- Use a direct title plus `TOP3` or `TOP4`.
- Keep reaction cards short and conversational.
- Prefer text-led storytelling or light narration over constant exposition.
- Reserve the strongest emotional phrase for the final rank.
- Keep spoken Japanese around 170-220 characters for a 35-45 second
  narrator-light short.

Read [japanese-localization.md](references/japanese-localization.md) before
writing Japanese copy.

### 7. Select Complete Highlights

Default per-story duration:

- Setup: 0.7-1.5 seconds.
- Action: 2.0-6.0 seconds.
- Reaction: 1.0-3.0 seconds.
- Tail: 0.3-0.8 seconds.

Use 8-14 seconds for each item in a TOP3. Use 6-10 seconds for each item in a
TOP4. Give the final item 9-16 seconds when it carries the strongest payoff.

Reject a highlight that:

- Begins after the cause.
- Ends before the reaction.
- Requires an unsupported caption to make sense.
- Shows only impact without consequence.
- Is available only from a repost with unknown rights.

### 8. Write The Production Blueprint

Deliver:

- One-sentence concept and audience promise.
- Rights-cleared source manifest.
- Timestamped edit decision list.
- On-screen copy in each requested language.
- Optional narration script and voice direction.
- Music and sound-effect plan.
- Caption style and safe-area rules.
- Evidence versus inference section.
- Original example script.

Use hard cuts at complete beat boundaries. Add effects only when the raw action
already reads clearly. A normal 35-50 second ranking short usually needs
three to six added sound cues, not one on every caption.

## Output Schema

Use this order:

1. Scope and analysis date.
2. Dataset table.
3. Per-video timeline.
4. Cross-video pattern matrix.
5. Language adaptation.
6. Source brief and rights status.
7. Original script and shot list.
8. Verification gaps.

## Complete Original Example

Topic: `Small Acts Of Kindness In The City TOP3`

All footage must be owned, licensed, permission-granted, Creative Commons, or
public domain. The events below are original production concepts.

### Japanese, 40 Seconds

| Time | Visual | On-Screen Copy | Optional Narration | Audio |
|---|---|---|---|---|
| 0.0-1.8 | A stranger steps into heavy rain without an umbrella. | 思わず笑顔になる親切 TOP3 | 見ているだけで優しくなれる瞬間。 | Music starts; soft rise |
| 1.8-10.5 | Rank 3: a commuter silently shares an umbrella, then waves goodbye. | 第3位 / 何も言わずに、半分どうぞ | 雨の日に差し出された、傘の半分。 | Light pop at reveal |
| 10.5-22.5 | Rank 2: a bus driver notices a running passenger and waits; the passenger bows. | 第2位 / あと3秒だけ待った運転手さん | 急いでいる誰かのために、ほんの少し待つ。 | Door chime; keep bow reaction |
| 22.5-36.5 | Rank 1: a child picks up a dropped wallet, runs after its owner, and receives a relieved smile. | 第1位 / 落とした人より先に気づいた子 | 最後は、落とした財布を全力で届けたこの子。 | Warm impact; music lift |
| 36.5-40.0 | Owner and child wave to each other. | あなたなら、どの瞬間が一番好き？ | いちばん好きな瞬間を教えて。 | Music tail; no extra hit |

### Korean, 40 Seconds

| Time | On-Screen Copy | Optional Narration |
|---|---|---|
| 0.0-1.8 | 보고 있으면 마음이 따뜻해지는 친절 TOP3 | 보기만 해도 마음이 부드러워지는 순간입니다. |
| 1.8-10.5 | 3위 / 말없이 우산의 절반을 내어준 사람 | 비 오는 날, 낯선 사람에게 건넨 우산의 절반. |
| 10.5-22.5 | 2위 / 딱 3초 더 기다려 준 버스 기사님 | 누군가를 위해 아주 잠깐 기다리는 친절. |
| 22.5-36.5 | 1위 / 지갑 주인보다 먼저 뛰기 시작한 아이 | 마지막은 떨어진 지갑을 끝까지 쫓아가 돌려준 아이입니다. |
| 36.5-40.0 | 여러분은 몇 위가 가장 좋았나요? | 가장 마음에 남은 순간을 댓글로 알려 주세요. |

### English, 40 Seconds

| Time | On-Screen Copy | Optional Narration |
|---|---|---|
| 0.0-1.8 | Small Acts Of Kindness TOP3 | Three tiny moments that made a city feel warmer. |
| 1.8-10.5 | #3 / Half an umbrella, no questions asked | A stranger quietly made room under one umbrella. |
| 10.5-22.5 | #2 / The driver who waited three more seconds | Sometimes kindness is simply choosing not to leave yet. |
| 22.5-36.5 | #1 / The child who chased down a lost wallet | This child ran after the owner before anyone else noticed. |
| 36.5-40.0 | Which moment stayed with you? | Tell us which one you would put at number one. |
