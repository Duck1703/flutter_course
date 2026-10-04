# M13 Implementation Notes

Step 08 — One-shot UI events from the ViewModel (first production
milestone through Agent Product v1).
Date: 2026-10-05. Basis: end-of-M12 learner app (52 tests green).
Work area: `AI_HANDOFF/work/milestones/M13/` (full audit chain).

## What was built

| File | Change |
|------|--------|
| `lib/view_models/menu/menu_ui_event.dart` | NEW — `abstract class MenuUiEvent`; `final class MenuGameRequested`; `final class MenuSnackBarRequested(String message)` (plain classes; `sealed` is M15) |
| `lib/view_models/menu/menu_view_model.dart` | + `StreamController<MenuUiEvent>.broadcast()` `_events` + `events` getter; `requestGame()` emits `MenuGameRequested`; `resetProfile()` emits `MenuSnackBarRequested('Đã đặt lại hồ sơ.')` after `clear()`; `dispose()` closes controller |
| `lib/screens/menu_screen.dart` | `import 'dart:async'`; `_MenuScreenViewState` gains the bridge: `_viewModel`/`_eventSubscription`, `didChangeDependencies` → `_attachViewModel(context.read)` with `==` guard + cancel-before-replace, `_handleUiEvent` (`is`-checks; `unawaited(_openGame())` for nav; `ScaffoldMessenger.of(context).showSnackBar` for snackbars), `dispose` cancels. `_onPlayTap` now only `setState(count++)` + `requestGame()`; M10 push-and-await-result moved verbatim to `_openGame()` |
| `test/menu_view_model_test.dart` | +3 tests (M13 group): `requestGame` emits `MenuGameRequested`; `resetProfile` emits snackbar event with exact message; broadcast gives no replay to late listeners |
| `test/menu_ui_events_test.dart` | NEW — 2 widget tests: tap BẮT ĐẦU CHƠI → GameScreen pushed via event path; tap ĐẶT LẠI HỒ SƠ (ensureVisible) → SnackBar `'Đã đặt lại hồ sơ.'` |

## Behavioural contract

- CTA tap → VM event → bridge → `Navigator.push<GameResult>`; no
  widget-side navigation decision remains.
- `didChangeDependencies` re-entry with same VM → `==` guard returns;
  no duplicate subscription → no duplicate navigation.
- Reset always emits the snackbar event (event ≠ notify gating —
  compare-before-notify still governs `notifyListeners` only).
- Broadcast semantics: late listeners get nothing replayed.

## Senior evidence mirrored

- `menu_screen_ui_event.dart` — same event names/shape, minus `sealed`.
- `menu_screen_view_model.dart` — broadcast `_events`/`events`/
  `requestGame()`/`_events.close()` in dispose.
- `_MenuScreenEventBridgeState` (menu_screen.dart L40–76) — same three
  duties; learner keeps them inside `_MenuScreenViewState` rather than
  a dedicated wrapper widget (declared TEACHING_SIMPLIFICATION).
- `AppNavigationController.openGame()` NOT ported — deferred (D20);
  bridge calls `Navigator.push` directly.

## Deferred (named in lessons)

sealed+exhaustive switch → M15; repository/rxdart/BehaviorSubject →
M14; navigation controller → D20-later; game-side VM events → M19
(D22 scope decision); error event variants → later.

## Verification (post-remediation re-runs)

`flutter analyze` clean · `flutter test` 57/57 · `flutter build web`
pass · site `npm run build` 61 pages (m13: 4 routes).
Remediation loop: 2 FAIL→fix→PASS cycles, artifacts preserved in
`03-*`/`05-*`.
