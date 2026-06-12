# Plan

- [✅] Analyze at least ten Shorts from the channel represented by the two
      approved reference URLs, then create and validate one reusable
      multilingual viral-short benchmarking skill with original example
      scripts.

## Allowed Files

- `tech_spec.md`
- `plan.md`
- `LessonsLearned.md`
- `video_project/**`

## Handoff Notes

Current task approved by the user on 2026-06-12.

Required reference Shorts:

- `https://youtube.com/shorts/2gyj5Koh7k8`
- `https://youtube.com/shorts/bnN_4w8grco`

Do not publish or reuse third-party footage without documented permission or a
compatible license. Public videos may be inspected for research and structural
benchmarking only.

Completed on 2026-06-12:

- Analyzed twelve Shorts from `윌리랭킹`: the ten highest-view samples in the
  collected channel set plus two recent controls, including both required URLs.
- Collected public metadata, available original-language automatic captions,
  and public storyboard frames without saving third-party source videos.
- Built timestamped evidence packets and contact sheets under
  `video_project/viral_shorts_benchmark/research/packets/`.
- Created `video_project/skills/benchmark-ranking-shorts/` with detailed
  channel findings, Japanese localization rules, rights-safe source selection,
  a reusable research-packet script, and complete Japanese/Korean/English
  example scripts.
- Passed the packet-builder test, Python compilation, twelve-packet rebuild,
  and the official skill validator in UTF-8 mode.
- Exact added sound-effect counts remain unverified because silent public
  storyboards cannot establish audio events. The skill requires an audible
  playback pass on a rights-cleared source rather than inventing counts.

Next task:

- Completed the next production step with Pexels-licensed footage.
- Final output:
  `video_project/viral_shorts_benchmark/production/output/cute_animal_ranking_top3.mp4`
- The 33.5-second 1080x1920 TOP3 uses Korean TTS only and keeps each ranked
  item on screen for 9.5, 11, and 13 seconds.
- Validation passed for decoding, source rights, Japanese-kana exclusion, and
  non-overlapping TTS segments.
