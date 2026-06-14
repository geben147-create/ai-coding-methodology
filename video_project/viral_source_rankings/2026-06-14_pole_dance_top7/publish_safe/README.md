# Publish-Safe Replacement Build

This folder contains a rights-cleared replacement edit. It does not claim that
the replacement stock footage is the original viral footage.

## Audio provenance

- `original_bgm.wav` is generated locally by `build_publish_safe.ps1`.
- It uses only FFmpeg-generated sine waves and pink noise.
- It contains no third-party music, loops, or samples.
- Narration uses Qwen3-TTS 0.6B CustomVoice's built-in `Sohee` speaker.
- No real-person voice clone is used.

## Rights gate

The build runs the fail-closed rights checker before rendering:

```powershell
python "$env:USERPROFILE\.codex\skills\video-editing-compliance-skill\scripts\rights_check.py" `
  ..\rights.manifest.replacement.json --operation render
```

Public upload still requires a separate final human approval.
