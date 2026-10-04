import '../../data/leaderboard/leaderboard_entry_data.dart';

abstract interface class LeaderboardRepository {
  Future<LeaderboardSnapshot> loadLeaderboard({String? currentUserId});
}

class LeaderboardSnapshot {
  final List<LeaderboardEntryData> entries;
  final LeaderboardEntryData? currentEntry;

  const LeaderboardSnapshot({required this.entries, this.currentEntry});
}
