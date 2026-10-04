# M27 — Atlas Brief: Platform extras (notifications, share, package info)

## Roadmap assignment (verbatim anchors)

`MILESTONE_ROADMAP.md` M27: daily local notifications (permission +
`zonedSchedule` + timezone), `share_plus` result sharing with
clipboard fallback, `package_info_plus` version row. Excluded:
exact-alarm modes, extra channels, boot-receiver depth, rollback
choreography (concept only).

## SENIOR FIDELITY CHECK

| Row | Learner (post-M26) | Senior target | M27 action | Final |
|---|---|---|---|---|
| FR-27 | Toggle persists flag only; `effectiveNotificationEnabled` == flag; onboarding simulates grant `onNotificationPermissionResult(true)`; no `LocalNotificationService`, no `notificationPermissionRequired` | `LocalNotificationService` contract+impl (plugin+timezone); `SettingsNotificationCoordinator` (enable/disable/updateTime + rollback); permission AND; `Future.wait` 3-way load; onboarding real `requestPermission` via scope | Port verbatim; wire DI; settings VM port verbatim; onboarding scope port | CONVERGED |
| FR-28 residual | Settings dialog: no `v$appVersion` text | `loadSettingsAppVersion` (`PackageInfo.fromPlatform().version`) → `appVersion` → `v…` bottom-right text | Port loader + VM field + dialog text | CONVERGED (version part) |
| FR-33 (unnumbered share row — tracked as dialog comment FR-33 refs) | `GameShareResultEvent` absent; no `shareResult` VM wrapper; no `GameShareRequested`/`GameShareResult` in DRE layer; result dialogs have 2 buttons, no share | `GameShareRequested(text)` → `GameShareResult` effect → `GameShareResultEvent` → screen `SharePlus.instance.share(ShareParams(text, sharePositionOrigin))` → catch → `Clipboard.setData` + snackbar; share button on ended+victory dialogs | Port full chain verbatim | CONVERGED |

### Senior paths/symbols (verified on disk, `c8eb860`)

- `lib/services/local_notification_service.dart` — contract (5
  methods) + `LocalNotificationServiceImpl` (plugin, `_dailyNotificationId
  1001`, channel `daily_quiz_notification`, `zonedSchedule` +
  `DateTimeComponents.time` + `inexactAllowWhileIdle` + payload
  `'daily_quiz'`; `flutter_timezone` → `tz.setLocalLocation` w/ UTC
  fallback; `_nextDailyTime` next-day rollover; `hasPermission`
  Android-resolve, `requestPermission` Android/iOS/macOS resolve,
  `!kIsWeb` fallback).
- `lib/view_models/settings/settings_notification_coordinator.dart`
  — enable→schedule-then-save-with-cancel-rollback; disable→
  cancel-then-save-with-restore-rollback; `updateTime` conditional
  schedule + restore-on-throw.
- `lib/view_models/settings/settings_app_version_loader.dart` — 6-line
  `PackageInfo.fromPlatform().version` loader seam.
- `lib/view_models/settings/settings_view_model.dart` — fields
  `notificationService`, `_hasNotificationPermission`, `_appVersion`,
  `_notificationCoordinator`, `_loadAppVersion`; `loadSettings`
  `Future.wait` ×3; `_toggleNotifications` (request→denied→save-off
  +snackbar / granted→coordinator.enable); `onNotificationTimeSelected`
  → coordinator; `effectiveNotificationEnabled` = flag AND permission.
- `lib/view_models/settings/settings_ui_event.dart` — enum +
  `notificationPermissionRequired`.
- `lib/widgets/menu/settings/{menu_settings_dialog_scope,settings_card}.
  dart` — `context.read<LocalNotificationService>()` into VM;
  `v$appVersion` when non-empty.
- `lib/screens/game_screen.dart:177-198` — `GameShareResultEvent` case:
  `RenderBox` sharePositionOrigin → `SharePlus.instance.share` → catch →
  `Clipboard.setData` + `resultCopiedSnackBar` snackbar.
- `lib/view_models/game/dre/game_dre_action.dart` (`GameShareRequested`),
  `game_dre_effect.dart` (`GameShareResult`), `game_reducer.dart:55`
  (effect arm), `bridge/..._effects.dart:20` (→`GameShareResultEvent`),
  `game_screen_view_model.dart:117` (`shareResult` dispatch wrapper),
  `game_dialog_layer.dart` (`onShareResult` param; ended→
  `shareResultMessage(earned)`, victory→`shareVictoryResultMessage
  (earned, affirmation)`), `game_result_dialogs.dart` (share
  `GameDialogButton`, `Icons.share`).
- `android/app/src/main/AndroidManifest.xml` — 2 receivers
  (ScheduledNotificationReceiver, ScheduledNotificationBootReceiver).
- `test/helpers/fake_local_notification_service.dart` (54 lines,
  counters + throwOn*).
- `test/settings_view_model_test.dart` — 10 tests incl. permission/
  schedule/cancel/rollback/version branches.
- `test/onboarding_app_test.dart` — `FakeLocalNotificationService`
  ctor dep.
- pubspec: `flutter_local_notifications ^22.0.1`, `timezone ^0.11.0`,
  `flutter_timezone ^5.1.0`, `package_info_plus ^10.1.0`,
  `share_plus ^13.1.0`.

### Rows intentionally remaining active

FR-28 account-row **visual** (M28 umbrella), FR-29 menu dialog
transport (M29), FR-30/32/34 visuals (M28), FR-31 l10n, FR-25
senior-source note. `GameDialogShell`/`QzdsGameButton` share-button
visual styling → M28 (learner share button reuses existing
`_DialogTextButton`/dialog chrome — senior uses `GameDialogButton`
which is an M28-visual widget; the *callback wiring* lands now).

### Permitted simplifications

- Share button uses learner's existing dialog button style (senior's
  `GameDialogButton`/`shareColor` visuals are M28-owned FR-34-adjacent).
- iOS/macOS paths compile but cannot be device-verified; Android
  manifest receivers copied with explanation.
- Web: `share_plus`/`flutter_local_notifications` are no-op-safe by
  senior design (`!kIsWeb` guards); app remains web-buildable.

### Forbidden alternatives

- No direct plugin calls from widgets (senior routes through service
  contract + coordinator).
- No scheduling without permission check (senior disables switch).
- No real OS share sheet / notification in automated tests.

## LEARNING DESIGN CHECK

- New Dart: `timezone`/`flutter_timezone`, `kIsWeb`, plugin
  `resolvePlatformSpecificImplementation`, `ShareParams`/
  `sharePositionOrigin`, `PackageInfo.fromPlatform`.
- New Flutter: `flutter_local_notifications` init/settings objects,
  per-platform permission APIs, `SharePlus.instance.share`,
  `Clipboard.setData`.
- New architecture: service contract boundary (VM→contract→plugin);
  coordinator with best-effort rollback; platform service DI via
  `Provider<Contract>.value`.
- Prerequisites taught: M13 events, M14 DI/contracts, M16 settings VM,
  A-26 coordinator call-site, M26 effects stream (share rides it).
- New concepts (registry): A-35 service-contract platform boundary;
  A-36 coordinator + best-effort rollback; A-37 permission-as-state
  (`_hasNotificationPermission` AND gate); D-47 `kIsWeb` + platform
  resolve; F-33 `share_plus`/`Clipboard`; F-34 `flutter_local_
  notifications`+`zonedSchedule`/`DateTimeComponents.time`;
  F-35 `package_info_plus`.
- Depth: contract/service=CORE, coordinator=NORMAL, share=NORMAL,
  version=LIGHT, manifest receivers=LIGHT (copy w/ explanation).
- Mental models: "UI never touches a plugin directly"; "permission is
  state the OS owns — you query/request, never assume"; "schedule =
  data at a wall-clock, matched daily by `DateTimeComponents.time`".
- Isolated examples: fake notification service counters; share-payload
  pure function; version loader seam.
- Independent exercises: implement fake service + assert
  schedule/cancel; PREDICT rollback path on save-failure; build share
  text from dialog variant.
- Cognitive load: 6 lessons; one concept per step; platform files
  land verbatim, teaching focuses on boundary + tests.
- Sequential checkpoints: deps → service+fake+tests → coordinator+VM
  +tests → dialog/scope wiring+version → share chain → regression.

## Tests (port senior verbatim, package-renamed)

`test/helpers/fake_local_notification_service.dart` +
`settings_view_model_test.dart` → 10-test senior suite (permission
grant/deny, schedule counts+times, cancel, schedule-failure rollbacks,
version '9.9.9' injected, time picker reschedule). Share: widget-test
the event→callback wiring + unit-test the reducer share arm; OS sheet
not exercised. Manifest receivers documented, not unit-tested.
`REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` expected — deterministic
fakes carry verification.
