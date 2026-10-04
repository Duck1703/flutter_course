import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../core/app_design_tokens.dart';
import '../widgets/common/design_frame.dart';
import '../widgets/common/game_screen_background.dart';
import '../widgets/common/glass_icon_button.dart';
import '../widgets/common/qzds_game_button.dart';
import 'preview_fixtures.dart';

@Preview(
  name: 'Design frame',
  group: 'Common',
  size: Size(420, 160),
  wrapper: previewGameApp,
)
Widget designFramePreview() {
  return DesignFrame(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.white20,
        borderRadius: BorderRadius.circular(AppTokens.radius4),
      ),
      child: const SizedBox(
        height: 96,
        child: Center(
          child: Text('375px frame', style: TextStyle(color: Colors.white)),
        ),
      ),
    ),
  );
}

@Preview(
  name: 'Game background',
  group: 'Common',
  size: Size(390, 720),
  wrapper: previewLayerApp,
)
Widget gameScreenBackgroundPreview() {
  return const GameScreenBackground();
}

@Preview(
  name: 'Glass icon button',
  group: 'Common',
  size: Size(160, 120),
  wrapper: previewGameApp,
)
Widget glassIconButtonPreview() {
  return GlassIconButton(
    assetIcon: AppAssets.iconGear,
    semanticLabel: 'Settings',
    onTap: previewNoop,
  );
}

@Preview(
  name: 'QZDS game button',
  group: 'Common',
  size: Size(360, 140),
  wrapper: previewGameApp,
)
Widget qzdsGameButtonPreview() {
  return QzdsGameButton(
    text: 'START GAME',
    color: AppTokens.qzdsPurple700,
    textGlow: true,
    onTap: previewNoop,
  );
}
