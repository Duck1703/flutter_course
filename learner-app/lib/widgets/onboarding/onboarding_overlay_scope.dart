import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/onboarding/onboarding_repository.dart';
import '../../repositories/settings/user_settings_repository.dart';
import '../../services/local_notification_service.dart';
import '../../view_models/onboarding/onboarding_view_model.dart';
import 'onboarding_overlay.dart';

class OnboardingOverlayScope extends StatefulWidget {
  const OnboardingOverlayScope({super.key});

  @override
  State<OnboardingOverlayScope> createState() => _OnboardingOverlayScopeState();
}

class _OnboardingOverlayScopeState extends State<OnboardingOverlayScope> {
  OnboardingRepository? _repository;
  Future<bool>? _completionFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final repository = context.read<OnboardingRepository>();
    if (identical(_repository, repository)) {
      return;
    }

    _repository = repository;
    _completionFuture = repository.loadOnboardingCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final repository = _repository;
    final completionFuture = _completionFuture;

    if (repository == null || completionFuture == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<bool>(
      future: completionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        if (snapshot.data ?? repository.onboardingCompletedStream.value) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<bool>(
          stream: repository.onboardingCompletedStream,
          initialData: repository.onboardingCompletedStream.value,
          builder: (context, snapshot) {
            if (snapshot.data ?? false) {
              return const SizedBox.shrink();
            }

            return ChangeNotifierProvider<OnboardingViewModel>(
              create: (_) => OnboardingViewModel(
                onboardingRepository: repository,
                settingsRepository: context.read<UserSettingsRepository>(),
              )..loadOnboarding(),
              child: const _OnboardingOverlayConnector(),
            );
          },
        );
      },
    );
  }
}

class _OnboardingOverlayConnector extends StatelessWidget {
  const _OnboardingOverlayConnector();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();

    return OnboardingOverlay(
      step: viewModel.currentStep,
      onNextStep: viewModel.nextStep,
      onSkipStep: viewModel.skipStep,
      onEnableNotifications: () =>
          unawaited(_requestNotificationPermission(context)),
      onLanguageSelected: (language) =>
          unawaited(viewModel.selectLanguage(language)),
      onFinish: viewModel.nextStep,
      onSkipIntro: () => unawaited(viewModel.skipIntro()),
    );
  }

  Future<void> _requestNotificationPermission(BuildContext context) async {
    final notificationService = context.read<LocalNotificationService>();
    final viewModel = context.read<OnboardingViewModel>();

    try {
      final granted = await notificationService.requestPermission();
      await viewModel.onNotificationPermissionResult(granted);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'onboarding',
          context: ErrorDescription('requesting notification permission'),
        ),
      );
      await viewModel.onNotificationPermissionResult(false);
    }
  }
}
