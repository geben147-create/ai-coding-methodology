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
- Korean UTF-8 attachment text may look corrupted under the default PowerShell
  console encoding even when the file itself is valid. Set
  `[Console]::OutputEncoding` to UTF-8 and read with `Get-Content -Encoding
  UTF8` before treating the source as damaged.
- The in-app browser screenshot command can time out on a long animated static
  page even when DOM rendering, responsive layout, interactions, and console
  logs are healthy. Verify layout dimensions and interaction states directly
  in the browser when capture alone is unavailable.
- On Windows, complex Firecrawl search queries containing nested quotation
  marks may be split into multiple CLI arguments. Use one double-quoted plain
  query string and keep exact-phrase verification in a follow-up search.
- Xiaohongshu can expose the public search shell while withholding individual
  result links and engagement metrics from logged-out web sessions. Record the
  access limitation and exclude those posts instead of fabricating candidates.
- An official creator channel is strong originality evidence but not a reuse
  license. Even likely-original Unitree uploads remain `permission-required`
  until the exact cut and publication rights are granted.
- FFmpeg's ASS filter on Windows can scan every file in `C:\Windows\Fonts` and
  emit noisy bitmap-font warnings. The render can still be valid when the log
  confirms `MalgunGothic` selection; verify the burned captions from extracted
  frames instead of treating unrelated font warnings as a render failure.
- Keep generated private-review source media and MP4 files local. Do not push
  uncleared third-party footage to GitHub merely to satisfy a general backup
  routine, because that would turn a local review artifact into distribution.
- UTF-8 Korean files can look garbled in PowerShell even when the file is fine.
  Re-read with an explicit UTF-8 decode before assuming the content is broken.
- For ranking hooks, inspect two-second contact sheets around the presumed
  action peak. Broad storyboard sampling can place the opening on an empty
  setup frame even when the selected source range contains a strong payoff.
- For a selection-first workflow, deliver both a tight 7-9 second core cut and
  a version with one-second handles on each side. Do not burn ranking labels or
  final captions until the user chooses the winning clips.
- VoiceBox 0.5.0 on Windows may initially start its bundled CPU backend even
  when an NVIDIA GPU is present. A Qwen CustomVoice model download can outlive
  the first server process; restart `voicebox-server.exe`, resume the same
  download, and verify `/models/status` before generating.
- Windows PowerShell can replace Korean characters in JSON request bodies.
  Write the request as a UTF-8 file and send it with `curl.exe --data-binary`
  plus `Content-Type: application/json; charset=utf-8`.
- Windows PowerShell 5 also decodes a BOM-less `.ps1` file as the active ANSI
  code page. Do not embed Korean narration literals in a generated PowerShell
  build script; read them from a UTF-8 text file with
  `Get-Content -Encoding UTF8`, then call `.ToString()` before
  `ConvertTo-Json` so PowerShell does not serialize the string's extended
  file-provider properties. VoiceBox `/generate` returns a queued
  generation, so poll `/history/{id}` and download `/audio/{id}` only after
  the status is `completed`.
- The 2026-06-13 stunt combined preview used Edge TTS
  `ko-KR-InJoonNeural` at rate `-2%` and pitch `-2Hz`; the VoiceBox `Sohee`
  sample was generated separately and was not mixed into that MP4. For future
  selection packages, keep individual cuts on source audio and use VoiceBox
  Qwen CustomVoice 0.6B `Sohee` for combined-preview narration. Treat Edge TTS
  as an explicitly approved fallback only.
- A Korean file can be valid UTF-8 while PowerShell displays mojibake under
  the wrong console encoding. Re-read with `Get-Content -Encoding UTF8`,
  validate the decoded text, and deliver original source URLs as clickable
  Markdown links both in the selection manifest and in the final response.
- When a user requires a long supplied skill specification to remain intact,
  preserve it line-for-line, limit corrections to an explicit allowlist, and
  verify that every corrected source line remains an ordered subsequence of
  the final `SKILL.md`. Record the source SHA-256 and line count separately.
- A rights gate should fail closed: `unknown` and `prohibited` must block
  rendering even when `render_allowed` is mistakenly true. Public publishing
  additionally requires per-source `publish` permission and explicit human
  approval, with every decision written to a UTF-8 audit log.
- A helper that returns `bool` does not automatically narrow an `Any | None`
  value for mypy. Before passing JSON values to a compiled regex, use an
  explicit `isinstance(value, str)` guard so the type checker and runtime
  share the same safety condition.
- VoiceBox preset profiles can disappear after an application reset even when
  the Qwen CustomVoice model remains downloaded. Resolve the preset profile at
  build time and recreate the built-in `Sohee` profile when absent instead of
  persisting a profile UUID.
- Windows PowerShell 5 can preserve a REST JSON array as one nested
  `System.Object[]` when it is wrapped again with `@(...)`. Do not add the
  extra array wrapper before filtering VoiceBox profiles.
- Build long FFmpeg filter graphs in a single variable before passing them to
  an argument array. Inline `+` concatenation inside `@(...)` can become
  separate command arguments and make FFmpeg interpret filter fragments as
  output filenames.
- Force final short-form AAC audio to 48 kHz. FFmpeg may otherwise negotiate a
  higher sample rate that plays correctly but is less predictable in mobile
  editors such as CapCut.
