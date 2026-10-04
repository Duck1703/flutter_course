import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_screen_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/design_frame.dart';
import '../../common/glass_icon_button.dart';
import '../timer/game_countdown_timer.dart';

class GameScreenTopBar extends StatelessWidget {
  final GameTimerData timer;
  final VoidCallback onBackTap;

  const GameScreenTopBar({
    super.key,
    required this.timer,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DesignFrame(
      child: SizedBox(
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: AppTokens.spacingZero),
                child: GlassIconButton(
                  assetIcon: AppAssets.iconGameBack,
                  semanticLabel: l10n.exitGameSemanticLabel,
                  onTap: onBackTap,
                ),
              ),
            ),
            GameCountdownTimer(data: timer),
          ],
        ),
      ),
    );
  }
}
