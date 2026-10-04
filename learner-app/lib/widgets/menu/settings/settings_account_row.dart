import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/profile/user_profile_data.dart';
import '../../../l10n/app_localizations.dart';
import '../profile/profile_avatar_image.dart';

/// Account block inside the settings dialog. Signing in and out used to be
/// reachable only by tapping the menu avatar; this surfaces both.
class SettingsAccountRow extends StatelessWidget {
  static const double avatarSize = 36;

  final UserProfileData data;
  final bool isAuthenticated;
  final VoidCallback? onAccountAction;

  const SettingsAccountRow({
    super.key,
    required this.data,
    required this.isAuthenticated,
    this.onAccountAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      key: const ValueKey('settings-account-row'),
      padding: const EdgeInsets.all(AppTokens.qzdsSpacingSm),
      decoration: BoxDecoration(
        color: isAuthenticated
            ? AppTokens.qzdsGrey100.withValues(alpha: 0.5)
            : AppTokens.qzdsPurple50.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusMd),
        border: Border.all(
          color: AppTokens.qzdsPurple100.withValues(
            alpha: isAuthenticated ? 0.3 : 0.6,
          ),
        ),
      ),
      child: Row(
        children: [
          if (isAuthenticated) ...[
            Container(
              width: avatarSize,
              height: avatarSize,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTokens.qzdsPurple600, width: 2),
              ),
              child: ProfileAvatarImage(
                data: data,
                isAuthenticated: true,
                size: avatarSize - 8,
              ),
            ),
            const SizedBox(width: AppTokens.qzdsSpacingSm),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAuthenticated ? data.username : l10n.menuGuestName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTokens.body5.copyWith(
                    color: isAuthenticated
                        ? AppTokens.qzdsBlack600
                        : AppTokens.qzdsPurple700,
                  ),
                ),
                Text(
                  isAuthenticated
                      ? l10n.menuSyncedStatus
                      : l10n.settingsGuestSyncHint,
                  style: AppTokens.caption3.copyWith(
                    color: AppTokens.qzdsBlack600.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.qzdsSpacingXs),
          _AccountActionButton(
            label: isAuthenticated ? l10n.signOutButton : l10n.signInButton,
            icon: isAuthenticated ? Icons.logout : Icons.login,
            filled: !isAuthenticated,
            onTap: onAccountAction,
          ),
        ],
      ),
    );
  }
}

class _AccountActionButton extends StatelessWidget {
  static const double _labelSize = 13;

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _AccountActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = label.toUpperCase();

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: AppTokens.qzdsChipHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingSm,
          ),
          decoration: BoxDecoration(
            color: filled ? AppTokens.qzdsPurple700 : null,
            borderRadius: BorderRadius.circular(AppTokens.radiusN),
            border: filled
                ? null
                : Border.all(color: AppTokens.red500.withValues(alpha: 0.4)),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: AppTokens.qzdsPurple700.withValues(alpha: 0.6),
                      blurRadius: AppTokens.spacingMd,
                      spreadRadius: -4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: AppTokens.qzdsIconXs,
                color: filled ? AppTokens.white100 : AppTokens.red500,
              ),
              const SizedBox(width: AppTokens.qzdsSpacingXs + 2),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTokens.body5.copyWith(
                    fontSize: _labelSize,
                    color: filled ? AppTokens.white100 : AppTokens.red500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
