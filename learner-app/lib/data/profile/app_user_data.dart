import '../auth/auth_session_data.dart';
import 'user_profile_data.dart';

/// Dòng `public.users` của Supabase — M25, port nguyên văn senior
/// `data/profile/app_user_data.dart`.
///
/// Đây là lớp biên giữa `UserProfileData` (local, SharedPreferences)
/// và row remote: `fromMap` đọc row trả về, `toUpsertMap` ghi payload
/// upsert, `fromProfile`/`toProfile` chuyển đổi hai phía. Parse phòng
/// thủ (`_stringValue`/`_nullableStringValue`/`_intValue`) — giá trị
/// xấu/thiếu rơi về default của `UserProfileData` thay vì ném.
class AppUserData {
  final String authUuid;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final int currentExp;
  final int totalGamesPlayed;
  final int totalQuestionCount;
  final int totalMoneyWon;

  const AppUserData({
    required this.authUuid,
    required this.displayName,
    this.avatarUrl,
    required this.level,
    required this.currentExp,
    required this.totalGamesPlayed,
    required this.totalQuestionCount,
    required this.totalMoneyWon,
  });

  factory AppUserData.fromMap(Map<String, dynamic> map) {
    const defaults = UserProfileData();

    return AppUserData(
      authUuid: _stringValue(map['auth_uuid'], ''),
      displayName: _stringValue(map['name'], defaults.username),
      avatarUrl: _nullableStringValue(map['avatar_url']),
      level: _intValue(map['level'], defaults.level),
      currentExp: _intValue(map['current_exp'], defaults.currentExp),
      totalGamesPlayed: _intValue(
        map['total_games_played'],
        defaults.gamesJoined,
      ),
      totalQuestionCount: _intValue(
        map['total_question_count'],
        defaults.totalQuestionCount,
      ),
      totalMoneyWon: _intValue(map['total_money_won'], defaults.totalMoneyWon),
    );
  }

  factory AppUserData.fromProfile({
    required AuthSessionAuthenticated session,
    required UserProfileData profile,
  }) {
    return AppUserData(
      authUuid: session.uid,
      displayName: profile.username,
      avatarUrl: profile.avatarUrl,
      level: profile.level,
      currentExp: profile.currentExp,
      totalGamesPlayed: profile.gamesJoined,
      totalQuestionCount: profile.totalQuestionCount,
      totalMoneyWon: profile.totalMoneyWon,
    );
  }

  Map<String, Object?> toUpsertMap() {
    return {
      'auth_uuid': authUuid,
      'name': displayName,
      'avatar_url': avatarUrl,
      'level': level,
      'current_exp': currentExp,
      'total_games_played': totalGamesPlayed,
      'total_question_count': totalQuestionCount,
      'total_money_won': totalMoneyWon,
    };
  }

  UserProfileData toProfile() {
    return UserProfileData(
      username: displayName,
      level: level,
      totalEarnings: UserProfileData.formatVnd(totalMoneyWon),
      currentExp: currentExp,
      totalQuestionCount: totalQuestionCount,
      totalMoneyWon: totalMoneyWon,
      gamesJoined: totalGamesPlayed,
      gamesWon: 0,
      avatarUrl: avatarUrl,
    );
  }

  static String _stringValue(Object? value, String fallback) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return fallback;
  }

  static String? _nullableStringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }

  static int _intValue(Object? value, int fallback) {
    if (value is int && value >= 0) {
      return value;
    }

    return fallback;
  }
}

/// Merge local ↔ remote khi sync — M25, port nguyên văn senior
/// (`mergeUserProfileForSync` trong `app_user_data.dart`).
///
/// Luật senior:
/// - Session (Google/Apple identity) THẮNG phần danh tính: `username`
///   ưu tiên `session.displayName`, fallback remote name, cuối cùng
///   leader's username; `avatarUrl` ưu tiên `session.photoUrl`.
/// - Progression theo "leader": profile có level cao hơn thắng; bằng
///   level → `currentExp` cao hơn thắng. Các tổng tích luỹ
///   (`totalMoneyWon`, `totalQuestionCount`, `gamesJoined`) lấy MAX.
/// - `gamesWon` giữ LOCAL — bảng `users` không có cột tương ứng.
/// - Profile demo cũ của app (`_hasDemoProgression`) bị normalize về
///   rỗng trước khi merge — tiến trình fake không được đẩy lên remote.
/// - Remote null → chỉ đắp danh tính session lên local đã normalize.
UserProfileData mergeUserProfileForSync({
  required AuthSessionAuthenticated session,
  required UserProfileData localProfile,
  required AppUserData? remoteProfile,
}) {
  final sessionName = _nonEmpty(session.displayName);
  final sessionPhoto = _nonEmpty(session.photoUrl);
  final normalizedLocalProfile = _withoutDemoProgression(localProfile);

  if (remoteProfile == null) {
    return normalizedLocalProfile.copyWith(
      username: sessionName ?? normalizedLocalProfile.username,
      avatarUrl: sessionPhoto ?? normalizedLocalProfile.avatarUrl,
    );
  }

  final remoteAsProfile = remoteProfile.toProfile();
  final levelLeader = _higherLevelProgressionProfile(
    remoteAsProfile,
    normalizedLocalProfile,
  );
  final totalMoneyWon = _maxInt(
    remoteAsProfile.totalMoneyWon,
    normalizedLocalProfile.totalMoneyWon,
  );

  return levelLeader.copyWith(
    username:
        sessionName ??
        _nonEmpty(remoteProfile.displayName) ??
        levelLeader.username,
    avatarUrl:
        sessionPhoto ??
        normalizedLocalProfile.avatarUrl ??
        remoteProfile.avatarUrl,
    totalEarnings: UserProfileData.formatVnd(totalMoneyWon),
    totalMoneyWon: totalMoneyWon,
    totalQuestionCount: _maxInt(
      remoteAsProfile.totalQuestionCount,
      normalizedLocalProfile.totalQuestionCount,
    ),
    gamesJoined: _maxInt(
      remoteProfile.totalGamesPlayed,
      normalizedLocalProfile.gamesJoined,
    ),
    gamesWon: normalizedLocalProfile.gamesWon,
  );
}

UserProfileData _higherLevelProgressionProfile(
  UserProfileData left,
  UserProfileData right,
) {
  if (left.level != right.level) {
    return left.level > right.level ? left : right;
  }

  return left.currentExp >= right.currentExp ? left : right;
}

int _maxInt(int left, int right) => left >= right ? left : right;

String? _nonEmpty(String? value) {
  if (value != null && value.trim().isNotEmpty) {
    return value;
  }

  return null;
}

UserProfileData _withoutDemoProgression(UserProfileData profile) {
  if (!_hasDemoProgression(profile)) {
    return profile;
  }

  return profile.copyWith(
    username: UserProfileData.defaultUsername,
    level: UserProfileData.defaultLevel,
    currentExp: 0,
    totalQuestionCount: 0,
    totalEarnings: UserProfileData.formatVnd(0),
    totalMoneyWon: 0,
    gamesJoined: 0,
    gamesWon: 0,
  );
}

bool _hasDemoProgression(UserProfileData profile) {
  return profile ==
      const UserProfileData(
        username: 'TÀU HỦ ĐI CHILL',
        level: 12,
        totalEarnings: '1.000.000 VNĐ',
        totalMoneyWon: 1000000,
        gamesJoined: 20,
        gamesWon: 12,
      );
}
