import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_design_tokens.dart';
import '../../../l10n/app_localizations.dart';

class SettingsDialogShell extends StatelessWidget {
  final String headerText;
  final String iconAsset;
  final Widget child;

  /// When provided, a close affordance is drawn in the header strip.
  final VoidCallback? onClose;

  const SettingsDialogShell({
    super.key,
    required this.headerText,
    required this.iconAsset,
    required this.child,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: constraints.maxHeight),
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(AppTokens.qzdsSpacingSm),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTokens.settingsDialogOuterGradient,
                borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusLg),
                border: Border.all(
                  color: AppTokens.white100.withValues(alpha: 0.24),
                ),
              ),
              padding: const EdgeInsets.all(AppTokens.spacingMd),
              child: Container(
                // The card clips its own children so the header's top corners
                // follow exactly the same curve. A border here would inset the
                // header by a pixel while it kept the card's radius, and the
                // two off-centre arcs leave a rim that thickens at the corners.
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppTokens.white100,
                  borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusLg),
                ),
                child: Stack(
                  children: [
                    _SettingsHeader(text: headerText, iconAsset: iconAsset),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTokens.spacingMd,
                        AppTokens.qzdsSpacingXxl + AppTokens.spacingMd,
                        AppTokens.spacingMd,
                        AppTokens.qzdsSpacingSm,
                      ),
                      child: child,
                    ),
                    if (onClose != null)
                      Positioned(
                        right: AppTokens.qzdsSpacingXs + 2,
                        top: AppTokens.qzdsSpacingXs + 2,
                        child: _SettingsCloseButton(onTap: onClose!),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String text;
  final String iconAsset;

  const _SettingsHeader({required this.text, required this.iconAsset});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      height: AppTokens.qzdsSpacingXxl,
      // No `alignment` here: it would wrap the sheen in an Align and shrink it
      // to the height of the title row, leaving the gradient painted on a strip
      // through the middle of the bar instead of the whole header.
      decoration: const BoxDecoration(
        color: AppTokens.qzdsYellow500,
        boxShadow: [
          BoxShadow(
            color: Color(0xA3FFFFFF),
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
            // The glyph and the close affordance both hold their place, so a
            // long localised title ellipsises rather than running under them.
            Flexible(
              child: Text(
                text,
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
            const SizedBox(width: AppTokens.qzdsSpacingXs + 2),
            SvgPicture.asset(
              iconAsset,
              width: AppTokens.qzdsIconSmPlus,
              height: AppTokens.qzdsIconSmPlus,
              semanticsLabel: l10n.settingsIconSemanticLabel(text),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCloseButton extends StatelessWidget {
  static const double size = 28;

  final VoidCallback onTap;

  const _SettingsCloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: l10n.closeButton,
      child: GestureDetector(
        key: const ValueKey('settings-close-button'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTokens.white100.withValues(alpha: 0.28),
          ),
          child: const Icon(
            Icons.close,
            size: AppTokens.qzdsIconSmPlus,
            color: AppTokens.white100,
          ),
        ),
      ),
    );
  }
}
