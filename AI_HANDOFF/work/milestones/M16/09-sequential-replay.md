# M16 Sequential Learner Replay (G24 proof)

> Method: fresh copy of production `learner-app` at
> `%TEMP%\m16-replay`, reverted to true M15 end-state (all M16 files
> deleted; `menu_screen_ui_event`, `menu_view_model`, `menu_screen`,
> `sealed_state_test`, `menu_view_model_test` surgically reverted).
> Then each lesson's Build-it steps applied IN ORDER, running each
> lesson's checkpoint exactly as written (post F-13/F-14 fix text).

## Baseline (M15 end-state)

- `flutter analyze` → No issues found!
- `flutter test` → **74/74** (matches production post-M15 count exactly)

## Per-lesson results

| Lesson | Applied | Checkpoint (as written) | Result |
|--------|---------|-------------------------|--------|
| L01 why persist | none (theory) | analyze | **PASS** |
| L02 item data + factory | `setting_item_data.dart`, `supported_language_data.dart`, `settings_item_factory.dart` | analyze clean | **PASS** |
| L03 dialog-scoped VM | `settings_ui_event.dart`, `settings_view_model.dart`, `test/settings_view_model_test.dart` (Bước 5, added by F-14 fix) | analyze clean + `settings_view_model_test.dart` **7/7** | **PASS** |
| L04 dialog UI | `MenuSettingsRequested` + `requestSettings` + bridge case + gear + `_openSettings`; `sealed_state_test` arm (Bước 2b); `menu_view_model_test` +1; `settings_dialog.dart` WITHOUT picker branch/import (F-13 fix) | analyze clean + `flutter test` **82/82** | **PASS** |
| L05 picker + synthesis | `notification_time_picker_dialog.dart`; picker branch + import into dialog (Bước 2, post-fix); `test/widgets/settings_dialog_test.dart` (Bước 4, post-fix) | analyze clean + `flutter test` **87/87** + `flutter build web` √ | **PASS** |

## Convergence

Replay end-state ≡ production M16 (same files; the dialog's
`timePickerVisible` branch is the only region assembled at L05 rather
than L04 — by design after F-13 fix). Test count 74 → 87 exactly
matches production.

## Defects found BY the replay (fixed before verdict)

- **F-13** — L04 listing imported/used `NotificationTimePicker`,
  created only in L05 → L04 analyze checkpoint unreachable. Fixed:
  branch+import moved to L05 Bước 2; scaffold callout added.
- **F-14** — `settings_view_model_test.dart`/`settings_dialog_test.dart`
  never created by any step; `sealed_state_test` exhaustiveness break
  unhandled; L04 run-command referenced the L05 test file. Fixed:
  creation steps L03 Bước 5 / L04 Bước 2b / L05 Bước 4 + guarded L04
  run command.
- Both registered in `CONTENT_GAP_REGISTER.md` (OPEN → IN_PROGRESS →
  RESOLVED) before this replay ran — which then proved the fixed
  sequence compiles/greens at every checkpoint.

SEQUENTIAL_REPLAY: PASS (5/5 lessons)
