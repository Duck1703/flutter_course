# M22 — SEQUENTIAL REPLAY

Replayed all 5 M22 lessons on the carried-forward clone at
`C:\Users\Lenovo\AppData\Local\Temp\m16-replay` (verified M21-end
state: `GameDialogLayer` present, `game_result.dart` still alive,
no `level_config.dart`).

## Per-lesson checkpoints

| Step | Action | Result |
|------|--------|--------|
| Baseline | `flutter test` on clone | **157/157** |
| L01 | mental model — no code | 157 (unchanged, checkpoint reads current state) |
| L02 | +`level_config.dart` + `level_config_test.dart` | **164/164** (+7), analyze clean |
| L03 | +`menu_level_progress.dart` + test + `_LevelCard` rewire (import, progress/expPercent locals, `progress.level`, `currentExp`/`requiredExp`, bar flexes) | **169/169** (+5), analyze clean |
| L04 | atomic cut — `hasSavedResult` swap, VM ctor+save block, `game_result.dart` deleted, `UserProfileData` 9-field surgery, transport retired (`openGame`→void, bare `goBack`, `_openGame`, `applyGameResult` deleted), test files updated | **168/168** (+8 persistence, −9 scaffold), analyze clean |
| L05 | regression sweep only (PRODUCE task is sandbox/no-merge) | **168/168** |

## Replay-caught defects

None this milestone — all lesson checkpoint claims (157→164→169→168
→168) reproduced exactly. The earlier Argus rounds had already
forced content fixes (fabricated `_finalVictory` symbol, `dart test`
commands, unobservable DEBUG exercise, grep-count honesty) before
replay ran.

## Post-replay parity

Normalized diff (CRLF-insensitive) clone vs production `lib/`:

- All M22-touched files **byte-identical** (`level_config`,
  `menu_level_progress`, `game_session_state_data`,
  `game_screen_view_model`, `user_profile_data`, nav controller,
  `game_screen`, `menu_screen`, `menu_view_model`; `game_result.dart`
  absent in both).
- 9 residual deltas — all pre-existing M≤21 replay-lineage artifacts
  (doc-comment variants in `menu_tokens`/`game_screen_data`/
  `user_settings_data`; ARB key ordering in `app_en.arb` +
  generated localizations; `.last_build_id` build artifact). Same
  9 the M21 replay recorded — **zero new divergence introduced by M22**.

## Verdict

Replay **PASS** — lessons are sequentially executable with honest
checkpoints and produce production-identical code.
