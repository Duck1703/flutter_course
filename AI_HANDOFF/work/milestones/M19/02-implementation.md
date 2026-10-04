# M19 — Implementation Evidence (Flux)

## Scope executed

Structured game architecture convergence: monolithic stateful `GameScreen`
→ `GameScreenViewModel extends ChangeNotifier` + immutable
`GameSessionState` + pure presentation mapper + VM-owned timer +
six-phase `GamePhase` + real money ladder + `AppNavigationController` +
`PopScope` + portrait lock. DRE intentionally absent (roadmap → M26).

## Senior source inspected (fresh, this milestone)

- `lib/view_models/game/game_screen_view_model.dart` (DreChangeNotifier
  surface — method names mirrored, not ported)
- `lib/view_models/game/game_reducer.dart` +
  `reducer/game_reducer_session_flow.dart` / `game_reducer_answer_flow.dart` /
  `game_reducer_feature_flow.dart` (transition semantics)
- `lib/view_models/game/game_reducer_timer_flow.dart` (tick/timeout)
- `lib/view_models/game/game_screen_presentation_mapper.dart`
- `lib/view_models/game/support/game_money_formatter.dart` (copied verbatim)
- `lib/view_models/game/support/game_money_ladder_mapper.dart` (items +
  `calculateGameWalkAwayAmount`, both copied verbatim semantics)
- `lib/data/game/game_quiz_question_data.dart` (verbatim copy)
- `lib/data/game/game_sample_{easy,medium,hard}_questions_data.dart` +
  `game_sample_questions_data.dart` (verbatim copies — 15 questions)
- `lib/data/game/game_money_ladder_data.dart` (verbatim copy — 15 levels,
  safe havens 5/10/15)
- `lib/data/game/game_session_state_data.dart` (phase enum + dialog
  variants — M19 subset ported)
- `lib/data/game/game_screen_data.dart` (verbatim minus M20 fields)
- `lib/navigation/app_navigation_controller.dart` (verbatim + typed
  `openGame`/`goBack(result)` for M10 transport)
- `lib/screens/game_screen.dart` (event-bridge + PopScope pattern)
- `lib/widgets/game/dialogs/game_dialog_layer.dart`,
  `game_help_dialogs.dart`, `game_result_dialogs.dart`,
  `game_confirm_dialogs.dart` (dialog content/l10n keys — in-Stack layer
  itself is M21, not ported)
- `lib/main.dart` (portrait lock), `lib/core/app_dependency_scope.dart`
- `lib/l10n/app_en.arb` / `app_vi.arb` (9 dialog keys ported verbatim)

## Files created (learner-app)

| File | Origin |
|---|---|
| `lib/data/game/game_quiz_question_data.dart` | verbatim senior |
| `lib/data/game/game_sample_easy_questions_data.dart` | verbatim senior |
| `lib/data/game/game_sample_medium_questions_data.dart` | verbatim senior |
| `lib/data/game/game_sample_hard_questions_data.dart` | verbatim senior |
| `lib/data/game/game_sample_questions_data.dart` | verbatim senior |
| `lib/data/game/game_money_ladder_data.dart` | verbatim senior |
| `lib/data/game/game_screen_data.dart` | senior minus `featureButtons`/`audiencePercentile` (M20) |
| `lib/view_models/game/game_screen_view_model.dart` | NEW — senior method surface on ChangeNotifier |
| `lib/view_models/game/game_screen_presentation_mapper.dart` | senior minus M20 params |
| `lib/view_models/game/support/game_money_formatter.dart` | verbatim senior |
| `lib/view_models/game/support/game_money_ladder_mapper.dart` | verbatim senior |
| `lib/navigation/app_navigation_controller.dart` | senior + typed result transport |

## Files rewritten

- `lib/data/game/game_session_state_data.dart` — 3-phase → 6-phase
  (`notStarted/playing/answeredPending/answeredRevealed/gameOver/victory`),
  dialog family 3 → 6 variants (+`GameMoneyLadderDialog`,
  `GameConfirmExitDialog`, `GameExplanationDialog`; Ended/Victory now
  carry `earnedAmount`, `GameEndReason` removed), new immutable
  `GameSessionState` + `flowToken`, new `GameScreenUiEvent` sealed family
  (`GameNavigateToMenuEvent`, `GameDialogRequested` scaffold).
- `lib/screens/game_screen.dart` — 629-line stateful owner →
  `ChangeNotifierProvider` + stateful event bridge (`_GameScreenEventBridge`)
  + `PopScope(canPop:false)` + render-from-`screenData` + showDialog
  scaffold bound to `dialogState`.
- `lib/data/game/game_result.dart` — +`earnedAmount` (ladder-based).
- `lib/data/profile/user_profile_data.dart` — `applyGameResult` money =
  `result.earnedAmount` (flat `moneyPerCorrectAnswer` policy removed).
- `lib/data/onboarding/onboarding_content_data.dart` — count reads
  `gameSampleQuestions.length` (15).
- `lib/core/app_dependency_scope.dart` — +`AppNavigationController` entry
  (senior `Provider.value` shape).
- `lib/main.dart` — portrait lock + `navigatorKey` + controller created
  in `main()`.
- `lib/screens/menu_screen.dart` — `_openGame` via
  `AppNavigationController.openGame()` (await still returns result).
- `lib/l10n/app_en.arb` / `app_vi.arb` — +9 senior dialog keys verbatim;
  12 dead learner keys removed (old dialog model + submit/next buttons).

## Files deleted

- `lib/data/game/quiz_question.dart`, `quiz_questions.dart`
  (4-question mini bank → replaced by senior 15-question bank).

## Tests

- NEW `test/game_screen_view_model_test.dart` — 15 tests over FakeAsync:
  initial state, intro ladder + event, playing+tick, submit→pending→
  reveal→explanation (correct & wrong incl. `explainForWrongAnswers`
  fallback to `aiHintMessage`), mid-game advance + timer reset, timeout
  auto-flow, safe-haven guaranteed amount ($20k kept on Q6 loss),
  victory, ladder/confirm-exit pause-resume, phase guards, flowToken
  invalidation on playAgain, dispose safety, `buildGameResult` fields.
- NEW `test/game_sample_questions_test.dart` — bank/ladder/formatter
  integrity (15 questions ↔ 15 levels, correctOption∈options,
  explanation completeness, safe-haven positions, `$` formatting).
- REWRITTEN `test/widgets/game_screen_test.dart` — 10 widget tests over
  the new flow (intro ladder → dismiss → tap-to-submit → reveal →
  explanation → next/end, timeout, mid-game ladder pause, confirm-exit
  stay/exit, victory, menu→game→exit→profile write).
- UPDATED `test/sealed_state_test.dart` (6-variant exhaustive switch),
  `test/user_profile_data_test.dart` + `menu_view_model_test.dart`
  (`earnedAmount`), `menu_provider_scope_test.dart` +
  `menu_screen_ui_events_test.dart` (nav controller in scope),
  `test/helpers/localized_test_app.dart` (`navigatorKey` param).

## Results

- `flutter analyze` — **No issues found!**
- `flutter test` — **121/121 passed** tại thời điểm viết evidence (baseline 102, +19); sau remediation +1 back-routing test = 122/122 tại approval; sau Lumen-stage mapper test file = **126/126** cuối.
- `flutter build web --release` — **Built build\web** (font tree-shake
  note only; pre-existing)

## Intentional deviations (registered)

- No DRE (`DreChangeNotifier`/reducer/effects) — intermediate
  `ChangeNotifier` VM per roadmap, DRE at M26. Method names mirror
  senior surface.
- `GameDialogRequested` event + `showDialog` scaffold until M21's
  in-Stack `GameDialogLayer` (FR-07 remains PARTIAL).
- `openGame()` returns `Future<GameResult?>` (M10 transport until
  M22 VM-side save, FR-04).
- No lifelines / audience poll / AI assist / walk-away feature button —
  M20 scope.
- No `GameShareResultEvent`/SharePlus — unassigned (FR-33).
- Victory affirmation is a hardcoded English string — verbatim senior.

## Bugs found & fixed during implementation

- Provider-mount crash: `startNewGame()` on injected VM during
  `didChangeDependencies` → notify while mounting → `!_dirty` assert.
  Fixed: auto-start + dialog-open deferred to post-frame.
- Test-writer error (not product bug): assumed walk-away > 0 before
  first safe haven; senior `calculateGameWalkAwayAmount` returns 0
  until guaranteed > 0 — test corrected to senior semantics.
