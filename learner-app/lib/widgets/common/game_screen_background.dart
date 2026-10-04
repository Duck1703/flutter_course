import 'package:flutter/material.dart';
import '../../core/app_design_tokens.dart';

class GameScreenBackground extends StatelessWidget {
  const GameScreenBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTokens.screenBackground,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppTokens.menuBackgroundGradient,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppTokens.menuBackgroundOverlay),
            Opacity(
              opacity: 0.6,
              child: Image.asset(AppAssets.menuBackground, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}
