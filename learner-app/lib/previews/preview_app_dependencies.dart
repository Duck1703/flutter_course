import 'package:rxdart/rxdart.dart';

import '../data/auth/auth_session_data.dart';
import '../data/leaderboard/leaderboard_entry_data.dart';
import '../data/profile/profile_sync_state_data.dart';
import '../data/profile/user_profile_data.dart';
import '../data/settings/user_settings_data.dart';
import '../repositories/auth/auth_repository_contract.dart';
import '../repositories/leaderboard/leaderboard_repository_contract.dart';
import '../repositories/onboarding/onboarding_repository.dart';
import '../repositories/profile/user_profile_repository.dart';
import '../repositories/profile/user_profile_sync_repository_contract.dart';
import '../repositories/settings/user_settings_repository.dart';
import '../services/local_notification_service.dart';
import '../view_models/menu/menu_screen_view_model.dart';
import '../view_models/settings/settings_view_model.dart';
import 'preview_sample_data.dart';

final class PreviewOnboardingRepository implements OnboardingRepository {
  final BehaviorSubject<bool> _subject;

  PreviewOnboardingRepository({bool completed = false})
    : _subject = BehaviorSubject<bool>.seeded(completed);

  @override
  ValueStream<bool> get onboardingCompletedStream => _subject.stream;

  @override
  Future<bool> loadOnboardingCompleted() async => _subject.value;

  @override
  Future<void> setOnboardingCompleted() async => _subject.add(true);

  @override
  Future<void> dispose() => _subject.close();
}

final class PreviewUserSettingsRepository implements UserSettingsRepository {
  final BehaviorSubject<UserSettingsData> _subject;

  PreviewUserSettingsRepository()
    : _subject = BehaviorSubject<UserSettingsData>.seeded(previewUserSettings);

  @override
  ValueStream<UserSettingsData> get userSettingsStream => _subject.stream;

  @override
  Future<UserSettingsData> loadUserSettings() async => _subject.value;

  @override
  Future<void> saveUserSettings(UserSettingsData settings) async {
    _subject.add(settings);
  }

  @override
  Future<void> dispose() => _subject.close();
}

final class PreviewLocalNotificationService
    implements LocalNotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleDaily({required int hour, required int minute}) async {}

  @override
  Future<void> cancelDaily() async {}
}

final class PreviewUserProfileRepository implements UserProfileRepository {
  final BehaviorSubject<UserProfileData> _subject;

  PreviewUserProfileRepository()
    : _subject = BehaviorSubject<UserProfileData>.seeded(previewProfile);

  @override
  ValueStream<UserProfileData> get userProfileStream => _subject.stream;

  @override
  Future<UserProfileData> loadUserProfile() async => _subject.value;

  @override
  Future<void> saveUserProfile(UserProfileData userData) async {
    _subject.add(userData);
  }

  @override
  Future<void> resetUserProfile() async =>
      _subject.add(const UserProfileData());

  @override
  Future<void> dispose() => _subject.close();
}

final class PreviewAuthRepository implements AuthRepository {
  final BehaviorSubject<AuthSessionData> _subject;

  PreviewAuthRepository()
    : _subject = BehaviorSubject<AuthSessionData>.seeded(
        const AuthSessionAuthenticated(
          uid: 'preview-user',
          email: 'preview@example.com',
          displayName: 'Preview Player',
        ),
      );

  @override
  ValueStream<AuthSessionData> get authStateStream => _subject.stream;

  @override
  Future<AuthSessionData> loadAuthState() async => _subject.value;

  @override
  Future<AuthActionResult> signInWithGoogle() async {
    return const AuthActionResult.success('Signed in');
  }

  @override
  Future<AuthActionResult> signInWithApple() async {
    return const AuthActionResult.success('Signed in');
  }

  @override
  Future<AuthActionResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return const AuthActionResult.success('Signed in');
  }

  @override
  Future<AuthActionResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return const AuthActionResult.success('Account created');
  }

  @override
  Future<AuthActionResult> signOut() async {
    _subject.add(const AuthSessionGuest());
    return const AuthActionResult.success('Signed out');
  }

  @override
  Future<void> dispose() => _subject.close();
}

final class PreviewLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<LeaderboardSnapshot> loadLeaderboard({String? currentUserId}) async {
    return const LeaderboardSnapshot(
      entries: leaderboardEntries,
      currentEntry: currentLeaderboardEntry,
    );
  }
}

final class PreviewProfileSyncRepository implements UserProfileSyncRepository {
  final BehaviorSubject<ProfileSyncStateData> _subject;

  PreviewProfileSyncRepository()
    : _subject = BehaviorSubject<ProfileSyncStateData>.seeded(
        const ProfileSyncIdle(),
      );

  @override
  ValueStream<ProfileSyncStateData> get syncStateStream => _subject.stream;

  @override
  Future<void> syncUserProfile(AuthSessionAuthenticated session) async {}

  @override
  Future<void> dispose() => _subject.close();
}

SettingsViewModel createPreviewSettingsViewModel() {
  return SettingsViewModel(
    settingsRepository: PreviewUserSettingsRepository(),
    notificationService: PreviewLocalNotificationService(),
    loadAppVersion: () async => '1.0.0',
  );
}

MenuScreenViewModel createPreviewMenuScreenViewModel() {
  return MenuScreenViewModel(
    userProfileRepository: PreviewUserProfileRepository(),
    authRepository: PreviewAuthRepository(),
  );
}
