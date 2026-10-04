import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_session_state_data.dart';
import '../../../l10n/app_localizations.dart';
import 'game_money_ladder_cta_button.dart';

const double _dialogTitleHorizontalPadding = 12;
const double _dialogTitleVerticalPadding = 16;
const double _dialogListPadding = 4;
const double _ladderRowGap = 4;
const double _ladderHorizontalPadding = 8;
const double _grandItemVerticalPadding = 12;
const double _normalItemVerticalPadding = 4;
const double _ladderIndexWidth = 22;

class GameMoneyLadderDialogView extends StatelessWidget {
  final GameMoneyLadderDialog data;
  final VoidCallback onDismiss;

  const GameMoneyLadderDialogView({
    super.key,
    required this.data,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth.clamp(0, AppTokens.screenDesignWidth)
            : AppTokens.screenDesignWidth;

        return FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(width: maxWidth.toDouble(), child: _content(context)),
        );
      },
    );
  }

  Widget _content(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: _dialogTitleHorizontalPadding,
            vertical: _dialogTitleVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppTokens.green500,
            borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusLg),
            boxShadow: [
              BoxShadow(
                color: AppTokens.white100.withValues(alpha: 0.5),
                blurRadius: AppTokens.spacingMd,
                spreadRadius: AppTokens.spacingXxs,
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppAssets.iconGameMoney,
                  width: AppTokens.qzdsIconSmPlus,
                  height: AppTokens.qzdsIconSmPlus,
                  colorFilter: const ColorFilter.mode(
                    AppTokens.white100,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: AppTokens.spacingXs),
                Text(
                  l10n.moneyLadderTitle.toUpperCase(),
                  style: AppTokens.qzdsSubtitle2.copyWith(
                    color: AppTokens.white100,
                    fontSize: 20,
                    height: 1,
                    shadows: const [
                      Shadow(color: AppTokens.qzdsYellow100, blurRadius: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTokens.qzdsSpacingXs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(_dialogListPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusLg),
            border: Border.all(
              color: AppTokens.white100.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < data.items.length; index++) ...[
                if (index > 0) const SizedBox(height: _ladderRowGap),
                _LadderItem(item: data.items[index], isGrand: index == 0),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppTokens.spacingSm),
        GameMoneyLadderCtaButton(
          text: l10n.understandButton.toUpperCase(),
          icon: Icons.check_circle,
          onPressed: onDismiss,
        ),
      ],
    );
  }
}

class _LadderItem extends StatelessWidget {
  final GameMoneyLadderItemData item;
  final bool isGrand;

  const _LadderItem({required this.item, required this.isGrand});

  @override
  Widget build(BuildContext context) {
    final Color accent = item.isCurrent
        ? AppTokens.green700
        : item.isSpecial
        ? AppTokens.qzdsYellow500
        : AppTokens.white20;
    final radius = isGrand ? AppTokens.qzdsRadiusLg : AppTokens.radiusN;
    final verticalPadding = isGrand
        ? _grandItemVerticalPadding
        : _normalItemVerticalPadding;
    final amountText = Text(
      item.amount,
      style: AppTokens.qzdsSubtitle2.copyWith(
        color: AppTokens.white100,
        fontSize: isGrand ? 22 : 14,
        fontWeight: FontWeight.w900,
        height: 1,
        shadows: isGrand
            ? const [Shadow(color: AppTokens.white100, blurRadius: 12)]
            : null,
      ),
    );
    final amountBox = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: isGrand ? Alignment.centerLeft : Alignment.centerRight,
      child: amountText,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _ladderHorizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [accent, AppTokens.white20.withValues(alpha: 0.2)],
        ),
        border: Border.all(color: AppTokens.white20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _ladderIndexWidth,
            child: Text(
              '${item.index}',
              textAlign: TextAlign.center,
              style:
                  (isGrand ? AppTokens.qzdsSubtitle2 : AppTokens.qzdsCaption1)
                      .copyWith(
                        color: AppTokens.white100,
                        fontSize: isGrand ? 18 : 12,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
            ),
          ),
          const SizedBox(width: AppTokens.qzdsSpacingXs),
          if (isGrand) ...[
            const Icon(Icons.emoji_events, color: AppTokens.white100, size: 24),
            const SizedBox(width: AppTokens.qzdsSpacingXs),
            Expanded(child: amountBox),
          ] else ...[
            Expanded(child: Container(height: 1, color: AppTokens.white20)),
            const SizedBox(width: AppTokens.qzdsSpacingXs),
            Flexible(child: amountBox),
          ],
          const SizedBox(width: AppTokens.qzdsSpacingXs),
          if (!isGrand)
            const Icon(Icons.attach_money, color: AppTokens.white100, size: 16),
        ],
      ),
    );
  }
}
