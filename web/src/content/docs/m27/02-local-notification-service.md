---
title: "Bài 2 · LocalNotificationService — contract + impl plugin"
description: "File verbatim senior: contract 5 method (`initialize`/`hasPermission`/`requestPermission`/`scheduleDaily`/`cancelDaily`) + impl bọc `FlutterLocalNotificationsPlugin` — lazy init, `tz.initializeTimeZones` + `FlutterTimezone` + UTC fallback, `resolvePlatformSpecificImplementation<T>` per-platform permission, `zonedSchedule` id 1001 + `DateTimeComponents.time` + `inexactAllowWhileIdle`, `_nextDailyTime` rollover +1 ngày. Fake counters + `throwOn*` cho test. +0 → 254."
sidebar:
  label: "Bài 2 · notification service"
  order: 2
---

## Mục tiêu

- Viết `lib/services/local_notification_service.dart` **verbatim
  senior**: `abstract interface class LocalNotificationService` 5
  method + `LocalNotificationServiceImpl` bọc plugin.
- Giải thích được vì sao `initialize()` chạy lazy ở đầu mọi public
  method, và vì sao `_setLocalTimeZone` nuốt lỗi thành UTC.
- Hiểu `resolvePlatformSpecificImplementation<T>()` — "hỏi plugin
  xem platform hiện tại có impl T không" — trả `null` khi không
 khớp (nửa hai).
- Đọc được chữ ký `zonedSchedule`: một notification id cố định
  (`1001`), `matchDateTimeComponents: DateTimeComponents.time` =
  lặp hằng ngày cùng giờ đồng hồ, `inexactAllowWhileIdle` =
 thân pin.
- Viết `FakeLocalNotificationService` (counters + `throwOn*`) vào
  `test/helpers/` — đối tượng thay OS trong mọi test sau này.
- +0 test (service + fake là nền — chưa ai gọi) → **254/254**.

## Bạn đang ở đâu

- Cuối Bài 1: 5 dep + manifest đã land, `flutter test` vẫn
  254/254 — chưa file Dart nào import plugin.
- Bài này tạo *chủ nhân duy nhất* của plugin: file `services/`
  duy nhất được `import 'package:flutter_local_notifications/…'`.

## Vì sao việc này quan trọng ngay bây giờ

Plugin `flutter_local_notifications` có API rộng — init settings
per-platform, permission API khác nhau giữa Android/iOS/macOS,
`zonedSchedule` cần `TZDateTime` của múi giờ thiết bị. Nếu rải
mấy dòng này vào VM/widget: (1) ai đọc VM cũng phải hiểu plugin;
(2) test VM phải chạy plugin thật (không thể — không có OS);
(3) đổi plugin = sửa khắp app. Ranh giới cô lập hết vào một
file — file này là *bộ phiên dịch* duy nhất giữa "ngôn ngữ app"
(`scheduleDaily(hour: h, minute: m)`) và "ngôn ngữ plugin"
(`zonedSchedule(id: 1001, scheduledDate: TZDateTime…)`).

## Bạn đã biết gì

- Contract `abstract interface class` + impl `implements` (
  Bài 1); fake counters (Bài 1 ví dụ độc lập).
- `kIsWeb` là hằng biên dịch (Bài 1).
- `static const` cho hằng nội bộ class + named-required
 parameter; null-coalescing `??`/`??=`.
- `Future<void>` + `await` chain; `try/catch` nuốt lỗi có
  chủ đích (đã thấy ở M22 save boundary).

## Mental model mới — "một file = một bộ phiên dịch platform"

`LocalNotificationServiceImpl` không chỉ "gọi plugin" — nó *phiên
dịch* ba thứ app không muốn biết:

1. **Phiên dịch thời gian**: app nói "8 giờ tối mỗi ngày" → impl
   phải tính `TZDateTime` kế tiếp trong *múi giờ thiết bị*
   (`tz.local`), rollover sang ngày mai khi giờ đó đã qua.
2. **Phiên dịch permission**: app chỉ hỏi `hasPermission()`/
   `requestPermission()` trả `bool` — impl lo việc Android dùng
   `areNotificationsEnabled`/`requestNotificationsPermission` còn
   iOS/macOS dùng `requestPermissions(alert:badge:sound:)`.
3. **Phiên dịch platform-null**: trên platform không có impl tương
   ứng, `resolve…` trả `null` → impl quyết định mặc định
   (`hasPermission` → `true`; `requestPermission` → `!kIsWeb`).

Giới hạn: impl vẫn *tin* plugin — nếu `zonedSchedule` throw (web
→ `UnsupportedError`), lỗi lan lên caller (coordinator/VM — Bài
3). Contract không biến lỗi platform thành an toàn; nó chỉ quyết
định *ai* phải lo lỗi đó.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `import '…' as tz` + **hai** file cùng prefix | `data/latest_all.dart` (database múi giờ) + `timezone.dart` (API) cùng alias `tz` — `tz.initializeTimeZones()`, `tz.TZDateTime`, `tz.local`, `tz.setLocalLocation` |
| `FlutterTimezone.getLocalTimezone()` | đọc múi giờ thật của OS → `timeZone.identifier` → `tz.getLocation` |
| `tz.TZDateTime(tz.local, y, m, d, h, min)` | thời điểm *có múi giờ* — `zonedSchedule` đòi kiểu này, không nhận `DateTime` |
| `resolvePlatformSpecificImplementation<T>()` | method của plugin: trả instance kiểu `T` nếu platform hiện tại khớp, `null` nếu không — gate per-platform |
| `_isInitialized` flag + early-return | lazy-init idempotent — mọi public method `await initialize()` đầu tiên, init chỉ chạy một lần |
| `scheduled.isAfter(now)` + `add(Duration(days:1))` | rollover: giờ đã qua (hoặc đúng bằng) → sang ngày mai |

## Flutter cần dùng

| API | Vai trò |
|---|---|
| `FlutterLocalNotificationsPlugin` | instance plugin — ctor injectable (`{plugin}` param) để test/mock được |
| `InitializationSettings(android:…, iOS:…, macOS:…)` | per-platform init; `DarwinInitializationSettings(request*Permission: false)` = *không* xin quyền lúc init — xin sau bằng `requestPermission()` |
| `AndroidInitializationSettings('@mipmap/ic_launcher')` | icon mặc định của notification Android |
| `AndroidNotificationDetails(channelId, channelName, channelDescription:, importance:, priority:)` | channel Android 8+ — tạo một lần vĩnh viễn theo `channelId`; `Importance.high` → heads-up |
| `zonedSchedule(id:, title:, body:, scheduledDate:, notificationDetails:, androidScheduleMode:, matchDateTimeComponents:, payload:)` | đặt lịch — `matchDateTimeComponents: DateTimeComponents.time` biến nó thành **lặp hằng ngày theo giờ đồng hồ** |
| `AndroidScheduleMode.inexactAllowWhileIdle` | OS được dời giờ để tiết kiệm pin, vẫn gửi khi máy ngủ (doze) — senior chọn thân pin, không cần giờ chính xác |
| `payload` | chuỗi data đi kèm notification (`'daily_quiz'`) — senior không có tap-handler; chỉ là metadata |

## Ví dụ độc lập — rollover `_nextDailyTime` (DartPad)

Logic rollover là Dart thuần — port sang `DateTime` để chạy thử
trước khi đụng plugin:

```dart
DateTime nextDailyTime(DateTime now, int hour, int minute) {
  var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
  if (!scheduled.isAfter(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

void main() {
  final now = DateTime(2025, 6, 1, 14, 30); // 14:30 ngày 1/6
  print(nextDailyTime(now, 20, 0));  // giờ tới còn ở tương lai
  print(nextDailyTime(now, 9, 0));   // giờ tới đã qua → ngày mai
  print(nextDailyTime(now, 14, 30)); // đúng-bằng → ngày mai!
}
```

Ba case cuối chính là bài tập dự đoán ở cuối bài — chú ý case
"đúng bằng": `!isAfter` bao gồm cả bằng → đặt đúng giờ hiện tại
vẫn nhảy sang ngày mai (senior chấp nhận — không có "bắn ngay").

## Android / Compose bridge

**SIMILARITY — `NotificationDetails` ≈ `NotificationCompat.Builder`
+ channel.** `AndroidNotificationDetails(channelId, channelName, …,
importance:)` là `NotificationChannel` + builder config bạn đã biết
(API 26+ channel là bắt buộc). `Importance.high` ≈
`NotificationManager.IMPORTANCE_HIGH` → heads-up.

**IMPORTANT DIFFERENCE — `inexactAllowWhileIdle` ≠ `setExact…`.**
Đây là `setAndAllowWhileIdle` tương đương — *không chính xác*: OS
được dời để gom batch tiết kiệm pin, không cần `SCHEDULE_EXACT_
ALARM`. Senior chọn inexact vì "nhắc chơi quiz" không phải báo
thức — đừng thêm exact mode (roadmap loại trừ).

**DO NOT ASSUME — `zonedSchedule` + `matchDateTimeComponents:
time` KHÔNG phải one-shot.** Nó tương đương `setRepeating` theo
giờ đồng hồ — mỗi ngày cùng `hour:minute` OS bắn lại, không cần
re-schedule sau mỗi lần hiện. Huỷ là `cancel(id: 1001)` một id
duy nhất.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/services/local_notification_service.dart` | file này port **verbatim** — cùng contract, cùng constants, cùng `_nextDailyTime` |
| `test/helpers/fake_local_notification_service.dart` | fake counters cùng shape — `scheduleCount`/`cancelCount`/`requestCount`/`lastHour`/`lastMinute`/`throwOn*` |

## Build it step by step

**Bước 1 — `lib/services/local_notification_service.dart`** (file
mới — verbatim senior; comment header ghi rõ ranh giới).

Phần contract — năm method là toàn bộ "ngôn ngữ" app được phép
nói về notification:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract interface class LocalNotificationService {
  Future<void> initialize();

  Future<bool> hasPermission();

  Future<bool> requestPermission();

  Future<void> scheduleDaily({required int hour, required int minute});

  Future<void> cancelDaily();
}
```

Phần impl — constants (id/channel/text cố định của senior):

```dart
class LocalNotificationServiceImpl implements LocalNotificationService {
  static const _dailyNotificationId = 1001;
  static const _channelId = 'daily_quiz_notification';
  static const _channelName = 'Daily Quiz Challenge';
  static const _channelDescription = 'Daily quiz reminders';
  static const _notificationTitle = 'Daily Challenge Ready!';
  static const _notificationBody =
      'Your daily quiz is waiting. Can you top the leaderboard today?';

  final FlutterLocalNotificationsPlugin _plugin;
  var _isInitialized = false;

  LocalNotificationServiceImpl({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
```

Init lazy + timezone (verbatim):

```dart
  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    tz.initializeTimeZones();
    await _setLocalTimeZone();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings: initializationSettings);
    _isInitialized = true;
  }
```

Permission — `hasPermission` chỉ hỏi Android (senior không wire
check cho iOS/macOS — coi như "granted cho tới khi request");
`requestPermission` resolve lần lượt Android → iOS → macOS, hết
impl nào khớp thì fallback `!kIsWeb`:

```dart
  @override
  Future<bool> hasPermission() async {
    await initialize();

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? true;
    }

    return true;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      return await androidImplementation.requestNotificationsPermission() ??
          true;
    }

    final iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImplementation != null) {
      return await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }

    final macOsImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (macOsImplementation != null) {
      return await macOsImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }

    return !kIsWeb;
  }
```

Schedule/cancel + hai helper (verbatim):

```dart
  @override
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    await initialize();
    await cancelDaily();

    await _plugin.zonedSchedule(
      id: _dailyNotificationId,
      title: _notificationTitle,
      body: _notificationBody,
      scheduledDate: _nextDailyTime(hour: hour, minute: minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_quiz',
    );
  }

  @override
  Future<void> cancelDaily() async {
    await initialize();
    await _plugin.cancel(id: _dailyNotificationId);
  }

  Future<void> _setLocalTimeZone() async {
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  tz.TZDateTime _nextDailyTime({required int hour, required int minute}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
```

**Bước 2 — `test/helpers/fake_local_notification_service.dart`**
(file mới — verbatim senior shape; đây là "OS giả" cho mọi test
Bài 3):

```dart
import 'package:ai_millionaire_course/services/local_notification_service.dart';

class FakeLocalNotificationService implements LocalNotificationService {
  bool permissionGranted;
  bool requestResult;
  int initializeCount = 0;
  int requestCount = 0;
  int scheduleCount = 0;
  int cancelCount = 0;
  int? lastHour;
  int? lastMinute;
  bool throwOnRequest = false;
  bool throwOnSchedule = false;

  FakeLocalNotificationService({
    this.permissionGranted = false,
    bool? requestResult,
  }) : requestResult = requestResult ?? permissionGranted;

  @override
  Future<void> initialize() async {
    initializeCount++;
  }

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<bool> requestPermission() async {
    requestCount++;
    if (throwOnRequest) {
      throw StateError('request failed');
    }

    permissionGranted = requestResult;
    return requestResult;
  }

  @override
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    if (throwOnSchedule) {
      throw StateError('schedule failed');
    }

    scheduleCount++;
    lastHour = hour;
    lastMinute = minute;
  }

  @override
  Future<void> cancelDaily() async {
    cancelCount++;
  }
}
```

**Bước 3 — `flutter analyze` + `flutter test`** → 254/254: fake
chưa được file test nào import, service chưa được ai gọi — hai
file này là nền cho Bài 3.

## Hiểu code — sáu chi tiết dễ trượt

1. **`initialize()` lazy + idempotent.** Mọi public method mở đầu
   bằng `await initialize()`; `_isInitialized` flag chặn chạy lại.
   Không cần `main()` gọi init — ai dùng đầu tiên trả giá init.
2. **`tz.initializeTimeZones()` tải database trước khi dùng
   `tz.local`/`TZDateTime`** — quên nó là crash "Timezone database
   not initialized". `FlutterTimezone.getLocalTimezone()` đọc múi
   giờ OS; lỗi (web/máy lạ) → `catch` → `tz.UTC` — **degrade sang
   UTC chứ không crash**: notification vẫn hẹn được, chỉ lệch múi.
3. **`scheduleDaily` gọi `cancelDaily()` trước** — cùng id `1001`
   nên schedule mới = ghi đè; huỷ trước làm idempotent rõ ràng
   (đổi giờ không tạo notification thứ hai).
4. **`resolvePlatformSpecificImplementation<T>` là gate type.**
   Plugin trả instance kiểu `T` nếu platform hiện tại khớp —
   Android trả `AndroidFlutterLocalNotificationsPlugin`, web trả
   `null` cho cả ba generic → `requestPermission` rơi vào
   `return !kIsWeb` → `false` (Bài 1 đã phân tích: web có impl
   federated riêng nhưng không khớp ba kiểu Android/iOS/macOS).
5. **`hasPermission` chỉ hỏi Android.** Trên iOS/macOS *và web*
   method trả `true` (không impl nào resolve → `return true`) —
   senior chỉ wire `areNotificationsEnabled` của Android; iOS tin
   đường `requestPermission` lúc enable. Giới hạn có ý: không phải
   bug của ta, là chính sách senior — ghi nhận, đừng "sửa".
6. **`matchDateTimeComponents: DateTimeComponents.time` = lặp.**
   Không có nó, `zonedSchedule` là one-shot. Với nó, OS tự bắn
   lại mỗi ngày cùng `hour:minute` theo đồng hồ — app chỉ cần
   schedule một lần (và re-schedule khi user đổi giờ — Bài 3).

## Chạy và quan sát

```text
flutter analyze  → No issues found!  (hai file mới compile sạch)
flutter test     → +254: All tests passed!  (chưa ai dùng — infra)
```

Trên thiết bị thật bạn *chưa* verify được — service chưa có ai
gọi (`REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` của milestone
đứng nguyên tới Bài 6).

## Thử nghiệm

Trong `scheduleDaily`, bỏ dòng `await cancelDaily()` rồi suy nghĩ:
user đổi giờ từ 20:00 → 8:00 hai lần liên tiếp, có bao nhiêu
notification sẽ hiện mỗi ngày?

<details>
<summary>Đáp án</summary>

Vẫn **một** — `zonedSchedule(id: 1001, …)` cùng id ghi đè lịch cũ,
không nhân đôi. `cancelDaily()` trước không chống nhân đôi (id cố
định đã chống) — nó làm **ý đồ rõ ràng + phòng plugin nào đó trên
platform nào đó treat same-id là "đã tồn tại" và bỏ qua**. Senior
viết defensive; cố ý giữ verbatim thay vì "tối ưu" bỏ.
</details>

## Lỗi hay gặp

1. **Quên `tz.initializeTimeZones()`** → `TZDateTime`/`tz.local`
   crash "timezone database not initialized" — init trước mọi dùng.
2. **Tưởng `zonedSchedule` là one-shot** → viết code re-schedule
   sau mỗi lần hiện — thừa; `DateTimeComponents.time` đã là lặp.
3. **Dùng `DateTime.now()`/`DateTime` trần cho `scheduledDate`** —
   `zonedSchedule` đòi `tz.TZDateTime`; `DateTime` không có múi
   giờ → sai giờ theo timezone thiết bị.
4. **Nghĩ `requestPermission` hỏi OS mọi platform** — trên web nó
   trả `false` ngay (`!kIsWeb`); trên platform không resolve được
   impl nào (Linux/Windows) trả `true`.
5. **Sửa constants cho "đẹp"** — id `1001`/channel id/payload
   `'daily_quiz'` là verbatim senior; đổi channel id sau khi ship
   thực tế là tạo channel mới (channel cũ vẫn tồn trong Settings
   của máy).

## Tự làm — PREDICT

Chạy ví dụ độc lập trên DartPad và trả lời: `now` = 14:30 ngày
1/6 — `nextDailyTime(now, 20, 0)`, `(now, 9, 0)`, `(now, 14, 30)`
trả gì? Sau đó: senior dùng `!isAfter` (bao gồm bằng) — nếu đổi
thành `isBefore` (chỉ khi nhỏ hơn) thì case 14:30 khác gì?

<details>
<summary><strong>Đáp án</strong></summary>

- `nextDailyTime(now, 20, 0)` → **20:00 ngày 1/6** (tương lai,
  giữ nguyên).
- `nextDailyTime(now, 9, 0)` → **09:00 ngày 2/6** (đã qua → +1
  ngày).
- `nextDailyTime(now, 14, 30)` → **14:30 ngày 2/6** — `!isAfter`
  gồm cả bằng → đúng giờ hiện tại cũng cuộn sang mai.

Đổi sang `isBefore(now)`: case bằng → `scheduled.isBefore(now)` =
false → **giữ 14:30 hôm nay** → notification bắn *ngay lập tức*
(giờ hiện tại). Senior chọn `!isAfter` có chủ đích: đặt đúng giờ
hiện tại = "ngày mai lúc đó", không phải "bắn ngay".
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao `scheduleDaily` `await cancelDaily()` trước? —
  **Đáp:** id `1001` cố định → huỷ trước đảm bảo re-schedule là
  ghi đè sạch, đổi giờ không tích luỹ notification.
- **Hỏi:** trên web `requestPermission()` trả gì, vì sao? —
  **Đáp:** `false` — ba `resolvePlatformSpecificImplementation`
  đều `null` → rơi vào `return !kIsWeb`.
- **Hỏi:** `DateTimeComponents.time` đổi `zonedSchedule` thành gì?
  — **Đáp:** lặp hằng ngày theo giờ đồng hồ thay vì one-shot —
  app schedule một lần, OS tự bắn lại.
- **Hỏi:** `_setLocalTimeZone` lỗi thì sao? — **Đáp:** `catch` →
  `tz.setLocalLocation(tz.UTC)` — notification vẫn hẹn được theo
  UTC (lệch giờ hiển thị mong đợi nhưng không crash).
- **Hỏi:** fake không `initialize` timezone được gì mà test vẫn
  ổn? — **Đáp:** fake `implements` contract — nó thay *toàn bộ*
  impl kể cả timezone/plugin; test verify `scheduleCount`/
  `lastHour` thay vì thời gian thật.

## Ta cố ý chưa thêm

- Ai gọi service — **Bài 3** (`SettingsNotificationCoordinator` +
  VM) và **Bài 4** (DI + onboarding).
- Tap-handler cho `payload: 'daily_quiz'` — senior không có;
  không thêm deep-link.
- Exact alarm, thêm channel, custom actions, hiện notification
  khi app foreground — roadmap loại trừ.
- `hasPermission` cho iOS/macOS (senior chỉ wire Android) — ghi
  nhận là chính sách senior, không "vá".

## Checkpoint hoàn thành

- [ ] `lib/services/local_notification_service.dart` verbatim
  senior: contract 5 method, id `1001`, channel
  `daily_quiz_notification`, `DateTimeComponents.time`,
  `inexactAllowWhileIdle`, payload `'daily_quiz'`, UTC fallback,
  `_nextDailyTime` rollover.
- [ ] `test/helpers/fake_local_notification_service.dart` có đủ
  counters `initializeCount`/`requestCount`/`scheduleCount`/
  `cancelCount`/`lastHour`/`lastMinute` + `throwOnRequest`/
  `throwOnSchedule` + `permissionGranted`/`requestResult`.
- [ ] Giải thích được `resolvePlatformSpecificImplementation<T>`
  trả `null` khi nào và fallback `!kIsWeb` nghĩa gì.
- [ ] `flutter analyze` sạch; `flutter test` **254/254**.
