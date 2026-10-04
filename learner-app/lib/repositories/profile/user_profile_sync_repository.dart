// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/profile/app_user_data.dart';
import '../../data/auth/auth_session_data.dart';
import '../../data/profile/profile_sync_state_data.dart';
import '../../data/profile/user_profile_data.dart';
import 'user_profile_repository.dart';
import 'user_profile_sync_repository_contract.dart';

export 'user_profile_sync_repository_contract.dart';

/// Impl sync thật — M25, port nguyên văn senior
/// `repositories/profile/user_profile_sync_repository.dart`.
///
/// Luồng `syncUserProfile` đúng senior: guard `_isSyncing` chặn gọi
/// chồng → emit `ProfileSyncInProgress` → đọc profile local → fetch
/// row `public.users` theo `auth_uuid` → `mergeUserProfileForSync`
/// → lưu local → upsert remote (`onConflict: 'auth_uuid'`) → emit
/// `ProfileSyncIdle`. Lỗi bất kỳ → emit `ProfileSyncFailed` rồi
/// RETHROW — caller (coordinator/dialog VM) quyết định hiển thị;
/// `_emit` guard `isClosed` + trùng giá trị.
class UserProfileSyncRepositoryImpl implements UserProfileSyncRepository {
  final SupabaseClient _client;
  final UserProfileRepository _userProfileRepository;
  final BehaviorSubject<ProfileSyncStateData> _syncStateSubject;
  var _isSyncing = false;

  UserProfileSyncRepositoryImpl({
    required SupabaseClient client,
    required UserProfileRepository userProfileRepository,
  }) : _client = client,
       _userProfileRepository = userProfileRepository,
       _syncStateSubject = BehaviorSubject<ProfileSyncStateData>.seeded(
         const ProfileSyncIdle(),
       );

  @override
  ValueStream<ProfileSyncStateData> get syncStateStream =>
      _syncStateSubject.stream;

  @override
  Future<void> syncUserProfile(AuthSessionAuthenticated session) async {
    if (_isSyncing) {
      return;
    }

    _isSyncing = true;
    _emit(const ProfileSyncInProgress());

    try {
      final localProfile = await _userProfileRepository.loadUserProfile();
      final remoteProfile = await _fetchRemoteProfile(session.uid);
      final mergedProfile = mergeUserProfileForSync(
        session: session,
        localProfile: localProfile,
        remoteProfile: remoteProfile,
      );

      await _userProfileRepository.saveUserProfile(mergedProfile);
      await _upsertRemoteProfile(session, mergedProfile);
      _emit(const ProfileSyncIdle());
    } catch (error) {
      _emit(ProfileSyncFailed(error.toString()));
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  Future<AppUserData?> _fetchRemoteProfile(String authUuid) async {
    final data = await _client
        .from('users')
        .select()
        .eq('auth_uuid', authUuid)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return AppUserData.fromMap(data);
  }

  Future<void> _upsertRemoteProfile(
    AuthSessionAuthenticated session,
    UserProfileData profile,
  ) async {
    final appUser = AppUserData.fromProfile(session: session, profile: profile);
    debugPrint(
      '[sync] upserting public.users '
      'level=${profile.level} exp=${profile.currentExp} '
      'games=${profile.gamesJoined} '
      'questions=${profile.totalQuestionCount} '
      'money=${profile.totalMoneyWon}',
    );

    await _client
        .from('users')
        .upsert(appUser.toUpsertMap(), onConflict: 'auth_uuid');
  }

  void _emit(ProfileSyncStateData state) {
    if (!_syncStateSubject.isClosed && _syncStateSubject.value != state) {
      _syncStateSubject.add(state);
    }
  }

  @override
  Future<void> dispose() => _syncStateSubject.close();
}

/// Impl sync khi chưa có remote — M24. Port từ senior
/// `repositories/profile/user_profile_sync_repository.dart`
/// (phần Disabled — senior cũng giữ class này trong cùng file với
/// impl thật; `main()` chọn Disabled khi thiếu dart-define).
///
/// Vai trò: giữ cho `MenuAuthActionCoordinator.syncUserProfile` đã
/// đúng chỗ-gọi từ M24 — khi app chạy chế độ unconfigured (guest),
/// lời gọi rơi vào đây là NO-OP an toàn.
class UserProfileSyncRepositoryDisabled implements UserProfileSyncRepository {
  final BehaviorSubject<ProfileSyncStateData> _syncStateSubject;

  UserProfileSyncRepositoryDisabled()
    : _syncStateSubject = BehaviorSubject<ProfileSyncStateData>.seeded(
        const ProfileSyncIdle(),
      );

  @override
  ValueStream<ProfileSyncStateData> get syncStateStream =>
      _syncStateSubject.stream;

  @override
  Future<void> syncUserProfile(AuthSessionAuthenticated session) async {}

  @override
  Future<void> dispose() => _syncStateSubject.close();
}
