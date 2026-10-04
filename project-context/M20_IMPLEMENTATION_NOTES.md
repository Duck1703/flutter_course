# M20 Implementation Notes — Lifelines & feature buttons

## What landed (learner-app)

- `lib/data/game/game_session_state_data.dart`:
  - `GameAudiencePollItemData` (`label`, `percentile`).
  - Sealed `GameDialogState` +3 variants → **9 variants, 1:1 senior**:
    `GameConfirmWalkAwayDialog(walkAwayAmount)`,
    `GameAudiencePollDialog(items)`, `GameAIAssistantDialog`.
  - `GameSessionState` +4 fields: `visibleOptionTexts` (defaults to
    `question.options`, mutated by 50:50), `audiencePercentiles`
    (cleared per question), `usedFeatureButtons`
    (`Set.unmodifiable`, single-use gate), `resolvedResult`
    (interim end-state carrier — `GameResult?`, →M22 VM-side save).
  - `copyWith` +`clearAudiencePercentiles`/`clearResolvedResult`
    flags (nullable-field ambiguity, D-34 pattern).
  - Constructor drops `const` (unmodifiable wrappers).
- `lib/data/game/game_screen_data.dart`:
  - `GameFeatureButtonType` — 5-value enum
    (`fiftyFifty`/`audiencePoll`/`aiAssistant`/`walkAway`/`exitGame`).
  - `GameFeatureButtonData` — `type`/`icon`(IconData — FR-34
    simplification)/`semanticLabel`/`isEnabled`.
  - `GameAnswerOptionData` +`audiencePercentile` + `copyWith`
    (+`clearAudiencePercentile`).
  - `GameScreenData` +`featureButtons` (required).
- `lib/view_models/game/support/game_lifeline_helper.dart` (new) —
  verbatim senior port: `buildFiftyFiftyVisibleOptions` (deterministic:
  keep correct + FIRST wrong, blank rest — not random);
  `buildAudiencePercentiles` (correct % by difficulty: easy 68 /
  medium 52 / hard 42) + `_splitWrongAudience` (50% / 32% /
  remainder, sums to 100); `buildGameAudiencePollItems`.
- `lib/view_models/game/game_screen_presentation_mapper.dart` —
  signature +4 params (`visibleOptionTexts`, `audiencePercentiles`,
  `usedFeatureButtons`, `canWalkAway`); `_buildAnswers` reads
  `visibleOptionTexts`; `_answerState` empty-text guard;
  `_buildFeatureButtons` + `_feature` verbatim (aiAssistant always,
  walkAway only when `canWalkAway`, **`exitGame` NOT in the bar**).
- `lib/view_models/game/game_screen_view_model.dart`:
  - `handleFeatureClick(GameFeatureButtonData)` → `_canUseFeature`
    phase-gates (50:50/poll/AI need `playing`; walkAway needs
    `canWalkAway`) + `usedFeatureButtons.contains` single-use check;
    double-guard kept verbatim (senior belt-and-suspenders).
  - `_useFiftyFifty` / `_showAudiencePoll` (pause timer, dialog,
    resume) / `_showAIAssistant` (pause; emit `isLoading:true`; real
    700ms `_aiAssistantDelay` Future with `flowToken` + `is!`
    stale-result guards — mutation lands in ONE open dialog, never a
    new emit) / `_showConfirmWalkAway` + `confirmWalkAway` →
    `victory` phase + `resolvedResult{won:false,
    earned:walkAwayAmount}` (senior: walk-away IS a win visually but
    not a `won` result).
  - `visibleOptionTexts` reseeded per question in
    `_loadNextQuestionOrVictory`; `audiencePercentiles` cleared.
  - `resolvedResult` chốt in `_endGame` (gameOver) / victory path /
    `backToMenu`; `buildGameResult` reads `resolvedResult ??`
    fallback.
- `lib/screens/game_screen.dart`:
  - `_GameFeatureBar` + `_GameFeatureButton` — data-driven bottom bar
    (FR-34: flat Material icons, not senior SVG/CustomPainter — M28).
  - `_AnswerOption` empty-`optionText` guard → non-tappable blank slot.
  - `_GameDialogHost` — snapshot field → `ListenableBuilder` live-read
    (required so the AI dialog transitions loading→result in place).
  - +3 `_dialogTitle`/`_dialogContent`/`_dialogActions` exhaustive
    arms; `_GameDialogAction.confirmWalkAway` →
    `vm.confirmWalkAway`; `_GameTopBar` `exitSemanticLabel` (a11y NIT).
- `lib/l10n/app_{en,vi}.arb` — +12 senior keys verbatim
  (`gameAIAssistant*`×3, `gameAudiencePoll*`×2, `gameConfirmWalkAway*`×3,
  `gameFiftyFiftyButton`, `gameAudiencePollButton`,
  `gameAIAssistantButton`, `gameWalkAwayButton`).

## What did NOT land (deferred, tracked)

- In-`Stack` `GameDialogLayer` → M21 (FR-07 mechanism).
- VM-side result save (`GameSaveResult` asyncOp + `hasSavedResult`) →
  M22 — `resolvedResult` is the interim carrier.
- DRE/reducer → M26.
- Lifeline visual parity (SVG/`CustomPainter`/press-scale) → M28
  (FR-34).
- `GameShareResultEvent` → FR-33 still reserved/unassigned.
- No real AI/network — simulated only, matching senior.

## Senior fidelity notes

- 50:50 deterministic (NOT random) — correct + first-wrong kept.
- Poll math verbatim; AI 700ms/85%/`aiHintMessage` verbatim; walk-away
  → `victory` + `won:false` verbatim; `exitGame` outside bar verbatim.
- Senior repo verified unchanged at `main @ c8eb860`.

## Validation

- `flutter analyze` clean; `flutter test` **147/147** (126 → +21:
  helper 5, mapper +2, VM +10, widget +4 — sealed arms grow 6→9).
- `flutter build web` pass. Sequential replay 4/4 on physical M19
  clone (126 → 131 → 141 → 147).
