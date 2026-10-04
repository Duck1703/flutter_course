import 'dart:convert';

import 'package:ai_millionaire_course/data/settings/user_settings_data.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads persisted supported language code', () async {
    SharedPreferences.setMockInitialValues({
      'user_settings': jsonEncode(
        const UserSettingsData(languageCode: 'vi').toMap(),
      ),
    });
    final repository = await UserSettingsRepositoryImpl.create();
    addTearDown(repository.dispose);

    final settings = await repository.loadUserSettings();

    expect(settings.languageCode, 'vi');
    expect(repository.userSettingsStream.value.languageCode, 'vi');
  });

  test('ignores unsupported persisted language code', () async {
    SharedPreferences.setMockInitialValues({
      'user_settings': jsonEncode({'languageCode': 'fr'}),
    });
    final repository = await UserSettingsRepositoryImpl.create();
    addTearDown(repository.dispose);

    final settings = await repository.loadUserSettings();

    expect(settings.languageCode, isNull);
    expect(repository.userSettingsStream.value.languageCode, isNull);
  });
}
