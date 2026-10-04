# Artifact 08 — Argus Content QA (independent review of changed pages)

Scope: every changed lesson + all 7 new M14 lessons + 2 new reference
pages + 14 synthesis checkpoints + 13 `Tự làm` blocks.
Reviewed against G17–G24 (outside authoring context — findings
verified against site files, not the register's assertions).

## M14 lessons — full five-axis QA

| Lesson | Depth | Technical | Fidelity | Sequential | Load | Exercise |
|---|---|---|---|---|---|---|
| 01 | PASS | PASS | PASS | PASS (no code) | PASS | PASS (boundary-spot task) |
| 02 | PASS | PASS (contract compiles standalone) | PASS | PASS | PASS | PASS (`CounterRepository`) |
| 03 | PASS | PASS (runnable `dart run`) | PASS | PASS | PASS | PASS (late-subscriber predict) |
| 04 | PASS | PASS | PASS | PASS (additive) | PASS | PASS (guard-reasoning) |
| 05 | PASS | PASS | PASS — parity items named, whitelist/exp marked temporary with milestones | PASS | PASS | PASS |
| 06 | PASS | PASS | PASS — bridge state labelled TRANSITIONAL, retires bài 7 | PASS | PASS | PASS (fake-wiring) |
| 07 | PASS | PASS | PASS — deletions named, no invented senior behavior | PASS | PASS | PASS (data-flow narration) |

Isolated-example requirement (F-07): satisfied at 02 (Counter
contract), 03 (subject demo), 06 (bad-direction sketch) — no major
concept debuts inside production code anymore.

## M01–M13 targeted edits

- F-01/F-02/F-03: corrected text verified verbatim on pages.
- F-04 `factory` section at m10/02: generative-vs-factory, Kotlin
  bridge, when-NOT, tiny example — CORE_CONCEPT depth now met.
- F-05 scaffold callouts: present at introduction sites m03/01 and
  m06/01; each states concept taught + convergence milestone.
- Exercises: 13 blocks verified; solutions are hint-gated, not
  printed inline; difficulty progresses as required.
- Synthesis checkpoints: present on all 14 milestone indexes.

## Challenged and resolved

- "Does m14/06's 4-arg scope ctor leak an untaught MultiProvider
  detail?" — No: lesson teaches providers list explicitly first.
- "Does the transitional getter violate fidelity?" — It is marked
  TRANSITIONAL with a named retirement point (bài 7) and deleted
  there; production app never ships it.
- "Is m14/03 still overloaded?" — It carries one concept family
  (state-vs-event stream) with one example; acceptable under G22.

QA VERDICT: **PASS** on all changed/new content.
