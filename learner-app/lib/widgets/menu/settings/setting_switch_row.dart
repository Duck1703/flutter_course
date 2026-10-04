import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/settings/setting_item_data.dart';

class SettingSwitchRow extends StatelessWidget {
  final SettingSwitchItemData item;
  final ValueChanged<SettingSwitchItemData> onToggle;

  const SettingSwitchRow({
    super.key,
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onToggle(item),
      child: _SettingRowFrame(
        child: Row(
          children: [
            _SettingIconBadge(
              iconAsset: item.iconAsset,
              semanticLabel: item.text,
              enabled: item.isEnabled,
            ),
            const SizedBox(width: AppTokens.qzdsSpacingSm),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.text,
                    style: AppTokens.qzdsBody1.copyWith(
                      color: AppTokens.qzdsBlack600,
                      height: 1.35,
                    ),
                  ),
                  if (item.subtitle case final subtitle?)
                    Text(
                      subtitle,
                      style: AppTokens.caption3.copyWith(
                        color: AppTokens.qzdsBlack600.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
            Switch(
              value: item.isEnabled,
              activeThumbColor: AppTokens.white100,
              inactiveThumbColor: AppTokens.white100,
              activeTrackColor: AppTokens.qzdsYellow500,
              inactiveTrackColor: AppTokens.qzdsGrey100,
              trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? AppTokens.qzdsYellow600
                    : AppTokens.qzdsGrey100;
              }),
              onChanged: (_) => onToggle(item),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRowFrame extends StatelessWidget {
  final Widget child;

  const _SettingRowFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _SettingIconBadge extends StatelessWidget {
  final String iconAsset;
  final String semanticLabel;
  final bool enabled;

  const _SettingIconBadge({
    required this.iconAsset,
    required this.semanticLabel,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = enabled
        ? AppTokens.settingsIconGradient
        : LinearGradient(
            colors: [
              AppTokens.qzdsGrey100,
              AppTokens.qzdsGrey100.withValues(alpha: 0.8),
            ],
          );

    return Container(
      width: AppTokens.qzdsIconBadgeSm,
      height: AppTokens.qzdsIconBadgeSm,
      padding: const EdgeInsets.all(
        (AppTokens.qzdsIconBadgeSm - AppTokens.qzdsIconXs) / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusMd),
        gradient: gradient,
      ),
      child: SvgPicture.asset(iconAsset, semanticsLabel: semanticLabel),
    );
  }
}
