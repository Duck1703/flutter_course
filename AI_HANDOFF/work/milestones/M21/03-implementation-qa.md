# M21 — Implementation QA (Argus)

## Verdict: PASS

Independent review of the M21 convergence (state-driven in-`Stack`
dialog layer + PopScope back choreography) against senior @ c8eb860 and
the M21 brief. Green paths verified by execution; every claimed
mechanism traced to senior source line-by-line. Deviations found are
cosmetic or documentation-level only — none behavioral.

## Environment verification

- `flutter analyze`: **PASS** — "No issues found!" (1.5s)
- `flutter test`: **PASS** — 157/157 (matches evidence: 147 pre-M21 +
  10 new `game_dialog_layer_test.dart` tests)
- `flutter build web`: **PASS** — "Built build\web" (27.2s, wasm dry-run
  succeeded)
- `showDialog|AlertDialog|GameDialogRequested|OverlayEntry` grep over
  `learner-app/lib`: **zero call sites in game surface** — only doc
  comments + menu-side `settings_dialog.dart`/`menu_screen.dart`
  (`showDialog` retained per M29 scope — not a defect)

## Checklist results

- [x] Senior fidelity — structure matches senior layer/screen
- [x] Zero showDialog in game surface
- [x] 9-variant parity + GameDialogRequested retired
- [x] VM semantics preserved (pause/resume, guards, single source of truth)
- [x] Test quality — behavior asserts, none weakened
- [x] Deviations — all within permitted simplifications (see Minor #1
      for a token-value note)
- [x] Regression — M20 behaviors intact (all lifeline/exit tests pass)

## Findings

### Critical (blocks PASS)

None.

### Major

None.

### Minor / Notes

1. **`spacingLg` token value differs from senior** — learner
   `MenuTokens.spacingLg = 24` (`lib/core/menu_tokens.dart:14`) vs
   senior `AppTokens.spacingLg = 20` (`app_design_tokens.dart:21`).
   `_DialogBackdrop`'s `SafeArea(minimum: EdgeInsets.symmetric(
   vertical: spacingLg))` therefore renders 24px vs senior's 20px —
   a 4px cosmetic inset delta. Notably, the brief's own fidelity table
   (01-brief.md line 33) recorded senior's `spacingLg` as `24`, which
   is factually wrong — the implementation matched the brief's
   (erroneous) documented value, not the senior constant. The whole
   `MenuTokens` spacing scale is a standing learner simplification
   (visual fidelity → M28 per FR-32/FR-34), so impact is nil, but
   lesson authors citing "senior `spacingLg`" should say 20. Also
   affects `_GameDialogCard` padding (24 vs 20) — same rationale,
   card chrome is M28 scope anyway.
2. **Stale route-era comments in `test/widgets/game_screen_test.dart`**
   — `dismissIntroLadder` lines 87–88 ("post-frame B (showDialog) →
   dialog route build"), line 94 ("// pop anim"),
   `answerAndAdvance` lines 103–104 ("post-frame mở dialog" /
   "// build route"), and the menu-flow test line 361 ("// post-frame
   B → showDialog") still narrate the retired route mechanism. The
   evidence file claims "comments updated (no more 'pop anim'/'dialog
   route')" — that claim is only partially true. Pumps themselves are
   harmless extras; asserts are correct. Doc hygiene only, but worth
   fixing before learners read these tests (M21 lesson 05 cites them).
3. **`_afterExit` terminal path has no dedicated test** — implemented
   (roadmap-optional) but no test taps `CHƠI LẠI`/`VỀ MENU` on a
   terminal dialog to assert the dismiss→await-300ms→action
   choreography or the `_terminalActionPending` double-tap guard.
   Senior's own 355-LOC test file does not cover it either
   (screen-level, not layer-level), so coverage matches the model —
   noting the gap, not a defect.
4. **Evidence LOC claim off** — "Rewritten 1095→269 LOC" for
   `game_screen.dart`; actual file is 588 LOC (the
   `GameScreen`+`_GameScreenEventBridge` portion ends at line 269;
   private widgets `_GameTopBar`/`_QuestionPanel`/`_QuestionCard`/
   `_AnswerOption`/`_GameFeatureBar`/`_GameFeatureButton` occupy the
   rest). Process-accuracy note only.
5. **`AnnotatedRegion<SystemUiOverlayStyle>` absent** — senior wraps
   the game screen in it (`game_screen.dart:76`); it is missing
   learner-wide (zero references in `learner-app/lib`). Pre-existing
   course-wide simplification (status-bar chrome → M28 visual scope),
   not an M21 regression.
6. **Learner-only `GameScreen({this.viewModel})` injection seam**
   (`game_screen.dart:31`) — senior ctor takes repositories. Pre-
   existing test seam retained intentionally; documented in-file.
7. **`_handleUiEvent` is sync `void`** (senior's is `async`) — correct:
   the only remaining event (`GameNavigateToMenuEvent`) needs no await;
   SharePlus handling is M27.
8. **Evidence confirmed-accurate where it matters**: 10 layer tests
   exist and assert behavior (keyed swap, reduced-motion immediate
   removal, outgoing-lingers-during-exit, terminal/ladder
   animate-out-then-remove, tap-outside allow/block, `ĐÃ HIỂU`
   dispatch, plus a learner-extra proving same-`runtimeType`-key
   payload swap does NOT re-animate — the AI loading→result case).
   Screen tests use real `tester.binding.handlePopRoute()` to exercise
   `PopScope` end-to-end. The 300→400ms dismiss pumps are documented
   timing headroom (reverse controller starts a frame after the swap
   build), not weakened asserts — all still expect `findsNothing`.

## Evidence inspected

**Senior (read @ c8eb860, read-only):**
- `lib/widgets/game/dialogs/game_dialog_layer.dart` (full, 191 LOC):
  `GameDialogLayer.build`, `_canDismissFromBackdrop`, `_isTerminalDialog`,
  `_buildTransition`, `_layerChild`, `_dialogBody`, `_DialogBackdrop`
- `lib/screens/game_screen.dart` (full, 201 LOC): `PopScope` +
  `onPopInvokedWithResult`, `_handleRouteBack` decision table, Stack
  order, `_afterExit`/`_terminalActionPending`, `_handleUiEvent`
  (incl. `GameShareResultEvent` → SharePlus + clipboard fallback)
- `lib/data/game/game_session_state_data.dart` (full): 9 sealed
  `GameDialogState` variants + `GameScreenUiEvent` family
  (`GameNavigateToMenuEvent`, `GameShareResultEvent`)
- `lib/view_models/game/reducer/game_reducer_session_flow.dart`
  (full): `_dismissDialog`/`_loadNextQuestionOrVictory`/`_endGame`/
  `_confirmWalkAway`/`_backToMenu`/`_withSaveResult` — pause/resume
  effects verified against learner VM
- `lib/view_models/game/reducer/game_reducer_feature_flow.dart`
  (full): `_showMoneyLadder`/`_showConfirmExit`/`_showConfirmWalkAway`/
  `_showAudiencePoll`/`_showAIAssistant` — all emit `GamePauseTimer`,
  matching learner `_stopTimer()`
- `lib/core/app_design_tokens.dart`: `dialogMotionLong=300ms`,
  `dialogHazeBlurSigma=16`, `dialogHazeScrim=0x00000000`,
  `screenDesignWidth=375`, `spacingSm=12`/`spacingMd=16`/`spacingLg=20`
- `lib/widgets/common/design_frame.dart` (full): `Center` +
  `ConstrainedBox(maxWidth: 375)` — confirms learner inline
  `ConstrainedBox(375)` equivalent
- `lib/widgets/game/money/game_money_ladder_dialog.dart`:
  `GameMoneyLadderDialogView(data, onDismiss)` signature parity
- `test/widgets/game_dialog_layer_test.dart` (full, 355 LOC): the
  behavioral model the learner tests port

**Learner (review target):**
- `lib/widgets/game/game_dialog_layer.dart` (full, 215 LOC)
- `lib/widgets/game/game_dialog_views.dart` (full, 671 LOC): all 9
  views + `_GameDialogCard`/`_ConfirmMessage`/`_EarnedContent`/
  `_DialogTextButton`; no share button anywhere (FR-33 honored)
- `lib/screens/game_screen.dart` (full, 588 LOC)
- `lib/data/game/game_session_state_data.dart` (full): 9 variants
  1:1 with senior (names + fields); `GameDialogRequested` absent
  (retirement note only); `GameScreenUiEvent` = nav-only
- `lib/view_models/game/game_screen_view_model.dart` (full, 611 LOC):
  zero `GameDialogRequested` emissions; `dialogState` single source of
  truth; `_stopTimer`/`_startTimer` placement identical to senior
  Pause/Start effects; guards (`playing`-only for ladder/exit/
  walk-away; `walkAwayAmount > 0`; token+dialog-type double guard for
  AI result) unchanged
- `lib/core/menu_tokens.dart` (full): dialog tokens verbatim
  (300ms / σ16 / transparent scrim)
- `lib/navigation/app_navigation_controller.dart`: `goBack<T>([T?
  result])` — supports `GameResult` transport (M10 → M22)
- `test/widgets/game_dialog_layer_test.dart` (full, 305 LOC, 10 tests)
- `test/widgets/game_screen_test.dart` (full, 518 LOC, 14 tests)
- `test/game_screen_view_model_test.dart` (full, 652 LOC): M21 change
  verified — `startNewGame` asserts `uiEvents` empty + `dialogState`
  is `GameMoneyLadderDialog` (behavioral proof of event retirement)
- `test/helpers/localized_test_app.dart`: `locale: vi` pin confirmed

**Not modified:** no files changed under review; senior repo untouched.
Commands run read-only (`flutter analyze`, `flutter test`,
`flutter build web`, `git log` — learner-app is not a git repo, so
no diff against M20 snapshot was possible; comparison was done
against senior + brief directly).

## Reverify (post-remediation)

**Verdict: REVERIFIED-PASS**

- `test/widgets/game_screen_test.dart` (now 520 LOC, 14 tests):
  Minor #2 resolved — route-era wording gone from `dismissIntroLadder`
  (lines 86–87 now describe the in-tree `dialogState` layer), the
  "// pop anim" site now documents the 400ms boundary (lines 94–95),
  and the menu-flow comment reads "dialog mở bằng dialogState"
  (line 363). The only `AlertDialog` mention left (line 486) is a
  correct new note stating there is none. Asserts unchanged — every
  `findsNothing` still `findsNothing`; nothing weakened.
- Pump bumps confirmed as claimed: `dismissIntroLadder` (line 96) and
  `answerAndAdvance` (line 110) now pump 400ms on dismiss paths —
  consistent with the already-documented reverse-animation boundary
  rationale; other 400ms dismiss pumps (294/328/361/435/461) predate
  this change.
- `02-implementation.md`: LOC claim corrected to 588 (line 31,
  matches actual file). Note: the reported `spacingLg` item 5 is not
  present — simplifications still list 4 items and `spacingLg` does
  not appear in the file; doc-hygiene gap only, Minor #1 already
  carries the finding.
- `flutter analyze`: clean — "No issues found! (ran in 1.4s)".
- `flutter test`: **157/157 PASS** — "All tests passed!".
