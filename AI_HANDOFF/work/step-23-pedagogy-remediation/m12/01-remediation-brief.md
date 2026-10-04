# M12 — STEP-23 REMEDIATION BRIEF (Atlas)

## Step-21 findings

F-H1: 1/3 lessons with `Tự làm`; zero isolated examples.
Provider is a top-priority false-analogy zone (runtime lookup ≠ DI
compile-time validation; `watch` ≠ Compose auto-tracking).

## Lessons

| Lesson | Depth | CORE | V2 gaps | Action |
|---|---|---|---|---|
| `m12/01` InheritedWidget + lookup | CORE_CONCEPT | F-17 (tree lookup) | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (hand-rolled InheritedWidget, DartPad — no package) +TỰ_LÀM (PREDICT lookup outcomes) |
| `m12/02` read vs watch | CORE_CONCEPT | F-18 | no `Tự làm` | +TỰ_LÀM (RECOGNIZE/PREDICT call-site selection) |
| `m12/03` ChangeNotifierProvider + scope | NORMAL | — | `Tự làm` exists | EXISTING_ACTIVITY_RETAINED |

## Justification — no isolated Provider example

`package:provider` is not reliably DartPad-available; a `.value`+watch
example would only duplicate m11/02's notifier mechanism plus one
lookup line. Raw tree-lookup mechanics are demonstrated standalone in
m12/01's hand-rolled `InheritedWidget` example (zero dependencies).
read/watch semantics are exercised against the real app in m12/02's
call-site exercise — verifiable there.

## Constraints

- No `sealed` (M15), no MultiProvider requirement, no repository (M14),
  no event stream (M13).
- Files: `web/src/content/docs/m12/{01,02}*.md`.
