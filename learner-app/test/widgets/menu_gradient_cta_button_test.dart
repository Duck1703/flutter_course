import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/widgets/common/qzds_game_button.dart';
import 'package:ai_millionaire_course/widgets/menu/gradient_cta_button.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the QZDS game button surface', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: AppTokens.screenDesignWidth,
              child: GradientCtaButton(onTap: () {}),
            ),
          ),
        ),
      ),
    );

    final button = tester.widget<QzdsGameButton>(find.byType(QzdsGameButton));
    expect(button.text, 'Start Game');
    expect(button.color, AppTokens.qzdsPurple700);
    expect(button.textGlow, isTrue);
    expect(tester.getSize(find.byType(QzdsGameButton)).width, 343);
    expect(button.scale, QzdsButtonScale.large);
    expect(
      tester.getSize(find.byType(QzdsGameButton)).height,
      greaterThan(AppTokens.qzdsButtonHeight),
    );

    final surface = tester.widget<DecoratedBox>(
      find.byWidgetPredicate((widget) {
        if (widget is! DecoratedBox) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.color == AppTokens.qzdsPurple700;
      }),
    );
    final surfaceDecoration = surface.decoration as BoxDecoration;
    final border = surfaceDecoration.border as Border;

    expect(surfaceDecoration.borderRadius, BorderRadius.circular(9999));
    expect(border.top.color, AppTokens.white100.withValues(alpha: 0.24));
    expect(
      surfaceDecoration.boxShadow?.first.color,
      AppTokens.qzdsPurple700.withValues(alpha: 0.42),
    );

    final radialGlow = tester.widget<DecoratedBox>(
      find.byWidgetPredicate((widget) {
        if (widget is! DecoratedBox) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.gradient is RadialGradient;
      }),
    );
    final glowDecoration = radialGlow.decoration as BoxDecoration;
    final gradient = glowDecoration.gradient as RadialGradient;
    expect(gradient.colors.first, AppTokens.white100.withValues(alpha: 0.32));
    // The sheen keeps light at the rim instead of fading out, and stretches to
    // the button box so a wide pill lights up edge to edge.
    expect(gradient.colors.last.a, greaterThan(0));
    expect(gradient.transform, isA<FillBoxGradientTransform>());
  });

  testWidgets('exposes enabled and disabled tap semantics', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: GradientCtaButton(onTap: () => tapCount++)),
      ),
    );

    await tester.tap(find.byType(GradientCtaButton));
    await tester.pump();

    expect(tapCount, 1);
    final buttonSemantics = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'Start Game',
    );

    expect(buttonSemantics, findsOneWidget);
    expect(
      tester.getSemantics(buttonSemantics),
      matchesSemantics(
        label: 'Start Game',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: GradientCtaButton()),
      ),
    );

    expect(buttonSemantics, findsOneWidget);
    expect(
      tester.getSemantics(buttonSemantics),
      matchesSemantics(
        label: 'Start Game',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        hasTapAction: false,
      ),
    );

    semantics.dispose();
  });

  testWidgets('passes caller-provided labels through unchanged', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: GradientCtaButton(label: 'Play now')),
      ),
    );

    final button = tester.widget<QzdsGameButton>(find.byType(QzdsGameButton));
    expect(button.text, 'Play now');
  });
}
