## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m27/06 — "Regression + tổng kết — app đã ra khỏi lồng Dart" (synthesis milestone: boundary→coordinator→permission→effect→platform call; fake counters = OS thay thế deterministic; notification flow + version text + share chain → CONVERGED; `REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` honesty; M28 visual parity + M29 MenuDialogLayer còn lại; analyze clean + 259/259 + build web PASS).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter build web`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: milestone gate — kiểm TỔNG THỂ M27 tích luỹ trên đỉnh M26; ngoài danh sách = không tính thiếu. `REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` là trạng thái trung thực cố ý — KHÔNG báo thiếu device verification (senior cũng không có); chỉ báo nếu code claim đã verify OS-thật mà không có bằng chứng.

EXPECTED STATE SAU BÀI NÀY (M27 tích luỹ):
- Platform boundary chain ĐỦ (STRICT):
  - `pubspec.yaml` 5 pin verbatim (`flutter_local_notifications ^22.0.1`, `package_info_plus ^10.1.0`, `timezone ^0.11.0`, `flutter_timezone ^5.1.0`, `share_plus ^13.1.0`);
  - `AndroidManifest.xml` 2 `uses-permission` + 2 receiver verbatim `com.dexterous.flutterlocalnotifications.*`;
  - `lib/services/local_notification_service.dart` — contract 5 method + impl verbatim (lazy init, `tz` prefix đôi, resolve<T> per-platform, `!kIsWeb` fallback, id 1001, `DateTimeComponents.time`, `inexactAllowWhileIdle`, `_nextDailyTime` `!isAfter` rollover, `_setLocalTimeZone` UTC-degrade);
  - `test/helpers/fake_local_notification_service.dart` — counters + `throwOn*` + `permissionGranted`/`requestResult`.
- Notification flow ĐỦ (STRICT): `settings_notification_coordinator.dart` (schedule→save order + `_saveSettingsWithRollback` best-effort giữ lỗi gốc + `_restoreSchedule`); `settings_view_model.dart` (`notificationService` + `_loadAppVersion` seam + `_hasNotificationPermission` OS-owned + `effectiveNotificationEnabled` AND-gate + `loadSettings` `Future.wait`×3 + `_toggleNotifications` 3-nhánh + `onNotificationTimeSelected`→coordinator); `settings_ui_event.dart` +`notificationPermissionRequired`; `settings_app_version_loader.dart` 6-dòng; `showSettingsDialog`/`SettingsDialogScope` `context.read`+`required` notificationService; `_snackBarText` arm + ARB key.
- DI + version + onboarding ĐỦ (STRICT): `main()` `LocalNotificationServiceImpl()` vô điều kiện (khác conditional Supabase — không dart-define); `AppDependencyScope` `Provider<LocalNotificationService>.value`; `v$appVersion` row `isNotEmpty`-gated `MenuTokens.textSecondary` 11px; `onboarding_overlay_scope.dart` `_requestNotificationPermission` verbatim (service→`requestPermission`→`onNotificationPermissionResult(granted)`; catch→`FlutterError.reportError`+`false`); 5 test hosts vá (4 `AppDependencyScope` + 1 onboarding `Provider.value`).
- Share chain ĐỦ 6 mắt (STRICT): `GameShareRequested{text}` action-14 + `GameShareResult{text}` effect-8 + `GameShareResultEvent{text}` ui-event + reducer arm-14 `_result(state, effects:[GameShareResult(text)])` state-nguyên + bridge arm-8 `_events.add` + `shareResult` VM wrapper + `onShareResult` layer `ValueChanged<String>` build-l10n-tại-layer + `_DialogShareButton` scaffold (Ended `0xFF325DFA`, Victory `statGreen`) + `_handleUiEvent` `Future<void>` share arm (`RenderBox`/`sharePositionOrigin`/`SharePlus.instance.share(ShareParams)`/catch→`Clipboard`+snackbar); ARB +4 keys; `game_dialog_layer_test` vá `onShareResult`.
- `flutter analyze` sạch; `flutter test` → **259/259** (STRICT 254 + 5 settings); `flutter build web` PASS (federated web impl + degrade paths caught).
- KHÔNG ĐƯỢC có (chưa đến — divergence mở cố ý sang M28–M29): `GameDialogButton`/`shareColor` gradient + `SettingsDialogShell`/`OnboardingGameButton`/`MenuDialogBackdrop`/`LevelProgressCard`/icon-assets/account-row auth visual (M28); `MenuDialogLayer` + `MenuDialogSettings`/`Auth`/`SignOut` state transport (M29); exact alarms/nhiều channel/notification actions/tap-handler payload/foreground presentation (senior không); share ảnh/file/analytics (senior không); iOS `hasPermission` (senior chỉ Android); re-request guidance "mở system Settings" khi denied (senior không); `initialize()` trong `main()` (lazy); conditional-DI notification; `SettingsViewModel` DRE-hoá (vẫn `extends ChangeNotifier` — senior không DRE settings); `_hasNotificationPermission` persist vào SharedPreferences (OS-owned); `_DialogShareButton` "đã làm đẹp" thành GameDialogButton (M28 việc).
- Honesty check (STRICT): không comment/test nào claim notification OS thật/share sheet thật/OS prompt đã được verify (REAL_DEVICE_PLATFORM_CHECK NOT_PERFORMED — fake counters + degrade paths là bằng chứng duy nhất); không "đã test notification" trong test names (test verify ý định qua counters, không verify plugin↔OS).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- M26 đỉnh DRE nguyên (GameState 13-field, action 13→14, effect 7→8 — chỉ share mở rộng; reducer/bridge/VM/`flowToken`/`hasSavedResult` không đổi); M25 sync pipeline + `_syncSavedGameResult`; M24 auth + 2 dialog VM + coordinator; M23 conditional DI + leaderboard VM `_requestId`; M22 hasSavedResult; M21 layer + PopScope; M18 onboarding overlay + `onNotificationPermissionResult` VM (VM không đổi — chỉ scope connector); M16 settings dialog + 7-test cũ (giờ 12); M14 `AppDependencyScope` + repos; `GameSessionState` không còn trong `data/` (M26); SettingsViewModel vẫn `ChangeNotifier` dialog-scoped.

Mục (STRICT) phải đúng; mục khác chấm semantic. Suite ≠ 259 hoặc build web fail = NEEDS_FIX/BLOCKED. Claim "device-verified" mà không có bằng chứng device = DIVERGED honesty. `_DialogShareButton` → GameDialogButton sớm = AHEAD_COMPATIBLE (M28 sẽ làm).

OUTPUT (đúng format; mục trống → "None"):
LESSON: m27/06
PROJECT_ALIGNMENT: ON_TRACK | NEEDS_FIX | DIVERGED | BLOCKED
COURSE_POSITION: ON_TRACK | BEHIND | AHEAD_COMPATIBLE | AHEAD_RISKY
READY_FOR_NEXT_LESSON: YES | YES_AFTER_FIXES | NO
VERIFICATION_PERFORMED:
WHAT_MATCHES:
GAPS:
AHEAD_OF_COURSE:
DIVERGENCES:
REQUIRED_FIXES_BEFORE_CONTINUING:
EVIDENCE: file/symbol → observation
FILES_MODIFIED_BY_REVIEW: NONE
```
