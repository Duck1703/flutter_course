## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m27/01 — "Ranh giới platform — UI không chạm plugin trực tiếp" (mental model widget→VM→contract→impl→plugin→OS; +5 dep pin senior; manifest 2 uses-permission + 2 receiver verbatim; `kIsWeb` const biên dịch; +0 code consumer → 254).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter pub deps`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này chỉ deps + manifest — chưa có file Dart nào import plugin là ĐÚNG (service BÀI 2).

EXPECTED STATE SAU BÀI NÀY:
- `pubspec.yaml` (STRICT +5 pin verbatim cuối block dependencies): `flutter_local_notifications: ^22.0.1`, `package_info_plus: ^10.1.0`, `timezone: ^0.11.0`, `flutter_timezone: ^5.1.0`, `share_plus: ^13.1.0`; `flutter pub get` resolves; `flutter pub deps` thấy cả 5 trong cây.
- `android/app/src/main/AndroidManifest.xml` (STRICT verbatim): 2 permission ngay dưới `<manifest>` — `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>` + `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>`; trong `<application>` sau `</activity>` + `<meta-data flutterEmbedding>` — `<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" android:exported="false"/>` + `<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver" android:exported="false">` với intent-filter 4 action `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, `QUICKBOOT_POWERON`, `com.htc.intent.action.QUICKBOOT_POWERON` (STRICT class name verbatim `com.dexterous.flutterlocalnotifications.*` — đổi chữ nào = OS không tìm thấy receiver).
- `lib/` KHÔNG có gì mới (STRICT): không `lib/services/local_notification_service.dart`, không import `flutter_local_notifications`/`timezone`/`flutter_timezone`/`share_plus`/`package_info_plus` ở đâu trong lib (có sớm = AHEAD BÀI 2+); không `FakeLocalNotificationService` (BÀI 2 test helper); không `SettingsNotificationCoordinator`/`notificationService` trong SettingsViewModel/`_toggleNotifications`/`effectiveNotificationEnabled`/`_loadAppVersion`/`v$appVersion` row (BÀI 3–4); không `GameShareRequested`/`GameShareResult`/`GameShareResultEvent`/`shareResult`/`onShareResult`/`_DialogShareButton`/`SharePlus`/`Clipboard` (BÀI 5); `settings_view_model.dart` nhánh notifications vẫn chỉ `_saveSettings(copyWith(notificationEnabled:))` (M16 state — BÀI 3 mới đổi); onboarding scope vẫn `onNotificationPermissionResult(true)` simulated (BÀI 4 mới đổi).
- `flutter analyze` sạch; `flutter test` → **254/254** (STRICT — không đổi: deps + manifest chưa có consumer Dart).
- Hiểu đúng (không kiểm bằng file — ghi nhận): `POST_NOTIFICATIONS` là runtime permission API 33+ (manifest chỉ cho phép xin, prompt do code chạy — BÀI 3); `RECEIVE_BOOT_COMPLETED` install-time nuôi BootReceiver đặt lại lịch sau reboot; `kIsWeb` là `const` biên dịch (nhánh chết tree-shake) khác `Platform.is*` của `dart:io` (không tồn tại trên web — import dart:io trong lib/ = DIVERGED web-unsafe).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- M26 đỉnh 254: `core/dre/` + `dre/` contract + `reducer/` 5 file + VM `extends DreChangeNotifier` + 2 bridge + GameSessionState đã xoá + 3 regression; M25 sync pipeline; M24 auth; M23 env + leaderboard; M22 VM-save; M18 onboarding overlay (simulated grant còn); M16 settings dialog + `SettingsDialogScope` ctor cũ (chưa có notificationService param); M14 repos.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. Pin sai version lớn hoặc manifest sai package receiver = NEEDS_FIX.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m27/01
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
