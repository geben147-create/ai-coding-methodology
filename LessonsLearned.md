# Lessons Learned

- The workstation has FFmpeg and an RTX 4070 Laptop GPU, but the detected VRAM
  is insufficient for the available large local video models.
- The existing video toolkit has Qwen3-TTS configured through Modal, while its
  LTX video-generation endpoint is not configured.
- For this proof of concept, generated keyframes plus FFmpeg motion are the most
  reliable available production path.
- The requested visual target is a low-budget mobile 3D story-animation look:
  long narrow faces, large glassy eyes, smooth waxy skin, thin limbs, stiff
  poses, simple textures, and flat daylight. Polished cinematic game rendering
  is the wrong direction for this series.
