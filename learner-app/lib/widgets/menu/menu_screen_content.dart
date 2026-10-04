import 'package:flutter/material.dart';
import '../../core/app_design_tokens.dart';
import '../../data/profile/user_profile_data.dart';
import '../../view_models/menu/menu_level_progress.dart';
import '../common/design_frame.dart';
import 'leaderboard/leaderboard_entry_card.dart';
import 'profile/earnings_card.dart';
import 'profile/level_progress_card.dart';
import 'profile/stats_card.dart';

/// Menu body: level, earnings, leaderboard, and stats read as one panel stack.
///
/// The four rows keep a single fixed gap so they group visually, and the block
/// is centered in the area between the header and the primary action instead
/// of hanging from the top. Taller screens grow the margins around the block,
/// never the gaps inside it.
class MenuScreenContent extends StatelessWidget {
  /// Gap between the stacked panels.
  static const double panelGap = AppTokens.spacingSm;

  final UserProfileData userData;
  final VoidCallback? onLeaderboardTap;

  const MenuScreenContent({
    super.key,
    required this.userData,
    this.onLeaderboardTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: DesignFrame(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.spacingMd,
                    vertical: panelGap,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LevelProgressCard(
                        progress: MenuLevelProgress.fromProfile(userData),
                      ),
                      const SizedBox(height: panelGap),
                      EarningsCard(data: userData),
                      const SizedBox(height: panelGap),
                      LeaderboardEntryCard(onTap: onLeaderboardTap),
                      const SizedBox(height: panelGap),
                      StatsCard(data: userData),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
