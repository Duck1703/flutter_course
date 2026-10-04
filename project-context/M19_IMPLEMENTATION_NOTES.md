# M19 Implementation Notes — Structured Game Architecture / GameViewModel convergence

## What landed (learner-app)

- `lib/data/game/game_session_state_data.dart`: verbatim-senior
  6-phase `GamePhase` (`notStarted`/`playing`/`answeredPending`/
  `answeredRevealed`/`gameOver`/`victory`) + sealed `GameDialogState`
  (`GameDialogHidden`, `GameMoneyLadderDialog`,
  `GameConfirmExitDialog`, `GameExplanationDialog`,
  `GameEndedDialog(earnedAmount)`, `GameVictoryDialog(earnedAmount)`)
  + immutable `GameSessionState` with `copyWith` (fields: `phase`,
  `questionIndex`, `moneyEarned`, `guaranteedAmount`,
  `moneyAnimationTrigger`, `remainingTime`, `selectedAnswer`,
  `dialogState`, `flowToken`). `GameEndReason` retired — end semantics
  live in phase.
- `lib/data/game/game_screen_data.dart`: `GameScreenData` +
  `GameQuestionViewData` + `GameAnswerOptionData`
  (`isEliminated`/`isSelected`/`isCorrect`/`isRevealed` — elimination
  flags inert until M20).
- `lib/data/game/game_quiz_question_data.dart`: full senior shape
  (`id`, `category`, `language`, `GameQuizDifficulty`,
  `correctOption` enum, `explanation{vi,en}`).
- `lib/data/game/game_money_ladder_data.dart`: 15-level ladder +
  safe havens {5,10,15}; `amountForLevel`, `isSafeHaven`,
  `guaranteedAmountForIndex`.
- `lib/data/game/game_result.dart`: `GameResult` gains
  `earnedAmount` (money-ladder payload toward FR-03/FR-04 M22
  convergence).
- `lib/data/game/game_quiz_questions.dart`: senior 45-question bank
  verbatim (`gameSampleQuestions`, `gameSampleEasyQuestions`,
  `gameSampleMediumQuestions`, `gameSampleHardQuestions`).
- `lib/view_models/game/support/game_money_formatter.dart`:
  `formatGameMoney` (vi đồng + en $, comma grouping).
- `lib/view_models/game/support/game_money_ladder_mapper.dart`:
  ladder → `GameMoneyLadderRowData` list (current/passed/current-
  is-safe flags).
- `lib/view_models/game/game_screen_presentation_mapper.dart`: pure
  `GameSessionState` + bank → `GameScreenData` (phase→visibility,
  timer display, per-option state derivation).
- `lib/view_models/game/game_screen_view_model.dart`:
  `GameScreenViewModel extends ChangeNotifier` — **intermediate
  architecture** (senior uses `DreChangeNotifier`+reducer → M26).
  Owns: `Timer.periodic(30s)` countdown w/ pause/resume around
  dialogs; 1500ms reveal + 1000ms explanation delayed flows; monotonic
  `flowToken` invalidating stale callbacks; `_isDisposed` + phase
  guards; `selectAnswer`, `onTimeUp`, `_advanceQuestion`,
  `openMoneyLadder`/`confirmExit`/`closeDialog`/`leaveGame`/
  `dismissTerminalDialog`; `GameScreenUiEvent` broadcast stream
  (dialog-open + result-applied one-shots); `screenData` getter via
  mapper; walk-away = verbatim senior `calculateGameWalkAwayAmount`
  (0 before first safe haven). Persist: `GameResult` route-pop +
  `applyGameResult`-on-model save site retained (→M22).
- `lib/navigation/app_navigation_controller.dart`:
  `AppNavigationController` (`GlobalKey<NavigatorState>`,
  `openGame()`/`goBack()` context-free); `navigatorKey` exposed.
- `lib/core/app_dependency_scope.dart`: nav controller provided via
  `Provider<AppNavigationController>.value`.
- `lib/main.dart`: `navigatorKey` on `MaterialApp`;
  `await SystemChrome.setPreferredOrientations(
  [DeviceOrientation.portraitUp])` before `runApp` (FR-17).
- `lib/screens/game_screen.dart`: full rewrite — provider scope
  (`create: (_) => GameScreenViewModel()..startNewGame()`) + stateful
  `_GameScreenView` event bridge (subscription in `initState`,
  `showDialog` per `GameDialogState` via exhaustive switch — interim
  until M21's in-Stack layer); `PopScope` + `_handleRouteBack` +
  dialog-route back intercept (senior back-routing: intro/terminal
  back ignored, confirm-exit back closes dialog); `context.watch`
  `screenData` rendering; tap-to-submit answers; question counter +
  timer text; portrait-only. Injected-VM startup deferred to
  post-frame (mount-phase `!_dirty` guard).
- `lib/screens/menu_screen.dart`: `_openGame` →
  `context.read<AppNavigationController>().openGame()` (context-free;
  no more `Navigator.push<GameResult>`).
- `lib/l10n/app_{en,vi}.arb`: dead game keys removed; 9 senior
  dialog keys added verbatim (`moneyLadderTitle`,
  `exitGameTitle`/`exitGameMessage`/`exitGameStay`/`exitGameLeave`,
  `correctAnswerExplanationTitle`, `gameOverTitle`/`gameWonTitle` —
  names per actual ARB; `index`/`count` placeholders).
  Learner-invented `gameRoomTitle`/`questionCounter` retained and
  documented.
- Deleted: `lib/data/quiz_questions.dart`,
  `lib/data/quiz_question_data.dart`, old `game_screen.dart` stub.
- `onboarding_content_data.dart`: question-count now derives from
  `gameSampleQuestions` (bank swap).
- `pubspec.yaml`: +`fake_async` dev-dependency.

## Tests (24 new; 126 total)

- `test/game_screen_view_model_test.dart` (17): initial state,
  select-answer flow, reveal/explanation timing via `fake_async`,
  timeout, progression, victory, safe-haven money, walk-away, exit,
  back semantics, disposal.
- `test/game_screen_presentation_mapper_test.dart` (4).
- `test/game_sample_questions_test.dart` (7): bank integrity.
- `test/sealed_state_test.dart` (5): dialog-state exhaustiveness.
- `test/widgets/game_screen_test.dart` (10): full session, dialogs,
  dialog-route back routing, menu→game→exit→profile result.
- Updated: profile tests (`earnedAmount`), menu tests (nav
  controller), test helper (`navigatorKey`).

## Register deltas

- **CONVERGED at M19**: FR-05 (6-phase machine), FR-06 (30s
  VM-owned timer), FR-10 (full question model), FR-13
  (AppNavigationController), FR-17 (portrait lock), FR-18 (senior
  question bank).
- **Advanced, still open**: FR-03 (ladder `earnedAmount` flows; EXP
  basis + new fields →M22), FR-04 (nav controller landed; VM-side
  save →M22), FR-07 (full dialog variant set + `earnedAmount`
  payload; in-Stack layer →M21, lifeline variants →M20).

## Deferred (register-tracked)

- DRE architecture (`DreChangeNotifier`, `GameReducer`, effects) →
  **M26**. M19's `ChangeNotifier`+`copyWith` is the sanctioned
  intermediate.
- In-Stack `GameDialogLayer` → **M21**.
- Lifelines (50:50, audience poll, AI hint, walk-away UI) → **M20**.
- Result persistence redesign (VM-side save, `totalEarnings`/
  `totalQuestionCount`) → **M22**.

## Lessons (canonical)

`AI_HANDOFF/work/milestones/M19/lessons/` — index + 6 (L04 CORE:
`GameScreenViewModel` + state machine; isolated D-33 order-machine
example). Site copies at `web/src/content/docs/m19/` byte-identical
(md5-verified).

## Verification

`flutter analyze` clean; `flutter test` **126/126**;
`flutter build web` pass; `npm run build` — **102 pages** (+7
routes). Sequential replay on M18-end clone: 6/6 checkpoints PASS
(102→95→99→116→126 + build web); 1 teaching gap (L02 menu-assertion
patch) folded into lesson. Senior repo unchanged at `c8eb860`.
