import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:ai_millionaire_course/view_models/settings/settings_view_model.dart';
import 'package:ai_millionaire_course/widgets/menu/settings/menu_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_local_notification_service.dart';

void main() {
  late UserSettingsRepository repository;
  late FakeLocalNotificationService notificationService;
  late SettingsViewModel viewModel;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = await UserSettingsRepositoryImpl.create();
    notificationService = FakeLocalNotificationService();
    viewModel = SettingsViewModel(
      settingsRepository: repository,
      notificationService: notificationService,
      loadAppVersion: () async => '1.0.0',
    );
    await viewModel.loadSettings();
  });

  tearDown(() async {
    viewModel.dispose();
    await repository.dispose();
  });

  testWidgets('settings dialog renders Compose-parity rows and save button', (
    tester,
  ) async {
    await tester.pumpWidget(_TestSurface(viewModel: viewModel));

    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.byKey(const ValueKey('settings-language-row')), findsOneWidget);
    expect(find.text('LANGUAGE'), findsOneWidget);
    expect(find.text('SOUND & HAPTICS'), findsOneWidget);
    expect(find.text('NOTIFICATIONS'), findsOneWidget);
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Tiếng Việt'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Music'), findsOneWidget);
    expect(find.text('Haptic Feedback'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Once a day'), findsOneWidget);
    expect(find.text('DONE'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
    expect(find.byKey(const ValueKey('settings-close-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('settings-time-row')), findsNothing);
  });

  testWidgets('account section switches between guest and signed-in', (
    tester,
  ) async {
    await tester.pumpWidget(_TestSurface(viewModel: viewModel));

    expect(find.byKey(const ValueKey('settings-account-row')), findsOneWidget);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);

    await tester.pumpWidget(
      _TestSurface(
        viewModel: viewModel,
        isAuthenticated: true,
        profile: const UserProfileData(username: 'SIGNED PLAYER'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SIGNED PLAYER'), findsOneWidget);
    expect(find.text('Synced'), findsOneWidget);
    expect(find.text('SIGN OUT'), findsOneWidget);
  });

  testWidgets('account action is forwarded from the account row', (
    tester,
  ) async {
    var accountTaps = 0;

    await tester.pumpWidget(
      _TestSurface(viewModel: viewModel, onAccountAction: () => accountTaps++),
    );

    await tester.tap(find.text('SIGN IN'));
    await tester.pump();

    expect(accountTaps, 1);
  });

  testWidgets('language row persists selected language', (tester) async {
    await tester.pumpWidget(_TestSurface(viewModel: viewModel));

    await tester.tap(find.text('Tiếng Việt'));
    await tester.pumpAndSettle();

    expect(repository.userSettingsStream.value.languageCode, 'vi');
  });

  testWidgets('notification toggle reveals time picker row', (tester) async {
    notificationService.requestResult = true;
    await tester.pumpWidget(_TestSurface(viewModel: viewModel));

    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('settings-time-row')), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);
  });

  testWidgets('time picker row opens picker state', (tester) async {
    notificationService.requestResult = true;
    await tester.pumpWidget(_TestSurface(viewModel: viewModel));
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-time-row')));
    await tester.pumpAndSettle();

    expect(viewModel.timePickerVisible, isTrue);
  });
}

class _TestSurface extends StatelessWidget {
  final SettingsViewModel viewModel;
  final bool isAuthenticated;
  final UserProfileData profile;
  final VoidCallback? onAccountAction;

  const _TestSurface({
    required this.viewModel,
    this.isAuthenticated = false,
    this.profile = const UserProfileData(),
    this.onAccountAction,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 375,
          height: 812,
          child: ChangeNotifierProvider<SettingsViewModel>.value(
            value: viewModel,
            child: MenuSettingsDialog(
              profile: profile,
              isAuthenticated: isAuthenticated,
              onAccountAction: onAccountAction,
            ),
          ),
        ),
      ),
    );
  }
}
