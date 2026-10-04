import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/game/game_sample_questions_data.dart';
import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_profile_sync_repository.dart';
import 'game_screen_test_helpers.dart';

void main() {
  testWidgets('terminal game over dialog is not dismissible and can reset', (
    WidgetTester tester,
  ) async {
    final repository = FakeGameProfileRepository();
    await pumpGame(tester, userProfileRepository: repository);
    await dismissMoneyLadder(tester);

    await tester.tap(answerOption('Ho Chi Minh City'));
    await tester.pump(const Duration(milliseconds: 2500));
    await _dismissIncorrectExplanation(tester);

    expect(find.text('GAME OVER'), findsOneWidget);
    expect(repository.saveCallCount, 1);
    expect(repository.value.gamesJoined, 1);
    expect(repository.value.gamesWon, 0);
    expect(repository.value.totalMoneyWon, 0);
    expect(repository.value.currentExp, 0);
    expect(repository.value.totalQuestionCount, 1);

    await tester.tapAt(const Offset(4, 4));
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('GAME OVER'), findsOneWidget);

    await tester.tap(dialogButton('PLAY AGAIN'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('GAME OVER'), findsOneWidget);
    expect(find.text('MONEY LADDER'), findsNothing);

    await tester.pump(AppTokens.dialogMotionLong);

    expect(find.text('MONEY LADDER'), findsOneWidget);
    expect(find.text('00:30'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:30'), findsOneWidget);

    await dismissMoneyLadder(tester);

    expect(find.text('What is the capital of Vietnam?'), findsOneWidget);
    expect(find.text(r'$0'), findsWidgets);
    expect(find.text('1/15'), findsOneWidget);
    expect(featureEnabled(tester, '50:50'), isTrue);

    await tester.tap(answerOption('Ho Chi Minh City'));
    await tester.pump(const Duration(milliseconds: 2500));
    await _dismissIncorrectExplanation(tester);

    expect(repository.saveCallCount, 2);
    expect(repository.value.gamesJoined, 2);
  });

  testWidgets('play again flow auto-syncs authenticated saved result', (
    WidgetTester tester,
  ) async {
    final repository = FakeGameProfileRepository();
    final authRepository = FakeAuthRepository(
      initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
    );
    final syncRepository = FakeUserProfileSyncRepository();
    await pumpGame(
      tester,
      userProfileRepository: repository,
      authRepository: authRepository,
      profileSyncRepository: syncRepository,
    );
    await dismissMoneyLadder(tester);

    await tester.tap(answerOption('Ho Chi Minh City'));
    await tester.pump(const Duration(milliseconds: 2500));
    await _dismissIncorrectExplanation(tester);

    await tester.tap(dialogButton('PLAY AGAIN'));
    await tester.pump(AppTokens.dialogMotionLong);

    expect(find.text('MONEY LADDER'), findsOneWidget);
    expect(repository.saveCallCount, 1);
    expect(syncRepository.syncCallCount, 1);
    expect(syncRepository.lastSyncedSession?.uid, 'user-1');
  });

  testWidgets('terminal menu action waits for dialog exit motion', (
    WidgetTester tester,
  ) async {
    final repository = FakeGameProfileRepository();
    await pumpGame(tester, userProfileRepository: repository);
    await dismissMoneyLadder(tester);

    await tester.tap(answerOption('Ho Chi Minh City'));
    await tester.pump(const Duration(milliseconds: 2500));
    await _dismissIncorrectExplanation(tester);

    expect(find.text('GAME OVER'), findsOneWidget);
    expect(repository.saveCallCount, 1);

    await tester.tap(find.text('MENU'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('GAME OVER'), findsOneWidget);

    await tester.pump(AppTokens.dialogMotionLong);
    await tester.pump(AppTokens.dialogMotionLong);
    await tester.pump();

    expect(find.text('GAME OVER'), findsNothing);
    expect(repository.saveCallCount, 1);
  });

  testWidgets('reduced motion runs terminal play again without exit wait', (
    WidgetTester tester,
  ) async {
    final repository = FakeGameProfileRepository();
    await pumpGame(
      tester,
      userProfileRepository: repository,
      disableAnimations: true,
    );
    await dismissMoneyLadder(tester);

    await tester.tap(answerOption('Ho Chi Minh City'));
    await tester.pump(const Duration(milliseconds: 2500));
    await _dismissIncorrectExplanation(tester);

    expect(find.text('GAME OVER'), findsOneWidget);

    await tester.tap(dialogButton('PLAY AGAIN'));
    await tester.pump();

    expect(find.text('GAME OVER'), findsNothing);
    expect(find.text('MONEY LADDER'), findsOneWidget);
    expect(repository.saveCallCount, 1);
  });

  testWidgets('rapid terminal play again taps only trigger one reset', (
    WidgetTester tester,
  ) async {
    final repository = FakeGameProfileRepository();
    await pumpGame(tester, userProfileRepository: repository);
    await dismissMoneyLadder(tester);

    await tester.tap(answerOption('Ho Chi Minh City'));
    await tester.pump(const Duration(milliseconds: 2500));
    await _dismissIncorrectExplanation(tester);

    expect(find.text('GAME OVER'), findsOneWidget);

    await tester.tap(dialogButton('PLAY AGAIN'));
    await tester.tap(dialogButton('PLAY AGAIN'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('GAME OVER'), findsOneWidget);
    expect(find.text('MONEY LADDER'), findsNothing);

    await tester.pump(AppTokens.dialogMotionLong);

    expect(find.text('MONEY LADDER'), findsOneWidget);
    expect(find.text('00:30'), findsOneWidget);
    expect(repository.saveCallCount, 1);
  });

  testWidgets('all correct answers end in victory dialog', (
    WidgetTester tester,
  ) async {
    final repository = FakeGameProfileRepository();
    await pumpGame(tester, userProfileRepository: repository);
    await dismissMoneyLadder(tester);

    for (final question in gameSampleQuestions) {
      final option = answerOption(question.correctOption);
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.tap(dialogButton('UNDERSTAND'));
      await tester.pump(const Duration(milliseconds: 450));
    }

    expect(find.text('CONGRATULATIONS'), findsOneWidget);
    expect(find.text(r'$1,000,000'), findsWidgets);
    expect(repository.saveCallCount, 1);
    expect(repository.value.gamesJoined, 1);
    expect(repository.value.gamesWon, 1);
    expect(repository.value.level, 14);
    expect(repository.value.currentExp, 92500);
    expect(repository.value.totalQuestionCount, 15);
    expect(repository.value.totalMoneyWon, 1000000);
    expect(repository.value.totalEarnings, '1.000.000 VNĐ');
  });

  testWidgets(
    'timeout reveals correct answer and ends game after explanation',
    (WidgetTester tester) async {
      final repository = FakeGameProfileRepository();
      await pumpGame(tester, userProfileRepository: repository);
      await dismissMoneyLadder(tester);

      await tester.pump(const Duration(seconds: 30));
      await tester.pump(const Duration(milliseconds: 1500));

      expect(answerState(tester, 'Hanoi'), GameAnswerState.correct);

      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.text('AI EXPLANATIONS'), findsOneWidget);

      await _dismissIncorrectExplanation(tester);

      expect(find.text('GAME OVER'), findsOneWidget);
      expect(find.text(r'$0'), findsWidgets);
      expect(repository.saveCallCount, 1);
      expect(repository.value.gamesJoined, 1);
      expect(repository.value.totalQuestionCount, 1);
    },
  );

  testWidgets(
    'walk away appears after safe haven and ends with current money',
    (WidgetTester tester) async {
      final repository = FakeGameProfileRepository();
      await pumpGame(tester, userProfileRepository: repository);
      await dismissMoneyLadder(tester);

      for (final question in gameSampleQuestions.take(5)) {
        final option = answerOption(question.correctOption);
        await tester.ensureVisible(option);
        await tester.tap(option);
        await tester.pump(const Duration(milliseconds: 1500));
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.tap(dialogButton('UNDERSTAND'));
        await tester.pump(const Duration(milliseconds: 450));
      }

      expect(find.text('6/15'), findsOneWidget);
      expect(featureEnabled(tester, 'Walk Away'), isTrue);

      await tester.tap(find.bySemanticsLabel('Walk Away'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('WALK AWAY?'), findsOneWidget);
      expect(find.text(r'$20,000'), findsWidgets);

      await tester.tap(dialogButton('CONFIRM WALK AWAY'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('CONGRATULATIONS'), findsOneWidget);
      expect(find.text(r'$20,000'), findsWidgets);
      expect(repository.saveCallCount, 1);
      expect(repository.value.gamesJoined, 1);
      expect(repository.value.gamesWon, 0);
      expect(repository.value.level, 1);
      expect(repository.value.currentExp, 20000);
      expect(repository.value.totalQuestionCount, 6);
      expect(repository.value.totalMoneyWon, 20000);
      expect(repository.value.totalEarnings, '20.000 VNĐ');
    },
  );
}

Future<void> _dismissIncorrectExplanation(WidgetTester tester) async {
  await tester.tap(dialogButton('UNDERSTAND'));
  await tester.pump();

  expect(find.text('GAME OVER'), findsOneWidget);

  await tester.pump(AppTokens.dialogMotionLong);
  await tester.pump();

  expect(find.text('AI EXPLANATIONS'), findsNothing);
}
