import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';

class GameMoneyLadderCtaButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const GameMoneyLadderCtaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppTokens.radiusN);

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTokens.green500,
          borderRadius: borderRadius,
          border: Border.all(color: AppTokens.white100.withValues(alpha: 0.24)),
          boxShadow: [
            BoxShadow(
              color: AppTokens.green500.withValues(alpha: 0.2),
              blurRadius: AppTokens.spacingLg,
            ),
            BoxShadow(
              color: AppTokens.qzdsPurple100.withValues(alpha: 0.28),
              blurRadius: AppTokens.spacingXs,
              spreadRadius: -AppTokens.spacingXxs,
            ),
          ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style:
              TextButton.styleFrom(
                foregroundColor: AppTokens.white100,
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ).copyWith(
                overlayColor: WidgetStatePropertyAll(
                  AppTokens.white100.withValues(alpha: 0.08),
                ),
              ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: surfaceGlow(
                AppTokens.white100.withValues(alpha: 0.32),
              ),
            ),
            // TextButton hands its child loose constraints (it centres it in an
            // Align), so the width has to be claimed back here — otherwise the
            // glow gradient above shrinks to the label and stops short of the
            // pill's ends.
            child: SizedBox(
              width: double.infinity,
              height: AppTokens.qzdsButtonHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.qzdsButtonHorizontalPadding,
                ),
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
                        style: AppTokens.body5.copyWith(
                          color: AppTokens.white100,
                          shadows: const [
                            Shadow(
                              color: AppTokens.white100,
                              blurRadius: AppTokens.spacingXs,
                            ),
                          ],
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
