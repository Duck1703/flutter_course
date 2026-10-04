import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/widgets/game/lifelines/game_feature_button.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses Compose mapper gradient colors', () {
    expect(AppTokens.gameLifelineGradient.colors, const [
      Color(0xFF00E0FF),
      Color(0xFF325DFA),
    ]);
    expect(AppTokens.red700, const Color(0xFFD32F2F));
    expect(AppTokens.red500, const Color(0xFFF44336));
  });

  testWidgets('renders a 48px circle with centered 24px icon', (
    WidgetTester tester,
  ) async {
    await _pumpFeatureButton(tester);

    final buttonRect = tester.getRect(find.byType(ClipOval));
    final iconRect = tester.getRect(find.byType(SvgPicture));

    expect(buttonRect.width, 48);
    expect(buttonRect.height, 48);
    expect(iconRect.width, 24);
    expect(iconRect.height, 24);
    expect(iconRect.center.dx, closeTo(buttonRect.center.dx, 0.1));
    expect(iconRect.center.dy, closeTo(buttonRect.center.dy, 0.1));
  });

  testWidgets('uses Compose enabled and disabled state motion values', (
    WidgetTester tester,
  ) async {
    await _pumpFeatureButton(tester);

    var opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    var scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(opacity.duration, const Duration(milliseconds: 200));
    expect(opacity.opacity, 1);
    expect(scale.duration, const Duration(milliseconds: 200));
    expect(scale.scale, 1);

    await _pumpFeatureButton(tester, isEnabled: false);

    opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(opacity.opacity, 0.38);
    expect(scale.scale, 0.94);
  });

  testWidgets('enabled state exposes tap semantics and calls handler', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var tapCount = 0;

    await _pumpFeatureButton(tester, onPressed: () => tapCount++);
    await tester.tap(find.byType(GameFeatureButton));
    await tester.pump();

    expect(tapCount, 1);
    expect(
      tester.getSemantics(find.bySemanticsLabel('50:50')),
      matchesSemantics(
        label: '50:50',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('disabled state removes tap action and does not call handler', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var tapCount = 0;

    await _pumpFeatureButton(
      tester,
      isEnabled: false,
      onPressed: () => tapCount++,
    );
    await tester.tap(find.byType(GameFeatureButton));
    await tester.pump();

    expect(tapCount, 0);
    expect(
      tester.getSemantics(find.bySemanticsLabel('50:50')),
      matchesSemantics(
        label: '50:50',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        hasTapAction: false,
      ),
    );
    semantics.dispose();
  });
}

Future<void> _pumpFeatureButton(
  WidgetTester tester, {
  bool isEnabled = true,
  VoidCallback? onPressed,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: GameFeatureButton(
            data: GameFeatureButtonData(
              type: GameFeatureButtonType.fiftyFifty,
              iconAsset: AppAssets.iconGameFiftyFifty,
              semanticLabel: '50:50',
              isEnabled: isEnabled,
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    ),
  );
}
