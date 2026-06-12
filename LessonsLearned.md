# Lessons Learned

- The workstation has FFmpeg and an RTX 4070 Laptop GPU, but the detected VRAM
  is insufficient for the available large local video models.
- The existing video toolkit has Qwen3-TTS configured through Modal, while its
  LTX video-generation endpoint is not configured.
- For this proof of concept, generated keyframes plus FFmpeg motion are the most
  reliable available production path.
- `System.Speech` can enumerate `Microsoft Heami Desktop` but cannot activate
  it on this workstation. The already-installed `edge-tts` package with
  `ko-KR-HyunsuMultilingualNeural` produces reliable Korean narration without
  adding a dependency.
- Several downloaded YouTube source files contain video only. Generate
  duration-matched silent WAV tracks before concatenating mixed audio.
- Windows PowerShell 5.1 does not support `Set-Content -Encoding utf8NoBOM`.
  Use `System.Text.UTF8Encoding($false)` for FFmpeg concat manifests.
- A long `winget install` command can time out after CapCut has already been
  registered successfully. Check `winget list` and the uninstall registry
  before retrying the installation.
- The requested visual target is a low-budget mobile 3D story-animation look:
  long narrow faces, large glassy eyes, smooth waxy skin, thin limbs, stiff
  poses, simple textures, and flat daylight. Polished cinematic game rendering
  is the wrong direction for this series.
- On Windows, the skill-creator Python tools may read UTF-8 Japanese files with
  the `cp949` locale and fail. Set `$env:PYTHONUTF8='1'` before running
  `generate_openai_yaml.py` or `quick_validate.py`.
- YouTube automatic captions are useful for narration timing, sentence density,
  and broad music markers, but they cannot verify the exact identity or count
  of sound effects. Analyze exact audio cues only from a rights-cleared source.
- Keep the 70-115 second 3D narrative format separate from the 20-50 second
  TOP-N compilation format. They share fast hooks but require different source
  rights, pacing, and payoff structures.
- YouTube public storyboard formats can support roughly one-second visual
  contact sheets without downloading the underlying third-party video. They
  are suitable for OCR, composition, gesture, and approximate boundary study,
  but not frame-accurate edit or audio claims.
- A newly posted Short should not be labeled a failure from cumulative views
  alone. Record the publication date and separate early like rate, comment
  rate, view velocity, and structural observations.
- The `윌리랭킹` samples primarily use source dialogue, music, and Korean
  translation or reaction cards rather than a stable channel narrator. Treat
  source speech and creator-authored narration as separate evidence classes.
- This workspace does not currently expose a `ruff` executable through PATH or
  `uv run`. Record the unavailable lint check and still run focused tests,
  Python compilation, and the official skill validator.
- For the `윌리랭킹` benchmark, the 12-video median was 9.54 seconds per ranked
  item. Videos above three million views had a median of 10.17 seconds per
  item, so use 9-12 seconds instead of the five-second pace in the 2026-06-11
  skate reference.
- Generate ranking TTS as separate files and verify `delay + duration` against
  the next segment start. If speech is too long, shorten the script before
  raising Korean TTS speed beyond 12%.
- Pexels source pages may be Cloudflare-protected while licensed media files
  remain available. Record the asset page, creator, license URL, and check date
  in a manifest before editing.
- Treat private-review approval and public-upload clearance as independent
  states. Approval to create a local review MP4 must never change a source from
  `허가 필요`, `공개 업로드 불가`, or `확인 불가` to publish-safe.
- For viral-source research, require exact visible engagement values or the
  literal marker `확인 불가`; do not normalize abbreviated counters into
  invented exact numbers.
- Stock footage must not replace viral-source research. Use Pexels, Pixabay, or
  stock only after the user explicitly requests a publish-safe version, and
  disclose `원본 바이럴 소스를 못 써서 대체함`.
- On Windows PowerShell, Korean `--interface` arguments passed to the skill
  metadata generator may be written with mojibake even with `PYTHONUTF8=1`.
  Use ASCII UI metadata when the generated YAML does not preserve Korean.
