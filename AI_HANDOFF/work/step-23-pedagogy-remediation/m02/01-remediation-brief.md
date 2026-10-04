# M02 — STEP-23 REMEDIATION BRIEF (Atlas)

## Step-21 findings

F-H1: 1/4 lessons with `Tự làm`; zero isolated examples. Constraints
mental model audited STRONG — preserve; add machinery only.

## Lessons

| Lesson | Depth | CORE first-teaching | V2 gaps | Action |
|---|---|---|---|---|
| `m02/01` constraints model + Column | CORE_CONCEPT | F-07 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE +TỰ_LÀM (PREDICT) |
| `m02/02` skeleton + tokens | NORMAL | — (applies F-07) | no `Tự làm` | +TỰ_LÀM (PREDICT wrap-order) |
| `m02/03` header/cards Row+Expanded | NORMAL | — (applies F-07, D-04) | no `Tự làm` | +TỰ_LÀM (PRODUCE small) |
| `m02/04` CTA + finish | NORMAL | — | `Tự làm` exists (MODIFY, two-decision) | EXISTING_ACTIVITY_RETAINED |

## Isolated-example requirement

`m02/01` — greedy `Container(width: 99999)` inside `Center`: constraints
clamp in action. ~20 lines, DartPad-Flutter runnable, domain-neutral.

## Constraints

- No state/`setState` (M03); no `ListView`/scroll (deferred); no
  `Stack`/`Positioned` (M18/M21 firewall); no assets.
- New card exercise uses ONLY already-shown APIs
  (`Container`/`BoxDecoration`/`Column`/`Row`/`Text`/`SizedBox`).
- Files allowed: `web/src/content/docs/m02/{01,02,03}*.md`.
