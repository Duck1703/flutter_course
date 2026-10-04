import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_design_tokens.dart';
import '../../common/qzds_game_button.dart';

class GameDialogShell extends StatelessWidget {
  final String title;
  final Color headerColor;
  final String? iconAsset;

  /// Header glyph for dialogs whose subject has no SVG in [AppAssets].
  /// Ignored when [iconAsset] is set.
  final IconData? icon;
  final Widget child;

  const GameDialogShell({
    super.key,
    required this.title,
    required this.headerColor,
    this.iconAsset,
    this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(AppTokens.qzdsSpacingSm),
        decoration: BoxDecoration(
          gradient: AppTokens.settingsDialogOuterGradient,
          borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusLg),
          border: Border.all(color: AppTokens.white100.withValues(alpha: 0.24)),
        ),
        padding: const EdgeInsets.all(AppTokens.spacingMd),
        child: Container(
          // The card clips its own children so the header's top corners follow
          // exactly the same curve. A border here would inset the header by a
          // pixel while it kept the card's radius, and the two off-centre arcs
          // leave a white rim that thickens at the corners.
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppTokens.white100,
            borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusLg),
          ),
          child: Stack(
            children: [
              _Header(
                title: title,
                color: headerColor,
                iconAsset: iconAsset,
                icon: icon,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.spacingMd,
                  AppTokens.qzdsSpacingXxl + AppTokens.spacingMd,
                  AppTokens.spacingMd,
                  AppTokens.spacingMd,
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameDialogButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;
  final bool textGlow;
  final IconData? icon;

  const GameDialogButton({
    super.key,
    required this.text,
    required this.color,
    required this.onTap,
    this.textGlow = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: QzdsGameButton(
        text: text,
        color: color,
        onTap: onTap,
        textGlow: textGlow,
        lightShadow: true,
        icon: icon,
      ),
    );
  }
}

class GameDialogMoneyRow extends StatelessWidget {
  final String amount;

  const GameDialogMoneyRow({super.key, required this.amount});

  /// The coin hangs to the left of the amount without displacing it, so the
  /// figure itself reads centred in the card. A trailing gap the width of the
  /// coin plus its spacing balances the row to get that.
  static const double _coinGutter = AppTokens.iconLg + AppTokens.spacingXs;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppAssets.iconGameMoney,
          width: AppTokens.iconLg,
          height: AppTokens.iconLg,
        ),
        const SizedBox(width: AppTokens.spacingXs),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: AppTokens.headline5.copyWith(
                color: AppTokens.yellow600,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                shadows: const [
                  Shadow(color: AppTokens.yellow400, blurRadius: 6),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: _coinGutter),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final Color color;
  final String? iconAsset;
  final IconData? icon;

  const _Header({
    required this.title,
    required this.color,
    required this.iconAsset,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTokens.qzdsSpacingXxl,
      // No `alignment` here: it would wrap the sheen in an Align and shrink it
      // to the height of the title row, leaving the gradient painted on a strip
      // through the middle of the bar instead of the whole header.
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: AppTokens.white100.withValues(alpha: 0.64),
            blurRadius: AppTokens.spacingXs,
            spreadRadius: -AppTokens.spacingXxs,
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: headerSheen),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The trailing glyph is never dropped, so a long localised title
            // ellipsises instead of pushing the icon past the card edge.
            Flexible(
              child: Text(
                title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTokens.qzdsSubtitle2.copyWith(
                  color: AppTokens.white100,
                  shadows: const [
                    Shadow(color: AppTokens.white100, blurRadius: 4),
                  ],
                ),
              ),
            ),
            if (iconAsset case final asset?) ...[
              const SizedBox(width: AppTokens.qzdsSpacingXs + 2),
              SvgPicture.asset(
                asset,
                width: AppTokens.qzdsIconSmPlus,
                height: AppTokens.qzdsIconSmPlus,
                colorFilter: const ColorFilter.mode(
                  AppTokens.white100,
                  BlendMode.srcIn,
                ),
              ),
            ] else if (icon case final iconData?) ...[
              const SizedBox(width: AppTokens.qzdsSpacingXs + 2),
              Icon(
                iconData,
                size: AppTokens.qzdsIconSmPlus,
                color: AppTokens.white100,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
