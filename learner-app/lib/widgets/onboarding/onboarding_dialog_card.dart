import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_design_tokens.dart';
import '../../core/onboarding_design_tokens.dart';
import '../../data/onboarding/onboarding_header_config.dart';

class OnboardingDialogCard extends StatelessWidget {
  final OnboardingHeaderConfig header;
  final String description;
  final Widget actions;

  const OnboardingDialogCard({
    super.key,
    required this.header,
    required this.description,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTokens.dialogQzdsSpacingSm),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: OnboardingTokens.cardShellGradient,
        borderRadius: BorderRadius.circular(AppTokens.radius4),
        border: Border.all(color: AppTokens.white20, width: 1),
      ),
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      child: Container(
        // The card clips its own children so the header's top corners follow
        // exactly the same curve. A border here would inset the header by a
        // pixel while it kept the card's radius, and the two off-centre arcs
        // leave a rim that thickens at the corners.
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppTokens.white100,
          borderRadius: BorderRadius.circular(AppTokens.radius4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OnboardingHeader(config: header),
            Padding(
              padding: const EdgeInsets.all(AppTokens.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OnboardingBadge(config: header),
                  const SizedBox(height: AppTokens.spacingMd),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: OnboardingTokens.body1.copyWith(
                      color: OnboardingTokens.grey600,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spacingMd),
                  actions,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingBadge extends StatelessWidget {
  final OnboardingHeaderConfig config;

  const _OnboardingBadge({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: OnboardingTokens.badgeSize,
      height: OnboardingTokens.badgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: config.badgeGradient,
        boxShadow: [
          BoxShadow(
            color: config.color.withValues(alpha: 0.6),
            blurRadius: AppTokens.spacingLg,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          config.badgeAsset,
          width: OnboardingTokens.badgeIconSize,
          height: OnboardingTokens.badgeIconSize,
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  final OnboardingHeaderConfig config;

  const _OnboardingHeader({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: OnboardingTokens.headerHeight,
      // No `alignment` here: it would wrap the sheen in an Align and shrink it
      // to the height of the title row, leaving the gradient painted on a strip
      // through the middle of the bar instead of the whole header.
      decoration: BoxDecoration(
        color: config.color,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.64),
            blurRadius: AppTokens.spacingXs,
            spreadRadius: -4,
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: headerSheen),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacingSm),
          child: Center(
            child: Text(
              config.title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OnboardingTokens.subtitle2.copyWith(
                color: AppTokens.white100,
                shadows: const [
                  Shadow(color: AppTokens.white100, blurRadius: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
