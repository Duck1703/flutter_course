import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/widgets/game/money/game_money_amount.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders centered pill-only amount display', (tester) async {
    await _pumpMoneyAmount(tester);

    final textStyle = tester.widget<Text>(find.text(r'$1,000')).style!;
    final pillDecoration =
        tester
                .widget<DecoratedBox>(
                  find.byKey(const ValueKey('game-money-amount-pill')),
                )
                .decoration
            as BoxDecoration;

    expect(find.text(r'$1,000'), findsOneWidget);
    expect(find.byKey(const ValueKey('game-money-amount-icon')), findsNothing);
    expect(pillDecoration.color, const Color(0xFFFFC107));
    expect(pillDecoration.boxShadow, hasLength(2));
    expect(textStyle.fontSize, 32);
    expect(textStyle.fontWeight, FontWeight.w900);
  });

  testWidgets('keeps tap and semantics contract stable', (
    WidgetTester tester,
  ) async {
    var tapCount = 0;

    await _pumpMoneyAmount(tester, onTap: () => tapCount++);
    await tester.tap(find.byType(GameMoneyAmount));
    await tester.pump();

    expect(tapCount, 1);
    expect(
      tester.getSemantics(_semanticsFinder()),
      matchesSemantics(
        label: r'Prize amount $1,000',
        isButton: true,
        hasTapAction: true,
      ),
    );

    await _pumpMoneyAmount(tester);

    expect(
      tester.getSemantics(_semanticsFinder()),
      matchesSemantics(label: r'Prize amount $1,000'),
    );
  });

  testWidgets('counts smoothly and glitches when animation trigger increases', (
    WidgetTester tester,
  ) async {
    await _pumpMoneyAmount(tester);

    await _pumpMoneyAmount(tester, amount: r'$2,000', animationTrigger: 1);

    expect(_visibleAmountText(tester).data, r'$1,000');
    expect(
      find.byKey(const ValueKey('game-money-amount-glitch-layer-0')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 130));
    final midpoint = _visibleAmountText(tester).data;
    expect(midpoint, isNot(r'$1,000'));
    expect(midpoint, isNot(r'$2,000'));

    await tester.pumpAndSettle();

    expect(find.text(r'$2,000'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('game-money-amount-glitch-layer-0')),
      findsNothing,
    );
  });

  testWidgets('updates amount without glitch when trigger is unchanged', (
    WidgetTester tester,
  ) async {
    await _pumpMoneyAmount(tester);

    await _pumpMoneyAmount(tester, amount: r'$2,000');

    expect(find.text(r'$1,000'), findsNothing);
    expect(find.text(r'$2,000'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('game-money-amount-glitch-layer-0')),
      findsNothing,
    );
  });

  testWidgets('updates amount without glitch when trigger resets', (
    WidgetTester tester,
  ) async {
    await _pumpMoneyAmount(tester, amount: r'$2,000', animationTrigger: 1);

    await _pumpMoneyAmount(tester, amount: r'$0');

    expect(find.text(r'$0'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('game-money-amount-glitch-layer-0')),
      findsNothing,
    );
  });

  testWidgets('skips motion when reduced animations are requested', (
    WidgetTester tester,
  ) async {
    await _pumpMoneyAmount(tester, disableAnimations: true);

    await _pumpMoneyAmount(
      tester,
      amount: r'$2,000',
      animationTrigger: 1,
      disableAnimations: true,
    );

    expect(find.text(r'$2,000'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('game-money-amount-glitch-layer-0')),
      findsNothing,
    );
  });
}

Future<void> _pumpMoneyAmount(
  WidgetTester tester, {
  String amount = r'$1,000',
  int animationTrigger = 0,
  VoidCallback? onTap,
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
            child: GameMoneyAmount(
              data: GameMoneyData(
                amount: amount,
                animationTrigger: animationTrigger,
              ),
              onTap: onTap,
            ),
          ),
        ),
      ),
    ),
  );
}

Finder _semanticsFinder() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Semantics &&
        widget.properties.label == r'Prize amount $1,000',
  );
}

Text _visibleAmountText(WidgetTester tester) {
  return tester.widget<Text>(
    find.descendant(
      of: find.byKey(const ValueKey('game-money-amount-text')),
      matching: find.byType(Text),
    ),
  );
}
