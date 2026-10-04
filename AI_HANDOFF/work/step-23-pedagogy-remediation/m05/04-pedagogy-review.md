# M05 — PEDAGOGY REVIEW (Pedagogy Reviewer)

CONTENT_REVISION: `b34a4445|8a4f780e|786c027a`
Companion technical review: not read.
Verdict: **PEDAGOGY_PASS**

## P1–P12 rows

| Lesson | CORE | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m05/01 | D-09, D-10 | 5 | 4 | 5 | 4 | 4 | 4 | 4 | 4 | 5 | 5 | 4 | 4 | PASS |
| m05/02 | F-09 | 4 | 4 | 4 | 4 | 4 | 5 | 4 | 4 | 5 | 5 | 4 | 4 | PASS |
| m05/03 | — | — | — | — | — | — | — | — | — | — | — | — | — | PASS (retained) |

## Instrument evidence

- **P10 (misconception vaccination):** the m05/01 example makes the
  learner *see* `Instance of 'Future<String>'` — the single most
  effective antidote to "async function returns the value". The PREDICT
  exercise then targets the false coroutine intuition head-on:
  "no await ≠ no run".
- **P9:** m05/02's exercise is *deliberate rule-breaking*: the learner
  creates the future-in-build bug themselves, predicts the symptom, then
  observes the spinner-flicker. A cause→symptom mapping they will never
  forget — and it inoculates the #1 real-world FutureBuilder bug.
- **Isolated examples:** bare-Future example is DartPad-pure (right
  medium); `QuoteLoader` is the complete FutureBuilder contract in 45
  lines with `snapshot.data` typed — complementing the app's `void`
  version rather than duplicating it.
- **P5:** ~130 added lines across 2 lessons; no new APIs beyond taught
  set; exercises reuse existing app behaviors (tap PLAY) as the
  observation instrument.
- **P7/P11:** zero ports; zero governance noise.

## Findings

None above NOTE.

## Verdict rationale

M05's already-strong prose now has demonstration + self-inflicted-bug
practice on exactly the two concepts Android devs mispredict.
`PEDAGOGY_PASS`.
