# M16 Implementation Notes — Settings (persisted preferences)

## What landed

| Surface | Before (M15) | After (M16) |
|---------|--------------|-------------|
| Settings data | `UserSettingsData` persisted via `UserSettingsRepository` (BehaviorSubject, M14) — no UI consumer | Same repo/model — now driving a real dialog |
| Language model | `languageCode` string field (non-empty guard) | + `SupportedLanguageData` {en, vi} for chips; `isSupportedCode`/`fromCode` exist but guard **not** wired (FR-26 → M17) |
| Settings UI rows | — | `sealed SettingItemData` (`SettingSwitchItemData`/`SettingTimePickerItemData`) + `buildSettingItems` factory (state → row descriptions; collection-`if` for conditional time row) |
| Settings VM | — | `SettingsViewModel` — created by `ChangeNotifierProvider` **inside** dialog subtree (dialog-scope lifetime); seeded from `stream.value`; `toggleSetting`/`selectLanguage`/`showTimePicker`/`onNotificationTimeSelected`/`saveSettings` |
| Settings events | — | `sealed SettingsUiEvent` {`SettingsDismissRequested`, `SettingsSnackBarRequested(message)`} — one-off stream, bridge pops/shows |
| Menu entry | profile header, no settings affordance | gear `Icons.settings` (GestureDetector+opaque) → `viewModel.requestSettings()` → `MenuSettingsRequested` → bridge `unawaited(_openSettings())` → `showSettingsDialog(context)` reads repos at caller, passes instances |
| Dialog | — | `AlertDialog` + `MenuTokens`; sections NGÔN NGỮ/ÂM THANH/THÔNG BÁO/TÀI KHOẢN; chips English/Tiếng Việt; `_SettingsAccountRow` (username display-only); `timePickerVisible` content-swap for `NotificationTimePicker` (two `_TimeWheel` StatefulWidgets owning FixedExtentScrollControllers) |
| Tests | 74 | **87** (+13: 7 VM tests, 5 widget dialog tests, 1 menu event test; sealed_state_test +1 arm) |

## Register outcomes

- **FR-26 ACTIVE → M17**: `isSupportedCode`/`fromCode` exist but
  `UserSettingsData.fromMap` still uses the non-empty guard; chips
  write `'en'`/`'vi'` but nothing drives `MaterialApp.locale` yet.
- **FR-27 OPEN → M27**: switch uses `effectiveNotificationEnabled`
  (repo flag only; senior ANDs OS permission `&& _hasNotificationPermission`).
- **FR-28 OPEN → M22+/M27**: `_SettingsAccountRow` display-only
  (senior has auth button + `package_info_plus` version).
- **FR-29 OPEN → M21**: learner emits `MenuSettingsRequested` event;
  senior sets `MenuDialogState`/`MenuDialogSettings` (in-Stack layer).
- **FR-30 OPEN**: `Icons.settings` vs senior `iconGear` asset.
- FR-16 (showDialog vs senior in-Stack) unchanged → M21.

## Deliberately NOT in M16

- Runtime localization (`MaterialApp.locale`, ARB) → **M17**.
- Notification permission request/scheduling/cancel → **M27**.
- Auth button, app version row → **M22+/M27**.
- Senior `SettingsDialogShell` glass styling/`transitionKey` → M21.

## Learning-design deltas vs typical settings tutorials

- Picker is a **content swap inside the same AlertDialog**
  (`timePickerVisible` state), not a nested `showDialog` — teaches
  render-by-state inside dialogs, closer to senior's in-tree overlay
  while staying compilable per-lesson.
- `SettingsDialogScope` passed repo **instances** from caller even
  though app-scope providers are reachable above Navigator — keeps
  dialog self-contained/pumpable in tests (corrected rationale; the
  original "can't reach providers" claim was a real QA catch).

## Sequential replay

`09-sequential-replay.md`: physical M15-state clone, 5/5 lessons,
74 → 87 tests converging exactly. F-13 (use-before-create picker) and
F-14 (uncreated test files) were caught here, registered, fixed, and
proven by the replay itself.
