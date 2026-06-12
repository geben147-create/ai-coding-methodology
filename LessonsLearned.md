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
