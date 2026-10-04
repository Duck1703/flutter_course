import 'package:ai_millionaire_course/core/app_dependency_scope.dart';
import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/navigation/app_navigation_controller.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository_contract.dart';
import 'package:ai_millionaire_course/repositories/leaderboard/leaderboard_repository.dart';
import 'package:ai_millionaire_course/repositories/onboarding/onboarding_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:ai_millionaire_course/screens/game_screen.dart';
import 'package:ai_millionaire_course/screens/menu_screen.dart';
import 'package:ai_millionaire_course/widgets/menu/auth/menu_auth_dialog.dart';
import 'package:ai_millionaire_course/widgets/menu/auth/menu_sign_out_dialog.dart';
import 'package:ai_millionaire_course/widgets/menu/gradient_cta_button.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_leaderboard_repository.dart';
import 'helpers/fake_profile_sync_repository.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/fake_local_notification_service.dart';

/// M13: `handleMenuUiEvent` route event → điều hướng/mở dialog qua
/// Provider re-read để "gỡ" nút xem màn hình kết nối gì vào root.
/// M14: helper pump dựng `AppDependencyScope` ngoài `MaterialApp` —
/// đúng layout main.dart. M17: locale ghim `vi` qua localizedTestApp.
/// M23: hàng leaderboard → event → dialog (FR-14). M29 (FR-29):
/// M24: scope có thêm `authRepository`/`profileSyncRepository`; pill
/// tài khoản → `requestAuthAction` → `MenuDialogState` → dialog
/// auth/sign-out in-Stack qua `MenuDialogLayer` (FR-28/FR-29); emit site `MenuSnackBarRequested` đã retire
/// (FR-12) — snackbar phát từ VM của chính dialog; class giữ trong
/// sealed family đúng senior (channel contract, zero emit sites).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Host scope y như main.dart ngoài root widget thật.
  Future<Widget> appUnderTest({
    Map<String, Object> prefs = const {'onboarding_completed': true},
    UserProfileRepository? profileRepository,
    FakeLeaderboardRepository? leaderboardRepository,
    FakeAuthRepository? authRepository,
    FakeUserProfileSyncRepository? profileSyncRepository,
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final nav = AppNavigationController();
    final profile =
        profileRepository ?? await UserProfileRepositoryImpl.create();
    return AppDependencyScope(
      userProfileRepository: profile,
      userSettingsRepository: await UserSettingsRepositoryImpl.create(),
      onboardingRepository: await OnboardingRepositoryImpl.create(),
      leaderboardRepository:
          leaderboardRepository ?? const DisabledLeaderboardRepository(),
      authRepository: authRepository ?? FakeAuthRepository(),
      notificationService: FakeLocalNotificationService(),
      profileSyncRepository:
          profileSyncRepository ?? FakeUserProfileSyncRepository(),
      navigationController: nav,
      child: localizedTestApp(
        navigatorKey: nav.navigatorKey,
        home: const MenuScreen(),
      ),
    );
  }

  testWidgets(
    'bấm BẮT ĐẦU CHƠI → MenuGameRequested → bridge điều hướng sang '
    'GameScreen qua AppNavigationController',
    (tester) async {
      await tester.pumpWidget(await appUnderTest());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byType(GradientCtaButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(); // post-frame startNewGame → intro ladder
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Handler thật: event → `_openGame` → `nav.openGame()` push
      // GameScreen (dialog intro "THANG TIỀN THƯỞNG" xác nhận đã tới).
      expect(find.byType(MenuScreen), findsNothing);
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.text('THANG TIỀN THƯỞNG'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'bấm hàng Bảng xếp hạng → MenuDialogLeaderboard → dialog mở '
    'đọc repo từ root scope',
    (tester) async {
      final leaderboard = FakeLeaderboardRepository();
      await tester.pumpWidget(
        await appUnderTest(leaderboardRepository: leaderboard),
      );
      await tester.pump();
      await tester.pump();

      final entry = find.byKey(const ValueKey('menu-leaderboard-entry'));
      await tester.ensureVisible(entry);
      await tester.pump();
      await tester.tap(entry);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(); // post-frame loadLeaderboard
      await tester.pump();

      expect(find.text('BẢNG XẾP HẠNG'), findsOneWidget);
      expect(leaderboard.loadCallCount, 1);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'header guest: pill hiển thị tên "Khách" + hint đồng bộ, không lộ '
    'username local (FR-28)',
    (tester) async {
      // Profile local có username — nhưng guest session KHÔNG hiển thị
      // nó: pill render `menuGuestName` + `menuGuestSyncHint` (senior).
      SharedPreferences.setMockInitialValues(
        const {'onboarding_completed': true},
      );
      final writer = await UserProfileRepositoryImpl.create();
      await writer.saveUserProfile(
        const UserProfileData(username: 'Tên Local'),
      );
      await writer.dispose();
      final profile = await UserProfileRepositoryImpl.create();
      addTearDown(profile.dispose);

      await tester.pumpWidget(
        await appUnderTest(profileRepository: profile),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Khách'), findsOneWidget);
      expect(find.text('Đăng nhập để đồng bộ'), findsOneWidget);
      expect(find.text('Tên Local'), findsNothing);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'bấm pill khi guest → MenuDialogAuth → auth dialog mở với các '
    'nút phương thức (Apple ẩn trên non-iOS)',
    (tester) async {
      await tester.pumpWidget(await appUnderTest());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('menu-profile-pill')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(MenuAuthDialog), findsOneWidget);
      expect(find.text('ĐĂNG NHẬP VỚI GOOGLE'), findsOneWidget);
      expect(find.text('ĐĂNG NHẬP VỚI APPLE'), findsNothing); // gate iOS
      expect(find.text('ĐĂNG NHẬP BẰNG EMAIL'), findsOneWidget);
      expect(find.text('TIẾP TỤC VỚI KHÁCH'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'bấm "Tiếp tục với khách" → DismissRequested → dialog đóng',
    (tester) async {
      await tester.pumpWidget(await appUnderTest());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('menu-profile-pill')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.byType(MenuAuthDialog),
        findsOneWidget,
      );

      await tester.tap(find.text('TIẾP TỤC VỚI KHÁCH'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(MenuAuthDialog), findsNothing);
      expect(find.byType(MenuScreen), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'bấm pill khi authenticated → MenuDialogSignOut → sign-out '
    'dialog mở (FR-28)',
    (tester) async {
      final auth = FakeAuthRepository(
        initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
      );
      addTearDown(auth.dispose);
      await tester.pumpWidget(await appUnderTest(authRepository: auth));
      await tester.pump();
      await tester.pump();

      // Authenticated: pill hiển thị username của profile + "Đã đồng bộ".
      expect(find.text('Đã đồng bộ'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('menu-profile-pill')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.byType(MenuSignOutDialog),
        findsOneWidget,
      );
      expect(find.text('ĐĂNG XUẤT'), findsOneWidget);
      expect(find.text('HỦY'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'sign-in thất bại → snackbar phát TỪ DIALOG VM hiện trong menu '
    'Scaffold, dialog vẫn mở (FR-12)',
    (tester) async {
      final auth = FakeAuthRepository(
        signInResult: const AuthActionResult.failure('Google failed'),
      );
      addTearDown(auth.dispose);
      await tester.pumpWidget(await appUnderTest(authRepository: auth));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('menu-profile-pill')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('ĐĂNG NHẬP VỚI GOOGLE'));
      await tester.pump(); // sign-in future resolve → snackbar event
      await tester.pump(); // SnackBar animation frame

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Google failed'), findsOneWidget);
      // Failure KHÔNG dismiss — dialog còn mở.
      expect(
        find.byType(MenuAuthDialog),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox());
    },
  );
}
