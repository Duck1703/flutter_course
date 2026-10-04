# Flutter Beginner Gaps

Knowledge a Flutter beginner must acquire to understand and rebuild the
senior app. Derived from actual usage in `flutter-accelerator-ai`, not a
generic syllabus.

Classifications:

- **A** — must learn before touching the project
- **B** — learn while implementing the relevant feature
- **C** — advanced; delay until the base app works
- **D** — senior implementation detail; simplify first
- **E** — project-specific behavior, not general Flutter knowledge

## A — Before touching the project

| Concept | Why needed | Senior evidence |
|---------|-----------|-----------------|
| Dart syntax, `class`, constructors, `final`/`const`, named/required params | every file | all of `lib/` |
| Null safety (`?`, `!`, `??`, `late`, `is` checks) | pervasive | `UserProfileData.avatarUrl`, `AppNavigationController._navigator` throws StateError |
| Collections, `List.map/generate`, spread `...`, collection `if` | model & widget code | `game_lifeline_helper.dart`, `settings_item_factory.dart` |
| `enum` | state/types | `GamePhase`, `GameFeatureButtonType`, `SettingType` |
| `Widget`, `StatelessWidget`, `build(BuildContext)` | all UI | every widget file |
| Basic widgets: `Scaffold`, `Column`, `Row`, `Stack`, `Positioned`, `Text`, `Image`, `GestureDetector`, `SafeArea`, `SizedBox`, `ConstrainedBox`, `Center`, `Expanded` | whole UI is composed from these | `menu_screen_view.dart`, `game_screen.dart` |
| Callbacks (`VoidCallback`, `ValueChanged`, `Function`) | widget APIs are callback-driven | all widgets |
| `StatefulWidget`/`State`, `setState`, `initState`/`dispose`, `mounted` | local widget state + lifecycle | `menu_screen_view.dart`, `wheel_picker.dart`, dialog scopes |
| `Future`, `async`/`await` | repos, VMs, `main()` | `main.dart`, all repositories |
| `pubspec.yaml`, `flutter pub get`, `flutter run`, `flutter analyze`, `flutter test` | workflow | repo root |

## B — Learn while implementing the related feature

| Concept | Where in senior app | Notes |
|---------|--------------------|-------|
| `BuildContext`, `context.read`/`context.watch` | every screen/scope | Provider lookup; teach with first VM |
| `Provider` / `MultiProvider` / `ChangeNotifierProvider` / `Provider.value` | `core/app_dependency_scope.dart`, all scopes | the app's DI + VM ownership mechanism |
| `ChangeNotifier` + `notifyListeners` | all VMs | primary reactivity |
| `Stream`, `StreamSubscription`, `StreamController.broadcast`, `StreamBuilder` | VM UI events, `main.dart`, `OnboardingOverlayScope` | cancel in `dispose()` |
| `FutureBuilder` | `onboarding_overlay_scope.dart` | one-shot async gating |
| `Navigator` push/pop, `MaterialPageRoute`, `GlobalKey<NavigatorState>` | `navigation/app_navigation_controller.dart` | imperative navigation only; no router package |
| `PopScope` / `onPopInvokedWithResult` | both screens | back-button interception (modern WillPopScope) |
| `SharedPreferences` + `jsonEncode`/`jsonDecode`, `toMap`/`fromMap` | profile/settings/onboarding repos | local persistence |
| `MaterialApp` options: `theme`, `locale`, `localizationsDelegates`, `supportedLocales`, `navigatorKey`, `home` | `main.dart` | app shell |
| Localization (ARB + `AppLocalizations.of`) | `l10n.yaml`, `lib/l10n/` | gen-l10n, committed generated files |
| Immutable models + `copyWith` + `==`/`hashCode` | all `data/` classes | hand-rolled; no codegen |
| `sealed class` + `switch` expressions/patterns | dialog/state/result types everywhere | Dart 3 feature, core idiom of this codebase |
| `abstract interface class` contracts + fakes | repositories, `test/helpers/` | testability seam |
| `SnackBar`, `ScaffoldMessenger` | event bridges | UI event pattern consumer |
| Implicit animations: `AnimatedSwitcher`, `FadeTransition`, `AnimatedBuilder` | dialog layers | dialog transitions |
| `ValueKey`-keyed widget swapping | dialog layers | why keys matter for state/animation |
| Assets (`pubspec` assets, `AssetImage`, `SvgPicture`) | `core/app_assets.dart`, widgets | centralized asset constants |
| `MediaQuery`, `AnnotatedRegion<SystemUiOverlayStyle>` | screen shells | chrome polish |
| `debugPrint`, `FlutterError.reportError` | VMs, onboarding | lightweight logging |

## C — Advanced; delay until base app works

| Concept | Where | Why delay |
|---------|-------|-----------|
| `Timer.periodic`, `Future.delayed` + cancellation/token guards | game bridge, reducer | correctness subtleties (`flowToken`) need stable mental model first |
| rxdart `BehaviorSubject`/`ValueStream` (seeded, `.value` reads) | all repositories | easier after plain Stream/Future comfort |
| `AnimationController`, `TickerProviderStateMixin`, `AnimatedBuilder` listeners | timer, buttons, money motion, auth dialog | animation subsystem is its own module |
| `CustomPainter` | `game_countdown_timer_progress_painter.dart` | paint API is advanced |
| `BackdropFilter`/blur, gradients, `ClipRect`, hit-testing (`HitTestBehavior.opaque`, `transformHitTests`) | dialog shell/backdrops, tokens | polish layer |
| `Future.wait`, error rollback choreography | settings coordinator, `loadSettings` | compound async patterns |
| Platform channels as black-box usage (plugins) | notifications, sign-in, share | treat as "services" first |
| `String.fromEnvironment` dart-defines | `supabase_environment.dart` | config plumbing; explain when adding Supabase |
| `unawaited()` discipline | screen/VM code | lint-driven async style |

## D — Senior details to simplify first

| Senior implementation | Simplification |
|----------------------|----------------|
| DRE framework (`lib/core/dre/`, `GameReducer` + 4 part files, effects + async ops) | Build the game as a plain `ChangeNotifier` first; reveal reducer pattern later as "why the senior code does this" |
| `part`/`part of` multi-file classes | Keep single files in learner project |
| Dialogs-as-state inside `Stack` + `PopScope` choreography | Use `showDialog` initially; graduate to in-stack overlay when teaching the senior approach |
| `OnboardingOverlayScope` FutureBuilder→StreamBuilder→Provider nesting | Simple boolean gate first |
| `SettingsNotificationCoordinator` rollback | Direct save-then-schedule first |
| `_requestId`/`flowToken` staleness guards | Explain as a lesson; skip in first pass |
| Supabase auth trio (Google v7 API + Apple nonce + email) | Fake/Disabled repository long before real providers |
| Release kit, signing env, `AuthCredentials.xcconfig` | Plain `flutter run`/`build` |
| Widget previews catalog (`lib/previews/`) | Optional appendix |

## E — Project-specific behavior (learn from the app, not general Flutter)

- "DRE" naming (`DreAction`/`DreEffect`/`DreAsyncOp`/`DreReducer`/
  `DreResult`) — project-local Redux-like core, not a pub package.
- `gameMoneyLadderLevels` safe-haven economics and `LevelConfig` milestone
  multipliers — game design, not Flutter.
- `MenuDialogState.transitionKey` = `runtimeType` used as switcher key.
- `_legacyDemoProfile` reset inside `UserProfileData.fromMap` — data
  migration quirk.
- Audience-poll percentages are computed heuristics by difficulty
  (`buildGameAudiencePoll`), not real data.
- "Ask AI" lifeline is simulated: fixed 85% confidence + per-question
  `aiHintMessage`; **no real AI/network call exists**.
- `onboardingQuestionCount` reads `gameSampleQuestions.length` so copy
  can't drift from the game.
- `scripts/kit` vendored release tooling + `.release-kit/project.env`
  contract — bespoke ops surface.

## Testing skills the learner will eventually need

`testWidgets`/`WidgetTester` (`pump`, `pumpAndSettle`, `tap`, `find`,
`ensureVisible`, `handlePopRoute`), `SharedPreferences.setMockInitialValues`,
`PackageInfo.setMockInitialValues`, hand-written fakes implementing
repository contracts, `Completer`-controlled async, golden-free layout
assertions via `tester.getRect`. Current suite: ~45 files in `test/`.
