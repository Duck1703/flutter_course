# M27 — Implementation Evidence (Flux)

## Verbatim senior ports (package-renamed)

- `lib/services/local_notification_service.dart` — contract+impl
  verbatim (id 1001, channel, zonedSchedule, `DateTimeComponents.time`,
  `inexactAllowWhileIdle`, payload `daily_quiz`, flutter_timezone →
  `tz.setLocalLocation` UTC-fallback, `_nextDailyTime` rollover,
  Android/iOS/macOS `resolvePlatformSpecificImplementation`,
  `!kIsWeb` fallback).
- `lib/view_models/settings/settings_notification_coordinator.dart`
  — verbatim (enable/disable/updateTime + rollback semantics).
- `lib/view_models/settings/settings_app_version_loader.dart` —
  verbatim (6 lines).
- `test/helpers/fake_local_notification_service.dart` — verbatim,
  package rename.

## Senior-parity modifications

- `pubspec.yaml` — +5 pins matching senior versions.
- `settings_view_model.dart` — senior verbatim logic: ctor
  `notificationService` + `loadAppVersion` seam, `_hasNotification
  Permission`, `_appVersion`, `_notificationCoordinator`,
  `loadSettings` `Future.wait` ×3, `_toggleNotifications`
  (request→denied-save+snackbar / granted→enable), `updateTime` via
  coordinator, `effectiveNotificationEnabled` AND-gate.
- `settings_ui_event.dart` — +`notificationPermissionRequired`.
- `settings_dialog.dart` — scope reads + passes service; `v…` row
  bottom-right when non-empty; snackbar arm.
- `app_dependency_scope.dart`/`main.dart` — `LocalNotificationServiceImpl`
  unconditional (senior parity) + `Provider<Contract>.value`.
- Share chain: `GameShareRequested` action, `GameShareResult` effect,
  reducer arm (verbatim senior), bridge → `GameShareResultEvent`,
  `shareResult` VM wrapper, `GameDialogLayer.onShareResult` + l10n
  threading, ended/victory views + share button (senior colors
  0xFF325DFA / green→`statGreen`), screen `_handleUiEvent` →
  `SharePlus.instance.share` + `Clipboard` fallback + snackbar.
- ARB +5 keys both locales (share×3 + copied + permission-required),
  placeholder metadata verbatim.
- `AndroidManifest.xml` — 2 senior receivers verbatim.
- `onboarding_overlay_scope.dart` — real `requestPermission` via
  `context.read<LocalNotificationService>()` + `FlutterError.
  reportError` catch (senior verbatim).

## Tests

- `settings_view_model_test.dart` — 7→12 tests (senior suite ported:
  version seam, permission grant/deny, schedule counts+times,
  cancel, schedule-failure rollbacks, time reschedule).
- Widget/scope tests updated: `notificationService` fake +
  `onShareResult` params (7 files); onboarding host grants
  permission; dialog-pop host provides service.

## Regression

- `flutter analyze`: clean (0 issues).
- `flutter test`: **259/259** (+5).
- `flutter build web`: PASS (plugins web-safe by senior design;
  `!kIsWeb` guards).

## Real device

`REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` — plugin calls go
through the fake service in tests; no emulator/device attached.
Manifest receivers copied verbatim (documented).
