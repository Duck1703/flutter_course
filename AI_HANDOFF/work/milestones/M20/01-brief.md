# M20 BRIEF — Lifelines & feature buttons

Milestone: **M20** — 50:50, audience poll, simulated AI hint,
walk-away, exit as single-use VM-owned features.
Roadmap source: `project-context/MILESTONE_ROADMAP.md` §M20
(read live). Prerequisite: M19 (`MILESTONE_COMPLETE`).

---

## SENIOR FIDELITY CHECK

Inspected live at `main @ c8eb860` (clean):

| Surface | Senior file / symbol |
|---------|---------------------|
| Feature dispatch | `view_models/game/reducer/game_reducer_feature_flow.dart` — `_selectFeature` (public: `handleFeatureClick(GameFeatureButtonData)` → `isEnabled` guard → dispatch), `_canUseFeature`, `_useFiftyFifty`, `_showAudiencePoll`, `_showAIAssistant`, `_showConfirmWalkAway`, `_showConfirmExit`, `_showAIAssistantResult` |
| Helpers (pure) | `view_models/game/support/game_lifeline_helper.dart` — `applyGameFiftyFifty`, `buildGameAudiencePoll`, `buildGameAudiencePollItems`, `_splitWrongAudience` |
| State fields | `view_models/game/dre/game_dre_state.dart` — `visibleOptionTexts` (`List.unmodifiable`), `audiencePercentiles` (`Map.unmodifiable`/null), `usedFeatureButtons` (`Set.unmodifiable`), `hasSavedResult` |
| Dialog variants | `data/game/game_session_state_data.dart` — `GameConfirmWalkAwayDialog(currentAmount)`, `GameAudiencePollDialog(items)`, `GameAudiencePollItemData{option,percentage,progress}`, `GameAIAssistantDialog{selectedAnswer,confidencePercentage,explanation,isLoading}` |
| Screen data | `data/game/game_screen_data.dart` — `GameFeatureButtonType` (5), `GameFeatureButtonData{type,iconAsset,semanticLabel,isEnabled}`, `GameAnswerOptionData.audiencePercentile` + `clearAudiencePercentile`, `GameScreenData.featureButtons` |
| Mapper | `view_models/game/game_screen_presentation_mapper.dart` — `_buildAnswers(visibleOptionTexts,audiencePercentiles)`, `_answerState` (`optionText.isEmpty→idle` first), `_buildFeatureButtons` (3 always + walkAway iff `canWalkAway`; **exitGame NOT in bar**), `_feature` (`isEnabled = canPlay && !used`) |
| AI delay | `game_screen_view_model.dart` — `_aiAssistantDelay = 700ms`; effect `_scheduleAIAssistant` → `GameAIAssistantElapsed(token)` → `_showAIAssistantResult` guarded by `flowToken` + `dialogState is GameAIAssistantDialog`; result = `correctOption`, **85%**, `question.explanation.aiHintMessage` |
| Walk-away | `_confirmWalkAway` → `phase: victory`, `remainingTime: 0`, `GameVictoryDialog(earnedAmount: format(walkAmt), affirmationMessage literal)`, save `isWin: false`, `earnedAmount: amount` |
| Exit | `_showConfirmExit` (phase playing only) → `GameConfirmExitDialog(guaranteedAmount: format(walkAway))`, pause; confirm → `_backToMenu` (zero time, save walk-away, `isWin:false`, `GameNavigateToMenu`) |
| Dismiss | generic branch — hidden + `GameStartTimer` iff `playing` (poll/AI/confirm dialogs ride it) |
| Widgets | `widgets/game/lifelines/game_feature_button_bar.dart` (DesignFrame+Row), `game_feature_button.dart` (~200 lines: gradient/ripple `CustomPainter`, `SvgPicture`, `AnimatedOpacity`+`AnimatedScale` 0.38/0.94, semantic labels), `game_audience_poll_row.dart` (label + `LinearProgressIndicator` + %) |
| Dialog widgets | `widgets/game/dialogs/game_help_dialogs.dart` — `GameAudiencePollDialogView` (shell + `AudiencePollRow`s + Understand), `GameAIAssistantDialogView` (`_LoadingBody` spinner+`aiThinkingMessage` → `_AIAssistantBody`: green answer chip + `confidencePercentage%` + explanation + Understand); `game_confirm_dialogs.dart` — `GameConfirmWalkAwayDialogView` (`_ConfirmBody`: title/message/primary/secondary) |
| l10n | en+vi: `fiftyFiftySemanticLabel`, `askAudienceSemanticLabel`, `askAiSemanticLabel`, `walkAwaySemanticLabel`, `exitGameSemanticLabel`, `walkAwayTitle`, `walkAwayMessage`, `confirmWalkAwayButton`, `keepPlayingButton`, `aiAssistantTitle`, `audienceHelpTitle`, `aiThinkingMessage` |

### Verbatim senior semantics to port

- `_canUseFeature`: `phase != playing → false`; `walkAway →
  _walkAwayAmount(state) > 0`; `exitGame → true`; else
  `!usedFeatureButtons.contains(type)`.
- 50:50 is **deterministic**: keep `correctOption` + **first** wrong
  option (`options.firstWhere(!= correctOption)`), blank the rest to
  `''`. NOT random.
- Poll: correct = easy 68 / medium 52 / hard 42; wrongs split
  `round(50%)`/`round(32%)`/rest → always sums 100.
- AI: **simulated** — no network; loading dialog → 700ms →
  `selectedAnswer = correctOption`, `confidence = 85`,
  `explanation = aiHintMessage`.
- Walk-away gating: bar hides `walkAway` unless `guaranteedAmount > 0`
  (mapper `canWalkAway`); `_canUseFeature` independently re-checks
  `_walkAwayAmount > 0` — belt-and-suspenders, port both.
- `submitAnswer` ignores `answerText.isEmpty` — blanked options are
  untappable for free (already in learner VM).
- Progression reset: next question sets `visibleOptionTexts =
  questions[i+1].options`, `clearAudiencePercentiles`, `clearSelected-
  Answer`, `remainingTime = 30s`. `startGame` seeds
  `visibleOptionTexts = questions.first.options`.

## Current learner form

- `GameSessionState`: no `visibleOptionTexts`/`audiencePercentiles`/
  `usedFeatureButtons`; no resolved-result carrier.
- `GameDialogState`: 6 variants (missing walk-away/poll/AI).
- `GameScreenData`: no `featureButtons`; `GameAnswerOptionData` lacks
  `audiencePercentile`+copyWith; no `GameFeatureButtonType`/
  `GameFeatureButtonData`.
- Mapper: `_buildAnswers` reads `question.options[index]` directly;
  `_answerState` lacks the `isEmpty→idle` first guard.
- VM: no `selectFeature`; `_advanceQuestion` doesn't reset lifeline
  fields; `buildGameResult` can't distinguish walk-away victory from
  true victory.
- Screen: no feature bar; dialog switch has 5 arms.
- ARB: has `understandButton`, `aiExplanationsTitle`,
  `continuePlayingButton`, `exitGame*`; missing 12 M20 keys.
- No `AppAssets`/SVG/`flutter_svg`; learner UI uses `Icons.*` +
  `MenuTokens`.

## Senior target form

See table above — five `GameFeatureButtonType`s, single-use set in
session state, dialog variants carrying view-ready data, VM-guarded
async AI flow, deterministic helper functions.

## Register entries owned

| ID | M19-state form | M19/M20 responsibility | Files | Final status |
|----|----------------|------------------------|-------|--------------|
| FR-07 (partial) | 6-variant `GameDialogState`, `showDialog` mechanism | +3 lifeline variants (`GameConfirmWalkAwayDialog`, `GameAudiencePollDialog`, `GameAIAssistantDialog`) rendered via existing `showDialog` bridge; in-Stack layer stays M21 | `data/game/game_session_state_data.dart`, `screens/game_screen.dart` | ACTIVE_TEMPORARY (M21 remains) |

Plus **FR-34 (new, opened this milestone)**: feature-button visuals —
senior SVG assets + gradient/ripple `CustomPainter` vs learner
`Icons.*` + opacity/scale; converges at M28 visual parity pass
(same bucket as FR-32). (FR-33 remains reserved for
`GameShareResultEvent`/SharePlus — unassigned.)

## Entries expected to close

None fully — FR-07 stays open (in-Stack layer is M21). The lifeline
*behavior* lands complete; only the rendering mechanism defers.

## Entries remaining active

FR-07 (in-Stack → M21), FR-03/FR-04 (M22), FR-16 (M21), FR-34 (new,
M28), FR-33 (reserved, unassigned); non-game rows unchanged.

## Permitted simplifications

1. **`GameFeatureButtonData.icon` is `IconData`**, not senior's
   `String iconAsset` (no SVG/`flutter_svg` pipeline in learner —
   FR-34, M28). `type`/`semanticLabel`/`isEnabled`/`copyWith` keep
   senior names/shape.
2. **Button visual** = `Icons.*` + `AnimatedOpacity`(0.38) + tap;
   senior's gradient/ripple painter deferred (FR-34).
3. **Dialogs** stay `showDialog`/`AlertDialog`-based; senior's
   `GameDialogShell` chrome approximated by existing dialog styles
   (FR-16 → M21).
4. **`resolvedResult` field** — interim carrier so `GameResult`
   transport reports walk-away (`won:false`, `earned=walkAway`)
   vs true victory correctly until M22's VM-side save replaces the
   route-pop transport. (Senior's analog: `GameSaveResult` asyncOp +
   `hasSavedResult`.)
5. VM remains `ChangeNotifier`+`copyWith` — DRE is M26.

## Forbidden alternatives

- No real AI/LLM/network behind "Ask AI" — senior simulates (85% +
  hint); the sim must stay visibly simulated in code and lessons.
- No random 50:50 — senior is deterministic (correct + first wrong).
- No `Set` in widget state — `usedFeatureButtons` lives in
  `GameSessionState`.
- No new navigation architecture; no in-Stack dialog layer (M21);
  no VM-side profile save (M22); no DRE (M26).
- Do not add lifelines beyond the five senior types.

---

## LEARNING DESIGN CHECK

## New Dart concepts

- `Set<T>` as single-use ledger (`usedFeatureButtons.add`/contains;
  `Set.unmodifiable`); `Map<String,int>` lookup + null handling;
  `switch` on `GameQuestionDifficulty`; `{...state.used, type}`
  spread-copy idiom.

## New Flutter concepts

- Feature-button bar pattern (data-driven `List<GameFeatureButtonData>`
  → row of buttons); disabled visuals (`isEnabled` → opacity + null
  `onTap`); `LinearProgressIndicator` as poll bars; loading→result
  dialog content swap on `isLoading`; `Semantics` labels.

## New architecture concepts

- **One-shot domain actions**: `handleFeatureClick` intent → `_canUseFeature`
  guard → state mutation — single-use enforced in *state*, not widgets.
- **Derived UI state**: `visibleOptionTexts`/`audiencePercentiles` are
  domain outputs the mapper folds into `GameScreenData`.
- **Simulated async**: `Future.delayed` + `flowToken` guard —
  reinforces M19's delayed-flow model on a new call path.

## Prerequisites

M19 (state machine, session state, mapper, `flowToken`, `showDialog`
bridge, `dismissDialog` routing); M05/M06 async basics; M13/M15
event-vs-state.

## Registry nodes

- New: D-35 (`Set` single-use ledger + spread-copy), F-29
  (data-driven feature bar + disabled visuals), A-20 (simulated async
  domain action — delay + token + dialog-state swap).
- Reinforced: D-33 (state machine), D-34 (`copyWith`), A-18 (state→
  mapper→screenData), F-27 (VM-owned timing).

## Depth classifications

- Single-use feature model (`_canUseFeature` + `usedFeatureButtons`):
  **CORE**.
- `Set`/`Map` mechanics: NORMAL.
- Helper purity + deterministic algorithms: NORMAL.
- Dialog/wigdet chrome: LIGHT.

## Mental models

- "Lifeline = intent → guard → one-shot flag in state → UI derives
  enablement." Buttons render *derived* `isEnabled`; they never own
  usage state.
- "Simulated AI" — honest framing: deterministic canned answer behind
  a delay; NOT a network call.
- Walk-away = a *victory-phase exit* carrying its own amount —
  distinct from true victory only in the saved result.

## Isolated examples

- Tiny `Set<int>` "lives used" or "coupon redeemed" example before the
  game (D-35).
- A two-state `isLoading` dialog mock before the AI flow.

## Independent exercises

- PRODUCE: add a 6th one-use "second chance" mechanic skeleton —
  enum + guard + used-set write + disabled render — following the
  established shape (exercise only; not merged into app behavior).
- PREDICT: what happens when 50:50 is pressed twice / during reveal.
- DEBUG: double-use bug where the used-check is forgotten.

## Reinforcement

VM ownership, phase gating, `flowToken` staleness, dialog-state→UI
mapping — all M19 machinery exercised on new paths.

## Cognitive load

5 lessons, one feature family each after the model lesson; the AI
lesson isolates async; no new architecture vocabulary beyond A-20.

## Lesson split

- **L01** — Lifelines as domain rules: `GameFeatureButtonType`,
  `usedFeatureButtons`, `_canUseFeature` mental model (CORE concept
  home; isolated `Set` example).
- **L02** — Data + helpers: new dialog variants,
  `GameAudiencePollItemData`, `GameFeatureButtonData`,
  `audiencePercentile`, state fields + `copyWith` flags,
  `game_lifeline_helper.dart` (pure functions + tests), ARB keys.
- **L03** — 50:50 + audience poll: VM methods, mapper changes,
  feature bar widget, poll dialog; disabled + blanked-option
  rendering.
- **L04** — Simulated AI hint + walk-away/exit: 700ms flow + token
  guard, loading→result dialog, `GameConfirmWalkAwayDialog` +
  `_confirmWalkAway` → victory-phase result resolution
  (`resolvedResult`), honest-simulation beat.
- **L05** — Tests + regression: helper unit tests, VM single-use /
  gating / delayed-flow tests, widget tests (bar, disabled, poll
  rows, AI loading); PRODUCE + DEBUG exercises.

## Sequential checkpoint strategy

- After L02: analyze clean; bank/state compile; helper tests pass;
  game unchanged at runtime (new fields inert).
- After L03: analyze clean; 50:50 + poll usable once, disabled after;
  tests green.
- After L04: full feature set works; walk-away/exit result semantics
  correct; tests green.
- After L05: full suite + `flutter build web` + site parity.

---

## Exit criteria

- Five features single-use, VM-owned, phase-gated.
- Walk-away gated on amount>0; confirm → victory-phase + result
  `won:false`, `earned=walkAway`.
- AI hint simulated + honest (700ms, 85%, `aiHintMessage`).
- `flutter analyze` clean; `flutter test` all green; `flutter build
  web` + site build pass; replay green.
- FR-07 updated; FR-34 opened; no M21/M22/M26 scope pulled forward.
