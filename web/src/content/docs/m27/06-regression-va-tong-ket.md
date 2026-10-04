---
title: "Bài 6 · Regression + tổng kết — app đã ra khỏi lồng Dart"
description: "Recap boundary→coordinator→permission→effect→platform call; fake counters = deterministic OS substitute (vì sao 12 test settings VM không chạm plugin); residual → CONVERGED; REAL_DEVICE_PLATFORM_CHECK NOT_PERFORMED honesty; còn M28 visual parity + M29 MenuDialogLayer. Final: analyze clean + 259/259 + build web PASS."
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
- Đọc bảng convergence: notification flow, version-text
  residual và share chain đều → CONVERGED.
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

## Mental model mới — bản đồ một trang của platform extras

```text
  ┌──────────────────────────── UI ────────────────────────────┐
  │ switch settings │ onboarding "Bật thông báo" │ SHARE dialog │
  └───────┬──────────────────┬──────────────────────┬──────────┘
          │                  │                      │
          ▼                  ▼                      ▼
   SettingsViewModel   Onboarding scope       viewModel.shareResult
   (AND-gate,     requestPermission()         │ dispatch
    Future.wait×3)     → VM.onNotification-        ▼
          │            PermissionResult        GameShareRequested
          ▼                                     (action)
   SettingsNotificationCoordinator                 │
   (order + best-effort rollback)            ▼
          │                              reducer → GameShareResult
          ▼                              (effect — state giữ nguyên)
   LocalNotificationService               │
   contract 5 method                              ▼
          │                              bridge → GameShareResultEvent
          ▼                                     (ui event)
   LocalNotificationServiceImpl                  │
   (plugin + timezone + resolve<T> +             ▼
    !kIsWeb fallback)         screen: SharePlus.share(
          │                                ShareParams(origin))
          ▼                                     │ lỗi → Clipboard +
   OS (alarm/permission prompt)                  snackbar
```

Một đường nữa ngoài sơ đồ: `loadSettingsAppVersion` →
`PackageInfo.fromPlatform().version` → `v…` row.

## Dart cần dùng / Dart mới

Không construct mới — recap checklist:

- [ ] `abstract interface class` contract 
- [ ] `resolvePlatformSpecificImplementation<T>()` + `kIsWeb`
- [ ] `tz.TZDateTime`/`setLocalLocation`/`initializeTimeZones`
 + `DateTimeComponents.time` + `inexactAllowWhileIdle` 
- [ ] Coordinator callback `Future<void> Function(X)` + tear-off
 rollback 
- [ ] `Future.wait` 3-việc + `as` unwrap results 
- [ ] `PackageInfo.fromPlatform().version` + `Function()` seam
- [ ] `RenderBox`/`localToGlobal`/`&` Rect + `ShareParams` +
 `Clipboard` 

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
milestone ghi `NOT_PERFORMED` thành limitation đã biết, không giả
vờ đã làm.

## Senior project connection — bảng convergence

| Feature | Trước M27 | Sau M27 | Trạng thái |
| --- | --- | --- | --- |
| notifications | switch chỉ persist flag; onboarding giả `true`; không service | contract+impl verbatim; coordinator rollback; permission AND-gate; `Future.wait`×3; onboarding `requestPermission` thật; snackbar `notificationPermissionRequired` | **CONVERGED** |
| version text (residual) | dialog không có `v…` | `loadSettingsAppVersion` seam + `_appVersion` + `v…` bottom-right `isNotEmpty`-gated | **CONVERGED** (phần version; account-row visual → M28) |
| share | không action/effect/event share; 2 nút kết thúc | `GameShareRequested`→`GameShareResult`→`GameShareResultEvent`→`SharePlus`+`Clipboard`; SHARE trên cả Ended+Victory | **CONVERGED** |

Deferred còn lại: (`MenuDialogLayer` transport) → M29;
phần visual (`SettingsDialogShell`, `GameDialogButton`,
`shareColor`, icon assets…) → M28; phần còn lại → milestone khác.

## Build it step by step — regression cuối milestone

**Bước 1 — `flutter analyze`** → `No issues found!`

**Bước 2 — `flutter test`** → `+259: All tests passed!`
(12 trong file settings VM; +5 net của milestone.)

**Bước 3 — `flutter build web`** → compile web xanh (plugin có
web impl federated; `zonedSchedule`/`share` trên web là runtime
degrade đã catch, không phải build error).

**Bước 4 — tự kiểm bằng tay (checklist dưới)** — chạy được đầy đủ
là đủ; *không* yêu cầu device thật (ghi rõ phần chưa verify).

## Hiểu code — bốn câu tự hỏi cuối

1. **Vì sao `_hasNotificationPermission` không persist?** — OS
   sở hữu sự thật; user thu hồi quyền ở system Settings lúc app
   tắt → flag persist-on sẽ nói dối. Query mỗi `loadSettings`.
2. **Vì sao coordinator tách ra khỏi VM?** — thứ tự side-effect
   (schedule→save) + rollback best-effort là *logic độc lập*
   khỏi stream/notify; test được coordinator mà không cần VM.
3. **Vì sao share qua effect chain thay vì dialog gọi plugin?** —
   plugin call cần `RenderBox`/`ScaffoldMessenger` của screen +
 giữ ranh giới "widget không import plugin"; effect là
   data → reducer testable.
4. **Vì sao `requestPermission` ở onboarding catch `reportError`
   mà settings catch snackbar?** — hai UX khác nhau: onboarding
   không có snackbar riêng + muốn flow tiếp tục (degrade denied);
   settings muốn *báo* user lỗi vì user chủ động bấm.

## Chạy và quan sát — thành phần verification thật

| Đường | Verify bởi |
| --- | --- |
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
2. **Save trước schedule sau** trong `enable` → flag on không
   notification (DEBUG Bài 3).
3. **Nuốt lỗi rollback lẫn lỗi gốc** → snackbar sai nguyên nhân.
4. **Dialog/widget import plugin** → phá, không test được.
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

- **Hỏi:** vẽ chuỗi bật thông báo thành công. — **Đáp:**
  `toggleSetting` → `_toggleNotifications` → `!_hasPermission` →
  `requestPermission` true → `coordinator.enable` → `scheduleDaily
  (h,m)` → `saveSettings(on)` → subject → notify → switch on +
  hàng giờ hiện.
- **Hỏi:** đổi giờ khi đang bật nhưng `scheduleDaily` throw? —
  **Đáp:** `updateTime` catch → `_restoreSchedule(previousSettings)`
  (giờ cũ) best-effort → rethrow → VM → snackbar `notification
  TimeUpdateFailed`; `notificationHour` không đổi.
- **Hỏi:** phần nào đã hội tụ, phần nào còn? — **Đáp:**
  notification flow + version text + share chain đã converge;
  account visual + onboarding/settings visuals → M28; menu
  dialog layer + asset parity → M29.
- **Hỏi:** phần nào suite *không* chứng minh? — **Đáp:** prompt
  OS thật, notification bắn thật, share sheet thật, iPad anchor —
  `NOT_PERFORMED`.

## Ta cố ý chưa thêm — tổng milestone

| Chưa | Milestone |
| --- | --- |
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
- [ ] Kể được notification flow, version-text residual và share chain đã converge ở file nào.
- [ ] Nói được không script: vì sao contract ở `services/`, vì sao
  coordinator tách VM, vì sao permission query không assume, vì
  sao share qua effect, vì sao `!kIsWeb` là fallback giá trị.
- [ ] Ghi nhận trung thực `REAL_DEVICE_PLATFORM_CHECK:
  NOT_PERFORMED` — và liệt kê được những gì nó không cover.
- [ ] Nêu đúng: `_DialogShareButton` scaffold → M28;
  `MenuDialogLayer` → M29.

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
