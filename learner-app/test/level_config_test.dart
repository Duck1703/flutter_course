import 'package:ai_millionaire_course/data/game/level_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// Port verbatim senior `test/level_config_test.dart` — M22.
/// Con số assert khớp từng giá trị reference (bảng milestone).
void main() {
  group('LevelConfig', () {
    test('getExpRequiredForLevel returns zero below minimum level', () {
      expect(LevelConfig.getExpRequiredForLevel(0), 0);
    });

    test('getExpRequiredForLevel returns base calculation for level one', () {
      expect(LevelConfig.getExpRequiredForLevel(1), 35000);
    });

    test('getExpRequiredForLevel applies milestone multiplier', () {
      expect(LevelConfig.getExpRequiredForLevel(4), 75000);
    });

    test('getExpRequiredForLevel applies major milestone multiplier', () {
      expect(LevelConfig.getExpRequiredForLevel(19), 375000);
    });

    test('getExpRequiredForLevel returns max requirement at max level', () {
      expect(
        LevelConfig.getExpRequiredForLevel(100),
        LevelConfig.maxExpRequirement,
      );
      expect(
        LevelConfig.getExpRequiredForLevel(101),
        LevelConfig.maxExpRequirement,
      );
    });

    test('getCumulativeExpForLevel sums previous level requirements', () {
      expect(LevelConfig.getCumulativeExpForLevel(1), 0);
      expect(
        LevelConfig.getCumulativeExpForLevel(5),
        LevelConfig.getExpRequiredForLevel(1) +
            LevelConfig.getExpRequiredForLevel(2) +
            LevelConfig.getExpRequiredForLevel(3) +
            LevelConfig.getExpRequiredForLevel(4),
      );
    });

    test('milestone helpers match Kotlin reference values', () {
      expect(LevelConfig.getMilestoneMultiplier(5), 1.5);
      expect(LevelConfig.getMilestoneMultiplier(20), 3.0);
      expect(LevelConfig.getMilestoneMultiplier(3), 1.0);
      expect(LevelConfig.isMilestoneLevel(5), isTrue);
      expect(LevelConfig.isMilestoneLevel(8), isFalse);
      expect(LevelConfig.isMajorMilestone(20), isTrue);
      expect(LevelConfig.isMajorMilestone(30), isFalse);
    });
  });
}
