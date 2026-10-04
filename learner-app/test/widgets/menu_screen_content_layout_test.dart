import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:ai_millionaire_course/widgets/menu/leaderboard/leaderboard_entry_card.dart';
import 'package:ai_millionaire_course/widgets/menu/menu_screen_content.dart';
import 'package:ai_millionaire_course/widgets/menu/profile/earnings_card.dart';
import 'package:ai_millionaire_course/widgets/menu/profile/level_progress_card.dart';
import 'package:ai_millionaire_course/widgets/menu/profile/stats_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const profile = UserProfileData(
    username: 'LAYOUT PLAYER',
    level: 3,
    currentExp: 12400,
    totalEarnings: '3.400.000 VNĐ',
    gamesJoined: 14,
    gamesWon: 6,
  );

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: MenuScreenContent(userData: profile)),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Gaps between the four stacked panels, top to bottom.
  List<double> panelGapsOf(WidgetTester tester) {
    final level = tester.getRect(find.byType(LevelProgressCard));
    final earnings = tester.getRect(find.byType(EarningsCard));
    final board = tester.getRect(find.byType(LeaderboardEntryCard));
    final stats = tester.getRect(find.byType(StatsCard));

    return [
      earnings.top - level.bottom,
      board.top - earnings.bottom,
      stats.top - board.bottom,
    ];
  }

  testWidgets('menu content lays out on the reference 375x812 frame', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812));

    expect(tester.takeException(), isNull);
    expect(find.text('12.400 / 45.000', findRichText: true), findsOneWidget);
    expect(find.text('3.400.000 VNĐ'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('menu-leaderboard-entry')),
      findsOneWidget,
    );
    expect(find.text('43%'), findsOneWidget);
  });

  testWidgets('panels keep one fixed gap so they read as a single block', (
    tester,
  ) async {
    for (final height in [812.0, 915.0, 640.0]) {
      await pumpAt(tester, Size(375, height));

      expect(
        panelGapsOf(tester),
        everyElement(MenuScreenContent.panelGap),
        reason: 'gaps must not stretch at height $height',
      );
    }
  });

  testWidgets('block is centered in the available height', (tester) async {
    for (final height in [812.0, 915.0]) {
      await pumpAt(tester, Size(375, height));

      final area = tester.getRect(find.byType(MenuScreenContent));
      final level = tester.getRect(find.byType(LevelProgressCard));
      final stats = tester.getRect(find.byType(StatsCard));

      final marginTop = level.top - area.top;
      final marginBottom = area.bottom - stats.bottom;

      expect(marginTop, greaterThan(MenuScreenContent.panelGap));
      expect(
        marginTop,
        closeTo(marginBottom, 1),
        reason: 'margins must stay symmetric at height $height',
      );
    }
  });

  testWidgets('menu content scrolls instead of overflowing when short', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 420));

    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(MenuScreenContent), const Offset(0, -160));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('43%'), findsOneWidget);
  });
}
