import 'package:flutter/material.dart';

import '../../core/app_design_tokens.dart';

class QzdsGameButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onTap;
  final bool textGlow;
  final bool lightShadow;

  /// Drawn before the label. Icons carry the action at a glance, which is what
  /// lets the label drop to 14px without the button reading as ambiguous.
  final IconData? icon;

  final QzdsButtonScale scale;

  const QzdsGameButton({
    super.key,
    required this.text,
    required this.color,
    required this.onTap,
    this.textGlow = false,
    this.lightShadow = false,
    this.icon,
    this.scale = QzdsButtonScale.compact,
  });

  /// [QzdsButtonScale.compact] pins the height so stacked dialog actions stay
  /// short; [QzdsButtonScale.large] lets the old vertical padding set it.
  Widget _label() {
    final isCompact = scale == QzdsButtonScale.compact;

    final content = ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon case final iconData?) ...[
            Icon(
              iconData,
              size: AppTokens.qzdsIconSm,
              color: AppTokens.white100,
            ),
            const SizedBox(width: AppTokens.spacingXs),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (isCompact ? AppTokens.body5 : AppTokens.qzdsSubtitle2)
                  .copyWith(
                    color: AppTokens.white100,
                    shadows: textGlow
                        ? const [
                            Shadow(
                              color: AppTokens.white100,
                              blurRadius: AppTokens.spacingXs,
                            ),
                          ]
                        : null,
                  ),
            ),
          ),
        ],
      ),
    );

    if (!isCompact) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppTokens.spacingLg,
          horizontal: AppTokens.spacingLg,
        ),
        child: content,
      );
    }

    return SizedBox(
      height: AppTokens.qzdsButtonHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.qzdsButtonHorizontalPadding,
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boxShadows = lightShadow
        ? [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: AppTokens.spacingLg,
            ),
            BoxShadow(
              color: AppTokens.qzdsPurple100.withValues(alpha: 0.28),
              blurRadius: AppTokens.spacingXs,
              spreadRadius: -AppTokens.spacingXxs,
            ),
          ]
        : [
            BoxShadow(
              color: color.withValues(alpha: 0.42),
              blurRadius: 28,
              spreadRadius: AppTokens.spacingXxs,
            ),
            BoxShadow(
              color: AppTokens.qzdsPurple100.withValues(alpha: 0.64),
              blurRadius: AppTokens.spacingMd,
              spreadRadius: -AppTokens.spacingXxs,
            ),
          ];

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTokens.radiusN),
            border: Border.all(
              color: AppTokens.white100.withValues(alpha: 0.24),
            ),
            boxShadow: boxShadows,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTokens.radiusN),
              gradient: surfaceGlow(AppTokens.white100.withValues(alpha: 0.32)),
            ),
            child: _label(),
          ),
        ),
      ),
    );
  }
}
