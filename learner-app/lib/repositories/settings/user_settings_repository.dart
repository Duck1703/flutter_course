import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/settings/user_settings_data.dart';

/// Contract repository cài đặt — cùng shape profile repo (M14).
/// Settings dialog thật tiêu thụ stream này ở M16; main() đã gọi
/// `loadUserSettings()` lúc bootstrap (đúng senior) để state sẵn sàng
/// trước build đầu tiên.
abstract interface class UserSettingsRepository {
  ValueStream<UserSettingsData> get userSettingsStream;

  Future<UserSettingsData> loadUserSettings();

  Future<void> saveUserSettings(UserSettingsData settings);

  Future<void> dispose();
}

/// Impl SharedPreferences — key `'user_settings'`, JSON codec, seeded
/// `BehaviorSubject`, emit-guard giống hệt profile repo.
class UserSettingsRepositoryImpl implements UserSettingsRepository {
  static const _settingsKey = 'user_settings';

  final SharedPreferences _preferences;
  final BehaviorSubject<UserSettingsData> _settingsSubject;

  UserSettingsRepositoryImpl._(this._preferences)
    : _settingsSubject = BehaviorSubject<UserSettingsData>.seeded(
        const UserSettingsData(),
      );

  static Future<UserSettingsRepositoryImpl> create() async {
    final preferences = await SharedPreferences.getInstance();
    return UserSettingsRepositoryImpl._(preferences);
  }

  @override
  ValueStream<UserSettingsData> get userSettingsStream =>
      _settingsSubject.stream;

  @override
  Future<UserSettingsData> loadUserSettings() async {
    final encodedSettings = _preferences.getString(_settingsKey);

    if (encodedSettings == null) {
      return _emitSettings(const UserSettingsData());
    }

    try {
      final decodedSettings = jsonDecode(encodedSettings);

      if (decodedSettings is Map) {
        return _emitSettings(
          UserSettingsData.fromMap(Map<String, Object?>.from(decodedSettings)),
        );
      }
    } on FormatException {
      return _emitSettings(const UserSettingsData());
    }

    return _emitSettings(const UserSettingsData());
  }

  @override
  Future<void> saveUserSettings(UserSettingsData settings) async {
    final didSave = await _preferences.setString(
      _settingsKey,
      jsonEncode(settings.toMap()),
    );

    if (!didSave) {
      throw StateError('Failed to save user settings.');
    }

    _emitSettings(settings);
  }

  UserSettingsData _emitSettings(UserSettingsData settings) {
    if (!_settingsSubject.isClosed && _settingsSubject.value != settings) {
      _settingsSubject.add(settings);
    }

    return settings;
  }

  @override
  Future<void> dispose() => _settingsSubject.close();
}
