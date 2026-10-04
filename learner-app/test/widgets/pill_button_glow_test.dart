import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/widgets/common/qzds_game_button.dart';
import 'package:ai_millionaire_course/widgets/game/money/game_money_ladder_cta_button.dart';
import 'package:ai_millionaire_course/widgets/onboarding/onboarding_game_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _hostWidth = 240.0;

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: SizedBox(width: _hostWidth, child: child)),
    ),
  );
}

/// The layer that paints the centre-out sheen. It has to cover the whole pill;
/// when it shrinks to the label the button reads as two mismatched shapes.
Finder _glowLayer(Finder button) {
  return find.descendant(
    of: button,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).gradient != null,
    ),
  );
}

/// A `Container` border insets its child by the stroke width on each side, so
/// the sheen is allowed to fall short by that much and no more.
const _borderInset = 2.0;

void _expectGlowSpansButton(WidgetTester tester, Finder button) {
  expect(
    tester.getSize(_glowLayer(button)).width,
    closeTo(tester.getSize(button).width, _borderInset),
  );
}

void main() {
  testWidgets('money ladder CTA sheen spans the whole pill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        GameMoneyLadderCtaButton(
          text: 'ĐÃ HIỂU',
          icon: Icons.check_circle,
          onPressed: () {},
        ),
      ),
    );

    _expectGlowSpansButton(tester, find.byType(GameMoneyLadderCtaButton));
  });

  testWidgets('QzdsGameButton sheen spans the whole pill at both scales', (
    WidgetTester tester,
  ) async {
    for (final scale in QzdsButtonScale.values) {
      await tester.pumpWidget(
        _host(
          QzdsGameButton(
            text: 'ĐÃ HIỂU',
            color: AppTokens.green500,
            icon: Icons.check_circle,
            scale: scale,
            onTap: () {},
          ),
        ),
      );

      _expectGlowSpansButton(tester, find.byType(QzdsGameButton));
    }
  });

  testWidgets('OnboardingGameButton sheen spans the whole pill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        OnboardingGameButton(
          text: 'Đăng nhập',
          color: AppTokens.qzdsPurple500,
          icon: Icons.login,
          onTap: () {},
        ),
      ),
    );

    _expectGlowSpansButton(tester, find.byType(OnboardingGameButton));
  });
}
