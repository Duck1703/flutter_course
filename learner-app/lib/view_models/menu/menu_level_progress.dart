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
