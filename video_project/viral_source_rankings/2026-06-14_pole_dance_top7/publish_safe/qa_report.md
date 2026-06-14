# Replacement Render QA

Checked: 2026-06-14

## Final media

- File: `pole_aerial_top7_publish_safe.mp4`
- Duration: 56.000 seconds
- Video: H.264, 1080x1920, 30 fps
- Audio: AAC, mono, 48 kHz
- Size: 52,526,380 bytes (50.09 MiB)
- SHA-256: `25C601CA67E970F07B214C05F08506F07D4E981F95EB5DB3BFA87CABE630C3DB`

## Visual QA

- Korean title and captions render without mojibake.
- The title is yellow and `랭킹 TOP7` is white.
- The left-side list remains visible in every segment.
- The active item changes to red every eight seconds.
- The first clip opens on the fire-sword action.
- All seven subjects remain within the centered 9:16 crop.
- Central reaction captions and lower educational captions are legible.

## Audio QA

- VoiceBox Qwen CustomVoice 0.6B built-in `Sohee` narration is present.
- BGM is generated locally from FFmpeg oscillators and pink noise.
- No third-party samples are used.
- Mean volume: -16.7 dB
- Maximum volume: -1.4 dB
- No silence interval longer than one second was detected below -45 dB.

## Rights QA

- `rights.manifest.original.json`: render blocked for all seven original sources.
- `rights.manifest.replacement.json`: render approved for seven licensed clips, generated BGM, and licensed TTS.
- Publish operation remains blocked until separate final human approval is added.
