# M04 — STEP-23 REMEDIATION BRIEF (Atlas)

## Step-21 findings

F-H1: 1/4 lessons with `Tự làm`; zero isolated examples. M04 prose
STRONG (null-safety and immutable-update teaching were both called out
positively). Preserve; add machinery only. Senior-parity notes
(`'0XFF'` defaults, `expForNextLevel` simplification, M22 retirement)
must remain untouched.

## Lessons

| Lesson | Depth | CORE first-teaching | V2 gaps | Action |
|---|---|---|---|---|
| `m04/01` model + null safety | CORE_CONCEPT | D-03, D-04 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (Dart) +TỰ_LÀM (PRODUCE field semantics) |
| `m04/02` copyWith/==/hashCode | CORE_CONCEPT | D-05 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (Dart) +TỰ_LÀM (PRODUCE method) |
| `m04/03` wire model → menu | NORMAL | — | no `Tự làm` | +TỰ_LÀM (PREDICT-DEBUG data-flow reach) |
| `m04/04` first unit test | CORE_CONCEPT | D-23 | `Tự làm` exists | EXISTING_ACTIVITY_RETAINED |

## Isolated examples

- `m04/01` — pure-Dart `Badge`-style snippet: nullable field + `??` +
  named-param defaults. ~20 lines DartPad.
- `m04/02` — pure-Dart `Wallet`/`Tag` pair: same class shown WITHOUT
  `==` (identity → `false`) then WITH (value → `true`), plus copyWith
  producing a new instance. ~35 lines DartPad.

## Constraints

- No `fromMap`/`toMap` (M10), no `!.`/`?.` beyond taught usage, no test
  framework in new examples (D-23 is m04/04's).
- No new permanent model fields in exercises (fidelity); new methods OK
  if additive and labelled exercise.
- Files allowed: `web/src/content/docs/m04/{01,02,03}*.md`.
