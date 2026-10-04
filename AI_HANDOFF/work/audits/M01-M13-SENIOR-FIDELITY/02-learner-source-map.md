# 02 — Learner Source Map (Flux)

Learner app: `learner-app/` (package `ai_millionaire_course`).
End-of-M13 state: `flutter analyze` clean · `flutter test` 57/57 ·
`flutter build web` PASS. Not under git — integrity by audit write-scope.

## lib/ (15 files)

| File | Role | Senior anchor |
|---|---|---|
| `lib/main.dart` | async `main`, `ensureInitialized`, `ProfileStore` construction, `AppDependencyScope`, `MaterialApp` (theme `fromSeed(0xFF5137E5)`, `useMaterial3`), `home: MenuScreen` | `lib/main.dart` — **missing: portrait lock, navigatorKey, l10n, Supabase init, 7 other deps** (all deferred per roadmap note "all wired later") |
| `lib/core/app_dependency_scope.dart` | `StatelessWidget` → `Provider<ProfileStore>.value` (single entry) | `core/app_dependency_scope.dart` — same name + `Provider.value` style; senior has MultiProvider×8 |
| `lib/core/menu_tokens.dart` | `MenuTokens` — spacing/radius/colors subset; designWidth 375 | `core/app_design_tokens.dart` `AppTokens` — labelled "phiên bản rút gọn" |
| `lib/data/profile/user_profile_data.dart` | immutable model; `copyWith`; `gainExp` (×1.5 cap growth); `moneyPerCorrectAnswer=50000`, `expPerCorrectAnswer=50`; `applyGameResult`; `toMap`/`fromMap` defensive; `expPercent`, `winRateDisplay`, `totalEarningsDisplay`, `formatThousands`; `==`/`hashCode` | `data/profile/user_profile_data.dart` — subset + invented `expForNextLevel` field + invented defaults (120/400 EXP, 'Khách') |
| `lib/data/profile/demo_profile_loader.dart` | `loadDemoProfile({fail, delay})` + `demoLoadedProfile` — M05 teaching loader | **no senior counterpart** (demo fixture); doc labels it temporary (M10→prefs, M14→repo). **Currently unreferenced in lib/** — only its test uses it |
| `lib/data/profile/profile_store.dart` | `ProfileStore` concrete; key `'user_profile'`; `jsonEncode(toMap)`; `load()`→default on missing/bad JSON; `save()` throws `StateError` on `!didSave`; `clear()` → `prefs.remove` | `repositories/profile/user_profile_repository.dart` — same key/format/throw; senior = interface+`BehaviorSubject`, `resetUserProfile` writes default (not remove) |
| `lib/data/menu_session_ticker.dart` | `Stream<int>.periodic` +1 — M06 stream demo source | **no senior counterpart** |
| `lib/data/game/quiz_question.dart` | `QuizQuestion{question, options, correctIndex:int}` + `isCorrect` | `data/game/game_quiz_question_data.dart` — subset; senior `correctOption` is a `String`, plus id/category/language/difficulty/explanation |
| `lib/data/game/quiz_questions.dart` | 4-question `const` bank (course-review questions) | `game_sample_questions_data.dart` — senior bank is larger w/ full fields |
| `lib/data/game/game_session_state.dart` | `GamePhase{answering,revealing,finished}` (3); `GameEndReason{wrongAnswer,timeout,victory}` | `data/game/game_session_state_data.dart` — senior GamePhase has 6; `GameEndReason` doesn't exist (sealed dialog states instead) |
| `lib/data/game/game_result.dart` | `GameResult{questionsAnswered, correctAnswers, won}` — route-result payload | no senior file; doc cites `_saveGameResult(earnedAmount,isWin,questionCount)` — mechanism differs (route pop vs repo write) |
| `lib/screens/menu_screen.dart` | `MenuScreen`(Stateless) → `ChangeNotifierProvider<MenuViewModel>(create: read(ProfileStore)..load())` → `_MenuScreenView`(Stateful: `_soundOn`,`_playTapCount`,`_sessionTicker` + **event bridge fields**); body: `_ProfileHeader`(sound toggle), `_LevelCard`, `_EarningsCard`, `_LeaderboardEntry`(static), `_StatsRow`, `_SessionTickerCard`, `_ResetButton`, `_PlayButton`+tap counter; `_MenuLoading`/`_MenuErrorState` | `screens/menu_screen.dart` + `widgets/menu/menu_screen_view.dart` — same provider/entry shape; learner invents: sound toggle, tap counter, ticker card, reset button, load-state UI; missing: settings/account taps, tappable leaderboard, dialog layer, onboarding overlay, PopScope |
| `lib/screens/game_screen.dart` | StatefulWidget owning all game state; `secondsPerQuestion=15` (comment labels senior=30); `Timer.periodic` 1s tick; select→CHỐT→reveal→TIẾP; `AlertDialog` via `showDialog` returns `_ResultAction`; `pop(result)` on VỀ MENU; free back-pop (no PopScope) | `screens/game_screen.dart` — senior is VM-driven, 30s, `PopScope(canPop:false)`+confirm-exit, in-Stack dialog layer, no route result |
| `lib/view_models/menu/menu_view_model.dart` | `MenuViewModel extends ChangeNotifier`; ctor `ProfileStore`; `MenuLoadState{loading,ready,failed}`; `load()`; `applyGameResult(GameResult)`; `resetProfile()` → `clear()` + emits `MenuSnackBarRequested('Đã đặt lại hồ sơ.')`; `requestGame()` → `MenuGameRequested`; broadcast `_events`; compare-before-notify; dispose closes controller | `view_models/menu/menu_screen_view_model.dart` — same ChangeNotifier+ctor+events shape; senior subscribes to repo streams (no load/applyGameResult/resetProfile methods) |
| `lib/view_models/menu/menu_ui_event.dart` | `abstract class MenuUiEvent`; `final class MenuGameRequested`; `final class MenuSnackBarRequested(message)` — doc labels sealed-deferred (M15) | `view_models/menu/menu_screen_ui_event.dart` — same member shapes; senior root is `sealed` |

## test/ (9 files, 57 tests)

`user_profile_data_test`, `demo_profile_loader_test`, `menu_session_ticker_test`,
`profile_store_test`, `quiz_questions_test`, `menu_view_model_test` (incl. M13
events group), `menu_provider_scope_test`, `menu_ui_events_test`,
`widgets/game_screen_test`. Senior test layout (`test/helpers/fake_*`,
`test/widgets/…`, DRE tests) arrives with M14+.

## Course-only elements now living in the learner app

| Element | Origin | Labelled? | Removal mapped? |
|---|---|---|---|
| `_soundOn` toggle + "Âm thanh: bật/tắt" | M03 setState demo | yes (comment "ephemeral") | implicit — M16 real persisted sound setting; M29 parity |
| `_playTapCount` + "Số lần bấm: N" | M03 | yes | **no explicit milestone** |
| `_SessionTickerCard` | M06 StreamBuilder demo | yes | implicit — M14 repo streams; M29 |
| `_ResetButton` + `resetProfile` + snackbar | M10/M13 | yes | implicit — M24 sign-out reset; M29 |
| `MenuLoadState` + `_MenuLoading`/`_MenuErrorState` | M05/M11 | yes | implicit — M14 stream-seeded profile |
| `demo_profile_loader.dart` (dead in lib/) | M05 | yes | none — orphaned |
| `expForNextLevel` stored field | M04 | partial | M22 LevelConfig derives cap |
| Default profile 120/400 EXP, 'Khách' | M03/M04 fixture | partial | none explicit (senior default: '0XFF', zeros) |
