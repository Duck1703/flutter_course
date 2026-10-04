# M13 — STEP-23 REMEDIATION BRIEF (Atlas)

## Step-21 findings

F-H1: 1/3 lessons with `Tự làm`; zero isolated examples.
Event-vs-state is a core conceptual boundary (the milestone's whole
purpose) and a false-analogy zone (broadcast ≠ SharedFlow replay;
no auto-dispose vs LaunchedEffect).

## Lessons

| Lesson | Depth | CORE | V2 gaps | Action |
|---|---|---|---|---|
| `m13/01` event ≠ state | CORE_CONCEPT | D-19/A-04 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (pure-Dart broadcast no-replay, DartPad `dart:async` only) +TỰ_LÀM (RECOGNIZE state-vs-event) |
| `m13/02` event bridge in State | CORE_CONCEPT | F-20 | no `Tự làm` | +TỰ_LÀM (PREDICT the three mandatory mechanisms) |
| `m13/03` snackbar event + test | NORMAL | — | `Tự làm` exists | EXISTING_ACTIVITY_RETAINED |

## Justification — no isolated widget example in m13/02

The bridge is Provider+State+subscription wiring — it cannot be
isolated without reproducing the whole app stack. Mechanism is
covered standalone by m13/01's pure-Dart demo; bridge mechanics are
exercised against real app code via three failure predictions.

## Constraints

- No `sealed` (M15 — lesson already notes this), no repository (M14),
  no BehaviorSubject/ValueStream.
- Files: `web/src/content/docs/m13/{01,02}*.md`.
