# M08 — STEP-23 REMEDIATION BRIEF (Atlas)

## Step-21 findings

F-H1: 1/4 lessons with `Tự làm`; zero isolated examples. Project
implementation already provides useful practice — add machinery where
missing, do not duplicate the strong m08/04 exercise.

## Lessons

| Lesson | Depth | CORE | V2 gaps | Action |
|---|---|---|---|---|
| `m08/01` quiz question model | NORMAL | — | no `Tự làm` | +TỰ_LÀM (MODIFY model semantics: optional `explanation` field) |
| `m08/02` quiz state + enum | CORE_CONCEPT | D-06, A-04 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (enum, no `switch` — D-14 is M09) +TỰ_LÀM (PREDICT derivation + reset) |
| `m08/03` render options + flow | NORMAL | — | no `Tự làm` | +TỰ_LÀM (PREDICT rebuild/no-setState symptom) |
| `m08/04` first widget test | CORE_CONCEPT | F-14 | `Tự làm` exists; example is app-bound | +ISOLATED_EXAMPLE (standalone counter test) |

## Constraints

- `switch` statement/expression is D-14 first taught M09/03 — m08/02
  example must use `==`-comparison/ternary only.
- No M09 concepts (Timer, showDialog, GamePhase), no sealed classes
  (M15), no test matchers beyond M08's taught set.
- Files: `web/src/content/docs/m08/{01,02,03,04}*.md`.
