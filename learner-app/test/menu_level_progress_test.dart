import 'package:ai_millionaire_course/data/game/level_config.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_level_progress.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test `MenuLevelProgress` — M22. Port các case DATA thuần của senior
/// `test/widgets/menu_level_progress_card_test.dart` (phần widget glass
/// card/ring gradient là M28 — visual scope, không port ở đây).
void main() {
  group('MenuLevelProgress.fromProfile', () {
    test('progress targets the experience required for the current level', () {
      const profile = UserProfileData(level: 3, currentExp: 12400);
      final progress = MenuLevelProgress.fromProfile(profile);

      expect(progress.requiredExp, LevelConfig.getExpRequiredForLevel(3));
      expect(progress.requiredExp, 45000);
      expect(progress.remainingExp, 32600);
      expect(progress.nextLevel, 4);
      expect(progress.ratio, closeTo(12400 / 45000, 0.0001));
      expect(progress.isMaxLevel, isFalse);
    });

    test('progress clamps negative experience and out-of-range levels', () {
      final belowMin = MenuLevelProgress.fromProfile(
        const UserProfileData(level: 0, currentExp: -50),
      );

      expect(belowMin.level, LevelConfig.minLevel);
      expect(belowMin.currentExp, 0);
      expect(belowMin.ratio, 0);
    });

    test('max level reads as complete with nothing remaining', () {
      final progress = MenuLevelProgress.fromProfile(
        const UserProfileData(level: LevelConfig.maxLevel, currentExp: 10),
      );

      expect(progress.isMaxLevel, isTrue);
      expect(progress.ratio, 1);
      expect(progress.remainingExp, 0);
      expect(progress.nextLevel, LevelConfig.maxLevel);
    });

    test('formatted getters group digits with dots', () {
      final progress = MenuLevelProgress.fromProfile(
        const UserProfileData(level: 3, currentExp: 12400),
      );

      expect(progress.formattedCurrentExp, '12.400');
      expect(progress.formattedRequiredExp, '45.000');
      expect(progress.formattedRemainingExp, '32.600');
    });
  });

  group('level ring tier', () {
    test('tier follows the milestones the level has passed', () {
      MenuLevelTier tierAt(int level) =>
          MenuLevelProgress.fromProfile(UserProfileData(level: level)).tier;

      expect(tierAt(1), MenuLevelTier.base);
      expect(tierAt(4), MenuLevelTier.base);
      expect(tierAt(5), MenuLevelTier.milestone);
      expect(tierAt(19), MenuLevelTier.milestone);
      expect(tierAt(20), MenuLevelTier.major);
      // Passing a later regular milestone must not demote a major tier.
      expect(tierAt(30), MenuLevelTier.major);
      expect(tierAt(LevelConfig.maxLevel), MenuLevelTier.major);
    });
  });
}
