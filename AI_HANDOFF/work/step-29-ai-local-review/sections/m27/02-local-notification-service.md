## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m27/02 — "LocalNotificationService — contract + impl plugin" (file verbatim senior: contract 5 method + impl bọc FlutterLocalNotificationsPlugin — lazy init, tz.initializeTimeZones + FlutterTimezone + UTC fallback, resolvePlatformSpecificImplementation<T> per-platform, zonedSchedule id 1001 + DateTimeComponents.time + inexactAllowWhileIdle, _nextDailyTime rollover; FakeLocalNotificationService counters + throwOn*; +0 → 254 — chưa ai gọi).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. File service + fake là nền — chưa ai gọi là ĐÚNG (consumer BÀI 3–5).

EXPECTED STATE SAU BÀI NÀY:
- `lib/services/local_notification_service.dart` (FILE MỚI, STRICT verbatim senior): imports `flutter/foundation.dart` + `flutter_local_notifications` + `flutter_timezone` + `timezone/data/latest_all.dart` + `timezone/timezone.dart` — CẢ HAI timezone file cùng prefix `as tz` (STRICT); `abstract interface class LocalNotificationService` đúng 5 method: `initialize()`, `hasPermission()→bool`, `requestPermission()→bool`, `scheduleDaily({required hour, required minute})`, `cancelDaily()` (STRICT — thêm method như `showNow`/`scheduleExact` = DIVERGED — senior không có; không tap-handler payload).
  `LocalNotificationServiceImpl implements LocalNotificationService` STRICT:
  - static const `_dailyNotificationId = 1001`, `_channelId = 'daily_quiz_notification'`, `_channelName = 'Daily Quiz Challenge'`, `_channelDescription = 'Daily quiz reminders'`, `_notificationTitle = 'Daily Challenge Ready!'`, `_notificationBody` (STRICT verbatim — đổi = NEEDS_FIX);
  - `final FlutterLocalNotificationsPlugin _plugin` + `var _isInitialized = false` + ctor `{FlutterLocalNotificationsPlugin? plugin} : _plugin = plugin ?? FlutterLocalNotificationsPlugin()` (injectable cho test);
  - `initialize()` — `_isInitialized → return` + `tz.initializeTimeZones()` + `await _setLocalTimeZone()` + `InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings(request*Permission: false ×3), macOS: …false ×3)` (STRICT iOS/macOS KHÔNG xin quyền lúc init) + `_plugin.initialize(settings:)` + `_isInitialized = true` — lazy + idempotent: MỌI public method mở đầu `await initialize()`;
  - `hasPermission()` — `await initialize()` + `resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()` → `!= null → areNotificationsEnabled() ?? true`; null → `return true` (STRICT chỉ hỏi Android — iOS/macOS/web trả true cố ý senior; "sửa" thêm iOS check = DIVERGED);
  - `requestPermission()` — `await initialize()` + resolve Android → `requestNotificationsPermission() ?? true`; resolve iOS → `requestPermissions(alert: true, badge: true, sound: true) ?? true`; resolve macOS → `requestPermissions(…) ?? true`; hết null → `return !kIsWeb` (STRICT thứ tự Android→iOS→macOS→`!kIsWeb` fallback);
  - `scheduleDaily` — `await initialize()` + `await cancelDaily()` trước (idempotent rõ ý — STRICT) + `_plugin.zonedSchedule(id: _dailyNotificationId, title: _notificationTitle, body: _notificationBody, scheduledDate: _nextDailyTime(hour:, minute:), notificationDetails: const NotificationDetails(android: AndroidNotificationDetails(_channelId, _channelName, channelDescription: _channelDescription, importance: Importance.high, priority: Priority.high), iOS: DarwinNotificationDetails(), macOS: DarwinNotificationDetails()), androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, matchDateTimeComponents: DateTimeComponents.time, payload: 'daily_quiz')` (STRICT: `DateTimeComponents.time` = lặp hằng ngày — thiếu nó là one-shot DIVERGED; `inexactAllowWhileIdle` — exact mode = DIVERGED; id 1001 cố định);
  - `cancelDaily` — `await initialize()` + `_plugin.cancel(id: _dailyNotificationId)`;
  - `_setLocalTimeZone` — try `FlutterTimezone.getLocalTimezone()` → `tz.setLocalLocation(tz.getLocation(timeZone.identifier))`; catch → `tz.setLocalLocation(tz.UTC)` (STRICT degrade UTC không crash);
  - `_nextDailyTime({hour, minute})` — `tz.TZDateTime.now(tz.local)` + `tz.TZDateTime(tz.local, y, m, d, hour, minute)` + `!scheduled.isAfter(now) → add(Duration(days: 1))` (STRICT `!isAfter` bao gồm bằng — đúng giờ hiện tại → ngày mai; `isBefore` = DIVERGED bắn ngay).
- `test/helpers/fake_local_notification_service.dart` (FILE MỚI, STRICT): `implements LocalNotificationService` — `permissionGranted` + `requestResult` (default `?? permissionGranted`) + `initializeCount`/`requestCount`/`scheduleCount`/`cancelCount`/`lastHour`/`lastMinute` + `throwOnRequest`/`throwOnSchedule` flags; `requestPermission` — requestCount++ + throwOnRequest → throw StateError + `permissionGranted = requestResult` + return requestResult; `scheduleDaily` — throwOnSchedule → throw + counters + lastHour/Minute; `cancelDaily` — cancelCount++; `hasPermission` → permissionGranted; `initialize` → initializeCount++.
- `flutter analyze` sạch; `flutter test` → **254/254** (STRICT — chưa ai gọi: service + fake là infra; fake chưa test file nào import).
- KHÔNG ĐƯỢC có (chưa đến): `SettingsNotificationCoordinator`/`notificationService` field trong SettingsViewModel/`_toggleNotifications`/`effectiveNotificationEnabled`/`_hasNotificationPermission`/`loadSettings` Future.wait/`_loadAppVersion`/`settings_app_version_loader.dart` (BÀI 3); `Provider<LocalNotificationService>.value` trong AppDependencyScope/`main()` impl/`v$appVersion` row/`_requestNotificationPermission` onboarding (BÀI 4); `GameShareRequested`/`GameShareResult`/`GameShareResultEvent`/`shareResult`/`_DialogShareButton`/SharePlus/Clipboard/`onShareResult` (BÀI 5); iOS `hasPermission` wire (senior chỉ Android — DIVERGED); notification tap-handler/deep-link (senior không có); exact alarm mode (senior inexact); `initialize()` gọi trong `main()` (lazy-init — BÀI 4 main chỉ tạo instance).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- Bài 1: 5 pin + manifest 2-permission 2-receiver verbatim; M26 đỉnh 254 (DRE toàn bộ); `settings_view_model.dart` M16 state (nhánh notifications vẫn persist-only); onboarding scope simulated grant; `SettingsDialogScope` ctor cũ; `AppDependencyScope` chưa có notificationService.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. Service ngoài `lib/services/` hoặc import plugin trong VM/widget = DIVERGED (ranh giới vỡ).

OUTPUT (đúng format; mục trống → "None"):
LESSON: m27/02
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
