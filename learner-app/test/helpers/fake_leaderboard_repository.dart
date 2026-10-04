import 'dart:async';

import 'package:ai_millionaire_course/repositories/leaderboard/leaderboard_repository.dart';

/// Test double cho `LeaderboardRepository` — M23, port senior
/// `test/helpers/fake_leaderboard_repository.dart`.
///
/// Ba chế độ scriptable:
/// - `snapshot`: trả snapshot sẵn có (mặc định list rỗng).
/// - `error`: throw — lái nhánh `LeaderboardPopupError`.
/// - `completers`: mỗi lần load POP một Completer và trả `.future` của
///   nó — test tự quyết KHI NÀO request "trả về" (delayed response cho
///   stale-request test).
///
/// `loadCallCount` + `lastCurrentUserId` ghi lại tương tác để assert
/// "VM gọi repo đúng tham số" — không cần mock framework (convention
/// handwritten fake của repo).
class FakeLeaderboardRepository implements LeaderboardRepository {
  final LeaderboardSnapshot? snapshot;
  final Object? error;
  final List<Completer<LeaderboardSnapshot>> completers;
  String? lastCurrentUserId;
  var loadCallCount = 0;

  FakeLeaderboardRepository({
    this.snapshot,
    this.error,
    List<Completer<LeaderboardSnapshot>>? completers,
  }) : completers = completers ?? [];

  @override
  Future<LeaderboardSnapshot> loadLeaderboard({String? currentUserId}) async {
    loadCallCount++;
    lastCurrentUserId = currentUserId;

    final error = this.error;
    if (error != null) {
      throw error;
    }

    if (completers.isNotEmpty) {
      return completers.removeAt(0).future;
    }

    return snapshot ?? const LeaderboardSnapshot(entries: []);
  }
}
