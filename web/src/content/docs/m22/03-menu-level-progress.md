---
title: "Bài 3 · MenuLevelProgress — view suy ra từ profile"
description: "Port menu_level_progress.dart (MenuLevelTier + fromProfile + ratio/formatted getters), rewire _LevelCard đọc progress thay expForNextLevel/expPercent. Vẫn chưa xoá field cũ — đó là việc của Bài 4. Suite 164 → 169."
sidebar:
  label: "Bài 3 · MenuLevelProgress"
  order: 3
---

## Mục tiêu

- Tạo `lib/view_models/menu/menu_level_progress.dart` — port senior.
- `_LevelCard` chuyển nguồn dữ liệu: `MenuLevelProgress.fromProfile(
  profile)` thay `profile.expForNextLevel`/`profile.expPercent`.
- Thêm `test/menu_level_progress_test.dart` (5 test) → **164 → 169**.

## Bạn đang ở đâu

- Bài 2: `LevelConfig` đã có — giờ cần "adapter" biến profile thành
  bộ giá trị menu cần (level đã kẹp, ngưỡng hiện tại, tỉ lệ 0..1,
  chuỗi format).
- Thanh EXP trên menu đang đọc `profile.expForNextLevel` + `expPercent`
  — hai member learner-only sẽ retire trong Bài 4 cùng `gainExp`.
  Bài này *đổi nguồn đọc trước*, Bài 4 mới xoá field — tách "đổi
  điểm đọc" khỏi "xoá model" để mỗi bước còn compile.

## Vì sao việc này quan trọng ngay bây giờ

`MenuLevelProgress` là ví dụ sạch của pattern **derived view-model**
(concept mới): model `UserProfileData` giữ `level` + `currentExp`
thô; mọi con số "để hiển thị" (required, remaining, ratio, formatted)
được *suy ra* qua `fromProfile` — không lưu thêm field, không đồng bộ
hai nguồn.

Bài học ẩn: `expForNextLevel` của learner là một field **dư thừa** —
nó có thể suy ra từ `level` qua `LevelConfig`. Dữ liệu suy được thì
đừng lưu: lưu là phải maintain đồng bộ (và đúng là learner đã phải
maintain `gainExp` cập nhật cả hai).

## Bạn đã biết gì

- `LevelConfig.getExpRequiredForLevel` (Bài 2).
- `factory` ctor + `@immutable` class + `==`/`hashCode`.
- `double.clamp(0.0, 1.0)`; `int.clamp` (LevelConfig min/max).
- `Expanded(flex:)` bar hai đoạn (M14 `_LevelCard`).

## Dart/Flutter cần dùng — xuất hiện đầu tiên

| Construct | Vai trò |
|---|---|
| `enum MenuLevelTier { base, milestone, major }` | tier ring senior — M22 chỉ dùng data, visual tier → M28 |
| `MenuLevelProgress.fromProfile(profile)` | factory derive: profile thô → view đầy đủ |
| `progress.ratio` (`double` 0..1) | nguồn fill của bar — thay `expPercent` int 1–99 |
| `formattedCurrentExp`/`formattedRequiredExp`/`formattedRemainingExp` | `formatThousands` dot-grouping sẵn cho UI |

## Code — `lib/view_models/menu/menu_level_progress.dart`

Port verbatim (đã Việt hoá doc; body giống senior từng dòng):

```dart
import 'package:flutter/foundation.dart';

import '../../data/game/level_config.dart';
import '../../data/profile/user_profile_data.dart';

/// Tier hiển thị của ring level trên menu — M22, port senior
/// `lib/view_models/menu/menu_level_progress.dart`.
///
/// Suy ra từ bảng milestone của [LevelConfig] để ring phản ánh bản thân
/// cấp độ; tiến trình EXP thuộc thanh bên cạnh (hai thứ không tranh
/// nhau một ý nghĩa). M22 mới chỉ dùng data — visual ring/glow → M28.
enum MenuLevelTier { base, milestone, major }

/// View trình bày của EXP mà menu hiển thị quanh ring level.
///
/// [UserProfileData.currentExp] giữ EXP kiếm được TRONG level hiện tại,
/// nên mục tiêu là [LevelConfig.getExpRequiredForLevel] của level đó —
/// không phải tổng tích lũy.
@immutable
class MenuLevelProgress {
  final int level;
  final int currentExp;
  final int requiredExp;

  const MenuLevelProgress({
    required this.level,
    required this.currentExp,
    required this.requiredExp,
  });

  factory MenuLevelProgress.fromProfile(UserProfileData profile) {
    final level = profile.level.clamp(
      LevelConfig.minLevel,
      LevelConfig.maxLevel,
    );

    return MenuLevelProgress(
      level: level,
      currentExp: profile.currentExp < 0 ? 0 : profile.currentExp,
      requiredExp: LevelConfig.getExpRequiredForLevel(level),
    );
  }

  bool get isMaxLevel => level >= LevelConfig.maxLevel;

  /// Tier milestone cao nhất mà level này đã đi qua.
  MenuLevelTier get tier {
    var reached = MenuLevelTier.base;

    for (var passed = LevelConfig.minLevel; passed <= level; passed++) {
      if (LevelConfig.isMajorMilestone(passed)) {
        return MenuLevelTier.major;
      }

      if (LevelConfig.isMilestoneLevel(passed)) {
        reached = MenuLevelTier.milestone;
      }
    }

    return reached;
  }

  int get nextLevel => isMaxLevel ? level : level + 1;

  int get remainingExp {
    if (isMaxLevel) {
      return 0;
    }

    final remaining = requiredExp - currentExp;
    return remaining < 0 ? 0 : remaining;
  }

  /// Độ đầy của ring/bar trong 0..1. Level max luôn đọc là đầy.
  double get ratio {
    if (isMaxLevel) {
      return 1;
    }

    if (requiredExp <= 0) {
      return 0;
    }

    return (currentExp / requiredExp).clamp(0.0, 1.0);
  }

  String get formattedCurrentExp => UserProfileData.formatThousands(currentExp);

  String get formattedRequiredExp =>
      UserProfileData.formatThousands(requiredExp);

  String get formattedRemainingExp =>
      UserProfileData.formatThousands(remainingExp);

  @override
  bool operator ==(Object other) {
    return other is MenuLevelProgress &&
        other.level == level &&
        other.currentExp == currentExp &&
        other.requiredExp == requiredExp;
  }

  @override
  int get hashCode => Object.hash(level, currentExp, requiredExp);
}
```

Ba guard đáng học (senior phòng thủ cả ở lớp *hiển thị*):

- `level` kẹp `[minLevel, maxLevel]`, `currentExp` kẹp `>= 0` —
  profile hỏng trên disk không làm UI hiển thị "CẤP 0" hay ratio âm.
- `requiredExp <= 0` → `ratio = 0` (chia-cho-0 không thể xảy ra).
- `isMaxLevel` → `ratio = 1`, `remainingExp = 0`, `nextLevel = level`
  — trần cấp đọc là "đã đầy", không phải "9e15 còn thiếu".

## Code — rewire `_LevelCard` trong `menu_screen.dart`

Đổi nguồn đọc — ba chỗ trong `build` của `_LevelCard`:

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final progress = MenuLevelProgress.fromProfile(profile);
  // `Expanded` yêu cầu flex > 0 — kẹp % trong 1–99 (ngữ nghĩa cũ của
  // `expPercent` learner, giờ suy từ `progress.ratio`).
  final expPercent = (progress.ratio * 100).round().clamp(1, 99);
  ...
  Text(
    // `progress.level` đã kẹp 1..100 — nhãn và thanh bar
    // luôn đọc CÙNG một level (profile hỏng cũng không lệch).
    l10n.profileLevel(progress.level),              // trước: profile.level
  ...
  l10n.menuExpProgress(
    progress.currentExp,                          // trước: profile.currentExp
    progress.requiredExp,                         // trước: profile.expForNextLevel
  )
  ...
  Expanded(flex: expPercent, …)                   // trước: profile.expPercent
  Expanded(flex: 100 - expPercent, …)
}
```

+ `import '../view_models/menu/menu_level_progress.dart';` ở đầu file.

> `profileLevel(progress.level)` (không phải `profile.level`) — nhãn
> và bar luôn đọc *cùng một* level đã kẹp; profile lỗi `level: 0`
> trên disk thì cả hai cùng hiển thị "CẤP 1".

## Test — `test/menu_level_progress_test.dart`

Port các case data-thuần của senior (phần widget glass-card/ring là
M28 — không port ở đây):

```dart
import 'package:ai_millionaire_course/data/game/level_config.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_level_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MenuLevelProgress.fromProfile', () {
    test('progress targets the experience required for the current level',
        () {
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
      // Mốc milestone thường sau đó KHÔNG hạ tier major.
      expect(tierAt(30), MenuLevelTier.major);
      expect(tierAt(LevelConfig.maxLevel), MenuLevelTier.major);
    });
  });
}
```

## Android / Compose bridge

```text
SIMILARITY:           `fromProfile` suy `requiredExp`/`ratio`/`tier`
                      từ profile thô ≈ `derivedStateOf { }` trong
                      Compose hay computed property trên ViewState —
                      UI không tự tra bảng, nhận view đã chuẩn bị.
IMPORTANT DIFFERENCE: đây là class immutable thường, KHÔNG phải
                      snapshot-state của Compose — mỗi emit của
                      profile stream tạo object mới; `==`/`hashCode`
                      được override đúng để so value.
DO NOT ASSUME:        đừng nhét `requiredExp` trở lại model
                      `UserProfileData` "cho tiện" — đó chính là
                      field `expForNextLevel` vừa retire (derived
                      data để trong view, không lưu trong model).
```

## Checkpoint

- `flutter analyze` sạch (field `expForNextLevel` vẫn còn trong model —
  Bài 4 mới xoá; giờ nó chỉ là field không còn ai đọc từ UI).
- `flutter test` → **169/169**.
- Mở menu (hoặc `flutter run`): thanh EXP và "x / y EXP" hiển thị y
  hệt như trước — nguồn khác, kết quả giống.

## Tự làm — RECOGNIZE→MODIFY

1. **RECOGNIZE:** Với `UserProfileData(level: 19, currentExp: 5000)` —
   `tier` là gì? `requiredExp` là bao nhiêu?
2. **MODIFY (sandbox, không merge):** trong test file, thêm case
   `level: 100, currentExp: 999999` → assert `ratio == 1`,
   `remainingExp == 0`. Chạy `flutter test test/menu_level_progress_test.dart`.

<details>
<summary>Đáp án bước 1</summary>

- `tier = MenuLevelTier.milestone` — đã qua mốc 5/10/15 (×1.5) nhưng
  chưa qua major (20).
- `requiredExp = getExpRequiredForLevel(19)` = `(30000+19×5000)×3` vì
  đích 20 là major → `125000 × 3` = **375000**.

</details>
