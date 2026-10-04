import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/data/game/level_config.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_level_progress.dart';
import 'package:ai_millionaire_course/widgets/menu/profile/level_progress_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('progress targets the experience required for the current level', () {
    const profile = UserProfileData(level: 3, currentExp: 12400);
    final progress = MenuLevelProgress.fromProfile(profile);

    expect(progress.requiredExp, LevelConfig.getExpRequiredForLevel(3));
    expect(progress.requiredExp, 45000);
    expect(progress.remainingExp, 32600);
    expect(progress.nextLevel, 4);
    expect(progress.ratio, closeTo(12400 / 45000, 0.0001));
    expect(progress.isMaxLevel, isFalse);
  });

  test('progress clamps negative experience and out-of-range levels', () {
    final belowMin = MenuLevelProgress.fromProfile(
      const UserProfileData(level: 0, currentExp: -50),
    );

    expect(belowMin.level, LevelConfig.minLevel);
    expect(belowMin.currentExp, 0);
    expect(belowMin.ratio, 0);
  });

  test('max level reads as complete with nothing remaining', () {
    final progress = MenuLevelProgress.fromProfile(
      const UserProfileData(level: LevelConfig.maxLevel, currentExp: 10),
    );

    expect(progress.isMaxLevel, isTrue);
    expect(progress.ratio, 1);
    expect(progress.remainingExp, 0);
    expect(progress.nextLevel, LevelConfig.maxLevel);
  });

  testWidgets('level card shows the dial, totals, and the next-level goal', (
    tester,
  ) async {
    await tester.pumpWidget(
      _CardSurface(
        progress: MenuLevelProgress.fromProfile(
          const UserProfileData(level: 3, currentExp: 12400),
        ),
      ),
    );

    expect(find.text('LEVEL'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('EXPERIENCE'), findsOneWidget);
    expect(find.text('12.400 / 45.000', findRichText: true), findsOneWidget);
    expect(find.text('32.600 EXP to Level 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('menu-level-ring')), findsOneWidget);
  });

  group('level ring tier', () {
    test('tier follows the milestones the level has passed', () {
      MenuLevelTier tierAt(int level) =>
          MenuLevelProgress.fromProfile(UserProfileData(level: level)).tier;

      expect(tierAt(1), MenuLevelTier.base);
      expect(tierAt(4), MenuLevelTier.base);
      expect(tierAt(5), MenuLevelTier.milestone);
      expect(tierAt(19), MenuLevelTier.milestone);
      expect(tierAt(20), MenuLevelTier.major);
      // Passing a later regular milestone must not demote a major tier.
      expect(tierAt(30), MenuLevelTier.major);
      expect(tierAt(LevelConfig.maxLevel), MenuLevelTier.major);
    });

    test('each tier paints its own ramp', () {
      final ramps = MenuLevelTier.values
          .map(LevelProgressCard.ringGradientFor)
          .toList();

      expect(ramps.toSet(), hasLength(MenuLevelTier.values.length));
    });

    testWidgets('ring accent follows the tier', (tester) async {
      await tester.pumpWidget(
        _CardSurface(
          progress: MenuLevelProgress.fromProfile(
            const UserProfileData(level: 23),
          ),
        ),
      );

      final label = tester.widget<Text>(find.text('LEVEL'));

      expect(label.style?.color, AppTokens.levelRingMajorGradient.colors.first);
      expect(find.byKey(const ValueKey('menu-level-ring')), findsOneWidget);
    });
  });

  group('experience bar', () {
    const barKey = ValueKey('menu-exp-bar');

    Future<LinearProgressIndicator> pumpBar(
      WidgetTester tester,
      UserProfileData profile,
    ) async {
      await tester.pumpWidget(
        _CardSurface(progress: MenuLevelProgress.fromProfile(profile)),
      );

      return tester.widget<LinearProgressIndicator>(find.byKey(barKey));
    }

    testWidgets('bar spans the column and reports the ratio', (tester) async {
      final bar = await pumpBar(
        tester,
        const UserProfileData(level: 3, currentExp: 12400),
      );
      final barRect = tester.getRect(find.byKey(barKey));
      final column = tester.getRect(
        find
            .ancestor(of: find.byKey(barKey), matching: find.byType(Column))
            .first,
      );

      // Guards the collapse where the track shrank to the filled part and the
      // empty remainder of the bar was never drawn.
      expect(barRect.width, column.width);
      expect(bar.value, closeTo(12400 / 45000, 0.0001));
      expect(bar.minHeight, LevelProgressCard.barHeight);
    });

    testWidgets('no progress reports an empty bar', (tester) async {
      final bar = await pumpBar(tester, const UserProfileData(level: 1));

      expect(bar.value, 0);
    });

    testWidgets('a sliver of progress stays visible', (tester) async {
      final bar = await pumpBar(
        tester,
        const UserProfileData(level: 1, currentExp: 30),
      );

      expect(bar.value, greaterThanOrEqualTo(0.02));
    });

    testWidgets('max level fills the bar', (tester) async {
      final bar = await pumpBar(
        tester,
        const UserProfileData(level: LevelConfig.maxLevel),
      );

      expect(bar.value, 1);
    });
  });

  testWidgets('max level card replaces the goal line', (tester) async {
    await tester.pumpWidget(
      _CardSurface(
        progress: MenuLevelProgress.fromProfile(
          const UserProfileData(level: LevelConfig.maxLevel),
        ),
      ),
    );

    expect(find.text('Max level reached'), findsOneWidget);
    expect(find.textContaining('EXP to Level'), findsNothing);
  });
}

class _CardSurface extends StatelessWidget {
  final MenuLevelProgress progress;

  const _CardSurface({required this.progress});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 343,
            child: LevelProgressCard(progress: progress),
          ),
        ),
      ),
    );
  }
}
