# M16 BRIEF — Settings feature (persisted)

> Atlas, for milestone M16 of the Step-15 long run (M16 → M17 → M18 →
> hard stop before M19). Sources: `MILESTONE_ROADMAP.md` §M16,
> `SENIOR_FIDELITY_REGISTER.md` (read from disk), senior source
> `main @ c8eb860` (read-only, inspected this run — see evidence).

## SENIOR FIDELITY CHECK

### Senior source target

The settings feature = a dialog-scoped `SettingsViewModel` rendering a
`SettingsCard` of `SettingItemData` rows, all backed by the persisted
`UserSettingsRepository` stream.

### Senior files/symbols (inspected on disk, `main @ c8eb860`)

- `lib/view_models/settings/settings_view_model.dart` —
  `SettingsViewModel extends ChangeNotifier`: seeds `_settings` from
  `userSettingsStream.value`, subscribes in ctor
  (`_settingsSubscription`), `settingItems` getter → `buildSettingItems`,
  `toggleSetting(SettingSwitchItemData)` = exhaustive `switch` over
  `SettingType` → `copyWith` → `saveUserSettings`, `selectLanguage`,
  `showTimePicker`/`dismissTimePicker`/`onNotificationTimeSelected`,
  broadcast `StreamController<SettingsUiEvent>` (`events`), `dispose`
  cancels sub + closes events. Deps: `UserSettingsRepository` +
  `LocalNotificationService` + `SettingsNotificationCoordinator` +
  `loadSettingsAppVersion` (last three are M27 surface).
- `lib/view_models/settings/settings_ui_event.dart` — sealed
  `SettingsUiEvent` {`SettingsDismissRequested`,
  `SettingsSnackBarRequested(SettingsSnackBarMessage)`}; enum
  `SettingsSnackBarMessage` {loadFailed, updateFailed,
  notificationTimeUpdateFailed, notificationPermissionRequired}.
- `lib/data/settings/setting_item_data.dart` — `enum SettingType
  {sound,music,haptic,notifications}`; `sealed class SettingItemData`
  {iconAsset,text,subtitle,settingType} with `final class
  SettingSwitchItemData(isEnabled)` + `final class
  SettingTimePickerItemData(hour,minute,formattedTime→padLeft)`.
- `lib/view_models/settings/settings_item_factory.dart` —
  `buildSettingItems({settings, effectiveNotificationEnabled, …texts})`
  → 4 switch rows + conditional `SettingTimePickerItemData` when
  notifications effective.
- `lib/widgets/menu/settings/menu_settings_dialog_scope.dart` —
  `MenuSettingsDialogScope`: `ChangeNotifierProvider<SettingsViewModel>`
  INSIDE the dialog surface (created when dialog opens, disposed on
  close); `_SettingsDialogEventBridge` (didChangeDependencies attach,
  `==` re-attach guard, `_didLoadSettings` once-flag →
  `unawaited(viewModel.loadSettings())`, sealed event switch →
  `onDismiss()` / `SnackBar`).
- `lib/widgets/menu/settings/settings_card.dart` — `SettingsCard`:
  `SettingsDialogShell` + sections Language (LanguageChipRow) / Audio
  (3 switch rows) / Notifications (switch + conditional time row) /
  Account + version text + Done button; `_rowsFor` = exhaustive switch
  on `SettingItemData` variants.
- `lib/widgets/menu/settings/time_picker_wheels.dart` +
  `wheel_picker.dart` — `ListWheelScrollView.useDelegate` +
  `FixedExtentScrollController(initialItem:)` two-wheel picker.
- `lib/widgets/common/language_chip_row.dart` — chips over
  `SupportedLanguageData.values`, `selected = code == selected`.
- `lib/data/settings/supported_language_data.dart` — `english`/`vi`
  constants + `values` + `isSupportedCode` + `fromCode`.
- `lib/view_models/menu/menu_screen_view_model.dart:94` —
  `requestSettingsDialog()` → `_setDialogState(MenuDialogSettings())`;
  `menu_dialog_layer.dart:55` renders `MenuSettingsDialogScope`.
- `lib/widgets/menu/profile/menu_profile_header.dart:41-44` — gear
  icon `GlassIconButton(assetIcon: iconGear, onTap: onSettingsTap)`.

### Current learner state

- `UserSettingsData` + `UserSettingsRepository`(impl) exist since M14,
  wired through `MultiProvider` + `main()` `loadUserSettings()` — the
  repository is real but has NO consumer UI. Field set already equals
  senior; `fromMap` guard is non-empty only (FR-26).
- Menu header: avatar + name pill; NO settings gear (the M03 sound
  toggle was removed at Step-10 — FR-20 REMOVED).
- Dialog mechanism: `showDialog`/`AlertDialog` only (FR-16 → M21).

### Senior target state (M16 slice)

Settings dialog reachable from menu gear; dialog-scoped VM; toggles +
time + language persist through repository → stream → rebuild;
notification side-effects and version row NOT in this slice (M27).

### Register entries expected to close

- **FR-26 → CONVERGED at M16** (early): chips write real
  `languageCode` via `selectLanguage` (senior semantics), which makes
  `SupportedLanguageData` necessary in M16; the whitelist guard lands
  with it. Register updated at canonical sync; M17's brief will note
  the early convergence. Justification: leaving a weak guard while a
  UI can write the value is the less honest state.

### Entries remaining active

- FR-16 (showDialog vs in-Stack `MenuDialogLayer`) — settings dialog
  rides `showDialog`; layer converges M21.
- FR-11 (menu reset button → M24), all game rows (M19+).
- **New rows to open:**
  - `FR-27` — notification side-effects: senior requests OS permission
    + schedules via `LocalNotificationService`/
    `SettingsNotificationCoordinator`; learner toggle persists the flag
    and stores the picked time only → converges M27.
  - `FR-28` — settings account row action + app-version row:
    senior `SettingsAccountRow` carries sign-in/out (M24 auth) and
    `loadSettingsAppVersion` uses `package_info_plus`; learner shows a
    profile-only account row, no version row → converges M24/M27.
  - `FR-29` — `MenuDialogSettings`/`MenuDialogLayer` entry path: senior
    opens settings via `MenuDialogState`; learner gear →
    `MenuSettingsRequested` event → `showDialog` → converges M21 with
    FR-16. (Row may merge into FR-16's description instead — decide at
    sync; keep one register row per remaining surface either way.)

### Permitted simplifications

- `showDialog` mechanism for the settings dialog (FR-16, M21).
- `LocalNotificationService`, `SettingsNotificationCoordinator`,
  permission flow, scheduling — absent; toggle persists flag (M27).
- `loadSettingsAppVersion`/`package_info_plus` — absent (M27).
- `SettingsAccountRow` without auth action (M24).
- Simplified two-wheel `ListWheelScrollView` picker instead of senior's
  custom `WheelPicker` chrome (fade overlay, semantic wheels) —
  same primitives, fewer decorations.
- `SettingsSnackBarMessage` keeps {loadFailed, updateFailed,
  notificationTimeUpdateFailed}; `notificationPermissionRequired`
  arrives with M27 (no writer yet — a dead enum member is worse).
- `SettingsViewModel.loadSettings` = `await repo.loadUserSettings()`
  only; senior's `Future.wait` triple-load excluded per roadmap
  ("Future.wait parallel load" explicitly excluded → M27).

### Forbidden alternatives

- No `MenuDialogState`/`MenuDialogLayer`/`isVisible`/`transitionKey`
  (M21). No `GameScreenUiEvent` (M19). No in-`Stack` overlay patterns
  beyond a `showDialog`-hosted dialog. No `intl`/l10n (M17). No
  onboarding code (M18). No local-notification packages (M27). No
  `package_info_plus` in M16 (optional per roadmap; we skip it).
- No custom settings file format, no replacement of the existing
  `BehaviorSubject`-seeded repository architecture.

## LEARNING DESIGN CHECK

### New Dart concepts

- `enum SettingType` as dispatch key inside sealed item data —
  reinforcement (D-06/D-27 already taught).
- `SettingItemData` sealed family + factory `buildSettingItems` with
  collection-if conditional row — reinforcement + first real use of
  "sealed items driving list UI".
- `String.padLeft` time formatting — LIGHT.
- `SettingsUiEvent` sealed + enum payload — reinforcement.

### New Flutter concepts

- **`Switch`/`SwitchListTile`-style toggle row** — first real form
  control in the course → NORMAL/CORE-leaning: onChanged semantics,
  `value`, visual vs persisted state.
- **Dialog-scoped ViewModel** (`ChangeNotifierProvider` created inside
  the dialog subtree; VM lives only while dialog open) — CORE
  (ownership/lifecycle is the teaching payload; roadmap names it the
  IMPORTANT DIFFERENCE).
- **`ListWheelScrollView` + `FixedExtentScrollController`** — first
  scrollable-picker; NORMAL (simplified two-wheel dialog).
- `ChoiceChip`-style language row (GestureDetector chips —
  reinforcement; senior uses custom `_LanguageChip`).
- `showDialog` with a Provider subtree — composition note (dialog's
  BuildContext can't see the screen's providers → scope must be inside).

### New architecture concepts

- **Feature state through repository→stream→UI loop end-to-end** —
  CORE reinforcement: first milestone where the learner *builds* the
  full loop for a second domain (settings) themselves.
- Dialog-scoped VM ownership (who creates/disposes; dialog = scope
  boundary) — new.

### Prerequisites (all resolve in registry/graph)

- D-04 class, D-05 copyWith, D-06 enum, D-09/D-10 Future/Stream,
  D-15 Map/JSON, D-19 interface+implements, D-20 static create,
  D-26 sealed, D-27 exhaustive switch/patterns, F-04/F-05
  Stateful/setState, F-13 showDialog/AlertDialog, F-15 ChangeNotifier,
  F-17/F-18 Provider/ChangeNotifierProvider, F-21 MultiProvider,
  A-06 repository, A-07 DI by contract, A-08 BehaviorSubject,
  A-09 state-vs-event stream, A-10 read/write boundary, A-11 fakes,
  A-14 render-by-state. All TAUGHT or MASTERED — graph closed for
  this scope.

### Registry changes required (before Lumen writes)

- **F-23** `Switch`/toggle control + `value`/`onChanged` — NORMAL —
  taught M16, first code M16.
- **F-24** `ListWheelScrollView` + `FixedExtentScrollController` —
  NORMAL — taught M16, first code M16.
- **A-15** dialog-scoped VM ownership — CORE — taught M16 (inside the
  settings-dialog lesson).
- **D-29** `padLeft`/time formatting — LIGHT — M16.
- Reinforcement notes: A-06/A-08/A-10 (settings domain), F-21
  (Provider inside dialog subtree), D-26/D-27 (sealed items +
  exhaustive switch on `SettingItemData`), A-05/A-09
  (SettingsUiEvent broadcast + enum payload).
- Prereq-graph edge: `repository+stream (M14) → sealed items →
  dialog-scoped VM → control rows (Switch/wheel) → persisted settings UI (M16)`.

### Depth classification

CORE_CONCEPT: dialog-scoped VM ownership (A-15). NORMAL: `Switch`
(F-23), wheel picker (F-24), sealed SettingItemData application.
LIGHT: padLeft. All repository/stream/DI = reinforcement only.

### Mental models required

- **A-15:** "scope = lifetime": `ChangeNotifierProvider(create:)` inside
  the dialog builder = VM born with the dialog, dies with it; compare
  screen-scoped (M12 `MenuViewModel`) vs app-scoped (repos).
- **Settings loop:** `toggle → VM.copyWith → repo.save → subject emit →
  stream → VM._handleSettings → notifyListeners → row rebuild`; the
  repo stream is the single source of truth — the VM never holds a
  private second source.
- **SettingItemData:** "list of typed row descriptions → UI renders by
  variant" (sealed family drives widget choice — M15 concept applied
  to a list, not a single dialog).

### Isolated examples required

- A-15 CORE: tiny counter dialog — open `showDialog` containing
  `ChangeNotifierProvider(create: CounterVm)`; increment, close, reopen
  → state reset = proof of scope-as-lifetime.
- `Switch`: standalone `value/onChanged` mini-example.
- Wheel picker can demo inside the lesson build (bounded NORMAL).

### Independent exercise

- PRODUCE: learner adds a **5th setting** — a `SettingSwitchItemData`
  (e.g. `musicEnabled` is provided; learner adds a new bool field like
  `vibrationSeparate`? — NO, can't invent model fields). Real exercise:
  learner adds a new sealed `SettingItemData` variant —
  `SettingInfoItemData(text, subtitle)` rendered as a read-only info
  row (e.g. "Phiên bản: 1.0") — extends the sealed family + factory +
  exhaustive switch themselves. Hidden solution.
- Plus a DEBUG/PREDICT: "toggle a switch while `pumpAndSettle`
  watching persistence" or "remove a `SettingType` case in
  `toggleSetting` → predict the compile error".

### Concept reinforcement

- Sealed family + exhaustive switch (M15) applied to a NEW domain.
- Event bridge pattern (M13) reproduced inside a dialog subtree.
- Repository save→stream→rebuild (M14) second application.

### Cognitive-load assessment

- L01 motivation+model: 0 new syntax. L02 Switch+data loop: 2.
- L03 dialog-scoped VM: 1 major (CORE). L04 sealed items+factory: 1.
- L05 wheel+time row: 1. L06 language row+assembly+exercises: 1.
- ≤3/lesson satisfied.

### Lesson split decision (Atlas)

**6 lessons** (may flex ±1 at Lumen draft time with recorded reason):

1. `01-vi-sao-settings` — why settings need persistence+architecture;
   settings loop mental model; sealed-item concept preview.
2. `02-switch-va-vong-du-lieu` — `Switch` control (NORMAL) + the
   repo→stream→UI loop end-to-end; `toggleSetting` dispatch.
3. `03-viewmodel-trong-dialog` — dialog-scoped VM CORE + sealed
   `SettingsUiEvent` + bridge inside dialog; menu gear →
   `MenuSettingsRequested` → `showDialog`.
4. `04-sealed-item-factory` — `SettingItemData` family +
   `buildSettingItems` + exhaustive row rendering; account row.
5. `05-wheel-picker-gio` — `ListWheelScrollView` + controller +
   `padLeft`; notification time row; persist picked time.
6. `06-ngon-ngu-va-hoan-thien` — `SupportedLanguageData` + chips +
   `selectLanguage` + FR-26 guard convergence; full assembly +
   independent exercise + synthesis.

Rationale: M14's Step-13 lesson learned — never put VM ownership +
new widgets + sealed family on one page.

### Sequential checkpoint strategy

- L01 theory-only → analyze clean.
- L02: VM + switch row compile + repo round-trip test runnable.
- L03: dialog opens/closes, VM lifecycle observable, snackbar events.
- L04: all sections render, toggles persist across restart.
- L05: time row appears when notifications on; picked time persists.
- L06: language chips persist; full suite + `flutter build web`.

## Scope allow-list (G1)

`learner-app` writes confined to: `lib/data/settings/`(+`setting_item
_data.dart`, `supported_language_data.dart`; guard edit inside
`user_settings_data.dart`), `lib/view_models/settings/`(new),
`lib/widgets/menu/settings/`(new), `lib/screens/menu_screen.dart`
(gear + bridge case), `lib/view_models/menu/menu_view_model.dart`
(+`requestSettings`), `lib/view_models/menu/menu_screen_ui_event.dart`
(+`MenuSettingsRequested`), `test/`(new settings tests). Nothing else.

## Risk flags

- `UserSettingsRepository` is app-scoped; the dialog reads it via
  `context.read` inside the dialog subtree — providers from the app
  scope ARE visible below `showDialog`? No: `showDialog` uses
  `useRootNavigator` context — the dialog's context does NOT see the
  app's `MultiProvider`. The scope's `ChangeNotifierProvider` must
  create the VM using the repo obtained from the CALLING context
  (menu screen) — captured before `showDialog`, or via a
  `Provider.value` inside the dialog builder. Flux must implement the
  correct injection (capture repo in the menu's context, pass it into
  the provider inside the dialog).

---

## ADDENDUM (dated — implementation correction, Atlas)

The brief proposed converging **FR-26 at M16** ("chips write real
`languageCode` → whitelist guard lands"). During implementation the
guard WAS briefly applied, then deliberately **reverted**: the
canonical register assigns FR-26 convergence to M17 together with the
real language model (`MaterialApp.locale` + gen-l10n), and converging
the parse guard early would silently pull M17 scope forward.

Final disposition: `_nonEmptyLanguageCode` (non-empty check) remains
the guard — **FR-26 stays ACTIVE_TEMPORARY → M17**.
`SupportedLanguageData` still ships in M16 because the senior
language-chip row needs it as a UI model; `isSupportedCode`/`fromCode`
exist but are not yet consulted by `UserSettingsData.fromMap`.
Lessons must say exactly this — "chips persist the choice now; the
guarded whitelist and the actual locale switch are M17".

## ADDENDUM-2 (dated — QA correction)

Content QA (MAJOR-2) flagged a false rationale propagated from this
brief: "context inside a `showDialog` route cannot see the app's
`MultiProvider`". Actually `AppDependencyScope` wraps `MaterialApp`
(above the root Navigator) — app-scoped repos ARE reachable from a
dialog route. What is NOT reachable: providers *below* the Navigator
(e.g. `MenuViewModel`'s provider inside `MenuScreen`). The read-at-
caller-and-pass-instance pattern stands — it keeps the dialog scope
self-contained and pumpable in tests — but for that reason, not
"invisible providers". Lessons + code comments corrected.
