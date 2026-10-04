# Android → Flutter Concept Map

For a learner strong in Kotlin/Jetpack Compose. Bridges are mapped to the
**senior app's actual usage**, with explicit warnings where the analogy
breaks down.

## UI model

| Android/Compose | Flutter (as used here) | Evidence / caveat |
|-----------------|------------------------|-------------------|
| `@Composable` function | `Widget` subclass with `build()` | Widgets are immutable config objects, not functions. `GameScreenBody`, `MenuProfileHeader`, etc. |
| stateless composable | `StatelessWidget` | e.g. `DesignFrame` (`widgets/common/design_frame.dart`) |
| `remember { mutableStateOf }` | `StatefulWidget` + `State` + `setState` | sparing: `MenuScreenView._dialogDismissLocked`, `wheel_picker.dart`. Most state lives in VMs, not widgets. |
| recomposition | widget rebuild via `build()` | triggered by `setState`, `context.watch`, `StreamBuilder` |
| `Column`/`Row`/`Box` | `Column`/`Row`/`Stack` (+`Positioned`) | direct analogues; menu screen = `Column` in a `Stack` over a background |
| `Modifier` | constructor params on widgets | **Dangerous analogy**: Flutter has no modifier chain; layout/styling params are per-widget. Padding is a `Padding` widget, not `.padding()`. |
| `Modifier.weight` | `Expanded`/`Flexible` | `Expanded(child: GameScreenBody(...))` |
| `LazyColumn` | `ListView` | `leaderboard_list.dart`, settings scroll |
| `Dp`/`Sp` units | logical pixels (`double`) | no unit wrappers; `AppTokens.spacingMd = 16` |
| `rememberCoroutineScope` + `LaunchedEffect` | `Future.delayed`, `Timer`, `initState`, VM methods | `bridge/game_screen_view_model_effects.dart` — **different**: effects are fired imperatively, no composition-scoped coroutines |
| `DisposableEffect`/lifecycle | `State.dispose`, `didChangeDependencies` | subscriptions cancelled in `dispose()`; deps re-read in `didChangeDependencies` (`_MenuScreenEventBridgeState`) |
| `LocalContext`/`CompositionLocal` | `BuildContext` + `InheritedWidget` (Provider wraps this) | `context.read<T>()` |
| `Dialog`/`AlertDialog` | in-`Stack` widget layer driven by state | **Dangerous**: senior app does NOT use `showDialog`; dialogs are state-driven overlay widgets (`MenuDialogLayer`, `GameDialogLayer`). Learner may start with `showDialog` then graduate. |
| `BackHandler`/`OnBackPressed` | `PopScope` + `onPopInvokedWithResult` | both screens |
| Animation: `animate*AsState`, `LaunchedEffect` transitions | `AnimatedSwitcher`, `AnimationController` + `TickerProviderStateMixin`, `CustomPainter` | dialog layers; `game_countdown_timer.dart` |

## State & architecture

| Android | Flutter (this app) | Notes |
|---------|--------------------|-------|
| `ViewModel` | `ChangeNotifier` ViewModels (`MenuScreenViewModel`, `SettingsViewModel`...) | **not identical**: no automatic lifecycle survival across config changes; scoped via `ChangeNotifierProvider(create:)`, disposed with the widget subtree. |
| `StateFlow` (hot, replay=1, `.value`) | `ChangeNotifier` + `context.watch`; rxdart `BehaviorSubject`/`ValueStream` in repositories | `userProfileStream.value` ≈ `stateFlow.value`; `.stream` ≈ collecting |
| `SharedFlow`/events channel (snackbar, nav) | `StreamController.broadcast` + `Stream` exposed as `events`/`uiEvents` | consumed by a `_EventBridge` `StatefulWidget` per screen/dialog scope |
| `MutableStateFlow.update` / reducer MVI | custom **DRE**: `dispatch(action) → reducer.reduce → state+effects+asyncOp` | `core/dre/`, `view_models/game/`; project-local, akin to a tiny MVI/Redux — closest Android analogue is a hand-rolled MVI store |
| Hilt / koin DI graph | manual constructor injection in `main()` + `Provider` tree | `AppDependencyScope` = service registry; **no** code-gen container |
| `Repository` pattern | same concept: `abstract interface class` + impl | identical shape: `UserProfileRepository` interface + `UserProfileRepositoryImpl` |
| Room / DataStore | `SharedPreferences` + JSON strings; Supabase Postgres | **Dangerous**: SharedPreferences stores plain strings; the app hand-serializes `toMap`/`jsonEncode`. No schema enforcement — defensive `fromMap` replaces it. |
| Retrofit + DTO | Supabase SDK query DSL + `fromMap` | `SupabaseLeaderboardRepository` maps `Map<String,dynamic>` → `_LeaderboardRecord` → `LeaderboardEntryData` |
| `WorkManager`/coroutines for sync | plain `async` method + in-flight guard | `UserProfileSyncRepositoryImpl._isSyncing` |
| Kotlin `data class` | immutable class + hand-rolled `copyWith`/`==`/`hashCode` | **Dangerous**: Dart has no data classes; equality must be written by hand (`UserProfileData`, ~30 lines of `==`) |
| `sealed class` + exhaustive `when` | `sealed class` + exhaustive `switch` | Dart 3 feature — maps 1:1; used pervasively (`GameDialogState`, `AuthSessionData`, `LeaderboardPopupState`) |
| `interface` | `abstract interface class` | Dart 3 class modifiers |
| Kotlin coroutines / suspend | `Future` + `async`/`await` | single-shot only; for streams use `Stream`/`await for` |
| `Flow` | `Stream` | `listen` ≈ `collect`; no cold/hot split teaching needed initially |
| `runBlocking`/test dispatchers | `fakeAsync`, `tester.pump(duration)` | widget tests pump virtual time |

## Navigation

| Android | Flutter (this app) |
|---------|--------------------|
| Navigation Compose / nav graph | **None** — manual `Navigator` |
| `navController.navigate("game")` | `AppNavigationController.openGame()` → `Navigator.push(MaterialPageRoute)` (`navigation/app_navigation_controller.dart`) |
| back stack / `popBackStack` | `Navigator.pop` via `goBack()` |
| deep links | none implemented |

Two pushed routes total (Menu→Game); all secondary UI is overlays. When the
course later needs more routes, named routes or `go_router` can be
introduced — but the senior app deliberately stays imperative.

## Build & tooling

| Android | Flutter |
|---------|---------|
| `build.gradle(.kts)` + dependencies | `pubspec.yaml` + `pub` |
| `minSdk`/`targetSdk`/`applicationId` | `android/app/build.gradle.kts` (familiar file exists!) + Dart SDK constraint `^3.12.1` |
| Gradle wrapper | `flutter` tool wraps platform builds; wrapper still exists for Android |
| `strings.xml` + locales | ARB files + gen-l10n (`l10n.yaml`, `AppLocalizations`) |
| `BuildConfig`-style config | `--dart-define` + `String.fromEnvironment` (`supabase_environment.dart`) |
| ProGuard/signing configs | signing via env vars in `build.gradle.kts` + vendored `scripts/kit` |
| JUnit + Espresso/Compose Test | `flutter_test`: `test()`/`testWidgets()` + `WidgetTester` |
| mockito/fakes | hand-written fakes (`test/helpers/`) — no codegen |

## Where Android intuition will mislead (danger list)

1. **"Widget = Composable"** is only half true: Flutter rebuilds create new
   widget objects; long-lived mutable state lives in `State`, VMs, and
   repositories — not in `remember`.
2. **No modifier chain** — styling is widget composition.
3. **No data class** — forgetting `==`/`hashCode` breaks the VM's
   "notify only if changed" logic (`_handleUserProfile` compares).
4. **Sealed-class switching without `when`** — same idea via `switch`;
   ensure exhaustiveness habits transfer.
5. **Context ≠ Android Context** — `BuildContext` is a position in the
   widget tree; `context.read` after `dispose` is a crash class the learner
   must respect (`_isDisposed` guards everywhere).
6. **Dialogs aren't routes/dialogs-fragment** — they're widgets rendered
   above a `Stack`; dismissing = state change, not `dismiss()` call.
7. **Async streams ≠ Flow collection scopes** — must cancel
   `StreamSubscription` manually; no structured concurrency.
8. **SharedPreferences ≠ DataStore-typed** — stringly-typed; validation is
   manual.
9. **No viewModelScope** — timers/subscriptions are owned and disposed
   manually in the VM (`dispose()`), which is itself tied to the Provider.
10. **pubspec `environment.sdk` ≠ compileSdk** — Dart language version
    gating works differently.
