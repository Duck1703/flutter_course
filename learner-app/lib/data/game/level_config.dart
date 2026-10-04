/// Bảng cấu hình EXP/level — M22, port verbatim từ senior
/// `lib/data/game/level_config.dart` (FR-01/FR-03 converge).
///
/// Ngưỡng EXP để lên từ `level` sang `level + 1`:
/// `(baseExp + level × growthPerLevel) × multiplier(level + 1)` —
/// multiplier > 1 chỉ ở các mốc milestone trong [_milestoneMultipliers].
/// Đây là "config table": con số game-design nằm trong một map tra cứu,
/// không rải magic number khắp code.
class LevelConfig {
  static const baseExp = 30000;
  static const growthPerLevel = 5000;
  static const minLevel = 1;
  static const maxLevel = 100;

  /// "Vô cực" cho ngưỡng ở max level — senior dùng `9223372036854775807`
  /// (int64 max); giá trị đó KHÔNG biểu diễn được trong JS (dart2js lỗi
  /// khi build web) nên learner dùng max-safe-int của JS
  /// (`2^53 - 1`). Ngữ nghĩa giữ nguyên: EXP thật không bao giờ chạm
  /// ngưỡng này → người chơi không lên quá [maxLevel].
  static const maxExpRequirement = 9007199254740991;

  /// Hệ số nhân ngưỡng tại mốc "level ĐÍCH" (target level):
  /// lên cấp 5/10/15 ×1.5; mốc major 20/40/60 ×3; 90 ×4; 100 ×5.
  static const _milestoneMultipliers = <int, double>{
    5: 1.5,
    10: 1.5,
    15: 1.5,
    20: 3,
    30: 2,
    40: 3,
    50: 2,
    60: 3,
    70: 2,
    80: 2,
    90: 4,
    100: 5,
  };

  const LevelConfig._();

  /// EXP cần để từ [level] lên `level + 1`. Dưới min → 0; ở max →
  /// [maxExpRequirement] (không bao giờ đủ → không lên nữa).
  static int getExpRequiredForLevel(int level) {
    if (level < minLevel) return 0;
    if (level >= maxLevel) return maxExpRequirement;

    final baseXp = baseExp + (level * growthPerLevel);
    final targetLevel = level + 1;
    final multiplier = getMilestoneMultiplier(targetLevel);
    return (baseXp * multiplier).toInt();
  }

  /// Tổng EXP đã đốt để đến [level] — tổng ngưỡng các level trước.
  static int getCumulativeExpForLevel(int level) {
    if (level <= minLevel) return 0;

    var total = 0;
    for (var index = minLevel; index < level; index++) {
      total += getExpRequiredForLevel(index);
    }

    return total;
  }

  /// Hệ số milestone của level đích — 1 khi không phải mốc.
  static double getMilestoneMultiplier(int targetLevel) {
    return _milestoneMultipliers[targetLevel] ?? 1;
  }

  static bool isMilestoneLevel(int level) {
    return _milestoneMultipliers.containsKey(level);
  }

  /// Mốc "major" (×3 trở lên) — senior dùng cho tier của ring M28.
  static bool isMajorMilestone(int level) {
    return getMilestoneMultiplier(level) >= 3;
  }
}
