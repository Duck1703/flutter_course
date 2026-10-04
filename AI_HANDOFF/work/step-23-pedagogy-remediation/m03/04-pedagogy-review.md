# M03 — PEDAGOGY REVIEW (Pedagogy Reviewer)

CONTENT_REVISION: `11c6b2b0|937d4b67|2b7695c0`
Companion technical review: not read.
Verdict: **PEDAGOGY_PASS**

## P1–P12 rows

| Lesson | CORE | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m03/01 | F-04, D-08 | 4 | 4 | 4 | 4 | 3 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | PASS |
| m03/02 | F-05 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | PASS |
| m03/03 | F-06, A-02 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | PASS |

## Instrument evidence

- **P9 difficulty:** m03/01 MODIFY — not "change a string": the real
  decision is *whether a new state field is needed at all* (derived-vs-
  source-state), which is the deepest idea M03 can offer at this point.
  m03/02 PREDICT×4 — edge cases chosen precisely where naive intuition
  fails (mutation outside closure still renders; setState in initState
  redundant-but-not-error). m03/03 existing activity retained.
- **Isolated examples:** `LightSwitch` = the *whole* concept in 25
  lines — the learner sees the complete Widget+State contract before
  its 5-step production application. `ScoreBoard`/`ScoreChip` makes the
  ownership rule concrete with a second instance (model generalization).
- **P7 ledger:** zero ports; both exercises demand reasoning before the
  hidden solution.
- **P5:** new sections reuse only taught syntax (verified no `${}`,
  no untaught APIs); ~100 added lines across 3 lessons, all high-signal.
- **P10:** the m03/02 PREDICT set *is* misconception vaccination — the
  two most common beginner errors are posed as predictions, not warnings.
- **P11:** zero governance noise.

## Findings

None above NOTE.

## Verdict rationale

The strongest-prose milestone in the early band now also has complete
active machinery; the derived-state exercise introduces a design
decision (not transcription) at exactly the right depth. `PEDAGOGY_PASS`.
