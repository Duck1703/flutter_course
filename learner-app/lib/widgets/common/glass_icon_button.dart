import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_design_tokens.dart';

class GlassIconButton extends StatelessWidget {
  final String assetIcon;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const GlassIconButton({
    super.key,
    required this.assetIcon,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTokens.white10),
                gradient: AppTokens.glassGradient,
              ),
              padding: const EdgeInsets.all(AppTokens.spacingXs),
              child: SvgPicture.asset(
                assetIcon,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
