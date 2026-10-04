import 'package:flutter/foundation.dart';

// Đúng shape senior `data/onboarding/onboarding_step_data.dart`: sealed
// family 3 bước + `stepOrder` const; welcome mang `selectedLanguageCode`,
// notification mang `isEnabled`/`hour`/`minute` (+`formattedTime`),
// ready không field. `==`/`hashCode` theo giá trị để `listEquals` của
// VM nhận ra "không đổi" và bỏ notify.
enum OnboardingStepType { welcome, notification, ready }

@immutable
sealed class OnboardingStepState {
  const OnboardingStepState();

  OnboardingStepType get type;

  static const stepOrder = [
    OnboardingStepType.welcome,
    OnboardingStepType.notification,
    OnboardingStepType.ready,
  ];
}

/// Opening step. It greets the player and picks the app language in one card,
/// so first-run costs one tap fewer than the previous split steps.
final class OnboardingWelcomeStep extends OnboardingStepState {
  final String? selectedLanguageCode;

  const OnboardingWelcomeStep({this.selectedLanguageCode});

  @override
  OnboardingStepType get type => OnboardingStepType.welcome;

  OnboardingWelcomeStep copyWith({String? selectedLanguageCode}) {
    return OnboardingWelcomeStep(
      selectedLanguageCode: selectedLanguageCode ?? this.selectedLanguageCode,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OnboardingWelcomeStep &&
        other.selectedLanguageCode == selectedLanguageCode;
  }

  @override
  int get hashCode => Object.hash(type, selectedLanguageCode);
}

final class OnboardingNotificationStep extends OnboardingStepState {
  final bool isEnabled;
  final int hour;
  final int minute;

  const OnboardingNotificationStep({
    this.isEnabled = false,
    required this.hour,
    required this.minute,
  });

  @override
  OnboardingStepType get type => OnboardingStepType.notification;

  String get formattedTime {
    final paddedHour = hour.toString().padLeft(2, '0');
    final paddedMinute = minute.toString().padLeft(2, '0');
    return '$paddedHour:$paddedMinute';
  }

  OnboardingNotificationStep copyWith({bool? isEnabled}) {
    return OnboardingNotificationStep(
      isEnabled: isEnabled ?? this.isEnabled,
      hour: hour,
      minute: minute,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OnboardingNotificationStep &&
        other.isEnabled == isEnabled &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(type, isEnabled, hour, minute);
}

final class OnboardingReadyStep extends OnboardingStepState {
  const OnboardingReadyStep();

  @override
  OnboardingStepType get type => OnboardingStepType.ready;

  @override
  bool operator ==(Object other) => other is OnboardingReadyStep;

  @override
  int get hashCode => type.hashCode;
}
