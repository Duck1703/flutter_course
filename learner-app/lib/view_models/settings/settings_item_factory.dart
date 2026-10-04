import '../../core/app_assets.dart';
import '../../data/settings/setting_item_data.dart';
import '../../data/settings/user_settings_data.dart';

List<SettingItemData> buildSettingItems({
  required UserSettingsData settings,
  required bool effectiveNotificationEnabled,
  String soundText = 'Sound',
  String musicText = 'Music',
  String hapticText = 'Haptic Feedback',
  String notificationsText = 'Notifications',
  String notificationTimeText = 'Notification Time',
  String notificationsHint = 'Once a day',
}) {
  return [
    SettingSwitchItemData(
      iconAsset: AppAssets.iconSpeaker,
      text: soundText,
      isEnabled: settings.soundEnabled,
      settingType: SettingType.sound,
    ),
    SettingSwitchItemData(
      iconAsset: AppAssets.iconMusic,
      text: musicText,
      isEnabled: settings.musicEnabled,
      settingType: SettingType.music,
    ),
    SettingSwitchItemData(
      iconAsset: AppAssets.iconVibration,
      text: hapticText,
      isEnabled: settings.hapticEnabled,
      settingType: SettingType.haptic,
    ),
    SettingSwitchItemData(
      iconAsset: AppAssets.iconBellNotification,
      text: notificationsText,
      subtitle: notificationsHint,
      isEnabled: effectiveNotificationEnabled,
      settingType: SettingType.notifications,
    ),
    if (effectiveNotificationEnabled)
      SettingTimePickerItemData(
        iconAsset: AppAssets.iconFilter,
        text: notificationTimeText,
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
        settingType: SettingType.notifications,
      ),
  ];
}
