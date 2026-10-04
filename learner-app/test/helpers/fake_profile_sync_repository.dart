import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/profile/profile_sync_state_data.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_sync_repository.dart';
import 'package:rxdart/rxdart.dart';

/// Test double cho `UserProfileSyncRepository` — M24, port nguyên văn
/// senior `test/helpers/fake_profile_sync_repository.dart`.
///
/// `syncCallCount`/`lastSyncedSession` chứng minh coordinator ĐÃ gọi
/// sync với đúng session (impl disabled không ghi nhận được); `syncError`
/// script throw để test đường exception của dialog VM.
class FakeUserProfileSyncRepository implements UserProfileSyncRepository {
  final BehaviorSubject<ProfileSyncStateData> _syncStateSubject;

  AuthSessionAuthenticated? lastSyncedSession;
  Object? syncError;
  var syncCallCount = 0;

  FakeUserProfileSyncRepository()
    : _syncStateSubject = BehaviorSubject<ProfileSyncStateData>.seeded(
        const ProfileSyncIdle(),
      );

  @override
  ValueStream<ProfileSyncStateData> get syncStateStream =>
      _syncStateSubject.stream;

  @override
  Future<void> syncUserProfile(AuthSessionAuthenticated session) async {
    syncCallCount++;
    lastSyncedSession = session;

    final error = syncError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> dispose() => _syncStateSubject.close();
}
