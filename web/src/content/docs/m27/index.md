---
title: "M27 — Platform Extras: Notifications, Share, Version"
description: "6 bài: ranh giới platform 'UI không chạm plugin trực tiếp' — contract→impl→plugin→OS + 5 dep + manifest (+0) → `LocalNotificationService` contract + impl plugin/timezone + `FakeLocalNotificationService` counters (+0) → `SettingsNotificationCoordinator` + permission-as-state trong SettingsViewModel + 5 test qua fake (+5) → DI `main()`/app-scope + onboarding xin quyền thật + `v$appVersion` (+0) → share cưỡi effects-stream M26: `GameShareRequested`→`GameShareResult`→`GameShareResultEvent`→`SharePlus`+`Clipboard` fallback (+0) → regression + tổng kết → 259/259. FR-27, FR-28 (version), FR-33 converge."
sidebar:
  order: 0
  label: Tổng quan M27
---

# M27 · Platform Extras: Notifications, Share, Version

Cuối M26, app đã đủ "ván chơi" hoàn chỉnh trong thế giới Dart thuần:
reducer thuần quyết transition, bridge biến effect thành
`Timer`/`Future`. Nhưng app **chưa từng nói chuyện với hệ điều
hành**: switch thông báo chỉ persist một flag vào
SharedPreferences (không ai nghe), nút "Bật thông báo" của
onboarding tự giả vờ `granted`, không có cách nào chia sẻ kết
quả, và dialog settings thiếu hàng version. Milestone này đưa app
ra khỏi lồng Dart: notification permission thật + `zonedSchedule`
hằng ngày theo giờ địa phương, share sheet qua `share_plus` với
clipboard fallback, version qua `package_info_plus` — đóng
**FR-27**, **FR-28** (phần version), **FR-33**.

:::note[Triết lý milestone: "UI không chạm plugin trực tiếp"]
- Mọi đường ra OS đi qua **contract ở biên**: widget → VM →
  `LocalNotificationService` (abstract interface) →
  `LocalNotificationServiceImpl` (plugin) → platform channel → OS.
  Không một widget hay VM nào `import` plugin trực tiếp — test
  thay impl bằng fake counters mà không sửa call-site (A-35).
- **Permission là state OS sở hữu** — app chỉ query/request,
  không assume: `effectiveNotificationEnabled` = flag AND
  permission (A-37).
- **Coordinator orchestrate thứ tự side-effect** — đặt lịch
  trước, save sau, hỏng thì hoàn tác best-effort (giữ lỗi gốc)
  (A-36).
- Share **không phải kiến trúc mới** — nó cưỡi effects-stream
  của M26: `GameShareRequested` → reducer → `GameShareResult`
  → bridge → `GameShareResultEvent` → screen gọi plugin
  (A-33 reuse).
:::

## Bản đồ bài học

| Bài | Nội dung | Checkpoint |
|-----|----------|-----------|
| [01](/m27/01-platform-boundary-va-dependencies/) | Felt problem: app chưa nói chuyện được với OS. Mental model "UI không chạm plugin trực tiếp" (A-35) — widget→VM→contract→impl→plugin→OS. 5 dep + vai trò; `kIsWeb` compile-time guard + `resolvePlatformSpecificImplementation` (D-47); manifest 2 `uses-permission` + 2 receiver verbatim senior (POST_NOTIFICATIONS = runtime permission Android 13+) | **254/254** (+0) |
| [02](/m27/02-local-notification-service/) | `lib/services/local_notification_service.dart` verbatim: contract 5 method; init per platform; `tz.initializeTimeZones` + `FlutterTimezone` + UTC fallback; `zonedSchedule` id 1001 + `DateTimeComponents.time` + `inexactAllowWhileIdle` (F-36); `_nextDailyTime` rollover; `resolvePlatformSpecificImplementation` (D-47 reuse); `FakeLocalNotificationService` counters + `throwOn*` | **254/254** (+0 — scaffold, chưa ai gọi) |
| [03](/m27/03-settings-coordinator-permission-state/) | `SettingsNotificationCoordinator` — enable/disable/updateTime + best-effort rollback giữ lỗi gốc (A-36); `_hasNotificationPermission` trong VM state + `effectiveNotificationEnabled` = flag AND permission (A-37); `loadSettings` `Future.wait`×3; `_toggleNotifications` 2 nhánh; scope `notificationService` param + `context.read` (compile-forced); +5 test qua counters | **259/259** (+5) |
| [04](/m27/04-settings-wiring-version-onboarding/) | `main()` tạo `LocalNotificationServiceImpl()` vô điều kiện (khác A-24 conditional — service tự guard, không cần dart-define) + `Provider<LocalNotificationService>.value`; onboarding đổi simulated grant → `requestPermission` thật + `FlutterError.reportError` (FR-27); `v$appVersion` + `loadAppVersion` seam (F-37); widget-test hosts thêm `notificationService:` | **259/259** (+0) |
| [05](/m27/05-share-chain-dre-effect/) | Share cưỡi effects-stream (A-33 reuse): `GameShareRequested{text}` → reducer arm → `GameShareResult` → bridge → `GameShareResultEvent` → `RenderBox`/`sharePositionOrigin` → `SharePlus.instance.share(ShareParams)` (F-35) → catch → `Clipboard` + snackbar; `_DialogShareButton` = TEACHING SCAFFOLD (senior `GameDialogButton`/`shareColor` → M28); ARB +4 key | **259/259** (+0) |
| [06](/m27/06-regression-va-tong-ket/) | Recap boundary→coordinator→effect→platform; vì sao fake counters thay OS trong test; FR-27/FR-28-residual/FR-33 → CONVERGED; `REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` honesty; còn lại M28 (visual parity)/M29 (`MenuDialogLayer`) | **259/259** (+0) |

## Kết quả cuối milestone

- `flutter analyze` sạch · `flutter test` **259/259**
  (254 + 0 + 0 + 5 + 0 + 0 + 0) · `flutter build web` PASS
  (`!kIsWeb` guard giữ app web-buildable).
- Notification flow senior-đầy-đủ: switch → `requestPermission()`
  → granted → `zonedSchedule` daily vào `notificationHour:Minute`
  theo giờ địa phương; denied → persist-off + snackbar
  `notificationPermissionRequired`; đổi giờ → reschedule có điều
  kiện; mọi bước có rollback best-effort khi save lỗi.
- Share chain: hai dialog kết thúc (thua/thắng) có nút SHARE —
  tap → share sheet với chuỗi l10n đã build; plugin lỗi (web…) →
  chuỗi vào `Clipboard` + snackbar "Đã sao chép kết quả".
- Dialog settings có `v…` căn phải cuối card khi version nạp xong
  (`PackageInfo.fromPlatform().version`); onboarding "Bật thông
  báo" xin quyền thật thay simulated grant.
- FR đóng: **FR-27** (permission + scheduling + onboarding real),
  **FR-28-residual** (version text — phần account-row visual còn
  ở M28), **FR-33** (share chain đầy đủ).

## Điều milestone này cố ý chưa làm

| Chưa làm | Milestone sở hữu | Vì sao |
|---|---|---|
| `GameDialogButton`/`shareColor` + `GameDialogShell` chrome (gradient/glow nút share) | **M28** (FR-32/FR-34) | nút `_DialogShareButton` là scaffold — ngữ nghĩa (icon share + label uppercase + tap) đúng, visual senior thuộc đợt visual parity |
| `SettingsDialogShell`/`OnboardingGameButton`/`MenuDialogBackdrop`/icon-assets/`LevelProgressCard`; account-row auth button visual | **M28** (FR-28 visual, FR-30/32) | chrome hiện tại đủ cho behavior; polish gộp đợt visual |
| `MenuDialogLayer` + `MenuDialogSettings`/`Auth`/`SignOut` state | **M29** (FR-29) | transport `showDialog` giữ — cùng scaffold đã chấp nhận từ M16 |
| Xử lý tap vào notification (payload `'daily_quiz'` deep-link) | — | senior cũng không có handler — payload chỉ là data đi kèm; đừng bịa tính năng senior không có |
| Exact-alarm (`exactAllowWhileIdle`), nhiều channel, custom actions, notification lúc app đang mở | — | roadmap loại trừ; senior dùng `inexactAllowWhileIdle` một channel duy nhất |
| Reschedule sau reboot tự viết | — | `ScheduledNotificationBootReceiver` của plugin làm việc đó — manifest receiver là đủ (senior y hệt) |
| Device-check iOS/macOS/Android thật | — | `REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` — fake counters gánh verification; đường iOS/macOS compile-only |
| `share_plus` trên iPad chạy thật | — | `sharePositionOrigin` đã wire đúng; không device để verify popover anchor |

## Checkpoint tổng kết

- [ ] `flutter analyze` sạch; `flutter test` **259/259**;
  `flutter build web` xanh.
- [ ] `lib/services/local_notification_service.dart` verbatim
  senior — id `1001`, channel `daily_quiz_notification`,
  `DateTimeComponents.time`, `inexactAllowWhileIdle`, payload
  `daily_quiz`, UTC fallback.
- [ ] `SettingsViewModel` có `notificationService` + `_loadAppVersion`
  seam; `effectiveNotificationEnabled` = flag AND permission;
  `loadSettings` là `Future.wait` 3-việc.
- [ ] `AppDependencyScope` có `Provider<LocalNotificationService>
  .value`; `main()` tạo impl vô điều kiện; onboarding scope gọi
  `requestPermission()` thật.
- [ ] Share chain đầy đủ 6 mắt: action → reducer arm → effect →
  bridge → UI event → `SharePlus`/`Clipboard` tại screen; hai
  dialog kết thúc có nút SHARE.
- [ ] Nói được không lắp bắp: vì sao widget không import plugin;
  "đặt lịch trước save sau" tránh tình trạng gì; permission vì
  sao phải query chứ không assume; `sharePositionOrigin` dành cho
  ai; vì sao `!kIsWeb` là hằng biên dịch chứ không `if` runtime.

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** Ranh giới service-contract cho platform (A-35);
   coordinator + best-effort rollback (A-36); permission-as-state
   AND-gate (A-37); `kIsWeb` + `resolvePlatformSpecificImplementation`
   (D-47); `flutter_local_notifications`/`zonedSchedule`/
   `DateTimeComponents.time` (F-36); `share_plus` + `Clipboard`
   fallback (F-35); `package_info_plus` (F-37).
2. **Giải thích được?** Vì sao service là `abstract interface
   class` chứ không phải gọi plugin thẳng; vì sao coordinator
   schedule-TRƯỚC-save-SAU (và thứ tự ngược lại sẽ để lại lỗi gì);
   vì sao permission sống trong VM state nhưng thuộc sở hữu OS;
   vì sao share đi qua effects-stream thay vì `onTap` gọi plugin;
   vì sao manifest cần POST_NOTIFICATIONS *và* `requestPermission`.
3. **Viết lại không copy?** Tự làm: PRODUCE `ReminderService`
   contract + fake counters (Bài 1) + PREDICT `_nextDailyTime`
   rollover (Bài 2) + DEBUG đảo thứ tự schedule/save trong
   `enable` (Bài 3 — đã verify trên suite thật) + PREDICT
   `loadSettings` fail-branch (Bài 4) + PRODUCE reducer test
   scratch cho `GameShareRequested` (Bài 5) + PREDICT chuỗi
   share-fail (Bài 6).
4. **Nếu … thì sao?** User từ chối quyền → persist-off + snackbar,
   switch tự về tắt; save settings lỗi sau khi đã schedule →
   `cancelDaily` hoàn tác, lỗi gốc vẫn lên snackbar; đổi giờ khi
   schedule hỏng → giờ cũ được restore, `notificationHour` không
   đổi; `SharePlus` throw (web) → text vào clipboard + snackbar;
   bấm SHARE lúc reducer guard → chỉ effect, không state đổi.
5. **Cần ở đâu sau?** M28 đổi `_DialogShareButton` scaffold →
   `GameDialogButton`/`shareColor` thật + toàn bộ visual parity;
   M29 `MenuDialogLayer` thay `showDialog` transport. Pattern
   "contract → fake counters → coordinator orchestration" là mẫu
   cho mọi platform service sau này.
