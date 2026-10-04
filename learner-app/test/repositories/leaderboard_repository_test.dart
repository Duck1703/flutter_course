import 'package:ai_millionaire_course/data/leaderboard/leaderboard_entry_data.dart';
import 'package:ai_millionaire_course/repositories/leaderboard/leaderboard_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test repository layer — M23. Không mạng, KHÔNG dựng SupabaseClient:
/// `DisabledLeaderboardRepository` chạy trực tiếp; impl remote chỉ kiểm
/// được qua seam `@visibleForTesting entryFromRow` (map row→entry).
void main() {
  group('DisabledLeaderboardRepository', () {
    test('trả đúng static data (entries + currentEntry)', () async {
      const repo = DisabledLeaderboardRepository();

      final snapshot = await repo.loadLeaderboard();

      expect(snapshot.entries, leaderboardEntries);
      expect(snapshot.currentEntry, currentLeaderboardEntry);
      expect(snapshot.entries, hasLength(6));
      expect(snapshot.currentEntry?.isCurrentUser, isTrue);
      expect(snapshot.currentEntry?.rank, 125);
    });

    test('bỏ qua currentUserId — impl static không query hàng riêng',
        () async {
      const repo = DisabledLeaderboardRepository();

      final snapshot = await repo.loadLeaderboard(currentUserId: 'uid-1');

      expect(snapshot.currentEntry, currentLeaderboardEntry);
    });
  });

  group('SupabaseLeaderboardRepository.entryFromRow (mapper seam)', () {
    test('row đầy đủ → entry đúng field, score bỏ hậu tố VNĐ', () {
      final entry = SupabaseLeaderboardRepository.entryFromRow(
        const {
          'rank': 3,
          'name': '  Trợ lí đậu bắp ',
          'avatar_url': 'https://example.com/a.png',
          'level': 9,
          'total_money_won': 510000,
        },
        isCurrentUser: false,
      );

      expect(entry.rank, 3);
      expect(entry.name, 'Trợ lí đậu bắp'); // trim
      expect(entry.level, 9);
      expect(entry.score, '510.000');
      expect(entry.avatarUrl, 'https://example.com/a.png');
      expect(entry.isCurrentUser, isFalse);
    });

    test('row thiếu/sai kiểu → fallback phòng thủ của senior', () {
      final entry = SupabaseLeaderboardRepository.entryFromRow(
        const {
          'rank': 'abc', // sai kiểu → 0
          'name': '   ', // blank → 'Player'
          'avatar_url': 42, // sai kiểu → null
          'total_money_won': 1500000.0, // num → int
        },
        isCurrentUser: true,
      );

      expect(entry.rank, 0);
      expect(entry.name, 'Player');
      expect(entry.level, 1); // thiếu → mặc định senior
      expect(entry.score, '1.500.000');
      expect(entry.avatarUrl, isNull);
      expect(entry.isCurrentUser, isTrue);
    });
  });
}
