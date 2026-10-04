import 'package:ai_millionaire_course/repositories/onboarding/onboarding_repository.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:ai_millionaire_course/services/local_notification_service.dart';
import 'package:ai_millionaire_course/widgets/onboarding/onboarding_overlay_scope.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_local_notification_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('completed onboarding stays hidden after repository hydration', (
    tester,
  ) async {
    final repository = _FakeOnboardingRepository(cachedCompleted: true);
    addTearDown(repository.dispose);

    await _pumpScope(tester, repository);

    expect(repository.loadCount, 1);
    expect(find.text('WELCOME TO AI QUIZ!'), findsNothing);
    expect(find.text('NEXT'), findsNothing);
  });

  testWidgets('incomplete onboarding shows and completes inside the scope', (
    tester,
  ) async {
    final repository = _FakeOnboardingRepository(cachedCompleted: false);
    addTearDown(repository.dispose);

    await _pumpScope(tester, repository);

    expect(find.text('WELCOME TO AI QUIZ!'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MAYBE LATER'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    expect(repository.onboardingCompletedStream.value, isTrue);
    expect(find.text('WELCOME TO AI QUIZ!'), findsNothing);
  });

  testWidgets(
    'enable notifications requests permission and advances when granted',
    (tester) async {
      final repository = _FakeOnboardingRepository(cachedCompleted: false);
      final notificationService = FakeLocalNotificationService(
        requestResult: true,
      );
      addTearDown(repository.dispose);

      await _pumpScope(
        tester,
        repository,
        notificationService: notificationService,
      );

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ENABLE NOTIFICATIONS'));
      await tester.pumpAndSettle();

      expect(notificationService.requestCount, 1);
      expect(find.text("YOU'RE ALL SET!"), findsOneWidget);
    },
  );

  testWidgets('denied notification permission stays on notification step', (
    tester,
  ) async {
    final repository = _FakeOnboardingRepository(cachedCompleted: false);
    final notificationService = FakeLocalNotificationService(
      requestResult: false,
    );
    addTearDown(repository.dispose);

    await _pumpScope(
      tester,
      repository,
      notificationService: notificationService,
    );

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ENABLE NOTIFICATIONS'));
    await tester.pumpAndSettle();

    expect(notificationService.requestCount, 1);
    expect(find.text('YOUR DAILY REMINDER'), findsOneWidget);
    expect(find.text('ENABLE NOTIFICATIONS'), findsOneWidget);
    expect(find.text("YOU'RE ALL SET!"), findsNothing);
  });

  testWidgets(
    'failed notification permission request stays on notification step',
    (tester) async {
      final repository = _FakeOnboardingRepository(cachedCompleted: false);
      final notificationService = FakeLocalNotificationService()
        ..throwOnRequest = true;
      addTearDown(repository.dispose);

      await _pumpScope(
        tester,
        repository,
        notificationService: notificationService,
      );

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ENABLE NOTIFICATIONS'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isA<StateError>());
      expect(notificationService.requestCount, 1);
      expect(find.text('YOUR DAILY REMINDER'), findsOneWidget);
      expect(find.text('ENABLE NOTIFICATIONS'), findsOneWidget);
      expect(find.text("YOU'RE ALL SET!"), findsNothing);
    },
  );
}

Future<void> _pumpScope(
  WidgetTester tester,
  OnboardingRepository repository, {
  FakeLocalNotificationService? notificationService,
}) async {
  final settingsRepository = await UserSettingsRepositoryImpl.create();
  addTearDown(settingsRepository.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<LocalNotificationService>.value(
          value: notificationService ?? FakeLocalNotificationService(),
        ),
        Provider<OnboardingRepository>.value(value: repository),
        Provider<UserSettingsRepository>.value(value: settingsRepository),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: const OnboardingOverlayScope()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeOnboardingRepository implements OnboardingRepository {
  final BehaviorSubject<bool> _completedSubject;
  var _cachedCompleted = false;
  var loadCount = 0;

  _FakeOnboardingRepository({required bool cachedCompleted})
    : _completedSubject = BehaviorSubject<bool>.seeded(false) {
    _cachedCompleted = cachedCompleted;
  }

  @override
  ValueStream<bool> get onboardingCompletedStream => _completedSubject.stream;

  @override
  Future<bool> loadOnboardingCompleted() async {
    loadCount++;
    _emitCompleted(_cachedCompleted);
    return _cachedCompleted;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    _cachedCompleted = true;
    _emitCompleted(true);
  }

  void _emitCompleted(bool completed) {
    if (_completedSubject.value != completed) {
      _completedSubject.add(completed);
    }
  }

  @override
  Future<void> dispose() => _completedSubject.close();
}
