# M10–M12 Implementation Notes

Step 06 — Local persistence, ChangeNotifier, Provider DI.
Date: 2026-10-05. Basis: end-of-M09 learner app (29 tests green).

This file records **what was actually built** for M10–M12, the senior
evidence it mirrors, and the deliberate deviations. It is the durable
handoff for the next step (M13+); do not rely on chat history.

## M10 — Local persistence (SharedPreferences & JSON)

### New/changed learner files

| File | Change |
|------|--------|
| `pubspec.yaml` | + `shared_preferences: ^2.5.5` |
| `lib/data/game/game_result.dart` | NEW — `GameResult{questionsAnswered, correctAnswers, won}` const model with `==`/`hashCode`/`toString` |
| `lib/data/profile/user_profile_data.dart` | + `toMap`, defensive `fromMap` (`_intValue`/`_stringValue` guards + `const defaults`), `applyGameResult`, `moneyPerCorrectAnswer`/`expPerCorrectAnswer` consts |
| `lib/data/profile/profile_store.dart` | NEW — concrete `ProfileStore(SharedPreferences)` with `load`/`save`/`clear` over key `'user_profile'` |
| `lib/main.dart` | `await SharedPreferences.getInstance()` → `ProfileStore` → constructor-threaded into `AIMillionaireApp`/`MenuScreen` |
| `lib/screens/game_screen.dart` | `_answeredCount` field (+reset in `_restart`); `_finish` builds `GameResult`; `_showResultDialog` → `await showDialog<_ResultAction>` → `playAgain: _restart()` / `backToMenu: Navigator.pop(result)` |
| `lib/screens/menu_screen.dart` | `profileStore` ctor param; `_loadProfile` reads store; `_onPlayTap` awaits `push<GameResult>` → `applyGameResult` → `await save`; `_resetProfile` (`clear` + defaults); `_MenuBody` gets `onReset` + `_ResetButton` pill; body Column wrapped in `SingleChildScrollView` |
| `test/profile_store_test.dart` | NEW — 6 tests: empty→defaults, round-trip via second store, corrupt JSON, non-Map JSON, partial map, `clear` |
| `test/user_profile_data_test.dart` | +8 tests: toMap/fromMap round-trip, missing/wrong-typed/double fields, nullable avatarUrl, `applyGameResult` won/lost/level-up/immutability |
| `test/widgets/game_screen_test.dart` | `menuApp()` helper (`setMockInitialValues` + `ProfileStore`); back-button test asserts no prefs write; VỀ MENU test asserts UI `'1'`/`'0%'` + disk `"gamesJoined":1` |

### Behavioural contract

- One `push<GameResult>` completes once → `applyGameResult` runs once.
- Back button (pop without result) → `null` → nothing applied/persisted.
- Corrupt/missing/partial JSON → `const UserProfileData()` fallback.
- Reset clears the key (`remove`), not writes an empty object.

### Senior evidence

- `repositories/profile/user_profile_repository.dart` — same key, same
  `jsonEncode(toMap())` / guarded `jsonDecode` pipeline, same
  `StateError` on failed `setString`.
- `data/profile/user_profile_data.dart` — `_intValue(map[k], fallback)`
  helper is the same defensive idiom senior uses.
- `view_models/game/bridge/game_screen_view_model_result_persistence.dart` —
  `_saveGameResult` = load → apply policy → save; our menu does the same
  three steps with the policy on the model.

## M11 — ChangeNotifier & ListenableBuilder

### New/changed learner files

| File | Change |
|------|--------|
| `lib/view_models/menu/menu_view_model.dart` | NEW — `MenuViewModel extends ChangeNotifier` + `MenuLoadState {loading, ready, failed}` enum |
| `lib/screens/menu_screen.dart` | `_profile`/`_profileLoadFuture`/`_loadProfile`/`_retryLoadProfile`/`_resetProfile` removed; `late final MenuViewModel _viewModel` created in `initState` + `unawaited(load())`, disposed in `dispose`; `FutureBuilder` → `ListenableBuilder` + `switch` expression on `loadState` |
| `test/menu_view_model_test.dart` | NEW — 7 tests incl. notify-count assertions and `_BrokenStore` subclass double |

### Boundary (what moved, what stayed)

- VM: `profile`, `loadState`, `load()`, `applyGameResult()`, `resetProfile()`.
- State (ephemeral, stays): `_soundOn`, `_playTapCount`, `_sessionTicker`,
  `_onPlayTap` (navigation needs context), `_toggleSound`.
- `_setLoadState` guards no-op notifies; `resetProfile` notifies only on
  real change (senior's compare-before-notify).

## M12 — Provider & dependency scope

### New/changed learner files

| File | Change |
|------|--------|
| `pubspec.yaml` | + `provider: ^6.1.5+1` (same major as senior) |
| `lib/core/app_dependency_scope.dart` | NEW — `AppDependencyScope` StatelessWidget → `Provider<ProfileStore>.value` |
| `lib/main.dart` | `runApp(AppDependencyScope(profileStore:…, child: AIMillionaireApp()))`; app widget back to `const`, `home: const MenuScreen()` |
| `lib/screens/menu_screen.dart` | `MenuScreen` → `StatelessWidget` with `ChangeNotifierProvider(create: (c) => MenuViewModel(store: c.read<ProfileStore>())..load())`; inner `_MenuScreenView` StatefulWidget: `context.watch` in build, `context.read` in `_onPlayTap`; `dart:async`/`unawaited` import removed |
| `test/menu_provider_scope_test.dart` | NEW — end-to-end scope test (seeded prefs → rendered) + provider auto-dispose test (`addListener` on disposed VM throws `FlutterError`) |
| `test/widgets/game_screen_test.dart` | `menuApp()` now wraps `AppDependencyScope` |

### Deliberate omissions (vs senior scope)

- No `MultiProvider` (one dependency only — roadmap's mention of
  settings/nav-controller is aspirational; they don't exist yet → no stubs).
- No `AppNavigationController` (single push/pop pair; senior's controller
  serves deeplinks/dialog infra the learner app lacks).
- `GameScreen` NOT Provider-ized — stays `setState` until M19.

## Website

- New dirs: `web/src/content/docs/m10/` (5 files: index + 4 lessons),
  `m11/` (4 files), `m12/` (4 files).
- `astro.config.mjs`: M10 added to Phase C group; new Phase D group with
  M11 + M12.
- `roadmap.md`: M10/M11/M12 → `AVAILABLE`.

## Test totals

| Point | Tests |
|-------|-------|
| End of M09 | 29 |
| End of M10 | 43 (+6 store, +8 model) |
| End of M11 | 50 (+7 VM) |
| End of M12 | 52 (+2 scope/lifecycle) |

## Verification log

- `flutter pub get` ✓ (shared_preferences 2.5.5, provider 6.1.5+1)
- `flutter analyze` — no issues at every gate
- `flutter test` — 52/52 pass at M12
- `flutter build web --release` — pass at every gate
- `npm run build` (website) — 57 pages, pass (known pagefind/sitemap
  warnings only)

## Known deviations from senior

- Flat reward constants instead of money ladder (M20/M22 territory).
- Menu applies results via route-result instead of game-side repository
  call — correct at this scale; M12/M14 move storage access closer to
  senior's shape (VM already holds the store; a repository + stream will
  replace it in M14).
- `_MenuScreenView` is private inside the screen file; senior extracts
  `MenuScreenView` to `widgets/menu/`. Deferred — no second consumer.
- No `MenuScreenUiEvent` stream (M13), no sealed states (M15).
