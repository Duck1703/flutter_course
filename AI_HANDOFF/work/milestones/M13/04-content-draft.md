# CONTENT DRAFT — M13: One-shot UI events from the VM

> Produced by: Lumen (`lumen-flutter-learning-expert`)
> Contract: `../../contracts/CONTENT-HANDOFF-CONTRACT.md`
> Based on: `02-implementation-evidence.md` r2 (IMPLEMENTATION_APPROVED)
> State on submission: `CONTENT_QA` (awaiting Argus)

## 1. Lesson decomposition

| Order | Slug | Title | Milestone coverage slice |
|-------|------|-------|--------------------------|
| 0 | `lessons/index.md` | Tổng quan M13 | result summary, concept table, completion criteria |
| 1 | `01-event-khong-phai-state` | Event ≠ state | event-vs-state model; `menu_ui_event.dart`; broadcast controller + `events` getter + `requestGame()`/`resetProfile()` emit + `dispose` close on VM |
| 2 | `02-event-bridge-trong-state` | Event bridge trong State | `_viewModel`/`_eventSubscription`, `didChangeDependencies` → `_attachViewModel` guard, `_handleUiEvent` (`is` + `unawaited`), `dispose` cancel; `_onPlayTap`/`_openGame` split |
| 3 | `03-snackbar-event-va-test` | SnackBar event & test | `MenuSnackBarRequested` → `ScaffoldMessenger`; 3 VM tests + 2 widget tests; broadcast no-replay semantics |

## 2. Learning goals

- L1: learner can explain state-vs-event and name two things that are
  events (navigation, snackbar); can create a broadcast event channel.
- L2: learner can implement a bridge `State` with correct subscribe /
  re-subscribe-guard / cancel lifecycle and explain each step.
- L3: learner can prove the channel works with a VM test
  (`events.first`) and a widget test (`ensureVisible`, manual pumps).
- Milestone total: roadmap outcome — "explain rebuild-vs-fire split,
  implement broadcast controller on VM, consume in StatefulWidget
  bridge" — plus roadmap test targets.

## 3. New concepts & first appearances

| Concept | Lesson explained | Code location |
|---------|------------------|---------------|
| `abstract class`/`final class` event classes | L1 (Dart table + file) | `menu_ui_event.dart` |
| `StreamController<T>.broadcast()` | L1 | `menu_view_model.dart` `_events` |
| `Stream` getter exposing one-way channel | L1 | `events` getter |
| `_events.add(...)` intent emission | L1 | `requestGame()`, `resetProfile()` |
| `StreamSubscription<T>` + `cancel()` | L2 (Dart table + lifecycle) | `_MenuScreenViewState` |
| `didChangeDependencies` as subscribe site | L2 (mental model + "hiểu code") | `didChangeDependencies` |
| re-subscribe identity guard | L2 | `_attachViewModel` `==` |
| `is`-check event dispatch | L2 | `_handleUiEvent` |
| `unawaited` | L2 (Dart table + step + "hiểu code") | `_handleUiEvent` — QA-IMPL-001 site |
| `SnackBar` widget (first course appearance — M13) | L2 (Flutter table + post-step note) | `_handleUiEvent` |
| `ScaffoldMessenger.of` (first course appearance — M13) | L2 (Flutter table + post-step note) | `_handleUiEvent` |
| `stream.first` in tests | L3 | `menu_view_model_test.dart` |
| `ensureVisible` before offscreen tap | L3 | `menu_ui_events_test.dart` |

## 4. Prerequisite references

- L1 → M06 (streams), M11 (ChangeNotifier), M12 (read/watch, Provider).
- L2 → M03 (lifecycle), M06 (`listen`/`StreamSubscription`), M09–M10
  (Navigator + `GameResult` flow), M12 (`context.read`).
- L3 → M06 (ticker → no `pumpAndSettle`), M04–M12 (test conventions),
  M12 (scope-wrapped widget test).
- All references are to concepts actually taught in shipped M01–M12.

## 5. Incremental implementation

L1: step 1 = +28 lines new file; step 2 = ~30 lines changed in VM
(controller, getter, `requestGame`, `resetProfile` emit, `dispose`).
L2: step 1 = ~35 lines (fields + 3 lifecycle methods) — justified as
one indivisible lifecycle; steps 2–3 ≈ 20 lines. L3: tests only.
Each step compiles standalone; nothing requires forward code.

## 6. Code explanation coverage

Every snippet's new constructs are explained in the adjacent text or
the Dart/Flutter tables: `abstract`/`final` (L1), `broadcast` (L1),
`didChangeDependencies` vs `initState` (L2 "Hiểu code"), identity
guard (L2), `unawaited` (L2 step comment + "Hiểu code"),
`ensureVisible`/`first` (L3). No unexplained block.

## 7. Android bridges (per lesson, three-line)

- L1: SIMILARITY `SharedFlow`/`Channel` one-shot effects; DIFFERENCE
  broadcast has no replay/buffer; DO NOT ASSUME Compose collection
  auto-cancels (Flutter cancels by hand).
- L2: SIMILARITY `LaunchedEffect` collecting events; DIFFERENCE
  manual `cancel()` vs auto lifecycle scope; DO NOT ASSUME
  re-subscribe is safe — guard needed against double handling.
- L3: SIMILARITY `SnackbarHostState.showSnackbar` + Turbine-style
  flow test; DIFFERENCE `stream.first` awaits next event directly;
  DO NOT ASSUME SnackBar renders synchronously after call.

## 8. Senior evidence references

| Citation | Class |
|----------|-------|
| `flutter-accelerator-ai/lib/view_models/menu/menu_screen_ui_event.dart` — `sealed class MenuScreenUiEvent`, `MenuGameRequested`, `MenuSnackBarRequested(message)` | DIRECT_EVIDENCE (static source inspection) |
| `flutter-accelerator-ai/lib/view_models/menu/menu_screen_view_model.dart` — `_events` broadcast ctor, `events` getter, `requestGame()` add, `_events.close()` in dispose | DIRECT_EVIDENCE |
| `flutter-accelerator-ai/lib/screens/menu_screen.dart` — `_MenuScreenEventBridgeState` lifecycle (L40–76) | DIRECT_EVIDENCE |
| senior `AppNavigationController.openGame()` | CITED as not-yet-introduced (D20); learner bridge calls `Navigator.push` directly — labelled TEACHING_SIMPLIFICATION |

All senior references are labelled inspection evidence; lessons tell
the learner the source is evidence, not copy-target.

## 9. Exercises/checks

Each lesson's "Kiểm tra hiểu biết" has 3 recall questions with inline
answers; "Checkpoint hoàn thành" is a binary checklist referencing
real files/commands (`flutter test` 57/57, file existence).

## 10. Common mistakes (per lesson)

- L1: single-subscription controller; forgetting `close()`; `await`
  in emit; storing event as state.
- L2: subscribe in `initState`; forget `dispose` cancel; no guard →
  duplicate handling; `await` in listener; `watch` for event reads.
- L3: offscreen `tap` without `ensureVisible`; `pumpAndSettle` with
  infinite ticker; asserting SnackBar too early; `listen` without
  cancel in tests; widget-only coverage hiding direct navigation.

## 11. Intentionally delayed concepts (named in lessons)

`sealed` events + exhaustive switch → M15 (L1, L2); repository/
rxdart/`BehaviorSubject`/`ValueStream` → M14 (L1, L3); navigation
controller → deferred per D20 (L2, overview); game-side VM events →
M19 (L1, overview); `context.select`, `MultiProvider`, `ProxyProvider`
→ forbidden by brief, not mentioned as near-term.

## 12. Completion criteria

Per lesson: checklists in each lesson file. Milestone (index.md):
event file exists; VM channel + emits + close; bridge lifecycle;
`_onPlayTap` → `requestGame`; `unawaited`; 57/57 tests green;
explicit "vẫn chưa có" list matching roadmap exclusions.

## 13. Code snapshot alignment

All Dart snippets were transcribed from the on-disk learner app after
Flux r2 — `menu_ui_event.dart` quoted in full; VM/bridge/test blocks
match `menu_view_model.dart`, `menu_screen.dart`,
`menu_view_model_test.dart` (M13 group), `menu_ui_events_test.dart`
verbatim including doc comments (r2 aligned the two trimmed comment
blocks; excerpts that omit surrounding file content are explicitly
framed as excerpts in the lesson text).
