---
title: "Bài 6 · Regression + tổng kết — app đã ra khỏi lồng Dart"
description: "Recap boundary→coordinator→permission→effect→platform call; fake counters = deterministic OS substitute (vì sao 12 test settings VM không chạm plugin); FR-27/FR-28-residual/FR-33 → CONVERGED; REAL_DEVICE_PLATFORM_CHECK NOT_PERFORMED honesty; còn M28 visual parity + M29 MenuDialogLayer. Final: analyze clean + 259/259 + build web PASS."
sidebar:
  label: "Bài 6 · regression + tổng kết"
  order: 6
---

## Mục tiêu

- Nhìn lại toàn bộ đường platform của M27 trên một sơ đồ — từ
  `pubspec`/manifest tới `zonedSchedule`/`SharePlus`/`Clipboard`.
- Giải thích được vai trò của fake counters như "OS thay thế
  deterministic" — vì sao 12 test settings VM không import plugin
  vẫn cover được permission/schedule/rollback.
- Đọc bảng FR convergence: FR-27 (notification flow), FR-28
  residual (version text), FR-33 (share chain) → CONVERGED.
- Chấp nhận và nói được thành phần honesty:
  `REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` — những đường nào
  test *không* chứng minh được.
- Nêu đúng phần còn lại: M28 visual parity (`GameDialogButton`/
  `shareColor`, settings shell…), M29 `MenuDialogLayer`.
- Chạy full regression: `flutter analyze` sạch · `flutter test`
  **259/259** · `flutter build web` PASS.

## Bạn đang ở đâu

- Cuối Bài 5: share chain đủ sáu mắt, 259/259, build web xanh.
- M27 kết thúc tại đây — app đã có: notification daily theo giờ
  địa phương + permission OS + rollback, version row, onboarding
  xin quyền thật, share sheet + clipboard fallback.

## Vì sao việc này quan trọng ngay bây giờ

Platform extras là nơi dễ "chạy xong mà không hiểu": dep cài xong,
copy code từ plugin README, bấm chạy được → nghĩ là xong. Bài này
bắt bạn chứng minh ngược lại — vẽ lại được chuỗi, đoán được
failure-paths, biết chính xác phần nào *chưa* được verify (không
có device thật). Đó là thói quen cần cho mọi platform feature sau
này — và là thứ reviewer/QA nhìn vào khi chấm milestone.

## Bạn đã biết gì

Mọi thứ của M27 + M26 — bài này không có construct mới; nó là
tổng hợp có cấu trúc.

## Mental model mới — bản đồ một-trang của platform extras

```text
  ┌──────────────────────────── UI ────────────────────────────┐
  │ switch settings │ onboarding "Bật thông báo" │ SHARE dialog │
  └───────┬──────────────────┬──────────────────────┬──────────┘
          │                  │                      │
          ▼                  ▼                      ▼
   SettingsViewModel   Onboarding scope       viewModel.shareResult
   (AND-gate A-37,     requestPermission()         │ dispatch
    Future.wait×3)     → VM.onNotification-        ▼
          │            PermissionResult        GameShareRequested
          ▼                                     (action)
   SettingsNotificationCoordinator                 │
   (A-36: order + best-effort rollback)            ▼
          │                              reducer → GameShareResult
          ▼                              (effect — state giữ nguyên)
   LocalNotificationService (A-35)               │
   contract 5 method                              ▼
          │                              bridge → GameShareResultEvent
          ▼                                     (ui event)
   LocalNotificationServiceImpl                  │
   (plugin + timezone + resolve<T> +             ▼
    !kIsWeb fallback — D-47/F-36)         screen: SharePlus.share(
          │                                ShareParams(origin))
          ▼                                     │ lỗi → Clipboard +
   OS (alarm/permission prompt)                  snackbar (F-35)
```

Một đường nữa ngoài sơ đồ: `loadSettingsAppVersion` →
`PackageInfo.fromPlatform().version` → `v…` row (F-37).

## Dart cần dùng / Dart mới

Không construct mới — recap checklist:

- [ ] `abstract interface class` contract (A-35)
- [ ] `resolvePlatformSpecificImplementation<T>()` + `kIsWeb`
  (D-47)
- [ ] `tz.TZDateTime`/`setLocalLocation`/`initializeTimeZones`
  + `DateTimeComponents.time` + `inexactAllowWhileIdle` (F-36)
- [ ] Coordinator callback `Future<void> Function(X)` + tear-off
  rollback (A-36)
- [ ] `Future.wait` 3-việc + `as` unwrap results (A-37/D-09)
- [ ] `PackageInfo.fromPlatform().version` + `Function()` seam
  (F-37)
- [ ] `RenderBox`/`localToGlobal`/`&` Rect + `ShareParams` +
  `Clipboard` (F-35)

## Flutter cần dùng

Không API mới — recap: `Provider<LocalNotificationService>.value`,
`TextButton.icon` scaffold, `SharePlus`, `Clipboard`,
`ScaffoldMessenger`, `FlutterError.reportError`.

## Ví dụ độc lập — "OS thay thế" deterministic

```dart
// Một fake = một OS giả có thể assert — KHÔNG cần thiết bị.
class CountingOs {
  var scheduled = <int>[];
  var cancelled = 0;
  var permissionGranted = false;
}

// Test ý định, không test plugin:
void main() {
  final os = CountingOs();
  // enable flow
  os.permissionGranted = true;
  os.scheduled.add(20 * 60); // 20:00 → minutes-since-midnight
  assert(os.scheduled.length == 1);
  // disable flow
  os.cancelled++;
  assert(os.cancelled == 1);
  print('OK — ý định verified mà không chạm plugin');
}
```

`FakeLocalNotificationService` là bản production của ý tưởng này —
counters thay OS, `throwOn*` mô phỏng failure OS.

## Android / Compose bridge

**SIMILARITY — toàn bộ notification path ≈ `WorkManager`/`Alarm
Manager` + `NotificationManager` wrapper.** Contract-interface +
impl plugin + fake counters tương đương repository/fake pattern
bạn đã dùng cho mọi subsystem Android.

**IMPORTANT DIFFERENCE — platform call trong Flutter test phải
luôn fake.** Không có Robolectric-equivalent miễn phí: method
channel trong unit test throw — counters là *cách duy nhất* để
assert ý định mà không `TestDefaultBinaryMessenger` phức tạp.

**DO NOT ASSUME — suite xanh ≠ platform thật chạy.** `flutter
test` không pump plugin, không mở share sheet, không bắn
notification. Xanh = ý định đúng; device-check vẫn cần tay —
milestone ghi `NOT_PERFORMED` thành limitation đã-biết, không giả
vờ đã làm.

## Senior project connection — bảng convergence

| FR | Trước M27 | Sau M27 | Trạng thái |
|---|---|---|---|
| **FR-27** notifications | switch chỉ persist flag; onboarding giả `true`; không service | contract+impl verbatim; coordinator rollback; permission AND-gate; `Future.wait`×3; onboarding `requestPermission` thật; snackbar `notificationPermissionRequired` | **CONVERGED** |
| **FR-28** (residual) | dialog không có `v…` | `loadSettingsAppVersion` seam + `_appVersion` + `v…` bottom-right `isNotEmpty`-gated | **CONVERGED** (phần version; account-row visual → M28) |
| **FR-33** share | không action/effect/event share; 2 nút kết thúc | `GameShareRequested`→`GameShareResult`→`GameShareResultEvent`→`SharePlus`+`Clipboard`; SHARE trên cả Ended+Victory | **CONVERGED** |

Deferred còn lại: FR-29 (`MenuDialogLayer` transport) → M29;
FR-30/32/34 visuals (`SettingsDialogShell`, `GameDialogButton`,
`shareColor`, icon assets…) → M28; FR-25/31 → milestone khác.

## Build it step by step — regression cuối milestone

**Bước 1 — `flutter analyze`** → `No issues found!`

**Bước 2 — `flutter test`** → `+259: All tests passed!`
(12 trong file settings VM; +5 net của milestone.)

**Bước 3 — `flutter build web`** → compile web xanh (plugin có
web impl federated; `zonedSchedule`/`share` trên web là runtime
degrade đã-catch, không phải build error).

**Bước 4 — tự kiểm bằng tay (checklist dưới)** — chạy được đầy đủ
là đủ; *không* yêu cầu device thật (ghi rõ phần chưa verify).

## Hiểu code — bốn câu tự-hỏi cuối

1. **Vì sao `_hasNotificationPermission` không persist?** — OS
   sở hữu sự thật; user thu hồi quyền ở system Settings lúc app
   tắt → flag persist-on sẽ nói dối. Query mỗi `loadSettings`.
2. **Vì sao coordinator tách ra khỏi VM?** — thứ tự side-effect
   (schedule→save) + rollback best-effort là *logic độc lập*
   khỏi stream/notify; test được coordinator mà không cần VM.
3. **Vì sao share qua effect chain thay vì dialog gọi plugin?** —
   plugin call cần `RenderBox`/`ScaffoldMessenger` của screen +
   giữ ranh giới "widget không import plugin" (A-35); effect là
   data → reducer testable.
4. **Vì sao `requestPermission` ở onboarding catch `reportError`
   mà settings catch snackbar?** — hai UX khác nhau: onboarding
   không có snackbar-riêng + muốn flow tiếp tục (degrade denied);
   settings muốn *báo* user lỗi vì user chủ động bấm.

## Chạy và quan sát — thành phần verification thật

| Đường | Verify bởi |
|---|---|
| schedule/cancel/rollback order | fake counters — `scheduleCount`, `cancelCount`, `lastHour`/`lastMinute`, `throwOn*` |
| permission grant/deny/AND-gate | `requestResult`/`permissionGranted` trên fake + `repo.value` + snackbar events |
| version load | seam `() async => '9.9.9'` → `vm.appVersion` |
| share chain đến bridge | reducer/`effects` shape (Tự làm Bài 5) |
| **OS prompt thật / notification thật / share sheet thật / iPad anchor** | **`REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED`** — không test được trong suite, cần tay |

Đây là thiết kế, không phải thiếu sót vô tình: contract đặt ý
định ở chỗ fake assert được; phần không fake được (plugin↔OS)
được *ghi nhận* là runtime-verified-only.

## Thử nghiệm — trace một failure-path

User bật switch trên Android 13, OS prompt hiện, user chọn
"Deny". Viết ra mỗi bước: counters của fake tương ứng sẽ là gì,
repo value, snackbar nào, switch cuối hiển thị gì.

<details>
<summary>Đáp án</summary>

- `requestCount` 1 → `requestResult false` → `_hasNotificationPermission
  = false` → `_saveSettings(notificationEnabled: false)` →
  `repo.value.notificationEnabled == false` → `_emitSnackBar(
  notificationPermissionRequired)` → `_notifyIfOpen()` → switch
  render `false` (AND-gate: flag-off AND permission-off).
- `scheduleCount` 0, `cancelCount` 0 — không đặt lịch nào.
</details>

## Lỗi hay gặp (tổng kết milestone)

1. **Assume permission persist được** → flag liar.
2. **Save trước schedule sau** trong `enable` → flag-on-không-
   notification (DEBUG Bài 3).
3. **Nuốt lỗi rollback lẫn lỗi gốc** → snackbar sai nguyên nhân.
4. **Dialog/widget import plugin** → phá A-35, không test được.
5. **`sharePositionOrigin` từ dialog context** → anchor có thể
   đã pop.
6. **Quên `!mounted` sau await trong event handler** → context
   chết.
7. **Nói "đã test notification" vì suite xanh** — fake ≠ OS;
   `NOT_PERFORMED` là trạng thái trung thực.

## Tự làm — PREDICT

Bấm SHARE **trên web** (hoặc platform `share_plus` không hỗ trợ):
`SharePlus.instance.share` throw. Trace chính xác chuỗi sau đó —
và trả lời: nếu `Clipboard.setData` *cũng* throw thì sao?

<details>
<summary><strong>Đáp án</strong></summary>

1. `catch (_)` bắt lỗi share → `await Clipboard.setData(
   ClipboardData(text: text))` → copy text vào clipboard.
2. `if (!mounted) return` — nếu route đã pop trong lúc await, dừng.
3. `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
   Text(l10n.resultCopiedSnackBar), duration: 2s))` — user thấy
   "Đã sao chép kết quả".

Nếu `Clipboard.setData` *cũng* throw: lỗi tràn ra khỏi
`_handleUiEvent` — handler `async` fire-and-forget →
**unhandled async error** lên `FlutterError` (zone), không có
snackbar nào. Senior không catch tầng hai — chấp nhận clipboard
"đủ tin cậy để không bọc". Đó là giới hạn cố ý: đừng thêm catch
vô hạn.
</details>

## Kiểm tra hiểu biết — synthesis cuối

- **Hỏi:** vẽ chuỗi bật-thông-báo thành công. — **Đáp:**
  `toggleSetting` → `_toggleNotifications` → `!_hasPermission` →
  `requestPermission` true → `coordinator.enable` → `scheduleDaily
  (h,m)` → `saveSettings(on)` → subject → notify → switch on +
  hàng giờ hiện.
- **Hỏi:** đổi giờ khi đang bật nhưng `scheduleDaily` throw? —
  **Đáp:** `updateTime` catch → `_restoreSchedule(previousSettings)`
  (giờ cũ) best-effort → rethrow → VM → snackbar `notification
  TimeUpdateFailed`; `notificationHour` không đổi.
- **Hỏi:** FR nào đóng, phần nào còn? — **Đáp:** FR-27, FR-28
  (version), FR-33 đóng; FR-28 account-visual + FR-30/32/34 →
  M28; FR-29 → M29.
- **Hỏi:** phần nào suite *không* chứng minh? — **Đáp:** prompt
  OS thật, notification bắn thật, share sheet thật, iPad anchor —
  `NOT_PERFORMED`.

## Ta cố ý chưa thêm — tổng milestone

| Chưa | Milestone |
|---|---|
| `GameDialogButton`/`shareColor` gradient + toàn bộ dialog/menu visual parity (`SettingsDialogShell`, `OnboardingGameButton`, `MenuDialogBackdrop`, `LevelProgressCard`, icon assets, account-row auth visual) | **M28** |
| `MenuDialogLayer` + `MenuDialogSettings`/`Auth`/`SignOut` state transport | **M29** |
| Exact alarms, nhiều channel, notification actions, tap-handler payload, foreground presentation | — (senior cũng không) |
| Re-schedule sau reboot tự viết | — (plugin receiver đã cover) |
| Share có ảnh/file, share analytics | — (senior không) |
| iOS `hasPermission` check, re-request guidance khi denied | — (senior không) |
| Device-check notification/share thật | cần tay ngoài milestone |

## Checkpoint hoàn thành

- [ ] `flutter analyze` → `No issues found!`
- [ ] `flutter test` → **259/259** (+5 net so với đầu milestone).
- [ ] `flutter build web` → PASS.
- [ ] FR-27/FR-28-residual/FR-33 kể được đã converge ở file nào.
- [ ] Nói được không script: vì sao contract ở `services/`, vì sao
  coordinator tách VM, vì sao permission query-không-assume, vì
  sao share qua effect, vì sao `!kIsWeb` là fallback giá trị.
- [ ] Ghi nhận trung thực `REAL_DEVICE_PLATFORM_CHECK:
  NOT_PERFORMED` — và liệt kê được những gì nó không cover.
- [ ] Nêu đúng: `_DialogShareButton` scaffold → M28;
  `MenuDialogLayer` → M29.
