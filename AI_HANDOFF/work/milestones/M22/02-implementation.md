# M22 IMPLEMENTATION — Result Persistence & Level Progression

Role: Flux | Milestone: M22 | Baseline: 157/157 → **168/168**

## Senior surface converged (verified @ `main@c8eb860`)

| Senior | Learner M22 | Status |
|--------|-------------|--------|
| `GameState.hasSavedResult` (DRE state flag) | `GameSessionState.hasSavedResult` (ctor default `false`, `copyWith`ed, reset in `initial`) | ported |
| `_withSaveResult` reducer guard | `_emitWithSaveResult(next, {earnedAmount, isWin})` — flag set inside the emitted state; save fires only when pre-transition flag was false; `questionCount = _state.questionIndex + 1` | ported (VM shape — no DRE queue until M26) |
| 4 terminal emit sites | `_loadNextQuestionOrVictory` victory branch (`moneyEarned`, `isWin:true`), `_endGame` (`guaranteedAmount`, false), `confirmWalkAway` (`_walkAwayAmount`, false), `backToMenu` (`_walkAwayAmount`, false) | 1:1 payload parity |
| `_saveGameResult` bridge | verbatim port into VM (load → `nextMoneyWon` → `_applyLevelProgression` → copyWith stats → `saveUserProfile` → `_syncSavedGameResult`; try/catch → `debugPrint`) | ported |
| `_applyLevelProgression` + `_normalizedLevel` | verbatim — `while` loop burns `LevelConfig.getExpRequiredForLevel(level)` per tier, clamps 1..100 | ported |
| `_syncSavedGameResult` auth-gated sync | documented stub (`// M25` — auth/sync repos not yet on ctor) | stub per roadmap |
| `LevelConfig` (base 30000, growth 5000, milestone map, min 1/max 100) | `lib/data/game/level_config.dart` verbatim | ported |
| `MenuLevelProgress.fromProfile` (+tier/ratio/formatted) | `lib/view_models/menu/menu_level_progress.dart` verbatim | ported |
| ctor `required userProfileRepository` (+auth/sync repos) | `required this.userProfileRepository` only — auth/sync repos deferred M24/M25 | partial (documented) |
| `openGame() → Future<void>`, bare `goBack()` | same | converged |
| menu reads `MenuLevelProgress`, not stored cap | `_LevelCard` derives `MenuLevelProgress.fromProfile(profile)`; `expPercent`/`expForNextLevel` gone | converged |

### Retired learner scaffolds

- `lib/data/game/game_result.dart` — **file deleted**.
- `GameResult` refs: `resolvedResult` field (state), `buildGameResult()`
  (VM), `openGame<GameResult>` + pop-result (nav/screen),
  `MenuViewModel.applyGameResult` (menu VM).
- `UserProfileData`: `expForNextLevel` field (+ ctor/toMap/fromMap/
  copyWith/==/hashCode), `expPercent`, `gainExp`, `expPerCorrectAnswer`,
  `applyGameResult` — all gone; field set now senior-identical (9
  fields). `fromMap` ignores the legacy `expForNextLevel` key on disk.
- `winRateDisplay`, `formatVnd`, `formatThousands` kept (senior-shaped).

### Deliberate divergence (documented in code)

- `LevelConfig.maxExpRequirement = 9007199254740991` (JS max-safe-int)
  instead of senior's int64 `9223372036854775807` — dart2js cannot
  represent the latter; semantics identical (unreachable sentinel).
  Marked in file doc comment.

### Files touched

- NEW `lib/data/game/level_config.dart` (72 LOC)
- NEW `lib/view_models/menu/menu_level_progress.dart` (105 LOC)
- `lib/data/profile/user_profile_data.dart` (330→257 LOC)
- `lib/data/game/game_session_state_data.dart` (`hasSavedResult` in,
  `resolvedResult` out)
- `lib/view_models/game/game_screen_view_model.dart` (+repo dep,
  `_emitWithSaveResult` at 4 sites, `_saveGameResult` family ~110 LOC)
- `lib/navigation/app_navigation_controller.dart` (`openGame` → void)
- `lib/screens/game_screen.dart` (bare `goBack()`, ctor injection)
- `lib/screens/menu_screen.dart` (`_openGame` bare await; `_LevelCard`
  via `MenuLevelProgress`)
- `lib/view_models/menu/menu_view_model.dart` (`applyGameResult` out)
- DEL `lib/data/game/game_result.dart`
- Tests: `level_config_test.dart` (NEW, 7), `menu_level_progress_test.dart`
  (NEW, 5), `game_screen_view_model_test.dart` (8 new persistence tests;
  ctor injection everywhere), `user_profile_data_test.dart`,
  `menu_view_model_test.dart`, `widgets/game_screen_test.dart`
  (repo-injected `pumpGameScreen` + save asserts).

## Evidence

```
flutter analyze  → No issues found!
flutter test     → 168/168
flutter build web → Built build\web (dart2js OK after sentinel fix)
```

Zero `GameResult`/`expForNextLevel`/`gainExp`/`applyGameResult`/
`buildGameResult`/`resolvedResult`/`expPercent` symbols remain in
`lib/` (only local var names + new `_saveGameResult` method names —
substring coincidences, no type refs).

## Open items for QA

- `unawaited(_saveGameResult)` timing: tests assert after
  `async.flushMicrotasks()` (FakeAsync) / `pump()` (widget). Confirm no
  race vs `notifyListeners` ordering.
- `_emitWithSaveResult` reads `questionIndex` post-emit — safe only
  because no terminal transition mutates `questionIndex` (verified all
  4 sites). Confirm reviewer agrees this invariant holds.
- `menuExpProgress` arb placeholders unchanged (ints) — fed
  `progress.currentExp`/`requiredExp` ints; senior's *formatted*
  variants exist but the learner row displays raw ints (consistent
  with pre-M22 display). Confirm acceptable vs switching to
  `formatted*` Strings.
