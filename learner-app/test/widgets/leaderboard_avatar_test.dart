import 'package:ai_millionaire_course/core/app_design_tokens.dart';
import 'package:ai_millionaire_course/data/leaderboard/leaderboard_entry_data.dart';
import 'package:ai_millionaire_course/widgets/leaderboard/leaderboard_avatar.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('current user renders valid profile avatar URL', (tester) async {
    await tester.pumpWidget(const _AvatarSurface(entry: _currentEntry));

    final image = tester.widget<Image>(find.byType(Image));

    expect(image.image, isA<NetworkImage>());
    expect((image.image as NetworkImage).url, _currentEntry.avatarUrl);
    expect(
      find.byKey(const ValueKey('leaderboard-avatar-initial-125')),
      findsNothing,
    );
  });

  testWidgets('current user missing avatar URL shows first name letter', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _AvatarSurface(
        entry: LeaderboardEntryData(
          rank: 125,
          name: 'Local Player',
          level: 4,
          score: '4.000',
          avatarAsset: AppAssets.avatarTauHuDiChill,
          rankAsset: AppAssets.leaderboardRankCurrent,
          style: LeaderboardRowStyle.currentUser,
          isCurrentUser: true,
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('leaderboard-avatar-initial-125')),
      findsOneWidget,
    );
    expect(find.text('L'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('invalid Supabase avatar URL shows first name letter', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _AvatarSurface(
        entry: LeaderboardEntryData(
          rank: 125,
          name: 'Broken Avatar',
          level: 4,
          score: '4.000',
          avatarAsset: AppAssets.avatarTauHuDiChill,
          avatarUrl: 'not-a-url',
          rankAsset: AppAssets.leaderboardRankCurrent,
          style: LeaderboardRowStyle.currentUser,
          isCurrentUser: true,
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('leaderboard-avatar-initial-125')),
      findsOneWidget,
    );
    expect(find.text('B'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('network load failure shows first name letter', (tester) async {
    await tester.pumpWidget(const _AvatarSurface(entry: _currentEntry));

    final imageFinder = find.byType(Image);
    final image = tester.widget<Image>(imageFinder);
    final fallback = image.errorBuilder!(
      tester.element(imageFinder),
      Exception('failed to load avatar'),
      StackTrace.current,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: fallback,
      ),
    );

    expect(
      find.byKey(const ValueKey('leaderboard-avatar-initial-125')),
      findsOneWidget,
    );
    expect(find.text('P'), findsOneWidget);
  });

  testWidgets('static row without avatar URL keeps bundled avatar asset', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _AvatarSurface(
        entry: LeaderboardEntryData(
          rank: 4,
          name: 'Static Player',
          level: 9,
          score: '510.000',
          avatarAsset: AppAssets.avatarRongBienBietBoi,
          rankAsset: AppAssets.leaderboardRank4,
          style: LeaderboardRowStyle.glass,
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));

    expect(image.image, isA<AssetImage>());
    expect(
      (image.image as AssetImage).assetName,
      AppAssets.avatarRongBienBietBoi,
    );
    expect(
      find.byKey(const ValueKey('leaderboard-avatar-initial-4')),
      findsNothing,
    );
  });
}

const _currentEntry = LeaderboardEntryData(
  rank: 125,
  name: 'Profile Player',
  level: 4,
  score: '4.000',
  avatarAsset: AppAssets.avatarTauHuDiChill,
  avatarUrl: 'https://example.com/avatar.png',
  rankAsset: AppAssets.leaderboardRankCurrent,
  style: LeaderboardRowStyle.currentUser,
  isCurrentUser: true,
);

class _AvatarSurface extends StatelessWidget {
  final LeaderboardEntryData entry;

  const _AvatarSurface({required this.entry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Center(
        child: ColoredBox(
          color: AppTokens.blue900,
          child: LeaderboardAvatar(entry: entry),
        ),
      ),
    );
  }
}
