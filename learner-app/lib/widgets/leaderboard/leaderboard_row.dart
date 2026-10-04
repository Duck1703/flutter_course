import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_design_tokens.dart';
import '../../data/leaderboard/leaderboard_entry_data.dart';
import '../../l10n/app_localizations.dart';
import 'leaderboard_avatar.dart';

class LeaderboardRow extends StatelessWidget {
  final LeaderboardEntryData entry;
  final double height;

  const LeaderboardRow({super.key, required this.entry, this.height = 72});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radius4),
              child: DecoratedBox(
                decoration: _rowDecoration(entry.style),
                child: DecoratedBox(
                  decoration: _rowHighlightDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppTokens.dialogQzdsSpacingSm,
                    ),
                    child: Row(
                      children: [
                        Semantics(
                          label: l10n.rankSemanticLabel(entry.rank),
                          image: true,
                          child: SvgPicture.asset(
                            entry.rankAsset,
                            width: 40,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: AppTokens.spacingXs),
                        LeaderboardAvatar(entry: entry),
                        const SizedBox(width: AppTokens.spacingXs),
                        Expanded(child: _PlayerText(entry: entry)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _rowDecoration(LeaderboardRowStyle style) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppTokens.radius4),
      border: Border.all(color: AppTokens.white20),
      gradient: _rowGradient(style),
      boxShadow: const [
        BoxShadow(color: Color(0x6BFFFFFF), blurRadius: 42, spreadRadius: -18),
      ],
    );
  }

  BoxDecoration _rowHighlightDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppTokens.radius4),
      gradient: surfaceGlow(const Color(0x40FFFFFF)),
    );
  }

  LinearGradient _rowGradient(LeaderboardRowStyle style) {
    switch (style) {
      case LeaderboardRowStyle.first:
        return const LinearGradient(
          colors: [Color(0xFFEA0600), Color(0x4DFFA000), Color(0x00000000)],
        );
      case LeaderboardRowStyle.second:
        return const LinearGradient(
          colors: [Color(0xFF0036F9), Color(0x6B00E0FF), Color(0x00000000)],
        );
      case LeaderboardRowStyle.third:
        return const LinearGradient(
          colors: [Color(0xFF745CFF), Color(0x6BD506FF), Color(0x00000000)],
        );
      case LeaderboardRowStyle.currentUser:
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0x806CE360), Color(0x00000000)],
        );
      case LeaderboardRowStyle.glass:
        return const LinearGradient(
          colors: [Color(0x1AD3CBFF), Color(0x00000000)],
        );
    }
  }
}

class _PlayerText extends StatelessWidget {
  final LeaderboardEntryData entry;

  const _PlayerText({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTokens.body4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTokens.spacingXxs),
        Row(
          children: [
            Image.asset(AppAssets.leaderboardScoreCoin, width: 20, height: 20),
            const SizedBox(width: AppTokens.spacingXxs),
            Flexible(
              child: Text(
                entry.score,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTokens.body3.copyWith(
                  color: AppTokens.yellow400,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  shadows: const [
                    Shadow(color: AppTokens.yellow400, blurRadius: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
