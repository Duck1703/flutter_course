# 01 — Senior Source Map (Flux)

Senior repo: `flutter-accelerator-ai` @ `main` / `c8eb860`, clean.
All paths below were **read directly** for this audit (not inferred from
filenames or prior reports).

## Bootstrap / DI

| File | Truth established |
|---|---|
| `lib/main.dart` | `WidgetsFlutterBinding.ensureInitialized()`; `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])` (line 24); Supabase env via dart-defines; conditional `Supabase.initialize`; constructs all repositories/services; wraps app in `AppDependencyScope`; `MaterialApp` uses `navigatorKey` from `AppNavigationController`, `StreamBuilder` on settings stream → `locale`, gen-l10n delegates |
| `lib/core/app_dependency_scope.dart` | `MultiProvider` with **8** `Provider.value` entries: `AppNavigationController`, `UserProfileRepository`, `AuthRepository`, `LeaderboardRepository`, `UserProfileSyncRepository`, `OnboardingRepository`, `UserSettingsRepository`, `LocalNotificationService`. All `.value` — objects created in `main()` |
| `lib/navigation/app_navigation_controller.dart` | `GlobalKey<NavigatorState> navigatorKey`; `openGame()` → `_push<void>(MaterialPageRoute<void>(builder: (_) => const GameScreen()))`; `goBack()` → `_pop()` with `canPop()` guard; `_navigator` throws `StateError` if key detached |

## Menu subsystem

| File | Truth established |
|---|---|
| `lib/screens/menu_screen.dart` | `MenuScreen extends StatelessWidget` → `MultiProvider[ChangeNotifierProvider<MenuScreenViewModel>(create: read repos …..loadUserProfile())]` → `_MenuScreenEventBridge` (StatefulWidget). Bridge: `didChangeDependencies` → `context.read` nav-controller + `_attachMenuViewModel` with `if (_viewModel == viewModel) return;` guard + cancel-old-subscription; `dispose` cancels; `_handleUiEvent` handles `MenuGameRequested` → `_navigationController.openGame()` (bare call — Future silently dropped, **no** `unawaited`), `MenuSnackBarRequested(:final message)` → `ScaffoldMessenger` SnackBar |
| `lib/view_models/menu/menu_screen_view_model.dart` | `extends ChangeNotifier`; ctor-injected `UserProfileRepository` + `AuthRepository`; seeded state from `stream.value`; subscribes to both streams in ctor; `compare-before-notify` (`shouldNotify = _userData != userData`); `_isDisposed` guard; `loadUserProfile()` = refresh kick to both repos (no load-state enum); `requestGame()` → `_events.add(MenuGameRequested())`; dialog state via `_setDialogState`; dispose cancels subs + closes `_events` |
| `lib/view_models/menu/menu_screen_ui_event.dart` | **`sealed class MenuScreenUiEvent`**; `final class MenuGameRequested`; `final class MenuSnackBarRequested(final String message)` — **`MenuSnackBarRequested` is declared but never emitted by `MenuScreenViewModel`** (grep: only emission is `MenuGameRequested` at line 107; snackbar events are emitted by *dialog* VMs `menu_auth_dialog_view_model.dart`, `menu_sign_out_dialog_view_model.dart` with their own types) |
| `lib/view_models/menu/menu_dialog_state.dart` | sealed `MenuDialogState` hierarchy (None/Leaderboard/Settings/Auth/SignOut) driving `MenuDialogLayer` |
| `lib/view_models/menu/menu_auth_action_coordinator.dart` | `signOut()` → on success `_userProfileRepository.resetUserProfile()` (line 116) — **reset is an auth-flow side effect, not a menu button** |
| `lib/widgets/menu/menu_screen_view.dart` | `MenuScreenView extends StatefulWidget` — `_dialogDismissLocked` only; `PopScope(canPop: !dialogState.isVisible)`; Stack: `GameScreenBackground` + header + `MenuScreenContent` + `GradientCtaButton` + `MenuDialogLayer` + `OnboardingOverlayScope` |
| `lib/widgets/menu/menu_screen_content.dart` | 4 cards: `LevelProgressCard(MenuLevelProgress.fromProfile)`, `EarningsCard`, `LeaderboardEntryCard(onTap → requestLeaderboardDialog)`, `StatsCard` |
| `lib/widgets/menu/profile/stats_card.dart` | shows gamesJoined / gamesWon / winRate — same triple as learner |
| `lib/widgets/menu/profile/menu_profile_header.dart` | avatar + account tap (auth action) + settings tap (settings dialog) — **no sound toggle** |
| `lib/view_models/menu/menu_level_progress.dart` | `MenuLevelProgress.fromProfile` computes `requiredExp` from `LevelConfig.getExpRequiredForLevel(level)` — EXP cap is *derived*, not a stored field |

## Game subsystem

| File | Truth established |
|---|---|
| `lib/screens/game_screen.dart` | `GameScreen extends StatelessWidget` → `ChangeNotifierProvider<GameScreenViewModel>(create: read 3 repos …..startNewGame())` → `_GameScreenEventBridge`. `PopScope(canPop:false)` + `_handleRouteBack` → `showConfirmExit`; `_handleUiEvent` handles `GameNavigateToMenuEvent` → `goBack()`, `GameShareResultEvent` → `SharePlus` + clipboard fallback; `_afterExit`/`_terminalActionPending` guard; dialogs rendered by in-Stack `GameDialogLayer` — **no `showDialog`, no route-result** |
| `lib/data/game/game_session_state_data.dart` | `enum GamePhase { notStarted, playing, answeredPending, answeredRevealed, gameOver, victory }` (6); `sealed class GameDialogState` (Hidden / MoneyLadder / ConfirmExit / ConfirmWalkAway / Explanation / AudiencePoll / AIAssistant / Ended / Victory); `sealed class GameScreenUiEvent` (`GameNavigateToMenuEvent`, `GameShareResultEvent(text)`). **No `GameEndReason` type exists** |
| `lib/data/game/game_quiz_question_data.dart` | `GameQuizQuestionData { id, question, options, correctOption:String, category, language, difficulty, explanation:GameQuestionExplanationData{explainForTrueAnswer, explainForWrongAnswers:Map, aiHintMessage} }`; `enum GameQuestionDifficulty {easy, medium, hard}` |
| `lib/data/game/level_config.dart` | `baseExp=30000, growthPerLevel=5000, minLevel=1, maxLevel=100`, milestone multipliers map (5,10,15:×1.5; 20,40,60,90:×3/…; 100:×5); `getExpRequiredForLevel`, `getCumulativeExpForLevel` |
| `lib/view_models/game/game_screen_view_model.dart` | `DreChangeNotifier<GameState,GameAction,GameEffect,GameAsyncOp>`; ctor takes 3 repositories; `timePerQuestion = 30s`; `_events` broadcast `GameScreenUiEvent`; `effects.listen(_handleEffect)`; `dispatch(GameAction)`; delays 1500/1000/700ms |
| `lib/view_models/game/bridge/game_screen_view_model_result_persistence.dart` | `_saveGameResult(earnedAmount, isWin, questionCount)` → `loadUserProfile` → `_applyLevelProgression(gainedExp: earnedAmount)` (EXP = money won) → `copyWith(totalEarnings: formatVnd(money), totalMoneyWon+, gamesJoined+1, gamesWon+isWin, totalQuestionCount+)` → `saveUserProfile` → conditional sync via auth session |

## Persistence / models

| File | Truth established |
|---|---|
| `lib/repositories/profile/user_profile_repository.dart` | `abstract interface class UserProfileRepository { ValueStream<UserProfileData> get userProfileStream; loadUserProfile(); saveUserProfile(); resetUserProfile(); dispose(); }`. Impl: `BehaviorSubject.seeded(const UserProfileData())`; key `'user_profile'`; `jsonEncode(toMap)`/`jsonDecode`+`fromMap`; `saveUserProfile` throws `StateError` when `!didSave` (line 70-71); `resetUserProfile()` = `saveUserProfile(const UserProfileData())` — **writes default, does not remove the key** |
| `lib/data/profile/user_profile_data.dart` | fields: username(`'0XFF'`), level(1), `totalEarnings`(stored String `'0 VNĐ'`), currentExp(0), `totalQuestionCount`(0), totalMoneyWon(0), gamesJoined(0), gamesWon(0), avatarUrl; `fromMap` defensive (`_intValue` requires `is int && >= 0`, `_stringValue` requires nonempty trimmed), `_moneyFromDisplay` recovers money from display string, `_isLegacyDemoProfile` purges known demo row; `formatThousands`/`formatVnd`; `toMap` uses `'avatarUrl': ?avatarUrl` (omits key when null) |
| `lib/widgets/onboarding/onboarding_overlay_scope.dart` | `FutureBuilder<bool>` gating → `StreamBuilder` with `initialData: stream.value`, `snapshot.data ?? …` — confirms M05/M06 lesson claims |

## Senior surface NOT yet in learner scope (mapped to later milestones)

Auth (`supabase_auth_repository`, `disabled_auth_repository`, sealed
`AuthSessionData`), settings (`UserSettingsRepository`, `SettingsViewModel`,
settings widgets), onboarding VMs, leaderboard repo+dialog VM,
`UserProfileSyncRepository`, `LocalNotificationService`, DRE (`core/dre`),
money ladder (`game_money_ladder_data.dart`), lifeline helpers, `share_plus`,
l10n (`l10n.yaml`, ARB, generated), CustomPainter/animation widgets,
previews, release kit — all confirmed present in senior, all mapped to
M16–M29 in `CURRICULUM_TRACEABILITY.md`.
