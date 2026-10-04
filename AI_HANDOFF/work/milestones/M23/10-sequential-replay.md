# M23 — SEQUENTIAL REPLAY

Replayed all 5 M23 lessons on the carried-forward clone at
`C:\Users\Lenovo\AppData\Local\Temp\m16-replay` (verified M22-end
state before start: `game_result.dart` absent, `level_config.dart`
present, no `supabase_environment.dart`, baseline 168/168).

## Per-lesson checkpoints

| Step | Action | Result |
|------|--------|--------|
| Baseline | `flutter test` on clone | **168/168** |
| L01 | +`core/supabase_environment.dart` + `test/core/supabase_environment_test.dart` | **171/171** (+3), clean |
| L02 | +`services/supabase_client_service.dart` + `data/leaderboard/` + `repositories/leaderboard/` (contract+impls) + `pubspec` (`supabase_flutter 2.14.2`, pub get) + `main.dart` + `app_dependency_scope.dart` + 3 test call-site fixes (`menu_provider_scope_test`, `menu_screen_ui_events_test`, `widgets/game_screen_test`) | **171/171** (no new tests — as lesson claims) |
| L03 | +`test/helpers/fake_leaderboard_repository.dart` + `test/repositories/leaderboard_repository_test.dart` | **175/175** (+4) |
| L04 | +`view_models/leaderboard/` + `test/view_models/leaderboard/` | **184/184** (+9) |
| L05 | +`widgets/leaderboard/` + `widgets/menu/leaderboard/` + menu VM/event/screen wiring + ARB (+regen localizations) + `widgets/menu_leaderboard_dialog_test` + `menu_view_model_test` + `menu_screen_ui_events_test` + `sealed_state_test` update + `supabase/student-setup/*.sql` | **193/193** (+9) |

## Replay-caught defects

Two mechanical replay misses (clone bookkeeping, NOT production or
lesson defects):

1. `game_screen_test.dart` initially copied to `test/` root instead
   of `test/widgets/` → stray file failed to load; moved correctly,
   suite green.
2. `sealed_state_test.dart` needed copying — it gained a
   `MenuLeaderboardRequested` exhaustiveness case; after copy the
   suite reached exactly 193.

No lesson checkpoint claim was wrong: `168→171→171→175→184→193`
reproduced exactly.

## Post-replay parity

`cmp` across all 31 M23-touched files (lib 16 + test 11 + arb 2 +
sql 1 + pubspec 1): **all byte-identical** between clone and
production — zero divergence introduced by replay.

## Verdict

Replay **PASS** — lessons are sequentially executable with honest
checkpoints and produce production-identical code.
