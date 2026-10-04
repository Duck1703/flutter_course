import 'package:flutter/material.dart';
import '../../../core/app_design_tokens.dart';
import '../../../data/profile/user_profile_data.dart';
import '../../../l10n/app_localizations.dart';

/// Three compact tiles summarising play history. The win rate is derived from
/// the stored counters, so no extra profile field is required.
class StatsCard extends StatelessWidget {
  final UserProfileData data;

  const StatsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Tiles carry single-line text, so intrinsic sizing keeps them level
    // without stretching (which would demand an infinite height inside the
    // menu's IntrinsicHeight column).
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '${data.gamesJoined}',
            label: l10n.gamesJoinedLabel,
            valueColor: AppTokens.green400,
          ),
        ),
        const SizedBox(width: AppTokens.spacingXs),
        Expanded(
          child: _StatTile(
            value: '${data.gamesWon}',
            label: l10n.gamesWonLabel,
            valueColor: AppTokens.purple300,
          ),
        ),
        const SizedBox(width: AppTokens.spacingXs),
        Expanded(
          child: _StatTile(
            key: const ValueKey('menu-stat-win-rate'),
            value: formatWinRate(data),
            label: l10n.menuWinRateLabel,
            valueColor: AppTokens.mint500,
          ),
        ),
      ],
    );
  }

  /// Rounded percentage of finished games that were won, or an em dash when no
  /// game has been played yet.
  static String formatWinRate(UserProfileData data) {
    if (data.gamesJoined <= 0) {
      return '—';
    }

    final rate = data.gamesWon * 100 / data.gamesJoined;
    return '${rate.round()}%';
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.spacingSm),
      decoration: BoxDecoration(
        color: AppTokens.white08,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: AppTokens.white14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTokens.numeric1.copyWith(color: valueColor),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTokens.label1.copyWith(color: AppTokens.white65),
          ),
        ],
      ),
    );
  }
}
