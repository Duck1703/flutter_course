import 'package:ai_millionaire_course/data/settings/setting_item_data.dart';
import 'package:ai_millionaire_course/data/settings/supported_language_data.dart';
import 'package:ai_millionaire_course/data/settings/user_settings_data.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:ai_millionaire_course/view_models/settings/settings_ui_event.dart';
import 'package:ai_millionaire_course/view_models/settings/settings_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_local_notification_service.dart';

void main() {
  late UserSettingsRepository repository;
  late FakeLocalNotificationService notificationService;
  late List<SettingsViewModel> viewModels;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = await UserSettingsRepositoryImpl.create();
    notificationService = FakeLocalNotificationService();
    viewModels = [];
  });

  tearDown(() async {
    for (final viewModel in viewModels) {
      viewModel.dispose();
    }
    await repository.dispose();
  });

  SettingsViewModel createViewModel() {
    final viewModel = SettingsViewModel(
      settingsRepository: repository,
      notificationService: notificationService,
      loadAppVersion: () async => '9.9.9',
    );
    viewModels.add(viewModel);
    return viewModel;
  }

  SettingSwitchItemData notificationSwitch(SettingsViewModel viewModel) =>
      viewModel.settingItems.whereType<SettingSwitchItemData>().singleWhere(
        (item) => item.settingType == SettingType.notifications,
      );
  test('settings view model loads defaults and app version', () async {
    final viewModel = createViewModel();

    await viewModel.loadSettings();

    expect(viewModel.appVersion, '9.9.9');
    expect(viewModel.languageCode, isNull);
    expect(
      viewModel.settingItems.whereType<SettingSwitchItemData>(),
      hasLength(4),
    );
    expect(
      viewModel.settingItems.whereType<SettingTimePickerItemData>(),
      isEmpty,
    );
  });

  test('selecting language persists supported locale code', () async {
    final viewModel = createViewModel();
    await viewModel.loadSettings();

    await viewModel.selectLanguage(SupportedLanguageData.vietnamese);

    expect(repository.userSettingsStream.value.languageCode, 'vi');
  });

  test('settings data ignores missing or unsupported language codes', () {
    expect(UserSettingsData.fromMap(const {}).languageCode, isNull);
    expect(
      UserSettingsData.fromMap(const {'languageCode': 'fr'}).languageCode,
      isNull,
    );
  });

  test(
    'enabling notifications requests permission and schedules daily',
    () async {
      notificationService.requestResult = true;
      final viewModel = createViewModel();
      await viewModel.loadSettings();
      final notificationItem = notificationSwitch(viewModel);

      await viewModel.toggleSetting(notificationItem);

      expect(notificationService.requestCount, 1);
      expect(notificationService.scheduleCount, 1);
      expect(notificationService.lastHour, 20);
      expect(notificationService.lastMinute, 0);
      expect(repository.userSettingsStream.value.notificationEnabled, isTrue);
      expect(
        viewModel.settingItems.whereType<SettingTimePickerItemData>(),
        hasLength(1),
      );
    },
  );

  test('denied notification permission keeps notifications disabled', () async {
    notificationService.requestResult = false;
    final viewModel = createViewModel();
    final snackBars = <SettingsSnackBarMessage>[];
    final subscription = viewModel.events.listen((event) {
      if (event is SettingsSnackBarRequested) {
        snackBars.add(event.message);
      }
    });
    await viewModel.loadSettings();
    final notificationItem = notificationSwitch(viewModel);

    await viewModel.toggleSetting(notificationItem);
    await pumpEventQueue();

    expect(notificationService.requestCount, 1);
    expect(notificationService.scheduleCount, 0);
    expect(repository.userSettingsStream.value.notificationEnabled, isFalse);
    expect(snackBars, [SettingsSnackBarMessage.notificationPermissionRequired]);

    await subscription.cancel();
  });

  test('disabling notifications cancels daily reminder', () async {
    notificationService.permissionGranted = true;
    final viewModel = createViewModel();
    await repository.saveUserSettings(
      const UserSettingsData(notificationEnabled: true),
    );
    await viewModel.loadSettings();

    await viewModel.toggleSetting(notificationSwitch(viewModel));

    expect(notificationService.cancelCount, 1);
    expect(repository.userSettingsStream.value.notificationEnabled, isFalse);
  });

  test('schedule failure keeps notifications disabled', () async {
    notificationService
      ..requestResult = true
      ..throwOnSchedule = true;
    final viewModel = createViewModel();
    final snackBars = <SettingsSnackBarMessage>[];
    final subscription = viewModel.events.listen((event) {
      if (event is SettingsSnackBarRequested) snackBars.add(event.message);
    });
    await viewModel.loadSettings();

    await viewModel.toggleSetting(notificationSwitch(viewModel));
    await pumpEventQueue();

    expect(repository.userSettingsStream.value.notificationEnabled, isFalse);
    expect(snackBars, [SettingsSnackBarMessage.updateFailed]);

    await subscription.cancel();
  });

  test(
    'selecting notification time persists and reschedules when enabled',
    () async {
      notificationService.permissionGranted = true;
      final viewModel = createViewModel();
      await repository.saveUserSettings(
        const UserSettingsData(notificationEnabled: true),
      );
      await viewModel.loadSettings();

      viewModel.showTimePicker(20, 0);
      await viewModel.onNotificationTimeSelected(8, 30);

      expect(viewModel.timePickerVisible, isFalse);
      expect(repository.userSettingsStream.value.notificationHour, 8);
      expect(repository.userSettingsStream.value.notificationMinute, 30);
      expect(notificationService.scheduleCount, 1);
      expect(notificationService.lastHour, 8);
      expect(notificationService.lastMinute, 30);
    },
  );

  test('schedule failure keeps previous notification time', () async {
    notificationService
      ..permissionGranted = true
      ..throwOnSchedule = true;
    final viewModel = createViewModel();
    final snackBars = <SettingsSnackBarMessage>[];
    final subscription = viewModel.events.listen((event) {
      if (event is SettingsSnackBarRequested) snackBars.add(event.message);
    });
    await repository.saveUserSettings(
      const UserSettingsData(notificationEnabled: true),
    );
    await viewModel.loadSettings();

    viewModel.showTimePicker(20, 0);
    await viewModel.onNotificationTimeSelected(8, 30);
    await pumpEventQueue();

    expect(repository.userSettingsStream.value.notificationHour, 20);
    expect(repository.userSettingsStream.value.notificationMinute, 0);
    expect(snackBars, [SettingsSnackBarMessage.notificationTimeUpdateFailed]);

    await subscription.cancel();
  });

  test('save settings emits dismiss event', () async {
    final viewModel = createViewModel();
    final events = <SettingsUiEvent>[];
    final subscription = viewModel.events.listen(events.add);

    viewModel.saveSettings();
    await pumpEventQueue();

    expect(events, [isA<SettingsDismissRequested>()]);

    await subscription.cancel();
  });
}
