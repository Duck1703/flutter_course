import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/settings/setting_item_data.dart';
import '../../data/settings/supported_language_data.dart';
import '../../data/settings/user_settings_data.dart';
import '../../repositories/settings/user_settings_repository.dart';
import '../../services/local_notification_service.dart';
import 'settings_app_version_loader.dart';
import 'settings_item_factory.dart';
import 'settings_notification_coordinator.dart';
import 'settings_ui_event.dart';

/// VM của settings dialog — M16 (SINH VÀ CHẾT CÙNG DIALOG:
/// `ChangeNotifierProvider(create:)` nằm trong subtree của dialog nên
/// Provider tự `dispose()` khi dialog pop — đúng senior
/// `MenuSettingsDialogScope`).
///
/// M27: `notificationService` + `_notificationCoordinator` +
/// `_hasNotificationPermission` + `_appVersion` + `_loadAppVersion`
/// đều verbatim senior — FR-27 (notification side-effects) và FR-28
/// (version text) converge.
///
/// Data flow (đúng senior, giống MenuScreenViewModel của M14/M29):
/// - ctor seed `_settings` từ `userSettingsStream.value` (subject đã
///   seeded → luôn có giá trị ngay) rồi subscribe stream;
/// - mọi thay đổi đi qua `_saveSettings` → repo → subject →
///   `_handleSettings` → notifyListeners → UI rebuild. Stream là nguồn
///   truth duy nhất; VM không giữ bản copy song song.
class SettingsViewModel extends ChangeNotifier {
  final UserSettingsRepository _settingsRepository;

  /// Contract dịch vụ thông báo — M27 (senior field public cùng tên):
  /// VM chỉ biết interface `LocalNotificationService`, impl/plugin
  /// sống ở `main()`/DI. Test inject `FakeLocalNotificationService`.
  final LocalNotificationService notificationService;

  /// Seam nạp version — senior inject `Future<String> Function()?`
  /// mặc định [loadSettingsAppVersion] (`package_info_plus`); test
  /// truyền `() async => '9.9.9'`.
  final Future<String> Function() _loadAppVersion;

  final StreamController<SettingsUiEvent> _events;

  /// M27 — senior `_notificationCoordinator`: orchestration
  /// enable/disable/updateTime + best-effort rollback notification
  /// khi save settings lỗi.
  late final SettingsNotificationCoordinator _notificationCoordinator;

  late final StreamSubscription<UserSettingsData> _settingsSubscription;

  UserSettingsData _settings;

  /// Quyền thông báo do OS nắm — M27: `hasPermission` nạp khi
  /// `loadSettings`, `requestPermission` cập nhật khi bật switch.
  var _hasNotificationPermission = false;
  var _timePickerVisible = false;
  var _timePickerHour = UserSettingsData.defaultNotificationHour;
  var _timePickerMinute = UserSettingsData.defaultNotificationMinute;

  /// `v…` text cuối dialog — nạp trong `loadSettings`; `''` trước khi
  /// nạp xong (senior: ẩn row khi rỗng).
  var _appVersion = '';
  var _isDisposed = false;

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

  Stream<SettingsUiEvent> get events => _events.stream;
  String get appVersion => _appVersion;
  bool get timePickerVisible => _timePickerVisible;
  String? get languageCode => _settings.languageCode;
  int get timePickerHour => _timePickerHour;
  int get timePickerMinute => _timePickerMinute;

  /// FR-27 converge — senior AND flag với quyền OS: toggle "bật" chỉ
  /// thật sự bật khi permission granted; mất quyền → switch tự tắt.
  bool get effectiveNotificationEnabled =>
      _settings.notificationEnabled && _hasNotificationPermission;

  List<SettingItemData> get settingItems => buildSettingItems(
    settings: _settings,
    effectiveNotificationEnabled: effectiveNotificationEnabled,
  );

  /// Bản đã bản địa hoá — senior `localizedSettingItems`: widget truyền
  /// chuỗi `l10n.*`, VM/factory không import AppLocalizations (VM
  /// không chạm context — tầng UI sở hữu chữ).
  List<SettingItemData> localizedSettingItems({
    required String soundText,
    required String musicText,
    required String hapticText,
    required String notificationsText,
    required String notificationTimeText,
    required String notificationsHint,
  }) {
    return buildSettingItems(
      settings: _settings,
      effectiveNotificationEnabled: effectiveNotificationEnabled,
      soundText: soundText,
      musicText: musicText,
      hapticText: hapticText,
      notificationsText: notificationsText,
      notificationTimeText: notificationTimeText,
      notificationsHint: notificationsHint,
    );
  }

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

  /// Bật/tắt một hàng switch — `switch` kiệt hợp trên `SettingType`:
  /// thêm SettingType mới mà quên nhánh là lỗi biên dịch.
  /// Nhánh notifications → [_toggleNotifications] (xin quyền +
  /// coordinator, M27 — FR-27).
  Future<void> toggleSetting(SettingSwitchItemData item) async {
    try {
      switch (item.settingType) {
        case SettingType.sound:
          await _saveSettings(
            _settings.copyWith(soundEnabled: !item.isEnabled),
          );
        case SettingType.music:
          await _saveSettings(
            _settings.copyWith(musicEnabled: !item.isEnabled),
          );
        case SettingType.haptic:
          await _saveSettings(
            _settings.copyWith(hapticEnabled: !item.isEnabled),
          );
        case SettingType.notifications:
          await _toggleNotifications(item);
      }
    } catch (_) {
      _emitSnackBar(SettingsSnackBarMessage.updateFailed);
    }
  }

  /// Chọn ngôn ngữ — ghi `languageCode` thật qua repo (đúng senior
  /// `selectLanguage`).
  Future<void> selectLanguage(SupportedLanguageData language) async {
    if (_settings.languageCode == language.code) {
      return;
    }

    try {
      await _saveSettings(_settings.copyWith(languageCode: language.code));
    } catch (_) {
      _emitSnackBar(SettingsSnackBarMessage.updateFailed);
    }
  }

  /// Mở picker giờ thông báo — visibility là STATE của VM (render-by-
  /// state, M15).
  void showTimePicker(int hour, int minute) {
    _timePickerVisible = true;
    _timePickerHour = hour;
    _timePickerMinute = minute;
    notifyListeners();
  }

  void dismissTimePicker() {
    if (!_timePickerVisible) {
      return;
    }

    _timePickerVisible = false;
    notifyListeners();
  }

  /// Chọn xong giờ → senior: `coordinator.updateTime` (reschedule nếu
  /// notifications đang effective rồi mới persist; lỗi → restore lịch
  /// cũ + snackbar). M27 — FR-27.
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

  /// Nút XONG — VM xin đóng, không tự pop (không có context).
  void saveSettings() {
    _events.add(const SettingsDismissRequested());
  }

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

  Future<void> _saveSettings(UserSettingsData settings) async {
    await _settingsRepository.saveUserSettings(settings);
    _handleSettings(settings);
  }

  void _handleSettings(UserSettingsData settings) {
    if (_isDisposed) {
      return;
    }

    final shouldNotify = _settings != settings;
    _settings = settings;

    if (shouldNotify) {
      notifyListeners();
    }
  }

  void _emitSnackBar(SettingsSnackBarMessage message) {
    if (!_events.isClosed) {
      _events.add(SettingsSnackBarRequested(message));
    }
  }

  void _notifyIfOpen() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _settingsSubscription.cancel();
    _events.close();
    super.dispose();
  }
}
