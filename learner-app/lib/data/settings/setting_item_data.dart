enum SettingType { sound, music, haptic, notifications }

sealed class SettingItemData {
  final String iconAsset;
  final String text;

  /// Optional second line explaining what the row does.
  final String? subtitle;
  final SettingType settingType;

  const SettingItemData({
    required this.iconAsset,
    required this.text,
    required this.settingType,
    this.subtitle,
  });
}

final class SettingSwitchItemData extends SettingItemData {
  final bool isEnabled;

  const SettingSwitchItemData({
    required super.iconAsset,
    required super.text,
    required this.isEnabled,
    required super.settingType,
    super.subtitle,
  });

  @override
  bool operator ==(Object other) {
    return other is SettingSwitchItemData &&
        other.iconAsset == iconAsset &&
        other.text == text &&
        other.subtitle == subtitle &&
        other.isEnabled == isEnabled &&
        other.settingType == settingType;
  }

  @override
  int get hashCode =>
      Object.hash(iconAsset, text, subtitle, isEnabled, settingType);
}

final class SettingTimePickerItemData extends SettingItemData {
  final int hour;
  final int minute;

  const SettingTimePickerItemData({
    required super.iconAsset,
    required super.text,
    required this.hour,
    required this.minute,
    required super.settingType,
  });

  String get formattedTime {
    final paddedHour = hour.toString().padLeft(2, '0');
    final paddedMinute = minute.toString().padLeft(2, '0');
    return '$paddedHour:$paddedMinute';
  }

  @override
  bool operator ==(Object other) {
    return other is SettingTimePickerItemData &&
        other.iconAsset == iconAsset &&
        other.text == text &&
        other.hour == hour &&
        other.minute == minute &&
        other.settingType == settingType;
  }

  @override
  int get hashCode => Object.hash(iconAsset, text, hour, minute, settingType);
}
