# M22 IMPLEMENTATION NOTES — Result persistence & level progression

## What changed (learner `learner-app/`)

### New files
- `lib/data/game/level_config.dart` — senior `LevelConfig` verbatim:
  base EXP 30000, growth 5000/level, milestone multiplier map,
  `minLevel 1` / `maxLevel 100`, `getExpRequiredForLevel`.
- `lib/view_models/menu/menu_level_progress.dart` — senior
  `MenuLevelProgress.fromProfile` verbatim: derived tier, ratio,
  formatted EXP/percent strings.

### Rewritten
- `lib/data/profile/user_profile_data.dart` — 330→257 LOC. Field set
  now senior-identical (9 fields): `expForNextLevel` field +
  `expPercent`/`gainExp`/`expPerCorrectAnswer`/`applyGameResult`
  removed. `winRateDisplay`, `formatVnd`, `formatThousands` kept
  (senior-shaped). `fromMap` ignores legacy `expForNextLevel` key on
  disk.
- `lib/data/game/game_session_state_data.dart` — `hasSavedResult`
  added (ctor default `false`, `copyWith`ed, reset in `initial`);
  `resolvedResult` removed.
- `lib/view_models/game/game_screen_view_model.dart` —
  `required userProfileRepository` ctor dep. `_emitWithSaveResult`
  reducer-style guard (senior `_withSaveResult`): flag inside the
  emitted state; save fires only when pre-transition flag was false;
  `questionCount = _state.questionIndex + 1`. Four terminal emit sites
  1:1: `_loadNextQuestionOrVictory` victory branch (`moneyEarned`,
  `isWin:true`), `_endGame` (`guaranteedAmount`, false),
  `confirmWalkAway` (`_walkAwayAmount`, false), `backToMenu`
  (`_walkAwayAmount`, false). `_saveGameResult` family (~110 LOC)
  verbatim port: load → `nextMoneyWon` → `_applyLevelProgression`
  (`while` loop burns `LevelConfig.getExpRequiredForLevel(level)` per
  tier via `_normalizedLevel` clamp 1..100) → copyWith stats →
  `saveUserProfile` → `_syncSavedGameResult` (documented stub —
  auth/sync repos arrive M24/M25); try/catch → `debugPrint`.
- `lib/navigation/app_navigation_controller.dart` — `openGame()` now
  `Future<void>`; route no longer carries `GameResult`.
- `lib/screens/game_screen.dart` — bare `goBack()` exits; repo-injected
  VM ctor.
- `lib/screens/menu_screen.dart` — `_openGame()` bare await; `_LevelCard`
  derives `MenuLevelProgress.fromProfile(profile)`; `expPercent`/
  `expForNextLevel` reads gone.
- `lib/view_models/menu/menu_view_model.dart` — `applyGameResult`
  removed (profile stream is source of truth).

### Deleted (retired scaffold)
- `lib/data/game/game_result.dart` — file deleted.
- All `GameResult` transport: `resolvedResult`, `buildGameResult()`,
  `openGame<GameResult>` + pop-result handling,
  `MenuViewModel.applyGameResult`.

### Deliberate divergence (documented in code)
- `LevelConfig.maxExpRequirement = 9007199254740991` (JS max-safe-int)
  instead of senior int64 `9223372036854775807` — dart2js cannot
  represent the latter; semantics identical (unreachable sentinel).
  Marked in file doc comment.

## Senior source

`main@c8eb860` — `game_screen_view_model.dart` (`hasSavedResult`,
`_withSaveResult`, `_saveGameResult`, `_applyLevelProgression`,
`_normalizedLevel`, `_syncSavedGameResult`), `level_config.dart`,
`menu_level_progress.dart`, `user_profile_data.dart` (9 fields).

## Fidelity rows converged

FR-01..FR-04 (route-result transport, saved-result flag/payload parity,
local persistence, menu progression display) — closed at M22.

## Verification

```
flutter analyze   → No issues found!
flutter test      → 168/168
flutter build web → PASS
website build     → 120 pages
```
