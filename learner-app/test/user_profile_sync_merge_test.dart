import 'package:ai_millionaire_course/data/profile/app_user_data.dart';
import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// M25 — port nguyên văn senior `test/user_profile_sync_merge_test.dart`:
/// 7 case phủ luật merge `mergeUserProfileForSync` (leader progression,
/// max-totals, session-identity wins, zero-starter, demo-normalize).
void main() {
  test('merge keeps local progression when no remote profile exists', () {
    const localProfile = UserProfileData(
      username: 'LOCAL PLAYER',
      avatarUrl: 'local.png',
      level: 4,
      currentExp: 50,
      totalQuestionCount: 8,
      totalMoneyWon: 8000,
    );
    const session = AuthSessionAuthenticated(
      uid: 'user-1',
      displayName: 'Google Player',
      photoUrl: 'google.png',
    );

    final merged = mergeUserProfileForSync(
      session: session,
      localProfile: localProfile,
      remoteProfile: null,
    );

    expect(merged.username, 'Google Player');
    expect(merged.avatarUrl, 'google.png');
    expect(merged.level, localProfile.level);
    expect(merged.totalMoneyWon, localProfile.totalMoneyWon);
  });

  test('merge uses remote progression when remote money is greater', () {
    const localProfile = UserProfileData(
      username: 'LOCAL PLAYER',
      avatarUrl: 'local.png',
      level: 4,
      currentExp: 50,
      gamesJoined: 8,
      gamesWon: 5,
      totalQuestionCount: 8,
      totalMoneyWon: 8000,
    );
    const remoteProfile = AppUserData(
      authUuid: 'user-1',
      displayName: 'REMOTE PLAYER',
      level: 9,
      currentExp: 120,
      totalGamesPlayed: 30,
      totalQuestionCount: 30,
      totalMoneyWon: 30000,
    );

    final merged = mergeUserProfileForSync(
      session: const AuthSessionAuthenticated(uid: 'user-1'),
      localProfile: localProfile,
      remoteProfile: remoteProfile,
    );

    expect(merged.username, 'REMOTE PLAYER');
    expect(merged.avatarUrl, 'local.png');
    expect(merged.level, 9);
    expect(merged.currentExp, 120);
    expect(merged.totalQuestionCount, 30);
    expect(merged.totalMoneyWon, 30000);
    expect(merged.totalEarnings, '30.000 VNĐ');
    expect(merged.gamesJoined, 30);
    expect(merged.gamesWon, 5);
  });

  test('merge keeps local progression when local money is greater', () {
    const localProfile = UserProfileData(
      username: 'LOCAL PLAYER',
      avatarUrl: 'local.png',
      level: 11,
      currentExp: 200,
      totalQuestionCount: 40,
      totalMoneyWon: 50000,
    );
    const remoteProfile = AppUserData(
      authUuid: 'user-1',
      displayName: 'REMOTE PLAYER',
      level: 7,
      currentExp: 90,
      totalGamesPlayed: 12,
      totalQuestionCount: 12,
      totalMoneyWon: 12000,
    );

    final merged = mergeUserProfileForSync(
      session: const AuthSessionAuthenticated(uid: 'user-1'),
      localProfile: localProfile,
      remoteProfile: remoteProfile,
    );

    expect(merged.username, 'REMOTE PLAYER');
    expect(merged.avatarUrl, 'local.png');
    expect(merged.level, localProfile.level);
    expect(merged.currentExp, localProfile.currentExp);
    expect(merged.totalQuestionCount, localProfile.totalQuestionCount);
    expect(merged.totalMoneyWon, localProfile.totalMoneyWon);
  });

  test('merge keeps local exp and played games when money is unchanged', () {
    const localProfile = UserProfileData(
      username: 'LOCAL PLAYER',
      level: 1,
      currentExp: 250,
      gamesJoined: 1,
      totalQuestionCount: 1,
      totalMoneyWon: 0,
    );
    const remoteProfile = AppUserData(
      authUuid: 'user-1',
      displayName: 'REMOTE PLAYER',
      level: 1,
      currentExp: 0,
      totalGamesPlayed: 0,
      totalQuestionCount: 0,
      totalMoneyWon: 0,
    );

    final merged = mergeUserProfileForSync(
      session: const AuthSessionAuthenticated(uid: 'user-1'),
      localProfile: localProfile,
      remoteProfile: remoteProfile,
    );

    expect(merged.currentExp, 250);
    expect(merged.gamesJoined, 1);
    expect(merged.totalQuestionCount, 1);
    expect(merged.totalMoneyWon, 0);
  });

  test('session identity overrides remote profile identity', () {
    const localProfile = UserProfileData(totalMoneyWon: 100);
    const remoteProfile = AppUserData(
      authUuid: 'user-1',
      displayName: 'REMOTE PLAYER',
      level: 2,
      currentExp: 3,
      totalGamesPlayed: 4,
      totalQuestionCount: 4,
      totalMoneyWon: 500,
    );
    const session = AuthSessionAuthenticated(
      uid: 'user-1',
      displayName: 'SESSION PLAYER',
      photoUrl: 'session.png',
    );

    final merged = mergeUserProfileForSync(
      session: session,
      localProfile: localProfile,
      remoteProfile: remoteProfile,
    );

    expect(merged.username, 'SESSION PLAYER');
    expect(merged.avatarUrl, 'session.png');
  });

  test(
    'merge keeps new zero starter progression before first remote upsert',
    () {
      final merged = mergeUserProfileForSync(
        session: const AuthSessionAuthenticated(
          uid: 'user-1',
          displayName: 'SESSION PLAYER',
        ),
        localProfile: const UserProfileData(),
        remoteProfile: null,
      );

      expect(merged.username, 'SESSION PLAYER');
      expect(merged.level, 1);
      expect(merged.currentExp, 0);
      expect(merged.totalMoneyWon, 0);
      expect(merged.totalEarnings, '0 VNĐ');
      expect(merged.gamesJoined, 0);
      expect(merged.gamesWon, 0);
    },
  );

  test(
    'merge normalizes legacy demo progression before first remote upsert',
    () {
      final merged = mergeUserProfileForSync(
        session: const AuthSessionAuthenticated(
          uid: 'user-1',
          displayName: 'SESSION PLAYER',
        ),
        localProfile: const UserProfileData(
          username: 'TÀU HỦ ĐI CHILL',
          level: 12,
          totalEarnings: '1.000.000 VNĐ',
          totalMoneyWon: 1000000,
          gamesJoined: 20,
          gamesWon: 12,
        ),
        remoteProfile: null,
      );

      expect(merged.username, 'SESSION PLAYER');
      expect(merged.level, 1);
      expect(merged.totalMoneyWon, 0);
      expect(merged.totalEarnings, '0 VNĐ');
      expect(merged.gamesJoined, 0);
      expect(merged.gamesWon, 0);
    },
  );
}
