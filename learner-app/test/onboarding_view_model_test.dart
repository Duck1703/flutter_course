import 'dart:async';

import 'package:ai_millionaire_course/data/onboarding/onboarding_step_data.dart';
import 'package:ai_millionaire_course/data/settings/supported_language_data.dart';
import 'package:ai_millionaire_course/data/settings/user_settings_data.dart';
import 'package:ai_millionaire_course/repositories/onboarding/onboarding_repository.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:ai_millionaire_course/view_models/onboarding/onboarding_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notification step seeded from the default reminder time in settings.
const _defaultNotificationStep = OnboardingNotificationStep(
  hour: UserSettingsData.defaultNotificationHour,
  minute: UserSettingsData.defaultNotificationMinute,
);

void main() {
  late List<OnboardingRepository> repositories;
  late UserSettingsRepository settingsRepository;
  late List<OnboardingViewModel> viewModels;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repositories = [];
    settingsRepository = await UserSettingsRepositoryImpl.create();
    viewModels = [];
  });

  tearDown(() async {
    for (final viewModel in viewModels) {
      viewModel.dispose();
    }

    for (final repository in repositories) {
      await repository.dispose();
    }
    await settingsRepository.dispose();
  });

  Future<OnboardingRepository> createRepository() async {
    final repository = await OnboardingRepositoryImpl.create();
    repositories.add(repository);
    return repository;
  }

  OnboardingViewModel createViewModel(
    OnboardingRepository repository, {
    UserSettingsRepository? settings,
  }) {
    final viewModel = OnboardingViewModel(
      onboardingRepository: repository,
      settingsRepository: settings ?? settingsRepository,
    );
    viewModels.add(viewModel);
    return viewModel;
  }

  test('loads welcome onboarding step when incomplete', () async {
    final viewModel = createViewModel(await createRepository());

    await viewModel.loadOnboarding();

    expect(viewModel.currentStep, const OnboardingWelcomeStep());
    expect(viewModel.isVisible, isTrue);
  });

  test('hides onboarding when completion is cached', () async {
    final repository = await createRepository();
    await repository.setOnboardingCompleted();
    final viewModel = createViewModel(repository);

    await viewModel.loadOnboarding();

    expect(viewModel.currentStep, isNull);
    expect(viewModel.isVisible, isFalse);
  });

  test('language selection persists and stays on the welcome step', () async {
    final viewModel = createViewModel(await createRepository());

    await viewModel.loadOnboarding();
    await viewModel.selectLanguage(SupportedLanguageData.vietnamese);

    expect(settingsRepository.userSettingsStream.value.languageCode, 'vi');
    expect(
      viewModel.currentStep,
      const OnboardingWelcomeStep(selectedLanguageCode: 'vi'),
    );
  });

  test('skip intro completes onboarding from the first step', () async {
    final repository = await createRepository();
    final viewModel = createViewModel(repository);

    await viewModel.loadOnboarding();
    await viewModel.skipIntro();

    expect(viewModel.currentStep, isNull);
    expect(repository.onboardingCompletedStream.value, isTrue);
    expect(await repository.loadOnboardingCompleted(), isTrue);
  });

  test('failed skip intro keeps the current step visible', () async {
    final previousOnError = FlutterError.onError;
    final reportedErrors = <FlutterErrorDetails>[];
    FlutterError.onError = reportedErrors.add;
    addTearDown(() => FlutterError.onError = previousOnError);

    final repository = _FailingCompletionRepository();
    repositories.add(repository);
    final viewModel = createViewModel(repository);

    await viewModel.loadOnboarding();
    await viewModel.skipIntro();

    expect(viewModel.currentStep, const OnboardingWelcomeStep());
    expect(viewModel.completionError, isA<StateError>());
    expect(repository.onboardingCompletedStream.value, isFalse);
    expect(reportedErrors, hasLength(1));
  });

  test('rapid language selections cannot skip onboarding steps', () async {
    final delayedSettingsRepository = _DelayedSettingsRepository();
    addTearDown(delayedSettingsRepository.dispose);
    final viewModel = createViewModel(
      await createRepository(),
      settings: delayedSettingsRepository,
    );

    await viewModel.loadOnboarding();
    final firstSelection = viewModel.selectLanguage(
      SupportedLanguageData.english,
    );
    final secondSelection = viewModel.selectLanguage(
      SupportedLanguageData.vietnamese,
    );

    expect(delayedSettingsRepository.saveCallCount, 1);
    expect(viewModel.currentStep, const OnboardingWelcomeStep());

    delayedSettingsRepository.completeSave();
    await Future.wait([firstSelection, secondSelection]);

    expect(
      delayedSettingsRepository.userSettingsStream.value.languageCode,
      'en',
    );
    expect(
      viewModel.currentStep,
      const OnboardingWelcomeStep(selectedLanguageCode: 'en'),
    );
  });

  test('next and skip advance through source order', () async {
    final viewModel = createViewModel(await createRepository());

    await viewModel.loadOnboarding();
    await viewModel.nextStep();

    expect(viewModel.currentStep, _defaultNotificationStep);

    await viewModel.skipStep();

    expect(viewModel.currentStep, const OnboardingReadyStep());
  });

  test('finish persists completion and hides overlay', () async {
    final repository = await createRepository();
    final viewModel = createViewModel(repository);

    await viewModel.loadOnboarding();
    await viewModel.nextStep();
    await viewModel.skipStep();
    await viewModel.nextStep();

    expect(viewModel.currentStep, isNull);
    expect(repository.onboardingCompletedStream.value, isTrue);
    expect(await repository.loadOnboardingCompleted(), isTrue);
  });

  test('denied notification permission stays on notification step', () async {
    final viewModel = createViewModel(await createRepository());

    await viewModel.loadOnboarding();
    await viewModel.nextStep();
    await viewModel.onNotificationPermissionResult(false);

    expect(viewModel.currentStep, _defaultNotificationStep);
  });

  test('granted notification permission advances to ready step', () async {
    final viewModel = createViewModel(await createRepository());

    await viewModel.loadOnboarding();
    await viewModel.nextStep();
    await viewModel.onNotificationPermissionResult(true);

    expect(viewModel.currentStep, const OnboardingReadyStep());
  });

  test('failed completion save keeps ready step visible', () async {
    final previousOnError = FlutterError.onError;
    final reportedErrors = <FlutterErrorDetails>[];
    FlutterError.onError = reportedErrors.add;
    addTearDown(() => FlutterError.onError = previousOnError);

    final repository = _FailingCompletionRepository();
    repositories.add(repository);
    final viewModel = createViewModel(repository);

    await viewModel.loadOnboarding();
    await viewModel.nextStep();
    await viewModel.skipStep();
    await viewModel.nextStep();

    expect(viewModel.currentStep, const OnboardingReadyStep());
    expect(viewModel.completionError, isA<StateError>());
    expect(repository.onboardingCompletedStream.value, isFalse);
    expect(reportedErrors, hasLength(1));
  });

  test(
    'dispose before load completes does not notify after disposal',
    () async {
      final repository = _DeferredLoadRepository();
      repositories.add(repository);
      final viewModel = createViewModel(repository);

      final loadFuture = viewModel.loadOnboarding();
      viewModel.dispose();
      viewModels.remove(viewModel);
      repository.completeLoad(false);

      await loadFuture;

      expect(viewModel.currentStep, isNull);
    },
  );
}

class _DelayedSettingsRepository implements UserSettingsRepository {
  final _settingsSubject = BehaviorSubject<UserSettingsData>.seeded(
    const UserSettingsData(),
  );
  Completer<void>? _saveCompleter;
  var saveCallCount = 0;

  @override
  ValueStream<UserSettingsData> get userSettingsStream =>
      _settingsSubject.stream;

  @override
  Future<UserSettingsData> loadUserSettings() async => _settingsSubject.value;

  @override
  Future<void> saveUserSettings(UserSettingsData settings) async {
    saveCallCount++;
    _saveCompleter = Completer<void>();
    await _saveCompleter!.future;
    _settingsSubject.add(settings);
  }

  void completeSave() {
    _saveCompleter?.complete();
  }

  @override
  Future<void> dispose() => _settingsSubject.close();
}

class _FailingCompletionRepository implements OnboardingRepository {
  final _completedSubject = BehaviorSubject<bool>.seeded(false);

  @override
  ValueStream<bool> get onboardingCompletedStream => _completedSubject.stream;

  @override
  Future<bool> loadOnboardingCompleted() async => _completedSubject.value;

  @override
  Future<void> setOnboardingCompleted() async {
    throw StateError('save failed');
  }

  @override
  Future<void> dispose() => _completedSubject.close();
}

class _DeferredLoadRepository implements OnboardingRepository {
  final _completedSubject = BehaviorSubject<bool>.seeded(false);
  final _loadCompleter = Completer<bool>();

  @override
  ValueStream<bool> get onboardingCompletedStream => _completedSubject.stream;

  @override
  Future<bool> loadOnboardingCompleted() => _loadCompleter.future;

  void completeLoad(bool completed) {
    _completedSubject.add(completed);
    _loadCompleter.complete(completed);
  }

  @override
  Future<void> setOnboardingCompleted() async {
    _completedSubject.add(true);
  }

  @override
  Future<void> dispose() => _completedSubject.close();
}
