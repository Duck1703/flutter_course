import 'package:flutter/material.dart';
import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_screen_data.dart';
import '../../../l10n/app_localizations.dart';
import 'game_money_amount_motion.dart';

class GameMoneyAmount extends StatelessWidget {
  final GameMoneyData data;
  final VoidCallback? onTap;

  const GameMoneyAmount({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : AppTokens.motionMedium;

    return Semantics(
      button: onTap != null,
      label: l10n.prizeAmountSemanticLabel(data.amount),
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: _MoneyPill(data: data, duration: duration),
        ),
      ),
    );
  }
}

class _MoneyPill extends StatelessWidget {
  final GameMoneyData data;
  final Duration duration;

  const _MoneyPill({required this.data, required this.duration});

  static const Color _yellow500 = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppTokens.radiusN);

    return DecoratedBox(
      key: const ValueKey('game-money-amount-pill'),
      decoration: BoxDecoration(
        color: _yellow500,
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(color: Color(0x80FFFFFF), blurRadius: AppTokens.spacingXs),
          BoxShadow(
            color: Color(0x66FFC107),
            blurRadius: AppTokens.spacingMd,
            offset: Offset(0, AppTokens.spacingXs),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned.fill(child: _MoneyPillGlow()),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.spacingLg,
                vertical: AppTokens.spacingXs,
              ),
              child: GameMoneyAmountMotion(
                amount: data.amount,
                animationTrigger: data.animationTrigger,
                duration: duration,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyPillGlow extends StatelessWidget {
  const _MoneyPillGlow();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusN),
        border: Border.all(color: const Color(0xADFFFFFF)),
        gradient: surfaceGlow(const Color(0x6BFFFFFF)),
      ),
    );
  }
}
