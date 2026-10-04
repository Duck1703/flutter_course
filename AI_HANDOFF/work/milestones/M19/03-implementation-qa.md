# M19 — Implementation QA (Argus)

## Verdict: FAIL

One MAJOR defect: the sanctioned `showDialog` scaffold makes every game dialog a
separate route, so the Android/web system back button pops the DIALOG route and
never reaches the page-level `PopScope`/`_handleRouteBack`. The senior routing
("ladder/terminal → ignore") is dead code exactly when it matters; popping a
terminal dialog this way strands the player on a dead game screen and loses the
GameResult. Everything else (VM semantics, data files verbatim, mapper, nav,
l10n, tests) is a faithful port.

## Findings

1. **MAJOR** — `lib/screens/game_screen.dart:157-184,197-203,108-127`
   `showDialog` pushes a real route above the game page. `PopScope(canPop:false)`
   at :197 registers on the PAGE route only; when a dialog is open, the system
   back button pops the DialogRoute (unconditionally — `barrierDismissible:false`
   at :167 only blocks barrier taps). `_showCurrentDialog` then resolves
   `action == null` → `_GameDialogAction.dismiss` → `viewModel.dismissDialog()`
   (:176-178). `_handleRouteBack` (:108-127) therefore only ever sees
   `GameDialogHidden`; its ladder/terminal branches are unreachable.
   Concrete failures vs senior (`screens/game_screen.dart:125-140`,
   `widgets/game/dialogs/game_dialog_layer.dart:55-61`):
   - **Terminal dialogs (`GameEndedDialog`/`GameVictoryDialog`):** back pops the
     dialog → `dismissDialog()` falls to the last branch → `dialogState` hidden
     while `phase = gameOver|victory`. Dead screen: ✕ → `showConfirmExit`
     guards `phase == playing` → no-op; answer/money taps likewise guarded; a
     second back → hidden → `showConfirmExit` → no-op. There is NO way out —
     and `AppNavigationController.openGame()` never completes →
     `MenuViewModel.applyGameResult` never runs → the played session is lost.
     Senior ignores back on terminal dialogs so a button choice is forced.
   - **Intro `GameMoneyLadderDialog` (phase `notStarted`):** back → dismiss →
     `dismissDialog` matches "ladder && notStarted" → transitions to `playing`
     and starts the timer — back literally starts the game. Senior ignores it.
   - **Mid-game `GameMoneyLadderDialog`:** back closes it (senior: ignored —
     `_canDismissFromBackdrop` is also false for the ladder).
   - `GameConfirmExitDialog`/`GameExplanationDialog` on back → dismiss — this
     coincidentally equals senior routing.
   Fix direction (staying inside M19's showDialog scaffold): wrap
   `_GameDialogHost` in a `PopScope` mirroring senior rules — canPop false for
   `GameMoneyLadderDialog`/terminal variants (and swallow the invocation), allow
   pop for `GameConfirmExitDialog`/`GameExplanationDialog` — or use
   `showDialog`'s route settings to intercept. Regression coverage needed: a
   widget test that simulates back (`tester.binding.handlePopRoute()` /
   `Navigator.maybePop`) with each dialog open.

2. **MINOR** — `lib/view_models/game/game_screen_view_model.dart:77-87`
   `startNewGame` rebuilds state as `GameSessionState.initial` whose
   `flowToken` is 0. Senior `_startGame` (`reducer/game_reducer_session_flow.dart:9`)
   does `flowToken: state.flowToken + 1` — tokens are monotonic for the VM's
   lifetime. Resetting to 0 breaks that invariant: a stale delayed callback
   survives if the next session reuses the same token value
   (submit → token 1 → playAgain → token 0 → submit → token 1: the FIRST
   reveal callback fires at its original delay while `flowToken` is again 1 →
   `_onRevealElapsed` mutates the fresh session). Compounding it, learner drops
   senior's second guard — `phase == answeredPending`/`answeredRevealed`
   re-checks in `_revealAnswer`/`_showExplanation`
   (`reducer/game_reducer_answer_flow.dart:27-28,64-65`) — so token equality is
   the only guard in `_onRevealElapsed`/`_onExplanationElapsed` (:212,:236).
   Unreachable via current product UI (playAgain only exists on terminal
   dialogs, where nothing is pending), but reachable through the public API and
   a real divergence from the reducer contract. One-line fix:
   `.copyWith(dialogState: ..., flowToken: _state.flowToken + 1)`.

3. **MINOR** — `game_screen_view_model.dart:258-298` — senior zeroes
   `remainingTime` on victory, game over and back-to-menu
   (`session_flow` :52, :84, :119); learner leaves the last countdown value.
   Timer text behind terminal dialogs shows a stale remainder (e.g. "00:17")
   instead of senior's "00:00". Cosmetic but a fidelity miss.

4. **NIT** — `game_screen_view_model.dart:143` — early-returns on
   `GameDialogHidden`; senior `_dismissDialog` falls through (re-hide +
   StartTimer-if-playing). Harmless, arguably cleaner.

5. **NIT** — `lib/l10n/app_*.arb:55-56` — pre-existing `menuButton`/`playAgainButton`
   values differ from senior ("MENU"/"VỀ MENU", "PLAY AGAIN"/"CHƠI LẠI" vs
   senior "Menu"/"Menu", "Play Again"/"Chơi lại"); UI `.toUpperCase()` gives
   display parity. The 9 NEW keys are verbatim senior (verified both locales).

6. **NIT** — `_walkAwayAmount` (:355) is inlined in the VM instead of copying
   senior's `calculateGameWalkAwayAmount` helper (deferred to M20 per comment);
   formula is semantically identical (`guaranteed>0 ? max(g,m) : 0`).

7. **TOOLING NOTE** — during review, `read` intermittently served stale
   snapshots (menu_screen.dart, widgets/game_screen_test.dart,
   game_screen_view_model_test.dart each showed an older import/assertion set
   than grep). All findings below were re-verified against live content via
   grep. Parent should re-run `flutter analyze`/`flutter test` rather than
   trusting the claim — claimed results (analyze clean, 121/121) are plausible
   against the live tree but unverifiable in this read-only pass.

## Senior-fidelity checklist results

1. **VM transition semantics — MISMATCH (finding 1 & 2).**
   - submitAnswer only in `playing` + non-empty text: OK (:92, senior
     `answer_flow:8`).
   - timeout → `selectedAnswer=''` + pending→reveal→explanation: OK (:325-336).
   - correct reveal → `moneyEarned = ladder[index].amount`, safe haven →
     `guaranteedAmount`: OK (:212-231 vs `answer_flow:32-47`), incl.
     `moneyAnimationTrigger` bump condition.
   - dismissDialog routing (intro→playing+timer; explanation→next/end;
     else hidden+resume-if-playing): OK in the VM (:141-170) — but see finding 1
     for the route-level bypass that makes terminal/ladder dismissal reachable.
   - explanation `explainForTrueAnswer` / `explainForWrongAnswers[selected] ??
     aiHintMessage`: OK (:241-251, verbatim ordering).
   - walkAway formula `guaranteed>0 ? max(guaranteed,earned) : 0`: OK (:355-360).
   - flowToken stale-guard: PARTIAL — works intra-session; `startNewGame`
     resets token to 0 instead of senior's `+1` (finding 2); missing phase
     re-checks in delayed handlers (finding 2).
   - dispose cancels timer + closes stream, broadcast events, `_isDisposed`:
     OK (:38,:373-379).
   - no DRE types anywhere: OK (grep-verified — `DreChangeNotifier`/`GameReducer`/
     `GameEffect`/`GameAsyncOp` appear only in doc comments).

2. **game_session_state_data.dart — OK.** 6 `GamePhase` values verbatim order;
   6 dialog variants (Hidden, MoneyLadder+`GameMoneyLadderItemData`,
   ConfirmExit{guaranteedAmount}, Explanation{question,correctAnswer,
   explanation,isCorrect}, Ended{earnedAmount}, Victory{earnedAmount,
   affirmationMessage}) — senior field names/shapes; `GameScreenUiEvent` sealed
   (NavigateToMenu + GameDialogRequested scaffold, FR-16 recorded);
   `GameSessionState` immutable + `initial()` + copyWith with
   `clearSelectedAnswer` flag (:216-244). M20+/M22 fields correctly absent.

3. **game_screen_data.dart + mapper — OK.** `GameAnswerState`/Money/Question/
   AnswerOption/Timer classes = senior minus M20 (`audiencePercentile`,
   `featureButtons`, `GameFeatureButtonType` all absent — grep-verified).
   `_answerState` derivation equivalent (pending→selected-only-on-chosen;
   revealed→correct-green/chosen-red/idle); senior's `optionText.isEmpty` guard
   correctly omitted (no `visibleOptionTexts` in learner). Timer `progress`
   clamp + mm:ss `formattedTime` identical to senior. A–D labels via
   `String.fromCharCode(65+index)` ✓.

4. **Verbatim data — OK.** `game_quiz_question_data.dart`,
   `game_sample_{easy,medium,hard}_questions_data.dart`, combinator,
   `game_money_ladder_data.dart` (15 levels, isSafeHaven 5/10/15, amounts
   {1k,2k,5k,10k,20k,40k,80k,150k,250k,400k,500k,600k,750k,900k,1M}),
   `game_money_formatter.dart`, `buildGameMoneyLadderItems` — all byte-level
   identical to senior.

5. **game_screen.dart — MISMATCH (finding 1).** StatelessWidget +
   ChangeNotifierProvider (plus a `ChangeNotifierProvider.value` test-injection
   branch — learner convenience, sensible); `_GameScreenEventBridge`
   StatefulWidget owns the `uiEvents` subscription; `PopScope(canPop:false,
   onPopInvokedWithResult)` present; `_handleRouteBack` codes the senior
   routing; tap-answer → `submitAnswer` immediately (no submit/next button);
   money tap → `showMoneyLadder`; ✕ → `showConfirmExit`; `showDialog` scaffold
   bound to `dialogState` + `GameDialogRequested` with `_dialogOpen` re-entrancy
   guard and post-frame bridging. BUT: routing is ineffective whenever a dialog
   is open — see finding 1 (terminal→ignore NOT honored; dead screen reachable;
   GameResult lost).

6. **app_navigation_controller.dart — OK.** `GlobalKey<NavigatorState>`,
   `openGame` pushes `MaterialPageRoute<GameResult>` → `const GameScreen()`,
   `goBack([result])` → `canPop`+`pop(result)`, unattached-key `StateError` —
   senior verbatim + registered `Future<GameResult?>` transport (FR-04).

7. **main.dart — OK.** `await SystemChrome.setPreferredOrientations(
   [DeviceOrientation.portraitUp])` immediately after `ensureInitialized`
   (:29-30, = senior :23-24); `navigatorKey` wired on MaterialApp (:69);
   controller created in `main()` (:34) and registered via
   `Provider<AppNavigationController>.value` in `app_dependency_scope.dart:61`.

8. **menu_screen.dart — OK.** `_openGame` →
   `context.read<AppNavigationController>().openGame()`, result applied via
   `viewModel.applyGameResult(result)` with `mounted`/`null` guards
   (:131-136, grep-verified live).

9. **user_profile_data.dart + game_result.dart — OK.** `applyGameResult` money
   = `result.earnedAmount` (:130, flat `moneyPerCorrectAnswer` policy gone —
   no references anywhere); EXP still `correctAnswers * expPerCorrectAnswer`
   (count-based, M22 owns the change) ✓; `GameResult` gains `earnedAmount`,
   `questionsAnswered` documents `questionIndex+1` semantics.

10. **l10n — OK.** All 9 new keys present verbatim in both arb files and the
    generated `app_localizations*` (moneyLadderTitle, exitGameTitle/Message/
    Button, continuePlayingButton, aiExplanationsTitle, understandButton,
    youEarnedLabel, congratulationsTitle); `nextButton` retained legitimately —
    used by `onboarding_overlay.dart` (not a dead key); no leftover references
    to removed keys (grep clean).

11. **No unused imports / dead code — OK** on the live tree (the live
    `game_screen_view_model_test.dart` has 6 imports, all used; earlier stale
    snapshot suggested an unused `game_screen_data` import — not present).
    No references to deleted `quiz_question.dart`/`quiz_questions.dart` (files
    confirmed absent; only build artifacts mention the new name). No
    `moneyPerCorrectAnswer`, `GameEndReason`, `SharePlus`/`share_plus` in
    pubspec, no in-Stack dialog layer, no lifeline fields.

12. **Tests — OK (real behavior).** `game_screen_view_model_test.dart` uses
    FakeAsync to drive real transitions: intro ladder + event, tick to 27s,
    pending→revealed money/trigger, wrong-answer fallback to `aiHintMessage`,
    next-question timer reset, 30s timeout auto-flow, safe-haven $20k
    end-game carry, victory payload, ladder pause/resume (10s frozen),
    phase guards, playAgain-token invalidation, dispose-safety, and
    `buildGameResult` field assertions. `game_sample_questions_test.dart`
    asserts real invariants (15↔15, correctOption∈options, per-wrong-option
    explanation presence, safe-haven positions/amounts, monotonic ladder,
    `$` formatting). `widgets/game_screen_test.dart` (10 tests) drives the
    real flow incl. menu→game→exit→profile-write persistence check.
    `sealed_state_test.dart` is structural but exercises all 6 variants.
    No assertions that can't fail. Gaps worth noting (not blockers by
    themselves): no test presses back WITH a dialog open — exactly where
    finding 1 lives; the flowToken test (:303-321) passes because the reset
    token 0≠1 and would NOT catch the token-reuse collision in finding 2.

13. **Style — OK.** `dart:async`+`unawaited` present wherever used (VM:1/347,
    game_screen:1/92,145, menu_screen:1); 2-space indent, trailing commas,
    const constructors throughout; Vietnamese comments are documentation-quality.

Extra check: `onboarding_content_data.dart:11` reads `gameSampleQuestions.length`
(=15) ✓.

## Regression note

- Pre-M19, the old `_GameScreenState` also used `showDialog` for its result
  dialogs, so a back-pop dismissing a terminal dialog may pre-date this change —
  but the milestone's acceptance criterion is the senior routing, which is now
  verifiably inert for open dialogs. Fixing finding 1 requires either a
  PopScope inside the dialog builder or an explicit dismiss-action contract;
  do NOT wait for M21's `GameDialogLayer` to land this.
- The remaining divergences (findings 2-4) are small, additive fixes:
  `flowToken: _state.flowToken + 1` in `startNewGame`; optional phase re-checks
  in the two delayed handlers; `remainingTime: Duration.zero` in the victory/
  gameOver/backToMenu transitions.
- After fixes: add a widget test simulating back on each dialog variant
  (terminal → stays; ladder → stays; confirm/explanation → dismiss) and a VM
  test chaining submit→playAgain→submit within one FakeAsync window to pin the
  token monotonicity.

---

## Remediation status (parent, post-FAIL)

- **F-1 (MAJOR, showDialog route back bypass):** FIXED — `_showCurrentDialog` now detects `action == null` (system back popped the dialog route) and re-applies senior `_handleRouteBack` semantics: `GameMoneyLadderDialog`/`GameEndedDialog`/`GameVictoryDialog` → back ignored (dialog re-opened from `dialogState`); `GameConfirmExitDialog`/`GameExplanationDialog` → `dismissDialog()`. Regression test added: `back hệ thống: intro ladder & dialog kết thúc bị BỎ QUA…` using `tester.binding.handlePopRoute()` — verifies intro-ladder re-open, no-dialog back → confirm-exit, confirm-exit back → dismiss, ended-dialog back → ignored.
- **F-2 (MINOR, flowToken reset):** FIXED — `startNewGame` now emits `flowToken: _state.flowToken + 1` (monotonic, verbatim senior `_startGame`). Phase re-checks added to `_onRevealElapsed`/`_onExplanationElapsed` (senior `answeredPending`/`answeredRevealed` guards).
- **F-3 (MINOR, stale remainingTime):** FIXED — `remainingTime: Duration.zero` on victory, game-over and `backToMenu` (senior parity).
- **F-4 (NIT, hidden-dismiss early return):** kept — behavior-equivalent, cleaner.
- **F-5 (NIT, menuButton/playAgainButton values):** pre-existing learner strings; out of M19 scope (FR-31 tracked).
- **F-6 (NIT, inline walk-away):** FIXED — `calculateGameWalkAwayAmount` copied verbatim into `support/game_money_ladder_mapper.dart`; VM calls it.
- **F-7 (TOOLING):** acknowledged — stale-read anomaly confirmed on this host; all findings re-verified via grep before remediation.

Post-remediation: `flutter analyze` clean, `flutter test` 122/122 (added 1 back-routing regression test).
