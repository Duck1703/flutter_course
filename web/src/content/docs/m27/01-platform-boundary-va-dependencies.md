---
title: "Bài 1 · Ranh giới platform — UI không chạm plugin trực tiếp"
description: "Felt problem: app chưa nói chuyện được với OS — switch thông báo chỉ ghi flag, onboarding giả vờ granted, không share, không version. Mental model 'UI không chạm plugin trực tiếp': widget→VM→contract→impl→plugin→OS. +5 dep đúng pin senior; manifest 2 uses-permission + 2 receiver verbatim; `kIsWeb` fallback + `resolvePlatformSpecificImplementation`. +0 test → 254."
sidebar:
  label: "Bài 1 · ranh giới platform"
  order: 1
---

## Mục tiêu

- Nêu được bài toán cảm nhận: ba chỗ trong app *giả vờ* nói chuyện
  với OS — switch thông báo chỉ persist flag, nút onboarding tự
  trả `granted`, không có nút share, không có hàng version.
- Phát biểu mental model: mọi đường ra OS đi qua một
  service contract ở biên — `widget → VM → abstract contract →
  impl bọc plugin → plugin → OS`; không ai `import` plugin ngoài
  file impl.
- Thêm 5 dependency đúng pin senior vào `pubspec.yaml` và nói
  được vai trò từng cái.
- Dán verbatim 2 `uses-permission` + 2 `receiver` vào
  `AndroidManifest.xml` — hiểu `POST_NOTIFICATIONS` là runtime
  permission (Android 13+), `RECEIVE_BOOT_COMPLETED` nuôi receiver
  đặt lại lịch sau reboot.
- Hiểu `kIsWeb` là **hằng biên dịch** — compiler xoá hẳn nhánh
 chết — khác hẳn `Platform.is*` runtime check (phần một;
  phần `resolvePlatformSpecificImplementation` xem kỹ ở Bài 2).
- +0 test → suite giữ **254/254** (deps + manifest, chưa có code
  mới nào dùng chúng).

## Bạn đang ở đâu

- Cuối M26: `flutter test` **254/254**. Game hoàn chỉnh trong
  thế giới Dart thuần — reducer thuần, effect là data, bridge
  biến effect thành `Timer`/`Future.delayed`.
- Ba "lỗ hổng platform" đang mở: (1) `SettingType.notifications`
  switch gọi `_saveSettings(copyWith(notificationEnabled: …))`
  như mọi switch khác — flag được ghi, **không ai lên lịch gì**;
  (2) onboarding scope bản cũ gọi thẳng
  `viewModel.onNotificationPermissionResult(true)` inline — giả
  vờ OS luôn đồng ý (không hỏi gì cả); (3) `GameScreenViewModel` không có `shareResult`,
  dialog kết thúc chỉ hai nút MENU | CHƠI LẠI.
- Milestone này bịa ra *lần đầu* app dùng plugin platform:
  `flutter_local_notifications`, `share_plus`, `package_info_plus`.

## Vì sao việc này quan trọng ngay bây giờ

Mở `settings_view_model.dart` nhánh `SettingType.notifications`:
cùng `_saveSettings(copyWith)` với ba switch âm thanh — khác biệt
duy nhất là tên field. Người dùng bật "Thông báo", thoát app,
đến 20:00 hôm sau… không có gì xảy ra. Flag đã persist đúng
(M14/M16), nhưng persist chỉ là ghi nhớ: **không ai đặt báo thức
với OS cả**. Tương tự nút share không tồn tại, version không có
chỗ đứng. Câu hỏi kiến trúc thật sự: *code phía OS nên sống ở
đâu?* — và senior trả lời bằng một ranh giới rõ, không phải bằng
`FlutterLocalNotificationsPlugin()` rải trong widget.

## Bạn đã biết gì

- `abstract interface class` + `implements` — contract thuần,
 không code chia sẻ (M14); `sealed`/`final class` variant
.
- DI by contract: `Provider<Contract>.value` + `context.read<T>()`
 (M12/M14); conditional DI `client == null ?
 Disabled : Impl` trong `main` (M23).
- Fake repo + counters thay thế impl thật trong test (M14);
  `test/helpers/` chứa fakes dùng chung.
- VM dialog-scoped + UI event một lần qua broadcast stream
 (M13/M16). `Future.wait` sẽ là *construct mới* ở
 Bài 3 — nền `Future`/`await` của (M05) là đủ.
- pubspec/dep pin + `flutter pub get` (M01 toolchain, đã dùng
  từ M14 `rxdart`/M23 `supabase_flutter`).

## Mental model mới — "UI không chạm plugin trực tiếp" (CORE)

```text
  Widget            ViewModel          Contract              Impl            Plugin        OS
  (dialog/switch)   (settings VM)      (abstract iface)      (services/)     (pub.dev)     (Android/iOS)
       │                 │                  │                  │                │            │
  "user bật          "enable() qua      LocalNotification   LocalNotif-    flutter_local_   AlarmManager/
   thông báo"    →    coordinator"  →   Service {           ServiceImpl →  notifications → Notification-
                      │                scheduleDaily(h,m) }  cầm plugin    zonedSchedule    Service
                      ▼                                       │
              SettingsNotificationCoordinator ────────────────┘
              (thứ tự: schedule → save → rollback-on-fail)
```

Ba quy tắc:

1. **Contract sống trong `lib/services/`** — `abstract interface
   class LocalNotificationService` khai báo *việc gì*
   (`initialize`/`hasPermission`/`requestPermission`/`scheduleDaily`
   /`cancelDaily`), không biết plugin nào.
2. **Impl duy nhất import plugin** — `LocalNotificationServiceImpl`
   bọc `FlutterLocalNotificationsPlugin`. Nếu ngày mai đổi plugin,
   chỉ file này viết lại; mọi call-site đứng yên.
3. **Test cấp impl thứ ba** — `FakeLocalNotificationService`
   `implements` cùng contract, đếm `scheduleCount`/`cancelCount`/
   `requestCount` + ghi `lastHour`/`lastMinute` + `throwOn*` flags.
   OS thật không bao giờ tham gia test — verification là
   deterministic counters, không phải "bắt" notification thật.

Giới hạn của model: contract chỉ chống *tight-coupling code*, nó
không làm plugin chạy trong unit test được — nó cho phép *thay
thế* plugin. Và ranh giới có giá: một lớp file `services/` dư ra
— senior chấp nhận vì đổi lại mọi call-site + test không cần biết
plugin tồn tại.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
| --- | --- |
| `kIsWeb` (`package:flutter/foundation.dart`) | **hằng `const` biên dịch** — compiler thế giá trị *trước khi* build (trong `if (kIsWeb)` nhánh chết bị xoá hẳn). Trong service này nó xuất hiện dạng **giá trị**: `return !kIsWeb` = "không platform impl nào resolve được → granted, *trừ* web → denied" (mới). Khác `Platform.isAndroid` của `dart:io`: runtime check, và `dart:io` không tồn tại trên web |
| `?` nullable + `!= null` gate | `resolvePlatformSpecificImplementation<T>()` trả `null` trên platform không khớp generic — mẫu "hỏi plugin có impl Android không" (chi tiết Bài 2) |
| `Future<bool>` trả `?? true` | plugin trả `null` (platform cũ không cần quyền) → mặc định granted |
| `import '…/foo.dart' as tz` | prefix import cho `timezone` — hai file `data/latest_all.dart` + `timezone.dart` cùng prefix `tz` (Bài 2) |

## Flutter cần dùng

| API | Vai trò |
| --- | --- |
| `pubspec.yaml` + `flutter pub get` | năm pin mới — đúng version senior |
| `AndroidManifest.xml` `<uses-permission>` | khai báo ý định với OS — POST_NOTIFICATIONS chỉ *cho phép app xin*; prompt thật do code chạy (Bài 2–3) |
| `AndroidManifest.xml` `<receiver>` | receiver của plugin — không phải code mình viết; manifest chỉ *đăng ký* class của `flutter_local_notifications` |

## Ví dụ độc lập — contract ở biên, impl đổi chỗ (DartPad)

```dart
// Ranh giới platform ở quy mô tối thiểu — KHÔNG đụng app.
abstract interface class ReminderService {
  Future<bool> requestPermission();
  Future<void> schedule({required int hour});
  Future<void> cancel();
}

class FakeReminderService implements ReminderService {
  var scheduleCount = 0;
  var cancelCount = 0;
  var lastHour = -1;
  bool requestResult;

  FakeReminderService({this.requestResult = false});

  @override
  Future<bool> requestPermission() async => requestResult;

  @override
  Future<void> schedule({required int hour}) async {
    scheduleCount++;
    lastHour = hour;
  }

  @override
  Future<void> cancel() async {
    cancelCount++;
  }
}

// "VM" — chỉ biết contract, không biết impl nào đang chạy.
Future<void> enableReminder(ReminderService service) async {
  if (!await service.requestPermission()) return;
  await service.schedule(hour: 20);
}

void main() async {
  final fake = FakeReminderService(requestResult: true);
  await enableReminder(fake);          // call-site đứng yên…
  print('scheduled=${fake.scheduleCount} at ${fake.lastHour}:00');
  // scheduled=1 at 20:00 — fake chứng minh được hành vi
  // mà không cần OS thật.
}
```

Đây chính là shape của `FakeLocalNotificationService` (Bài 2) —
counters + `requestResult`, call-site chỉ nhìn contract.

## Android / Compose bridge

**SIMILARITY — `AndroidManifest.xml` là của Android thuần.** `<uses-
permission>`/`<receiver>` bạn đã biết — Flutter app *là* Android app
khi chạy trên Android; manifest nằm ngoài thế giới Dart, plugin
cung cấp class receiver, manifest chỉ đăng ký.

**IMPORTANT DIFFERENCE — `POST_NOTIFICATIONS` (API 33+) là runtime
permission.** Manifest *khai báo ý định*; `requestNotifications-
Permission()` trong impl (Bài 2) mới hiện prompt — tương đương
`ActivityCompat.requestPermissions`, nhưng gọi từ Dart qua channel.

**DO NOT ASSUME — `kIsWeb` ≠ `Platform.isWeb` và ≠ "xoá code
plugin".** `Platform` sống trong `dart:io` — import nó trên web là
lỗi biên dịch. `kIsWeb` là `const` biên dịch: dùng trong `if` thì
nhánh chết bị tree-shake, nhưng trong service này nó chỉ là *giá
trị fallback* (`return !kIsWeb`). Web build xanh là nhờ
`flutter_local_notifications` có **web impl federated** sẵn —
`initialize()` trên web chạy được (trả `false` khi trình duyệt
thiếu Notification API), còn `zonedSchedule` trên web throw
`UnsupportedError` → coordinator bắt → snackbar. Không có
`MissingPluginException` nào cả.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
| --- | --- |
| `pubspec.yaml` — 5 pin `flutter_local_notifications`/`package_info_plus`/`timezone`/`flutter_timezone`/`share_plus` | learner pin y hệt version |
| `lib/services/local_notification_service.dart` | contract + impl — ranh giới nguyên mẫu (Bài 2 port verbatim) |
| `lib/core/app_dependency_scope.dart` — `Provider<LocalNotificationService>.value` | service đăng ký theo *kiểu contract* như mọi repo (Bài 4) |
| `android/app/src/main/AndroidManifest.xml` dòng 2–3 + receiver `ScheduledNotification(Boot)Receiver` | manifest copy verbatim — hai permission + hai receiver |

## Build it step by step

**Bước 1 — `pubspec.yaml`** (thêm vào cuối block `dependencies:`,
verbatim senior pins):

```yaml
  # M27: năm pin đúng senior — notification plugin + timezone pair,
  # package_info cho version row, share_plus cho result share.
  flutter_local_notifications: ^22.0.1
  package_info_plus: ^10.1.0
  timezone: ^0.11.0
  flutter_timezone: ^5.1.0
  share_plus: ^13.1.0
```

rồi `flutter pub get`.

Vai trò từng dep:

| Dep | Việc |
| --- | --- |
| `flutter_local_notifications` | plugin lên/huỷ lịch notification, permission per-platform |
| `timezone` | database múi giờ + `TZDateTime`/`setLocalLocation` (bắt buộc cho `zonedSchedule`) |
| `flutter_timezone` | đọc múi giờ thật của thiết bị (`getLocalTimezone`) |
| `package_info_plus` | đọc `version` từ pubspec lúc runtime (hàng `v…` trong settings) |
| `share_plus` | native share sheet + `ShareParams`/`sharePositionOrigin` |

**Bước 2 — `android/app/src/main/AndroidManifest.xml`** (verbatim
senior; hai permission ngay dưới `<manifest>`, hai receiver trong
`<application>` sau `</activity>` + `<meta-data flutterEmbedding>`):

```xml
    <!-- M27 — verbatim senior: quyền nhận boot để receiver đặt lại
         lịch, và quyền POST_NOTIFICATIONS (Android 13+) để
         `requestNotificationsPermission()` có thể prompt. -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

```xml
        <!-- M27 — verbatim senior: hai receiver của
             flutter_local_notifications. Receiver đầu nhận alarm đã
             hẹn; receiver boot đặt lại lịch sau khi máy khởi động
             (BOOT_COMPLETED/MY_PACKAGE_REPLACED/QUICKBOOT). -->
        <receiver
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
            android:exported="false" />
        <receiver
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
```

- `POST_NOTIFICATIONS`: từ Android 13 (API 33) notification là
  **runtime permission** — manifest chỉ mở khả năng xin;
  `requestNotificationsPermission()` (Bài 2) mới hiện dialog. Máy
  cũ (<33) bỏ qua — không hại.
- `ScheduledNotificationReceiver` nhận sự kiện "đến giờ" khi app
  đang tắt — alarm do plugin cài, receiver này là mắt xích OS→app.
- `ScheduledNotificationBootReceiver`: notification đã lên lịch
  **không sống sót reboot** — receiver này nghe BOOT_COMPLETED để
  plugin đặt lại. `MY_PACKAGE_REPLACED`/`QUICKBOOT_POWERON` là
  hai biến thể cùng vai (update app / firmware quickboot của HTC).

**Bước 3 — `flutter analyze` + `flutter test`** → 254/254 giữ
nguyên: chưa file Dart nào import plugin — bước này chỉ đặt nền.

## Hiểu code — ba chi tiết dễ trượt

1. **Receiver không phải code mình viết.** Hai `<receiver>` trỏ tới
   class *của plugin* (`com.dexterous.flutterlocalnotifications…`)
   — manifest đăng ký chúng với OS; nếu quên dòng này, alarm vẫn
   hẹn được nhưng notification **không sống sót reboot** và trên
   Android 13+ `requestNotificationsPermission` không prompt được
   vì thiếu khai báo ý định.
2. **`uses-permission` ≠ quyền đã có.** `POST_NOTIFICATIONS` chỉ
   *cho phép xin* — app vẫn phải `requestPermission()` lúc chạy
   (Bài 3). Ngược lại `RECEIVE_BOOT_COMPLETED` là install-time:
   khai báo là có, không cần hỏi.
3. **`kIsWeb` là hằng, không phải hàm.** `const kIsWeb` được
   compiler thế bằng `true`/`false` *trước khi* build — trong
 `if (kIsWeb) …` nhánh chết bị xoá hẳn. Nhưng đừng nhầm:
   `flutter_local_notifications` đi kèm **web impl federated** —
   `initialize()`/`cancel()` trên web chạy được (initialize trả
   `false` khi trình duyệt thiếu Notification API — không throw),
   còn `zonedSchedule` trên web throw `UnsupportedError` → nhảy
   lên `catch` của VM → snackbar `updateFailed`. Trong file này
   `kIsWeb` chỉ xuất hiện trong `return !kIsWeb` — *giá trị*
   fallback "không ai hỏi được quyền → granted, trừ web → denied"
   (đường onboarding gọi `requestPermission` thẳng — Bài 4).

## Chạy và quan sát

```text
flutter pub get  → resolves 5 pin mới
flutter analyze  → No issues found!
flutter test     → +254: All tests passed!   (không đổi — chưa ai dùng)
```

Kiểm chứng nhanh dep đã vào: `flutter pub deps | grep
flutter_local_notifications` (PowerShell: `| findstr …`) thấy
package trong cây dep.

## Thử nghiệm

Xoá `POST_NOTIFICATIONS` khỏi manifest, `flutter pub get` +
`flutter test` — đoán suite có đỏ không? Sau đó suy ra *đường nào*
sẽ hỏng trên thiết bị thật.

<details>
<summary>Đáp án</summary>

Suite **không đỏ** — không test nào chạy plugin thật (fakes gánh
verification). Hỏng ở runtime: `requestNotificationsPermission()`
trên Android 13+ không hiện prompt (thiếu khai báo ý định) → OS
coi như từ chối → switch về tắt + snackbar — lỗi chỉ thấy trên
thiết bị thật, đó là lý do `REAL_DEVICE_PLATFORM_CHECK` của
milestone là `NOT_PERFORMED` được ghi thành warning riêng (Bài 6).
</details>

## Lỗi hay gặp

1. **Cho rằng khai manifest = có quyền** — `POST_NOTIFICATIONS` chỉ
   là điều kiện để được xin; OS vẫn hỏi user lúc chạy.
2. **Dùng `Platform.isAndroid` trên code chạy web** — `dart:io`
   không tồn tại trên web → lỗi biên dịch; `kIsWeb`/`defaultTarget-
 Platform` (foundation) mới là API đúng tầng.
3. **Đặt receiver sai package** — class name của receiver phải
   verbatim `com.dexterous.flutterlocalnotifications.*`; đổi chữ
   nào là OS không tìm thấy class → notification mất sau reboot.
4. **Nghĩ permission là một lần vĩnh viễn** — user có thể thu hồi
   trong Settings của OS bất cứ lúc nào; app phải query lại mỗi
   lần mở settings (Bài 3 — `hasPermission` trong `Future.wait`).

## Tự làm — PRODUCE

Trên DartPad, thêm một impl thứ hai cho `ReminderService` của ví
dụ độc lập: `LoggingReminderService` — *decorator* bọc một
`ReminderService` khác, đếm tổng số lần gọi vào `callCount` rồi
forward cho delegate. Sau đó chạy
`enableReminder(LoggingReminderService(fake))` và in
`guard.callCount` + `fake.scheduleCount` — đoán trước rồi verify.

:::note[Gợi ý]
Decorator là `implements` + field `final ReminderService inner;`
— mỗi method `inner.x(…)` sau khi `callCount++`. Constructor
`LoggingReminderService(this.inner)`.
:::

<details>
<summary><strong>Đáp án</strong></summary>

```dart
class LoggingReminderService implements ReminderService {
  final ReminderService inner;
  var callCount = 0;

  LoggingReminderService(this.inner);

  @override
  Future<bool> requestPermission() {
    callCount++;
    return inner.requestPermission();
  }

  @override
  Future<void> schedule({required int hour}) {
    callCount++;
    return inner.schedule(hour: hour);
  }

  @override
  Future<void> cancel() {
    callCount++;
    return inner.cancel();
  }
}

// main: guard.callCount == 2 (request + schedule),
//       fake.scheduleCount == 1 — đổi impl không sửa call-site.
```

Đây đúng kỹ thuật `FakeLocalNotificationService` áp vào contract
thật: impl bất kỳ thoả contract thay thế được — call-site đứng yên.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao `context.read<LocalNotificationService>()` (Bài
  4) trả được impl plugin? — **Đáp:** đăng ký theo kiểu *contract*
  `Provider<LocalNotificationService>.value` — widget hỏi interface,
 scope trả bất kỳ impl nào đã đặt (reuse).
- **Hỏi:** `kIsWeb` khác `Platform.isAndroid` ở hai điểm nào? —
  **Đáp:** (1) `kIsWeb` là `const` biên dịch → nhánh chết bị xoá
  (tree-shake); (2) `Platform` thuộc `dart:io` — không tồn tại
  trên web, còn `kIsWeb` an toàn mọi platform.
- **Hỏi:** `ScheduledNotificationBootReceiver` giải quyết vấn đề
  gì? — **Đáp:** alarm notification không sống sót reboot/update —
  receiver nghe BOOT_COMPLETED/MY_PACKAGE_REPLACED để plugin đặt
  lịch lại.
- **Hỏi:** vì sao test dùng fake counters thay vì mở notification
  thật? — **Đáp:** unit/widget test không có OS; deterministic
  counters (`scheduleCount`, `lastHour`) assert được ý định đúng
 mà không cần thiết bị (áp cho service).

## Ta cố ý chưa thêm

- `LocalNotificationService` contract + impl — **Bài 2** (deps
  chưa có consumer — cố ý).
- `SettingsNotificationCoordinator` + permission flow —
  **Bài 3**.
- DI `Provider<LocalNotificationService>.value` + `main()` impl +
  onboarding request thật + `v$appVersion` — **Bài 4**.
- Share chain `GameShareRequested`→`SharePlus`/`Clipboard` —
  **Bài 5**.
- `POST_NOTIFICATIONS` runtime-prompt trên iOS/macOS +
  `resolvePlatformSpecificImplementation` — **Bài 2** (impl).
- Xử lý tap vào notification (payload deep-link) — senior cũng
  không có handler; không thêm.
- Exact-alarm mode / nhiều channel — roadmap loại trừ; senior
  `inexactAllowWhileIdle` một channel duy nhất.

## Checkpoint hoàn thành

- [ ] `pubspec.yaml` có đủ 5 pin mới; `flutter pub get` xanh.
- [ ] `AndroidManifest.xml` có 2 `uses-permission` + 2 receiver
  verbatim senior (đúng class name, `exported="false"`).
- [ ] Kể được chuỗi `widget→VM→contract→impl→plugin→OS` và vì sao
  widget không import plugin.
- [ ] `flutter analyze` sạch; `flutter test` **254/254** (deps +
  manifest land, chưa code mới nào dùng — scaffold nền).

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
