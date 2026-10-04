import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/app_design_tokens.dart';
import '../common/design_frame.dart';

class MenuDialogBackdrop extends StatelessWidget {
  final Widget child;
  final VoidCallback onDismiss;
  final Widget? foregroundOverlay;

  const MenuDialogBackdrop({
    super.key,
    required this.child,
    required this.onDismiss,
    this.foregroundOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        key: const ValueKey('menu-dialog-backdrop-filter'),
        filter: ImageFilter.blur(
          sigmaX: AppTokens.dialogHazeBlurSigma,
          sigmaY: AppTokens.dialogHazeBlurSigma,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onDismiss,
          child: ColoredBox(
            key: const ValueKey('menu-dialog-haze-overlay'),
            color: AppTokens.dialogHazeScrim,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SafeArea(
                  minimum: const EdgeInsets.symmetric(
                    vertical: AppTokens.spacingLg,
                  ),
                  child: Center(
                    child: DesignFrame(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        child: child,
                      ),
                    ),
                  ),
                ),
                if (foregroundOverlay != null)
                  Positioned.fill(child: foregroundOverlay!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
