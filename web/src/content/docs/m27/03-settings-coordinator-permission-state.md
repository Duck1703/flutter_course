---
title: "Bài 3 · Coordinator + permission-as-state — bật thông báo thật"
description: "SettingsNotificationCoordinator verbatim — enable/disable/updateTime + `_saveSettingsWithRollback` giữ lỗi gốc. SettingsViewModel: `notificationService` + `_loadAppVersion` seam, `_hasNotificationPermission` là state OS-owned, `effectiveNotificationEnabled` = flag AND permission, `loadSettings` Future.wait×3, `_toggleNotifications` hai nhánh grant/deny, snackbar `notificationPermissionRequired`. +5 test qua fake counters → 259."
sidebar:
  label: "Bài 3 · coordinator + permission state"
  order: 3
---

## Mục tiêu

- Viết `SettingsNotificationCoordinator` verbatim senior —
  orchestration `enable`/`disable`/`updateTime` với rollback
 best-effort giữ nguyên lỗi gốc (CORE).
- Mở rộng `SettingsViewModel`: field `notificationService`
  (contract), seam `_loadAppVersion`, `_notificationCoordinator`
  tạo trong ctor.
- Hiểu **permission là state do OS sở hữu** (CORE):
  `_hasNotificationPermission` nạp từ `hasPermission()` mỗi lần
  `loadSettings`, cập nhật từ `requestPermission()` khi bật —
  `effectiveNotificationEnabled` = flag AND permission, không bao
  giờ assume.
- Viết `loadSettings` thành `Future.wait` ba việc song song
  (settings + permission + version) — một lỗi → snackbar
  `loadFailed`.
- Hai nhánh `_toggleNotifications`: denied → persist-off +
  snackbar `notificationPermissionRequired`; granted →
  `coordinator.enable`.
- `SettingsDialogScope` + `showSettingsDialog` nhận/đọc
  `LocalNotificationService` — `required` ctor param **compile-
  force** mọi call-site phải cung cấp service.
- +5 test mới (12 total trong file) — grant/deny/schedule-fail/
  reschedule/rollback đều qua fake counters → **259/259**.

## Bạn đang ở đâu

- Cuối Bài 2: service contract + impl + fake đã land, 254/254 —
  chưa ai gọi.
- `SettingsViewModel` hiện tại (M16): nhánh `SettingType.
  notifications` chỉ `_saveSettings(copyWith(notificationEnabled:
  !item.isEnabled))` — cùng path ba switch âm thanh.
- `SettingsDialogScope` ctor chỉ có `settingsRepository` +
  `profile`.

## Vì sao việc này quan trọng ngay bây giờ

Service của Bài 2 có ba "khách" cần gọi theo **thứ tự nghiệp vụ**,
không phải gọi bừa:

- Bật switch → xin quyền → granted → đặt lịch → lưu flag on.
- Tắt switch → huỷ lịch → lưu flag off.
- Đổi giờ → (đang bật?) đặt lại lịch giờ mới → lưu giờ mới.

Mỗi chuỗi có hai loại side-effect: **OS** (schedule/cancel — undo
được) và **persist** (save settings — cũng undo được nhưng đắt).
Nếu save xong rồi schedule hỏng → flag nói "bật" nhưng OS không
hẹn gì — *invariant hỏng âm thầm*. Senior tách chuỗi này ra một
**coordinator**: một class không state, nhận service + callback
`saveSettings`, chịu trách nhiệm thứ tự + hoàn tác. VM chỉ quyết
định *khi nào* gọi (permission branches), coordinator lo *gọi
theo thứ tự nào và lỗi thì dọn dẹp ra sao*.

## Bạn đã biết gì

- `SettingsViewModel` dialog-scoped: ctor seed từ
  `userSettingsStream.value`, `_saveSettings` → repo → subject →
 `_handleSettings` → notify (M16); events một lần
  `SettingsSnackBarRequested` + enum `SettingsSnackBarMessage`
 (M16).
- `buildSettingItems`/`localizedSettingItems` — factory nhận
  `effectiveNotificationEnabled` (M16 — sealed `SettingItemData`
 variant + switch kiệt hợp).
- Contract `LocalNotificationService` + `FakeLocalNotificationService`
 counters/`throwOn*` (Bài 2).
- `context.read<T>()` ở caller trước khi `showDialog` (M16 —
); dialog-scoped VM `ChangeNotifierProvider(create:)`
 (dạy ở M12, scope này áp dụng lại từ M16).

## Mental model mới

### — permission là state OS sở hữu (CORE)

```text
  persisted flag                OS permission
  (SharedPreferences)           (Settings hệ thống — app không
        │                        ghi được, chỉ đọc/xin)
        │                              │
        └────────── AND ───────────────┘
                     │
        effectiveNotificationEnabled  →  Switch.value
```

Ba quy tắc:

1. **Query, đừng assume** — `_hasNotificationPermission` không
   persist: nạp lại bằng `hasPermission()` mỗi `loadSettings` (user
   có thể thu hồi quyền trong Settings của OS lúc app đang tắt).
2. **Request chỉ khi cần** — bật switch và *chưa biết có quyền* →
   `requestPermission()`; OS trả `false` → persist-off + snackbar
   (không im lặng fail).
3. **AND-gate mọi nơi dùng** — `settingItems` và `updateTime`'s
   `shouldSchedule` đều qua `effectiveNotificationEnabled`: flag
   on mà permission mất → switch tự render tắt, không ai schedule.

### — coordinator orchestrate, rollback best-effort (CORE)

```text
 enable(settings):           disable(settings):          updateTime(prev, next, shouldSchedule):
   scheduleDaily(new)          cancelDaily()               if shouldSchedule: scheduleDaily(new)
   saveSettings(enabled)        saveSettings(off)          saveSettings(next)
        │ lỗi?                      │ lỗi?                      │ lỗi?
        └→ cancelDaily()            └→ restoreSchedule(prev)    └→ if shouldSchedule: restore(prev)
           rethrow lỗi GỐC             rethrow lỗi GỐC             rethrow lỗi GỐC
```

- **Schedule-TRƯỚC-save-SAU**: nếu schedule hỏng thì chưa persist
  gì → fail sạch; nếu save hỏng thì chỉ cần undo phía OS (cancel/
  restore) — mỗi hướng chỉ cần **một** rollback rẻ.
- **Best-effort**: rollback *cũng có thể lỗi* → bọc try/catch
  nuốt, `rethrow` **lỗi gốc** — snackbar phải nói "lưu settings
  lỗi" chứ không phải "rollback lỗi".

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `Future.wait([f1, f2, f3])` → `results[i]` | ba Future *độc lập* chạy song song, một lỗi → cả wait throw — **lần đầu trong codebase**, xây trên `Future`/`await` |
| `Future<void> Function(UserSettingsData)` typedef-param | coordinator nhận `saveSettings` làm **callback** — không biết repo, không biết VM (inversion nhỏ trong app) |
| `required` ctor param thêm vào class có sẵn | **compile-forced call-site update**: analyzer liệt kê mọi chỗ tạo `SettingsDialogScope`/`SettingsViewModel` — kể cả test |
| `rollback: notificationService.cancelDaily` | **tear-off** method làm callback — `cancelDaily` là `Future<void> Function()` hợp lệ |

## Flutter cần dùng

Không API Flutter mới — bài này toàn Dart + DI đã biết
(`context.read`, `ChangeNotifierProvider`). Thay đổi duy nhất ở
lớp widget: `_snackBarText` switch thêm arm `notificationPermission
Required` → l10n key mới.

## Ví dụ độc lập — rollback giữ lỗi gốc (DartPad)

```dart
// Mô phỏng _saveSettingsWithRollback — lỗi rollback KHÔNG che
// lỗi gốc.
Future<void> runWithRollback(Future<void> Function() op,
    Future<void> Function() rollback) async {
  try {
    await op();
  } catch (_) {
    try {
      await rollback();
    } catch (_) {
      // nuốt — best effort
    }
    rethrow; // lỗi GỐC, không phải lỗi rollback
  }
}

Future<void> failingSave() async =>
    throw StateError('disk full'); // lỗi gốc
Future<void> failingRollback() async =>
    throw StateError('network down'); // rollback cũng hỏng

void main() async {
  try {
    await runWithRollback(failingSave, failingRollback);
  } on StateError catch (e) {
    print(e.message); // 'disk full' — không phải 'network down'
  }
}
```

Nếu quên `rethrow` lỗi gốc (hoặc để lỗi rollback tràn ra), caller
thấy sai nguyên nhân — snackbar sẽ nói nhầm chuyện.

## Android / Compose bridge

**SIMILARITY — coordinator ≈ "transaction script" quanh hai
subsystem.** Giống `try { prefs.edit().commit(); workManager.
enqueue() } catch { rollback }` — một nơi chịu trách nhiệm thứ tự
SharedPreferences + WorkManager, caller chỉ nói "bật/tắt".

**IMPORTANT DIFFERENCE — rollback là *best-effort*, không
transactional.** Không có atomicity kiểu DB: notification đã
schedule rồi save hỏng → `cancelDaily` hoàn tác *có thể cũng hỏng*
→ nuốt và giữ lỗi gốc. Đừng kỳ vọng all-or-nothing.

**DO NOT ASSUME — permission không persist được.** `hasPermission`
hỏi OS mỗi lần `loadSettings` vì user thu hồi quyền trong system
Settings bất cứ lúc nào — lưu "đã granted" vào SharedPreferences
là stale ngay lập tức. (Tương đương `checkSelfPermission` mỗi
`onResume`, không phải flag một lần.)

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/view_models/settings/settings_notification_coordinator.dart` | port verbatim — `enable`/`disable`/`updateTime` + `_saveSettingsWithRollback` + `_restoreSchedule` |
| `lib/view_models/settings/settings_view_model.dart` | `_hasNotificationPermission`, `effectiveNotificationEnabled`, `_toggleNotifications`, `loadSettings` `Future.wait` — y hệt |
| `lib/view_models/settings/settings_ui_event.dart` — `notificationPermissionRequired` | enum member verbatim |
| `lib/widgets/menu/settings/menu_settings_dialog_scope.dart` | scope `context.read<LocalNotificationService>()` cùng điểm vào |
| `test/settings_view_model_test.dart` | 12 test cùng shape — grant/deny/fail/reschedule/rollback qua counters |

:::tip[Điểm dừng — suy ra trước khi port]
Trước khi mở ba bước verbatim, tự trả lời trên giấy:

1. **Ai sở hữu gì?** Ba nguồn — persisted flag (storage), OS
   permission (platform), coordinator (orchestrate) — đặt từng cái
   vào đúng chủ: cái nào VM *giữ*, cái nào VM *hỏi mỗi lần*, cái nào
   VM *không chạm*?
2. **Derived value.** `effectiveNotificationEnabled` = flag AND
   permission — nếu bạn thiết kế nó là hai field riêng cho UI tự AND,
   điều gì hỏng? (Gợi ý: mọi consumer phải nhớ AND — kể cả cái bạn
   chưa viết.)
3. **Rollback giữ cái gì?** Nếu `scheduleDaily` thành công nhưng
   `saveSettings` fail: giờ đã hẹn và flag trong storage lệch nhau —
   undo thứ nào trước, và lỗi nào lên snackbar?

Đối chiếu với các bước bên dưới — phần bạn đoán khác chính là chỗ
quyết định kiến trúc của senior.
:::

## Build it step by step

**Bước 1 — `lib/view_models/settings/settings_notification_
coordinator.dart`** (file mới — verbatim senior):

```dart
import '../../data/settings/user_settings_data.dart';
import '../../services/local_notification_service.dart';

class SettingsNotificationCoordinator {
  final LocalNotificationService notificationService;
  final Future<void> Function(UserSettingsData settings) saveSettings;

  const SettingsNotificationCoordinator({
    required this.notificationService,
    required this.saveSettings,
  });

  Future<void> enable(UserSettingsData settings) async {
    final enabledSettings = settings.copyWith(notificationEnabled: true);

    await notificationService.scheduleDaily(
      hour: enabledSettings.notificationHour,
      minute: enabledSettings.notificationMinute,
    );
    await _saveSettingsWithRollback(
      enabledSettings,
      rollback: notificationService.cancelDaily,
    );
  }

  Future<void> disable(UserSettingsData settings) async {
    await notificationService.cancelDaily();
    await _saveSettingsWithRollback(
      settings.copyWith(notificationEnabled: false),
      rollback: () => _restoreSchedule(settings),
    );
  }

  Future<void> updateTime({
    required UserSettingsData previousSettings,
    required UserSettingsData updatedSettings,
    required bool shouldSchedule,
  }) async {
    try {
      if (shouldSchedule) {
        await notificationService.scheduleDaily(
          hour: updatedSettings.notificationHour,
          minute: updatedSettings.notificationMinute,
        );
      }

      await saveSettings(updatedSettings);
    } catch (_) {
      if (shouldSchedule) await _restoreSchedule(previousSettings);

      rethrow;
    }
  }

  Future<void> _saveSettingsWithRollback(
    UserSettingsData settings, {
    required Future<void> Function() rollback,
  }) async {
    try {
      await saveSettings(settings);
    } catch (_) {
      try {
        await rollback();
      } catch (_) {
        // Best effort rollback; keep the original persistence failure.
      }

      rethrow;
    }
  }

  Future<void> _restoreSchedule(UserSettingsData settings) async {
    try {
      await notificationService.scheduleDaily(
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      );
    } catch (_) {
      return;
    }
  }
}
```

Coordinator **không state** — chỉ giữ hai dependency (service +
callback). `saveSettings` là callback VM truyền vào (`_saveSettings`
của VM — qua repo → subject → notify), nên coordinator không cần
biết repository tồn tại.

**Bước 2 — `settings_ui_event.dart`**: thêm enum member
verbatim:

```dart
enum SettingsSnackBarMessage {
  loadFailed,
  updateFailed,
  notificationTimeUpdateFailed,
  // M27: xin quyền thông báo bị từ chối.
  notificationPermissionRequired,
}
```

**Bước 3 — `settings_view_model.dart`**: sáu thay đổi verbatim.

(a) import + fields + ctor:

```dart
import '../../services/local_notification_service.dart';
import 'settings_app_version_loader.dart';
import 'settings_notification_coordinator.dart';
```

```dart
  /// Contract dịch vụ thông báo — M27 (senior field public cùng tên):
  /// VM chỉ biết interface `LocalNotificationService`, impl/plugin
  /// sống ở `main()`/DI. Test inject `FakeLocalNotificationService`.
  final LocalNotificationService notificationService;

  /// Seam nạp version — senior inject `Future<String> Function()?`
  /// mặc định [loadSettingsAppVersion] (`package_info_plus`); test
  /// truyền `() async => '9.9.9'`.
  final Future<String> Function() _loadAppVersion;

  /// M27 — senior `_notificationCoordinator`: orchestration
  /// enable/disable/updateTime + best-effort rollback notification
  /// khi save settings lỗi.
  late final SettingsNotificationCoordinator _notificationCoordinator;

  /// Quyền thông báo do OS nắm — M27: `hasPermission` nạp khi
  /// `loadSettings`, `requestPermission` cập nhật khi bật switch.
  var _hasNotificationPermission = false;

  /// `v…` text cuối dialog — nạp trong `loadSettings`; `''` trước khi
  /// nạp xong (senior: ẩn row khi rỗng).
  var _appVersion = '';
```

```dart
  SettingsViewModel({
    required UserSettingsRepository settingsRepository,
    required this.notificationService,
    Future<String> Function()? loadAppVersion,
  }) : _settingsRepository = settingsRepository,
       _loadAppVersion = loadAppVersion ?? loadSettingsAppVersion,
       _events = StreamController<SettingsUiEvent>.broadcast(),
       _settings = settingsRepository.userSettingsStream.value {
    _notificationCoordinator = SettingsNotificationCoordinator(
      notificationService: notificationService,
      saveSettings: _saveSettings,
    );
    _settingsSubscription = _settingsRepository.userSettingsStream.listen(
      _handleSettings,
    );
  }
```

Tear-off `_saveSettings` truyền làm callback — coordinator gọi nó
mà không biết nó là method của ai (coordinator độc lập VM).

(a-2) `lib/view_models/settings/settings_app_version_loader.dart`
(file mới — verbatim senior; VM import nó nên file phải tồn tại
ngay bây giờ — giải thích `package_info_plus` ở Bài 4):

```dart
import 'package:package_info_plus/package_info_plus.dart';

Future<String> loadSettingsAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}
```

(b) AND-gate + appVersion getter:

```dart
  String get appVersion => _appVersion;

  /// Senior AND flag với quyền OS: toggle "bật" chỉ
  /// thật sự bật khi permission granted; mất quyền → switch tự tắt.
  bool get effectiveNotificationEnabled =>
      _settings.notificationEnabled && _hasNotificationPermission;
```

(`settingItems`/`localizedSettingItems` đổi `effectiveNotificationEnabled:
effectiveNotificationEnabled` — flag đơn thành AND-gate.)

(c) `loadSettings` — `Future.wait` ba việc (verbatim):

```dart
  /// Senior `loadSettings` — `Future.wait` ba việc song song: settings
  /// từ disk, quyền thông báo hiện tại, app version. Một lỗi → cả
  /// `wait` throw → catch → snackbar `loadFailed`.
  Future<void> loadSettings() async {
    try {
      final results = await Future.wait<Object>([
        _settingsRepository.loadUserSettings(),
        notificationService.hasPermission(),
        _loadAppVersion(),
      ]);

      _settings = results[0] as UserSettingsData;
      _hasNotificationPermission = results[1] as bool;
      _appVersion = results[2] as String;
      _notifyIfOpen();
    } catch (_) {
      _emitSnackBar(SettingsSnackBarMessage.loadFailed);
    }
  }
```

(d) `toggleSetting` arm notifications → `_toggleNotifications`
(verbatim):

```dart
        case SettingType.notifications:
          await _toggleNotifications(item);
```

```dart
  /// Senior `_toggleNotifications`: tắt → coordinator.disable (cancel
  /// + persist-off w/ restore-on-fail); bật → xin quyền nếu chưa có,
  /// denied → persist-off + snackbar `notificationPermissionRequired`,
  /// granted → coordinator.enable (schedule + persist-on).
  Future<void> _toggleNotifications(SettingSwitchItemData item) async {
    final shouldEnable = !item.isEnabled;

    if (!shouldEnable) {
      await _notificationCoordinator.disable(_settings);
      return;
    }

    if (!_hasNotificationPermission) {
      _hasNotificationPermission = await notificationService
          .requestPermission();

      if (!_hasNotificationPermission) {
        await _saveSettings(_settings.copyWith(notificationEnabled: false));
        _emitSnackBar(SettingsSnackBarMessage.notificationPermissionRequired);
        _notifyIfOpen();
        return;
      }
    }

    await _notificationCoordinator.enable(_settings);
  }
```

(e) `onNotificationTimeSelected` → coordinator (verbatim):

```dart
  /// Chọn xong giờ → senior: `coordinator.updateTime` (reschedule nếu
  /// notifications đang effective rồi mới persist; lỗi → restore lịch
  /// cũ + snackbar).
  Future<void> onNotificationTimeSelected(int hour, int minute) async {
    _timePickerVisible = false;
    notifyListeners();

    final previousSettings = _settings;
    final updatedSettings = previousSettings.copyWith(
      notificationHour: hour,
      notificationMinute: minute,
    );

    try {
      await _notificationCoordinator.updateTime(
        previousSettings: previousSettings,
        updatedSettings: updatedSettings,
        shouldSchedule: effectiveNotificationEnabled,
      );
    } catch (_) {
      _emitSnackBar(SettingsSnackBarMessage.notificationTimeUpdateFailed);
    }
  }
```

**Bước 4 — `settings_dialog.dart`**: `showSettingsDialog` đọc
service từ app-scope, scope ctor nhận + truyền (verbatim):

```dart
final notificationService = context.read<LocalNotificationService>();
return showDialog<void>(
  context: context,
  builder: (_) => SettingsDialogScope(
    settingsRepository: settingsRepository,
    notificationService: notificationService,
    profile: profileRepository.userProfileStream.value,
  ),
);
```

```dart
class SettingsDialogScope extends StatelessWidget {
  final UserSettingsRepository settingsRepository;

  /// M27: service thông báo — truyền vào VM để xin quyền + hẹn/huỷ
  /// daily reminder (senior scope `context.read` ở cùng điểm này).
  final LocalNotificationService notificationService;
  ...
  create: (_) => SettingsViewModel(
    settingsRepository: settingsRepository,
    notificationService: notificationService,
  ),
```

và `_snackBarText` thêm arm (switch kiệt hợp bắt buộc):

```dart
      SettingsSnackBarMessage.notificationPermissionRequired =>
        l10n.settingsNotificationPermissionRequiredMessage,
```

kèm ARB key mới — en `"Notification permission required"`, vi
`"Cần cấp quyền thông báo"`.

:::caution[Hai lỗi compile-forced + một khoảng hở runtime cố ý]
`required this.notificationService` làm **hai test file ngừng
compile** — `settings_dialog_test.dart` và `localization_switch_
test.dart` pump `SettingsDialogScope` trực tiếp mà chưa truyền
param; Bước 6 dưới vá ngay trong bài này. Còn một khoảng hở
**runtime**: mở settings trên app thật lúc này sẽ
`ProviderNotFoundException: LocalNotificationService` —
`context.read` hỏi provider chưa đăng ký. Đây chính là tín hiệu
"DI còn thiếu" — **Bài 4 vá** bằng `Provider<Local
NotificationService>.value` ở app-scope.
:::

**Bước 5 — `test/settings_view_model_test.dart`**: helper nhận
fake + seam, năm test mới (verbatim shape senior):

```dart
    late FakeLocalNotificationService notificationService;

    setUp(() {
      notificationService = FakeLocalNotificationService();
    });

    SettingsViewModel createViewModel(
      FakeUserSettingsRepository repo, {
      Future<String> Function()? loadAppVersion,
    }) {
      final vm = SettingsViewModel(
        settingsRepository: repo,
        notificationService: notificationService,
        loadAppVersion: loadAppVersion ?? () async => '9.9.9',
      );
      addTearDown(vm.dispose);
      return vm;
    }

    SettingSwitchItemData notificationSwitch(SettingsViewModel vm) =>
        vm.settingItems.whereType<SettingSwitchItemData>().singleWhere(
          (item) => item.settingType == SettingType.notifications,
        );
```

Hai test chốt (verbatim — ba test còn lại đọc trong file):

```dart
    test(
      'bật notifications → xin quyền + schedule daily + hàng giờ hiện',
      () async {
        notificationService.requestResult = true;
        ...
        await vm.toggleSetting(notificationSwitch(vm));

        expect(notificationService.requestCount, 1);
        expect(notificationService.scheduleCount, 1);
        expect(notificationService.lastHour, 20);
        expect(notificationService.lastMinute, 0);
        expect(repo.value.notificationEnabled, isTrue);
        ...
      },
    );

    test('quyền bị từ chối → switch vẫn tắt + snackbar permission', () async {
      notificationService.requestResult = false;
      ...
      await vm.toggleSetting(notificationSwitch(vm));
      await pumpEventQueue();

      expect(notificationService.requestCount, 1);
      expect(notificationService.scheduleCount, 0);
      expect(repo.value.notificationEnabled, isFalse);
      expect(snackBars, [
        SettingsSnackBarMessage.notificationPermissionRequired,
      ]);
    });
```

Danh sách 12 test của file sau bài này: ctor seed · **loadSettings
nạp defaults + appVersion qua seam** · toggleSetting sound ·
**bật → xin quyền + schedule** · **denied → off + snackbar** ·
**tắt → cancel + persist-off** · **schedule lỗi → off +
updateFailed** · onNotificationTimeSelected **+ reschedule** ·
**schedule lỗi khi đổi giờ → giữ giờ cũ** · selectLanguage ·
dismiss event · loadFailed (đậm = mới/mở rộng ở M27; `loadFailed`
đã có từ M16).

**Bước 6 — hai test host compile-forced**: `required
notificationService` bắt hai file pump scope trực tiếp phải
truyền fake:

```dart
// test/widgets/settings_dialog_test.dart — _dialogHost
      notificationService: FakeLocalNotificationService(
        permissionGranted: true,   // quyền cấp sẵn → switch bật được
      ),

// test/localization_switch_test.dart — SettingsDialogScope home
      notificationService: FakeLocalNotificationService(),
```

`settings_dialog_test.dart` còn một chỗ nữa: test gọi
`showSettingsDialog` thật (hàm này giờ `context.read<
LocalNotificationService>()`) — host của nó cần
`Provider<LocalNotificationService>.value` trong `MultiProvider`,
ngay cả khi app-scope chưa đăng ký:

```dart
        Provider<LocalNotificationService>.value(
          value: FakeLocalNotificationService(),
        ),
```

(fake này không cần `permissionGranted: true` — test chỉ cần
entry-point chạy được, không bật switch.)

**Bước 7 — `flutter analyze` + `flutter test`** → **259/259**.

## Hiểu code — năm chi tiết dễ trượt

1. **Vì sao schedule-TRƯỚC-save-SAU trong `enable`.** Nếu save
   trước rồi schedule hỏng: flag đã on, notification không tồn tại
   → phải rollback *phía persist* (đắt + có thể hỏng nốt). Đảo
   lại: schedule hỏng → chưa persist gì → **fail sạch**; chỉ save
   hỏng mới cần rollback, và rollback chỉ là `cancelDaily` (rẻ).
   Thứ tự được chọn để *đường rollback rẻ nhất*.
2. **`rethrow` trong catch của rollback-path.** `_saveSettingsWith
   Rollback` nuốt lỗi rollback *nhưng* `rethrow` lỗi gốc — VM
   `catch` nhận đúng "save lỗi" → snackbar `updateFailed`. Nếu
   rollback throw tràn ra, user thấy thông điệp sai nguyên nhân.
3. **`_hasNotificationPermission` không nằm trong
   `UserSettingsData`.** Flag `notificationEnabled` là *ý định
   user* (persist); permission là *sự thật OS* (query). Gộp hai
   thứ vào một field persist = stale ngay khi user đổi quyền ở
   Settings máy.
4. **Denied path gọi `_saveSettings(false)` *trước* snackbar.**
   Đảm bảo flag off persist kể cả khi user kill app ngay sau —
   không để flag-on mà OS-denied tồn tại qua restart.
5. **`updateTime`'s `shouldSchedule` đọc `effectiveNotificationEnabled`
   *trước* khi gọi coordinator.** Flag on nhưng permission mất →
   không schedule — chỉ persist giờ mới cho lần bật sau.

## Chạy và quan sát

```text
flutter analyze  → No issues found!
flutter test     → +259: All tests passed!  (254 + 5)
```

Trên app thật: **đừng** mở settings lúc này — `ProviderNotFound`
(app-scope chưa đăng ký provider). Suite xanh vì các host đã được
vá ở Bước 6 — kể cả test đi qua `showSettingsDialog` thật (nhờ
`Provider.value` cục bộ trong chính host).

## Thử nghiệm

Đặt `notificationService.requestResult = false` trong test nhưng
*quên* `await vm.loadSettings()` trước `toggleSetting` — đoán
`requestCount` và `scheduleCount`.

<details>
<summary>Đáp án</summary>

`requestCount` vẫn **1**, `scheduleCount` **0** — nhưng vì lý do
khác: `_hasNotificationPermission` khởi tạo `false` (không qua
`hasPermission`) → nhánh request chạy → denied → persist-off.
Kết quả counters trùng ý định test, nhưng test này không còn kiểm
đường "đã loadSettings rồi mới toggle" — bỏ `loadSettings` làm
test *đi qua nhánh khác* mà vẫn xanh (false confidence).
</details>

## Lỗi hay gặp

1. **Lưu permission vào settings persist** — stale ngay khi user
   thu hồi quyền ở system Settings; luôn query lại (`hasPermission`
   trong `loadSettings`).
2. **Quên `rethrow` sau rollback** — nuốt luôn lỗi gốc → VM không
   `catch` được → không snackbar, user tưởng thành công.
3. **Cho `updateTime` schedule khi flag-off** — user đổi giờ lúc
   đang tắt phải *chỉ persist* (giờ dùng cho lần bật sau);
   `shouldSchedule` gate bằng `effectiveNotificationEnabled`.
4. **`effectiveNotificationEnabled` quên AND permission** — flag
   on + OS-denied → switch hiện on nhưng không notification nào
   hẹn — đúng bug senior ngăn bằng AND-gate.
5. **Gọi `coordinator.enable` trước khi biết permission** — denied
   mà vẫn `zonedSchedule` là vô nghĩa; nhánh request phải đứng
   trước coordinator.

## Tự làm — DEBUG

Đảo thứ tự trong `coordinator.enable`: gọi `_saveSettingsWith
Rollback(enabledSettings, rollback: notificationService.cancelDaily)`
**trước**, rồi `scheduleDaily` **sau**. Không đổi gì khác. Chạy
`flutter test test/settings_view_model_test.dart` và trả lời: test
nào đỏ, expect nhận gì? Invariant nào hỏng nếu test đó không tồn
tại?

<details>
<summary><strong>Đáp án</strong></summary>

Test **`'schedule lỗi → settings vẫn off + snackbar updateFailed'`**
đỏ: `expect(repo.value.notificationEnabled, isFalse)` nhận `true`.

Vì sao: với thứ tự đảo, `saveSettings` chạy trước → flag on đã
persist; `scheduleDaily` (throwOnSchedule) throw *sau* → propagate
ra `toggleSetting` catch → `updateFailed` vẫn bắn đúng — nhưng
`repo.value.notificationEnabled` đã là `true`. `_saveSettingsWith
Rollback` không cứu được vì nó chỉ bọc *save*, còn save thì đã
thành công.

Invariant hỏng: **flag on nhưng không có notification nào được
hẹn** — user thấy "thông báo bật" trong settings nhưng OS không
biết gì. Chính là lý do senior chọn schedule trước: đường hỏng
duy nhất cần rollback là save, và rollback của nó (`cancelDaily`)
rẻ.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** `effectiveNotificationEnabled` khác
  `_settings.notificationEnabled` ở đâu? — **Đáp:** flag là ý định
  persist; effective = flag AND `_hasNotificationPermission` —
  quyền OS mất thì switch render tắt dù flag còn on.
- **Hỏi:** vì sao `loadSettings` dùng `Future.wait` chứ không
  await tuần tự? — **Đáp:** ba việc độc lập (disk / OS permission /
  PackageInfo) — song song nhanh hơn và *một lỗi throw cả nhóm*
  khớp chính sách "load hỏng → loadFailed".
- **Hỏi:** `_toggleNotifications` denied-path làm theo thứ tự gì?
  — **Đáp:** `_saveSettings(false)` trước → `_emitSnackBar(
  notificationPermissionRequired)` → `_notifyIfOpen()` → return —
  persist-off đảm bảo flag không nói dối permission.
- **Hỏi:** coordinator biết repo/VM không? — **Đáp:** không —
  nó giữ `LocalNotificationService` + callback `saveSettings`
  (tear-off `_saveSettings` của VM). Testable độc lập, không biết
  stream/notify tồn tại.

## Ta cố ý chưa thêm

- `Provider<LocalNotificationService>.value` trong
  `AppDependencyScope` + `LocalNotificationServiceImpl()` trong
  `main()` — **Bài 4** (đọc kỹ warning khoảng hở runtime ở Bước 4).
- `v$appVersion` row trong dialog + giải thích `package_info_plus`
  — **Bài 4** (file loader đã land ở đây vì VM import nó; row UI +
 giải thích ở Bài 4).
- Onboarding `_requestNotificationPermission` gọi thật —
  **Bài 4**.
- iOS `hasPermission` check — senior không wire; giữ verbatim.
- Notification tap → deep-link — senior không có handler.

## Checkpoint hoàn thành

- [ ] `settings_notification_coordinator.dart` verbatim: `enable`
  schedule trước save sau, `disable` cancel trước persist sau,
  `updateTime` conditional-reschedule, `_saveSettingsWithRollback`
  giữ lỗi gốc.
- [ ] VM có `notificationService` + `_loadAppVersion` seam +
  `_notificationCoordinator` trong ctor; `effectiveNotificationEnabled`
  = flag AND permission; `loadSettings` là `Future.wait` ba việc.
- [ ] `_toggleNotifications`: disable→coordinator; enable→request
  nếu chưa có quyền → denied persist-off+snackbar, granted→enable.
- [ ] `SettingsDialogScope`/`showSettingsDialog` truyền service;
  enum + `_snackBarText` có arm `notificationPermissionRequired`;
  ARB key cả en/vi.
- [ ] Hai test host (`settings_dialog_test`,
  `localization_switch_test`) truyền `notificationService:` fake;
  `settings_dialog_test` thêm `Provider<…>.value` cho test gọi
  `showSettingsDialog` thật.
- [ ] `flutter analyze` sạch; `flutter test` **259/259** (+5).
- [ ] Hiểu và chấp nhận khoảng hở: mở settings trên app thật lúc
  này → `ProviderNotFoundException` — Bài 4 vá.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m27/03 — "Coordinator + permission-as-state — bật thông báo thật" (SettingsNotificationCoordinator verbatim — enable/disable/updateTime + _saveSettingsWithRollback giữ lỗi gốc; SettingsViewModel + notificationService + _loadAppVersion seam + _hasNotificationPermission OS-owned + effectiveNotificationEnabled AND-gate + loadSettings Future.wait×3 + _toggleNotifications hai nhánh + snackbar notificationPermissionRequired; SettingsDialogScope + showSettingsDialog required notificationService compile-force; +5 test → 259).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Khoảng hở runtime `ProviderNotFoundException` là CỐ Ý của bài này — DI vá ở BÀI 4; báo nó là GAP chỉ khi reviewer mở app thật thấy crash VÀ checkpoint Bài 4 chưa học.

EXPECTED STATE SAU BÀI NÀY:
- `lib/view_models/settings/settings_notification_coordinator.dart` (FILE MỚI, STRICT verbatim): `class SettingsNotificationCoordinator` — `final LocalNotificationService notificationService` + `final Future<void> Function(UserSettingsData) saveSettings` + `const` ctor (STRICT KHÔNG state — chỉ 2 deps; coordinator không import repository/VM); `enable(settings)` — `copyWith(notificationEnabled: true)` + `await notificationService.scheduleDaily(hour: enabledSettings.notificationHour, minute: enabledSettings.notificationMinute)` TRƯỚC + `_saveSettingsWithRollback(enabledSettings, rollback: notificationService.cancelDaily)` SAU (STRICT schedule-trước-save-sau — đảo thứ tự = DIVERGED: save-fail để lại flag-on không notification); `disable(settings)` — `cancelDaily()` + `_saveSettingsWithRollback(settings.copyWith(notificationEnabled: false), rollback: () => _restoreSchedule(settings))`; `updateTime({previousSettings, updatedSettings, shouldSchedule})` — try: `shouldSchedule → scheduleDaily(new)` + `saveSettings(updatedSettings)`; catch: `shouldSchedule → _restoreSchedule(previousSettings)` + `rethrow`; `_saveSettingsWithRollback(settings, {required rollback})` — try saveSettings → catch → try `await rollback()` catch nuốt + `rethrow` (STRICT lỗi GỐC rethrow, rollback best-effort nuốt — lỗi rollback tràn ra hoặc nuốt lỗi gốc = DIVERGED); `_restoreSchedule(settings)` — try scheduleDaily(settings.hour/minute) catch → return.
- `lib/view_models/settings/settings_app_version_loader.dart` (FILE MỚI, STRICT): `import 'package:package_info_plus/package_info_plus.dart';` + `Future<String> loadSettingsAppVersion() async { final packageInfo = await PackageInfo.fromPlatform(); return packageInfo.version; }`.
- `lib/view_models/settings/settings_ui_event.dart` (STRICT): enum `SettingsSnackBarMessage` có `notificationPermissionRequired` member mới (giữ 3 cũ: loadFailed, updateFailed, notificationTimeUpdateFailed).
- `lib/view_models/settings/settings_view_model.dart` (STRICT 6 thay đổi): imports `../../services/local_notification_service.dart` + `settings_app_version_loader.dart` + `settings_notification_coordinator.dart`; field `final LocalNotificationService notificationService` PUBLIC cùng tên + `final Future<String> Function() _loadAppVersion` + `late final SettingsNotificationCoordinator _notificationCoordinator` + `var _hasNotificationPermission = false` + `var _appVersion = ''`; ctor `SettingsViewModel({required UserSettingsRepository settingsRepository, required this.notificationService, Future<String> Function()? loadAppVersion}) : _settingsRepository = …, _loadAppVersion = loadAppVersion ?? loadSettingsAppVersion, …` + body `_notificationCoordinator = SettingsNotificationCoordinator(notificationService: notificationService, saveSettings: _saveSettings)` (STRICT tear-off `_saveSettings` làm callback — coordinator độc lập); `String get appVersion => _appVersion`; `bool get effectiveNotificationEnabled => _settings.notificationEnabled && _hasNotificationPermission` (STRICT AND-gate — mất permission → switch tự tắt; `settingItems`/`localizedSettingItems` truyền `effectiveNotificationEnabled: effectiveNotificationEnabled`); `loadSettings()` — `final results = await Future.wait<Object>([_settingsRepository.loadUserSettings(), notificationService.hasPermission(), _loadAppVersion()])` + `_settings = results[0] as UserSettingsData` + `_hasNotificationPermission = results[1] as bool` + `_appVersion = results[2] as String` + `_notifyIfOpen()`; catch → `_emitSnackBar(loadFailed)` (STRICT Future.wait×3 — tuần tự 3 await = DIVERGED; một lỗi → cả wait throw trước gán → 3 state giữ giá trị cũ); `toggleSetting` arm `SettingType.notifications` → `await _toggleNotifications(item)`; `_toggleNotifications(SettingSwitchItemData item)` — `!shouldEnable → coordinator.disable(_settings) return`; `_hasNotificationPermission = await notificationService.requestPermission()` → false → `_saveSettings(_settings.copyWith(notificationEnabled: false))` + `_emitSnackBar(notificationPermissionRequired)` + `_notifyIfOpen()` + return; granted → `coordinator.enable(_settings)` (STRICT 3 nhánh: disable / denied-persist-off+snackbar / enable); `onNotificationTimeSelected` — `_timePickerVisible = false` + `previousSettings`/`updatedSettings` + try `coordinator.updateTime(previousSettings:, updatedSettings:, shouldSchedule: effectiveNotificationEnabled)` catch → `_emitSnackBar(notificationTimeUpdateFailed)`.
- `lib/widgets/menu/settings/settings_dialog.dart` (STRICT): `showSettingsDialog` — `final notificationService = context.read<LocalNotificationService>();` + `SettingsDialogScope(settingsRepository:, notificationService: notificationService, profile:)`; `SettingsDialogScope` field `final LocalNotificationService notificationService` + `required` + create `SettingsViewModel(settingsRepository:, notificationService: notificationService)`; `_snackBarText` thêm arm `notificationPermissionRequired => l10n.settingsNotificationPermissionRequiredMessage`; ARB key `settingsNotificationPermissionRequiredMessage` en "Notification permission required" / vi "Cần cấp quyền thông báo".
- `test/settings_view_model_test.dart` — **12 test tổng** (STRICT: 7 cũ M16 + 5 mới grant/deny/schedule-fail/reschedule/rollback qua `FakeLocalNotificationService` counters — không test nào import plugin); `test/settings_dialog_test.dart` + `test/localization_switch_test.dart` truyền `notificationService: FakeLocalNotificationService()` vào `SettingsDialogScope` (compile-forced vá).
- `flutter analyze` sạch; `flutter test` → **259/259** (STRICT 254 + 5). `SettingsViewModel(` call-site thiếu `notificationService` = compile đỏ = BLOCKED.
- KHÔNG ĐƯỢC có (chưa đến): `Provider<LocalNotificationService>.value` trong `AppDependencyScope` + `LocalNotificationServiceImpl()` trong `main()` (BÀI 4 — thiếu nghĩa là app thật mở settings crash `ProviderNotFoundException` — khoảng hở cố ý Bài 3); `v$appVersion` row trong settings card (BÀI 4); `_requestNotificationPermission` onboarding scope (BÀI 4 — scope vẫn `onNotificationPermissionResult(true)` simulated); `GameShareRequested`/`GameShareResult`/`GameShareResultEvent`/`shareResult`/`_DialogShareButton`/SharePlus/Clipboard (BÀI 5); `_hasNotificationPermission` persist vào SharedPreferences/UserSettingsData (DIVERGED — OS-owned, query mỗi lần); `requestPermission` gọi bừa khi đã granted; coordinator import plugin/`FlutterLocalNotificationsPlugin` (coordinator chỉ biết contract — DIVERGED ranh giới); UI tự AND `notificationEnabled && permission` ngoài `effectiveNotificationEnabled` (DIVERGED derived-value split).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- Bài 1–2: 5 pin + manifest + service verbatim + fake; M26 đỉnh (DRE — SettingsViewModel VẪN `extends ChangeNotifier` dialog-scoped, KHÔNG DRE — DIVERGED nếu DRE hoá); `_saveSettings` → repo → subject → `_handleSettings` → notify (M16 đường giữ); sealed `SettingItemData` family + `buildSettingItems`/`localizedSettingItems`; M14 repos; M23 conditional DI Supabase (notification KHÔNG conditional — BÀI 4 giải thích).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. `AppDependencyScope` thiếu provider sau Bài 3 là EXPECTED — đánh dấu AHEAD của Bài 4 thôi.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m27/03
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
