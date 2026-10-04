import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/widgets/game/questions/game_question_panel.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

const _questionData = GameQuestionData(
  questionText: 'Ai là người sáng lập Microsoft?',
  currentQuestionIndex: 0,
  totalQuestions: 15,
  category: 'Công nghệ',
  difficulty: 'Dễ',
);

void main() {
  testWidgets('renders Compose-style question surface and centered badge', (
    WidgetTester tester,
  ) async {
    await _pumpPanel(tester);

    final panelRect = tester.getRect(find.byType(GameQuestionPanel));
    final surfaceRect = tester.getRect(
      find.byKey(const ValueKey('game-question-surface')),
    );
    final badgeRect = tester.getRect(
      find.byKey(const ValueKey('game-question-count-badge')),
    );

    expect(find.text('Ai là người sáng lập Microsoft?'), findsOneWidget);
    expect(find.text('DỄ'), findsNothing);
    expect(find.text('CÔNG NGHỆ'), findsNothing);
    expect(find.text('1/15'), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(2));
    expect(surfaceRect.height, greaterThanOrEqualTo(140));
    expect(surfaceRect.left - panelRect.left, AppTokens.spacingZero);
    expect(badgeRect.center.dx, closeTo(panelRect.center.dx, 0.1));
    expect(badgeRect.top, lessThan(surfaceRect.bottom));
    expect(_questionTextStyle(tester).fontSize, 16);
    expect(_questionTextStyle(tester).fontWeight, FontWeight.w700);
    expect(_countTextStyle(tester).fontSize, 18);
    expect(_countTextStyle(tester).fontWeight, FontWeight.w700);
    expect(
      _surfaceDecoration(tester).gradient,
      AppTokens.gameQuestionStrokeGradient,
    );
    expect(
      _badgeDecoration(tester).gradient,
      AppTokens.gameQuestionBadgeStrokeGradient,
    );
  });
}

Future<void> _pumpPanel(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 375,
          child: GameQuestionPanel(data: _questionData),
        ),
      ),
    ),
  );
}

TextStyle _questionTextStyle(WidgetTester tester) {
  return tester
      .widget<Text>(find.text('Ai là người sáng lập Microsoft?'))
      .style!;
}

TextStyle _countTextStyle(WidgetTester tester) {
  return tester.widget<Text>(find.text('1/15')).style!;
}

BoxDecoration _surfaceDecoration(WidgetTester tester) {
  return tester
          .widget<DecoratedBox>(
            find.byKey(const ValueKey('game-question-surface')),
          )
          .decoration
      as BoxDecoration;
}

BoxDecoration _badgeDecoration(WidgetTester tester) {
  return tester
          .widget<Container>(
            find.byKey(const ValueKey('game-question-count-badge')),
          )
          .decoration!
      as BoxDecoration;
}
