# M22 IMPLEMENTATION QA — Argus verdict

Reviewer: Argus (independent, outside authoring context) | Verdict: **PASS**

## Blockers

None.

## Checklist outcome

- Payload parity at all 4 terminal sites — verified vs
  `game_reducer_session_flow.dart` (victory `moneyEarned`/true,
  gameOver `guaranteedAmount`/false, walkAway+backToMenu
  `_walkAwayAmount`/false, `questionCount = questionIndex+1`).
- `hasSavedResult` idempotence — pre-transition read, flag inside the
  emitted state, `initial` resets; double-`backToMenu` and
  gameOver→backToMenu provably single-save.
- `_saveGameResult` math verbatim (money totals, stats, EXP =
  `earnedAmount` via `LevelConfig` loop, not correctAnswers).
- `LevelConfig`/`MenuLevelProgress`/`UserProfileData` senior-identical.
- Transport fully retired; `openGame` void; stub `_syncSavedGameResult`
  documented M25 no-op (no invented auth).
- Menu uses `MenuLevelProgress` + positive flexes.
- Tests assert senior semantics; level_config_test has all 7 senior
  tests (brief said 11 — senior file has 7; brief corrected).

## Minors (non-blocking, dispositioned)

1. `clamp(1,99)` on the EXP bar — intentional (`Expanded` requires
   flex>0); cosmetic, real card visual is M28. **Kept.**
2. Max-level shows raw `9007199254740991` in `menuExpProgress` — M28
   replaces with `menuMaxLevelReached`; logged for M28. **Deferred.**
3. `profileLevel(profile.level)` unclamped vs `progress.level` —
   **FIXED** (label now reads `progress.level`).
4. Brief miscount "11 tests" → corrected to 7. **Fixed.**
5. Argus could not run `flutter` itself (read-only profile); parent
   re-verified: `analyze` clean, `168/168`, `build web` PASS. ✓

## Atlas verdict

**IMPLEMENTATION_APPROVED** — proceed to Lumen content stage.
