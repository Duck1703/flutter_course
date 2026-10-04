// Cài đặt người chơi — model bất biến, đến ở M14 cùng
// `UserSettingsRepository` (roadmap M14: settings repo trước, UI
// settings dialog thật là M16).
//
// Đúng shape senior `lib/data/settings/user_settings_data.dart`:
// cùng 7 field, cùng defaults, cùng parse phòng thủ
// (`_boundedInt` kẹp giờ/phút, bool parse qua `== true`).
//
// FR-26 (CONVERGED tại M17): `languageCode` whitelist qua
// `SupportedLanguageData.isSupportedCode` — y hệt senior; mã lạ
// trong storage → null → locale rơi về mặc định hệ thống.
import 'supported_language_data.dart';

class UserSettingsData {
  static const defaultNotificationHour = 20;
  static const defaultNotificationMinute = 0;

  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticEnabled;
  final bool notificationEnabled;
  final int notificationHour;
  final int notificationMinute;
  final String? languageCode;

  const UserSettingsData({
    this.soundEnabled = false,
    this.musicEnabled = false,
    this.hapticEnabled = true,
    this.notificationEnabled = false,
    this.notificationHour = defaultNotificationHour,
    this.notificationMinute = defaultNotificationMinute,
    this.languageCode,
  });

  UserSettingsData copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticEnabled,
    bool? notificationEnabled,
    int? notificationHour,
    int? notificationMinute,
    String? languageCode,
  }) {
    return UserSettingsData(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'hapticEnabled': hapticEnabled,
      'notificationEnabled': notificationEnabled,
      'notificationHour': notificationHour,
      'notificationMinute': notificationMinute,
      'languageCode': languageCode,
    };
  }

  /// Parse phòng thủ: bool chỉ true khi đúng `true` (vắng → default);
  /// `hapticEnabled` ngoại lệ — vắng/sai kiểu → `true` (senior bật
  /// haptic mặc định). Giờ/phút phải nằm trong khoảng hợp lệ.
  factory UserSettingsData.fromMap(Map<String, Object?> map) {
    final hour = _boundedInt(map['notificationHour'], 0, 23);
    final minute = _boundedInt(map['notificationMinute'], 0, 59);
    final languageCode = _supportedLanguageCode(map['languageCode']);

    return UserSettingsData(
      soundEnabled: map['soundEnabled'] == true,
      musicEnabled: map['musicEnabled'] == true,
      hapticEnabled: map['hapticEnabled'] is bool
          ? map['hapticEnabled'] == true
          : true,
      notificationEnabled: map['notificationEnabled'] == true,
      notificationHour: hour ?? defaultNotificationHour,
      notificationMinute: minute ?? defaultNotificationMinute,
      languageCode: languageCode,
    );
  }

  static int? _boundedInt(Object? value, int min, int max) {
    if (value is! int || value < min || value > max) {
      return null;
    }

    return value;
  }

  /// FR-26 (CONVERGED tại M17): y hệt senior `_supportedLanguageCode`
  /// — không phải String HOẶC không nằm trong whitelist → null.
  static String? _supportedLanguageCode(Object? value) {
    if (value is! String || !SupportedLanguageData.isSupportedCode(value)) {
      return null;
    }

    return value;
  }

  @override
  bool operator ==(Object other) {
    return other is UserSettingsData &&
        other.soundEnabled == soundEnabled &&
        other.musicEnabled == musicEnabled &&
        other.hapticEnabled == hapticEnabled &&
        other.notificationEnabled == notificationEnabled &&
        other.notificationHour == notificationHour &&
        other.notificationMinute == notificationMinute &&
        other.languageCode == languageCode;
  }

  @override
  int get hashCode => Object.hash(
    soundEnabled,
    musicEnabled,
    hapticEnabled,
    notificationEnabled,
    notificationHour,
    notificationMinute,
    languageCode,
  );
}
