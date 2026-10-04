import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../navigation/app_navigation_controller.dart';
import '../repositories/auth/auth_repository_contract.dart';
import '../repositories/leaderboard/leaderboard_repository_contract.dart';
import '../repositories/onboarding/onboarding_repository.dart';
import '../repositories/profile/user_profile_repository.dart';
import '../repositories/profile/user_profile_sync_repository_contract.dart';
import '../repositories/settings/user_settings_repository.dart';
import '../services/local_notification_service.dart';

class AppDependencyScope extends StatelessWidget {
  final AppNavigationController navigationController;
  final UserProfileRepository userProfileRepository;
  final AuthRepository authRepository;
  final LeaderboardRepository leaderboardRepository;
  final UserProfileSyncRepository profileSyncRepository;
  final OnboardingRepository onboardingRepository;
  final UserSettingsRepository userSettingsRepository;
  final LocalNotificationService notificationService;
  final Widget child;

  const AppDependencyScope({
    super.key,
    required this.navigationController,
    required this.userProfileRepository,
    required this.authRepository,
    required this.leaderboardRepository,
    required this.profileSyncRepository,
    required this.onboardingRepository,
    required this.userSettingsRepository,
    required this.notificationService,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppNavigationController>.value(value: navigationController),
        Provider<UserProfileRepository>.value(value: userProfileRepository),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<LeaderboardRepository>.value(value: leaderboardRepository),
        Provider<UserProfileSyncRepository>.value(value: profileSyncRepository),
        Provider<OnboardingRepository>.value(value: onboardingRepository),
        Provider<UserSettingsRepository>.value(value: userSettingsRepository),
        Provider<LocalNotificationService>.value(value: notificationService),
      ],
      child: child,
    );
  }
}
