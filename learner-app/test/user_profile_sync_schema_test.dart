import 'package:ai_millionaire_course/data/profile/app_user_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// M25 — port nguyên văn senior `test/user_profile_sync_schema_test.dart`:
/// khóa `toUpsertMap` với đúng cột `public.users` (constraint NOT NULL +
/// CHECK ≥ 0 + unique `auth_uuid`), và `fromMap` đọc row không có email.
void main() {
  test('upsert payload includes profile identity and progression fields', () {
    const appUser = AppUserData(
      authUuid: 'user-1',
      displayName: 'PLAYER',
      avatarUrl: 'https://example.com/avatar.png',
      level: 20,
      currentExp: 300,
      totalGamesPlayed: 7,
      totalQuestionCount: 40,
      totalMoneyWon: 50000,
    );

    expect(appUser.toUpsertMap(), {
      'auth_uuid': 'user-1',
      'name': 'PLAYER',
      'avatar_url': 'https://example.com/avatar.png',
      'level': 20,
      'current_exp': 300,
      'total_games_played': 7,
      'total_question_count': 40,
      'total_money_won': 50000,
    });
  });

  test('remote profile reads users row fields without email', () {
    final appUser = AppUserData.fromMap({
      'auth_uuid': 'user-1',
      'name': 'PLAYER',
      'avatar_url': 'https://example.com/avatar.png',
      'level': 20,
      'current_exp': 300,
      'total_games_played': 7,
      'total_question_count': 40,
      'total_money_won': 50000,
    });

    expect(appUser.displayName, 'PLAYER');
    expect(appUser.avatarUrl, 'https://example.com/avatar.png');
    expect(appUser.totalGamesPlayed, 7);
  });
}
