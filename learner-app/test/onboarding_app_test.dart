import 'package:ai_millionaire_course/core/app_dependency_scope.dart';
import 'package:ai_millionaire_course/core/supabase_environment.dart';
import 'package:ai_millionaire_course/main.dart';
import 'package:ai_millionaire_course/navigation/app_navigation_controller.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository.dart';
import 'package:ai_millionaire_course/repositories/leaderboard/leaderboard_repository.dart';
import 'package:ai_millionaire_course/repositories/onboarding/onboarding_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_sync_repository.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_local_notification_service.dart';

void main() {
  late UserProfileRepository userProfileRepository;
  late AuthRepository authRepository;
  late UserProfileSyncRepository profileSyncRepository;
  late UserSettingsRepository userSettingsRepository;
  late FakeLocalNotificationService notificationService;
  late AppNavigationController navigationController;
  late List<OnboardingRepository> onboardingRepositories;

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
    userSettingsRepository = await UserSettingsRepositoryImpl.create();
    notificationService = FakeLocalNotificationService();
    navigationController = AppNavigationController();
    onboardingRepositories = [];
  });

  tearDown(() async {
    await authRepository.dispose();
    await profileSyncRepository.dispose();
    for (final repository in onboardingRepositories) {
      await repository.dispose();
    }
    await userProfileRepository.dispose();
    await userSettingsRepository.dispose();
  });

  Future<OnboardingRepository> createFreshOnboardingRepository() async {
    final repository = await OnboardingRepositoryImpl.create();
    onboardingRepositories.add(repository);
    return repository;
  }

  Future<void> pumpApp(
    WidgetTester tester,
    OnboardingRepository onboardingRepository,
  ) async {
    await tester.pumpWidget(
      AppDependencyScope(
        navigationController: navigationController,
        userProfileRepository: userProfileRepository,
        authRepository: authRepository,
        leaderboardRepository: const DisabledLeaderboardRepository(),
        profileSyncRepository: profileSyncRepository,
        onboardingRepository: onboardingRepository,
        userSettingsRepository: userSettingsRepository,
        notificationService: notificationService,
        child: const AIMillionaireApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('app shows onboarding when completion is not cached', (
    tester,
  ) async {
    await pumpApp(tester, await createFreshOnboardingRepository());

    expect(find.text('WELCOME TO AI QUIZ!'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('Start Game'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Leaderboard'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('WELCOME TO AI QUIZ!'), findsOneWidget);
    expect(find.text('Ai là người sáng lập Microsoft?'), findsNothing);
    expect(find.text('LEADERBOARD'), findsNothing);
  });

  testWidgets('completing onboarding returns to the menu', (tester) async {
    final onboardingRepository = await createFreshOnboardingRepository();
    await pumpApp(tester, onboardingRepository);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MAYBE LATER'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    expect(find.text('WELCOME TO AI QUIZ!'), findsNothing);
    expect(find.text('Guest'), findsOneWidget);
    expect(onboardingRepository.onboardingCompletedStream.value, isTrue);
  });

  testWidgets('selecting Vietnamese in onboarding changes app locale', (
    tester,
  ) async {
    final onboardingRepository = await createFreshOnboardingRepository();
    await pumpApp(tester, onboardingRepository);

    await tester.tap(find.text('Tiếng Việt'));
    await tester.pumpAndSettle();

    expect(userSettingsRepository.userSettingsStream.value.languageCode, 'vi');
    expect(find.text('Chào mừng đến AI Quiz!'.toUpperCase()), findsOneWidget);
    expect(find.text('Tiếp tục'.toUpperCase()), findsOneWidget);
  });
}
