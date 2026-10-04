---
title: "Bài 2 · LevelConfig — bảng milestone-multiplier"
description: "Port verbatim lib/data/game/level_config.dart từ senior: static const config table (Map<int,double>), getExpRequiredForLevel với multiplier theo level đích, maxLevel=100. Thêm 7 unit test — bài này chỉ THÊM, chưa nối vào VM."
sidebar:
  label: "Bài 2 · LevelConfig"
  order: 2
---

## Mục tiêu

- Tạo `lib/data/game/level_config.dart` — port nguyên bản senior.
- Hiểu công thức ngưỡng: `(baseExp + level × growthPerLevel) ×
  multiplier(level + 1)`.
- Thêm `test/level_config_test.dart` (7 test port từ senior) → suite
  **157 → 164**.

Bài này **thuần additive**: file mới + test mới, không đụng code cũ.

## Bạn đang ở đâu

- Bài 1: save nằm trong VM; EXP = `earnedAmount` — cần một "bảng
  ngưỡng theo level" để biết khi nào lên cấp.
- Learner đang có curve tạm: `gainExp` tăng ngưỡng ×1.5 mỗi cấp
  (register FR-01/FR-03 — scaffold chờ đúng M22 này để retire).
  `LevelConfig` là bản thật của nó.

## Vì sao việc này quan trọng ngay bây giờ

Progression là *game-design data*, không phải logic rải rác. Senior
gom toàn bộ vào một class `static const`: đổi độ khó = sửa một map,
không đào code. Một bảng tra cứu + một hàm đọc — đó là toàn bộ.

So sánh hai curve để thấy cái scaffold tạm khác gì:

| Cấp | learner cũ (`expForNextLevel`, ×1.5/cấp) | senior `getExpRequiredForLevel` |
|---|---|---|
| 1 → 2 | 35000 | 35000 (`(30000+5000)×1`) |
| 2 → 3 | 52500 | 40000 (`(30000+10000)×1`) |
| 4 → 5 | 118125 | 75000 (`(30000+20000)×1.5` — đích là mốc 5) |
| 100 → — | ∞ tự nhiên | `maxExpRequirement` (không lên nữa) |

Curve learner tăng theo hàm mũ vô hạn; senior là **tuyến tính nhân
mốc**: mỗi cấp trả `(baseExp + level×growth)` nhân hệ số của *level
đích* — chỉ mốc 5/10/15/20/… mới nhảy hệ số, và level 100 là trần.

## Bạn đã biết gì

- `static const` field + `Map<K,V>` literal (D-15).
- `factory`/`const ctor` (D-16); `class` private ctor `LevelConfig._()`
  = "namespace chỉ chứa statics".
- `for` loop cộng dồn (D-07); `int.clamp(min,max)`.
- Unit test `test`/`expect`/`group` (D-23 — MASTERED).

## Dart/Flutter cần dùng — xuất hiện đầu tiên

| Construct | Vai trò |
|---|---|
| `static const _map = <int, double>{5: 1.5, …}` | bảng tra cứu compile-time — **config table** |
| `map[key] ?? 1` | mốc không có trong bảng → hệ số mặc định 1 |
| `while (level < max) { if (exp < need) break; … }` | vòng lặp "đốt" ngưỡng từng cấp — dùng ở Bài 4 |
| `9007199254740991` | sentinel "vô cực" an toàn cho dart2js (JS chỉ chính xác tới 2^53−1) |

Bảng multiplier + vòng `while` thăng cấp + kẹp min/max là **D-38**
(NORMAL): *config-table progression* — đọc là được, không cần thuộc.

:::note[Divergence duy nhất so với senior]
Senior viết `maxExpRequirement = 9223372036854775807` (int64 max).
Hằng đó **không compile được cho web** — JS chỉ biểu diễn int chính
xác đến `2^53 − 1` (`9007199254740991`). Learner đổi literal sentinel;
ngữ nghĩa giống hệt (EXP thật không bao giờ chạm ngưỡng này — nó chỉ
cần "lớn hơn mọi EXP khả dĩ"). Ghi chú này có trong doc comment file.
:::

## Code — tạo `lib/data/game/level_config.dart`

Port verbatim (doc comment Việt hoá, còn lại y senior):

```dart
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
```

Chi tiết đáng để ý: `getExpRequiredForLevel(level)` nhân hệ số của
**`level + 1`** — level ĐÍCH. Ngưỡng "1→2" dùng multiplier của 2
(=1); "4→5" dùng multiplier của 5 (=1.5). Đọc nhầm "multiplier của
level hiện tại" là lỗi phổ biến nhất với bảng này.

## Test — `test/level_config_test.dart`

Port 7 test senior — mỗi test khóa một cạnh của công thức:

```dart
import 'package:ai_millionaire_course/data/game/level_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelConfig', () {
    test('getExpRequiredForLevel returns zero below minimum level', () {
      expect(LevelConfig.getExpRequiredForLevel(0), 0);
    });

    test('getExpRequiredForLevel returns base calculation for level one',
        () {
      expect(LevelConfig.getExpRequiredForLevel(1), 35000);
    });

    test('getExpRequiredForLevel applies milestone multiplier', () {
      expect(LevelConfig.getExpRequiredForLevel(4), 75000);
    });

    test('getExpRequiredForLevel applies major milestone multiplier', () {
      expect(LevelConfig.getExpRequiredForLevel(19), 375000);
    });

    test('getExpRequiredForLevel returns max requirement at max level', () {
      expect(LevelConfig.getExpRequiredForLevel(100),
          LevelConfig.maxExpRequirement);
      expect(LevelConfig.getExpRequiredForLevel(101),
          LevelConfig.maxExpRequirement);
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
```

## Android / Compose bridge

```text
SIMILARITY:           `object LevelConfig` + `mapOf<Int, Double>`
                      trong Kotlin — cùng ý tưởng config table, cùng
                      phép nhân milestone. Test port của learner thậm
                      chí giữ tên "milestone helpers match Kotlin
                      reference values".
IMPORTANT DIFFERENCE: Dart static-method class ≈ Kotlin `object`
                      singleton — nhưng `const LevelConfig._()`
                      private ctor chặn mọi `LevelConfig()` ngoài ý
                      muốn, còn `object` tự là singleton.
DO NOT ASSUME:        đừng cho rằng `static` field bị per-instance —
                      `baseExp`/`_milestoneMultipliers` tồn tại một
                      bản duy nhất, load cùng class.
```

## Checkpoint

- `flutter analyze` sạch.
- `flutter test` → **164/164** (157 + 7 mới).
- `flutter test test/level_config_test.dart` xanh lẻ.

## Tự làm — PREDICT

Tính tay, không code:

1. `getExpRequiredForLevel(9)` = ? (đích = 10, mốc ×1.5)
2. `getExpRequiredForLevel(29)` = ? (đích = 30, mốc ×2)
3. `getCumulativeExpForLevel(2)` = ?

<details>
<summary>Đáp án</summary>

1. `(30000 + 9×5000) × 1.5 = 75000 × 1.5` = **112500**.
2. `(30000 + 29×5000) × 2 = 175000 × 2` = **350000**.
3. Chỉ tổng ngưỡng của level 1 → **35000** (cumulative(2) = exp cần
   để *đến* level 2).

</details>
