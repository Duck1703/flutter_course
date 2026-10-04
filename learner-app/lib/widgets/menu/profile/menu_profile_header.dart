import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/profile/user_profile_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/glass_icon_button.dart';
import 'profile_avatar_image.dart';

/// Top row of the menu: a tappable identity pill on the left and the settings
/// action on the right. The pill accent tells guests their progress is local.
class MenuProfileHeader extends StatelessWidget {
  static const double avatarSize = 36;

  final UserProfileData data;
  final bool isAuthenticated;
  final VoidCallback? onAccountTap;
  final VoidCallback? onSettingsTap;

  const MenuProfileHeader({
    super.key,
    required this.data,
    required this.isAuthenticated,
    this.onAccountTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacingMd,
        vertical: AppTokens.spacingXs,
      ),
      child: Row(
        children: [
          Expanded(child: _buildPill(l10n)),
          const SizedBox(width: AppTokens.spacingSm),
          GlassIconButton(
            assetIcon: AppAssets.iconGear,
            semanticLabel: l10n.settingsSemanticLabel,
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }

  Widget _buildPill(AppLocalizations l10n) {
    final accent = isAuthenticated
        ? AppTokens.mint500
        : AppTokens.qzdsYellow500;

    return Semantics(
      button: onAccountTap != null,
      label: l10n.accountSemanticLabel,
      child: GestureDetector(
        key: const ValueKey('menu-profile-pill'),
        behavior: HitTestBehavior.opaque,
        onTap: onAccountTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.qzdsIconSmPlus / 4,
            AppTokens.qzdsIconSmPlus / 4,
            AppTokens.spacingSm,
            AppTokens.qzdsIconSmPlus / 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusN),
            border: Border.all(
              color: isAuthenticated
                  ? AppTokens.white14
                  : accent.withValues(alpha: 0.45),
            ),
            gradient: isAuthenticated
                ? AppTokens.glassGradient
                : AppTokens.guestPillGradient,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                key: const ValueKey('menu-profile-avatar-frame'),
                width: avatarSize,
                height: avatarSize,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 2),
                ),
                child: ProfileAvatarImage(
                  data: data,
                  isAuthenticated: isAuthenticated,
                  size: avatarSize - 8,
                ),
              ),
              const SizedBox(width: AppTokens.qzdsSpacingSm),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAuthenticated ? data.username : l10n.menuGuestName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.body5.copyWith(
                        color: AppTokens.white100,
                      ),
                    ),
                    Text(
                      isAuthenticated
                          ? l10n.menuSyncedStatus
                          : l10n.menuGuestSyncHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.caption3.copyWith(color: accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
