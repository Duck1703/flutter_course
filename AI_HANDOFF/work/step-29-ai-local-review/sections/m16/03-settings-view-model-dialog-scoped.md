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
