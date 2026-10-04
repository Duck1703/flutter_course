import 'package:rxdart/rxdart.dart';

import '../../data/auth/auth_session_data.dart';
import '../../data/profile/profile_sync_state_data.dart';

/// Contract đồng bộ profile local → `public.users` — M24, port nguyên
/// văn senior `repositories/profile/user_profile_sync_repository_contract.dart`.
///
/// Tách khỏi `UserProfileRepository` (local SharedPreferences): sync là
/// trách nhiệm RIÊNG chạy sau khi đăng nhập — `MenuAuthActionCoordinator`
/// gọi `syncUserProfile(session)` sau mỗi sign-in thành công.
///
/// `main()` chọn impl: `UserProfileSyncRepositoryDisabled` (no-op)
/// khi thiếu dart-define, `UserProfileSyncRepositoryImpl` (merge +
/// upsert `public.users`, M25) khi đủ — call-site không đổi.
abstract interface class UserProfileSyncRepository {
  /// Stream trạng thái sync — seeded `ProfileSyncIdle`; UI hiển thị
  /// InProgress/Failed theo đây.
  ValueStream<ProfileSyncStateData> get syncStateStream;

  /// Đồng bộ profile local với remote cho phiên authenticated.
  Future<void> syncUserProfile(AuthSessionAuthenticated session);

  Future<void> dispose();
}
