# Viral Source Highlight Editor Skill

## Goal

Create a new global Codex skill named `viral-source-highlight-editor` for
researching already-viral source videos and planning or producing Korean
ranking-style highlight edits.

## Requirements

- Preserve the existing `rights-safe-shorts-editor` unchanged.
- Install the new skill under
  `C:\Users\llorr\.codex\skills\viral-source-highlight-editor\`.
- Use `VIRAL_SOURCE_CUT_PRIVATE_REVIEW` as the default mode.
- Search actual viral originals before considering stock footage.
- Prioritize original long-form uploads, earliest uploaders, high-view
  long-form sources, then TikTok, Douyin, Xiaohongshu, and Shorts.
- Record unavailable engagement metrics as `확인 불가`; never estimate them.
- Separate private-review editing from public-upload rights clearance.
- Require explicit user approval before rendering `private_review.mp4`.
- Never remove watermarks, conceal attribution, bypass access controls, evade
  copyright detection, or claim unknown-rights footage is publish-safe.
- Produce templates and validation for:
  `source_candidates.md`, `cut_manifest.json`, `edit_plan.md`,
  `script_ko.txt`, `rights_report.md`, `private_review.mp4`,
  and `publish_safe_plan.md`.
- Use TOP3 31-45 seconds or TOP5 45-60 seconds, normally 8-12 seconds per item.
- Require setup, action, reaction, and tail beats.
- Permit Pexels, Pixabay, or stock footage only when the user explicitly
  requests a publish-safe version, with the required fallback disclosure.
- Output MP4, SRT, and a CapCut-friendly project folder when rendering is
  approved.
- Include deterministic validation scripts and test them.
- Validate the completed skill with the official skill-creator validator.

## Non-Goals

- Editing a new private-review video during this task.
- Downloading any third-party viral footage.
- Declaring private-review footage safe for public upload.
- Modifying or deleting the existing rights-safe skill.
