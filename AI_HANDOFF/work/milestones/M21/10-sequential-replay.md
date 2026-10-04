# M21 — SEQUENTIAL REPLAY (Atlas)

## Setup

Physical M20 checkpoint clone at `C:\Users\Lenovo\AppData\Local\Temp\m16-replay`
(carried M20-end state: `GameDialogRequested`/`showDialog` scaffold intact,
no dialog tokens, no `widgets/game/` dir). `flutter pub get` → clean.

## Per-lesson execution

| Lesson | Action | Checkpoint |
|---|---|---|
| L01 | Mental model only — no code | `flutter analyze` clean, `flutter test` **147/147** ✅ |
| L02 | +3 `MenuTokens` dialog tokens; `game_dialog_views.dart` (verbatim port); skeleton `game_dialog_layer.dart` per lesson (no `AnimatedSwitcher`); `game_dialog_layer_test.dart` 3 tests | analyze **1 warning** initially — `unused_element_parameter` on pre-staged `disableAnimations` → **lesson defect found & fixed** (param moved to L03); after fix: analyze clean, **150/150** ✅ |
| L03 | Layer → `AnimatedSwitcher` production version; `_TestSurface` +`disableAnimations` param + `MediaQuery` wrap (new L03 step); +3 transition tests | analyze clean, **153/153** ✅ |
| L04 | Atomic cut per lesson: production `game_screen.dart` (Stack mount + `PopScope` + `_handleRouteBack` + `_afterExit`), `game_session_state_data.dart` (`GameDialogRequested` retired), `game_screen_view_model.dart` (10 emit sites gone), `game_screen_test.dart` + `game_screen_view_model_test.dart` (finder/timing/`isEmpty` edits) | analyze clean, **153/153** ✅ |
| L05 | +4 parity tests (ended/ladder animate-out, terminal tap-lock, same-variant-in-place) | analyze clean, **157/157** ✅ |

## Replay-discovered lesson defect (fixed in lessons + clone)

L02's `_TestSurface` pre-staged `disableAnimations` (unused until
L03) → `unused_element_parameter` warning broke the "analyze sạch"
checkpoint. Fixed: L02 test file no longer declares the param; L03
gained an explicit step (Bước 4) adding it when the reduced-motion
test needs it. Applied to lessons and re-verified in clone.

## Final parity — clone lib/+test/ vs production M21

9 file deltas, **all non-functional** (EOL-normalized comparison):

- `menu_tokens.dart` — token comment wording only.
- `game_screen_data.dart`, `user_settings_data.dart`,
  `app_localizations*.dart`, `sealed_state_test.dart`,
  `game_screen_presentation_mapper_test.dart` — pre-existing
  comment/test-name deltas inherited from the M20 replay lineage
  (unchanged by M21; production texts evolved past the clone's M20
  state).
- `game_dialog_layer_test.dart` — header comment + test ORDER only;
  same 10 tests, same assertions.

M21-touched files byte-identical: `game_screen.dart`,
`game_session_state_data.dart`, `game_screen_view_model.dart`,
`game_dialog_layer.dart`, `game_dialog_views.dart`,
`game_screen_test.dart`, `game_screen_view_model_test.dart`.

## Verdict

**SEQUENTIAL REPLAY: PASS** — 5/5 lesson checkpoints
(147→150→153→153→157), analyze clean at each, final state
functionally identical to production M21.
