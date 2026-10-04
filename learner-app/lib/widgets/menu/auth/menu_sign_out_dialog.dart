import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../core/onboarding_design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_game_button.dart';
import '../settings/settings_dialog_shell.dart';

class MenuSignOutDialog extends StatelessWidget {
  final VoidCallback onSignOut;
  final VoidCallback? onCancel;

  const MenuSignOutDialog({
    super.key,
    required this.onSignOut,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDialogShell(
      headerText: l10n.accountTitle.toUpperCase(),
      iconAsset: AppAssets.iconLevelRank,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.signOutPrompt,
            textAlign: TextAlign.center,
            style: AppTokens.qzdsBody1.copyWith(
              color: AppTokens.qzdsBlack600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppTokens.spacingMd),
          OnboardingGameButton(
            text: l10n.signOutButton,
            color: AppTokens.red500,
            icon: Icons.logout,
            onTap: onSignOut,
          ),
          const SizedBox(height: AppTokens.spacingXs),
          OnboardingGameButton(
            text: l10n.cancelButton,
            color: OnboardingTokens.grey600,
            icon: Icons.close,
            onTap: onCancel,
          ),
        ],
      ),
    );
  }
}
