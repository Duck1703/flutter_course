import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_design_tokens.dart';
import '../../../l10n/app_localizations.dart';

/// Full-width menu row that opens the leaderboard popup. It replaces the
/// 44px trophy icon so the ranking has a visible entry point.
class LeaderboardEntryCard extends StatelessWidget {
  final VoidCallback? onTap;

  const LeaderboardEntryCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: onTap != null,
      excludeSemantics: true,
      label: l10n.leaderboardSemanticLabel,
      child: GestureDetector(
        key: const ValueKey('menu-leaderboard-entry'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTokens.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radius4),
            border: Border.all(color: AppTokens.white16),
            gradient: AppTokens.menuEntryGradient,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                AppAssets.iconTrophy,
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(
                  AppTokens.white100,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: AppTokens.spacingSm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.leaderboardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.qzdsSubtitle2.copyWith(
                        color: AppTokens.white100,
                      ),
                    ),
                    Text(
                      l10n.menuLeaderboardEntrySubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.label1.copyWith(
                        color: AppTokens.white72,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: AppTokens.iconLg,
                color: AppTokens.white65,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
