import 'package:ai_millionaire_course/data/game/game_session_state_data.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:ai_millionaire_course/widgets/game/dialogs/game_confirm_dialogs.dart';
import 'package:ai_millionaire_course/widgets/game/dialogs/game_dialog_shell.dart';
import 'package:ai_millionaire_course/widgets/game/dialogs/game_result_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _cardWidth = 375.0;

/// Sub-pixel rounding is fine; a displaced coin would shift the figure by half
/// the coin's own width, which is far larger than this.
const _centringTolerance = 0.5;

Widget _host(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(child: SizedBox(width: _cardWidth, child: child)),
    ),
  );
}

/// The coin sits to the left of the amount but must not push it off centre.
void _expectAmountCentred(WidgetTester tester) {
  final row = find.byType(GameDialogMoneyRow);
  final amount = find.descendant(of: row, matching: find.byType(Text));

  expect(
    tester.getRect(amount).center.dx,
    closeTo(tester.getRect(row).center.dx, _centringTolerance),
  );
}

void main() {
  testWidgets('exit dialog centres the guaranteed amount', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        GameConfirmExitDialogView(
          data: const GameConfirmExitDialog(guaranteedAmount: r'$20,000'),
          onConfirm: () {},
          onCancel: () {},
        ),
      ),
    );

    _expectAmountCentred(tester);
  });

  testWidgets('walk away dialog centres the current amount', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        GameConfirmWalkAwayDialogView(
          data: const GameConfirmWalkAwayDialog(currentAmount: r'$150,000'),
          onConfirm: () {},
          onCancel: () {},
        ),
      ),
    );

    _expectAmountCentred(tester);
  });

  testWidgets('result dialog centres the earned amount', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        GameEndedDialogView(
          data: const GameEndedDialog(earnedAmount: r'$20,000'),
          onPlayAgain: () {},
          onBackToMenu: () {},
          onShare: () {},
        ),
      ),
    );

    _expectAmountCentred(tester);
  });

  testWidgets('a long amount stays centred and scales down to fit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        GameVictoryDialogView(
          data: const GameVictoryDialog(
            earnedAmount: r'$1,000,000',
            affirmationMessage: 'Bạn đã chinh phục toàn bộ 15 câu hỏi!',
          ),
          onPlayAgain: () {},
          onBackToMenu: () {},
          onShare: () {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    _expectAmountCentred(tester);
  });
}
