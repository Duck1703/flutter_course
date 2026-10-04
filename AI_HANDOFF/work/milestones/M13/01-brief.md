# MILESTONE BRIEF — M13: One-shot UI events from the VM

> Produced by: Atlas (`atlas-flutter-course-architect`)
> Basis: `project-context/MILESTONE_ROADMAP.md` M13 section +
> `CURRENT_STATE.md` (end-of-M12) + `DECISIONS.md` D20
> State on creation: `BRIEF_READY`

---

## 1. Scope (hard boundaries)

**This milestone does only:** add a broadcast `StreamController` UI-event
channel to `MenuViewModel`; consume its events through an event-bridge
`State` on `_MenuScreenView` (`didChangeDependencies` subscribe,
`dispose` cancel); route play-CTA navigation and reset confirmation
snackbar through events instead of direct widget calls.

**This milestone does not do:**
- sealed event classes (M15 owns `sealed` — M13 uses plain classes)
- a game-screen ViewModel or game-side events (see §5)
- `AppNavigationController` (still deferred — D20; events call
  `Navigator.push` directly inside the bridge)
- repository contracts / `ValueStream` / rxdart (M14)
- any change to `GameScreen`, persistence schema, or app scope shape

**Absolutely forbidden:**
- `sealed class`, `rxdart`, `BehaviorSubject`, `abstract interface class`,
  `ProxyProvider`, `MultiProvider`, `context.select`
- inventing senior features not in the cited evidence
- touching files outside the allow-list

**Write allow-list (Flux):**
`learner-app/lib/view_models/menu/` (+ new `menu_ui_event.dart`),
`learner-app/lib/screens/menu_screen.dart`,
`learner-app/test/menu_view_model_test.dart`,
`learner-app/test/menu_provider_scope_test.dart` (or a new
`test/` file if cleaner).

## 2. Roadmap contract

| Field | Value |
|-------|-------|
| Learner outcome | rebuild-state vs fire-event split; broadcast event channel on a VM; event consumption in a bridge `State` |
| Visible project result | CTA navigates via VM event (not direct call); reset produces a SnackBar via VM event; no double-navigation on re-subscription |
| Prerequisites | M06 (streams) ✓ taught; M12 (Provider) ✓ shipped |
| Dart introduced | plain event classes (`MenuGameRequested {}`), `StreamController.broadcast`, `StreamSubscription` in `State`, event-carrying class with field (`message`) |
| Flutter introduced | event-bridge pattern (`didChangeDependencies` subscribe / `dispose` cancel / re-subscribe guard), `ScaffoldMessenger` from events |
| Test targets | VM test: method → event emitted; widget test: tap → SnackBar; tap CTA → game pushed via event path |
| Completion criteria | CTA navigates via VM event; emitted snackbar event shows a SnackBar; no duplicate navigation on re-subscription |

## 3. Starting state (verified from disk — end of M12)

- `menu_view_model.dart`: `ChangeNotifier`, `loadState`/`profile`,
  `load()`/`applyGameResult()`/`resetProfile()`, no event channel.
- `menu_screen.dart`: `MenuScreen` = StatelessWidget owning
  `ChangeNotifierProvider(create: …read<ProfileStore>()..load())`;
  `_MenuScreenView` StatefulWidget holds `_soundOn`, `_playTapCount`,
  `_sessionTicker`; `_onPlayTap` does `push<GameResult>` + apply + save
  **directly**; `_ResetButton` → `viewModel.resetProfile` (silent).
- 52 tests green; analyze clean.

## 4. Senior evidence to inspect

| Topic | Path + symbol | What to verify |
|-------|---------------|----------------|
| Event class family | `lib/view_models/menu/menu_screen_ui_event.dart` — `sealed class MenuScreenUiEvent`, `MenuGameRequested`, `MenuSnackBarRequested` | shape; learner drops `sealed` (M15) |
| VM channel | `lib/view_models/menu/menu_screen_view_model.dart` — `_events` field, `events` getter, `requestGame()`, `_events.close()` | broadcast ctor, add-on-intent, close-in-dispose |
| Bridge | `lib/screens/menu_screen.dart` — `_MenuScreenEventBridgeState`: `didChangeDependencies` read, `_attachMenuViewModel` re-subscribe guard, `StreamSubscription`, `_handleUiEvent` switch, `dispose` cancel | exact lifecycle ordering |
| Navigation | `AppNavigationController.openGame()` | senior routes nav through controller; learner defers controller → bridge calls `Navigator.push` directly (recorded simplification) |

**Known unknowns (must not be invented):** senior's snackbar message
content, senior's navigation controller internals beyond `openGame()`.

## 5. Simplification guidance

| Senior approach | Learner approach | Label |
|-----------------|------------------|-------|
| `sealed class MenuScreenUiEvent` + exhaustive switch | `abstract class MenuUiEvent` + `is`-checks | `TEACHING_SIMPLIFICATION` → sealed returns M15 |
| `AppNavigationController.openGame()` | bridge calls `Navigator.push<GameResult>` directly (reuses the M10 route-result flow) | `TEACHING_SIMPLIFICATION` → controller not yet introduced |
| Roadmap line "game VM navigate-back event" | **out of M13 scope** — no `GameViewModel` exists (D20 keeps GameScreen setState until M19); creating a one-event VM is premature structure. Completion criteria are all menu-side, so intent is preserved | `DEFERRED` → M19 (Atlas scope decision, documented) |
| Snackbar events for errors etc. | one concrete snackbar event on successful reset (`MenuSnackBarRequested('Đã đặt lại hồ sơ')`) — minimal real consumer | `TEACHING_SIMPLIFICATION` |

## 6. Lesson-count guidance

3 lessons + overview (matches M11/M12 cadence):
1. Why events ≠ state; broadcast controller + event classes on the VM.
2. The bridge `State`: subscribe in `didChangeDependencies`, guard
   re-subscription, cancel in `dispose`, handle events.
3. Snackbar event + VM/widget tests proving the contract.

Lumen owns final decomposition.

## 7. Done criteria (stage 2 exit)

- [ ] `flutter analyze` clean
- [ ] `flutter test` green; new coverage: VM emits `MenuGameRequested`
      on `requestGame()`; `MenuSnackBarRequested` on `resetProfile()`;
      widget tap → SnackBar visible; tap CTA → GameScreen pushed
- [ ] `flutter build web` passes
- [ ] `02-implementation-evidence.md` complete per contract
- [ ] Completion criteria demonstrable: CTA→event→navigate;
      reset→event→SnackBar; single subscription (no double-nav)

## 8. Next step

```text
NEXT STEP (INTERNAL)
  Who: Flux
  Input: this brief + STATE: BRIEF_READY
  Output: learner-app changes + 02-implementation-evidence.md
```
