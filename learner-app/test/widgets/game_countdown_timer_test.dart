import 'dart:math' as math;

import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/widgets/game/timer/game_countdown_timer.dart';
import 'package:ai_millionaire_course/widgets/game/layout/game_screen_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Compose-style pill with accessible time', (
    WidgetTester tester,
  ) async {
    await _pumpTimer(tester, remainingSeconds: 25);

    final timerSize = tester.getSize(_timerPaintFinder());

    expect(find.text('00:25'), findsOneWidget);
    expect(_timerSemantics(tester).properties.label, 'Time remaining 00:25');
    expect(timerSize.width, greaterThanOrEqualTo(120));
    expect(timerSize.width, greaterThan(timerSize.height));
  });

  testWidgets('uses Compose countdown color thresholds', (
    WidgetTester tester,
  ) async {
    await _pumpTimer(tester, remainingSeconds: 25);
    expect(_timerTextStyle(tester).color, Colors.white);

    await _pumpTimer(tester, remainingSeconds: 12);
    expect(_timerTextStyle(tester).color, const Color(0xFFFFC107));

    await _pumpTimer(tester, remainingSeconds: 6);
    expect(_timerTextStyle(tester).color, const Color(0xFFF44336));
    expect(_timerTextStyle(tester).fontSize, 24);
    expect(_timerTextStyle(tester).fontWeight, FontWeight.w600);
  });

  testWidgets('pulses only in critical state', (WidgetTester tester) async {
    await _pumpTimer(tester, remainingSeconds: 12);
    expect(_pulseFinder(), findsNothing);

    await _pumpTimer(tester, remainingSeconds: 6);
    expect(_pulseFinder(), findsOneWidget);
  });

  testWidgets('animates progress smoothly between second ticks', (
    WidgetTester tester,
  ) async {
    await _pumpTimer(tester, remainingSeconds: 25);
    expect(_paintProgress(tester), closeTo(25 / 30, 0.001));

    await _pumpTimer(tester, remainingSeconds: 24);
    expect(find.text('00:24'), findsOneWidget);
    expect(_paintProgress(tester), closeTo(25 / 30, 0.001));

    await tester.pump(const Duration(milliseconds: 500));
    expect(_paintProgress(tester), closeTo(24.5 / 30, 0.001));

    await _pumpTimer(tester, remainingSeconds: 24);
    await tester.pump(const Duration(milliseconds: 250));
    expect(_paintProgress(tester), closeTo(24.25 / 30, 0.001));

    await tester.pump(const Duration(milliseconds: 250));
    expect(_paintProgress(tester), closeTo(24 / 30, 0.001));
  });

  testWidgets('snaps progress when the countdown resets', (
    WidgetTester tester,
  ) async {
    await _pumpTimer(tester, remainingSeconds: 6);
    expect(_paintProgress(tester), closeTo(6 / 30, 0.001));

    await _pumpTimer(tester, remainingSeconds: 30);
    expect(_paintProgress(tester), closeTo(1, 0.001));

    await tester.pump(const Duration(milliseconds: 500));
    expect(_paintProgress(tester), closeTo(1, 0.001));
  });

  test('builds progress border path from the top center clockwise', () {
    final path = buildGameCountdownTimerProgressPath(const Size(160, 44));
    final metric = path.computeMetrics().single;
    const radius = 20.0;
    const straightWidth = 116.0;
    final topRightArcEnd = metric.getTangentForOffset(
      (straightWidth / 2) + (math.pi * radius / 2),
    )!;

    expect(
      metric.length,
      closeTo((straightWidth * 2) + (2 * math.pi * radius), 1),
    );
    expect(metric.getTangentForOffset(0)!.position.dx, closeTo(80, 0.1));
    expect(metric.getTangentForOffset(0)!.position.dy, closeTo(2, 0.1));
    expect(topRightArcEnd.position.dx, closeTo(158, 0.3));
    expect(topRightArcEnd.position.dy, closeTo(22, 0.3));
  });

  testWidgets('fits beside the back button in the game top bar', (
    WidgetTester tester,
  ) async {
    var backTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SizedBox(
          width: 375,
          height: 120,
          child: GameScreenTopBar(
            timer: _timerData(25),
            onBackTap: () => backTapped = true,
          ),
        ),
      ),
    );

    final timerRect = tester.getRect(find.byType(GameCountdownTimer));
    final backRect = tester.getRect(find.bySemanticsLabel('Exit Game'));

    expect(timerRect.left, greaterThan(backRect.right));
    expect(timerRect.height, lessThanOrEqualTo(72));

    await tester.tap(find.bySemanticsLabel('Exit Game'));
    expect(backTapped, isTrue);
  });
}

Future<void> _pumpTimer(
  WidgetTester tester, {
  required int remainingSeconds,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: GameCountdownTimer(data: _timerData(remainingSeconds)),
        ),
      ),
    ),
  );
}

GameTimerData _timerData(int remainingSeconds) {
  return GameTimerData(
    totalTime: const Duration(seconds: 30),
    remainingTime: Duration(seconds: remainingSeconds),
  );
}

Finder _timerPaintFinder() {
  return find.descendant(
    of: find.byType(GameCountdownTimer),
    matching: find.byType(CustomPaint),
  );
}

Semantics _timerSemantics(WidgetTester tester) {
  return tester.widget<Semantics>(
    find.descendant(
      of: find.byType(GameCountdownTimer),
      matching: find.byType(Semantics),
    ),
  );
}

Finder _pulseFinder() {
  return find.byKey(const ValueKey('game-countdown-timer-pulse'));
}

TextStyle _timerTextStyle(WidgetTester tester) {
  return tester
      .widget<AnimatedDefaultTextStyle>(
        find.descendant(
          of: find.byType(GameCountdownTimer),
          matching: find.byType(AnimatedDefaultTextStyle),
        ),
      )
      .style;
}

double _paintProgress(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(_timerPaintFinder());

  return debugGameCountdownTimerPaintProgress(paint);
}
