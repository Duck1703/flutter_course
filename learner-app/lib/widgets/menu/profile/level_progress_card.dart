import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../view_models/menu/menu_level_progress.dart';

/// Glass card pairing the level dial with the experience readout, so the menu
/// answers "what is my next goal" instead of only "who am I".
///
/// The ring around the dial states the level tier; experience progress lives
/// only in the bar, so the two never compete for the same meaning.
class LevelProgressCard extends StatelessWidget {
  static const double ringSize = 116;
  static const double ringStrokeWidth = 10;
  static const double dialSize = 96;
  static const double barHeight = 6;

  /// Blur sigma of the neon halo behind the ring.
  static const double glowSigma = 3;

  final MenuLevelProgress progress;

  const LevelProgressCard({super.key, required this.progress});

  /// Ring ramp for a level tier.
  static LinearGradient ringGradientFor(MenuLevelTier tier) {
    return switch (tier) {
      MenuLevelTier.base => AppTokens.levelRingGradient,
      MenuLevelTier.milestone => AppTokens.levelRingMilestoneGradient,
      MenuLevelTier.major => AppTokens.levelRingMajorGradient,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radius4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radius4),
            border: Border.all(color: AppTokens.white20, width: 2),
            gradient: AppTokens.glassCardGradient,
          ),
          padding: const EdgeInsets.all(AppTokens.spacingLg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _LevelDial(progress: progress, levelLabel: l10n.menuLevelShort),
              const SizedBox(width: AppTokens.spacingLg),
              Expanded(child: _buildExperience(l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperience(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.menuExperienceLabel.toUpperCase(),
          style: AppTokens.caption2.copyWith(color: AppTokens.white55),
        ),
        const SizedBox(height: AppTokens.spacingXs),
        Text.rich(
          TextSpan(
            text: progress.formattedCurrentExp,
            style: AppTokens.numeric1.copyWith(color: AppTokens.white100),
            children: [
              TextSpan(
                text: ' / ${progress.formattedRequiredExp}',
                style: AppTokens.body3.copyWith(color: AppTokens.white65),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppTokens.spacingSm),
        _ExperienceBar(ratio: progress.ratio),
        const SizedBox(height: AppTokens.spacingSm),
        Text(
          progress.isMaxLevel
              ? l10n.menuMaxLevelReached
              : l10n.menuExpToNextLevel(
                  progress.formattedRemainingExp,
                  progress.nextLevel,
                ),
          style: AppTokens.label1.copyWith(color: AppTokens.white72),
        ),
      ],
    );
  }
}

class _LevelDial extends StatelessWidget {
  final MenuLevelProgress progress;
  final String levelLabel;

  const _LevelDial({required this.progress, required this.levelLabel});

  @override
  Widget build(BuildContext context) {
    final gradient = LevelProgressCard.ringGradientFor(progress.tier);
    final accent = gradient.colors.first;

    return SizedBox.square(
      dimension: LevelProgressCard.ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              key: const ValueKey('menu-level-ring'),
              painter: _LevelRingPainter(gradient: gradient),
            ),
          ),
          Container(
            width: LevelProgressCard.dialSize,
            height: LevelProgressCard.dialSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTokens.levelDialGradient,
            ),
            // Inset from the dial edge so a three-digit level never runs into
            // the ring around it.
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.spacingSm,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  levelLabel,
                  style: AppTokens.caption2.copyWith(color: accent),
                ),
                // Long levels stay inside the dial instead of clipping.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${progress.level}',
                      maxLines: 1,
                      style: AppTokens.numericXl.copyWith(
                        color: AppTokens.white100,
                        shadows: [
                          Shadow(
                            color: accent.withValues(alpha: 0.5),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Closed ring with an even diagonal ramp. Drawing the full circle keeps the
/// colour spread constant at every level, unlike an arc where the same ramp
/// gets squeezed into whatever fraction is currently filled.
class _LevelRingPainter extends CustomPainter {
  final LinearGradient gradient;

  const _LevelRingPainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - LevelProgressCard.ringStrokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = LevelProgressCard.ringStrokeWidth
        ..color = gradient.colors.first.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          LevelProgressCard.glowSigma,
        ),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = LevelProgressCard.ringStrokeWidth
        ..shader = gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_LevelRingPainter oldDelegate) =>
      oldDelegate.gradient != gradient;
}

/// Flat determinate meter matching the bootstrap splash bar: rounded track,
/// one solid fill colour, no gradient to spread unevenly.
class _ExperienceBar extends StatelessWidget {
  /// Smallest value drawn for non-zero progress, so a freshly gained level
  /// still shows a sliver instead of an empty track.
  static const double minVisibleValue = 0.02;

  final double ratio;

  const _ExperienceBar({required this.ratio});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      key: const ValueKey('menu-exp-bar'),
      value: ratio <= 0 ? 0 : ratio.clamp(minVisibleValue, 1),
      minHeight: LevelProgressCard.barHeight,
      backgroundColor: AppTokens.white20,
      color: AppTokens.mint500,
      borderRadius: BorderRadius.circular(AppTokens.radiusN),
    );
  }
}
