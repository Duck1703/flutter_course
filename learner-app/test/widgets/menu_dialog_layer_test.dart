import 'package:ai_millionaire_course/core/app_assets.dart';
import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/leaderboard/leaderboard_entry_data.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository.dart';
import 'package:ai_millionaire_course/repositories/leaderboard/leaderboard_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_sync_repository.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:ai_millionaire_course/services/local_notification_service.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_dialog_state.dart';
import 'package:ai_millionaire_course/widgets/menu/menu_dialog_backdrop.dart';
import 'package:ai_millionaire_course/widgets/menu/menu_dialog_layer.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_leaderboard_repository.dart';
import '../helpers/fake_local_notification_service.dart';
import '../helpers/fake_profile_sync_repository.dart';

const _leaderboardShellKey = ValueKey('leaderboard-dialog-shell');

MenuDialogLayer _dialogLayer({
  required MenuDialogState dialogState,
  VoidCallback? onDismiss,
}) {
  return MenuDialogLayer(
    dialogState: dialogState,
    onDismiss: onDismiss ?? () {},
  );
}

void main() {
  late UserSettingsRepository settingsRepository;
  late UserProfileRepository userProfileRepository;
  late FakeAuthRepository authRepository;
  late FakeUserProfileSyncRepository profileSyncRepository;
  late FakeLeaderboardRepository leaderboardRepository;
  late FakeLocalNotificationService notificationService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Flutter Accelerator AI',
      packageName: 'app.ai_millionaire_course',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    settingsRepository = await UserSettingsRepositoryImpl.create();
    userProfileRepository = await UserProfileRepositoryImpl.create();
    authRepository = FakeAuthRepository();
    profileSyncRepository = FakeUserProfileSyncRepository();
    leaderboardRepository = FakeLeaderboardRepository(
      snapshot: const LeaderboardSnapshot(
        entries: [_leaderboardEntry],
        currentEntry: _currentEntry,
      ),
    );
    notificationService = FakeLocalNotificationService();
  });

  tearDown(() async {
    await settingsRepository.dispose();
    await userProfileRepository.dispose();
    await authRepository.dispose();
    await profileSyncRepository.dispose();
  });

  Widget settingsScope(Widget child) {
    return MultiProvider(
      providers: [
        Provider<UserSettingsRepository>.value(value: settingsRepository),
        Provider<LocalNotificationService>.value(value: notificationService),
      ],
      child: child,
    );
  }

  Widget leaderboardScope(Widget child) {
    return MultiProvider(
      providers: [
        Provider<UserProfileRepository>.value(value: userProfileRepository),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<LeaderboardRepository>.value(value: leaderboardRepository),
      ],
      child: child,
    );
  }

  Widget authScope(Widget child) {
    return MultiProvider(
      providers: [
        Provider<UserProfileRepository>.value(value: userProfileRepository),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<UserProfileSyncRepository>.value(value: profileSyncRepository),
      ],
      child: child,
    );
  }

  testWidgets('menu dialog none state does not block underlying taps', (
    WidgetTester tester,
  ) async {
    var backgroundTaps = 0;
    await tester.pumpWidget(
      _TestSurface(
        onBackgroundTap: () => backgroundTaps++,
        child: _dialogLayer(
          dialogState: const MenuDialogNone(),
          onDismiss: () {},
        ),
      ),
    );

    expect(find.text('LEADERBOARD'), findsNothing);
    expect(find.byType(MenuDialogBackdrop), findsNothing);
    expect(
      find.byKey(const ValueKey('menu-dialog-backdrop-filter')),
      findsNothing,
    );

    await tester.tap(find.byKey(_backgroundKey));
    await tester.pump();

    expect(backgroundTaps, 1);
  });

  testWidgets('menu dialog layer renders leaderboard popup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestSurface(
        child: leaderboardScope(
          _dialogLayer(
            dialogState: const MenuDialogLeaderboard(),
            onDismiss: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('LEADERBOARD'), findsOneWidget);
    expect(find.text('REMOTE PLAYER'), findsOneWidget);
    expect(leaderboardRepository.loadCallCount, 1);
    expect(find.byType(MenuDialogBackdrop), findsOneWidget);
    expect(
      find.byKey(const ValueKey('menu-dialog-backdrop-filter')),
      findsOneWidget,
    );
    final hazeOverlay = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('menu-dialog-haze-overlay')),
    );

    expect(hazeOverlay.color, Colors.transparent);

    final refreshIndicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    await refreshIndicator.onRefresh();
    await tester.pump();

    expect(leaderboardRepository.loadCallCount, 2);
  });

  testWidgets('menu dialog layer renders settings popup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestSurface(
        child: settingsScope(
          _dialogLayer(
            dialogState: const MenuDialogSettings(),
            onDismiss: () {},
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.byType(MenuDialogBackdrop), findsOneWidget);
  });

  testWidgets('settings save dismisses through dialog scoped bridge', (
    WidgetTester tester,
  ) async {
    var dismissCount = 0;
    await tester.pumpWidget(
      _TestSurface(
        child: settingsScope(
          _dialogLayer(
            dialogState: const MenuDialogSettings(),
            onDismiss: () => dismissCount++,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('DONE'));
    await tester.tap(find.text('DONE'));
    await tester.pump();

    expect(dismissCount, 1);
  });

  testWidgets('settings snackbar events use dialog scoped bridge', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestSurface(
        child: settingsScope(
          _dialogLayer(
            dialogState: const MenuDialogSettings(),
            onDismiss: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Notifications'));
    await tester.pump();

    expect(find.text('Notification permission required'), findsOneWidget);
  });

  testWidgets('settings snackbar events use Vietnamese locale', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestSurface(
        locale: const Locale('vi'),
        child: settingsScope(
          _dialogLayer(
            dialogState: const MenuDialogSettings(),
            onDismiss: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Thông báo'));
    await tester.pump();

    expect(find.text('Cần cấp quyền thông báo'), findsOneWidget);
  });

  testWidgets('settings time picker uses full screen backdrop', (
    WidgetTester tester,
  ) async {
    notificationService.requestResult = true;
    var dismissCount = 0;
    await tester.pumpWidget(
      _TestSurface(
        child: settingsScope(
          _dialogLayer(
            dialogState: const MenuDialogSettings(),
            onDismiss: () => dismissCount++,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-time-row')));
    await tester.pumpAndSettle();

    final backdropFinder = find.byKey(
      const ValueKey('settings-time-picker-backdrop-filter'),
    );

    expect(backdropFinder, findsOneWidget);
    expect(
      find.byKey(const ValueKey('settings-time-picker-modal-barrier')),
      findsOneWidget,
    );
    expect(tester.getTopLeft(backdropFinder), Offset.zero);
    expect(
      tester.getSize(backdropFinder),
      tester.getSize(find.byKey(_backgroundKey)),
    );

    await tester.tapAt(const Offset(12, 12));
    await tester.pump();

    expect(dismissCount, 0);
    expect(backdropFinder, findsOneWidget);
  });

  testWidgets('menu dialog layer renders Android social sign in popup', (
    WidgetTester tester,
  ) async {
    var dismissCount = 0;
    await tester.pumpWidget(
      _TestSurface(
        platform: TargetPlatform.android,
        child: authScope(
          _dialogLayer(
            dialogState: const MenuDialogAuth(),
            onDismiss: () => dismissCount++,
          ),
        ),
      ),
    );

    expect(find.text('SYNC YOUR PROGRESS'), findsOneWidget);
    expect(
      find.text('Use your phone account to sync progress across devices.'),
      findsOneWidget,
    );
    expect(find.text('SIGN IN WITH GOOGLE'), findsOneWidget);
    expect(find.text('SIGN IN WITH APPLE'), findsNothing);
    expect(find.text('CONTINUE AS GUEST'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
    expect(find.text('Password'), findsNothing);
    expect(find.text('Confirm Password'), findsNothing);
    expect(find.text('SIGN IN'), findsNothing);
    expect(find.text('Create Account'), findsNothing);
    expect(find.text('CREATE ACCOUNT'), findsNothing);
    expect(find.byKey(const ValueKey('auth-actions-signIn')), findsNothing);
    expect(find.byKey(const ValueKey('auth-actions-register')), findsNothing);
    expect(find.text('Enter your email and password.'), findsNothing);
    expect(find.text('BACK'), findsNothing);
    expect(find.text('SIGN IN WITH EMAIL'), findsOneWidget);
    expect(find.byType(MenuDialogBackdrop), findsOneWidget);

    expect(authRepository.signInCallCount, 0);
    expect(authRepository.appleSignInCallCount, 0);
    expect(dismissCount, 0);
  });

  testWidgets('menu dialog layer renders iOS social sign in popup', (
    WidgetTester tester,
  ) async {
    var dismissCount = 0;
    await tester.pumpWidget(
      _TestSurface(
        platform: TargetPlatform.iOS,
        child: authScope(
          _dialogLayer(
            dialogState: const MenuDialogAuth(),
            onDismiss: () => dismissCount++,
          ),
        ),
      ),
    );

    expect(find.text('SIGN IN WITH GOOGLE'), findsOneWidget);
    expect(find.text('SIGN IN WITH APPLE'), findsOneWidget);
    expect(find.text('CONTINUE AS GUEST'), findsOneWidget);
    expect(find.text('SIGN IN WITH EMAIL'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
    expect(dismissCount, 0);
  });

  testWidgets('menu dialog layer switches to email form from email option', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestSurface(
        platform: TargetPlatform.android,
        child: authScope(_dialogLayer(dialogState: const MenuDialogAuth())),
      ),
    );

    expect(find.text('SIGN IN WITH EMAIL'), findsOneWidget);

    await tester.tap(find.text('SIGN IN WITH EMAIL'));
    await tester.pump();

    expect(find.text('SIGN IN WITH GOOGLE'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.byType(SizeTransition), findsNothing);
    for (final key in [
      'auth-method-form-size',
      'auth-method-buttons-size',
      'auth-email-form-size',
    ]) {
      expect(
        tester.widget<AnimatedSize>(find.byKey(ValueKey(key))).clipBehavior,
        Clip.none,
      );
    }
    final authSwitcher = tester.widget<AnimatedSwitcher>(
      find.byKey(const ValueKey('auth-method-form-switcher')),
    );
    expect(authSwitcher.duration, const Duration(milliseconds: 380));
    expect(authSwitcher.reverseDuration, const Duration(milliseconds: 380));

    await tester.pumpAndSettle();

    expect(find.text('SIGN IN WITH GOOGLE'), findsNothing);
    expect(find.text('SIGN IN WITH EMAIL'), findsNothing);
    expect(find.text('CONTINUE AS GUEST'), findsNothing);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    await tester.tap(find.text('Create Account'));
    await tester.pump();

    expect(find.text('Confirm Password'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('auth-submit-button-signIn')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('auth-submit-button-register')),
      findsOneWidget,
    );

    await tester.pumpAndSettle();

    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create Account'), findsNothing);

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Confirm Password'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('auth-submit-button-signIn')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('auth-submit-button-register')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('auth-mode-toggle-signIn')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('auth-mode-toggle-register')),
      findsNothing,
    );

    await tester.tap(find.text('Back'));
    await tester.pump();

    expect(find.text('SIGN IN WITH EMAIL'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('SIGN IN WITH EMAIL'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
  });

  testWidgets('menu dialog layer signs in with Google from dialog scope', (
    WidgetTester tester,
  ) async {
    var dismissCount = 0;
    await tester.pumpWidget(
      _TestSurface(
        platform: TargetPlatform.android,
        child: authScope(
          _dialogLayer(
            dialogState: const MenuDialogAuth(),
            onDismiss: () => dismissCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('SIGN IN WITH GOOGLE'));
    await tester.pumpAndSettle();

    expect(authRepository.signInCallCount, 1);
    expect(authRepository.appleSignInCallCount, 0);
    expect(profileSyncRepository.syncCallCount, 1);
    expect(dismissCount, 1);
    expect(find.text('Signed in successfully.'), findsOneWidget);
  });

  testWidgets('menu dialog layer signs in with Apple from dialog scope', (
    WidgetTester tester,
  ) async {
    var dismissCount = 0;

    await tester.pumpWidget(
      _TestSurface(
        platform: TargetPlatform.iOS,
        child: authScope(
          _dialogLayer(
            dialogState: const MenuDialogAuth(),
            onDismiss: () => dismissCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('SIGN IN WITH APPLE'));
    await tester.pumpAndSettle();

    expect(authRepository.signInCallCount, 0);
    expect(authRepository.appleSignInCallCount, 1);
    expect(profileSyncRepository.syncCallCount, 1);
    expect(dismissCount, 1);
    expect(find.text('Signed in successfully.'), findsOneWidget);
  });

  testWidgets('menu dialog layer continues as guest from auth popup', (
    WidgetTester tester,
  ) async {
    var dismissCount = 0;
    await tester.pumpWidget(
      _TestSurface(
        platform: TargetPlatform.android,
        child: authScope(
          _dialogLayer(
            dialogState: const MenuDialogAuth(),
            onDismiss: () => dismissCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('CONTINUE AS GUEST'));
    await tester.pump();

    expect(authRepository.signInCallCount, 0);
    expect(authRepository.appleSignInCallCount, 0);
    expect(dismissCount, 1);
  });

  testWidgets('menu dialog layer signs out from dialog scope', (
    WidgetTester tester,
  ) async {
    authRepository = FakeAuthRepository(
      initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
    );
    var dismissCount = 0;
    await tester.pumpWidget(
      _TestSurface(
        child: authScope(
          _dialogLayer(
            dialogState: const MenuDialogSignOut(),
            onDismiss: () => dismissCount++,
          ),
        ),
      ),
    );

    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('SIGN OUT'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);

    await tester.tap(find.text('SIGN OUT'));
    await tester.pumpAndSettle();

    expect(authRepository.signOutCallCount, 1);
    expect(dismissCount, 1);
    expect(find.text('Signed out successfully.'), findsOneWidget);
  });

  testWidgets('failed dialog scoped sign out keeps confirmation open', (
    WidgetTester tester,
  ) async {
    authRepository = FakeAuthRepository(
      initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
      signOutResult: const AuthActionResult.failure('Sign out failed.'),
    );
    var dismissCount = 0;
    await tester.pumpWidget(
      _TestSurface(
        child: authScope(
          _dialogLayer(
            dialogState: const MenuDialogSignOut(),
            onDismiss: () => dismissCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('SIGN OUT'));
    await tester.pumpAndSettle();

    expect(authRepository.signOutCallCount, 1);
    expect(dismissCount, 0);
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('Sign out failed.'), findsOneWidget);

    await tester.tap(find.text('CANCEL'));
    await tester.pump();

    expect(dismissCount, 1);
  });

  testWidgets('outside tap dismisses and inside tap is consumed', (
    WidgetTester tester,
  ) async {
    var dismissCount = 0;
    await tester.pumpWidget(
      _TestSurface(
        child: leaderboardScope(
          _dialogLayer(
            dialogState: const MenuDialogLeaderboard(),
            onDismiss: () => dismissCount++,
          ),
        ),
      ),
    );
    await tester.pump();

    final shellRect = tester.getRect(find.byKey(_leaderboardShellKey));

    expect(shellRect.left, greaterThan(0));

    await tester.tapAt(shellRect.center);
    await tester.pump();

    expect(dismissCount, 0);

    await tester.tapAt(Offset(shellRect.left / 2, shellRect.center.dy));
    await tester.pump();

    expect(dismissCount, 1);
  });
}

const _leaderboardEntry = LeaderboardEntryData(
  rank: 1,
  name: 'REMOTE PLAYER',
  level: 9,
  score: '9.000',
  avatarAsset: AppAssets.avatarMitUotChayTask,
  rankAsset: AppAssets.leaderboardRank1,
  style: LeaderboardRowStyle.first,
);

const _currentEntry = LeaderboardEntryData(
  rank: 7,
  name: 'CURRENT PLAYER',
  level: 5,
  score: '5.000',
  avatarAsset: AppAssets.avatarTauHuDiChill,
  rankAsset: AppAssets.leaderboardRankCurrent,
  style: LeaderboardRowStyle.currentUser,
  isCurrentUser: true,
);

const _backgroundKey = ValueKey('menu-dialog-test-background');

class _TestSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBackgroundTap;
  final TargetPlatform? platform;
  final Locale? locale;

  const _TestSurface({
    required this.child,
    this.onBackgroundTap,
    this.platform,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: platform == null ? null : ThemeData(platform: platform),
      home: Scaffold(
        body: SizedBox(
          width: 375,
          height: 812,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  key: _backgroundKey,
                  behavior: HitTestBehavior.opaque,
                  onTap: onBackgroundTap,
                  child: const ColoredBox(color: Colors.black),
                ),
              ),
              Positioned.fill(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
