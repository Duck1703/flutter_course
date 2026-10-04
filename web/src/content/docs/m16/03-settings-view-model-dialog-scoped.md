---
title: "Bài 3 · SettingsViewModel — VM sinh và chết cùng dialog"
description: "CORE: dialog-scoped ViewModel — ChangeNotifierProvider nằm TRONG subtree của dialog, VM chỉ sống khi dialog mở; sealed SettingsUiEvent + toggleSetting/selectLanguage/showTimePicker."
sidebar:
  label: "Bài 3 · SettingsViewModel"
  order: 3
---

## Mục tiêu

Sau bài này bạn **làm được**:

- Giải thích "scope = lifetime": `ChangeNotifierProvider(create:)`
  đặt **bên trong** dialog builder → VM được tạo khi dialog mở và bị
  `dispose()` khi dialog đóng — đúng senior `MenuSettingsDialogScope`.
- Viết `SettingsViewModel extends ChangeNotifier`: seed từ
  `userSettingsStream.value`, subscribe stream, `toggleSetting` bằng
  `switch` kiệt hợp trên `SettingType`, broadcast `events`.
- Nói được khi nào state nên sống ở app-scope (repository) vs
  screen-scope (MenuViewModel) vs **dialog-scope** (SettingsViewModel).

## Bạn đang ở đâu

- M16 bài 3/5 — bài CORE của milestone. Bài 2 đã có
  `SettingItemData` + factory; bài này viết **chủ sở hữu state** của
  dialog: `SettingsViewModel`.
- `MenuViewModel` (M12) sống ở screen-scope: Provider trên `MenuScreen`.
  Settings dialog cần VM *khác* — vì vòng đời nó khác hẳn.

## Vì sao việc này quan trọng ngay bây giờ

Hỏi thật: trạng thái "đang mở picker giờ" (`timePickerVisible`) nên sống
ở đâu?

- **Trong `_SettingsDialogState` bằng `setState`?** → VM không test
  được ngoài widget; logic persist trộn vào UI — quay về M11.
- **Trong `MenuViewModel`?** → MenuViewModel (VM của CẢ menu) phải biết
  "settings đang mở picker" — state của dialog rò lên screen; mở/đóng
  dialog không tự dọn rác, phải nhớ reset tay.
- **Trong repo?** → đây là UI-state thoáng qua, không phải dữ kiện
  persist — repo chỉ chứa `UserSettingsData`.

Senior trả lời: **dialog-scope** — một `SettingsViewModel` riêng, tạo
bởi `ChangeNotifierProvider` bên trong scope dialog, dispose khi đóng.
Lợi ích: state phát sinh trong dialog chết cùng dialog; `MenuViewModel`
sạch; VM test được như unit thường.

## Bạn đã biết gì

- `ChangeNotifier`/`notifyListeners` (M11) — VM phát tín hiệu.
- `ChangeNotifierProvider` create/auto-dispose (M12) — Provider
  tạo VM **và** dispose khi bị tháo khỏi cây.
- `context.read` vs `context.watch` (M12) — callback vs rebuild.
- Event bridge 3 khâu (M13/14): attach ở `didChangeDependencies`,
  guard `==`, cancel ở `dispose` — bài này lặp lại nguyên mẫu trong
  dialog.
- Stream `events` broadcast + sealed event (M13–M15).
- Repository stream + `.value` seed (M14/03–06).

## Mental model mới — "scope = lifetime"

```
AppDependencyScope (MultiProvider)     ← sống suốt app: repositories
  └─ MenuScreen
       ├─ ChangeNotifierProvider<MenuViewModel>   ← sống cùng MÀN menu
       │     └─ ...
       └─ (bấm gear) → showDialog route
             └─ SettingsDialogScope
                  └─ ChangeNotifierProvider<SettingsViewModel>
                        ← SINH khi dialog mở, CHẾT khi dialog pop
```

Ba tầng sống: **app** (repos) > **screen** (MenuViewModel) >
**dialog** (SettingsViewModel). Chọn tầng = trả lời "state này cần
sống bao lâu?" Picker-visibility chỉ cần sống đúng một phiên dialog →
tầng dialog là đúng — không hơn, không kém.

**Giới hạn:** VM dialog chỉ thấy được những gì truyền vào — nó không
tự `context.read` lên app-scope (và không nên: giữ dialog
self-contained, pump được standalone trong test). Chính xác hơn:
`AppDependencyScope` của app nằm **trên** `MaterialApp` nên trên cả
Navigator — context trong dialog route *có thể* `read` repo app-scope
được; thứ **không** với tới là provider nằm **dưới** Navigator (ví dụ
provider của `MenuViewModel` bên trong `MenuScreen`). Truyền instance
từ caller giữ scope rõ ràng và độc lập với thứ tự provider phía trên.

## Dart cần dùng / Flutter cần dùng

| Cú pháp | Ví dụ | Nghĩa |
| --- | --- | --- |
| `StreamController<T>.broadcast()` | `_events = StreamController.broadcast()` | event một-lần: listener đến trễ không nhận lại |
| `late final` | `late final StreamSubscription _settingsSubscription;` | first-use: khai báo trước, gán sau — bắt buộc vì subscription chỉ tạo được *trong thân* ctor (sau khi field khác sẵn sàng) |
| `unawaited(future)` | `unawaited(viewModel.loadSettings())` | "cố ý không chờ" — bỏ lint dangling future |
| `ChangeNotifierProvider(create:)` trong dialog subtree | bên dưới | Provider tạo+dispose VM theo vòng đời subtree |
| `context.read` ở caller context | `context.read<UserSettingsRepository>()` | lấy repo TRƯỚC khi vào dialog route |

## Ví dụ độc lập — chứng minh scope = lifetime

```dart
// Một counter-VM tầm thường:
class CounterVm extends ChangeNotifier {
  var count = 0;
  void inc() { count++; notifyListeners(); }
}

// Mở dialog chứa provider RIÊNG:
showDialog(
  context: context,
  builder: (_) => ChangeNotifierProvider(
    create: (_) => CounterVm(),   // sinh lúc dialog mở
    child: const CounterBody(),
  ),
);
```

Bấm tăng 3 lần → đóng → mở lại → `count` = 0. **VM bị dispose cùng
dialog** — đó chính là "scope = lifetime" mà không cần viết
`dispose` tay. Đặt provider ở `MaterialApp` thay vào: count sống mãi.
Cùng một VM, hai lifetime khác nhau — chỉ đổi *chỗ đặt provider*.

## Android / Compose bridge

- **SIMILARITY:** rất giống "ViewModel scoped to a NavBackStackEntry"
  — VM của dialog/destination chết khi destination pop.
- **IMPORTANT DIFFERENCE:** ở đây scope là *widget subtree*, không gắn
  với hệ navigation — `showDialog` route vẫn là route, nhưng VM sống
  theo provider trong builder, không theo route registry.
- **DO NOT ASSUME:** "ViewModel màn hình" không tự động đúng — một màn
  có thể nuôi NHIỀU scope VM lồng nhau.

## Senior project connection

- `lib/view_models/settings/settings_view_model.dart` — VM senior:
  ctor seed `_settings = settingsRepository.userSettingsStream.value`
  rồi `listen`; `toggleSetting` = switch kiệt hợp trên `SettingType`;
  `selectLanguage` bỏ qua nếu trùng mã; `saveSettings()` chỉ *phát
  event* `SettingsDismissRequested` — VM không `Navigator.pop` (không
  có context).
- `lib/widgets/menu/settings/menu_settings_dialog_scope.dart` —
  `MenuSettingsDialogScope`: `ChangeNotifierProvider<SettingsViewModel>`
  nằm trong scope dialog; `_SettingsDialogEventBridge` attach ở
  `didChangeDependencies` + cờ `_didLoadSettings` gọi `loadSettings()`
  đúng một lần.
- `lib/view_models/settings/settings_ui_event.dart` — sealed
  `SettingsUiEvent` {`SettingsDismissRequested`,
  `SettingsSnackBarRequested(SettingsSnackBarMessage)`}.

## Build it step by step

**Bước 1 — `lib/view_models/settings/settings_ui_event.dart`:**

```dart
/// Event một-lần của settings dialog — sealed để switch kiệt hợp
/// (M15). Senior có thêm `notificationPermissionRequired` — chưa cần
/// vì quyền thông báo là M27.
sealed class SettingsUiEvent {
  const SettingsUiEvent();
}

final class SettingsDismissRequested extends SettingsUiEvent {
  const SettingsDismissRequested();
}

final class SettingsSnackBarRequested extends SettingsUiEvent {
  final SettingsSnackBarMessage message;
  const SettingsSnackBarRequested(this.message);
}

enum SettingsSnackBarMessage {
  loadFailed,
  updateFailed,
  notificationTimeUpdateFailed,
}
```

**Bước 2 — `lib/view_models/settings/settings_view_model.dart`**
(khung quan trọng nhất):

```dart
class SettingsViewModel extends ChangeNotifier {
  final UserSettingsRepository _settingsRepository;
  final StreamController<SettingsUiEvent> _events;
  late final StreamSubscription<UserSettingsData> _settingsSubscription;

  UserSettingsData _settings;
  var _timePickerVisible = false;
  var _timePickerHour = UserSettingsData.defaultNotificationHour;
  var _timePickerMinute = UserSettingsData.defaultNotificationMinute;
  var _isDisposed = false;

  SettingsViewModel({required UserSettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      _events = StreamController<SettingsUiEvent>.broadcast(),
      // SEED từ snapshot hiện tại — subscriber tới sau vẫn có giá trị
      _settings = settingsRepository.userSettingsStream.value {
    _settingsSubscription =
        _settingsRepository.userSettingsStream.listen(_handleSettings);
  }

  List<SettingItemData> get settingItems => buildSettingItems(
    settings: _settings,
    effectiveNotificationEnabled: effectiveNotificationEnabled,
  );

  /// M27: senior = `notificationEnabled && hasPermission`.
  bool get effectiveNotificationEnabled => _settings.notificationEnabled;
```

Rồi các hành vi — đọc kỹ **thứ tự**:

```dart
  Future<void> toggleSetting(SettingSwitchItemData item) async {
    try {
      switch (item.settingType) {
        case SettingType.sound:
          await _saveSettings(
            _settings.copyWith(soundEnabled: !item.isEnabled));
        case SettingType.music:
          await _saveSettings(
            _settings.copyWith(musicEnabled: !item.isEnabled));
        case SettingType.haptic:
          await _saveSettings(
            _settings.copyWith(hapticEnabled: !item.isEnabled));
        case SettingType.notifications:
          await _saveSettings(
            _settings.copyWith(notificationEnabled: !item.isEnabled));
      }
    } catch (_) {
      _emitSnackBar(SettingsSnackBarMessage.updateFailed);
    }
  }

  Future<void> _saveSettings(UserSettingsData settings) async {
    await _settingsRepository.saveUserSettings(settings);
    _handleSettings(settings);   // stream cũng sẽ emit — != guard lo
  }

  void _handleSettings(UserSettingsData settings) {
    if (_isDisposed) return;
    final shouldNotify = _settings != settings;
    _settings = settings;
    if (shouldNotify) notifyListeners();
  }
```

Lưu ý `_saveSettings` KHÔNG tự đổi `_settings` trước khi repo trả
lời — luật 2 của bài 1: stream là nguồn truth.

**Bước 3 — picker visibility + chọn giờ + ngôn ngữ:**

```dart
  void showTimePicker(int hour, int minute) {
    _timePickerVisible = true;
    _timePickerHour = hour;
    _timePickerMinute = minute;
    notifyListeners();
  }

  void dismissTimePicker() {
    if (!_timePickerVisible) return;
    _timePickerVisible = false;
    notifyListeners();
  }

  Future<void> onNotificationTimeSelected(int hour, int minute) async {
    _timePickerVisible = false;
    notifyListeners();
    try {
      await _saveSettings(_settings.copyWith(
        notificationHour: hour, notificationMinute: minute));
    } catch (_) {
      _emitSnackBar(
        SettingsSnackBarMessage.notificationTimeUpdateFailed);
    }
  }

  Future<void> selectLanguage(SupportedLanguageData language) async {
    if (_settings.languageCode == language.code) return; // no-op guard
    try {
      await _saveSettings(_settings.copyWith(languageCode: language.code));
    } catch (_) {
      _emitSnackBar(SettingsSnackBarMessage.updateFailed);
    }
  }

  /// Nút XONG — VM xin đóng bằng EVENT, không pop (không có context).
  void saveSettings() {
    _events.add(const SettingsDismissRequested());
  }
```

**Bước 4 — dispose (kết thúc vòng đời):**

```dart
  @override
  void dispose() {
    _isDisposed = true;
    _settingsSubscription.cancel();
    _events.close();
    super.dispose();
  }
```


**Bước 5 — test `test/settings_view_model_test.dart` (file mới):**

M11–M13 đã quen pattern: test VM không cần pump widget — `new` trực
tiếp, truyền `FakeUserSettingsRepository` (đã có từ M14), nghe
`events.first` để bắt event một-lần. Bảy test cho bảy hành vi:

```dart
import 'package:ai_millionaire_course/data/settings/setting_item_data.dart';
import 'package:ai_millionaire_course/data/settings/supported_language_data.dart';
import 'package:ai_millionaire_course/data/settings/user_settings_data.dart';
import 'package:ai_millionaire_course/view_models/settings/settings_ui_event.dart';
import 'package:ai_millionaire_course/view_models/settings/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_user_settings_repository.dart';

/// M16 — SettingsViewModel: seeded từ stream, toggle/selectLanguage đi
/// qua repo (stream là nguồn truth), events một-lần đúng shape senior.
void main() {
  group('SettingsViewModel', () {
    test('ctor seed _settings từ userSettingsStream.value', () {
      final repo = FakeUserSettingsRepository(
        initialSettings: const UserSettingsData(soundEnabled: true),
      );
      addTearDown(repo.dispose);
      final vm = SettingsViewModel(settingsRepository: repo);
      addTearDown(vm.dispose);

      expect(vm.settingItems.first, isA<SettingSwitchItemData>());
      expect(
        (vm.settingItems.first as SettingSwitchItemData).isEnabled,
        isTrue,
      );
    });

    test('toggleSetting sound → persist qua repo + notify', () async {
      final repo = FakeUserSettingsRepository();
      addTearDown(repo.dispose);
      final vm = SettingsViewModel(settingsRepository: repo);
      addTearDown(vm.dispose);
      var notified = 0;
      vm.addListener(() => notified++);

      await vm.toggleSetting(
        const SettingSwitchItemData(
          icon: Icons.volume_up,
          text: 'Âm thanh',
          isEnabled: false,
          settingType: SettingType.sound,
        ),
      );

      expect(repo.saveCallCount, 1);
      expect(repo.value.soundEnabled, isTrue);
      expect(notified, greaterThan(0));
    });

    test('bật notifications → hàng giờ xuất hiện trong settingItems', () async {
      final repo = FakeUserSettingsRepository();
      addTearDown(repo.dispose);
      final vm = SettingsViewModel(settingsRepository: repo);
      addTearDown(vm.dispose);

      expect(
        vm.settingItems.any((i) => i is SettingTimePickerItemData),
        isFalse,
      );

      await vm.toggleSetting(
        const SettingSwitchItemData(
          icon: Icons.notifications,
          text: 'Thông báo',
          isEnabled: false,
          settingType: SettingType.notifications,
        ),
      );

      final timeItem = vm.settingItems
          .whereType<SettingTimePickerItemData>()
          .first;
      expect(timeItem.hour, UserSettingsData.defaultNotificationHour);
      expect(timeItem.formattedTime, '20:00');
    });

    test('onNotificationTimeSelected persist giờ + phút', () async {
      final repo = FakeUserSettingsRepository(
        initialSettings: const UserSettingsData(notificationEnabled: true),
      );
      addTearDown(repo.dispose);
      final vm = SettingsViewModel(settingsRepository: repo);
      addTearDown(vm.dispose);

      vm.showTimePicker(20, 0);
      expect(vm.timePickerVisible, isTrue);

      await vm.onNotificationTimeSelected(7, 30);

      expect(vm.timePickerVisible, isFalse);
      expect(repo.value.notificationHour, 7);
      expect(repo.value.notificationMinute, 30);
    });

    test(
      'selectLanguage ghi languageCode; chọn lại cùng mã thì bỏ qua',
      () async {
        final repo = FakeUserSettingsRepository();
        addTearDown(repo.dispose);
        final vm = SettingsViewModel(settingsRepository: repo);
        addTearDown(vm.dispose);

        await vm.selectLanguage(SupportedLanguageData.vietnamese);
        expect(repo.value.languageCode, 'vi');
        expect(repo.saveCallCount, 1);

        await vm.selectLanguage(SupportedLanguageData.vietnamese);
        expect(repo.saveCallCount, 1);
      },
    );

    test('saveSettings → bắn SettingsDismissRequested lên events', () async {
      final repo = FakeUserSettingsRepository();
      addTearDown(repo.dispose);
      final vm = SettingsViewModel(settingsRepository: repo);
      addTearDown(vm.dispose);

      final emitted = vm.events.first;
      vm.saveSettings();
      expect(await emitted, isA<SettingsDismissRequested>());
    });

    test('loadSettings lỗi → SnackBarRequested(loadFailed)', () async {
      final repo = _ThrowingSettingsRepository();
      addTearDown(repo.dispose);
      final vm = SettingsViewModel(settingsRepository: repo);
      addTearDown(vm.dispose);

      final emitted = vm.events.first;
      await vm.loadSettings();
      final event = await emitted;
      expect(event, isA<SettingsSnackBarRequested>());
      expect(
        (event as SettingsSnackBarRequested).message,
        SettingsSnackBarMessage.loadFailed,
      );
    });
  });
}

/// Fake ném lỗi để thử nhánh catch → event snackbar.
class _ThrowingSettingsRepository extends FakeUserSettingsRepository {
  @override
  Future<UserSettingsData> loadUserSettings() => throw StateError('boom');
}
```

## Hiểu code

- `_settings = settingsRepository.userSettingsStream.value` trong
  **initializer list**: BehaviorSubject đã seeded nên `.value` luôn có
  — VM mở ra là render được ngay, không cần vòng "loading".
- `_isDisposed` guard: stream có thể emit SAU `dispose()` (listener
  cancel là async) — không guard sẽ `notifyListeners` trên VM đã chết.
- `saveSettings()` → event thay vì `pop`: VM không giữ `BuildContext`;
  bridge (bài 4) nghe `SettingsDismissRequested` rồi mới pop. Tách
  "quyết định" khỏi "hành động navigation" — y hệt senior.
- `selectLanguage` ghi `languageCode` **thật** vào repo — đúng senior;
  chữ trên màn hình đổi ngôn ngữ là việc của M17 (MaterialApp.locale).

## Chạy và quan sát

```bash
flutter test test/settings_view_model_test.dart
```

Bảy test: seed từ stream, toggle → `saveCallCount`+`repo.value`, bật
thông báo → time item xuất hiện, `onNotificationTimeSelected(7,30)` →
persist, `selectLanguage` → `languageCode='vi'` + no-op khi trùng,
`saveSettings` → event dismiss, load lỗi → snackbar `loadFailed`.

## Thử nghiệm

Xoá case `SettingType.haptic` khỏi `toggleSetting`. Dự đoán lỗi
analyzer — và tại sao đây là *lợi ích* chứ không phải phiền?

## Lỗi hay gặp

1. **Đặt `ChangeNotifierProvider<SettingsViewModel>` lên
   `main()`/app scope** — VM sống mãi; `timePickerVisible` dính lại
   giữa hai lần mở dialog; test counter-example ở trên chứng minh
   khác biệt.
2. **`context.read<MenuViewModel>()` (hoặc bất kỳ provider nào
   **dưới** Navigator) TRONG dialog builder** — context route chỉ với
   tới provider **trên** Navigator; `MenuViewModel` sống trong subtree
   `MenuScreen` → `ProviderNotFoundException`. Repo app-scope
   (`UserSettingsRepository`, trên `MaterialApp`) đọc được — nhưng
   learner vẫn đọc ở caller và truyền instance: dialog tự chứa, test
   không cần dựng cả `MultiProvider`.
3. **VM tự `Navigator.pop`** — VM không có context; pop là việc của
   bridge khi nghe event dismiss.
4. **`notifyListeners()` sau `dispose()`** — luôn qua `_isDisposed`
   guard; subscription phải `cancel()` trong `dispose`.

## Tự làm — ba VM mới, ba tầng scope

Ba nhu cầu mới giả định. Với **mỗi** cái, quyết định: provider đặt
ở tầng nào (app / screen / dialog), **ai tạo** instance, **ai
dispose**, và state sống **bao lâu**. Viết đáp án ra *trước* khi mở
gợi ý — đây là bài tập thiết kế, không phải nhận diện.

| Nhu cầu | Tầng của bạn? |
| --- | --- |
| (a) `ConfirmResetViewModel` — dialog "Xoá toàn bộ dữ liệu local?" với trạng thái đang-xử-lý + đã-tick-checkbox |  |
| (b) `MenuTabState` — tab nào của menu đang được chọn (persist giữa các lần đẩy dialog, mất khi rời menu) |  |
| (c) `AppLocaleController` — quyết định `MaterialApp.locale`, sống suốt app |  |

Kèm câu hỏi bắt buộc cho mỗi hàng: *nếu đặt sai một tầng CAO hơn,
hậu quả nhìn thấy là gì? nếu đặt THẤP hơn?*

<details><summary>Đáp án + lập luận</summary>

- **(a) Tầng dialog** — trạng thái "đang xử lý" của một dialog chỉ có
  nghĩa trong một phiên dialog; sinh khi `showDialog` build, chết khi
  pop. Đặt ở screen-tier → mở lại dialog thấy lại checkbox/spinner
  cũ (bug UX nguyên mẫu). Đặt app-tier → sống vĩnh viễn, rác lifetime.
- **(b) Tầng screen** (`MenuScreen` subtree, dưới Navigator) — cần
  sống khi dialog settings mở/đóng, phải chết khi rời menu. Đặt ở
  dialog → dialog pop giết nó: tab "quên" mỗi lần mở settings. Đặt
  app-scope → persist sau khi quay menu lần sau — sai nếu spec muốn
  tab mặc định khi vào màn.
- **(c) Tầng app** — locale ảnh hưởng `MaterialApp` nên provider phải
  nằm *trên* nó (trong `AppDependencyScope`). Đặt dưới screen/dialog
  → `MaterialApp` không với tới (provider dưới điểm dùng) hoặc chết
  theo màn.

Quy tắc rút ra: **chọn tầng = trả lời "state này có quyền sống lâu
hơn thứ hiển thị nó không?"** — không thì đặt đúng tầng của thứ đó.

</details>

## Kiểm tra hiểu biết

1. Vì sao `timePickerVisible` nằm trong VM thay vì `setState` của
   dialog?
2. `events` dùng `broadcast()` thay vì controller thường — hệ quả gì
   cho listener đến trễ?
3. `_saveSettings` gọi `_handleSettings` trực tiếp — vậy stream emit
   của repo có gây notify kép không?

<details><summary>Đáp án</summary>

1. Để VM test được không cần widget + state tự dọn khi dialog đóng.
   `setState` trộn logic vào UI và không reset được theo scope.
2. Broadcast: subscriber mới KHÔNG nhận event đã phát trước khi nó
   listen — đúng nghĩa "event một-lần". Ngược với `BehaviorSubject`
   replay (state).
3. Không — `_handleSettings` so `!=` trước khi notify; emit lặp từ
   subject chỉ chạy lại hàm, `shouldNotify` sai → không rebuild thừa.

</details>

## Ta cố ý chưa thêm

- `LocalNotificationService` + `SettingsNotificationCoordinator` +
  `Future.wait` triple-load (xin quyền, version) — **M27**.
- Variant `notificationPermissionRequired` của snackbar enum — **M27**.
- Auth action trên account row — **M22+**.

## Checkpoint hoàn thành

- [ ] `flutter analyze` sạch; `settings_view_model_test.dart` 7/7.
- [ ] Giải thích được tại sao `SettingsViewModel` KHÔNG nằm trong
      `AppDependencyScope`/`MultiProvider`.
- [ ] Vẽ được 3 tầng lifetime: app → screen → dialog.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m16/03 — "SettingsViewModel — VM sinh và chết cùng dialog" (bài CORE M16: dialog-scoped VM + sealed SettingsUiEvent + toggleSetting switch kiệt hợp; chưa có dialog UI — bài 4).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test test/settings_view_model_test.dart`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. LƯU Ý: chưa có dialog UI/widget settings nào — VM + events + test là toàn bộ deliverable; `ChangeNotifierProvider<SettingsViewModel>` chưa tồn tại (scope đặt trong dialog ở bài 4).

EXPECTED STATE SAU BÀI NÀY:
- `lib/view_models/settings/settings_ui_event.dart` (STRICT): `sealed class SettingsUiEvent` + `final class SettingsDismissRequested` + `final class SettingsSnackBarRequested(this.message)` + `enum SettingsSnackBarMessage { loadFailed, updateFailed, notificationTimeUpdateFailed }` (STRICT đúng 3 message).
- `lib/view_models/settings/settings_view_model.dart` (STRICT): `SettingsViewModel extends ChangeNotifier` nhận `required UserSettingsRepository` (kiểu CONTRACT — không Impl); ctor: `_settings = settingsRepository.userSettingsStream.value` trong initializer + `_events = StreamController<SettingsUiEvent>.broadcast()` + `_settingsSubscription = _settingsRepository.userSettingsStream.listen(_handleSettings)` trong thân (STRICT seed `.value` + subscribe; `late final StreamSubscription<UserSettingsData> _settingsSubscription`).
- State: `UserSettingsData _settings`, `_timePickerVisible = false`, `_timePickerHour`/`_timePickerMinute` khởi tạo từ `UserSettingsData.defaultNotificationHour`/`defaultNotificationMinute` (constant đã có trên model — nếu model dùng literal khác thì note semantic), `_isDisposed = false`; `Stream<SettingsUiEvent> get events`; getter `settingItems` → `buildSettingItems(settings: _settings, effectiveNotificationEnabled: effectiveNotificationEnabled)`; `bool get effectiveNotificationEnabled => _settings.notificationEnabled` (STRICT — chưa AND quyền OS, đó là M27).
- `toggleSetting(SettingSwitchItemData item)`: `switch (item.settingType)` kiệt hợp 4 case → `_saveSettings(_settings.copyWith(<field tương ứng>: !item.isEnabled))`, bọc try/catch → `_emitSnackBar(SettingsSnackBarMessage.updateFailed)` (STRICT switch statement trên SettingType — KHÔNG if-chain trên text).
- `_saveSettings(settings)`: `await _settingsRepository.saveUserSettings(settings);` rồi `_handleSettings(settings)` (STRICT — KHÔNG gán `_settings` trước khi save; stream là truth). `_handleSettings`: `if (_isDisposed) return;` → `shouldNotify = _settings != settings` → gán → `if (shouldNotify) notifyListeners();` (STRICT 2 guard).
- `showTimePicker(h, m)` set visible + hour/minute + notify; `dismissTimePicker` guard `!visible → return` rồi false+notify; `onNotificationTimeSelected(h, m)`: visible=false+notify → `_saveSettings(copyWith(notificationHour/minute))` catch → `notificationTimeUpdateFailed`; `selectLanguage(language)`: `if (_settings.languageCode == language.code) return;` no-op guard → save `copyWith(languageCode: ...)` catch → `updateFailed` (STRICT no-op guard).
- `saveSettings()` → `_events.add(const SettingsDismissRequested())` (STRICT event thay vì pop — VM không có context); `loadSettings()` gọi repo + catch → `_emitSnackBar(loadFailed)` (semantic); `dispose()`: `_isDisposed=true; _settingsSubscription.cancel(); _events.close(); super.dispose();` (STRICT thứ tự).
- `test/settings_view_model_test.dart` (STRICT): ~7 test dùng `FakeUserSettingsRepository` + `addTearDown(repo.dispose/vm.dispose)`: ctor-seed, toggle→saveCallCount+repo.value+notified, bật notifications→SettingTimePickerItemData xuất hiện `hour==20`/`formattedTime=='20:00'`, onNotificationTimeSelected(7,30)→persist, selectLanguage→'vi'+no-op trùng (`saveCallCount` giữ 1), saveSettings→`events.first` isA<SettingsDismissRequested>, loadSettings lỗi→SettingsSnackBarRequested(loadFailed) qua `_ThrowingSettingsRepository` (extends fake, override loadUserSettings throw).
- `flutter test test/settings_view_model_test.dart` xanh; `flutter analyze` sạch.

INVARIANTS NỀN:
- `buildSettingItems`/`SettingItemData`/`SupportedLanguageData` bài 2; `FakeUserSettingsRepository` (saveCallCount/value) M14/06; repo architecture + MultiProvider M14; sealed/pattern M15; `SettingsViewModel` CHƯA có trong scope nào (dialog scope = bài 4 — nếu đã có = AHEAD).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (dialog scope/UI/settings_dialog.dart) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m16/03
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
