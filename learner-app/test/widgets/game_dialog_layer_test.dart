import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/data/game/game_session_state_data.dart';
import 'package:ai_millionaire_course/view_models/game/support/game_money_ladder_mapper.dart';
import 'package:ai_millionaire_course/widgets/common/qzds_game_button.dart';
import 'package:ai_millionaire_course/widgets/game/dialogs/game_dialog_layer.dart';
import 'package:ai_millionaire_course/widgets/game/dialogs/game_dialog_shell.dart';
import 'package:ai_millionaire_course/widgets/game/money/game_money_ladder_cta_button.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('game dialog layer uses keyed fade transitions', (
    WidgetTester tester,
  ) async {
    await _pumpTestSurface(
      tester,
      _TestSurface(dialog: const GameDialogHidden()),
    );

    expect(find.text('EXIT GAME?'), findsNothing);

    await _pumpTestSurface(
      tester,
      _TestSurface(
        dialog: const GameConfirmExitDialog(guaranteedAmount: r'$0'),
      ),
    );

    expect(find.byType(AnimatedSwitcher), findsOneWidget);
    expect(find.byType(FadeTransition), findsWidgets);

    await tester.pump(AppTokens.dialogMotionLong);

    expect(find.text('EXIT GAME?'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('game-dialog-backdrop-filter')),
      findsOneWidget,
    );
  });

  testWidgets('reduced motion removes outgoing dialog immediately', (
    WidgetTester tester,
  ) async {
    await _pumpTestSurface(
      tester,
      _TestSurface(
        disableAnimations: true,
        dialog: const GameConfirmExitDialog(guaranteedAmount: r'$0'),
      ),
    );

    expect(find.text('EXIT GAME?'), findsOneWidget);

    await _pumpTestSurface(
      tester,
      _TestSurface(disableAnimations: true, dialog: const GameDialogHidden()),
    );

    expect(find.text('EXIT GAME?'), findsNothing);
    expect(
      find.byKey(const ValueKey('game-dialog-backdrop-filter')),
      findsNothing,
    );
  });

  testWidgets('dismiss keeps outgoing dialog during exit motion', (
    WidgetTester tester,
  ) async {
    await _pumpTestSurface(
      tester,
      _TestSurface(
        dialog: const GameConfirmExitDialog(guaranteedAmount: r'$0'),
      ),
    );
    await tester.pump(AppTokens.dialogMotionLong);

    expect(find.text('EXIT GAME?'), findsOneWidget);

    await _pumpTestSurface(
      tester,
      _TestSurface(dialog: const GameDialogHidden()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('EXIT GAME?'), findsOneWidget);

    await tester.pump(AppTokens.dialogMotionLong);

    expect(find.text('EXIT GAME?'), findsNothing);
  });

  testWidgets('terminal result dialog animates out before removal', (
    WidgetTester tester,
  ) async {
    await _pumpTestSurface(
      tester,
      _TestSurface(dialog: const GameEndedDialog(earnedAmount: r'$0')),
    );
    await tester.pump(AppTokens.dialogMotionLong);

    expect(find.text('GAME OVER'), findsOneWidget);

    await _pumpTestSurface(
      tester,
      _TestSurface(dialog: const GameDialogHidden()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('GAME OVER'), findsOneWidget);

    await tester.pump(AppTokens.dialogMotionLong);

    expect(find.text('GAME OVER'), findsNothing);
  });

  testWidgets('money ladder animates out before removal', (
    WidgetTester tester,
  ) async {
    await _pumpTestSurface(tester, _TestSurface(dialog: _moneyLadderDialog));
    await tester.pump(AppTokens.dialogMotionLong);

    expect(find.text('MONEY LADDER'), findsOneWidget);

    await _pumpTestSurface(
      tester,
      _TestSurface(dialog: const GameDialogHidden()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('MONEY LADDER'), findsOneWidget);

    await tester.pump(AppTokens.dialogMotionLong);

    expect(find.text('MONEY LADDER'), findsNothing);
  });

  testWidgets('money ladder fits all levels without scrolling', (
    WidgetTester tester,
  ) async {
    final items = buildGameMoneyLadderItems(currentQuestionIndex: 0);

    await _pumpTestSurface(
      tester,
      _TestSurface(dialog: GameMoneyLadderDialog(items: items)),
    );
    await tester.pump(AppTokens.dialogMotionLong);

    expect(tester.takeException(), isNull);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(Scrollable), findsNothing);
    expect(items.first.index, 15);
    expect(items.last.index, 1);
    expect(tester.widget<Text>(find.text('MONEY LADDER')).style?.fontSize, 20);

    for (final item in items) {
      expect(find.text('${item.index}'), findsOneWidget);
      expect(find.text(item.amount), findsOneWidget);
    }

    final firstRect = tester.getRect(find.text('${items.first.index}'));
    final lastRect = tester.getRect(find.text('${items.last.index}'));

    expect(firstRect.top, greaterThanOrEqualTo(0));
    expect(lastRect.bottom, lessThanOrEqualTo(812));
    expect(firstRect.top, lessThan(lastRect.top));
  });

  testWidgets('money ladder acknowledge button dismisses dialog', (
    WidgetTester tester,
  ) async {
    var dismissCount = 0;

    await _pumpTestSurface(
      tester,
      _TestSurface(dialog: _moneyLadderDialog, onDismiss: () => dismissCount++),
    );
    await tester.pump(AppTokens.dialogMotionLong);

    expect(find.text('UNDERSTAND'), findsOneWidget);
    expect(
      tester.getSize(find.byType(GameMoneyLadderCtaButton)).width,
      AppTokens.screenDesignWidth,
    );

    await tester.tap(find.text('UNDERSTAND'));
    await tester.pump();

    expect(dismissCount, 1);
  });

  testWidgets('game dialog action buttons fill width with lighter shadows', (
    WidgetTester tester,
  ) async {
    await _pumpTestSurface(
      tester,
      _TestSurface(
        dialog: const GameConfirmExitDialog(guaranteedAmount: r'$0'),
      ),
    );
    await tester.pump(AppTokens.dialogMotionLong);

    final exitButtonWidth = tester.getSize(_dialogButton('EXIT GAME')).width;
    final continueButtonWidth = tester
        .getSize(_dialogButton('CONTINUE PLAYING'))
        .width;

    expect(exitButtonWidth, greaterThan(AppTokens.screenDesignWidth * 0.75));
    expect(continueButtonWidth, exitButtonWidth);
    expect(
      tester.widget<QzdsGameButton>(_qzdsButton('EXIT GAME')).lightShadow,
      isTrue,
    );
    expect(
      tester
          .widget<QzdsGameButton>(_qzdsButton('CONTINUE PLAYING'))
          .lightShadow,
      isTrue,
    );
  });

  testWidgets('outside tap does not dismiss money ladder dialog', (
    WidgetTester tester,
  ) async {
    var dismissCount = 0;

    await _pumpTestSurface(
      tester,
      _TestSurface(dialog: _moneyLadderDialog, onDismiss: () => dismissCount++),
    );
    await tester.pump(AppTokens.dialogMotionLong);

    await tester.tapAt(const Offset(8, 8));
    await tester.pump();

    expect(dismissCount, 0);
    expect(find.text('MONEY LADDER'), findsOneWidget);
  });

  testWidgets('money ladder with acknowledge button fits compact height', (
    WidgetTester tester,
  ) async {
    final items = buildGameMoneyLadderItems(currentQuestionIndex: 0);

    await _pumpTestSurface(
      tester,
      _TestSurface(height: 568, dialog: GameMoneyLadderDialog(items: items)),
    );
    await tester.pump(AppTokens.dialogMotionLong);

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsNothing);
    expect(find.text('UNDERSTAND'), findsOneWidget);
  });

  testWidgets('outside tap still dismisses visible dialog', (
    WidgetTester tester,
  ) async {
    var dismissCount = 0;

    await _pumpTestSurface(
      tester,
      _TestSurface(
        dialog: const GameConfirmExitDialog(guaranteedAmount: r'$0'),
        onDismiss: () => dismissCount++,
      ),
    );
    await tester.pump(AppTokens.dialogMotionLong);

    await tester.tapAt(const Offset(8, 8));
    await tester.pump();

    expect(dismissCount, 1);
  });
}

Future<void> _pumpTestSurface(WidgetTester tester, _TestSurface surface) async {
  tester.view.physicalSize = Size(AppTokens.screenDesignWidth, surface.height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(surface);
}

Finder _dialogButton(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is GameDialogButton && widget.text == text,
  );
}

Finder _qzdsButton(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is QzdsGameButton && widget.text == text,
  );
}

const _moneyLadderDialog = GameMoneyLadderDialog(
  items: [
    GameMoneyLadderItemData(
      index: 15,
      amount: r'$1,000,000',
      isCurrent: false,
      isSpecial: true,
    ),
    GameMoneyLadderItemData(
      index: 1,
      amount: r'$1,000',
      isCurrent: true,
      isSpecial: false,
    ),
  ],
);

class _TestSurface extends StatelessWidget {
  final GameDialogState dialog;
  final VoidCallback? onDismiss;
  final bool disableAnimations;
  final double height;

  const _TestSurface({
    required this.dialog,
    this.onDismiss,
    this.disableAnimations = false,
    this.height = 812,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: SizedBox(
          width: 375,
          height: height,
          child: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: Colors.black)),
              GameDialogLayer(
                dialog: dialog,
                onDismiss: onDismiss ?? () {},
                onConfirmWalkAway: () {},
                onBackToMenu: () {},
                onPlayAgain: () {},
                onShareResult: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
