import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import 'wheel_picker.dart';

class TimePickerWheels extends StatelessWidget {
  static const double _maxWheelWidth = AppTokens.qzdsSpacingGiant;
  static const double _minWheelWidth = 48;
  static const double _separatorWidth = 28;
  static const double _layoutSafetyPadding = 4;

  final int currentHour;
  final int currentMinute;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  const TimePickerWheels({
    super.key,
    required this.currentHour,
    required this.currentMinute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hourItems = List.generate(24, _formatNumber);
    final minuteItems = List.generate(60, _formatNumber);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.qzdsSpacingSm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wheelWidth = _resolveWheelWidth(constraints.maxWidth);

          return Center(
            child: Container(
              decoration: BoxDecoration(
                color: AppTokens.qzdsGrey100.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusLg),
                border: Border.all(
                  color: AppTokens.qzdsPurple100.withValues(alpha: 0.45),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.qzdsSpacingXs,
                vertical: AppTokens.qzdsSpacingXs,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned.fill(
                    child: IgnorePointer(child: _SelectedTimeBand()),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SemanticWheel(
                        label: l10n.hourPickerSemanticLabel,
                        value: _formatNumber(currentHour),
                        child: WheelPicker(
                          width: wheelWidth,
                          fadeColor: AppTokens.qzdsGrey100,
                          items: hourItems,
                          initialIndex: currentHour,
                          onSelectedChanged: onHourChanged,
                        ),
                      ),
                      SizedBox(
                        width: _separatorWidth,
                        child: Center(
                          child: Text(
                            ':',
                            style: AppTokens.headline5.copyWith(
                              color: AppTokens.qzdsPurple600,
                            ),
                          ),
                        ),
                      ),
                      _SemanticWheel(
                        label: l10n.minutePickerSemanticLabel,
                        value: _formatNumber(currentMinute),
                        child: WheelPicker(
                          width: wheelWidth,
                          fadeColor: AppTokens.qzdsGrey100,
                          items: minuteItems,
                          initialIndex: currentMinute,
                          onSelectedChanged: onMinuteChanged,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _resolveWheelWidth(double maxWidth) {
    if (maxWidth.isInfinite) {
      return _maxWheelWidth;
    }

    final availableWheelWidth =
        (maxWidth -
            _separatorWidth -
            AppTokens.qzdsSpacingXs * 2 -
            _layoutSafetyPadding) /
        2;
    return availableWheelWidth.clamp(_minWheelWidth, _maxWheelWidth);
  }

  static String _formatNumber(int value) => value.toString().padLeft(2, '0');
}

class _SelectedTimeBand extends StatelessWidget {
  const _SelectedTimeBand();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: AppTokens.qzdsPickerItemHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTokens.qzdsYellow100.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusMd),
            border: Border.all(
              color: AppTokens.qzdsYellow500.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _SemanticWheel extends StatelessWidget {
  final String label;
  final String value;
  final Widget child;

  const _SemanticWheel({
    required this.label,
    required this.value,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(label: label, value: value, child: child);
  }
}
