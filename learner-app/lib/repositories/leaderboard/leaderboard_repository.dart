// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_design_tokens.dart';
import '../../data/leaderboard/leaderboard_entry_data.dart';
import '../../data/profile/user_profile_data.dart';
import 'leaderboard_repository_contract.dart';

export 'leaderboard_repository_contract.dart';

const _leaderboardView = 'leaderboard';
const _leaderboardColumns = 'rank,name,avatar_url,level,total_money_won';
const _topEntryCount = 10;

class SupabaseLeaderboardRepository implements LeaderboardRepository {
  final SupabaseClient _client;

  const SupabaseLeaderboardRepository({required SupabaseClient client})
    : _client = client;

  /// Learner test seam (không có trong senior): bóc mapper
  /// `_LeaderboardRecord.fromMap → toEntry` để test phòng-thủ-parse
  /// không cần SupabaseClient. Giống các seam `@visibleForTesting`
  /// đã dùng ở M26/M28 — logic bên trong vẫn verbatim senior.
  @visibleForTesting
  static LeaderboardEntryData entryFromRow(
    Map<String, dynamic> row, {
    required bool isCurrentUser,
  }) => _LeaderboardRecord.fromMap(row).toEntry(isCurrentUser: isCurrentUser);

  @override
  Future<LeaderboardSnapshot> loadLeaderboard({String? currentUserId}) async {
    final rows = await _client
        .from(_leaderboardView)
        .select(_leaderboardColumns)
        .order('total_money_won', ascending: false)
        .order('rank')
        .limit(_topEntryCount);
    final records = rows.map(_LeaderboardRecord.fromMap).toList();
    final topEntries = records
        .map((record) => record.toEntry(isCurrentUser: false))
        .toList();
    final currentEntry = await _loadCurrentEntry(currentUserId);

    return LeaderboardSnapshot(entries: topEntries, currentEntry: currentEntry);
  }

  Future<LeaderboardEntryData?> _loadCurrentEntry(String? currentUserId) async {
    if (currentUserId == null || currentUserId.isEmpty) {
      return null;
    }

    final row = await _client
        .from(_leaderboardView)
        .select(_leaderboardColumns)
        .eq('auth_uuid', currentUserId)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return _LeaderboardRecord.fromMap(row).toEntry(isCurrentUser: true);
  }
}

class DisabledLeaderboardRepository implements LeaderboardRepository {
  const DisabledLeaderboardRepository();

  @override
  Future<LeaderboardSnapshot> loadLeaderboard({String? currentUserId}) async {
    return const LeaderboardSnapshot(
      entries: leaderboardEntries,
      currentEntry: currentLeaderboardEntry,
    );
  }
}

class _LeaderboardRecord {
  final int rank;
  final String name;
  final String? avatarUrl;
  final int level;
  final int totalMoneyWon;

  const _LeaderboardRecord({
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.level,
    required this.totalMoneyWon,
  });

  factory _LeaderboardRecord.fromMap(Map<String, dynamic> map) {
    return _LeaderboardRecord(
      rank: _intValue(map['rank'], 0),
      name: _stringValue(map['name']) ?? 'Player',
      avatarUrl: _stringValue(map['avatar_url']),
      level: _intValue(map['level'], 1),
      totalMoneyWon: _intValue(map['total_money_won'], 0),
    );
  }

  LeaderboardEntryData toEntry({required bool isCurrentUser}) {
    return LeaderboardEntryData(
      rank: rank,
      name: name,
      level: level,
      score: _formatScore(totalMoneyWon),
      avatarAsset: _avatarAsset(rank),
      avatarUrl: avatarUrl,
      rankAsset: isCurrentUser
          ? AppAssets.leaderboardRankCurrent
          : _rankAsset(rank),
      style: isCurrentUser ? LeaderboardRowStyle.currentUser : _rowStyle(rank),
      isCurrentUser: isCurrentUser,
    );
  }

  static String _formatScore(int amount) {
    return UserProfileData.formatVnd(amount).replaceAll(' VNĐ', '');
  }

  static String _rankAsset(int rank) {
    return switch (rank) {
      1 => AppAssets.leaderboardRank1,
      2 => AppAssets.leaderboardRank2,
      3 => AppAssets.leaderboardRank3,
      4 => AppAssets.leaderboardRank4,
      5 => AppAssets.leaderboardRank5,
      6 => AppAssets.leaderboardRank6,
      _ => AppAssets.leaderboardRankCurrent,
    };
  }

  static LeaderboardRowStyle _rowStyle(int rank) {
    return switch (rank) {
      1 => LeaderboardRowStyle.first,
      2 => LeaderboardRowStyle.second,
      3 => LeaderboardRowStyle.third,
      _ => LeaderboardRowStyle.glass,
    };
  }

  static String _avatarAsset(int rank) {
    const assets = [
      AppAssets.avatarMitUotChayTask,
      AppAssets.avatarLopTruongBiNgo,
      AppAssets.avatarTroLiDauBap,
      AppAssets.avatarRongBienBietBoi,
      AppAssets.avatarCuCaiXinhDep,
      AppAssets.avatarBanhCaCheNgoi,
    ];
    final index = (rank - 1).clamp(0, assets.length - 1).toInt();
    return assets[index];
  }

  static String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }

  static int _intValue(Object? value, int fallback) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return fallback;
  }
}
