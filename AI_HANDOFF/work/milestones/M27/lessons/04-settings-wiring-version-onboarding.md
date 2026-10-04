---
title: "Bài 4 · Wiring — DI scope, version row, onboarding xin quyền thật"
description: "Đóng khoảng hở Bài 3: `main()` tạo `LocalNotificationServiceImpl()` VÔ ĐIỀU KIỆN (khác A-24 conditional — service tự guard, không dart-define) + `Provider<LocalNotificationService>.value` trong AppDependencyScope. Onboarding đổi simulated grant → `requestPermission()` thật + `FlutterError.reportError` (FR-27). `v$appVersion` row + `package_info_plus` seam `() async => '9.9.9'` (F-37). Widget-test hosts nhận `notificationService:` — +0 test → 259."
sidebar:
  label: "Bài 4 · wiring + version + onboarding"
  order: 4
---

## Mục tiêu

- Đóng khoảng hở Bài 3: `main()` tạo `LocalNotificationServiceImpl()`
  **vô điều kiện** + `AppDependencyScope` đăng ký
  `Provider<LocalNotificationService>.value`.
- Giải thích được vì sao service này *không* theo conditional-DI
  của Supabase (A-24): không dart-define lái — impl tự an toàn
  (`initialize` web OK, `requestPermission` → `!kIsWeb`).
- Đổi onboarding từ simulated grant sang `requestPermission()`
  thật + `FlutterError.reportError` khi lỗi — coi lỗi là denied,
  không crash overlay (FR-27).
- Hiển thị `v$appVersion` cuối settings dialog + giải thích
  `package_info_plus` và seam `loadAppVersion` (F-37).
- Cập nhật widget-test hosts (bốn `AppDependencyScope` hosts +
  onboarding `Provider.value` host) nhận fake service — +0 test →
  **259/259**. (Hai `SettingsDialogScope` hosts đã vá ở Bài 3.)

## Bạn đang ở đâu

- Cuối Bài 3: VM + coordinator + scope param compile sạch,
  259/259 — nhưng `context.read<LocalNotificationService>()` trong
  `showSettingsDialog` **chưa có provider** → app thật mở settings
  crash `ProviderNotFoundException`. (Onboarding scope còn nguyên
  simulated grant — `context.read` của nó chỉ được viết ở Bước 4
  bài này, sau khi provider đã đăng ký ở Bước 2.)
- Bài này là "nối điện": provider → main() → loader → row UI →
  onboarding → test hosts.

## Vì sao việc này quan trọng ngay bây giờ

Đây là bài chứng-minh-claim của A-35: vì VM/widget chỉ biết
*contract*, giờ ta đặt impl plugin vào app-scope mà **không sửa
một dòng nào** trong VM/dialog/onboarding — đổi impl = đổi một
chỗ `main()`. Đồng thời đây là lúc hai tính năng user-facing
cuối cùng bật lên: `v…` version text và nút "Bật thông báo"
onboarding xin quyền thật — cái `onNotificationPermissionResult(
true)` giả-vờ cũ chết tại đây.

## Bạn đã biết gì

- `AppDependencyScope` + `Provider<CONTRACT>.value` — đăng ký theo
  kiểu interface (M14 — A-07/F-21).
- Conditional DI: `client == null ? Disabled : Impl` trong `main()`
  (M23 — A-24) — *sẽ đối lập* với unconditional của bài này.
- `context.read<T>()` ở `didChangeDependencies`/caller trước
  `showDialog` (M16 — F-17).
- `OnboardingViewModel.onNotificationPermissionResult(bool)` đã
  tồn tại từ M18 — scope cũ gọi nó với `true` hardcode.
- `unawaited(...)` cho future-không-await trong callback (D-17 —
  M11).
- `FlutterError.reportError` — báo lỗi không-fatal lên framework
  (đã gặp trong `OnboardingViewModel` error paths — M18).

## Mental model mới — "hai kiểu DI: conditional vs unconditional"

```text
   Supabase (A-24):                    Notification (M27):
   client == null ? Disabled : Impl    LocalNotificationServiceImpl()  ← luôn impl

   Điều kiện = CẤU HÌNH build          Điều kiện = PLATFORM runtime —
   (thiếu dart-define → Disabled)     impl tự phân nhánh bên trong
                                     (resolve… / !kIsWeb / web impl
                                     federated), không cần dart-define
```

Quy tắc chọn: nếu *không-có-impl-an-toàn* (Supabase thiếu URL thì
không chạy được) → conditional DI với Disabled-impl. Nếu impl
*tự an toàn mọi platform* (plugin có web stub, mọi call đều
degrade gracefully) → unconditional — không cần fake/disabled
song song.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `PackageInfo.fromPlatform()` | static async — đọc metadata bundle của app đang chạy; `.version` trả chuỗi `version:` từ pubspec (F-37 — mới) |
| `FlutterError.reportError(FlutterErrorDetails(exception:, stackTrace:, library:, context:))` | báo lỗi không-fatal lên framework — xuất hiện trong console/TestWidgetsFlutterBinding mà không crash app |
| `unawaited(future)` | đánh dấu "cố ý không await" — onboarding callback fire-and-forget nhưng vẫn `async` bên trong |

## Flutter cần dùng

| API | Vai trò |
|---|---|
| `Provider<LocalNotificationService>.value` | đăng ký *theo contract* — cùng entry shape bảy provider khác |
| `context.read<LocalNotificationService>()` | onboarding scope + `showSettingsDialog` đọc — giờ đã có provider trả |
| `Text('v${viewModel.appVersion}')` + `isNotEmpty` gate | row version chỉ render khi đã nạp — `''` trước `loadSettings` → không hiện `v` trần |

## Ví dụ độc lập — seam hàm-thay-impl (DartPad)

```dart
// Seam `Future<String> Function()` — production truyền loader thật,
// test truyền hàm trả chuỗi cố định.
class VersionHolder {
  final Future<String> Function() _load;
  var version = '';

  VersionHolder({Future<String> Function()? load})
    : _load = load ?? _realLoad;

  static Future<String> _realLoad() async => 'from-platform';

  Future<void> load() async {
    version = await _load();
  }
}

void main() async {
  final prod = VersionHolder();
  await prod.load();
  print(prod.version); // from-platform

  final test = VersionHolder(load: () async => '9.9.9');
  await test.load();
  print(test.version); // 9.9.9 — deterministic, không plugin
}
```

`??` ở ctor chọn mặc định; caller-test không gửi gì thì dùng
loader thật — đúng `loadAppVersion ?? loadSettingsAppVersion`.

## Android / Compose bridge

**SIMILARITY — `PackageInfo.fromPlatform().version` ≈
`packageManager.getPackageInfo(packageName, 0).versionName`.** Cùng
đọc metadata bundle đã build — không hardcode `'v1.0.0'` trong
code; pubspec `version: x.y.z+n` đắp vào `versionName` lúc build.

**IMPORTANT DIFFERENCE — `requestPermission` không phải lúc nào
cũng prompt.** Android chỉ hiện dialog runtime-permission một
lần; user tích "Don't ask again"/denied 2 lần →
`requestNotificationsPermission()` trả `false` im lặng (hệ quả:
app phải chịu "denied" và không auto-retry vô hạn — đúng flow
denied-path ở Bài 3).

**DO NOT ASSUME — `initialize()` đã không nằm trong `main()`.**
Service lazy-init (mọi method tự `await initialize()`) nên
`main()` chỉ *tạo instance* — không `await service.initialize()`
ở startup: nhanh hơn, và web không tốn một service-worker-
registration vô dụng khi user không đụng notification.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/main.dart` — `final notificationService = LocalNotificationServiceImpl();` (vô điều kiện, ngay sau repos) | learner verbatim — cùng điểm khởi tạo, không dart-define |
| `lib/core/app_dependency_scope.dart` — field + `Provider<LocalNotificationService>.value` | learner verbatim — entry theo contract |
| `lib/view_models/settings/settings_app_version_loader.dart` | 6 dòng verbatim (đã land Bài 3); F-37 giải thích ở đây |
| `lib/widgets/menu/settings/settings_card.dart` — `v$appVersion` cuối card | learner render cùng điều kiện `isNotEmpty` |
| `lib/widgets/onboarding/onboarding_overlay_scope.dart` — `_requestNotificationPermission` | verbatim — đọc service → `requestPermission()` → `onNotificationPermissionResult(granted)`; catch → `FlutterError.reportError` + `false` |

## Build it step by step

**Bước 1 — `lib/main.dart`**: tạo impl **vô điều kiện** (verbatim
senior — khác hẳn conditional của `profileSyncRepository` ngay
trên):

```dart
  // M27: notification service luôn là impl plugin — senior `main()`
  // cũng khởi tạo vô điều kiện (plugin tự no-op/`!kIsWeb` guard;
  // không có dart-define nào lái nó).
  final notificationService = LocalNotificationServiceImpl();
  final navigationController = AppNavigationController();
  await userSettingsRepository.loadUserSettings();
  runApp(
    AppDependencyScope(
      ...
      notificationService: notificationService,
      ...
```

**Bước 2 — `lib/core/app_dependency_scope.dart`**: field + ctor +
provider entry (verbatim):

```dart
  /// M27: service thông báo local — contract `LocalNotificationService`,
  /// impl `LocalNotificationServiceImpl` (plugin) tạo ở `main()` đúng
  /// senior `Provider<LocalNotificationService>.value`.
  final LocalNotificationService notificationService;
```

```dart
    required this.notificationService,
```

```dart
        Provider<LocalNotificationService>.value(value: notificationService),
```

Từ đây `context.read<LocalNotificationService>()` của Bài 3 trả
được impl — khoảng hở `ProviderNotFound` đóng.

**Bước 3 — `settings_dialog.dart`**: version row cuối card
(verbatim — sau `_SettingsAccountRow`):

```dart
            _SettingsAccountRow(profile: profile),
            // M27 — senior `settings_card.dart`: `v$appVersion` căn
            // phải cuối card, chỉ render khi version đã nạp (không rỗng).
            if (viewModel.appVersion.isNotEmpty) ...[
              const SizedBox(height: MenuTokens.spacingSm),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'v${viewModel.appVersion}',
                  style: const TextStyle(
                    color: MenuTokens.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
```

`PackageInfo.fromPlatform().version` (đã nạp trong `loadSettings`
Bài 3) trả đúng chuỗi `version:` trong pubspec trừ phần `+build` —
`v1.0.0` thay vì `v1.0.0+1`. Gate `isNotEmpty` tránh hiện `v` trần
khi `loadSettings` chưa xong hoặc lỗi (senior cùng chính sách).

**Bước 4 — `onboarding_overlay_scope.dart`**: connector đổi
callback + method thật (verbatim):

```dart
      // M27 (FR-27 converge): xin quyền THẬT qua service — senior
      // `_requestNotificationPermission` verbatim phía dưới.
      onEnableNotifications: () =>
          unawaited(_requestNotificationPermission(context)),
```

```dart
  /// Senior verbatim: đọc service từ scope → `requestPermission()` →
  /// kết quả thật vào VM; lỗi → `FlutterError.reportError` + coi như
  /// denied (step chuyển `isEnabled: false`, không crash overlay).
  Future<void> _requestNotificationPermission(BuildContext context) async {
    final notificationService = context.read<LocalNotificationService>();
    final viewModel = context.read<OnboardingViewModel>();

    try {
      final granted = await notificationService.requestPermission();
      await viewModel.onNotificationPermissionResult(granted);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'onboarding',
          context: ErrorDescription('requesting notification permission'),
        ),
      );
      await viewModel.onNotificationPermissionResult(false);
    }
  }
```

Ba ý đồ: (1) `context.read` hai lần — service + VM cùng lúc, vì
callback chạy sau nên context vẫn valid trong scope còn mounted;
(2) kết quả **thật** đi vào VM — granted mới advance step với
`isEnabled: true`; (3) catch → `reportError` (không im lặng:
framework log thấy) *và* `onNotificationPermissionResult(false)`
— lỗi coi như denied, overlay không kẹt.

**Bước 5 — test hosts** (năm file — `required` trên
`AppDependencyScope` compile-force bốn host pump nó trực tiếp;
host onboarding cần `Provider` cho `context.read` mới):

```dart
// 4 host AppDependencyScope — thêm một dòng ctor-arg:
      notificationService: FakeLocalNotificationService(),
//   test/menu_provider_scope_test.dart
//   test/menu_screen_ui_events_test.dart
//   test/widgets/game_screen_test.dart
//   test/widgets/menu_leaderboard_dialog_test.dart

// test/widgets/onboarding_overlay_test.dart — MultiProvider host
        Provider<LocalNotificationService>.value(
          value: FakeLocalNotificationService(permissionGranted: true),
        ),
```

(`settings_dialog_test` + `localization_switch_test` đã vá ở Bài
3 Bước 6 — hai file đó pump `SettingsDialogScope`, không qua
`AppDependencyScope`.)

**Bước 6 — `flutter analyze` + `flutter test`** → **259/259**
(+0 — hosts là sửa-call-site, không test mới).

## Hiểu code — bốn chi tiết dễ trượt

1. **Vì sao KHÔNG conditional như Supabase.** `LocalNotification
   ServiceImpl` tự an toàn mọi platform (web có impl federated,
   `requestPermission` → `!kIsWeb`); Disabled-impl song song chỉ
   thêm lớp không ai dùng. Điều kiện DI chỉ đáng khi *thiếu impl
   an toàn* — dart-define điều khiển *cấu hình*, không phải
   *khả-năng-chạy*.
2. **`requestPermission` ở onboarding vs settings.** Cùng contract
   method, hai call-site khác nhau — onboarding truyền kết quả vào
   VM riêng của nó (`onNotificationPermissionResult`), settings
   đi qua `_toggleNotifications`/coordinator. Service không biết
   ai gọi — đúng ranh giới A-35.
3. **`catch` onboarding báo `reportError` thay vì snackbar.**
   Onboarding không có cơ chế snackbar riêng — lỗi hiếm (plugin
   chết) → log qua `FlutterError` để dev/CI thấy, user-flow coi
   như denied và đi tiếp. Không nuốt im lặng, không crash.
4. **`v$appVersion` gate `isNotEmpty`.** `loadSettings` lỗi →
   `_appVersion` giữ `''` → row không render — dialog vẫn dùng
   được (degrade), không hiện `v` cô đơn.

## Chạy và quan sát

```text
flutter analyze  → No issues found!
flutter test     → +259: All tests passed!
flutter build web → ✓  (impl plugin land trong scope — web safe)
```

Trên máy thật: mở settings → `v…` hiện cuối dialog; onboarding
"Bật thông báo" → OS prompt thật lần đầu — **nhưng** milestone
ghi `REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED`: không có device
để verify, fake counters đứng ra gánh (Bài 6 nói rõ thành phần).

## Thử nghiệm

Trong `main()`, đổi sang conditional kiểu Supabase:
`supabaseClient == null ? DisabledNotificationService() : Impl`
— được không? Cần thêm gì?

<details>
<summary>Đáp án</summary>

Được — nhưng phải *viết* `DisabledNotificationService` implements
contract (mọi method no-op/`return false`) vì senior không có.
Khác biệt: `!kIsWeb` đã xử lý web bên trong impl, nên Disabled-
impl chỉ đáng nếu bạn muốn "tắt notification khi thiếu config"
như Supabase — notification không có config nên không có gì để
điều kiện hoá. Bài học: conditional-DI giải *bài toán config*,
không phải *bài toán platform*.
</details>

## Lỗi hay gặp

1. **`await service.initialize()` trong `main()`** — thừa và chậm
   startup; service lazy-init (Bài 2).
2. **Quên update test hosts** — `required notificationService`
   trên `AppDependencyScope` compile-force bốn file test; analyzer
   đỏ ngay — đây là *tính năng* của required param, không phải bug.
3. **Gọi `requestPermission` hai call-site kiểu khác nhau** —
   nhớ: onboarding truyền kết quả vào `onNotificationPermission
   Result`, settings đi `_toggleNotifications`; đừng viết thêm
   logic trong widget.
4. **Hardcode `'v1.0.0'`** — `PackageInfo` đọc từ pubspec; chuỗi
   cứng sẽ sai ngay release kế.
5. **Tưởng `reportError` crash app** — nó *báo* lỗi cho framework
   (console/error widget trong debug); flow tiếp tục với `false`.

## Tự làm — PREDICT

`_loadAppVersion` throw (ví dụ `PackageInfo` lỗi trên platform
lạ): trace `loadSettings` — `_settings`, `_hasNotificationPermission`,
`_appVersion` mỗi cái giữ giá trị gì sau `catch`? `appVersion` row
hiện không?

<details>
<summary><strong>Đáp án</strong></summary>

`Future.wait` throw ngay khi `_loadAppVersion()` reject → `await`
thoát **trước** ba phép gán → `_settings` giữ giá trị seeded từ
ctor (stream.value), `_hasNotificationPermission` giữ `false`,
`_appVersion` giữ `''` → `isNotEmpty` false → **row v… không
hiện**; snackbar `loadFailed` bắn. `hasPermission()` *đã chạy*
song song (fire không hủy) nhưng kết quả bị bỏ cùng `wait`.
Ba-state-atomicity của `wait`: hoặc cả ba gán, hoặc không gán —
không có trạng thái nửa-vở.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao `LocalNotificationServiceImpl()` không theo
  `supabaseClient == null ? Disabled : Impl`? — **Đáp:** impl tự
  an toàn mọi platform (`!kIsWeb` + web impl federated); không có
  dart-define nào lái notification → conditional chỉ thêm lớp vô
  dụng (khác A-24: Supabase *không chạy được* khi thiếu config).
- **Hỏi:** onboarding request lỗi thì user thấy gì? — **Đáp:**
  không gì thêm — catch báo `FlutterError.reportError` (log cho
  dev) rồi `onNotificationPermissionResult(false)` → step coi như
  denied, overlay đi tiếp.
- **Hỏi:** `v…` row hiện khi nào? — **Đáp:** khi `loadSettings`
  thành công gán `_appVersion` khác `''` — `isNotEmpty` gate.
- **Hỏi:** test truyền version như thế nào? — **Đáp:** seam
  `loadAppVersion: () async => '9.9.9'` — `Future<String>
  Function()` thay `PackageInfo` thật (F-37).

## Ta cố ý chưa thêm

- `MenuDialogLayer` + `MenuDialogSettings` state — **M29**
  (transport `showDialog` giữ nguyên).
- `SettingsDialogShell`/`OnboardingGameButton`/icon-assets —
  **M28** (visual parity).
- Re-request permission có UI "mở Settings máy" khi denied lần 2
  — senior không có; chỉ snackbar.
- Version tap-to-copy/build-number — senior không có.
- iOS/macOS `hasPermission` check — senior chỉ wire Android.

## Checkpoint hoàn thành

- [ ] `main()` có `LocalNotificationServiceImpl()` vô điều kiện +
  comment M27 verbatim; `AppDependencyScope` field + `Provider
  <LocalNotificationService>.value`.
- [ ] Mở settings trên app thật không còn `ProviderNotFound` —
  khoảng hở Bài 3 đóng.
- [ ] `settings_dialog.dart` có `v$appVersion` row `isNotEmpty`-
  gated cuối card.
- [ ] `onboarding_overlay_scope.dart` `_requestNotificationPermission`
  verbatim — service → `requestPermission` → kết quả thật; catch
  → `reportError` + `false`.
- [ ] Năm host test vá xong: bốn `AppDependencyScope` host
  (`menu_provider_scope_test`, `menu_screen_ui_events_test`,
  `game_screen_test`, `menu_leaderboard_dialog_test`) truyền
  `notificationService:` fake; `onboarding_overlay_test` thêm
  `Provider<LocalNotificationService>.value`.
- [ ] `flutter analyze` sạch; `flutter test` **259/259**;
  `flutter build web` xanh.
