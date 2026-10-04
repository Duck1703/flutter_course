# M01 — PEDAGOGY REVIEW (Pedagogy Reviewer)

CONTENT_REVISION: `919f9911…|6cce1d1f…|55d8c939…` (same blob set as
`02-content-draft-manifest.md`)
Companion technical review: **not read** — independent first pass.
Verdict: **PEDAGOGY_PASS**

## P1–P12 rows

| Lesson | CORE concepts | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m01/01 | — | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | PASS |
| m01/02 | F-01/02/03, A-01, D-01/02 | 4 | 4 | 4 | 4 | 3 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | PASS |
| m01/03 | — | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | PASS |

## Instrument evidence

- **P7 PORT ledger:** zero port activity added. `ProfileChip` is
  authored-for-teaching (~20 lines, domain-neutral); the Tự làm snippet
  is a 1-line *modification the learner must reason about*, not an answer
  dump. `DERIVATION_BEFORE_ANSWER: YES` on both new tasks (task first,
  hint optional, solution hidden behind `<details>`).
- **P9 difficulty ledger:** m01/01 PREDICT (apply naming rule to 4 cases,
  two edge cases); m01/02 PREDICT (compile-vs-display split + naming
  MaterialApp's services); m01/03 existing PREDICT retained — verified
  `Tự làm` ≠ transcription: each requires a decision not spelled out.
  Band target (M01–M03: PREDICT/MODIFY/small PRODUCE) met.
- **Scaffold fading:** M01 is the high-guidance end of the course by
  design; predict-verify tasks appropriately fade "watch me" into
  "you predict, then check".
- **P3 mental model:** the new isolated example exercises the *same*
  widget-as-config model with a second instance (`ProfileChip`) — model
  generalization, not duplication. The Tự làm converts a potential
  misconception ("MaterialApp = styling") into an observed fact
  (directionality error) — this is P10 work disguised as a PREDICT task.
- **P5 load:** additions are small; `ProfileChip` reuses only taught
  syntax (verified: no `Column`, no interpolation, no `EdgeInsets`).
- **P11 noise:** zero registry/gate IDs introduced; table header in
  m01/01 exercise is learner-meaningful (accept/reject + why).

## Findings

- NOTE — m01/02 exercise requires the learner to *temporarily break* the
  app; the restore instruction mitigates. Acceptable; the broken state is
  itself the teaching payload.

## Verdict rationale

All three lessons now end in meaningful, verifiable activity at band-
appropriate difficulty; the CORE lesson carries a domain-neutral isolated
example that exercises exactly the taught syntax; zero new load sources
beyond the intended concepts. `PEDAGOGY_PASS`.
