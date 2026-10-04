import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_screen_data.dart';

class GameAnswerOptionColors {
  /// Answer-state accents. Named by state rather than by hue step so they do
  /// not collide with the differently-valued [AppTokens] palette entries of
  /// the same hue name.
  static const selectedAccent = Color(0xFFFFCA28);
  static const correctAccent = Color(0xFF4CAF50);
  static const correctBorder = Color(0xFF388E3C);
  static const incorrectAccent = AppTokens.red500;
  static const incorrectBorder = AppTokens.red700;
  static const idleBorder = Color(0xB3FFFFFF);

  final Color background;
  final Color border;

  const GameAnswerOptionColors({
    required this.background,
    required this.border,
  });

  factory GameAnswerOptionColors.fromState(GameAnswerState state) {
    return switch (state) {
      GameAnswerState.idle => const GameAnswerOptionColors(
        background: AppTokens.white10,
        border: idleBorder,
      ),
      GameAnswerState.selected => GameAnswerOptionColors(
        background: selectedAccent.withValues(alpha: 0.5),
        border: selectedAccent,
      ),
      GameAnswerState.correct => GameAnswerOptionColors(
        background: correctAccent.withValues(alpha: 0.5),
        border: correctBorder,
      ),
      GameAnswerState.incorrect => GameAnswerOptionColors(
        background: incorrectAccent.withValues(alpha: 0.5),
        border: incorrectBorder,
      ),
    };
  }
}
