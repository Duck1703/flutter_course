import '../../core/app_design_tokens.dart';

class LeaderboardEntryData {
  final int rank;
  final String name;
  final int level;
  final String score;
  final String avatarAsset;
  final String? avatarUrl;
  final String rankAsset;
  final LeaderboardRowStyle style;
  final bool isCurrentUser;

  const LeaderboardEntryData({
    required this.rank,
    required this.name,
    required this.level,
    required this.score,
    required this.avatarAsset,
    this.avatarUrl,
    required this.rankAsset,
    required this.style,
    this.isCurrentUser = false,
  });
}

enum LeaderboardRowStyle { first, second, third, glass, currentUser }

enum LeaderboardPopupMessage { empty, loadError, loading }

sealed class LeaderboardPopupState {
  const LeaderboardPopupState();
}

final class LeaderboardPopupSuccess extends LeaderboardPopupState {
  final List<LeaderboardEntryData> entries;
  final LeaderboardEntryData? currentEntry;
  final bool isRefreshing;

  const LeaderboardPopupSuccess({
    this.entries = leaderboardEntries,
    this.currentEntry = currentLeaderboardEntry,
    this.isRefreshing = false,
  });
}

final class LeaderboardPopupEmpty extends LeaderboardPopupState {
  final LeaderboardPopupMessage message;

  const LeaderboardPopupEmpty({this.message = LeaderboardPopupMessage.empty});
}

final class LeaderboardPopupError extends LeaderboardPopupState {
  final LeaderboardPopupMessage message;

  const LeaderboardPopupError({
    this.message = LeaderboardPopupMessage.loadError,
  });
}

final class LeaderboardPopupLoading extends LeaderboardPopupState {
  final LeaderboardPopupMessage message;

  const LeaderboardPopupLoading({
    this.message = LeaderboardPopupMessage.loading,
  });
}

const leaderboardEntries = [
  LeaderboardEntryData(
    rank: 1,
    name: 'Mít ướt chạy task',
    level: 12,
    score: '2.210.000',
    avatarAsset: AppAssets.avatarMitUotChayTask,
    rankAsset: AppAssets.leaderboardRank1,
    style: LeaderboardRowStyle.first,
  ),
  LeaderboardEntryData(
    rank: 2,
    name: 'Lớp trưởng bí ngô',
    level: 10,
    score: '1.210.000',
    avatarAsset: AppAssets.avatarLopTruongBiNgo,
    rankAsset: AppAssets.leaderboardRank2,
    style: LeaderboardRowStyle.second,
  ),
  LeaderboardEntryData(
    rank: 3,
    name: 'Trợ lí đậu bắp',
    level: 9,
    score: '510.000',
    avatarAsset: AppAssets.avatarTroLiDauBap,
    rankAsset: AppAssets.leaderboardRank3,
    style: LeaderboardRowStyle.third,
  ),
  LeaderboardEntryData(
    rank: 4,
    name: 'Rong biển biết bơi',
    level: 9,
    score: '510.000',
    avatarAsset: AppAssets.avatarRongBienBietBoi,
    rankAsset: AppAssets.leaderboardRank4,
    style: LeaderboardRowStyle.glass,
  ),
  LeaderboardEntryData(
    rank: 5,
    name: 'Củ cải xinh đẹp',
    level: 9,
    score: '510.000',
    avatarAsset: AppAssets.avatarCuCaiXinhDep,
    rankAsset: AppAssets.leaderboardRank5,
    style: LeaderboardRowStyle.glass,
  ),
  LeaderboardEntryData(
    rank: 6,
    name: 'Bánh cá chẻ ngôi',
    level: 9,
    score: '510.000',
    avatarAsset: AppAssets.avatarBanhCaCheNgoi,
    rankAsset: AppAssets.leaderboardRank6,
    style: LeaderboardRowStyle.glass,
  ),
];

const currentLeaderboardEntry = LeaderboardEntryData(
  rank: 125,
  name: 'Tàu hủ đi chill',
  level: 9,
  score: '510.000',
  avatarAsset: AppAssets.avatarTauHuDiChill,
  rankAsset: AppAssets.leaderboardRankCurrent,
  style: LeaderboardRowStyle.currentUser,
  isCurrentUser: true,
);
