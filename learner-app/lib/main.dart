import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_dependency_scope.dart';
import 'core/supabase_environment.dart';
import 'data/settings/supported_language_data.dart';
import 'l10n/app_localizations.dart';
import 'navigation/app_navigation_controller.dart';
import 'repositories/auth/disabled_auth_repository.dart';
import 'repositories/leaderboard/leaderboard_repository.dart';
import 'repositories/onboarding/onboarding_repository.dart';
import 'repositories/auth/supabase_auth_repository.dart';
import 'repositories/settings/user_settings_repository.dart';
import 'repositories/profile/user_profile_repository.dart';
import 'repositories/profile/user_profile_sync_repository.dart';
import 'screens/menu_screen.dart';
import 'services/apple_auth_service.dart';
import 'services/google_auth_service.dart';
import 'services/local_notification_service.dart';
import 'services/supabase_client_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final supabaseEnvironment = SupabaseEnvironment.fromEnvironment();
  debugPrint(
    '[auth] config supabase=${supabaseEnvironment.isSupabaseConfigured} '
    'google=${supabaseEnvironment.isGoogleConfigured}',
  );
  final supabaseClient = await SupabaseClientService.initialize(
    supabaseEnvironment,
  );
  debugPrint(
    '[auth] repository=${supabaseClient == null ? 'disabled' : 'supabase'}',
  );
  final userProfileRepository = await UserProfileRepositoryImpl.create();
  final onboardingRepository = await OnboardingRepositoryImpl.create();
  final userSettingsRepository = await UserSettingsRepositoryImpl.create();
  await userSettingsRepository.loadUserSettings();
  final notificationService = LocalNotificationServiceImpl();
  final navigationController = AppNavigationController();
  final authRepository = supabaseClient == null
      ? DisabledAuthRepository(environment: supabaseEnvironment)
      : AuthRepositoryImpl(
          client: supabaseClient,
          googleAuthService: GoogleAuthServiceImpl(
            environment: supabaseEnvironment,
          ),
          appleAuthService: AppleAuthServiceImpl(),
        );
  final leaderboardRepository = supabaseClient == null
      ? const DisabledLeaderboardRepository()
      : SupabaseLeaderboardRepository(client: supabaseClient);
  final profileSyncRepository = supabaseClient == null
      ? UserProfileSyncRepositoryDisabled()
      : UserProfileSyncRepositoryImpl(
          client: supabaseClient,
          userProfileRepository: userProfileRepository,
        );

  runApp(
    AppDependencyScope(
      navigationController: navigationController,
      userProfileRepository: userProfileRepository,
      authRepository: authRepository,
      leaderboardRepository: leaderboardRepository,
      profileSyncRepository: profileSyncRepository,
      onboardingRepository: onboardingRepository,
      userSettingsRepository: userSettingsRepository,
      notificationService: notificationService,
      child: const AIMillionaireApp(),
    ),
  );
}

class AIMillionaireApp extends StatelessWidget {
  const AIMillionaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = context.read<AppNavigationController>();
    final settingsStream = context
        .read<UserSettingsRepository>()
        .userSettingsStream;

    return StreamBuilder(
      stream: settingsStream,
      initialData: settingsStream.value,
      builder: (context, snapshot) {
        final selectedLocale = _selectedLocaleFor(snapshot.data?.languageCode);

        return MaterialApp(
          locale: selectedLocale,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: navigationController.navigatorKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MenuScreen(),
        );
      },
    );
  }

  Locale? _selectedLocaleFor(String? languageCode) {
    final language = SupportedLanguageData.fromCode(languageCode);
    return language == null ? null : Locale(language.code);
  }
}
