import 'dart:async';

import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/core/app_dependency_scope.dart';
import 'package:ai_millionaire_course/core/supabase_environment.dart';
import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/data/settings/user_settings_data.dart';
import 'package:ai_millionaire_course/main.dart';
import 'package:ai_millionaire_course/navigation/app_navigation_controller.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository.dart';
import 'package:ai_millionaire_course/repositories/leaderboard/leaderboard_repository.dart';
import 'package:ai_millionaire_course/repositories/onboarding/onboarding_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_sync_repository.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:ai_millionaire_course/screens/game_screen.dart';
import 'package:ai_millionaire_course/screens/menu_screen.dart';
import 'package:ai_millionaire_course/widgets/game/lifelines/game_feature_button.dart';
import 'package:ai_millionaire_course/widgets/menu/profile/menu_profile_header.dart';
import 'package:ai_millionaire_course/widgets/menu/profile/stats_card.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_local_notification_service.dart';
import 'widgets/game_screen_test_helpers.dart' show dialogButton;

void main() {
  late UserProfileRepository userProfileRepository;
  late AuthRepository authRepository;
  late UserProfileSyncRepository profileSyncRepository;
  late OnboardingRepository onboardingRepository;
  late UserSettingsRepository userSettingsRepository;
  late FakeLocalNotificationService notificationService;
  late AppNavigationController navigationController;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Flutter Accelerator AI',
      packageName: 'app.ai_millionaire_course',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    userProfileRepository = await UserProfileRepositoryImpl.create();
    authRepository = DisabledAuthRepository(
      environment: SupabaseEnvironment.fromEnvironment(),
    );
    profileSyncRepository = UserProfileSyncRepositoryDisabled();
    onboardingRepository = await OnboardingRepositoryImpl.create();
    userSettingsRepository = await UserSettingsRepositoryImpl.create();
    notificationService = FakeLocalNotificationService();
    navigationController = AppNavigationController();
    await onboardingRepository.setOnboardingCompleted();
  });

  tearDown(() async {
    await authRepository.dispose();
    await profileSyncRepository.dispose();
    await onboardingRepository.dispose();
    await userProfileRepository.dispose();
    await userSettingsRepository.dispose();
  });

  Widget buildApp({Widget child = const AIMillionaireApp()}) {
    return AppDependencyScope(
      navigationController: navigationController,
      userProfileRepository: userProfileRepository,
      authRepository: authRepository,
      leaderboardRepository: const DisabledLeaderboardRepository(),
      profileSyncRepository: profileSyncRepository,
      onboardingRepository: onboardingRepository,
      userSettingsRepository: userSettingsRepository,
      notificationService: notificationService,
      child: child,
    );
  }

  testWidgets('Menu screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter Accelerator AI'), findsNothing);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Sign in to sync'), findsOneWidget);
    expect(find.text('0 VNĐ'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
    expect(find.text('Played'), findsOneWidget);
    expect(find.text('Won'), findsOneWidget);
    expect(find.text('Win rate'), findsOneWidget);
    expect(find.text('Experience'.toUpperCase()), findsOneWidget);
    expect(
      find.byKey(const ValueKey('menu-leaderboard-entry')),
      findsOneWidget,
    );
    final avatarImage = tester.widget<Image>(
      find.descendant(
        of: find.byType(MenuProfileHeader),
        matching: find.byType(Image),
      ),
    );
    expect(avatarImage.image, isA<AssetImage>());
    expect((avatarImage.image as AssetImage).assetName, AppAssets.avatar);
    expect(
      find.byKey(const ValueKey('menu-profile-avatar-initial')),
      findsNothing,
    );
    expect(
      find.descendant(of: find.byType(StatsCard), matching: find.text('0')),
      findsNWidgets(2),
    );
    expect(
      find.descendant(of: find.byType(StatsCard), matching: find.text('—')),
      findsOneWidget,
    );
  });

  testWidgets('app locale follows persisted language settings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Start Game'), findsOneWidget);

    await userSettingsRepository.saveUserSettings(
      const UserSettingsData(languageCode: 'vi'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bắt đầu chơi'), findsOneWidget);
    expect(find.bySemanticsLabel('Cài đặt'), findsOneWidget);
  });

  testWidgets('Menu screen opens settings popup from the gear action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: navigationController.navigatorKey,
          home: const MenuScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Shop'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('SOUND & HAPTICS'), findsOneWidget);
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('DONE'), findsOneWidget);

    await tester.ensureVisible(find.text('DONE'));
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();

    expect(find.text('SETTINGS'), findsNothing);
  });

  testWidgets('Start game button opens screen and back returns to menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('MONEY LADDER'), findsOneWidget);
    await tester.tap(find.text('UNDERSTAND'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('What is the capital of Vietnam?'), findsOneWidget);
    expect(find.text(r'$0'), findsOneWidget);
    expect(find.text('00:30'), findsOneWidget);
    expect(find.text('Hanoi'), findsOneWidget);
    expect(find.text('Ho Chi Minh City'), findsOneWidget);
    expect(find.text('Da Nang'), findsOneWidget);
    expect(find.text('Hai Phong'), findsOneWidget);
    expect(find.bySemanticsLabel('50:50'), findsOneWidget);
    expect(find.bySemanticsLabel('Ask the Audience'), findsOneWidget);
    expect(find.bySemanticsLabel('Ask AI'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('50:50'));
    await tester.pump(const Duration(milliseconds: 250));

    final fiftyFiftyButton = tester.widget<GameFeatureButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is GameFeatureButton && widget.data.semanticLabel == '50:50',
      ),
    );
    expect(fiftyFiftyButton.data.isEnabled, isFalse);

    await tester.tap(find.bySemanticsLabel('Exit Game'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('EXIT GAME?'), findsOneWidget);

    await tester.ensureVisible(dialogButton('EXIT GAME'));
    await tester.tap(dialogButton('EXIT GAME'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
  });

  testWidgets('Leaderboard button opens popup and back dismisses it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('LEADERBOARD'), findsOneWidget);
    expect(find.text('Mít ướt chạy task'), findsOneWidget);
    expect(find.text('2.210.000'), findsOneWidget);
    expect(find.bySemanticsLabel('Rank 125'), findsOneWidget);
    expect(find.text('Tàu hủ đi chill'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('leaderboard-current-user-row')),
      findsOneWidget,
    );
    expect(find.text('510.000'), findsWidgets);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
    expect(find.text('LEADERBOARD'), findsNothing);
  });

  testWidgets('Sign out blocks system back while loading and shows result', (
    WidgetTester tester,
  ) async {
    final signOutCompleter = Completer<AuthActionResult>();
    final fakeAuthRepository = FakeAuthRepository(
      initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
      signOutCompleter: signOutCompleter,
    );
    await authRepository.dispose();
    authRepository = fakeAuthRepository;

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('menu-profile-pill')));
    await tester.tap(find.byKey(const ValueKey('menu-profile-pill')));
    await tester.pumpAndSettle();

    expect(find.text('ACCOUNT'), findsOneWidget);

    await tester.tap(find.text('SIGN OUT'));
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pump(AppTokens.dialogMotionLong);

    expect(fakeAuthRepository.signOutCallCount, 1);
    expect(find.text('ACCOUNT'), findsOneWidget);

    signOutCompleter.complete(
      const AuthActionResult.success('Signed out successfully.'),
    );
    await tester.pumpAndSettle();

    expect(find.text('ACCOUNT'), findsNothing);
    expect(find.text('Signed out successfully.'), findsOneWidget);
  });

  testWidgets('Menu screen renders cached profile data', (
    WidgetTester tester,
  ) async {
    await userProfileRepository.saveUserProfile(
      const UserProfileData(
        username: 'CACHE PLAYER',
        level: 22,
        totalEarnings: '22.000 VNĐ',
        gamesJoined: 30,
        gamesWon: 18,
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('22'), findsOneWidget);
    expect(find.text('22.000 VNĐ'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('CACHE PLAYER'), findsNothing);
  });

  testWidgets('Profile pill stacks identity right of the avatar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(
          child: SizedBox(
            width: 375,
            child: MenuProfileHeader(
              data: UserProfileData(username: 'PROFILE NAME', level: 7),
              isAuthenticated: true,
            ),
          ),
        ),
      ),
    );

    final avatarRect = tester.getRect(
      find.byKey(const ValueKey('menu-profile-avatar-frame')),
    );
    final nameRect = tester.getRect(find.text('PROFILE NAME'));
    final statusRect = tester.getRect(find.text('Synced'));
    final gearRect = tester.getRect(find.bySemanticsLabel('Settings'));

    expect(nameRect.left, greaterThan(avatarRect.right));
    expect(statusRect.left, greaterThan(avatarRect.right));
    expect(statusRect.top, greaterThanOrEqualTo(nameRect.bottom));
    expect(gearRect.left, greaterThan(nameRect.right));
  });

  testWidgets('User profile repository implementation creates explicit state', (
    WidgetTester tester,
  ) async {
    final nextRepository = await UserProfileRepositoryImpl.create();
    addTearDown(nextRepository.dispose);

    expect(identical(userProfileRepository, nextRepository), isFalse);
    expect(await nextRepository.loadUserProfile(), const UserProfileData());
  });

  testWidgets('Game screen renders inside a short viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildApp(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: navigationController.navigatorKey,
          home: const GameScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('What is the capital of Vietnam?'), findsOneWidget);
    expect(find.text('00:30'), findsOneWidget);
    expect(find.bySemanticsLabel('Exit Game'), findsOneWidget);
  });

  testWidgets('Game icon assets load from the Flutter bundle', (
    WidgetTester tester,
  ) async {
    final paths = [
      AppAssets.iconGameBack,
      AppAssets.iconGameFiftyFifty,
      AppAssets.iconGameAudience,
      AppAssets.iconGameSparkle,
      AppAssets.iconGameTrophy,
      AppAssets.iconGameLightning,
      AppAssets.iconGameMoney,
    ];

    for (final path in paths) {
      expect(await rootBundle.loadString(path), contains('<svg'));
    }
  });
}
