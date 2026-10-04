import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:ai_millionaire_course/widgets/game/dialogs/game_dialog_shell.dart';
import 'package:ai_millionaire_course/widgets/menu/settings/settings_dialog_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Longer than any shipped title, so the header has to give somewhere.
const _longTitle = 'ĐỒNG BỘ TIẾN TRÌNH GIỮA CÁC THIẾT BỊ CỦA BẠN';
const _narrowWidth = 320.0;

Widget _host(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(child: SizedBox(width: _narrowWidth, child: child)),
    ),
  );
}

void main() {
  testWidgets('game dialog header keeps its glyph when the title is long', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const GameDialogShell(
          title: _longTitle,
          headerColor: AppTokens.qzdsYellow500,
          icon: Icons.exit_to_app,
          child: SizedBox.shrink(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
    expect(
      tester.getSize(find.byIcon(Icons.exit_to_app)).width,
      AppTokens.qzdsIconSmPlus,
    );
  });

  testWidgets('game dialog header prefers the SVG over the icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const GameDialogShell(
          title: 'CHÚC MỪNG',
          headerColor: AppTokens.green500,
          iconAsset: AppAssets.iconGameTrophy,
          icon: Icons.exit_to_app,
          child: SizedBox.shrink(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.exit_to_app), findsNothing);
  });

  testWidgets('settings dialog header keeps its close affordance reachable', (
    WidgetTester tester,
  ) async {
    var closed = false;

    await tester.pumpWidget(
      _host(
        SettingsDialogShell(
          headerText: _longTitle,
          iconAsset: AppAssets.iconSetting,
          onClose: () => closed = true,
          child: const SizedBox.shrink(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('settings-close-button')));
    expect(closed, isTrue);
  });
}
