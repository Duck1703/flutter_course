# M16 — IMPLEMENTATION EVIDENCE (Flux)

Role: Flux (implementation). Brief: `01-brief.md`. Senior inspected
directly at `main @ c8eb860`, read-only, unchanged.

## Files created

- `lib/data/settings/supported_language_data.dart` —
  `SupportedLanguageData` {english(en), vietnamese(vi)} + `values` +
  `isSupportedCode` + `fromCode`. Mirrors senior
  `lib/data/settings/supported_language_data.dart` 1:1 (2 languages,
  same API). Used NOW by the language chip row (senior uses it the same
  way in `LanguageChipRow`); M17 will additionally drive
  `MaterialApp.locale` from `code`.
- `lib/data/settings/setting_item_data.dart` — `enum SettingType
  {sound,music,haptic,notifications}` + `sealed class
  SettingItemData{icon,text,subtitle,settingType}` with
  `SettingSwitchItemData(isEnabled)` and
  `SettingTimePickerItemData(hour,minute)` whose `formattedTime`
  = `'$h:$mm'` via `padLeft(2,'0')`. Mirrors senior
  `setting_item_data.dart`; learner uses `IconData` (senior uses asset
  path strings — `iconAsset`) because learner app has no icon assets;
  document as FR-note in evidence below.
- `lib/view_models/settings/settings_ui_event.dart` — sealed
  `SettingsUiEvent` {`SettingsDismissRequested`,
  `SettingsSnackBarRequested(SettingsSnackBarMessage)`} + enum
  `SettingsSnackBarMessage` {loadFailed, updateFailed,
  notificationTimeUpdateFailed}. Senior also has
  `notificationPermissionRequired` — omitted: notification permission
  is M27 surface (FR-27).
- `lib/view_models/settings/settings_item_factory.dart` —
  `buildSettingItems({settings, effectiveNotificationEnabled})` →
  4 `SettingSwitchItemData` + conditional `SettingTimePickerItemData`
  when notifications effective. Senior signature also takes localized
  strings; learner is pre-l10n (M17) so labels are Vietnamese literals.
- `lib/view_models/settings/settings_view_model.dart` —
  `SettingsViewModel extends ChangeNotifier`: ctor seeds `_settings`
  from `userSettingsStream.value` + subscribes; `settingItems`,
  `effectiveNotificationEnabled` (name kept — senior ANDs with
  notification permission; FR-27 documents the difference);
  `toggleSetting` = exhaustive switch on `SettingType` → `copyWith` →
  repo save → stream; `selectLanguage` (persist `languageCode`, skip
  no-op); `showTimePicker`/`dismissTimePicker` (visibility = VM state);
  `onNotificationTimeSelected` (persist hour+minute); broadcast
  `events`; `loadSettings` (senior `Future.wait` collapses to single
  load — permission/version are M27); `dispose` cancels both.
- `lib/widgets/menu/settings/settings_dialog.dart` —
  `showSettingsDialog(context)` reads `UserSettingsRepository` via
  `context.read` from the CALLING context and passes it in;
  `SettingsDialogScope` = `ChangeNotifierProvider<SettingsViewModel>`
  INSIDE the dialog subtree (dialog-scoped VM; Provider disposes it on
  pop — matches senior `MenuSettingsDialogScope`); private
  `_SettingsDialogEventBridge` (didChangeDependencies attach, `==`
  re-attach guard, `_didLoadSettings` once-flag →
  `unawaited(loadSettings())`, sealed switch → `pop()` /
  `SnackBar`); `_SettingsDialog` renders `timePickerVisible`-driven
  content swap; `_SettingItemRow` = exhaustive switch over sealed
  variants; `_LanguageChipRow` over `SupportedLanguageData.values`.
- `lib/widgets/menu/settings/notification_time_picker_dialog.dart` —
  `NotificationTimePicker`: `ListWheelScrollView.useDelegate` +
  `FixedExtentScrollController(initialItem:)` two wheels (hour 0-23,
  minute 0-59) + XÁC NHẬN/HỦY. Same primitives as senior
  `wheel_picker.dart`/`time_picker_wheels.dart`.

## Files modified

- `lib/data/settings/user_settings_data.dart` — docstring updated;
  `_nonEmptyLanguageCode` guard KEPT (see FR-26 note below).
- `lib/view_models/menu/menu_screen_ui_event.dart` — added third
  sealed variant `MenuSettingsRequested`.
- `lib/view_models/menu/menu_view_model.dart` — `requestSettings()` →
  `_events.add(MenuSettingsRequested())`.
- `lib/screens/menu_screen.dart` — bridge `case MenuSettingsRequested`
  → `unawaited(_openSettings())` → `showSettingsDialog(context)`;
  `_ProfileHeader` gained `onSettingsTap` + gear icon (senior
  `GlassIconButton(iconGear)` → learner `GestureDetector`+`Icon`
  — icon asset not present in learner app).

## Tests added/updated

- `test/settings_view_model_test.dart` (7 tests): seed-from-stream,
  toggle persist + notify, notifications-on reveals time row (20:00),
  `onNotificationTimeSelected` persists 7:30, `selectLanguage` persists
  + skips no-op, `saveSettings` → `SettingsDismissRequested`, load
  failure → `loadFailed` snackbar event (throwing fake subclass).
- `test/widgets/settings_dialog_test.dart` (5 tests): 4 switches +
  chips + XONG + no time row when notifications off; sound Switch tap →
  repo persist; notifications on → time row appears (ensureVisible —
  row sits below fold) → picker swaps content in-dialog → XÁC NHẬN
  persists 20:00 and returns to main content; Tiếng Việt chip →
  `languageCode='vi'`; XONG → `SettingsDismissRequested` → pop.
- `test/menu_view_model_test.dart` — `requestSettings` →
  `MenuSettingsRequested`.
- `test/sealed_state_test.dart` — exhaustive switch gains third arm.

## Senior-fidelity decisions

1. **Dialog-scoped VM kept.** `ChangeNotifierProvider(create:)` lives
   inside the dialog subtree; VM exists only while dialog open — exact
   senior ownership semantics (roadmap completion criterion).
2. **In-dialog content swap for the picker.** Senior overlays the wheel
   picker inside `MenuSettingsDialogScope`'s Stack/dialog layer (M21
   dialog system). Learner has no dialog layer (FR-16 → M21), so the
   picker swaps the dialog's `AlertDialog` content via
   `timePickerVisible` — same render-by-state model as M15, no nested
   `showDialog` (initially implemented as nested route; rejected as
   unnecessary complexity diverging from the state-driven direction).
3. **Gear entry point.** Senior: `MenuDialogSettings` state →
   `menu_dialog_layer` renders scope. Learner (FR-16 active):
   `MenuSettingsRequested` event → `showDialog`. Event shape mirrors
   `MenuGameRequested`/`MenuSnackBarRequested` exactly.
4. **Omissions are all registered:** LocalNotificationService/
   coordinator/version/permission (M27, FR-27/FR-28), account-row auth
   action (senior shell has it; learner account row is display-only),
   `SettingsDialogShell` styling (tokens already exist).
5. **`iconAsset` → `IconData`.** Learner app ships no SVG icon assets;
   `SettingItemData.icon` is `IconData`. Visual-only difference; data
   model shape (icon,text,subtitle,settingType) preserved.
6. **FR-26 deliberately NOT converged.** During implementation the
   whitelist guard was briefly applied then REVERTED: the register
   assigns `languageCode` whitelist convergence to M17 together with
   the real language model. `SupportedLanguageData` ships now because
   the senior language-chip row needs it; `_nonEmptyLanguageCode`
   remains the guard. FR-26 stays ACTIVE → M17.

## Regression (post-implementation)

- `flutter analyze` → `No issues found!`
- `flutter test` → **87/87** passed (was 74 baseline; +13 M16 tests)
- `flutter build web` → `√ Built build\web`
- `dart format` applied to all touched files.

## Known deviations to register (for Argus/Atlas)

- `iconAsset` → `IconData` substitution (new ACTIVE_TEMPORARY or
  documented permanent simplification — learner has no icon assets
  pipeline; senior target uses `iconAsset` strings resolved by widgets).
- `notificationPermissionRequired` event variant deferred with FR-27.
