# M19 — CONTENT DRAFT MANIFEST (Lumen)

## Intake gate

`IMPLEMENTATION_APPROVED` confirmed — `04-implementation-approval.md`
on disk after Argus implementation QA PASS + remediation re-verify
PASS (dialog back-routing MAJOR + flowToken/phase-guard/zero-timer
MINORs). Learner app verified: `flutter analyze` clean,
`flutter test` **126/126**, `flutter build web` pass. Senior source
unchanged (`main@c8eb860`).

## Lessons authored (6 + index)

| File | Concepts | Exercise |
|---|---|---|
| `index.md` | milestone map + 5-question synthesis checkpoint | — |
| `01-vi-sao-widget-khong-giu-noi-game.md` | A-18 mental model (FSM; enum>bool) | comprehension checkpoint |
| `02-data-game-moi-va-xe-man-cu.md` | D-34 `copyWith`+`clear*` (CORE); `GamePhase`×6; sealed `GameDialogState`×6; question model + bank; ladder 15; `game_money_formatter`; `GameResult.earnedAmount`; ARB; teardown→stub (+menu-test patch) | isolated `Form` example + checklist |
| `03-mapper-state-sang-screen-data.md` | A-20 presentation mapper; `GameScreenData` DTO; `_answerState`=f(phase) | mapper unit test (4) |
| `04-game-screen-view-model.md` (CORE) | D-33 `Timer.periodic`+`Duration` in VM; A-18 guards/transitions; `flowToken` anti-stale; `dismissDialog` routing | Tự làm PRODUCE: wrong-phase transition test |
| `05-man-hinh-moi-provider-bridge-popscope.md` | F-27 `PopScope`; A-19 `AppNavigationController`+`navigatorKey`; event bridge; portrait lock | widget test back-routing (10) |
| `06-tests-regression-tu-lam.md` | regression + synthesis | Tự làm PRODUCE: `GameRatingDialog` xuyên stack + DEBUG flowToken-reset |

## Registry / graph updates (done before QA)

- `LEARNER_CONCEPT_REGISTRY.md`: +D-33, +D-34, +F-27, +A-18, +A-19,
  +A-20 — all TAUGHT; F-22 gains M19 usage via A-19 prereq.
- `PREREQUISITE_GRAPH.md`: M19 section appended (edges M10/M11–M15
  → M19; feeds M20/M21/M22/M26).

## Depth assignments (per brief Learning Design Check)

- CORE: D-33 (L04), D-34 (L02), A-18 (L01+L04) — each has isolated
  example (OrderMachine / `Form` copyWith / fakeAsync timing), an
  experiment or DEBUG, a production Tự làm, and a checkpoint.
- NORMAL: F-27 (L05), A-19 (L05), A-20 (L03).

## Declared section merges/drops (template V2)

- L01 (theory): drops step-by-step build + Tự làm — no code changes;
  keeps mental model + isolated `OrderMachine` example + bridge +
  senior connection + comprehension checkpoint.
- L02: `Mental model mới`, `Thử nghiệm`, `Tự làm` folded — FSM
  model landed in L01; L02 is mechanical data+teardown whose check
  is analyze+tests, not an experiment. Everything else present
  incl. bridge, mistakes, checkpoint (analyze clean + 95/95).
- L03: `Ví dụ độc lập` + `Thử nghiệm` folded (mapper *is* the
  runnable example — tested directly); keeps mental-model-as-purpose
  prose + bridge + mistakes + checkpoint (99/99).
- L04 (CORE): **full skeleton** — Dart/Flutter tables, isolated
  runnable `MiniTimer` (Timer.periodic + cancel + dispose),
  `Thử nghiệm` (remove `flowToken` guard → stale reveal leaks into
  new session), mistakes, PRODUCE Tự làm (wrong-phase transition
  test), checkpoint (116/116).
- L05: `Ví dụ độc lập` folded (widget wiring has no isolated version —
  the widget tests are the executable check); keeps mental-model
  note + bridge + mistakes + checkpoint (126/126).
- L06: synthesis + regression + production Tự làm.

## Checkpoint arithmetic (honest, derived from M18 baseline 102)

| Lesson end | Count | Delta |
|---|---|---|
| L02 | 95 | −3 quiz −11 old widget +7 bank (sealed 5→5) |
| L03 | 99 | +4 mapper |
| L04 | 116 | +17 VM |
| L05/L06 | 126 | +10 widget |

## Scaffolding declarations

- `GameDialogRequested` event + `showDialog` bridge → M21
  (`GameDialogLayer` in `Stack`); declared in L02 + L05 callouts.
- `GameScreen` stub (L02→L05) — declared TEACHING SCAFFOLD.
- `openGame` returns `Future<GameResult?>` (senior `Future<void>`) — pop-
  result transport until M22 (FR-04); declared in L05.
- VM `extends ChangeNotifier` vs senior `DreChangeNotifier` — M26;
  declared in L01 + L04.
- `aiHintMessage`/`explainForWrongAnswers` field roles labelled
  "M20 dùng" where applicable.
