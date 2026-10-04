# M01 — STEP-23 REMEDIATION BRIEF (Atlas)

Status: `DRAFTED → UNDER_DUAL_REVIEW` target | Milestone state: `MILESTONE_COMPLETE` (historical, unchanged)

## Step-21 findings relevant here

- F-H1: early course lacks V2 active-learning machinery — M01 has 1/3
  lessons with `Tự làm`, zero structurally explicit isolated examples.
- M01 prose pedagogy audited STRONG/ACCEPTABLE — **preserve all existing
  explanations**; add missing machinery only.

## Lessons

| Lesson | Depth | CORE first-teaching | V2 gaps | Action |
|---|---|---|---|---|
| `m01/01` orientation/tooling | NORMAL | none | no `Tự làm` | +TỰ_LÀM (PREDICT) |
| `m01/02` runApp/widget tree | CORE_CONCEPT | F-01, F-02, F-03, A-01, D-01, D-02 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE +TỰ_LÀM (PREDICT) |
| `m01/03` run/reload/tooling | NORMAL | none | `Tự làm` exists (PREDICT r/R — P9 verified) | EXISTING_ACTIVITY_RETAINED |

## Isolated-example requirement

`m01/02` — domain-neutral `StatelessWidget` (`ProfileChip`) exercising
exactly the just-taught syntax (`required this.name`, `build` returns a
tree). Runnable in DartPad (Flutter mode). ~15 lines.

## Exercise targets

M01–M03 band: PREDICT / MODIFY / small PRODUCE. Chosen: two PREDICT tasks
each requiring a real decision (naming-rule application; MaterialApp's
hidden services), each verifiable by running.

## Constraints

- No state/`setState`/lifecycle (M03 firewall); no `Column`/`Padding`/
  `EdgeInsets` (M02); no string interpolation (not yet taught);
  Flutter SDK only (no packages — M01 rule).
- No senior-code changes; senior citations stay inspection-only.
- No learner-facing registry/gate IDs.
- Files allowed: `web/src/content/docs/m01/{01,02}*.md` only.

## Files allowed to change

`web/src/content/docs/m01/01-flutter-dart-va-project-dau-tien.md`,
`web/src/content/docs/m01/02-main-runapp-va-cay-widget.md`.
