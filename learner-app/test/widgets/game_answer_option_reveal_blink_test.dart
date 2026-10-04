import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/widgets/game/answers/game_answer_option.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps total duration but shortens visible correct blink', (
    WidgetTester tester,
  ) async {
    const blinkFinder = ValueKey<String>('game-answer-reveal-blink');

    await _pumpOption(
      tester,
      const GameAnswerOptionData(answerLabel: 'A', answerText: 'Hanoi'),
    );

    await _pumpOption(
      tester,
      const GameAnswerOptionData(
        answerLabel: 'A',
        answerText: 'Hanoi',
        state: GameAnswerState.correct,
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.byKey(blinkFinder), findsOneWidget);
    expect(_blinkOverlayColor(tester).a, greaterThan(0));

    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(blinkFinder), findsNothing);

    await tester.pump(const Duration(milliseconds: 780));
    expect(find.byKey(blinkFinder), findsNothing);
  });

  testWidgets('does not blink when answer reveal enters incorrect state', (
    WidgetTester tester,
  ) async {
    const blinkFinder = ValueKey<String>('game-answer-reveal-blink');

    await _pumpOption(
      tester,
      const GameAnswerOptionData(
        answerLabel: 'B',
        answerText: 'Ho Chi Minh City',
      ),
    );

    await _pumpOption(
      tester,
      const GameAnswerOptionData(
        answerLabel: 'B',
        answerText: 'Ho Chi Minh City',
        state: GameAnswerState.incorrect,
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.byKey(blinkFinder), findsNothing);
  });

  testWidgets('skips reveal blink when reduced animations are requested', (
    WidgetTester tester,
  ) async {
    const blinkFinder = ValueKey<String>('game-answer-reveal-blink');

    await _pumpOption(
      tester,
      const GameAnswerOptionData(answerLabel: 'A', answerText: 'Hanoi'),
      disableAnimations: true,
    );

    await _pumpOption(
      tester,
      const GameAnswerOptionData(
        answerLabel: 'A',
        answerText: 'Hanoi',
        state: GameAnswerState.correct,
      ),
      disableAnimations: true,
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.byKey(blinkFinder), findsNothing);
  });
}

Future<void> _pumpOption(
  WidgetTester tester,
  GameAnswerOptionData data, {
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 343,
              child: GameAnswerOption(data: data, onTap: () {}),
            ),
          ),
        ),
      ),
    ),
  );
}

Color _blinkOverlayColor(WidgetTester tester) {
  return (tester
              .widget<DecoratedBox>(
                find.byKey(const ValueKey<String>('game-answer-reveal-blink')),
              )
              .decoration
          as BoxDecoration)
      .color!;
}
