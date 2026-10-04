import 'package:flutter/material.dart';
import '../../core/app_design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../common/qzds_game_button.dart';

class GradientCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const GradientCtaButton({super.key, this.label = '', this.onTap});

  @override
  Widget build(BuildContext context) {
    final buttonLabel = label.isEmpty
        ? AppLocalizations.of(context).startGameButton
        : label;

    return Padding(
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      child: SizedBox(
        width: double.infinity,
        child: QzdsGameButton(
          text: buttonLabel,
          color: AppTokens.qzdsPurple700,
          textGlow: true,
          scale: QzdsButtonScale.large,
          onTap: onTap,
        ),
      ),
    );
  }
}
