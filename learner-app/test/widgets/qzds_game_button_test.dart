import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/widgets/common/qzds_game_button.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: SizedBox(width: 320, child: child))),
  );
}

void main() {
  testWidgets('settles on the minimum comfortable tap target', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        QzdsGameButton(
          text: 'PLAY',
          color: AppTokens.qzdsPurple700,
          onTap: () {},
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(QzdsGameButton)).height,
      AppTokens.qzdsButtonHeight,
    );
  });

  testWidgets('draws the leading icon before the label when one is given', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        QzdsGameButton(
          text: 'PLAY',
          color: AppTokens.qzdsPurple700,
          icon: Icons.check_circle,
          onTap: () {},
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
    expect(icon.size, AppTokens.qzdsIconSm);
    expect(
      tester.getTopLeft(find.byIcon(Icons.check_circle)).dx,
      lessThan(tester.getTopLeft(find.text('PLAY')).dx),
    );
    expect(
      tester.getSize(find.byType(QzdsGameButton)).height,
      AppTokens.qzdsButtonHeight,
    );
  });

  testWidgets('the large scale stays taller than a dialog action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        QzdsGameButton(
          text: 'PLAY',
          color: AppTokens.qzdsPurple700,
          scale: QzdsButtonScale.large,
          onTap: () {},
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(QzdsGameButton)).height,
      greaterThan(AppTokens.qzdsButtonHeight),
    );
  });

  testWidgets('keeps the icon out of the accessible label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        QzdsGameButton(
          text: 'PLAY',
          color: AppTokens.qzdsPurple700,
          icon: Icons.check_circle,
          onTap: () {},
        ),
      ),
    );

    expect(
      find.bySemanticsLabel('PLAY'),
      findsOneWidget,
    );
  });
}
