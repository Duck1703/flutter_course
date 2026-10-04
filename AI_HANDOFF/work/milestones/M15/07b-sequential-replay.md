# M15 Sequential Learner Replay (G24 proof)

> Method: scratch clone of `learner-app` at `%TEMP%\m15-replay`,
> reverted to the true M14 end-state (`abstract MenuUiEvent` +
> `is`-chain; `GameEndReason{victory,…}`; no `GameDialogState`; old
> filenames; no `sealed_state_test.dart`). Then each lesson's
> instructions applied in order; checkpoints run at each stage.

## Baseline (M14 end-state clone)

- `flutter pub get` ✓ · `flutter analyze` → `No issues found!`
- `flutter test` → `+69: All tests passed!`

## Per-lesson results

| Lesson | Changes applied | Checkpoint | Result |
|--------|-----------------|------------|--------|
| L01 — vì sao state đóng | none (theory) | analyze clean | **PASS** |
| L02 — `sealed class` | none (theory + isolated PaymentState mental work) | analyze clean | **PASS** |
| L03 — switch kiệt hợp + patterns | none (theory) | analyze clean | **PASS** |
| L04 — seal event bridge | `menu_ui_event.dart`→`menu_screen_ui_event.dart` + `sealed`; VM type rename; `_handleUiEvent`→`switch`; test import | `flutter analyze` → clean; menu-scope tests (events+VM+scope) → 16/16 | **PASS** |
| L05 — GameDialogState | `game_session_state.dart`→`_data.dart` + hierarchy + `GameEndReason` trim; `game_screen` `_dialogState`/`_finish`/switch-expr dialog content + title-color wildcard + `_restart` reset; new `sealed_state_test.dart` | `flutter analyze` → clean; `flutter test` → **74/74** | **PASS** |

## Convergence

End-state of replay ≡ production learner-app (same files, same shapes
— doc comments on the state file are the only intentional delta:
replay used the lesson-derived minimal docs). Test count 69 → 74
exactly matches production.

## Incidents during replay

- Replay-fixture authoring (not lesson defects): two hand-written
  string escapes needed correction (`\n` literal handling in the
  revert script). These were clone-construction issues, not lesson
  issues — the lesson steps themselves replayed cleanly.
- No lesson instruction was impossible or produced a compile error
  mid-step — the "atomic" warnings in L04/L05 correctly describe the
  only safe application order.

SEQUENTIAL_REPLAY: PASS (5/5 lessons)
