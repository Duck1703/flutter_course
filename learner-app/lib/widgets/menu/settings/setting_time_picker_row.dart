import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/settings/setting_item_data.dart';

const double _timeChipHeight = 32;
const double _timeChipLabelSize = 15;

class SettingTimePickerRow extends StatelessWidget {
  final SettingTimePickerItemData item;
  final VoidCallback onTap;

  const SettingTimePickerRow({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('settings-time-row'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.qzdsSpacingSm,
          vertical: AppTokens.qzdsSpacingXs,
        ),
        decoration: BoxDecoration(
          color: AppTokens.qzdsGrey100.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusMd),
          border: Border.all(
            color: AppTokens.qzdsPurple100.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppTokens.qzdsIconBadgeSm,
              height: AppTokens.qzdsIconBadgeSm,
              padding: const EdgeInsets.all(
                (AppTokens.qzdsIconBadgeSm - AppTokens.qzdsIconXs) / 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusMd),
                gradient: AppTokens.settingsIconGradient,
              ),
              child: SvgPicture.asset(
                item.iconAsset,
                semanticsLabel: item.text,
              ),
            ),
            const SizedBox(width: AppTokens.qzdsSpacingSm),
            Expanded(
              child: Text(
                item.text,
                style: AppTokens.qzdsBody1.copyWith(
                  color: AppTokens.qzdsBlack600,
                ),
              ),
            ),
            Container(
              height: _timeChipHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.qzdsSpacingSm,
              ),
              decoration: BoxDecoration(
                color: AppTokens.qzdsYellow500,
                borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule,
                    size: AppTokens.qzdsIconXs,
                    color: AppTokens.white100,
                  ),
                  const SizedBox(width: AppTokens.qzdsSpacingXs),
                  Text(
                    item.formattedTime,
                    style: AppTokens.qzdsSubtitle2.copyWith(
                      fontSize: _timeChipLabelSize,
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
}
