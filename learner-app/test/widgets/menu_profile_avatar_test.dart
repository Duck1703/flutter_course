import 'package:ai_millionaire_course/core/app_assets.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/widgets/menu/profile/profile_avatar_image.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('guest menu profile avatar renders default asset', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _AvatarSurface(
        isAuthenticated: false,
        data: UserProfileData(
          username: 'Guest Player',
          avatarUrl: 'https://example.com/profile.png',
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));

    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, AppAssets.avatar);
    expect(
      find.byKey(const ValueKey('menu-profile-avatar-initial')),
      findsNothing,
    );
  });

  testWidgets('menu profile avatar renders valid profile avatar URL', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _AvatarSurface(
        data: UserProfileData(
          username: 'Profile Player',
          avatarUrl: 'https://example.com/profile.png',
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));

    expect(image.image, isA<NetworkImage>());
    expect(
      (image.image as NetworkImage).url,
      'https://example.com/profile.png',
    );
    expect(
      find.byKey(const ValueKey('menu-profile-avatar-initial')),
      findsNothing,
    );
  });

  testWidgets('menu profile avatar missing URL shows first name letter', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _AvatarSurface(data: UserProfileData(username: 'Local Player')),
    );

    expect(
      find.byKey(const ValueKey('menu-profile-avatar-initial')),
      findsOneWidget,
    );
    expect(find.text('L'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('menu profile avatar invalid URL shows first name letter', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _AvatarSurface(
        data: UserProfileData(username: 'Broken Avatar', avatarUrl: 'invalid'),
      ),
    );

    expect(
      find.byKey(const ValueKey('menu-profile-avatar-initial')),
      findsOneWidget,
    );
    expect(find.text('B'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets(
    'menu profile avatar network load failure shows first name letter',
    (tester) async {
      await tester.pumpWidget(
        const _AvatarSurface(
          data: UserProfileData(
            username: 'Profile Player',
            avatarUrl: 'https://example.com/profile.png',
          ),
        ),
      );

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
        find.byKey(const ValueKey('menu-profile-avatar-initial')),
        findsOneWidget,
      );
      expect(find.text('P'), findsOneWidget);
    },
  );
}

class _AvatarSurface extends StatelessWidget {
  final UserProfileData data;
  final bool isAuthenticated;

  const _AvatarSurface({required this.data, this.isAuthenticated = true});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Center(
        child: ProfileAvatarImage(
          data: data,
          isAuthenticated: isAuthenticated,
          size: 36,
        ),
      ),
    );
  }
}
