import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
class OnboardingHeaderConfig {
  final String title;
  final Color color;

  /// Gradient of the round badge shown above the step description.
  final Gradient badgeGradient;

  /// SVG asset rendered inside the badge.
  final String badgeAsset;

  const OnboardingHeaderConfig({
    required this.title,
    required this.color,
    required this.badgeGradient,
    required this.badgeAsset,
  });
}
