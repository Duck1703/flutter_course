# M04 — PEDAGOGY REVIEW (Pedagogy Reviewer)

CONTENT_REVISION: `9d39a9cb|a2ac0f67|399d0e66|b7110f6d`
Companion technical review: not read.
Verdict: **PEDAGOGY_PASS**

## P1–P12 rows

| Lesson | CORE | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m04/01 | D-03, D-04 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | PASS |
| m04/02 | D-05 | 4 | 4 | 4 | 4 | 4 | 5 | 4 | 4 | 5 | 5 | 4 | 4 | PASS |
| m04/03 | — | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 5 | 4 | 4 | 4 | PASS |
| m04/04 | D-23 | — | — | — | — | — | — | — | — | — | — | — | — | PASS (retained) |

## Instrument evidence

- **P9:** m04/01 PRODUCE — three distinct semantic decisions (required /
  nullable-means-absent / has-default) forced per field, then a
  predicted compile error. m04/02 PRODUCE — the *design* decisions
  (negative-EXP policy, de-level semantics) are genuinely open, not
  transcription; solution acknowledges the second defensible answer.
  m04/03 PREDICT — five-point trace forces connecting setState →
  model-fields → widget-reads, the real data-flow skill.
- **Isolated examples:** `Badge` compresses the lesson's three param
  patterns into 15 runnable lines. `Wallet` is the better kind of
  example: it *demonstrates the misconception* (const canonicalization
  masking identity-`==`) before showing the fix — P10 vaccination by
  construction.
- **P10:** the const-canonicalization trap is exactly where a Kotlin
  `data class` mental model mispredicts; the example surfaces it with a
  deliberate false-`true` first.
- **P5:** ~130 added lines across 3 lessons; pure-Dart examples need no
  Flutter context (right medium for Dart concepts — no forced Flutter).
- **P7/P11:** zero ports, zero governance noise.

## Findings

None above NOTE.

## Verdict rationale

Both CORE lessons now carry domain-neutral runnable examples; every
exercise requires a decision not spelled out in preceding text.
`PEDAGOGY_PASS`.
