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
