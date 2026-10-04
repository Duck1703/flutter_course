import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/app_design_tokens.dart';
import '../../../data/profile/user_profile_data.dart';
import '../../../l10n/app_localizations.dart';

/// Compact earnings strip. Kept short so the level card and the leaderboard
/// entry both stay above the fold on a 812px screen.
class EarningsCard extends StatelessWidget {
  static const double stripHeight = 76;

  final UserProfileData data;

  const EarningsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radius4),
      child: SizedBox(
        width: double.infinity,
        height: stripHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTokens.radius4),
                  border: Border.all(color: AppTokens.white20, width: 2),
                  gradient: AppTokens.earningsGradient,
                ),
              ),
            ),
            Positioned(
              right: -18,
              top: -26,
              child: _coin(AppAssets.coinLarge, 118),
            ),
            Positioned(
              left: -6,
              top: 46,
              child: Transform.flip(
                flipX: true,
                child: _blurredCoin(AppAssets.coinSmall, 22, 2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.totalEarningsLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTokens.label1.copyWith(color: AppTokens.white100),
                  ),
                  Text(
                    data.totalEarnings,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTokens.headline4.copyWith(
                      color: AppTokens.white100,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coin(String asset, double size) {
    return SvgPicture.asset(asset, width: size, height: size);
  }

  Widget _blurredCoin(String asset, double size, double blur) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: _coin(asset, size),
    );
  }
}
