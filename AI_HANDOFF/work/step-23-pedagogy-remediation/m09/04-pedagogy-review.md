# M09 — PEDAGOGY REVIEW (Pedagogy Reviewer)

CONTENT_REVISION: `fb2190cd|0e2714f9|ffc7e60a|712f66ef`
Companion technical review: not read.
Verdict: **PEDAGOGY_PASS**

## P1–P12 rows

| Lesson | CORE | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m09/01 | D-12, A-04 | 4 | 4 | 5 | 4 | 4 | 4 | 4 | 4 | 5 | 5 | 4 | 4 | PASS |
| m09/02 | — | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | PASS |
| m09/03 | F-13 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 5 | 4 | 4 | 4 | PASS |
| m09/04 | — | — | — | — | — | — | — | — | — | — | — | — | — | PASS (retained) |

## Instrument evidence

- **P9:** m09/01's exercise weaponizes the lesson's own 3-rule table —
  each rule must be *broken on paper* and the observable symptom
  predicted (timer errors are temporal, not compile-time: the exercise
  teaches where to look). m09/02's transition table forces the
  non-obvious backward edge (TIẾP returns to answering) and the
  lifecycle-vs-state-machine distinction (row 6). m09/03's stack
  prediction makes `dialogContext`/`popUntil` reasoned rather than read.
- **Isolated examples:** bare `Timer.periodic` shows
  survives-main + self-cancel in 15 lines; the `AlertDialog` demo shows
  barrier-as-route in ~50.
- **P10:** double-pop race surfaced as a *question to predict*, not
  merely a warning line.
- **P5:** ~170 added lines across 3 lessons.
- **P7/P11:** zero ports; zero governance noise; M21 honesty intact.

## Findings

None above NOTE.

## Verdict rationale

Phase-machine and dialog-as-route are now practised as *predictions
about failure*, which is how these bugs actually appear in the wild.
`PEDAGOGY_PASS`.
