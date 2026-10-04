# M09 — STEP-23 REMEDIATION BRIEF (Atlas)

## Step-21 findings

F-H1: 1/4 lessons with `Tự làm`; zero isolated examples. The deliberate
`showDialog` scaffold and honest "overlay system comes in M21" framing
must be preserved verbatim.

## Lessons

| Lesson | Depth | CORE | V2 gaps | Action |
|---|---|---|---|---|
| `m09/01` GamePhase + Timer.periodic | CORE_CONCEPT | D-12, A-04 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (Timer DartPad) +TỰ_LÀM (PREDICT missing-cancel symptoms) |
| `m09/02` phase flow | NORMAL | — | no `Tự làm` | +TỰ_LÀM (PREDICT transition table) |
| `m09/03` showDialog + popUntil | CORE_CONCEPT | F-13 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (dialog demo) +TỰ_LÀM (PREDICT stack per button) |
| `m09/04` test game session | NORMAL | — | `Tự làm` exists | EXISTING_ACTIVITY_RETAINED |

## Constraints

- No `GameDialogState`/sealed overlay system (M21), no `PopScope`
  (M21), no repository/VM refactor (M11+), no `Timer`→Stream confusion.
- `switch` IS available here (D-14 taught in this lesson).
- Files: `web/src/content/docs/m09/{01,02,03}*.md`.
