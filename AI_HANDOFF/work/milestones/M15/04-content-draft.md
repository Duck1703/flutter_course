# CONTENT DRAFT — M15: Sealed classes & state-driven UI

> Produced by: Lumen (`lumen-flutter-learning-expert`)
> Basis: `01-brief.md` + `02-implementation-evidence.md`
> (**IMPLEMENTATION_APPROVED** by Atlas — see `00-status.md`)
> Prerequisite gates checked against `LEARNER_CONCEPT_REGISTRY.md` +
> `PREREQUISITE_GRAPH.md` before authoring.

## Lesson list / routes

| # | Slug | Title | New concepts (major count) |
|---|------|-------|---------------------------|
| 01 | `01-vi-sao-state-dong` | Vì sao cần state đóng — finite variants vs trường rời rạc | state-driven UI intro (A-14) — 1 |
| 02 | `02-sealed-class` | `sealed class` — tập đóng các variant | `sealed class` (D-26) — 1 |
| 03 | `03-switch-kiet-hop-pattern` | `switch` kiệt hợp + object patterns | switch expression + `Type()`/`(:final f)`/`_` (D-27) + `runtimeType` LIGHT (D-28) — 1 major + 1 light |
| 04 | `04-seal-event-bridge` | Seal hoá event bridge (FR-15) | application only; A-05 reinforcement — 0 new |
| 05 | `05-gamedialogstate-state-driven-ui` | `GameDialogState` + dialog render theo state | A-14 completion — 0 new (application) |

5 lessons — matches the brief's split decision (≤2 majors/page).

## Concept coverage vs registry

- D-26 `sealed class` → taught L02, first code L04, reinforced L05 ✓
- D-27 exhaustive switch + patterns → taught L03, first code L04–05 ✓
- D-28 `runtimeType` → awareness only, senior evidence L03/L05 ✓
- A-14 state-driven UI → introduced L01, completed L05 ✓
- A-05 state vs event → reinforced L04 ✓

## First-appearance & prerequisites

- All prereqs verified in registry: D-04/D-06/D-13/D-14/D-22, A-01/A-05,
  F-13 (`showDialog`), F-04 (`State` fields). No assumed Kotlin-only
  knowledge; Kotlin `sealed`/`when` bridges marked IMPORTANT DIFFERENCE.
- No lesson cites a "cố ý chưa làm" item as learned.

## Isolated examples (before production code)

- L02: `PaymentState` sealed hierarchy (Idle/Processing/Success(id)/Failure(error)) — 4 variants, pure Dart.
- L03: `label(PaymentState)` switch expression + PREDICT experiment
  (delete `PaymentFailure` case → `non_exhaustive_switch_expression`).

## Independent exercises

- L02 `Tự làm`: define `sealed ConnectionState{Offline, Connecting(retries), Online}` — production.
- L03 `Tự làm` + PREDICT: write `describe(ConnectionState)` exhaustively; predict compile error when a case is dropped.
- L05 `Tự làm`: DEBUG — a `switch` on `GameDialogState` missing `GameDialogHidden` — learner must explain + fix.

## Template V2 checklist per lesson

Template-V2 section audit (post-Argus remediation — every drop or
merge is declared):

| Lesson | Sections dropped/merged | Reason |
|--------|------------------------|--------|
| L01 | `Hiểu code` merged into `Ví dụ độc lập`; `Tự làm` = pointer to L02/L05 | theory-only lesson — no new construct to walk; no production to exercise |
| L02 | none — full skeleton | CORE_CONCEPT lesson |
| L03 | none — full skeleton | CORE_CONCEPT lesson |
| L04 | `Ví dụ độc lập` (points back to L02/L03); `Tự làm` merged | application lesson — shape identical to PaymentState; production exercise lives in L05 |
| L05 | `Ví dụ độc lập` (declares reuse of L03's `label(PaymentState)`); `Tự làm` = DEBUG exercise | application lesson — pattern already isolated; DEBUG is the production exercise |

No section is silently absent anywhere — each `Flutter cần dùng`/
`Dart cần dùng` exists and says "không có mới" where true.

## Sequential checkpoint plan

| Lesson | Code change | Checkpoint |
|--------|-------------|------------|
| L01 | none | explain-why Q&A; analyze clean |
| L02 | none | PaymentState mentally traceable; analyze clean |
| L03 | none | PREDICT verified by reading compiler evidence |
| L04 | seal event file + bridge + VM types (atomic) | `flutter analyze` clean; menu tests pass |
| L05 | GameDialogState + game_screen refactor + tests | analyze clean; `flutter test` 74 green |

## Fidelity labels

- `GameDialogState` 3-variant subset: `TEACHING_SIMPLIFICATION` (senior 9)
- `reason` payload vs `earnedAmount`: `TEACHING_SIMPLIFICATION` → M19/M22
- `showDialog` kept: `TEACHING_SIMPLIFICATION` → M21
- `MenuDialogState` absent: deferred (no learner menu dialogs; M16/M21+)

## M16+ leakage scan

Zero: no settings/onboarding/lifeline/leaderboard/auth concepts; no
reducer/immutable-state/`copyWith`-state-returns teaching (M19); no
`AnimatedSwitcher`/`transitionKey` usage (awareness citation only);
no `MenuDialogState` learner code.
