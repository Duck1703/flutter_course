# M20 — Implementation Evidence (Flux)

## Scope executed

Roadmap M20 — lifelines / senior game mechanics: 50:50, audience poll,
simulated AI assistant, walk-away, exit; single-use enable/disable;
feature-button bar; difficulty-keyed poll percentages; simulated
`Future.delayed(700ms)` AI loading; VM-owned `Set<GameFeatureButtonType>`;
`showDialog` dialogs until M21. No DRE, no real AI/network, no in-Stack
dialog layer, no stale-token protection beyond senior's dialog-type
guard.

## Senior source inspected (fresh, this milestone)

| File | Symbols ported |
|---|---|
| `lib/view_models/game/reducer/game_reducer_feature_flow.dart` | `handleFeatureClick` dispatch, `_canUseFeature` (phase `playing` gate; walk-away amount>0; 3 lifelines write `usedFeatureButtons`; walk-away/exit NOT single-use), `_applyFiftyFifty`, `_openAudiencePoll`, `_openAIAssistant` (loading → `Future.delayed(700ms)` → dialog-swap only if still `GameAIAssistantDialog`), `_confirmWalkAway` (→ victory, `isWin:false` result) |
| `lib/view_models/game/support/game_lifeline_helper.dart` | `applyGameFiftyFifty` (keep correct + FIRST wrong, blank rest — deterministic, no random), `buildGameAudiencePoll` (easy 68 / medium 52 / hard 42, remainder split deterministically over wrongs), `buildGameAudiencePollItems` (null→`0%`) — ported **verbatim** |
| `lib/view_models/game/dre/game_dre_state.dart` | `GameState` lifeline fields: `visibleOptionTexts`, `audiencePercentiles`, `usedFeatureButtons`, `hasSavedResult` (learner analogue: `resolvedResult`) |
| `lib/data/game/game_screen_data.dart` | `GameFeatureButtonType` (5 values), `GameFeatureButtonData{type,icon,semanticLabel,isEnabled}`, `GameAnswerOptionData.audiencePercentile`, `GameScreenData.featureButtons` |
| `lib/view_models/game/game_screen_presentation_mapper.dart` | signature +`_visibleOptionTexts`/`_audiencePercentiles`/`_usedFeatureButtons`/`_canWalkAway`, verbatim `_buildAnswers`/`_answerState`/`_buildFeatureButtons` (exit NOT in bar) |
| `lib/view_models/game/bridge/game_screen_view_model_effects.dart` | dialog-event emission for feature flows |
| `lib/widgets/game/lifelines/game_feature_button.dart` + `_bar.dart` | bar = row of buttons; senior button itself is ~200-line animated `CustomPainter`+SVG → **documented visual-depth simplification** |
| `lib/widgets/game/lifelines/game_audience_poll_row.dart` | row = label + `LinearProgressIndicator` + `NN%` |
| `lib/widgets/game/dialogs/game_help_dialogs.dart` + `game_confirm_dialogs.dart` | poll body, AI loading/result body, walk-away confirm (same shape as confirm-exit: message + amount) |
| `lib/l10n/app_vi.arb` / `app_en.arb` | 12 new keys, senior-verbatim |

## Starting learner state (from disk, M19 end)

- `GameSessionState` — 6 phases, 6 dialog variants, `flowToken`,
  `questionIndex`, `moneyEarned`, `guaranteedAmount`, `remainingTime`.
- `GameScreenViewModel` — `submitAnswer`, `startNewGame`,
  `confirmExit`/`backToMenu`/`playAgain`/`dismissDialog`,
  `buildGameResult`, `_runDelayed` token guard.
- `GameScreenData`/`mapper` — M19 signature (no lifeline params).
- `game_screen.dart` — `showDialog` host bound to `dialogState`,
  `_GameDialogAction{dismiss,backToMenu,playAgain}`.

## Target learner state (now on disk)

- `GameSessionState` +4 fields: `visibleOptionTexts` (List<String>),
  `audiencePercentiles` (Map<String,int>?), `usedFeatureButtons`
  (Set<GameFeatureButtonType>), `resolvedResult` (GameResult?).
- Dialog family 6 → 9 variants: +`GameConfirmWalkAwayDialog`
  (`currentAmount`), +`GameAudiencePollDialog` (`items`),
  +`GameAIAssistantDialog` (`isLoading`, `selectedAnswer`,
  `confidencePercentage`, `explanation`); +`GameAudiencePollItemData`
  (`option`, `percentage`, `progress`).
- VM +lifeline surface: `handleFeatureClick(GameFeatureButtonData)`
  (senior name verbatim), `_canUseFeature`, `confirmWalkAway`,
  `_audiencePollItems`; `submitAnswer` guards `answerText.isEmpty`
  (senior-true); `buildGameResult` prefers `resolvedResult`.
- Mapper +4 params + `_buildFeatureButtons` (exit excluded — senior).
- Screen: bottom feature bar (3–4 buttons), blank 50:50 options render
  idle + non-tappable, 3 new dialog arms, `confirmWalkAway` action.
- ARB +12 keys each locale; generated localizations refreshed.

## Files created (learner-app)

- `lib/view_models/game/support/game_lifeline_helper.dart` — **verbatim
  senior port** (3 pure functions).
- `test/game_lifeline_helper_test.dart` — 5 pure-function tests.

## Files modified

- `lib/data/game/game_screen_data.dart` — +`GameFeatureButtonType`,
  +`audiencePercentile`, +`GameFeatureButtonData`, +`featureButtons`.
- `lib/data/game/game_session_state_data.dart` — +3 dialog variants,
  +`GameAudiencePollItemData`, +4 state fields + `copyWith`.
- `lib/view_models/game/game_screen_presentation_mapper.dart` — senior
  signature + verbatim answer/feature-button builders.
- `lib/view_models/game/game_screen_view_model.dart` — feature dispatch,
  poll/AI/walk-away methods, `resolvedResult`, progression resets
  (`visibleOptionTexts`→full options, `audiencePercentiles`→null;
  `usedFeatureButtons` NOT reset — senior keeps per-game).
- `lib/screens/game_screen.dart` — feature bar render + semantic
  labels, blank-option tap guard, `_content`/`_actions` arms for the 3
  new dialogs, `confirmWalkAway` action.
- `lib/l10n/app_vi.arb` / `app_en.arb` — +12 keys:
  `fiftyFiftySemanticLabel`, `askAudienceSemanticLabel`,
  `askAiSemanticLabel`, `walkAwaySemanticLabel`,
  `exitGameSemanticLabel`, `walkAwayTitle`, `walkAwayMessage`,
  `confirmWalkAwayButton`, `keepPlayingButton`, `aiAssistantTitle`,
  `audienceHelpTitle`, `aiThinkingMessage`.
- `lib/l10n/app_localizations*.dart` — regenerated.

## Tests

- NEW `test/game_lifeline_helper_test.dart` — **5 tests**: 50:50
  keeps correct + first-wrong + blanks rest + no bank mutation;
  poll easy 68%/sum 100/deterministic wrong split (16/10/6);
  medium 52, hard 42; `buildGameAudiencePollItems` label/`NN%`/
  progress + null→0.
- `test/game_screen_view_model_test.dart` — **+10 tests** (17→27):
  bar contains 3 buttons when playing (walkAway hidden at 0);
  disabled-button + non-playing-phase `handleFeatureClick` no-ops;
  50:50 blanks exactly 2, single-use, empty option unsubmittable,
  reset on next question while `usedFeatureButtons` persists;
  poll dialog items + `audiencePercentiles` + timer pause/resume +
  percentile persistence until next question;
  AI 700ms loading→result (correctOption, 85%, `aiHintMessage`),
  late-result drop when dialog closed mid-load;
  walk-away hidden/blocked before safe haven, dialog amount, timer
  pause, confirm → victory + `resolvedResult{won:false,20k,6}`;
  walk-away NOT in `usedFeatureButtons`.
- `test/game_screen_presentation_mapper_test.dart` — **+2** (4→6):
  blanked text → idle non-tappable + percentile lookup by text;
  feature-button set, used→`isEnabled:false`, walkAway visibility
  gated by `canWalkAway`.
- `test/widgets/game_screen_test.dart` — **+4** (10→14): bar renders
  3 icons + 50:50 blanks 2 options live + button marks used; poll
  dialog (4 `LinearProgressIndicator`s, 68%) + dismiss; AI
  loading→result UI (answer chip, 85%, hint); walk-away E2E after
  safe haven → victory + `won:false` + `earnedAmount:20000`.
- `test/sealed_state_test.dart` — exhaustive switch extended to the
  9-variant dialog family.

## Results

- `flutter analyze` — **No issues found!** (VERIFIED)
- `flutter test` — **147/147 passed** (M19 final 126, +21). (VERIFIED)
- `flutter build web --release` — **√ Built build\web** (45.1s; font
  tree-shake note only, pre-existing). (VERIFIED)

## Intentional deviations (registered)

- `GameFeatureButton` visuals simplified — senior button is ~200 lines
  of animated `CustomPainter` + layered SVG glow; learner bar is flat
  `IconButton`-style with `isEnabled` opacity. TEACHING_SIMPLIFICATION,
  converges with the visual-parity sweep at **M28** (FR-34 PARTIAL).
- `showDialog` routes remain — in-Stack `GameDialogLayer` is M21
  (FR-07 PARTIAL).
- No DRE — intermediate `ChangeNotifier` VM until M26.
- Simulated AI is **not** a deviation — senior itself is
  `Future.delayed(700ms)` + fixed 85% + `aiHintMessage` (no network).
- `resolvedResult` named differently from senior `hasSavedResult` +
  reducer-resolved result — same semantic (terminal result recorded on
  state, `buildGameResult` reads it); naming deviation cosmetic.
- Exit stays on the screen close affordance (✕ + back routing), NOT in
  the bottom bar — verbatim senior.

## Bugs found & fixed during implementation

- First-frame `RangeError`: mapper indexes `visibleOptionTexts` before
  `startNewGame()` populates it when a test injects a VM. Senior-true
  fix: injected VMs must `..startNewGame()` before pump (senior's
  create-path always starts pre-build); bridge post-frame recovery
  opens the missed intro event.
- `sealed_state_test` exhaustiveness broke on 3 new variants → extended.
- Mapper-test signature drift on 4 new params → local builder defaults.
- `stale-write` environment anomaly: two `edit`-tool writes reported
  success but didn't persist; re-applied via python, verified by grep.

## Content-author guidance (for Lumen)

- Natural lesson split: (1) helper math (50:50 + poll — pure functions,
  deterministic); (2) state fields + `handleFeatureClick`/guards;
  (3) AI simulated flow + dialog isLoading swap; (4) walk-away +
  `resolvedResult` + why `won:false`; (5) widget bar + blank options +
  dialogs wiring; (6) tests/recap.
- First appearances: `Set<T>` as state field, `Map<String,int>?` for
  percentiles, `Future.delayed` staged dialog mutation, `LinearProgressIndicator`,
  `find.descendant`.
- Traps worth teaching: deterministic (non-random) 50:50; used-set is
  per-game not per-question; AI result must not overwrite a dismissed
  dialog (senior guard); walk-away `won:false` despite "victory" phase.
