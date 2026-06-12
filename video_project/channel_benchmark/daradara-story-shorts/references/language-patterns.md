# Language Patterns

Use meaning-preserving adaptation, not literal translation.

## Timing Targets

| Language | Narration target | Caption unit |
|---|---|---|
| Japanese | 7.8-8.6 characters/s; up to 9.1 for a deliberate fast cut | 12-24 characters |
| Korean | 4.8-6.2 syllable blocks/s | 8-18 blocks |
| English | 150-185 words/min | 4-9 words |
| Spanish | 150-180 words/min | 4-9 words |
| Portuguese | 145-175 words/min | 4-9 words |
| Simplified Chinese | 4.0-5.2 characters/s | 8-16 characters |

Generate TTS before locking shot length. Shorten wording before accelerating a
voice by more than 15%.

## Japanese

Use:

- polite factual narration in `です/ました`
- short clauses with explicit subjects when clarity requires them
- concrete quantities and objects
- `ですが` for reversal
- `ある日` for a new incident
- `次の瞬間` only at a genuine visual turn
- `そこで` for the protagonist's decision
- `そして` for the final consequence

Avoid:

- literary descriptions
- long nested relative clauses
- repeated rhetorical questions
- excessive slang
- ending every line with identical cadence

Hook model:

`結果 + まだ説明されていない原因`

Example:

`卒業式の日、校長先生が一人の生徒に頭を下げました。学校全体が、
半年間その子を疑っていたからです。`

## Korean

Prefer a direct spoken-news rhythm:

- `그런데`, `바로 그때`, `결국`, `하지만`
- one noun-heavy visual fact per line
- omit subjects when they are already visually obvious
- keep quoted dialogue short and natural

Do not preserve Japanese honorific cadence when it sounds translated.

## English

Prefer active verbs and short subject-verb-object sentences. Replace Japanese
connectors with causal transitions such as `But`, `Then`, `That was when`, and
`By graduation day`.

Keep the hook under 18 spoken words when possible.

## Spanish And Portuguese

Shorten pronoun-heavy clauses. Move the concrete object or consequence earlier
than a literal translation would. Keep dialogue conversational and avoid
region-specific slang unless the target market is specified.

## Chinese

Use compact cause-and-effect clauses. Avoid stacking four-character idioms
that make the narration sound literary. Keep names and numbers visible in the
caption when they are essential clues.

## Adaptation Checklist

- Does the first sentence create a question?
- Is each caption readable before the next cut?
- Does the repeated dialogue line sound natural in this language?
- Does the reveal land in the final third?
- Is the final sentence shorter and calmer than the confrontation?
- Does the translated TTS fit without speeding beyond 15%?
