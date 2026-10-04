/// State của job đồng bộ profile lên Supabase — M24 port nguyên văn
/// senior `lib/data/profile/profile_sync_state_data.dart`; M25 bắt
/// đầu được emit thật bởi `UserProfileSyncRepositoryImpl`.
///
/// Sealed union (M15) cho "sync đang ở đâu": Idle (rảnh) /
/// InProgress / Failed(message).
sealed class ProfileSyncStateData {
  const ProfileSyncStateData();
}

final class ProfileSyncIdle extends ProfileSyncStateData {
  const ProfileSyncIdle();

  @override
  bool operator ==(Object other) => other is ProfileSyncIdle;

  @override
  int get hashCode => 0;
}

final class ProfileSyncInProgress extends ProfileSyncStateData {
  const ProfileSyncInProgress();

  @override
  bool operator ==(Object other) => other is ProfileSyncInProgress;

  @override
  int get hashCode => 1;
}

final class ProfileSyncFailed extends ProfileSyncStateData {
  final String message;

  const ProfileSyncFailed(this.message);

  @override
  bool operator ==(Object other) {
    return other is ProfileSyncFailed && other.message == message;
  }

  @override
  int get hashCode => Object.hash(2, message);
}
