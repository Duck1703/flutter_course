# M27 Implementation Notes — Platform extras

Ported the senior's three remaining platform surfaces verbatim:
daily local notifications (permission + `zonedSchedule` + timezone),
`share_plus` result sharing with clipboard fallback, and
`package_info_plus` version row.

## Verbatim ports (package-renamed where applicable)

- `lib/services/local_notification_service.dart` — contract (5
  methods) + `LocalNotificationServiceImpl`: plugin init with
  per-platform settings objects, `tz.initializeTimeZones()` +
  `FlutterTimezone.getLocalTimezone()` → `tz.setLocalLocation`
  (UTC fallback), `zonedSchedule` id `1001` on channel
  `daily_quiz_notification` with `DateTimeComponents.time` +
  `AndroidScheduleMode.inexactAllowWhileIdle` + payload
  `'daily_quiz'`, `_nextDailyTime` next-day rollover, permission
  APIs via `resolvePlatformSpecificImplementation`, `!kIsWeb`
  value-fallbacks.
- `lib/view_models/settings/settings_notification_coordinator.dart`
  — enable (schedule→save, cancel-rollback on save-fail),
  disable (cancel→save, restore-schedule rollback), updateTime
  (conditional reschedule→save, restore rollback); best-effort
  rollback preserves the original persistence error.
- `lib/view_models/settings/settings_app_version_loader.dart` —
  `PackageInfo.fromPlatform().version` seam.
- `test/helpers/fake_local_notification_service.dart` — counters
  + `throwOn*` flags (deterministic OS substitute).

## Senior-parity modifications

- `pubspec.yaml` — 5 pins matching senior: `flutter_local_notifications
  ^22.0.1`, `package_info_plus ^10.1.0`, `timezone ^0.11.0`,
  `flutter_timezone ^5.1.0`, `share_plus ^13.1.0`.
- `settings_view_model.dart` — senior logic verbatim: ctor
  `notificationService` + `loadAppVersion` seam,
  `_hasNotificationPermission`, `_appVersion`,
  `_notificationCoordinator`, `loadSettings` `Future.wait` ×3,
  `_toggleNotifications` (request→denied→save-off+snackbar /
  granted→coordinator.enable), `onNotificationTimeSelected` via
  coordinator, `effectiveNotificationEnabled` = flag AND
  permission.
- `settings_ui_event.dart` — `notificationPermissionRequired`.
- `settings_dialog.dart` — scope `context.read<LocalNotification
  Service>()` → VM; `v$appVersion` bottom-right gated `isNotEmpty`
  (senior `settings_card.dart` semantics); snackbar arm.
- `app_dependency_scope.dart` + `main.dart` —
  `LocalNotificationServiceImpl()` unconditional (service
  self-guards `!kIsWeb`; no config needed — contrasted with the
  conditional-Supabase A-24 pattern) + `Provider<Contract>.value`.
- `onboarding_overlay_scope.dart` — real `requestPermission()` +
  `FlutterError.reportError` catch (simulated
  `onNotificationPermissionResult(true)` retired — FR-27).
- Share chain — `GameShareRequested{text}` action, reducer arm
  (effect-only, state unchanged), `GameShareResult{text}` effect,
  bridge arm → `GameShareResultEvent{text}`, VM `shareResult`
  dispatch wrapper, `GameDialogLayer.onShareResult` (l10n strings
  built at layer), `_DialogShareButton` on ended+victory
  (**TEACHING SCAFFOLD** — senior `GameDialogButton`/`shareColor`
  visuals are M28-owned), `game_screen.dart` `RenderBox` →
  `sharePositionOrigin` → `SharePlus.instance.share(ShareParams)` →
  catch → `Clipboard.setData` + `resultCopiedSnackBar`.
- ARB +5 keys both locales; `AndroidManifest.xml` +2
  `uses-permission` (RECEIVE_BOOT_COMPLETED, POST_NOTIFICATIONS)
  +2 receivers — all verbatim senior.
- `onboarding_view_model.dart` — doc comment updated to describe
  the real permission flow (Argus remediation).

## Verification

- `flutter analyze` clean; `flutter test` **259/259** (+5:
  settings VM permission/schedule/rollback/version branches);
  `flutter build web` PASS (plugins web-safe by senior design).
- `REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` — no device
  attached; fake counters + seam carry verification, manifest
  receivers verified verbatim vs senior.
- Sequential replay (M26-end clone): 254→254→254→259→259→259→259,
  tree byte-identical to production.

## Register outcomes

- **FR-27** → CONVERGED at M27 (notification permission +
  scheduling + coordinator + real onboarding request).
- **FR-33** → CONVERGED at M27 (share chain end-to-end; new
  register row added).
- **FR-28** → version-text residual CONVERGED (`v$appVersion`);
  account-row visual stays M28 umbrella.
