import 'package:flutter/material.dart';

import '../../core/app_design_tokens.dart';
import '../../core/onboarding_design_tokens.dart';

class OnboardingGameButton extends StatelessWidget {
  final String text;
  final Color color;
  final bool textGlow;
  final VoidCallback? onTap;

  /// Drawn before the label, matching `QzdsGameButton` so both button families
  /// read the same inside a dialog.
  final IconData? icon;

  /// Brand glyphs are drawn smaller than the rest of their em box, so the
  /// provider buttons scale their icon up to stay optically equal.
  final double iconSize;

  final QzdsButtonScale scale;

  const OnboardingGameButton({
    super.key,
    required this.text,
    required this.color,
    this.textGlow = false,
    this.onTap,
    this.icon,
    this.iconSize = AppTokens.qzdsIconSm,
    this.scale = QzdsButtonScale.compact,
  });

  @override
  Widget build(BuildContext context) {
    final label = text.toUpperCase();
    final isCompact = scale == QzdsButtonScale.compact;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: isCompact
              ? AppTokens.qzdsButtonHeight
              : OnboardingTokens.buttonHeightLarge,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTokens.radiusN),
            border: Border.all(color: AppTokens.white20, width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.42),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.64),
                blurRadius: 12,
                spreadRadius: -8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusN),
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: OnboardingTokens.buttonGlow),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.qzdsButtonHorizontalPadding,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon case final iconData?) ...[
                      Icon(iconData, size: iconSize, color: AppTokens.white100),
                      const SizedBox(width: AppTokens.spacingXs),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (isCompact
                                    ? AppTokens.body5
                                    : OnboardingTokens.subtitle2)
                                .copyWith(
                                  color: AppTokens.white100,
                                  shadows: textGlow
                                      ? const [
                                          Shadow(
                                            color: AppTokens.white100,
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
