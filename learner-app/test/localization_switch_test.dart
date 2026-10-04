import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/data/settings/supported_language_data.dart';
import 'package:ai_millionaire_course/data/settings/user_settings_data.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:ai_millionaire_course/services/local_notification_service.dart';
import 'package:ai_millionaire_course/widgets/menu/settings/menu_settings_dialog_scope.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_user_settings_repository.dart';
import 'helpers/fake_local_notification_service.dart';

/// M17 — locale follows persisted settings: FR-26 whitelist unit tests
/// + widget test đúng shape senior `widget_test.dart`
/// ("app locale follows persisted language settings").
void main() {
  group('FR-26 — languageCode whitelist (senior _supportedLanguageCode)', () {
    test('mã hỗ trợ giữ nguyên: en / vi', () {
      expect(
        UserSettingsData.fromMap(const {'languageCode': 'en'}).languageCode,
        'en',
      );
      expect(
        UserSettingsData.fromMap(const {'languageCode': 'vi'}).languageCode,
        'vi',
      );
    });

    test('mã không hỗ trợ / sai kiểu / rỗng → null', () {
      expect(
        UserSettingsData.fromMap(const {'languageCode': 'fr'}).languageCode,
        isNull,
      );
      expect(
        UserSettingsData.fromMap(const {'languageCode': ''}).languageCode,
        isNull,
      );
      expect(
        UserSettingsData.fromMap(const {'languageCode': 7}).languageCode,
        isNull,
      );
      expect(
        UserSettingsData.fromMap(const {}).languageCode,
        isNull,
      );
    });
  });

  testWidgets('app locale follows persisted language settings', (
    tester,
  ) async {
    final repo = FakeUserSettingsRepository();
    addTearDown(repo.dispose);

    // Mirror `main.dart`: StreamBuilder bọc MaterialApp, locale ←
    // SupportedLanguageData.fromCode(languageCode) (null → fallback en).
    await tester.pumpWidget(
      StreamBuilder<UserSettingsData>(
        stream: repo.userSettingsStream,
        initialData: repo.userSettingsStream.value,
        builder: (context, snapshot) {
          final language = SupportedLanguageData.fromCode(
            snapshot.data?.languageCode,
          );
          return MaterialApp(
            locale: language == null ? null : Locale(language.code),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MultiProvider(
              providers: [
                Provider<UserSettingsRepository>.value(value: repo),
                Provider<LocalNotificationService>.value(
                  value: FakeLocalNotificationService(),
                ),
              ],
              child: MenuSettingsDialogScope(
                onDismiss: () {},
                profile: const UserProfileData(username: 'TestPlayer'),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // languageCode null → fallback template en.
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('DONE'), findsOneWidget);

    // Ghi 'vi' qua repo → stream emit → MaterialApp.locale đổi →
    // chữ Việt hiện KHÔNG cần restart (senior test y hệt).
    await repo.saveUserSettings(const UserSettingsData(languageCode: 'vi'));
    await tester.pumpAndSettle();

    expect(find.text('CÀI ĐẶT'), findsOneWidget);
    expect(find.text('XONG'), findsOneWidget);
    expect(find.text('Âm thanh'), findsOneWidget);
  });
}
