# M08 — PEDAGOGY REVIEW (Pedagogy Reviewer)

CONTENT_REVISION: `f0f19dfc|bb510935|e7bf2800|2e55a5a1`
Companion technical review: not read.
Verdict: **PEDAGOGY_PASS**

## P1–P12 rows

| Lesson | CORE | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m08/01 | — | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | PASS |
| m08/02 | D-06, A-04 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 5 | 4 | 4 | 4 | PASS |
| m08/03 | — | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 5 | 5 | 4 | 4 | PASS |
| m08/04 | F-14 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | PASS |

## Instrument evidence

- **P9:** m08/01 MODIFY — the real decision is "optional nullable param
  keeps every existing call-site valid", discovered via the compiler
  counterfactual. m08/02 PREDICT — applies the derivation table AND
  demands the reset-field list (the phase-transition discipline M09
  will need). m08/03 PREDICT — deliberately reintroduces the
  missing-`setState` bug on harder state, plus a rebuild-scope nuance
  question.
- **Isolated examples:** TrafficLight shows enum's compile-time
  guarantee in 20 lines *without* `switch` (correctly scaffolded);
  counter widget-test example isolates pumpWidget→find→tap→pump→expect
  before the app test buries it in fixtures.
- **P10:** forgetting `setState` exercised *again* at higher complexity
  — spaced repetition of the milestone's most costly misconception.
- **P5:** ~140 added lines across 4 lessons.
- **P7/P11:** zero ports; zero governance noise.

## Findings

None above NOTE.

## Verdict rationale

Exercises now test derivation and mechanism, not transcription; the
enum and widget-test CORE concepts both carry domain-neutral runnable
examples. `PEDAGOGY_PASS`.
