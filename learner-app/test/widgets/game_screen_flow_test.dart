import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/widgets/game/money/game_money_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'game_screen_test_helpers.dart';

void main() {
  testWidgets('new game shows intro ladder before countdown starts', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester);

    expect(find.text('MONEY LADDER'), findsOneWidget);
    expect(find.text('What is the capital of Vietnam?'), findsOneWidget);
    expect(find.text(r'$0'), findsWidgets);
    expect(find.text('1/15'), findsOneWidget);
    expect(find.text('00:30'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:30'), findsOneWidget);

    await dismissMoneyLadder(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('MONEY LADDER'), findsNothing);
    expect(find.text('00:29'), findsOneWidget);
  });

  testWidgets('route back does not dismiss intro ladder', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester);

    expect(find.text('MONEY LADDER'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('MONEY LADDER'), findsOneWidget);
    expect(find.text('00:30'), findsOneWidget);

    await dismissMoneyLadder(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('MONEY LADDER'), findsNothing);
    expect(find.text('00:29'), findsOneWidget);
  });

  testWidgets('correct answer reveals explanation and advances question', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester);
    await dismissMoneyLadder(tester);

    await tester.tap(answerOption('Hanoi'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(answerState(tester, 'Hanoi'), GameAnswerState.selected);

    await tester.pump(const Duration(milliseconds: 1500));
    expect(answerState(tester, 'Hanoi'), GameAnswerState.correct);
    expect(
      tester
          .widget<GameMoneyAmount>(find.byType(GameMoneyAmount))
          .data
          .animationTrigger,
      1,
    );

    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('AI EXPLANATIONS'), findsOneWidget);
    expect(find.text('UNDERSTAND'), findsOneWidget);

    await tester.tap(dialogButton('UNDERSTAND'));
    await tester.pump();
    await tester.pump(AppTokens.dialogMotionLong);

    expect(
      find.text('How many continents are there on Earth?'),
      findsOneWidget,
    );
    expect(find.text(r'$1,000'), findsOneWidget);
    expect(find.text('2/15'), findsOneWidget);
  });

  testWidgets('wrong answer reaches game over after explanation dismissal', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester);
    await dismissMoneyLadder(tester);

    await tester.tap(answerOption('Ho Chi Minh City'));
    await tester.pump(const Duration(milliseconds: 1500));
    expect(answerState(tester, 'Ho Chi Minh City'), GameAnswerState.incorrect);
    expect(answerState(tester, 'Hanoi'), GameAnswerState.correct);
    await tester.pump(const Duration(milliseconds: 120));
    expect(
      find.byKey(const ValueKey<String>('game-answer-reveal-blink')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<GameMoneyAmount>(find.byType(GameMoneyAmount))
          .data
          .animationTrigger,
      0,
    );

    await tester.pump(const Duration(milliseconds: 1000));
    await tester.tap(dialogButton('UNDERSTAND'));
    await tester.pump();

    expect(find.text('GAME OVER'), findsOneWidget);

    await tester.pump(AppTokens.dialogMotionLong);
    await tester.pump();

    expect(find.text('GAME OVER'), findsOneWidget);
    expect(find.text('AI EXPLANATIONS'), findsNothing);
    expect(find.text('You earned'), findsOneWidget);
    expect(find.text(r'$0'), findsWidgets);
  });

  testWidgets('lifelines mirror Kotlin local dialog behavior', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester);
    await dismissMoneyLadder(tester);

    await tester.tap(find.bySemanticsLabel('50:50'));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Hanoi'), findsOneWidget);
    expect(find.text('Ho Chi Minh City'), findsOneWidget);
    expect(find.text('Da Nang'), findsNothing);
    expect(featureEnabled(tester, '50:50'), isFalse);

    await tester.tap(find.bySemanticsLabel('Ask the Audience'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('AUDIENCE HELP'), findsOneWidget);
    expect(find.text('68%'), findsWidgets);
    expect(featureEnabled(tester, 'Ask the Audience'), isFalse);

    await tester.tap(dialogButton('UNDERSTAND'));
    await tester.pump();
    await tester.pump(AppTokens.dialogMotionLong);

    await tester.tap(find.bySemanticsLabel('Ask AI'));
    await tester.pump();

    expect(find.text('AI ASSISTANT'), findsOneWidget);
    expect(find.text('AI is thinking...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Hanoi'), findsWidgets);
    expect(find.text('85%'), findsOneWidget);
    expect(
      find.text(
        'Think about the political center of Vietnam, located in the north.',
      ),
      findsOneWidget,
    );
    expect(find.text('UNDERSTAND'), findsOneWidget);
    expect(dialogButton('UNDERSTAND'), findsOneWidget);

    await tester.tap(dialogButton('UNDERSTAND'));
    await tester.pumpAndSettle();

    expect(find.text('AI ASSISTANT'), findsNothing);
    expect(featureEnabled(tester, 'Ask AI'), isFalse);
  });

  testWidgets('mid-game money ladder pauses and resumes countdown', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester);
    await dismissMoneyLadder(tester);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:28'), findsOneWidget);

    await tester.tap(find.text(r'$0'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('MONEY LADDER'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:28'), findsOneWidget);

    await dismissMoneyLadder(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('00:27'), findsOneWidget);
  });

  testWidgets('money amount opens ladder and route back opens exit dialog', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester);
    await dismissMoneyLadder(tester);
    expect(
      tester
          .widget<GameMoneyAmount>(find.byType(GameMoneyAmount))
          .data
          .animationTrigger,
      0,
    );

    await tester.tap(find.text(r'$0'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('MONEY LADDER'), findsOneWidget);
    expect(find.text(r'$1,000,000'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(
      tester
          .widget<GameMoneyAmount>(find.byType(GameMoneyAmount))
          .data
          .animationTrigger,
      0,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpGame(tester);
    await dismissMoneyLadder(tester);

    await tester.tap(find.bySemanticsLabel('Exit Game'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('EXIT GAME?'), findsOneWidget);
    expect(find.text('CONTINUE PLAYING'), findsOneWidget);
  });
}
