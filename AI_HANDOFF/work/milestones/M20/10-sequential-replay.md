# M20 — SEQUENTIAL REPLAY

Clone: `C:\Users\Lenovo\AppData\Local\Temp\m16-replay` (carried
through M17 + M18 + M19 replays — verified M19 end-state: no
lifeline fields, no `game_lifeline_helper.dart`, no feature bar,
126/126 green baseline).

## Checkpoint results

| Lesson | Prescribed change | Verify command | Result |
|---|---|---|---|
| L02 | `GameAudiencePollItemData` + 4 state fields + copyWith flags; `GameFeatureButtonType`/`GameFeatureButtonData`/`audiencePercentile` on screen-data; helper file; helper test; 12 ARB keys — NO sealed variants, NO `featureButtons` field | `flutter analyze` + `flutter test` | clean, **131/131** (126+5 helper) — matches claim | **PASS** |
| L03 | `GameAudiencePollDialog` variant (7 total); `GameScreenData.featureButtons`; mapper 4-param + `_buildAnswers`/`_answerState`/`_buildFeatureButtons` (2 nút)/`_feature`; VM 4-arg + seed/reset + `handleFeatureClick`/`_canUseFeature`/`_useFiftyFifty`/`_showAudiencePoll`/`_audiencePollItems` (ai/walkAway `break` stubs); screen bar + `_AnswerOption` guard + poll `_title`/`_content`/`_actions`; tests (sealed 7, mapper builder+2, VM +6, widget +2 + `pumpGameScreen` `..startNewGame()`) | `flutter analyze` + `flutter test` | clean, **141/141** (+6 VM, +2 mapper, +2 widget) — matches claim | **PASS** |
| L04 | `GameConfirmWalkAwayDialog` + `GameAIAssistantDialog` (9 total); VM `_aiAssistantDelay`/`_showAIAssistant`/`_onAIAssistantElapsed`/`_showConfirmWalkAway`/`showConfirmWalkAway`/`confirmWalkAway` + `resolvedResult` writes (`_endGame`/victory/`backToMenu`/`buildGameResult`); mapper 3+walkAway gating; host snapshot→`ListenableBuilder`; AI/walkAway dialog arms + `confirmWalkAway` action; tests (sealed 9, mapper assert, VM +4, widget +2, 2 staged asserts opened to 3-nút) | `flutter analyze` + `flutter test` | clean, **147/147** — matches claim | **PASS** |
| L05 | regression only (no prod changes) | `flutter build web`; diff clone `lib/`+`test/` vs production | `√ Built build\web`; functional diff clean | **PASS** |

## Final-state parity (clone vs production)

Only cosmetic deltas remain — doc-comment wording, sealed-test
label strings (`'confirm-walkaway'` vs `'confirm-walk-away'`),
method declaration order (`_audiencePollItems`), ctor-arg order
(`exitSemanticLabel`), and ARB key ordering. Zero functional
difference.

Two non-trivial parity notes:
- `user_settings_data.dart`: **comment-only** delta carried from
  M17 closeout (pre-existing, unchanged by M20 replay).
- Event-bridge arm: production removed the "auto-start injected VM"
  recovery branch in `_showCurrentDialog`'s post-frame (an
  un-started VM now crashes on `visibleOptionTexts` indexing
  *before* post-frame) — clone synced to match. This IS taught in
  L03 (the `pumpGameScreen` `..startNewGame()` caution).

Everything else identical. Final replay state = production M20
end-state (modulo cosmetics).

## Findings worth noting

1. **Two L03-staged asserts must open up at L04** — the L03 lesson
   prescribes 2-button assertions (`Icons.auto_awesome`
   `findsNothing`, VM `featureButtons` 2-type list) that fail at
   L04; the lesson does cover the widget-side fix ("sửa test bar
   L03: findsNothing → findsOneWidget") and the mapper assert
   reopen, and the equivalent VM rename to "3 nút" is implied by
   the same step. No stale content — the staged rewrites are
   taught.
2. **Compile-safety of staging verified** — the
   sealed-variant-per-lesson staging (the r1-QA fix) works: at no
   checkpoint did an exhaustive `switch` break. L02's state holds
   lifeline fields with zero variants; L03 adds poll + its arms;
   L04 completes to 9.

## Verdict

REPLAY PASS — learner starting from M19 end-state reaches each
checkpoint's promised green state by following the lessons.
