import 'package:ai_millionaire_course/data/leaderboard/leaderboard_entry_data.dart';
import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/widgets/menu/leaderboard/menu_leaderboard_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

const _dialogShellKey = ValueKey('leaderboard-dialog-shell');
const _scrollMaskKey = ValueKey('leaderboard-scroll-mask');
const _scrollableTopRowsKey = ValueKey('leaderboard-scrollable-top-rows');
const _currentUserRowKey = ValueKey('leaderboard-current-user-row');
const _frameBorderKey = ValueKey('leaderboard-transparent-frame-border');
const _refreshProgressKey = ValueKey('leaderboard-refresh-progress');
const _loadingProgressKey = ValueKey('leaderboard-loading-progress');

void main() {
  testWidgets('leaderboard dialog renders static leaderboard entries', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _DialogSurface(height: 720));

    expect(find.text('LEADERBOARD'), findsOneWidget);
    expect(find.text('Mít ướt chạy task'), findsOneWidget);
    expect(find.text('2.210.000'), findsOneWidget);
    expect(find.bySemanticsLabel('Rank 125'), findsOneWidget);
    expect(find.text('Tàu hủ đi chill'), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);
    expect(find.byType(ClipOval), findsWidgets);
    expect(_avatarRingColor(tester, 1), AppTokens.yellow400);
    expect(_avatarRingColor(tester, 2), AppTokens.mint500);
    expect(_avatarRingColor(tester, 3), const Color(0xFFFF8A00));
    expect(_avatarRingColor(tester, 4), AppTokens.purple300);
    expect(_avatarRingColor(tester, 125), AppTokens.green400);
    expect(_avatarRingWidth(tester, 1), 2);
    expect(_avatarRingInset(tester, 1), const EdgeInsets.all(4));
    expect(_avatarRingInset(tester, 125), const EdgeInsets.all(2));
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byKey(_frameBorderKey), findsOneWidget);

    final frame = tester.widget<CustomPaint>(find.byKey(_frameBorderKey));
    expect(frame.painter, isNull);
    expect(frame.foregroundPainter, isNotNull);
  });

  testWidgets('leaderboard dialog leaves outside tap space on regular height', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _DialogSurface(height: 720));

    final shellRect = tester.getRect(find.byKey(_dialogShellKey));

    expect(shellRect.top, greaterThanOrEqualTo(AppTokens.spacingLg));
    expect(720 - shellRect.bottom, greaterThanOrEqualTo(AppTokens.spacingLg));
    expect(shellRect.height, lessThan(720));
  });

  testWidgets('leaderboard dialog leaves side backdrop gutters', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _DialogSurface(height: 720));

    final shellRect = tester.getRect(find.byKey(_dialogShellKey));

    expect(shellRect.width, 375 - (AppTokens.spacingXl * 2));
  });

  testWidgets('leaderboard dialog pins current user below scrollable rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _DialogSurface(height: 480));

    final currentRow = find.byKey(_currentUserRowKey);
    final scrollableRows = find.byKey(_scrollableTopRowsKey);

    expect(currentRow, findsOneWidget);
    expect(scrollableRows, findsOneWidget);
    expect(
      find.descendant(
        of: currentRow,
        matching: find.bySemanticsLabel('Rank 125'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: scrollableRows,
        matching: find.bySemanticsLabel('Rank 125'),
      ),
      findsNothing,
    );

    final currentRowTop = tester.getTopLeft(currentRow).dy;
    final scrollableBottom = tester.getBottomLeft(scrollableRows).dy;
    final scrollClip = tester.widget<ClipRRect>(find.byKey(_scrollMaskKey));

    expect(scrollableBottom, lessThanOrEqualTo(currentRowTop));
    expect(scrollClip.borderRadius, BorderRadius.circular(AppTokens.radius4));

    await tester.drag(scrollableRows, const Offset(0, -120));
    await tester.pump();

    expect(tester.getTopLeft(currentRow).dy, currentRowTop);
  });

  testWidgets(
    'leaderboard dialog supports top 10 rows when no current row exists',
    (WidgetTester tester) async {
      final topEntries = List.generate(10, (index) => _topEntry(index + 1));

      await tester.pumpWidget(
        _DialogSurface(
          height: 720,
          state: LeaderboardPopupSuccess(
            entries: topEntries,
            currentEntry: null,
          ),
        ),
      );

      expect(find.byKey(_scrollableTopRowsKey), findsOneWidget);
      expect(find.byKey(_currentUserRowKey), findsNothing);
      expect(find.bySemanticsLabel('Rank 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Rank 10'), findsOneWidget);
      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 10'), findsOneWidget);
      expect(find.bySemanticsLabel('Rank 125'), findsNothing);
    },
  );

  testWidgets('leaderboard dialog fits inside a short viewport', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _DialogSurface(height: 360));

    expect(tester.takeException(), isNull);
    expect(find.text('LEADERBOARD'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('leaderboard dialog renders empty state inside frame', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const _DialogSurface(height: 480, state: LeaderboardPopupEmpty()),
    );

    expect(find.text('LEADERBOARD'), findsOneWidget);
    expect(find.text('No leaderboard data yet'), findsOneWidget);
    expect(find.byKey(_scrollableTopRowsKey), findsNothing);
    expect(find.text('Mít ướt chạy task'), findsNothing);
  });

  testWidgets('leaderboard dialog renders error state and retries', (
    WidgetTester tester,
  ) async {
    var retryCount = 0;

    await tester.pumpWidget(
      _DialogSurface(
        height: 480,
        state: const LeaderboardPopupError(),
        onRetry: () => retryCount++,
      ),
    );

    expect(find.text('Unable to load leaderboard'), findsOneWidget);
    expect(find.text('RETRY'), findsOneWidget);

    await tester.tap(find.text('RETRY'));
    await tester.pump();

    expect(retryCount, 1);
  });

  testWidgets('leaderboard dialog localizes error state in Vietnamese', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const _DialogSurface(
        height: 480,
        locale: Locale('vi'),
        state: LeaderboardPopupError(),
      ),
    );

    expect(find.text('Không thể tải bảng xếp hạng'), findsOneWidget);
  });

  testWidgets('leaderboard dialog renders loading state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const _DialogSurface(height: 480, state: LeaderboardPopupLoading()),
    );

    expect(find.text('Loading leaderboard...'), findsOneWidget);
    expect(find.byKey(_loadingProgressKey), findsOneWidget);
    expect(find.byKey(_scrollableTopRowsKey), findsNothing);
  });

  testWidgets('leaderboard dialog exposes refresh without moving pinned row', (
    WidgetTester tester,
  ) async {
    var refreshCount = 0;

    await tester.pumpWidget(
      _DialogSurface(
        height: 480,
        state: const LeaderboardPopupSuccess(isRefreshing: true),
        onRefresh: () async {
          refreshCount++;
        },
      ),
    );

    final currentRow = find.byKey(_currentUserRowKey);
    final scrollableRows = find.byKey(_scrollableTopRowsKey);
    final currentRowTop = tester.getTopLeft(currentRow).dy;

    expect(find.byKey(_refreshProgressKey), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);

    final refreshIndicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    await refreshIndicator.onRefresh();
    await tester.pump(const Duration(milliseconds: 120));

    await tester.drag(scrollableRows, const Offset(0, -120));
    await tester.pump();

    expect(refreshCount, 1);
    expect(tester.getTopLeft(currentRow).dy, currentRowTop);
  });
}

class _DialogSurface extends StatelessWidget {
  final double height;
  final LeaderboardPopupState state;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onRetry;
  final Locale? locale;

  const _DialogSurface({
    required this.height,
    this.state = const LeaderboardPopupSuccess(),
    this.onRefresh,
    this.onRetry,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Center(
        child: SizedBox(
          width: 375,
          height: height,
          child: Center(
            child: MenuLeaderboardDialog(
              state: state,
              onRefresh: onRefresh,
              onRetry: onRetry,
            ),
          ),
        ),
      ),
    );
  }
}

LeaderboardEntryData _topEntry(int rank) {
  final sourceIndex = (rank - 1)
      .clamp(0, leaderboardEntries.length - 1)
      .toInt();
  final source = leaderboardEntries[sourceIndex];

  return LeaderboardEntryData(
    rank: rank,
    name: 'Player $rank',
    level: 20 - rank,
    score: '${11 - rank}.000',
    avatarAsset: source.avatarAsset,
    rankAsset: source.rankAsset,
    style: source.style,
  );
}

Color _avatarRingColor(WidgetTester tester, int rank) {
  final ring = tester.widget<DecoratedBox>(
    find.byKey(ValueKey('leaderboard-avatar-ring-$rank')),
  );
  final decoration = ring.decoration as BoxDecoration;
  final border = decoration.border as Border;

  return border.top.color;
}

double _avatarRingWidth(WidgetTester tester, int rank) {
  final ring = tester.widget<DecoratedBox>(
    find.byKey(ValueKey('leaderboard-avatar-ring-$rank')),
  );
  final decoration = ring.decoration as BoxDecoration;
  final border = decoration.border as Border;

  return border.top.width;
}

EdgeInsets _avatarRingInset(WidgetTester tester, int rank) {
  final gap = tester.widget<Padding>(
    find.byKey(ValueKey('leaderboard-avatar-gap-$rank')),
  );

  return gap.padding as EdgeInsets;
}
