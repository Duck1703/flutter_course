# Milestone Roadmap

Progressive reconstruction path for the senior app. Count was derived from
the audited dependency graph (`DEPENDENCY_GRAPH.md`), feature inventory
(`FEATURE_INVENTORY.md`), and beginner gaps (`FLUTTER_BEGINNER_GAPS.md`) —
not chosen in advance.

## How the count was derived

Rule: **one coherent learning/building achievement per milestone** and no
milestone may require an untaught concept. Applying that to the senior app
produced:

- 3 orientation milestones (Flutter mental model, layout, local state) —
  nothing else can start without them.
- 4 foundation milestones (models, Future, Stream, navigation) — the async
  trio is split because `Future`, `Stream`, and imperative navigation are
  three distinct mental-model jumps.
- 3 local-loop milestones (quiz mechanics, full session, persistence).
- 3 state-architecture milestones (ChangeNotifier → Provider → UI events) —
  deliberately separated so each motivation is felt.
- 5 richer-local-app milestones (repositories/streams, sealed-state UI,
  settings, localization, onboarding).
- 10 senior-depth milestones (structured game VM, lifelines, senior dialog
  layer, progression, Supabase read, auth, sync, DRE, platform extras,
  polish).
- 1 alignment milestone (senior parity + appendices).

Total: **29 milestones (M01–M29)** across Phases A–G.

## Testing progression (horizontal lane)

| Stage | Introduced at | Learner can |
|-------|---------------|-------------|
| `test()` pure Dart | M04 | test model/format logic |
| `testWidgets` basics | M08 | pump, find, tap, expect |
| Fake repositories + VM tests | M14 | test VM without Flutter UI |
| `pump(duration)` virtual time | M19 | test timers/delays |
| Contract/staleness tests | M23–M26 | request-id guards, reducer unit tests |
| Suite hygiene | M29 | organized `test/helpers/` parity |

## Phase A — Orientation

### M01 — Flutter orientation & first run

**Learner outcome:** Explain a Flutter project's anatomy (`pubspec.yaml`,
`lib/main.dart`, platform folders), run the app on a device/emulator, use
hot reload, and describe the widget tree in plain terms.

**Visible project result:** Learner project created; runs a custom first
screen ("AI Millionaire" title + styled text) on a real/emulated device;
hot-reload demonstrated live.

**Prerequisites:** none.

**Dart introduced:** `main()`, `void`, top-level functions, `class` +
`extends`, constructor + `super.key`, `const` constructors, named
parameters, `@override`, `import`.

**Flutter introduced:** `runApp`, `WidgetsFlutterBinding` (mentioned),
`MaterialApp`, `Scaffold`, `StatelessWidget`, `build(BuildContext)`,
`Text`, `TextStyle`, `Colors`, `Center`, hot reload vs restart,
`flutter pub get`/`analyze`/`run`.

**Concepts reinforced:** none (first milestone).

**Android/Compose bridge:**
- SIMILARITY: `runApp(MyApp())` ≈ Activity `setContent { App() }`;
  `StatelessWidget` ≈ stateless composable; hot reload ≈ Compose preview/
  live edit but for the real running app.
- IMPORTANT DIFFERENCE: widgets are immutable configuration objects
  recreated on rebuild — not composable functions with remembered state.
- DO NOT ASSUME: `MaterialApp` is required for everything; it is the app
  shell, not the whole framework.

**Senior source evidence:** `lib/main.dart` (`runApp`,
`MaterialApp`, `home: MenuScreen`), `pubspec.yaml` (deps, `generate: true`,
assets), `.metadata` (Flutter stable pin).

**Learner implementation scope:** `flutter create`, trim to a minimal
`main()` + one `StatelessWidget` screen; run, edit text, hot reload.

**Intentionally excluded:** Supabase env/dart-defines, repositories,
`Provider`, orientation lock, localization — all wired later; `main()`
starts synchronous.

**Testing/checkpoint:** `flutter analyze` clean; `flutter run` succeeds;
manual: text visible, hot reload applies edit.

**Completion criteria:**
- App runs on a device/emulator showing the custom screen.
- Learner changes a string and sees it update via hot reload.
- `flutter analyze` reports no issues.

**Leads to:** M02 — a running shell ready to host real layout.

---

### M02 — Widget composition & static layout

**Learner outcome:** Compose complex static UI from basic widgets and
explain the layout constraint flow (constraints down, sizes up) at a
beginner level.

**Visible project result:** A static replica of the senior menu screen
look: background color/image, profile header row, stats cards, earnings
area, leaderboard entry, big gradient CTA button — all hardcoded values,
no behavior.

**Prerequisites:** M01.

**Dart introduced:** `List<Widget>` collection literals, string
interpolation `'$var'`, `double` literals, `final` local variables,
cascade-free composition, private widgets `_Foo`, positional vs named
params.

**Flutter introduced:** `Column`, `Row`, `Stack`, `Positioned`,
`Positioned.fill`, `SafeArea`, `Expanded`, `Padding`/`EdgeInsets`,
`SizedBox`, `Container`, `BoxDecoration` (color, borderRadius, gradient),
`Image.asset`, `Icon`, `Spacer`, `ConstrainedBox`; `MediaQuery` awareness;
asset declaration in `pubspec.yaml`.

**Concepts reinforced:** widget immutability, `const` usage, `build`.

**Android/Compose bridge:**
- SIMILARITY: `Column`/`Row`/`Stack` ≈ `Column`/`Row`/`Box`; `Expanded`
  ≈ `Modifier.weight`; `EdgeInsets` ≈ padding modifiers.
- IMPORTANT DIFFERENCE: there is no `Modifier` chain — padding, size,
  decoration are separate widgets or per-widget parameters; order matters.
- DO NOT ASSUME: widgets size like Android Views — a `Text` doesn't take
  `match_parent` by default; constraints come from the parent.

**Senior source evidence:** `lib/widgets/menu/menu_screen_view.dart`
(Stack + Column layout), `lib/widgets/common/design_frame.dart` (375 px
`ConstrainedBox`), `lib/core/app_design_tokens.dart` (spacing/color
tokens), `lib/core/app_assets.dart` (asset paths), `pubspec.yaml` assets
section, `lib/widgets/menu/profile/` cards.

**Learner implementation scope:** static menu UI only; introduce a
`MenuTokens`-lite constants file and a few private layout widgets; PNG
placeholders or pure-color substitutes allowed (senior art assets may be
referenced as design intent but learner draws simplified versions).

**Intentionally excluded:** real senior assets/SVG set, `flutter_svg`,
`google_fonts`, gradients/glow polish (M28), scrolling edge cases,
`FittedBox`/responsive tuning beyond the design frame.

**Testing/checkpoint:** visual parity with a reference screenshot region;
`flutter analyze` clean.

**Completion criteria:**
- Menu renders all sections statically without overflow warnings.
- Layout uses `DesignFrame`-like max-width wrapper.
- Learner can explain why `Expanded` was needed where used.

**Leads to:** M03 — a static UI ready to become interactive.

---

### M03 — Interactivity: StatefulWidget & setState

**Learner outcome:** Explain the Widget/State split, use `setState` to
mutate local UI state, and describe the State lifecycle
(`initState`/`dispose`/`didUpdateWidget` at intro level).

**Visible project result:** The CTA button responds to taps (tap counter
or pressed state shown); a settings-like icon toggles a visible indicator;
counter survives hot reload (state vs widget discussion).

**Prerequisites:** M02.

**Dart introduced:** closures/lambdas `() { }`, `() => expr`, `typedef`-free
callbacks, `void Function()`, `++`/assignment ops, `is`/`as` casts (light).

**Flutter introduced:** `StatefulWidget`, `createState()`, `State`,
`setState`, `initState`, `dispose`, `mounted`, `VoidCallback`,
`GestureDetector`, `InkWell`, `Material` ink response; why `build` re-runs.

**Concepts reinforced:** composition, const constructors, keys (mentioned).

**Android/Compose bridge:**
- SIMILARITY: `setState` ≈ `mutableStateOf` + `remember`; rebuild ≈
  recomposition of affected subtree.
- IMPORTANT DIFFERENCE: `State` object lives beside the widget and can be
  disposed; `remember` has no direct equivalent — state lives in `State`
  fields; `setState` must wrap mutations.
- DO NOT ASSUME: mutating a field rebuilds UI — without `setState` nothing
  repaints; and `setState` after `dispose` crashes.

**Senior source evidence:** sparing real `setState` usage —
`lib/widgets/menu/menu_screen_view.dart` (`_dialogDismissLocked`),
`lib/widgets/menu/settings/wheel_picker.dart`; State lifecycle in
`_MenuScreenEventBridgeState` (`lib/screens/menu_screen.dart`).

**Learner implementation scope:** convert CTA and one more control to
interactive `StatefulWidget`s; a counter display; a toggle.

**Intentionally excluded:** Provider/ChangeNotifier (felt absence becomes
motivation in M11), animations of the press, persistence.

**Testing/checkpoint:** manual tap behavior; discussion: why does state
survive hot reload.

**Completion criteria:**
- Tapping CTA visibly changes the screen.
- Toggle flips state both directions.
- Learner explains why `setState` is required.

**Leads to:** M04 — need structured data instead of loose fields.

---

## Phase B — Small application foundation

### M04 — Immutable data models & first unit test

**Learner outcome:** Write a Dart model class with `final` fields, named
parameters, `copyWith`, `toString`, and basic `==`/`hashCode`; render UI
from a model; write the first `flutter test` unit test.

**Visible project result:** Menu header/cards render from a
`UserProfileData`-style object (name, level, money won, games counts);
changing the model updates the UI via `setState`.

**Prerequisites:** M03.

**Dart introduced:** `final` fields, `required` named params, `copyWith`
pattern, `??` and `?.` (null safety deep-dive: nullable types, `!`,
`late`), `toString`, `==`/`hashCode` overrides, `static const` defaults,
factory constructors (intro).

**Flutter introduced:** passing models via constructor params; separation
"data object vs widget".

**Concepts reinforced:** `setState` now mutating via `copyWith`.

**Android/Compose bridge:**
- SIMILARITY: model ≈ Kotlin `data class`; `copyWith` ≈ `copy()`;
  nullability `?` maps directly.
- IMPORTANT DIFFERENCE: no compiler-generated `copy`/`equals`/`hashCode` —
  hand-written or future codegen; forgetting `==` silently breaks
  value comparisons later (streams rely on it).
- DO NOT ASSUME: `late` is a safe default — it's a promise you must keep.

**Senior source evidence:** `lib/data/profile/user_profile_data.dart`
(defaults, `copyWith`, `==`/`hashCode`, `formatVnd`/`formatThousands`),
`lib/data/settings/user_settings_data.dart`, `lib/data/game/*` models.

**Learner implementation scope:** `UserProfileData`-lite model + render +
one `test/` file with 2–3 `test()` cases (`copyWith`, equality, format).

**Intentionally excluded:** `toMap`/`fromMap` JSON (M10), `formatVnd`
locale specifics (can add simplified version), sealed classes.

**Testing/checkpoint:** first `flutter test` run green; test verifies
copyWith/equality.

**Completion criteria:**
- Menu renders entirely from the model object.
- A `setState` update via `copyWith` visibly changes values.
- `flutter test` passes the new unit test file.

**Leads to:** M05 — models will soon be loaded asynchronously.

---

### M05 — Asynchronous Dart: Future

**Learner outcome:** Explain Dart's event loop at a beginner level, write
`async`/`await` code, use `Future.delayed`, and render async results with
`FutureBuilder`.

**Visible project result:** Profile loads with a simulated delay and a
loading indicator; "loading → content" transition visible on app start;
`main()` becomes `async` to prepare data before `runApp` (mirrors senior
bootstrap shape).

**Prerequisites:** M04.

**Dart introduced:** `Future<T>`, `async`, `await`, `Future.delayed`,
`Future.value`, `try/catch` around awaits, `unawaited` (mentioned),
`.then` (awareness only — await preferred).

**Flutter introduced:** `FutureBuilder` (`snapshot.connectionState`,
`snapshot.data`, `hasError`), async `main()` +
`WidgetsFlutterBinding.ensureInitialized()`, disabled-busy button pattern
(`isLoading` flag in `setState`).

**Concepts reinforced:** StatefulWidget lifecycle, model usage.

**Android/Compose bridge:**
- SIMILARITY: `Future` ≈ `suspend`/`Deferred`; `await` ≈ suspending call;
  `FutureBuilder` ≈ `produceState`/collecting a one-shot flow into state.
- IMPORTANT DIFFERENCE: no `Dispatchers`/structured concurrency; a Future
  started in `initState` is not auto-cancelled — guard with `mounted`.
- DO NOT ASSUME: `await` blocks a thread — it suspends within Dart's
  single-isolate event loop.

**Senior source evidence:** `lib/main.dart` async bootstrap sequence,
`lib/widgets/onboarding/onboarding_overlay_scope.dart` `FutureBuilder`
gating, `loadUserSettings()` before first render.

**Learner implementation scope:** async `main()` loading a fake profile
into a field; `FutureBuilder`-free variant allowed (load in `initState` +
setState) but `FutureBuilder` must appear at least once; keep the real
persistence stub for M10.

**Intentionally excluded:** real SharedPreferences, error retry UX,
`Future.wait` parallel loads (settings M16/M22).

**Testing/checkpoint:** loading state visible; unit test an async function.

**Completion criteria:**
- App shows loading → profile content without hardcoded flicker.
- Learner explains why a delayed `setState` needs a `mounted` check.

**Leads to:** M06 — continuous async data (Streams) builds on Future.

---

### M06 — Streams & StreamBuilder

**Learner outcome:** Explain `Stream` as "sequence of Futures", use
`Stream.periodic`/simple custom streams, render with `StreamBuilder`, and
cancel `StreamSubscription`s in `dispose`.

**Visible project result:** A live countdown/clock element and a
profile-level "stream" that updates the menu when data changes (fake
`Stream` for now — real one arrives with repositories in M14).

**Prerequisites:** M05.

**Dart introduced:** `Stream<T>`, `Stream.periodic`, `StreamController`
(intro + `broadcast()`), `StreamSubscription`, `await for` (awareness),
`listen` + `onDone`/`onError`.

**Flutter introduced:** `StreamBuilder` (`initialData`, `snapshot`
variants), subscription-in-`State` pattern with cancel in `dispose`.

**Concepts reinforced:** dispose discipline, `setState`, model flow.

**Android/Compose bridge:**
- SIMILARITY: `Stream` ≈ cold-ish `Flow`; `StreamBuilder` ≈
  `collectAsState`; `StreamController` ≈ `MutableSharedFlow`.
- IMPORTANT DIFFERENCE: no coroutine scope manages subscription lifetime —
  forgetting `cancel()` leaks; `broadcast` controllers differ subtly from
  single-subscription ones (replayed `BehaviorSubject` comes in M14).
- DO NOT ASSUME: `Stream` events rebuild UI automatically — only
  `StreamBuilder` (or `setState` in a listener) does.

**Senior source evidence:** broadcast event streams in VMs
(`view_models/menu/menu_screen_view_model.dart` `_events`),
`StreamBuilder` in `lib/main.dart` for locale,
`StreamSubscription` lifecycle in every VM/bridge.

**Learner implementation scope:** countdown text ticking via
`StreamBuilder`; a `StreamController`-backed "profile updates" demo feeding
menu stats.

**Intentionally excluded:** rxdart/`BehaviorSubject` (M14), error mapping,
real repo streams.

**Testing/checkpoint:** observe ticking; dispose verified (no leak/log).

**Completion criteria:**
- Countdown ticks without manual rebuild calls.
- Changing the "profile stream" source visibly updates the menu.
- Learner explains `Stream` vs `Future` and why `dispose` matters.

**Leads to:** M07 — screens need to move before more UI is added.

---

### M07 — Navigation: Navigator push/pop

**Learner outcome:** Explain Flutter's imperative `Navigator` stack, push
a `MaterialPageRoute`, return with `pop`, and know where `navigatorKey`
fits conceptually.

**Visible project result:** Tapping Start Game pushes a `GameScreen`
placeholder (static question + answers layout); back returns to menu.

**Prerequisites:** M02 (layout), M03 (callbacks).

**Dart introduced:** `Route<T>` generics basics, builder closure params.

**Flutter introduced:** `Navigator.of(context).push/pop`,
`MaterialPageRoute`, route `builder`, `Scaffold` back arrow,
`Navigator.push` returning a `Future` (awareness),
`GlobalKey<NavigatorState>` (mentioned — full controller in M19).

**Concepts reinforced:** screens as widgets, composition.

**Android/Compose bridge:**
- SIMILARITY: push/pop ≈ Navigation Compose `navigate`/`popBackStack`.
- IMPORTANT DIFFERENCE: Navigation Compose is declarative/route-string
  based; Flutter's classic `Navigator` is imperative object calls — the
  senior app deliberately stays on this model.
- DO NOT ASSUME: pushing a route needs `BuildContext` from *under* the
  `Navigator` — wrong context = "navigator not found".

**Senior source evidence:**
`lib/navigation/app_navigation_controller.dart` (whole file — the app
never grows past two routes),
`lib/screens/menu_screen.dart` event bridge calling `openGame()`.

**Learner implementation scope:** `MenuScreen`→`GameScreen` push on CTA;
`AppNavigationController`-lite object (or direct calls first — controller
formalized in M19); game screen shows question/answers static layout.

**Intentionally excluded:** named routes, `go_router`, deep links, route
arguments (senior has none — say so explicitly).

**Testing/checkpoint:** first `testWidgets` navigation check optional
(formal widget tests start M08).

**Completion criteria:**
- CTA push → game screen; system back/app-bar back returns.
- Learner explains the stack model and why context matters.

**Leads to:** M08 — the game screen gets real behavior.

---

## Phase C — Core local application loop

### M08 — Mini-quiz answer flow (setState era)

**Learner outcome:** Model a question as data, drive answer selection with
`setState`, and write the first widget test.

**Visible project result:** Playable 3–5 question mini-quiz on
`GameScreen`: tap an answer → it highlights (selected state); Next/confirm
advances; question index/labels update.

**Prerequisites:** M04 (models), M07 (route).

**Dart introduced:** enums (`GameAnswerState`-lite: idle/selected),
`List` indexing, `firstWhere`/collection methods, collection `if`/`for`
inside literals.

**Flutter introduced:** `ListView`/`Column` of options, `ValueKey` (intro),
button disabled state, basic widget test APIs: `testWidgets`, `pumpWidget`,
`find.text`, `tester.tap`, `expect(findsOneWidget)`.

**Concepts reinforced:** setState-driven UI, model rendering, keys
changing identity.

**Android/Compose bridge:**
- SIMILARITY: enum UI state ≈ sealed/enum in Compose; list rendering ≈
  `LazyColumn`/`forEach`.
- IMPORTANT DIFFERENCE: widget identity/state is tied to position+key —
  reusing option widgets with changing data needs awareness.
- DO NOT ASSUME: tapping mutates the model directly — state lives in
  `State`, models stay immutable.

**Senior source evidence:**
`lib/widgets/game/answers/game_answer_option*.dart`,
`lib/data/game/game_quiz_question_data.dart`,
`lib/data/game/game_sample_*_questions_data.dart` (5+5+5 const bank),
`test/widgets/game_answer_option_test.dart`.

**Learner implementation scope:** question model + small const bank
(own questions), option list widget, selection state, next-question flow.

**Intentionally excluded:** reveal/correct-wrong phases, timer, money,
dialogs, VM extraction — all later; keep single StatefulWidget.

**Testing/checkpoint:** first `testWidgets` — tap option → find selected
styling.

**Completion criteria:**
- Mini-quiz is playable end-to-end for its 3–5 questions.
- Widget test passes: tap changes rendered state.

**Leads to:** M09 — complete the session loop (reveal, score, end).

---

### M09 — Full game session: reveal, money, end & restart

**Learner outcome:** Implement the complete game phase machine with enums
+ `setState` + `Future.delayed`, present results via `showDialog`, and
handle restart.

**Visible project result:** Full local session: 30s countdown per question
(or short dev value), answer → pending → reveal (correct/wrong colors)
→ explanation dialog → next; wrong/timeout ends at "guaranteed" amount;
final victory dialog; play again.

**Prerequisites:** M05 (delayed futures), M08.

**Dart introduced:** `enum` with fields/switch, `switch` statements,
`Duration` arithmetic, `isEmpty`/null-handling patterns, `int`/math ops.

**Flutter introduced:** `Timer.periodic` (or reuse Stream) for countdown,
`showDialog` + `AlertDialog`/custom dialog builder (standard Flutter
approach — *deliberately* not the senior's in-Stack layer yet),
`WillPopScope`/`PopScope` awareness (deeper in M21), `SnackBar`/
`ScaffoldMessenger` intro.

**Concepts reinforced:** lifecycle (cancel timer in dispose), delayed
callbacks + `mounted`, enums.

**Android/Compose bridge:**
- SIMILARITY: `showDialog` ≈ `AlertDialog` composable-ish trigger;
  `Timer.periodic` ≈ coroutine `while(delay)`.
- IMPORTANT DIFFERENCE: `showDialog` returns a `Future`; dialogs pushed on
  navigator stack — senior app will later replace this with state-driven
  overlay widgets.
- DO NOT ASSUME: `Future.delayed` callbacks check themselves — always
  verify `mounted`/phase.

**Senior source evidence:** `lib/view_models/game/reducer/` phase flow
(`_submitAnswer`, `_revealAnswer`, `_showExplanation`,
`_loadNextQuestionOrVictory`, `_endGame`), `GamePhase` enum
(`lib/data/game/game_session_state_data.dart`), money ladder data
(`lib/data/game/game_money_ladder_data.dart`), result dialogs
(`lib/widgets/game/dialogs/game_result_dialogs.dart`).

**Learner implementation scope:** phase enum (notStarted/playing/pending/
revealed/gameOver/victory), countdown, reveal delay, simple money amount
per question, end + victory dialogs via `showDialog`, restart.

**Intentionally excluded:** sealed `GameDialogState` + in-Stack
`GameDialogLayer` (M21), safe-haven ladder table (simplified: last correct
= guaranteed), explanation-per-wrong-answer map (single explanation ok),
share button.

**Testing/checkpoint:** widget test: answer → pump 1.5s → reveal state;
game-over path.

**Completion criteria:**
- Full session playable: win path and lose path both reachable.
- Timer expiry auto-submits and ends game.
- Dialog shows result and Play Again restarts cleanly.

**Leads to:** M10 — results should survive app restarts.

> **As-shipped annotation (fidelity remediation, FD-12):** the delivered
> M09 learner scope was a *smaller* subset than the scope text above:
> shipped = 3 phases (`answering`/`revealing`/`finished`), 15s/question
> (D18), `GameEndReason` enum, single `AlertDialog`, no money display,
> no explanation dialog, no reveal delay. Deferred and owned exactly:
> real money ladder + per-question earnedAmount → **M19**; reveal delay
> timing → **M19**; explanation dialog → **M19** (dialog layer → M21);
> guaranteed-amount table → **M20**. Full `GameQuizQuestionData` shape
> (`id`/`category`/`language`/`difficulty`/`correctOption`/`explanation`)
> → **M19** (needed by its mapper + explanation flow). See
> `M07_M09_IMPLEMENTATION_NOTES.md` + `SENIOR_FIDELITY_REGISTER.md`.

---

### M10 — Local persistence: SharedPreferences & JSON

**Learner outcome:** Persist the profile as JSON via
`shared_preferences`, hand-write `toMap`/`fromMap` with defensive parsing,
and load on startup.

**Visible project result:** Money/stats earned in a game session appear on
the menu **after app restart**; a reset action clears them.

**Prerequisites:** M04 (models), M05 (async), M09 (results exist).

**Dart introduced:** `dart:convert` `jsonEncode`/`jsonDecode`,
`Map<String, Object?>`, `fromMap`/`toMap` patterns, `int.tryParse`,
`is int`/`is String` guards, `FormatException` handling,
async factory/static `create()`.

**Flutter introduced:** `flutter pub add shared_preferences`, plugin
concept (platform channel behind the API — explain at awareness level),
load-before-render via `FutureBuilder` or async `main`.

**Concepts reinforced:** Futures, models, startup sequence.

**Android/Compose bridge:**
- SIMILARITY: `SharedPreferences` ≈ Android `SharedPreferences`/
  DataStore-preferences; JSON string store ≈ manual serialization.
- IMPORTANT DIFFERENCE: no typed DataStore/proto — validation is entirely
  your job; the senior's `fromMap` shows defensive parsing defaults.
- DO NOT ASSUME: prefs writes are synchronous — they're async; fire-and-
  forget loses writes on close.

**Senior source evidence:**
`lib/repositories/profile/user_profile_repository.dart`
(`'user_profile'` key + `jsonEncode(toMap())`),
`lib/data/profile/user_profile_data.dart` `fromMap`/`toMap` incl. legacy
reset, `lib/repositories/settings/user_settings_repository.dart` same
pattern, `test/user_settings_repository_test.dart` mock-initial-values.

**Learner implementation scope:** `flutter pub add shared_preferences`;
`saveProfile`/`loadProfile` functions then a thin `ProfileStore` class;
menu reads persisted profile; game end writes money/stats.

**Intentionally excluded:** repository interface + stream (M14), multiple
prefs keys/settings (M16), remote sync.

**Testing/checkpoint:** unit test round-trip with
`SharedPreferences.setMockInitialValues({})` (mirrors senior tests);
manual: kill+reopen app, stats persist.

**Completion criteria:**
- After replaying a game and restarting the app, menu stats persist.
- Corrupt/missing stored JSON falls back to defaults without crash.
- Round-trip unit test passes.

**Leads to:** Phase D — enough concrete state exists to justify real
state architecture.

---

## Phase D — State architecture

### M11 — Lifting state: ChangeNotifier & ListenableBuilder

**Learner outcome:** Explain why widget-local `setState` breaks down
(prop drilling, scattered state), create a `ChangeNotifier` state holder,
and rebuild UI via `ListenableBuilder`/`AnimatedBuilder` — the framework
primitive *before* Provider.

**Visible project result:** Game or menu state lives in a
`MenuViewModel`-style `ChangeNotifier` (extends `ChangeNotifier`, calls
`notifyListeners()`); widgets slimmed down; behavior identical to M09/M10.

**Prerequisites:** M09, M10.

**Dart introduced:** `extends`+`super()` usage in practice,
`ChangeNotifier` API, `Listenable`, separating private `_field` +
getter, `@override dispose` in VM.

**Flutter introduced:** `ListenableBuilder`/`AnimatedBuilder`,
listener-driven rebuilds without `setState`, owning/disposing the
notifier in `State`.

**Concepts reinforced:** lifecycle discipline, immutability of state
objects.

**Android/Compose bridge:**
- SIMILARITY: `ChangeNotifier` ≈ `ViewModel` + `MutableStateFlow`;
  `notifyListeners` ≈ posting a new state; `ListenableBuilder` ≈
  `collectAsState`.
- IMPORTANT DIFFERENCE: no `viewModelScope`, no config-change survival —
  the notifier is owned/disposed by whoever created it; Flutter rebuilds
  by identity of listenable, not diffing.
- DO NOT ASSUME: `notifyListeners` diffs — it notifies unconditionally;
  the "did it change" check is your job (senior VMs compare before
  notifying).

**Senior source evidence:** every VM extends `ChangeNotifier`
(`view_models/menu/menu_screen_view_model.dart`,
`settings_view_model.dart`, …); notify-only-if-changed pattern
(`_handleUserProfile` compares `_userData != userData`).

**Learner implementation scope:** extract menu profile/dialog state into
`MenuViewModel`; game screen may keep setState until M19 (graduated
refactor is a teaching beat).

**Intentionally excluded:** Provider (M12 shows why wiring it manually is
clunky), event streams (M13), DRE.

**Testing/checkpoint:** VM unit test — mutate → listener notified.

**Completion criteria:**
- Menu renders from a ChangeNotifier; no `setState` for that state.
- A VM-level method updates UI; unit test verifies notify behavior.

**Leads to:** M12 — now we need to *get* the VM/services to widgets.

---

### M12 — Provider & the app dependency scope

**Learner outcome:** Explain `InheritedWidget`/lookup concept at a
beginner level, use `provider` (`context.read`/`watch`,
`ChangeNotifierProvider`, `MultiProvider`, `Provider.value`) to inject
dependencies and own VMs.

**Visible project result:** `AppScope`-style `MultiProvider` above
`MaterialApp` provides profile store, settings store (stub ok),
notification stub, and a navigation controller; `MenuScreen` and
`GameScreen` get their VMs from `ChangeNotifierProvider(create:)`.

**Prerequisites:** M11.

**Dart introduced:** generic types `Provider<T>`, `context.read<T>()`/`watch<T>()`,
typedef-free function types in `create:`.

**Flutter introduced:** `provider` package, `MultiProvider`,
`ChangeNotifierProvider` (auto-dispose semantics), `Provider.value`,
`context.read` vs `context.watch` vs `select` (read vs watch taught;
`select` mentioned only), `didChangeDependencies` (why read/watching
there is safe).

**Concepts reinforced:** BuildContext as tree position; DI constructor
pattern.

**Android/Compose bridge:**
- SIMILARITY: Provider ≈ `CompositionLocal` + manual DI/Hilt-lite;
  `ChangeNotifierProvider` ≈ `viewModel()` scoping to a nav destination.
- IMPORTANT DIFFERENCE: Provider is *tree lookup* — context below the
  provider sees it, siblings/above do not; no annotation processing, no
  graph validation at compile time.
- DO NOT ASSUME: `context.read` in `build` rebuilds — it doesn't (that's
  `watch`); and calling `watch` in event callbacks is a bug pattern.

**Senior source evidence:** `lib/core/app_dependency_scope.dart`
(8 `Provider.value` entries), `lib/screens/menu_screen.dart` +
`game_screen.dart` `ChangeNotifierProvider(create:)`, all `*DialogScope`
widgets, `context.read<T>()` usage throughout.

**Learner implementation scope:** add `provider`; create app scope with
stores/controller; scope VMs to menu/game; move the navigation controller
into the scope (matching senior).

**Intentionally excluded:** proxies (`ProxyProvider`), scoped disposal
edge cases, `context.select`.

**Testing/checkpoint:** pump widget wrapped in scope (mirrors senior
`widget_test.dart` `buildApp`); verify VM creation/disposal.

**Completion criteria:**
- No global variables / manual passing of stores through constructors.
- Menu & game VMs come from providers; app works identically.
- Learner explains read vs watch and provider lookup direction.

**Leads to:** M13 — VMs now need a channel for one-shot events.

---

### M13 — One-shot UI events from the VM

**Learner outcome:** Explain the "rebuild state vs fire event" split,
implement a broadcast `StreamController` event channel on a VM, and
consume events in a `StatefulWidget` bridge.

**Visible project result:** Navigation/snackbar/dismiss actions are
emitted by VMs as typed events and handled by a private `_EventBridge`
`State` — e.g., menu `requestGame()` → event → controller `openGame()`;
errors → `SnackBar`.

**Prerequisites:** M06 (streams), M12 (Provider).

**Dart introduced:** sealed-free simple event classes first
(`class MenuGameRequested {}` then sealed in M15), `StreamController.broadcast`,
`StreamSubscription` in State, `unawaited`.

**Flutter introduced:** event-bridge pattern (subscribe in
`didChangeDependencies`, cancel in `dispose`), `ScaffoldMessenger` from
events, calling the injected navigation controller from the bridge.

**Concepts reinforced:** stream lifecycle, Provider reads, lifecycle.

**Android/Compose bridge:**
- SIMILARITY: event stream ≈ `SharedFlow`/`Channel` for one-shot effects;
  bridge ≈ `LaunchedEffect` collecting events.
- IMPORTANT DIFFERENCE: collection isn't lifecycle-scoped — the bridge
  `State` must cancel manually; broadcast controllers don't buffer for
  late listeners.
- DO NOT ASSUME: events are state — an event consumed twice must not
  double-navigate; `broadcast` is chosen deliberately.

**Senior source evidence:** `_MenuScreenEventBridge` in
`lib/screens/menu_screen.dart`, `MenuScreenUiEvent` sealed events,
`viewModels` `StreamController<...>.broadcast()` pattern in all dialog VMs,
`game_screen.dart` `_handleUiEvent`.

**Learner implementation scope:** add `events` stream to menu VM +
navigate/snackbar events; game VM navigate-back event; bridge widgets.

**Intentionally excluded:** sealed class hierarchy (M15 makes events
sealed/exhaustive), effect channels in DRE sense.

**Testing/checkpoint:** VM test: call method → expect event emitted;
widget test: tap → SnackBar appears.

**Completion criteria:**
- Tapping CTA navigates via VM event (not a direct widget call).
- An emitted snackbar event visibly shows a SnackBar.
- No duplicate navigation on re-subscription.

**Leads to:** Phase E — architecture is in place for repository streams
and feature-rich surfaces.

---

## Phase E — Persistence & richer application behavior

### M14 — Repository contracts & rxdart BehaviorSubject

**Learner outcome:** Define `abstract interface class` contracts, expose
`ValueStream<T>` state via `BehaviorSubject`, implement
SharedPreferences-backed repositories, and consume `.value`/`.stream` in
VMs — the exact senior repository shape. Introduce fake repositories for
tests.

**Visible project result:** `UserProfileRepository`,
`UserSettingsRepository`, `OnboardingRepository` contracts + impls; menu
profile updates instantly when any writer saves (stream propagation);
onboarding flag repo exists (used in M18).

**Prerequisites:** M10 (prefs), M12 (Provider), M13 (events).

**Dart introduced:** `abstract interface class`, `implements`,
`extension` awareness (senior uses `part`+extensions — read-only),
`BehaviorSubject.seeded`, `ValueStream`, `.value` synchronous read,
`isClosed` guard.

**Flutter introduced:** rxdart package usage scope; repository
`dispose()`; VMs subscribing to repository streams in constructor.

**Concepts reinforced:** streams, DI, models, JSON.

**Android/Compose bridge:**
- SIMILARITY: `BehaviorSubject` ≈ `MutableStateFlow`; `ValueStream.value`
  ≈ `stateFlow.value`; interface+impl repo ≈ identical Android pattern.
- IMPORTANT DIFFERENCE: `BehaviorSubject` is rxdart, not SDK — explain
  why senior chose it (replayable current value); closing subjects is
  manual.
- DO NOT ASSUME: `.value` always exists — only on value streams; plain
  `Stream` has no current-value getter.

**Senior source evidence:**
`lib/repositories/profile/user_profile_repository.dart` (contract + impl
in one file), `repositories/settings/user_settings_repository.dart`,
`repositories/onboarding/onboarding_repository.dart`, all
`ValueStream` getters, `test/helpers/fake_*` fakes.

**Learner implementation scope:** refactor M10 `ProfileStore` into
`UserProfileRepository` contract+impl; add settings + onboarding repos;
menu VM subscribes to streams; write `Fake*` implementations + VM tests.

**Fidelity-convergence items this milestone owns (from Step-09 audit):**
- `UserProfileData` reaches senior field set: add `totalEarnings`
  (formatted String) + `totalQuestionCount`; keep senior defaults
  (`'0XFF'`/zeros — already corrected at remediation); deepen
  `fromMap` parse to senior level (`>=0` int guards, non-empty string
  guards, `_moneyFromDisplay` recovery, legacy-demo purge).
- `resetUserProfile()` = `saveUserProfile(const UserProfileData())`
  (write-default — already aligned in learner `ProfileStore.reset()`).
- `MenuLoadState`/`load()`/`_MenuLoading`/`_MenuErrorState` **retire** —
  the stream-seeded `BehaviorSubject` repository makes manual load
  state unnecessary (senior menu has no load-state surface). Menu VM
  subscribes to `userProfileStream` in constructor instead.
- `expForNextLevel` field is NOT dropped here — it persists (display
  cap) until M22 lands `LevelConfig`-derived cap.

**Intentionally excluded:** remote variants, sync, `Retry`/`switchMap`
rxdart depth.

**Testing/checkpoint:** fake repo unit tests; widget test menu updates on
stream event.

**Completion criteria:**
- Profile/settings persist via repositories and stream to UI live.
- A `FakeUserProfileRepository` drives a VM test without Flutter.
- Learner explains why contract-first enables the disabled/fake variants
  the senior app uses.

**Leads to:** M15 — richer state variants need a better type tool.

---

### M15 — Sealed classes & state-driven UI

**Learner outcome:** Model "one of several states carrying data" with Dart
3 `sealed class` + exhaustive `switch` expressions/patterns; refactor
event classes and dialog state to sealed hierarchies.

**Visible project result:** `MenuDialogState`-style sealed hierarchy drives
which dialog content shows; game end/phase states become sealed with
payloads; compiler refuses non-exhaustive switches (demonstrated).

**Prerequisites:** M13 (events to seal), M14.

**Dart introduced:** `sealed class`, `final class`/`abstract interface
class` recap, `switch` expressions, pattern matching (`:final field`),
object/case patterns, exhaustiveness, `runtimeType` (awareness — senior
uses it as transition key).

**Flutter introduced:** rendering via `switch (state)` over sealed
variants; keyed children (`ValueKey(state.runtimeType)`) for
`AnimatedSwitcher`-ready swaps (full animation in M21).

**Concepts reinforced:** immutability, UI-from-state.

**Android/Compose bridge:**
- SIMILARITY: Dart `sealed` ≈ Kotlin `sealed class`/`when` — the closest
  1:1 bridge in the course.
- IMPORTANT DIFFERENCE: Dart `switch` expression syntax differs
  (`case X() =>`, pattern destructure `:final x`); no companion `object`
  but `final class` + const constructor is idiomatic here.
- DO NOT ASSUME: enums can carry per-variant data — that's exactly when to
  graduate to sealed classes.

**Senior source evidence:** `lib/view_models/menu/menu_dialog_state.dart`,
`lib/data/game/game_session_state_data.dart` (`GameDialogState` variants
with payloads), `lib/data/auth/auth_session_data.dart`,
`lib/data/leaderboard/leaderboard_entry_data.dart`
(`LeaderboardPopupState`), `switch (dialog)` rendering in
`lib/widgets/game/dialogs/game_dialog_layer.dart`.

**Learner implementation scope:** seal `MenuDialogState`, UI event types,
and a `GameDialog`-lite hierarchy; refactor dialog `if/else` to `switch`;
keep `showDialog` usage until M21 (sealed *state* now, in-Stack layer
later).

**Intentionally excluded:** full in-Stack dialog layer, backdrop blur,
`AnimatedSwitcher` choreography.

**Testing/checkpoint:** unit tests for each state's derived getters;
compiler exhaustiveness demo.

**Completion criteria:**
- All dialog/event variants are sealed; `switch` is exhaustive.
- Deleting a `case` produces a compile error (shown intentionally).

**Leads to:** M16 — settings screen is a state-list feature on this base.

---

### M16 — Settings feature (persisted)

**Learner outcome:** Build the settings dialog: switch rows, persisted
`UserSettingsData`, a time-picker row, and an account row; see settings
flow repository → UI and back.

**Visible project result:** Working settings surface (dialog or sheet):
sound/music/haptic switches + notification toggle + time picker wheel —
all persisted across restarts.

**Prerequisites:** M14 (settings repo), M15 (sealed item types).

**Dart introduced:** `enum SettingType`, sealed `SettingItemData` variants
(switch vs time-picker), default parameter values in factories,
`Duration`/int formatting with `padLeft`.

**Flutter introduced:** `Switch`/`SwitchListTile`, `ListWheelScrollView`
(or simplified picker), `AlertDialog`/dialog composition, `Radio`/chips
for language row (visual; real switching in M17),
`package_info_plus` intro for version row (optional within milestone).

**Concepts reinforced:** repository save→stream→rebuild, Provider scoping
(dialog-scoped VM).

**Android/Compose bridge:**
- SIMILARITY: `Switch` ≈ `Switch` composable; wheel picker ≈ number-picker
  style; settings screen ≈ PreferenceScreen.
- IMPORTANT DIFFERENCE: dialog-scoped VM ownership — the VM is created
  when the dialog opens and disposed on close (`ChangeNotifierProvider` in
  the dialog subtree).
- DO NOT ASSUME: toggling a switch writes prefs itself — you must call the
  repository; UI re-renders from the stream.

**Senior source evidence:**
`lib/view_models/settings/settings_view_model.dart`,
`settings_item_factory.dart` (`buildSettingItems` list incl. conditional
time row), `lib/widgets/menu/settings/*`,
`lib/repositories/settings/user_settings_repository.dart`,
`lib/data/settings/user_settings_data.dart` (bounds-checked `fromMap`).

**Learner implementation scope:** `SettingsViewModel` (ChangeNotifier) +
settings repo wiring + dialog UI + persistence; permission/scheduling is
a stub noted for M27.

**Fidelity-convergence items this milestone owns (from Step-09 audit):**
- The real persisted **sound switch** lives here (settings dialog) —
  the course-only header sound toggle from M03 was already removed at
  fidelity remediation; nothing needs deleting, just don't resurrect it.

**Intentionally excluded:** real notification scheduling/permissions
(M27), `SettingsNotificationCoordinator` rollback (M27/appendix),
`Future.wait` parallel load (mentioned).

**Testing/checkpoint:** repo round-trip test; VM test toggle→save;
widget test switch tap.

**Completion criteria:**
- Toggles persist across restarts.
- Notification time picked persists.
- Settings VM created only while dialog is open.

**Leads to:** M17 — the language row becomes real localization.

---

### M17 — Localization (en/vi)

**Learner outcome:** Configure gen-l10n (`l10n.yaml` + ARB files), consume
`AppLocalizations.of(context)`, and switch `MaterialApp.locale` live from
the persisted language setting.

**Visible project result:** English/Vietnamese UI switching at runtime via
the settings language row; onboarding copy ready for l10n (M18).

**Prerequisites:** M16 (languageCode stored), M06/M14 (settings stream).

**Dart introduced:** `intl` awareness, generated `AppLocalizations`
class usage, `Locale`.

**Flutter introduced:** `generate: true` in pubspec, `l10n.yaml` fields,
ARB syntax incl. placeholders, `localizationsDelegates`,
`supportedLocales`, `MaterialApp.locale` driven by a `StreamBuilder` on
settings stream (senior pattern).

**Concepts reinforced:** stream-driven rebuild at app root, repository
writes propagating up.

**Android/Compose bridge:**
- SIMILARITY: ARB ≈ `strings.xml` + locales; `AppLocalizations.of` ≈
  `stringResource()`.
- IMPORTANT DIFFERENCE: generated Dart accessors compile into the app;
  switching locale is just rebuilding `MaterialApp` with a different
  `Locale` — no activity recreate.
- DO NOT ASSUME: every string must be localized day one — senior keeps
  quiz content and repo messages unlocalized deliberately.

**Senior source evidence:** `l10n.yaml`, `lib/l10n/app_en.arb` +
`app_vi.arb` + generated `app_localizations*.dart` (committed),
`lib/main.dart` `StreamBuilder` → `locale` + delegates,
`SupportedLanguageData` (`lib/data/settings/supported_language_data.dart`),
`language_chip_row.dart`.

**Learner implementation scope:** add `flutter_localizations`+`intl`,
author en/vi ARB for menu+settings+game chrome strings, wire locale to
settings stream, language chips row.

**Intentionally excluded:** localizing seeded quiz content (senior doesn't
either), plural/ICU depth (mention), RTL.

**Testing/checkpoint:** widget test: change setting → Vietnamese text
appears (senior has this exact test in `widget_test.dart`).

**Completion criteria:**
- Selecting Tiếng Việt switches visible strings without restart.
- Back to English restores strings.
- New strings added via ARB compile.

**Leads to:** M18 — first-run overlay reuses localization + settings +
repos.

---

### M18 — Onboarding overlay (first run)

**Learner outcome:** Build a first-run overlay: step model, in-`Stack`
overlay card, "show once" persistence, skip/complete flow, language
preselect.

**Visible project result:** Fresh install shows 3-step onboarding over the
menu (welcome+language, notification step, ready); completion persists;
"skip intro" works; reinstall-or-reset shows it again.

**Prerequisites:** M14 (onboarding repo), M16, M17.

**Dart introduced:** `listEquals` (foundation), sealed `OnboardingStepState`
with typed steps, guarded async flows (`_languageSelectionInProgress`
flag concept).

**Flutter introduced:** rendering an overlay layer inside the screen
`Stack`, gating render with `FutureBuilder`+repo stream (simplified
version of senior's scope), permission-step UI w/o real plugin call yet,
`PopScope` interplay note.

**Concepts reinforced:** Provider scoping (overlay-scoped VM), sealed
states, repository persistence, localization.

**Android/Compose bridge:**
- SIMILARITY: overlay ≈ Compose dialog/box overlay gated by a flag;
  stepper state ≈ sealed step model.
- IMPORTANT DIFFERENCE: the overlay is just widgets in a `Stack` — no
  window/route; visibility = state, not navigation.
- DO NOT ASSUME: onboarding needs a route — the senior renders it inside
  the menu screen itself.

**Senior source evidence:**
`lib/widgets/onboarding/onboarding_overlay_scope.dart` (Future/StreamBuilder
gating + scoped VM), `lib/view_models/onboarding/onboarding_view_model.dart`
(step list model, `skipIntro`, language select),
`lib/data/onboarding/onboarding_step_data.dart`,
`onboarding_content_data.dart` (question count read from game bank).

**Learner implementation scope:** overlay widget + step state + repo flag
+ simplified gating (load flag → show if incomplete); language pick writes
settings; notification step records choice but defers real permission
(M27).

**Intentionally excluded:** senior's exact nested
FutureBuilder→StreamBuilder→Provider gating chain (EXPLAIN_ONLY — shown,
rationalized, simplified), real permission request.

**Testing/checkpoint:** delete prefs → onboarding appears; after complete
it never reappears; widget test for step advance.

**Completion criteria:**
- Overlay appears only when flag unset.
- Completing or skipping persists `true` and hides permanently.
- Language chosen during onboarding changes app locale.

**Leads to:** Phase F — the local app is now feature-complete enough to
rebuild the game at senior depth.

---

## Phase F — Advanced senior features

### M19 — Game v2: structured VM, phases, timer, money ladder

**Learner outcome:** Refactor the game to a senior-style
`GameScreenViewModel extends ChangeNotifier`: explicit `GamePhase` enum
state, `Timer.periodic` countdown, real `gameMoneyLadderLevels` table,
presentation-mapper function producing `GameScreenData`.

**Visible project result:** Game fully driven by VM: 30s timer with pause
during dialogs, real 15-level money ladder display/values, explanation
dialog flow, guaranteed-amount progression.

**Prerequisites:** M09, M11–M13, M15.

**Dart introduced:** `Timer` field ownership, `Duration` ops, pure mapper
functions, immutable state struct for session (`GameState`-lite without
DRE — VM holds fields or one `GameState` object updated by copyWith —
*choose fields/copyWith hybrid as stepping stone*), `unmodifiable` views
(awareness).

**Flutter introduced:** `AppNavigationController` parity (GlobalKey on
MaterialApp + context-free `openGame`/`goBack`), `PopScope` intro for game
back, timer-driven rebuild cadence (notify once/sec).

**Concepts reinforced:** ChangeNotifier VMs, events, sealed state,
Provider scope, testing with `pump(duration)`.

**Android/Compose bridge:**
- SIMILARITY: VM+state ≈ ViewModel+StateFlow; mapper ≈ presentation model
  mapping; `Timer` ≈ `tickerFlow`/handler.
- IMPORTANT DIFFERENCE: timer callbacks aren't lifecycle-bound — cancel in
  `dispose`; a 1-second tick notifying all listeners is coarse but fine
  (explain efficiency trade-off).
- DO NOT ASSUME: `PopScope` is optional decoration — without it, Android
  back skips your confirm dialog.

**Senior source evidence:**
`lib/view_models/game/game_screen_view_model.dart` (VM surface,
`screenData` getter), `game_screen_presentation_mapper.dart`,
`game_reducer_timer_flow.dart` (tick semantics),
`lib/data/game/game_money_ladder_data.dart` (15 levels, safe havens),
`lib/navigation/app_navigation_controller.dart`.

**Learner implementation scope:** extract all game logic to VM; real
ladder + safe havens; `GameScreenData` presentation data; timer with
pause/resume; navigation controller parity.

**Fidelity-convergence items this milestone owns (from Step-09 audit):**
- `GameQuizQuestionData` full field set — `id`, `category`, `language`,
  `difficulty`, `correctOption`, `explanation` (senior
  `lib/data/game/game_quiz_question_data.dart`): needed by the
  presentation mapper + explanation-dialog flow this milestone lands.
- Portrait-lock bootstrap (`SystemChrome.setPreferredOrientations` in
  `main.dart` — senior `lib/main.dart`): assigned here because M19 is
  the milestone that rewires `MaterialApp`/bootstrap for
  `AppNavigationController` (`navigatorKey`) — same file, same class of
  wiring, and the game screen is the strongest orientation motivation.
- M09-deferred items collected here: reveal-delay timing, per-question
  `earnedAmount` on the ladder, explanation dialog flow.

**Intentionally excluded:** DRE (M26), in-Stack dialog layer (M21 —
dialogs still `showDialog`), lifelines (M20), persistence (M22 — reuse
M10 save at end).

**Testing/checkpoint:** `pump(Duration(seconds:1))` timer tests; VM unit
tests for phase transitions (mirrors senior `game_reducer_test` intent,
written pre-DRE).

**Completion criteria:**
- All game state transitions driven by VM; widget layer is dumb.
- Timer pauses while a dialog shows, resumes after.
- Correct answer advances the money ladder; safe haven updates guaranteed.

**Leads to:** M20 — lifelines plug into the phase machine.

---

### M20 — Lifelines & feature buttons

**Learner outcome:** Implement 50:50, audience poll, simulated AI hint,
walk-away, and exit as single-use features with enable/disable state.

**Visible project result:** Bottom lifeline bar works: 50:50 blanks two
wrong options; audience poll opens a percentages dialog; "Ask AI" shows
loading→hint dialog; walk-away/exit confirmations.

**Prerequisites:** M19.

**Dart introduced:** `Set` usage (`usedFeatureButtons`), helper pure
functions, `Map<String,int>` percentiles, difficulty-keyed `switch`.

**Flutter introduced:** feature button bar widget, disabled visuals,
dialog types for poll/AI/confirm (still `showDialog`-based), simulated
loading via `Future.delayed`.

**Concepts reinforced:** VM-driven UI, sealed dialog state usage,
immutability.

**Android/Compose bridge:**
- SIMILARITY: lifeline state ≈ one-shot flags in a game VM; poll dialog ≈
  Compose dialog content.
- IMPORTANT DIFFERENCE: single-use enforcement lives in VM state
  (`usedFeatureButtons`), not the widget — a good architecture demo.
- DO NOT ASSUME: "Ask AI" calls a network service — in the senior app it
  is *simulated* (fixed 85% + per-question hint); keep simulation honest.

**Senior source evidence:**
`lib/view_models/game/reducer/game_reducer_feature_flow.dart`,
`lib/view_models/game/support/game_lifeline_helper.dart`
(`applyGameFiftyFifty`, `buildGameAudiencePoll` difficulty percentages),
`GameFeatureButtonType` enum + `usedFeatureButtons` set,
`widgets/game/lifelines/*`, AI/poll dialog classes.

**Learner implementation scope:** all 5 features with VM methods + state;
audience percentages via difficulty heuristic; AI delay + hint text.

**Intentionally excluded:** real AI/network (doesn't exist in senior),
stale-token delay protection (M21/26 explanation beat).

**Testing/checkpoint:** unit tests for helper functions; VM tests
(single-use, disabled states); widget test for 50:50 visible options.

**Completion criteria:**
- Each lifeline usable once; buttons disable appropriately.
- Walk-away unavailable before first safe haven/earning; then works.
- Game-over paths still function.

**Leads to:** M21 — dialogs deserve the senior's unified layer.

---

### M21 — Senior dialog layer & back handling

**Learner outcome:** Replace `showDialog` with the senior's state-driven
in-`Stack` dialog layer: sealed `GameDialogState` → `GameDialogLayer` →
`AnimatedSwitcher` + blur backdrop + `PopScope` choreography.

**Visible project result:** All game dialogs (ladder, explanation, poll,
AI, confirm exit/walk-away, ended, victory) render in a `Stack` overlay
with fade/slide transitions, tap-outside rules, terminal dialogs that
block dismiss, and correct system-back behavior.

**Prerequisites:** M15, M19, M20.

**Dart introduced:** `ValueKey(runtimeType)` keys, transition builder
functions, `dart:ui` `ImageFilter` (awareness).

**Flutter introduced:** `AnimatedSwitcher` (duration/curves/
`transitionBuilder`), `FadeTransition`, `Transform.translate`,
`BackdropFilter`+`ClipRect`, `IgnorePointer`, `HitTestBehavior.opaque`,
full `PopScope(canPop:onPopInvokedWithResult:)` usage,
`MediaQuery.disableAnimations` respect.

**Concepts reinforced:** sealed UI state, Stack layering, VM-driven
rendering.

**Android/Compose bridge:**
- SIMILARITY: dialog-as-state ≈ Compose `if (state) Dialog()` in a `Box`;
  `AnimatedSwitcher` ≈ `AnimatedContent`.
- IMPORTANT DIFFERENCE: these are NOT navigation routes — back button
  handling must be wired via `PopScope` manually; blur needs
  `dart:ui` filters.
- DO NOT ASSUME: `PopScope`'s `canPop:false` pops anyway — it blocks and
  hands you the event; you decide what it means (dismiss vs confirm).

**Senior source evidence:**
`lib/widgets/game/dialogs/game_dialog_layer.dart` (full layer, backdrop,
transitions, dismiss rules), `lib/screens/game_screen.dart` `PopScope` +
`_handleRouteBack` + `_isTerminalDialog`, `menu_screen_view.dart` PopScope
dialog-dismiss, `MenuDialogLayer` keyed `AnimatedSwitcher`.

**Learner implementation scope:** build `GameDialogLayer` mapping sealed
dialog states to views; migrate all dialogs off `showDialog`; add PopScope
rules; menu dialogs can wait until M29 (same technique).

**Intentionally excluded:** terminal-action animation-wait choreography
(`_afterExit` double-check — EXPLAIN then optionally implement),
`transitionKey` subtleties beyond runtimeType.

**Testing/checkpoint:** widget tests for dialog open/dismiss/back paths
(senior `game_dialog_layer_test.dart`, `menu_dialog_layer_test.dart` are
the model); manual back during each dialog.

**Completion criteria:**
- No `showDialog` calls remain in the game; all dialogs are state-driven.
- System back never hard-exits mid-game; confirm-exit appears.
- Transitions animate; reduced-motion setting honored.

**Leads to:** M22 — the session's results now flow to persistence.

---

### M22 — Result persistence & level progression

**Learner outcome:** Persist game results into the profile (money, games,
questions), compute XP/levels via `LevelConfig`-style rules, and display
progression on the menu (level ring/bar, stats, earnings).

**Visible project result:** Finishing/quitting a game updates menu stats
and level progress immediately (stream) and across restarts; milestone
multipliers visible in EXP pacing.

**Prerequisites:** M14, M19, M21.

**Dart introduced:** `while` loops with accumulation, clamp/normalize
helpers, `static const` config tables (milestone multipliers map),
formatting helpers (`formatThousands` dot-grouping).

**Flutter introduced:** progress `LinearProgressIndicator`/custom bar +
level ring basics (full glow polish M28), live profile-stream updates.

**Concepts reinforced:** repository write→stream→rebuild, immutable
models, event→async op boundary (save after game end — guard against
double-save, `hasSavedResult` concept).

**Android/Compose bridge:**
- SIMILARITY: progression table ≈ constants/JSON config; result write ≈
  repository update; live menu ≈ collecting StateFlow.
- IMPORTANT DIFFERENCE: save happens in the VM's async boundary — there's
  no coroutine supervisor; double-invocation guarded by state flag.
- DO NOT ASSUME: shared prefs writes complete instantly — await them
  before relying on stream state.

**Senior source evidence:**
`bridge/game_screen_view_model_result_persistence.dart`
(`_saveGameResult` → level loop → save → conditional sync),
`lib/data/game/level_config.dart` (base/growth/milestones),
`lib/view_models/menu/menu_level_progress.dart` (tiers/ratio),
`widgets/menu/profile/*` display widgets.

**Learner implementation scope:** `LevelConfig`-lite + full version,
`_applyLevelProgression`, save on game end (once), menu progress UI.

**Fidelity-convergence items this milestone owns (from Step-09 audit):**
- `expForNextLevel` field is **dropped** — cap becomes
  `LevelConfig.getExpRequiredForLevel(level)`-derived (senior has no
  such stored field). The learner field was a registered scaffold.
- EXP basis switches to senior rule: EXP = `earnedAmount` (money), not
  count×50; `totalQuestionCount`/`totalEarnings` get written by
  `_saveGameResult` (fields arrive at M14).
- Course-only ×1.5 cap-growth curve in `gainExp` retires for the real
  milestone-multiplier table.

**Intentionally excluded:** Supabase sync call (M25 — keep a stub branch
`if authed`), VNĐ formatting nuances (keep `formatVnd` simple).

**Testing/checkpoint:** unit tests: XP→level thresholds, milestone
multipliers, merge math; widget: finish game → menu shows new stats.

**Completion criteria:**
- Ending a game updates persisted stats once (not twice).
- Menu shows updated level/EXP/stats without restart.
- Level-up boundary conditions hold (tests prove).

**Leads to:** M23 — local app is complete; remote features begin.

---

### M23 — Supabase bootstrap & first remote read (leaderboard)

**Learner outcome:** Configure Supabase via dart-defines, initialize the
client conditionally, implement the `LeaderboardRepository` contract with
static fallback, and read the `public.leaderboard` view into a
loading/empty/error/success UI.

**Visible project result:** Leaderboard dialog with static fallback rows;
with a configured backend, real top-10 + current-user row; explicit
loading/empty/error states and refresh.

**Prerequisites:** M14 (contract+fakes), M15 (sealed popup states), M16
(dialog surfaces).

**Dart introduced:** `String.fromEnvironment` (dart-defines),
`--dart-define` CLI, `maybeSingle()`, mapping `Map<String,dynamic>` rows
to records→entry data, `_requestId` stale-response guard.

**Flutter introduced:** `supabase_flutter` add, `Supabase.initialize` in
`main`, conditional construction (real vs disabled impl), RefreshIndicator
or refresh button pattern.

**Concepts reinforced:** repositories, sealed UI states, streams,
DI-scope.

**Android/Compose bridge:**
- SIMILARITY: Supabase query DSL ≈ Retrofit service call; dart-define ≈
  BuildConfig field; contract+fallback ≈ fake/flavor repository.
- IMPORTANT DIFFERENCE: dart-defines are compile-time strings — no
  runtime env file; the senior app runs fully without backend via
  disabled repos — that's a feature to copy.
- DO NOT ASSUME: secrets belong in env files shipped in-app — publishable
  keys only; service-role never.

**Senior source evidence:**
`lib/core/supabase_environment.dart` (4 dart-define keys),
`lib/services/supabase_client_service.dart` (conditional init),
`lib/repositories/leaderboard/leaderboard_repository.dart`
(`select`/`order`/`limit` + `eq('auth_uuid').maybeSingle()` +
`DisabledLeaderboardRepository` static data),
`lib/view_models/leaderboard/leaderboard_dialog_view_model.dart`
(`_requestId` guard, `LeaderboardPopupState` variants),
`supabase/student-setup/01-setup-database.sql` (schema + view + RLS).

**Learner implementation scope:** env class + conditional init; contract +
static impl first, Supabase impl second; dialog VM with state variants +
guard; dialog UI.

**Fidelity-convergence items this milestone owns (from Step-09 audit):**
- The menu leaderboard row (`_LeaderboardEntry`, static since M02) becomes
  tappable → `requestLeaderboardDialog()` → `MenuDialogLeaderboard`,
  matching senior `LeaderboardEntryCard.onTap` wiring.

**Intentionally excluded:** auth (M24), writes/RLS depth (M25), realtime,
error taxonomy (catch→error state is enough).

**Testing/checkpoint:** fake repo tests for success/empty/error/refresh;
stale-request unit test; manual: run with and without defines.

**Completion criteria:**
- App runs fully unconfigured (static leaderboard).
- With a real backend: top-10 rows render; refresh works.
- Out-of-order responses can't corrupt state (test proves guard).

**Leads to:** M24 — identity layer sits on the same client.

---

### M24 — Authentication (contract → disabled → providers)

**Learner outcome:** Model auth as a sealed session stream, implement the
`AuthRepository` contract + a `DisabledAuthRepository` guest mode, then
Supabase email + Google sign-in; add sign-out with profile reset.

**Visible project result:** Auth dialog from the menu avatar: sign-in
(email + Google; Apple where platform allows — appendix), guest continue,
sign-up; authenticated menu shows name/avatar; sign-out dialog resets
profile.

**Prerequisites:** M15 (sealed session), M23 (Supabase client).

**Dart introduced:** `AuthSessionData` sealed guest/authenticated,
`AuthActionResult` success/failure value type, `sha256`+nonce concept
(Apple — appendix), error-to-message mapping.

**Flutter introduced:** `google_sign_in` v7 `GoogleSignIn.instance`
`initialize`/`authenticate` flow, `supabase_flutter`
`signInWithIdToken`/`signInWithPassword`/`signUp`/`onAuthStateChange`
stream, platform permission/URL-scheme awareness (iOS reversed client ID —
documented, configured only if targeting iOS).

**Concepts reinforced:** sealed states, BehaviorSubject session stream,
event-driven snackbars, scoped dialog VM.

**Android/Compose bridge:**
- SIMILARITY: `onAuthStateChange` ≈ Firebase authStateListener; ID-token
  exchange ≈ Credential Manager/One Tap → backend exchange; auth repo ≈
  Android auth repo.
- IMPORTANT DIFFERENCE: google_sign_in v7 API differs from old versions —
  `authenticate()` not `signIn()`; provider tokens are exchanged to
  Supabase rather than used directly.
- DO NOT ASSUME: sign-in success = synced profile — the senior separates
  sign-in from `syncUserProfile` via the action coordinator (M25).

**Senior source evidence:**
`lib/repositories/auth/auth_repository_contract.dart`,
`supabase_auth_repository.dart` (Google/Apple/email + `onAuthStateChange`
+ `_sessionProfileOverride`), `disabled_auth_repository.dart`,
`lib/services/google_auth_service.dart`,
`lib/services/apple_auth_service.dart` (nonce),
`lib/view_models/menu/menu_auth_dialog_view_model.dart` +
`menu_auth_action_coordinator.dart` +
`menu_sign_out_dialog_view_model.dart`,
`lib/data/auth/auth_session_data.dart`.

**Learner implementation scope:** contract + disabled impl + sealed
session first (guest-mode parity is the teaching point); then email +
Google via Supabase; sign-out flow resets local profile. Apple kept as
an optional appendix lesson (iOS-only hardware requirement).

**Fidelity-convergence items this milestone owns (from Step-09 audit):**
- The course-only menu **reset button** ("ĐẶT LẠI HỒ SƠ", M10) **retires
  here**: senior exposes profile reset via the sign-out dialog
  (`menu_auth_action_coordinator.dart` → `resetUserProfile()`), not a
  menu button. Learner swaps the button for the real dialog path.
- Menu-VM snackbar emit site (learner `resetProfile → MenuSnackBarRequested`)
  moves to the dialog VMs where senior actually emits snackbar events.

**Intentionally excluded:** Apple in core path (appendix),
`_sessionProfileOverride` nuance (explained, optional implement),
OAuth deep-dive, account linking.

**Testing/checkpoint:** `FakeAuthRepository`-style fake driving VM tests;
sign-in/out state stream tests; manual provider smoke when credentials
available (documented as environment-dependent).

**Completion criteria:**
- Guest mode and disabled auth keep the app fully playable.
- Successful sign-in updates menu identity + emits snackbar.
- Sign-out returns to guest and clears profile stats.

**Leads to:** M25 — signed-in sessions enable remote profile sync.

---

### M25 — Profile sync (local ↔ remote merge)

**Learner outcome:** Implement `UserProfileSyncRepository`: fetch remote
`public.users` row, merge with local (max-progression + session identity),
save locally, upsert remotely, expose sync state; wire post-sign-in and
post-game sync.

**Visible project result:** After sign-in, remote stats and local progress
merge sensibly (higher level wins, money maxed, name/avatar from session);
subsequent games upsert to the backend; sync state observable.

**Prerequisites:** M14, M22 (progression writes), M24 (session).

**Dart introduced:** `upsert(..., onConflict:)`, merge-strategy functions,
nullable-field precedence (`session ?? remote ?? local`), error emission
to a `BehaviorSubject` state stream.

**Flutter introduced:** `public.users` RLS interaction at app level
(owner-only rows — explained via senior SQL), `ProfileSyncStateData`
stream consumption.

**Concepts reinforced:** everything — this milestone deliberately
re-uses the whole stack (models, repos, streams, sealed state, async).

**Android/Compose bridge:**
- SIMILARITY: merge/upsert ≈ repository sync strategy; RLS ≈ server-side
  auth scoping; in-flight guard ≈ `Mutex`/single-flight.
- IMPORTANT DIFFERENCE: merge logic is pure Dart — very testable; the app
  trusts client writes (documented senior limitation).
- DO NOT ASSUME: sync is bidirectional truth — remote wins identity,
  max() wins progression; document the rule.

**Senior source evidence:**
`lib/repositories/profile/user_profile_sync_repository.dart`
(`syncUserProfile`, `_isSyncing`, state subject),
`lib/data/profile/app_user_data.dart` (`fromMap`/`toUpsertMap`/`toProfile`,
`mergeUserProfileForSync` incl. demo-purge),
`lib/view_models/menu/menu_auth_action_coordinator.dart` (post-sign-in
sync), `bridge/..._result_persistence.dart` (post-game conditional sync),
`supabase/student-setup/01-setup-database.sql` RLS policies.

**Learner implementation scope:** `AppUserData` + merge function + sync
repo + hook into auth coordinator and game-save path; sync state stream
consumed for a subtle UI indicator or logs.

**Intentionally excluded:** conflict UIs, retry/backoff, multi-device
resolution; `SettingsNotificationCoordinator`-style rollback shown as a
concept note only.

**Testing/checkpoint:** pure-Dart merge tests (local>remote, remote>local,
null remote, demo purge — mirrors `user_profile_sync_merge_test.dart`);
schema mapping test.

**Completion criteria:**
- Merge rules verified by unit tests for each branch.
- Sign-in followed by a game produces a remote upsert (verified in
  backend or fake).
- Sync failure surfaces `ProfileSyncFailed`, not a crash.

**Leads to:** M26 — the now-complete game justifies the senior's DRE
refactor.

---

### M26 — Senior architecture: DRE refactor of the game

**Learner outcome:** Understand *why* the senior game uses a reducer
(state explosion + testability), implement the tiny `core/dre` primitives
(`DreAction`/`DreEffect`/`DreAsyncOp`/`DreReducer`/`DreResult`/
`DreChangeNotifier`), and migrate the game VM to dispatch/reduce/effects
with `flowToken` staleness guards.

**Visible project result:** `GameScreenViewModel` becomes a
`DreChangeNotifier`; all game transitions go through `GameReducer` (pure,
unit-testable); timers/delays/persistence become effects and async ops;
behavior unchanged.

**Prerequisites:** M19–M22 (working game worth refactoring), M15 (sealed
actions/effects), M13 (event channel).

**Dart introduced:** `abstract` base generics pattern
(`DreChangeNotifier<S,A,E,O>`), `part`/`part of` file splitting (EXPLAIN
— senior uses it; learner may keep single files), `@protected`,
`unawaited`, token-based staleness invalidation.

**Flutter introduced:** effects stream bridging to timers/navigation,
async-op boundary for repository writes.

**Concepts reinforced:** immutability, sealed switches, event streams,
testing pure logic.

**Android/Compose bridge:**
- SIMILARITY: DRE ≈ MVI/reducer (Action→Reducer→State+Effect); effects ≈
  `SharedFlow` one-offs; async op ≈ side-effect handler.
- IMPORTANT DIFFERENCE: this is *project-local* code (~75 lines in
  `core/dre`), not a pub framework like Bloc — demystify it by reading the
  source.
- DO NOT ASSUME: reducer may do async work — it must stay pure; async goes
  to `asyncOp`/effects.

**Senior source evidence:** `lib/core/dre/dre.dart` +
`dre_change_notifier.dart`, `lib/view_models/game/dre/*` (contract,
state, actions, effects, async op), `lib/view_models/game/reducer/*`
(4 part files), `bridge/game_screen_view_model_effects.dart` +
`_result_persistence.dart`, `test/core/dre/dre_change_notifier_test.dart`,
`test/view_models/game/game_reducer_test.dart`.

**Learner implementation scope:** port game VM to DRE; write reducer
unit tests first (safety net), migrate one flow at a time
(start→answer→reveal→explanation→next/end).

**Intentionally excluded:** applying DRE elsewhere (senior doesn't),
middleware/effect-handler generalization beyond senior's shape.

**Testing/checkpoint:** reducer unit-test suite green before+after;
full game widget flow test still passes.

**Completion criteria:**
- All game transitions are reducer-produced; no direct mutation.
- Delayed callbacks are token-guarded (stale reveals can't corrupt).
- Reducer tests cover phase transitions and effects.

**Leads to:** M27 — remaining senior surface: platform extras.

---

### M27 — Platform extras: notifications, share, package info

**Learner outcome:** Add daily local notifications (permission +
`zonedSchedule` + timezone), `share_plus` result sharing with clipboard
fallback, and `package_info_plus` version row.

**Visible project result:** Settings notification toggle schedules a real
daily reminder at the picked time; result share opens the share sheet;
settings shows app version.

**Prerequisites:** M16 (settings), M22 (results exist), M24 optional.

**Dart introduced:** `timezone`/`flutter_timezone` usage, `kIsWeb` guard,
`id`/`payload` params, `DateTimeComponents.time` matching.

**Flutter introduced:** `flutter_local_notifications` plugin init
(platform-specific settings objects), permission request APIs per
platform, `share_plus` `SharePlus.instance.share` + `sharePositionOrigin`,
`package_info_plus` `PackageInfo.fromPlatform`.

**Concepts reinforced:** service contracts, coordinator rollback concept
(senior `SettingsNotificationCoordinator` — teach pattern, simplified
impl acceptable), dart-define-free config.

**Android/Compose bridge:**
- SIMILARITY: notification channels/permissions ≈ Android 13+ model the
  plugin wraps; share ≈ `ACTION_SEND`; version ≈ `PackageManager` info.
- IMPORTANT DIFFERENCE: plugins abstract both platforms — iOS/macOS/web
  behavior differs and must be guarded; manifest receivers come from the
  plugin docs.
- DO NOT ASSUME: scheduling succeeds without permission — the senior
  disables the setting when permission is denied.

**Senior source evidence:**
`lib/services/local_notification_service.dart` (init, permissions,
`zonedSchedule`, timezone fallback), `settings_notification_coordinator.dart`
(rollback), `lib/screens/game_screen.dart` share handling + clipboard
fallback, `settings_app_version_loader.dart`, AndroidManifest receivers.

**Learner implementation scope:** notification service impl + settings
wiring + time picker effect; share button on result dialogs; version row.

**Intentionally excluded:** exact-alarm modes, channels beyond the one,
boot-receiver semantics depth (manifest entries copied w/ explanation),
rollback choreography (concept only).

**Testing/checkpoint:** fake notification service tests (senior has
`FakeLocalNotificationService`); manual device check for schedule.

**Completion criteria:**
- Toggling + time pick schedules/cancels a daily notification.
- Share button opens share sheet; failure falls back to clipboard copy.
- Version string renders in settings.

**Leads to:** M28 — polish layer on a feature-complete app.

---

### M28 — Polish: animations, CustomPainter, design tokens

**Learner outcome:** Apply the senior's visual polish: implicit
transitions, `AnimationController` choreography (timer pulse, money
motion, button sheen), a `CustomPainter` progress ring, and consolidate
`AppTokens`/`AppAssets`.

**Visible project result:** Countdown ring painted + pulses under 20%;
money amount animates on change; buttons/dialogs get gradient/sheen/glow
styling; asset set swapped to SVG via `flutter_svg` where applicable.

**Prerequisites:** M02, M19–M21.

**Dart introduced:** `dart:math` for geometry, `CustomPainter`
(`paint`/`shouldRepaint`), `Path`/`Paint`/`Canvas` basics,
`AnimationController`+`Tween`+`CurvedAnimation`+`vsync`
(`TickerProviderStateMixin`).

**Flutter introduced:** `AnimationController` lifecycle, `AnimatedBuilder`
explicit rebuilds, `flutter_svg` `SvgPicture.asset`, `google_fonts`
typography, `BackdropFilter` already seen → decorative gradients,
`RepaintBoundary` (awareness).

**Concepts reinforced:** dispose discipline (controllers), keys,
media-query reduced-motion.

**Android/Compose bridge:**
- SIMILARITY: `AnimationController` ≈ `Animatable`/`rememberInfiniteTransition`;
  `CustomPainter` ≈ Compose `Canvas`/custom drawing; SVG ≈ vector drawables.
- IMPORTANT DIFFERENCE: controllers need explicit `dispose` + `vsync`;
  painters repaint per frame input — `shouldRepaint` granularity matters.
- DO NOT ASSUME: more animation = better — senior respects
  `MediaQuery.disableAnimations`; so does the learner app.

**Senior source evidence:**
`widgets/game/timer/game_countdown_timer.dart` +
`..._progress_painter.dart`, `money/game_money_amount_motion.dart`,
`lifelines/game_feature_button.dart` (sheen), `core/app_design_tokens.dart`
+ `surface_glow_gradient.dart`, `flutter_svg` usage in widgets.

**Learner implementation scope:** countdown painter, money-motion,
button/dialog gradients, token consolidation, SVG icon swap subset.

**Intentionally excluded:** full senior asset parity (subset acceptable),
animated-list choreography, performance profiling depth.

**Testing/checkpoint:** golden-free widget assertions (painter exists,
controller lifecycle); reduced-motion behavior verified manually.

**Completion criteria:**
- Timer ring paints and pulses at low time.
- Money change animates; dialogs/buttons carry token styling.
- Animations respect `disableAnimations`.

**Leads to:** M29 — structural alignment and course completion.

---

## Phase G — Senior alignment

### M29 — Senior alignment pass & course completion

**Learner outcome:** Bring the learner project's structure and remaining
behaviors to senior parity where earlier milestones simplified: menu
dialog layer (sealed `MenuDialogState` + in-Stack layer), event-bridge
form, file/folder conventions, `AppDependencyScope` parity, and
docs/consistency review.

**Visible project result:** Menu dialogs (leaderboard/settings/auth/
sign-out) are state-driven in-Stack like the senior app; project layout
mirrors `lib/` conventions; a final checklist compares learner vs senior
feature-by-feature.

**Prerequisites:** all previous milestones.

**Dart introduced:** `part`/`part of` optional adoption note,
`extension` usage where justified, `TransitionKey`/`runtimeType` subtleties.

**Flutter introduced:** `MenuDialogLayer` parity (AnimatedSwitcher +
keyed children + PopScope + dismiss-lock), `MenuAuthDialogScope`-style
dialog-scoped VM ownership, `flutter widget-preview` (appendix intro),
release kit appendix (`.release-kit`/`scripts/kit` concepts explained —
not executed).

**Concepts reinforced:** everything — this is a deliberate refactor/
alignment milestone.

**Android/Compose bridge:**
- SIMILARITY: alignment pass ≈ architecture conformance refactor;
  dialog-layer ≈ unified overlay host.
- IMPORTANT DIFFERENCE: parity means same *concepts and wiring*, not
  identical files — course explicitly allows learner-grade simplifications
  where documented.
- DO NOT ASSUME: matching the senior means copying — mismatches that are
  documented simplifications are acceptable and marked.

**Senior source evidence:** `lib/widgets/menu/menu_dialog_layer.dart`,
`*_dialog_scope.dart` files, `lib/previews/*` (`@Preview` catalog),
`scripts/kit` + `.release-kit/project.env` (explained),
`docs/codebase-summary.md` structure map.

**Learner implementation scope:** refactor menu dialogs to the senior
pattern; audit folder/file parity; final feature checklist vs
`FEATURE_INVENTORY.md`; optional preview catalog for 2–3 widgets;
release-kit walkthrough doc.

**Fidelity-convergence items this milestone owns (from Step-09 audit):**
- Final pass over `SENIOR_FIDELITY_REGISTER.md`: every `ACTIVE_TEMPORARY`
  entry must reach `CONVERGED` or `REMOVED` — no scaffold survives to
  course end (the M03–M06 menu scaffolds were already removed at
  remediation; this is the verification gate, not the removal site).

**Intentionally excluded:** signing/release pipeline execution, widget
previews for every widget, CI.

**Testing/checkpoint:** full `flutter analyze` + `flutter test` green;
feature checklist all CORE items observable in the running app.

**Completion criteria:**
- Menu dialogs are state-driven overlays (no `showDialog` remains).
- `lib/` structure maps to senior conventions.
- `CURRICULUM_TRACEABILITY.md` statuses reviewed and accurate.

**Leads to:** course completion (definition in `COURSE_ARCHITECTURE.md`).

---

## Roadmap invariants (recheck before milestone generation)

1. No milestone requires an untaught concept (dependency audit passed at
   design time — see report).
2. Every milestone changes something visible/runnable.
3. Senior features F1–F15 all mapped (see `CURRICULUM_TRACEABILITY.md`).
4. Advanced areas stay late: DRE (M26), dialog layer (M21/M29), onboarding
   gating (M18 simplified), Supabase/auth/notifications (M23–M27),
   stale-guards (M23/M26), CustomPainter/animation (M28), release kit
   (M29 appendix).
5. Learner project is never required to be code-identical to senior —
   parity is behavioral + structural, with documented simplifications.
