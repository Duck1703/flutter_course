import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/onboarding/onboarding_step_data.dart';
import '../../data/settings/supported_language_data.dart';
import '../../repositories/onboarding/onboarding_repository.dart';
import '../../repositories/settings/user_settings_repository.dart';

/// VM của onboarding overlay — **senior-identical** với
/// `view_models/onboarding/onboarding_view_model.dart`: danh sách bước
/// là state, `currentStep` = phần tử đầu, tiến bằng `removeAt(0)`;
/// `listEquals` chặn notify thừa, `List.unmodifiable` giữ bất biến;
/// subscribe `onboardingCompletedStream` để clear khi cờ bật từ nơi
/// khác; `_languageSelectionInProgress` chặn double-tap save lồng nhau;
/// `_isDisposed` chặn set-state sau dispose.
class OnboardingViewModel extends ChangeNotifier {
  final OnboardingRepository _repository;
  final UserSettingsRepository _settingsRepository;
  late final StreamSubscription<bool> _completedSubscription;
  List<OnboardingStepState> _steps = const [];
  Object? _completionError;
  var _isDisposed = false;
  var _languageSelectionInProgress = false;

  OnboardingViewModel({
    required OnboardingRepository onboardingRepository,
    required UserSettingsRepository settingsRepository,
  }) : this._(onboardingRepository, settingsRepository);

  OnboardingViewModel._(this._repository, this._settingsRepository) {
    _completedSubscription = _repository.onboardingCompletedStream.listen(
      _handleCompletionChanged,
    );
  }

  OnboardingStepState? get currentStep => _steps.isEmpty ? null : _steps.first;

  bool get isVisible => currentStep != null;

  Object? get completionError => _completionError;

  Future<void> loadOnboarding() async {
    final completed = await _repository.loadOnboardingCompleted();

    if (_isDisposed) {
      return;
    }

    _setSteps(completed ? const [] : _initialSteps());
  }

  Future<void> nextStep() => _advanceStep();

  Future<void> skipStep() => _advanceStep();

  Future<void> selectLanguage(SupportedLanguageData language) async {
    final current = currentStep;

    if (current is! OnboardingWelcomeStep || _languageSelectionInProgress) {
      return;
    }

    final settings = _settingsRepository.userSettingsStream.value;
    _languageSelectionInProgress = true;
    try {
      await _settingsRepository.saveUserSettings(
        settings.copyWith(languageCode: language.code),
      );
    } catch (error, stackTrace) {
      _setCompletionError(error);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'onboarding',
          context: ErrorDescription('saving onboarding language preference'),
        ),
      );
      return;
    } finally {
      _languageSelectionInProgress = false;
    }

    if (_isDisposed || currentStep is! OnboardingWelcomeStep) {
      return;
    }

    _replaceCurrentStep(
      OnboardingWelcomeStep(selectedLanguageCode: language.code),
    );
  }

  /// Ends onboarding from the "skip intro" link without walking the remaining
  /// steps. Notification permission is simply never requested.
  Future<void> skipIntro() async {
    if (_steps.isEmpty || !await _completeOnboarding()) {
      return;
    }

    if (_isDisposed) {
      return;
    }

    _completionError = null;
    _setSteps(const []);
  }

  /// Senior gọi hàm này từ scope sau khi `LocalNotificationService`
  /// trả kết quả thật — M27: scope gọi `requestPermission()` qua
  /// `LocalNotificationService` rồi truyền kết quả OS vào đây (FR-27
  /// converge).
  Future<void> onNotificationPermissionResult(bool granted) async {
    final current = currentStep;

    if (current is! OnboardingNotificationStep) {
      return;
    }

    if (!granted) {
      _replaceCurrentStep(current.copyWith(isEnabled: false));
      return;
    }

    _replaceCurrentStep(current.copyWith(isEnabled: true));
    await _advanceStep();
  }

  Future<void> _advanceStep() async {
    if (_steps.isEmpty) {
      return;
    }

    final remaining = List<OnboardingStepState>.of(_steps)..removeAt(0);

    if (remaining.isEmpty && !await _completeOnboarding()) {
      return;
    }

    if (_isDisposed) {
      return;
    }

    _completionError = null;
    _setSteps(remaining);
  }

  Future<bool> _completeOnboarding() async {
    try {
      await _repository.setOnboardingCompleted();
      return true;
    } catch (error, stackTrace) {
      _setCompletionError(error);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'onboarding',
          context: ErrorDescription('saving onboarding completion'),
        ),
      );
      return false;
    }
  }

  void _replaceCurrentStep(OnboardingStepState step) {
    if (_steps.isEmpty || _steps.first == step) {
      return;
    }

    _setSteps([step, ..._steps.skip(1)]);
  }

  void _handleCompletionChanged(bool completed) {
    if (_isDisposed || !completed) {
      return;
    }

    _setSteps(const []);
  }

  void _setSteps(List<OnboardingStepState> steps) {
    if (_isDisposed) {
      return;
    }

    if (listEquals(_steps, steps)) {
      return;
    }

    _steps = List.unmodifiable(steps);
    notifyListeners();
  }

  void _setCompletionError(Object error) {
    if (_isDisposed || identical(_completionError, error)) {
      return;
    }

    _completionError = error;
    notifyListeners();
  }

  List<OnboardingStepState> _initialSteps() {
    final settings = _settingsRepository.userSettingsStream.value;

    return [
      OnboardingWelcomeStep(selectedLanguageCode: settings.languageCode),
      OnboardingNotificationStep(
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      ),
      const OnboardingReadyStep(),
    ];
  }

  @override
  void dispose() {
    _isDisposed = true;
    _completedSubscription.cancel();
    super.dispose();
  }
}
