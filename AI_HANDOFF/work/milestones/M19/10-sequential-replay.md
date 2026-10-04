# M19 — SEQUENTIAL REPLAY (physical)

Clone: `C:\Users\Lenovo\AppData\Local\Temp\m16-replay` (carried
through M17 + M18 replays — verified M18 end-state: three-phase
`GamePhase` {notStarted, playing, gameOver}, `GameEndReason` present,
widget-owned timer, 630-line `game_screen.dart`, no M19 VM test,
`102/102`).

## Baseline (M18 end-state)

- `flutter analyze`: clean
- `flutter test`: **102/102**

## Replay log

| Step | Action per lesson | Checkpoint | Result |
|---|---|---|---|
| L01 | theory only — state-ownership mental model, no code | — | n/a |
| L02 | create `data/game/` (5 files) + `game_money_formatter.dart`; copy `game_quiz_questions.dart` bank; ARB key swap (dead keys removed, 9 senior dialog keys added); delete `quiz_questions.dart` + `quiz_question_data.dart`; swap `onboarding_content_data.dart` bank refs; `earnedAmount` contract → profile tests patched; replace `game_screen.dart` with stub; patch menu test `"Phòng chơi"`→stub assertion | analyze clean, **95/95** | **PASS** |
| L03 | create `game_screen_presentation_mapper.dart` + `game_money_ladder_mapper.dart` + `game_screen_presentation_mapper_test.dart` | analyze clean, **99/99** | **PASS** |
| L04 | create `game_screen_view_model.dart` + `game_screen_view_model_test.dart`; `flutter pub add fake_async --dev` | analyze clean, **116/116** | **PASS** |
| L05 | create `navigation/app_navigation_controller.dart`; rewrite `game_screen.dart` (provider scope + stateful event bridge + `PopScope` + `showDialog` interim); DI scope + `main.dart` (portrait lock) + `menu_screen.dart` (`_openGame` via nav controller); test helper `navigatorKey`; new `test/widgets/game_screen_test.dart`; menu scope/UI-event tests copied | analyze clean, **126/126** | **PASS** |
| L06 | `flutter build web`; diff clone `lib/`+`test/` vs production | `√ Built build\web`; diff clean | **PASS** |

## Final-state parity (clone vs production)

`diff -r lib test` vs production:

- `user_settings_data.dart`: **comment-only** delta — clone header
  still annotates `FR-26 (ACTIVE → M17)`; production updated it to
  `FR-26 (CONVERGED tại M17)` during M17 closeout after the clone was
  snapshotted. No code delta.
- `lib/build/.last_build_id`: production build artifact, not source.

Everything else identical. Final replay state = production M19
checkpoint.

## Defects found & remediated in lessons

1. **L02 — stale menu assertion (real teaching gap).** Production's
   menu test asserts the M19 *final* behavior (intro ladder on entry).
   At L02's stub stage the game route still shows the stub, so the old
   `"Phòng chơi"` assertion must be patched to expect the stub — L02
   now teaches this test-host patch explicitly. Checkpoint after fix:
   95/95.
2. **L03 — stray file copy (replay operator error, not a lesson
   defect).** `game_money_ladder_mapper.dart` was copied without its
   `game_money_formatter.dart` dependency already being present at the
   expected path in one copy attempt; removed the stray file, re-copied
   correctly — analyze clean. Lesson ordering already correct (L02
   creates the formatter).

No compile gaps between lesson steps. Checkpoint counts match lesson
claims exactly (95 → 99 → 116 → 126).

## Replay verdict

**PASS** — M19 lesson sequence executes end-to-end from a verified
M18 end-state clone; all checkpoint claims truthful; one teaching gap
(L02 menu-assertion patch) discovered and folded back into the lesson.
