# M08 — CONTENT DRAFT MANIFEST

CONTENT_REVISION: `f0f19dfc|bb510935|e7bf2800|2e55a5a1`

| Lesson | Change type | CORE | Exercise level | Decision required | Verification |
|---|---|---|---|---|---|
| m08/01 | TỰ_LÀM | — | MODIFY | nullable-vs-required for new field + ctor compatibility | analyze + print new field |
| m08/02 | ISOLATED_EXAMPLE (TrafficLight enum) + TỰ_LÀM | D-06, A-04 | PREDICT | derive 4 visual states + reset-field list | run app, compare scenario |
| m08/03 | TỰ_LÀM | — | PREDICT | mutation-without-notification symptom + rebuild scope | run/debugPrint |
| m08/04 | ISOLATED_EXAMPLE (counter test) | F-14 | — | — | existing exercise retained |

Strong prose preserved: model-read-only rationale, enum-vs-sealed
boundary, derived-state table, test lifecycle prose. `switch` correctly
absent (D-14 = M09/03).
