import 'package:flutter/material.dart';

import '../../core/app_design_tokens.dart';
import '../../core/onboarding_design_tokens.dart';
import '../../data/onboarding/onboarding_step_data.dart';

class OnboardingStepIndicator extends StatelessWidget {
  final OnboardingStepType currentStepType;

  const OnboardingStepIndicator({super.key, required this.currentStepType});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final stepType in OnboardingStepState.stepOrder) ...[
          _OnboardingStepDot(isActive: stepType == currentStepType),
          if (stepType != OnboardingStepState.stepOrder.last)
            const SizedBox(width: AppTokens.spacingXs),
        ],
      ],
    );
  }
}

class _OnboardingStepDot extends StatelessWidget {
  final bool isActive;

  const _OnboardingStepDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppTokens.motionMedium,
      curve: Curves.linear,
      width: isActive
          ? OnboardingTokens.indicatorActiveWidth
          : OnboardingTokens.indicatorSize,
      height: OnboardingTokens.indicatorSize,
      decoration: BoxDecoration(
        color: AppTokens.white100.withValues(alpha: isActive ? 1 : 0.3),
        borderRadius: BorderRadius.circular(
          isActive ? AppTokens.spacingXxs : AppTokens.radiusN,
        ),
      ),
    );
  }
}
