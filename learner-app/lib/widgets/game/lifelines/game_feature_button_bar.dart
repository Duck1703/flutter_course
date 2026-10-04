import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_screen_data.dart';
import '../../common/design_frame.dart';
import 'game_feature_button.dart';

class GameFeatureButtonBar extends StatelessWidget {
  final List<GameFeatureButtonData> buttons;
  final ValueChanged<GameFeatureButtonData> onPressed;

  const GameFeatureButtonBar({
    super.key,
    required this.buttons,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DesignFrame(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.spacingMd,
          AppTokens.spacingSm,
          AppTokens.spacingMd,
          AppTokens.spacingMd,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final button in buttons) ...[
              GameFeatureButton(
                data: button,
                onPressed: () => onPressed(button),
              ),
              if (button != buttons.last)
                const SizedBox(width: AppTokens.spacingSm),
            ],
          ],
        ),
      ),
    );
  }
}
