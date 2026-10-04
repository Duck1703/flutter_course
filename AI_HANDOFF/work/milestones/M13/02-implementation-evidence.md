# IMPLEMENTATION EVIDENCE — M13: One-shot UI events from the VM

> Produced by: Flux (`flux-flutter-implementation-engineer`)
> Contract: `../../contracts/IMPLEMENTATION-HANDOFF-CONTRACT.md`
> Revision: r2 — remediates QA-IMPL-001 (`unawaited` now introduced
> at the discard site in `_handleUiEvent`)
> State on submission: `IMPLEMENTATION_QA` (awaiting Argus)

## 1. Milestone & scope

- Milestone: M13 — One-shot UI events from the VM
- Brief: `01-brief.md` r1
- Scope consumed: broadcast `StreamController` UI-event channel on
  `MenuViewModel`; event-bridge `State` on `_MenuScreenView`
  (`didChangeDependencies` subscribe / re-subscribe guard / `dispose`
  cancel); play-CTA navigation and reset-confirmation SnackBar routed
  through events instead of direct widget calls. All within the
  write allow-list.

## 2. Starting learner state (verified from disk)

- `menu_view_model.dart`: `ChangeNotifier` with `loadState`/`profile`,
  `load()`/`applyGameResult()`/`resetProfile()`; no event channel.
- `menu_screen.dart`: `MenuScreen` StatelessWidget owning
  `ChangeNotifierProvider`; `_MenuScreenView` StatefulWidget holding
  `_soundOn`, `_playTapCount`, `_sessionTicker`; `_onPlayTap` did
  `Navigator.push<GameResult>` + `applyGameResult` **directly**;
  reset button called `viewModel.resetProfile` with no UI feedback.
- 52 tests green; analyze clean (Step 06 baseline).

## 3. Target learner state

- `menu_ui_event.dart` (new): `abstract class MenuUiEvent`,
  `MenuGameRequested`, `MenuSnackBarRequested(String message)` —
  plain classes, intentionally not sealed.
- `menu_view_model.dart`: owns
  `StreamController<MenuUiEvent>.broadcast()` exposed as `events`;
  `requestGame()` adds `MenuGameRequested`; `resetProfile()` adds
  `MenuSnackBarRequested('Đã đặt lại hồ sơ.')` after `clear()`;
  `dispose()` closes the controller.
- `menu_screen.dart`: `_MenuScreenViewState` gains the bridge —
  `_viewModel`/`_eventSubscription` fields, `didChangeDependencies`
  → `_attachViewModel(context.read<MenuViewModel>())` with
  identity guard + cancel-before-replace, `_handleUiEvent` (`is`-checks:
  `MenuGameRequested` → `_openGame()`, `MenuSnackBarRequested` →
  `ScaffoldMessenger.of(context).showSnackBar(...)`), `dispose()` cancels.
  `_onPlayTap` now: `setState(count++)` + `context.read<MenuViewModel>()
  .requestGame()`; the M10 push-and-await-result flow moved unchanged
  into `_openGame()`.

## 4. Senior evidence used

| Topic | Path + symbol | Evidence class | What it supports |
|-------|---------------|----------------|------------------|
| Event class family | `flutter-accelerator-ai/lib/view_models/menu/menu_screen_ui_event.dart` — `sealed class MenuScreenUiEvent`, `MenuGameRequested`, `MenuSnackBarRequested(message)` | DIRECT_EVIDENCE | same event names/shape; learner drops `sealed` per brief |
| VM channel | `flutter-accelerator-ai/lib/view_models/menu/menu_screen_view_model.dart` — `_events`, `events`, `requestGame()`, `dispose` close | DIRECT_EVIDENCE | broadcast controller, add-on-intent, close-in-dispose |
| Bridge lifecycle | `flutter-accelerator-ai/lib/screens/menu_screen.dart` — `_MenuScreenEventBridgeState`: `didChangeDependencies`, `_attachMenuViewModel` guard, `StreamSubscription`, `_handleUiEvent`, `dispose` cancel | DIRECT_EVIDENCE | subscribe site, re-subscribe guard, cancel ordering |
| Navigation | senior routes via `AppNavigationController.openGame()` | DIRECT_EVIDENCE | nav is event-driven in senior; controller itself deferred (see §7) |

## 5. Files changed

| Path | New/Modified | Purpose |
|------|--------------|---------|
| `learner-app/lib/view_models/menu/menu_ui_event.dart` | new | plain event classes |
| `learner-app/lib/view_models/menu/menu_view_model.dart` | modified | broadcast channel, `requestGame()`, snackbar emit on reset, close in dispose |
| `learner-app/lib/screens/menu_screen.dart` | modified | event bridge lifecycle; `_onPlayTap` → `requestGame()`; `_openGame()` holds the M10 push flow |
| `learner-app/test/menu_view_model_test.dart` | modified | +3 M13 event tests |
| `learner-app/test/menu_ui_events_test.dart` | new | 2 widget tests (tap→navigate, tap→SnackBar) |

## 6. Concepts introduced (in learner code)

| Concept | First course appearance? | Where it appears |
|---------|--------------------------|------------------|
| `StreamController<T>.broadcast()` | YES | `menu_view_model.dart` |
| `StreamSubscription<T>` field + `.cancel()` | YES | `menu_screen.dart` |
| `didChangeDependencies` used for provider-read subscription | YES (M11 used initState + context.read which Provider allows for read-only) | `menu_screen.dart` |
| Plain event classes w/ `abstract`/`final` modifiers | YES (first `abstract`/`final class` usage in learner code) | `menu_ui_event.dart` |
| Event carrying a payload field (`message`) | YES | `menu_ui_event.dart` |
| `ScaffoldMessenger.of(context).showSnackBar` | YES | `menu_screen.dart` |
| `is`-check event dispatch | YES | `menu_screen.dart` |
| `unawaited` (explicit Future discard in a sync listener) | YES (r2 — added per QA-IMPL-001) | `menu_screen.dart` `_handleUiEvent` |

## 7. Deliberate simplifications

| Senior approach | Learner approach | Returns in |
|-----------------|------------------|------------|
| `sealed class MenuScreenUiEvent` + exhaustive switch | `abstract class MenuUiEvent` + `is`-checks | `TEACHING_SIMPLIFICATION` → sealed arrives M15 |
| `AppNavigationController.openGame()` | bridge calls `Navigator.push<GameResult>` directly (reuses M10 route-result flow) | `TEACHING_SIMPLIFICATION` → nav controller deferred (D20) |
| Roadmap line "game VM navigate-back event" | out of M13 scope — no GameViewModel exists (D20); recorded in brief §5 | `DEFERRED` → M19 |
| Multiple snackbar/effect event consumers | one concrete snackbar event on successful reset | `TEACHING_SIMPLIFICATION` |
| Event bridge as separate `_MenuScreenEventBridge` wrapper widget | bridge lifecycle lives inside `_MenuScreenViewState` (the State already exists; same three duties, one less widget layer for a beginner) | `TEACHING_SIMPLIFICATION` — structural equivalent, named so in code comments |

## 8. Deferred concepts

`sealed`/`final`-on-base hierarchies (M15), `AppNavigationController`
(D20/M-later), `rxdart`/`BehaviorSubject`/`ValueStream` (M14),
repository contracts (M14), game-screen VM/events (M19), DRE effect
channels, `context.select`, `MultiProvider`/`ProxyProvider`.

## 9. Tests added/changed

| File | Tests | Proves |
|------|-------|--------|
| `test/menu_view_model_test.dart` (M13 group) | 3 | `requestGame()` emits `MenuGameRequested`; `resetProfile()` emits `MenuSnackBarRequested` with exact message; broadcast stream gives no replay to late listeners |
| `test/menu_ui_events_test.dart` | 2 | tap BẮT ĐẦU CHƠI → GameScreen pushed (event→bridge→Navigator path — no direct widget nav remains in `_onPlayTap`); tap ĐẶT LẠI HỒ SƠ → SnackBar `'Đã đặt lại hồ sơ.'` visible |

No-duplicate-navigation is enforced structurally by the `==` guard in
`_attachViewModel` (re-entry of `didChangeDependencies` with the same VM
does not create a second subscription), and indirectly by test 1:
a second subscription would double-push the route.

## 10. Verification commands + results

```text
$ flutter pub get     → Got dependencies! (9 packages have newer
                        versions incompatible with constraints —
                        pre-existing, unchanged)              [VERIFIED]
$ flutter analyze     → No issues found! (2.0s r1; 2.2s r2)   [VERIFIED]
$ flutter test        → 57/57 passed (52 baseline + 5 new)    [VERIFIED]
$ flutter build web   → √ Built build\web (44.9s; wasm dry-run
                        ok; cupertino_icons font note is
                        pre-existing)                          [VERIFIED]

r2 re-run after QA-IMPL-001 remediation (`unawaited` added):
analyze clean, 57/57 still green.
```

First test run failed 2/57 — a real iteration, recorded honestly:
- broadcast test used a `timeout()` wrapper that closed the
  subscription before the second emit → rewrote to a direct
  `listen` + delayed count.
- SnackBar test tapped an offscreen reset button (hit-test miss)
  → added `ensureVisible` before tap.
Both fixes verified green on rerun (57/57).

## 11. Known limitations

- Broadcast events emitted with no listener are lost — correct
  semantics, now taught; any future event needing guaranteed delivery
  is not a broadcast event.
- Bridge lives inside `_MenuScreenViewState` rather than a dedicated
  wrapper widget — functionally identical, one less class.
- SnackBar uses default styling/duration; the course has no design
  token for it yet (senior does have richer snackbar plumbing —
  not ported).
- `ScaffoldMessenger.of(context)` resolves via the app-level
  messenger (ancestor `MaterialApp`), not a local Scaffold — fine
  here, worth noting if nested scaffolds arrive later.
- Visual/manual run of the menu on a device: NOT performed by Flux
  (no emulator run in this environment); widget tests + web build
  are the executed verification.

## 12. Code snapshot notes

The diff story for the lesson: `_onPlayTap` shrinks to "report the
intent" (`requestGame()`); the navigation code moves verbatim into
`_openGame()` and gains a new caller — the bridge. `resetProfile`
gains one line (`_events.add`). New file `menu_ui_event.dart` is the
milestone's whole vocabulary. Everything else — provider scope, M10
save/load, ticker — untouched.

## 13. Content-author guidance (for Lumen)

- First appearances needing full explanation: `StreamController.broadcast`
  (why broadcast, what "no replay" means), `StreamSubscription` +
  cancel (manual lifecycle vs Compose's auto-scoping),
  `didChangeDependencies` as the subscribe site (why not initState:
  `context.read` needs inherited widgets), event-vs-state mental model.
- Suggested lesson split (guidance only): L1 events≠state + event
  classes + controller on VM; L2 the bridge lifecycle (subscribe /
  guard / cancel / handle); L3 snackbar event + tests as proof.
- Bridge opportunities: `SharedFlow`/`Channel` + `LaunchedEffect` →
  broadcast stream + bridge `State`; the manual `cancel()` ≈ lifecycle
  scope Compose gives for free; `abstract`+`is` ≈ Kotlin `is` checks,
  sealed arrives M15.
- Traps to warn about: subscribing in `initState` (context not ready);
  forgetting `dispose` cancel (leak); subscribing without the identity
  guard (double navigation); treating events as replayable state;
  reaching for `Navigator` inside the VM (no context there).
- Snippets that must match disk exactly: `menu_ui_event.dart` (entire
  file is tiny — safe to quote whole), the `_events` field + `events`
  getter + `requestGame()` + `dispose` block, the bridge block
  (`_attachViewModel`/`_handleUiEvent`/`didChangeDependencies`/`dispose`),
  `_onPlayTap` + `_openGame`.
