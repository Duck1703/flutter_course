import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/widgets/game/answers/game_answer_option.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Compose-style full-width pill and audience badge', (
    WidgetTester tester,
  ) async {
    await _pumpOption(
      tester,
      const GameAnswerOptionData(
        answerLabel: 'A',
        answerText: 'Bill Gates',
        audiencePercentile: 64,
      ),
    );

    final optionRect = tester.getRect(find.byType(GameAnswerOption));
    final surfaceRect = tester.getRect(_surfaceFinder());
    final labelRect = tester.getRect(find.text('A'));
    final answerRect = tester.getRect(find.text('Bill Gates'));
    final badgeDecoration = _badgeDecoration(tester);

    expect(surfaceRect.width, closeTo(optionRect.width, 0.1));
    expect(labelRect.left, lessThan(answerRect.left));
    expect(answerRect.center.dx, closeTo(surfaceRect.center.dx, 0.1));
    expect(find.text('64%'), findsOneWidget);
    expect(
      badgeDecoration.gradient,
      const LinearGradient(colors: [Color(0xFF0036F9), Color(0xFF00E0FF)]),
    );
    expect(badgeDecoration.color, isNull);
  });

  testWidgets('exposes state semantics and live region only when non-idle', (
    WidgetTester tester,
  ) async {
    const nonIdleStates = {
      GameAnswerState.selected: 'Selected',
      GameAnswerState.correct: 'Correct',
      GameAnswerState.incorrect: 'Incorrect',
    };

    for (final entry in nonIdleStates.entries) {
      await _pumpOption(
        tester,
        GameAnswerOptionData(
          answerLabel: 'B',
          answerText: 'Bill Gates',
          state: entry.key,
        ),
      );

      expect(
        tester.getSemantics(_semanticsFinder()),
        matchesSemantics(
          label: 'Option B, Bill Gates',
          value: entry.value,
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isLiveRegion: true,
          hasTapAction: true,
        ),
      );
    }

    await _pumpOption(
      tester,
      const GameAnswerOptionData(answerLabel: 'C', answerText: 'Jeff Bezos'),
    );

    expect(
      tester.getSemantics(_semanticsFinder()),
      matchesSemantics(
        label: 'Option C, Jeff Bezos',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('does not fire taps or show audience badge for empty answers', (
    WidgetTester tester,
  ) async {
    var tapCount = 0;

    await _pumpOption(
      tester,
      const GameAnswerOptionData(
        answerLabel: '',
        answerText: '',
        audiencePercentile: 42,
      ),
      onTap: () => tapCount++,
    );

    await tester.tap(find.byType(GameAnswerOption));
    await tester.pump();

    expect(tapCount, 0);
    expect(find.text('42%'), findsNothing);
    expect(
      tester.getSemantics(_semanticsFinder()),
      matchesSemantics(
        label: 'Option , ',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        hasTapAction: false,
      ),
    );
  });

  testWidgets('reports disabled semantics when callback is absent', (
    WidgetTester tester,
  ) async {
    await _pumpOption(
      tester,
      const GameAnswerOptionData(answerLabel: 'D', answerText: 'Jeff Bezos'),
      withCallback: false,
    );

    expect(
      tester.getSemantics(_semanticsFinder()),
      matchesSemantics(
        label: 'Option D, Jeff Bezos',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        hasTapAction: false,
      ),
    );
  });
}

Future<void> _pumpOption(
  WidgetTester tester,
  GameAnswerOptionData data, {
  VoidCallback? onTap,
  bool withCallback = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 343,
            child: GameAnswerOption(
              data: data,
              onTap: withCallback ? onTap ?? () {} : null,
            ),
          ),
        ),
      ),
    ),
  );
}

Finder _surfaceFinder() {
  return find.descendant(
    of: find.byType(GameAnswerOption),
    matching: find.byType(AnimatedContainer),
  );
}

Finder _semanticsFinder() {
  return find.descendant(
    of: find.byType(GameAnswerOption),
    matching: find.byType(Semantics),
  );
}

BoxDecoration _badgeDecoration(WidgetTester tester) {
  return tester
      .widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(GameAnswerOption),
          matching: find.byType(DecoratedBox),
        ),
      )
      .map((widget) => widget.decoration)
      .whereType<BoxDecoration>()
      .singleWhere((decoration) => decoration.gradient != null);
}
