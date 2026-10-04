import 'package:ai_millionaire_course/core/app_dependency_scope.dart';
import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/navigation/app_navigation_controller.dart';
import 'package:ai_millionaire_course/repositories/leaderboard/leaderboard_repository.dart';
import 'package:ai_millionaire_course/repositories/onboarding/onboarding_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:ai_millionaire_course/screens/menu_screen.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_profile_sync_repository.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/fake_local_notification_service.dart';

/// Test DI của M14: scope app-level giờ là `MultiProvider` của BA
/// repository contract — đúng shape senior `AppDependencyScope`.
///
/// Widget test bọc cây trong cùng các provider app thật dùng; repo
/// được tạo bằng `Impl.create()` trên prefs mock — đúng cách main()
/// bootstrap.
void main() {
  Future<UserProfileRepositoryImpl> profileRepo() async {
    SharedPreferences.setMockInitialValues(const {'onboarding_completed': true});
    return UserProfileRepositoryImpl.create();
  }

  Future<Widget> scopedMenu(
    UserProfileRepository repo, {
    AuthSessionData session = const AuthSessionGuest(),
  }) async {
    return AppDependencyScope(
      userProfileRepository: repo,
      userSettingsRepository: await UserSettingsRepositoryImpl.create(),
      onboardingRepository: await OnboardingRepositoryImpl.create(),
      leaderboardRepository: const DisabledLeaderboardRepository(),
      notificationService: FakeLocalNotificationService(),
      // M24: scope yêu cầu cặp auth/sync repo — fakes; `session` chọn
      // guest (pill hiện "Khách") hay authenticated (hiện username).
      authRepository: FakeAuthRepository(initialSession: session),
      profileSyncRepository: FakeUserProfileSyncRepository(),
      navigationController: AppNavigationController(),
      child: localizedTestApp(home: const MenuScreen()),
    );
  }

  testWidgets('scope cung cấp repo contract → VM đọc profile đã lưu '
      'qua stream', (tester) async {
    // Seed prefs bằng repo thứ nhất — kiểm chứng toàn chuỗi:
    // disk → repo impl → BehaviorSubject → VM → UI.
    const saved = UserProfileData(username: 'Minh', gamesJoined: 7);
    SharedPreferences.setMockInitialValues(const {'onboarding_completed': true});
    final writer = await UserProfileRepositoryImpl.create();
    await writer.saveUserProfile(saved);
    await writer.dispose();

    // Repo đọc trên CÙNG prefs — KHÔNG reseed (setMockInitialValues
    // lần hai reset mock store, xoá mất 'user_profile' vừa ghi).
    final repo = await UserProfileRepositoryImpl.create();
    // M24: pill chỉ hiển thị username khi session AUTHENTICATED —
    // guest render `menuGuestName`. Session authed → 'Minh' hiện.
    await tester.pumpWidget(
      await scopedMenu(
        repo,
        session: const AuthSessionAuthenticated(uid: 'u1'),
      ),
    );
    await tester.pump(); // cho loadUserProfile() emit qua stream
    await tester.pump(); // notify → rebuild

    expect(find.text('Minh'), findsOneWidget);
    expect(find.text('7'), findsOneWidget); // stat "Đã chơi"

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('profile render NGAY từ seed — không có màn loading',
      (tester) async {
    final repo = await profileRepo();
    await tester.pumpWidget(await scopedMenu(repo));

    // Frame đầu tiên đã có UI đầy đủ: `.value` của seeded subject
    // seed VM đồng bộ — `MenuLoadState`/`_MenuLoading` đã retire
    // (FR-08): không còn 'Đang tải hồ sơ…' hay nút THỬ LẠI.
    expect(find.text('Đang tải hồ sơ…'), findsNothing);
    expect(find.text('THỬ LẠI'), findsNothing);
    // M24: session mặc định guest → pill hiện 'Khách' (username local
    // '0XFF' không hiển thị — chỉ hiện khi đã đăng nhập).
    expect(find.text('Khách'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('save lên repo TRONG test → UI cập nhật qua stream '
      '(không reload tay)', (tester) async {
    final repo = await profileRepo();
    // M24: session authenticated → pill hiện username từ stream.
    await tester.pumpWidget(
      await scopedMenu(
        repo,
        session: const AuthSessionAuthenticated(uid: 'u1'),
      ),
    );
    await tester.pump();
    expect(find.text('0XFF'), findsOneWidget);

    // Một writer bất kỳ save → BehaviorSubject emit → VM nhận →
    // notifyListeners → build lại. Đây là cốt lõi M14. Hai pump:
    // một cho microtask deliver emit, một cho frame rebuild.
    await repo.saveUserProfile(const UserProfileData(username: 'Stream'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Stream'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('ChangeNotifierProvider tự dispose VM khi màn hình '
      'rời cây', (tester) async {
    final repo = await profileRepo();
    await tester.pumpWidget(await scopedMenu(repo));

    // Lấy VM mà provider đã tạo — context của widget BÊN DƯỚI
    // provider mới tra được (đây chính là bài học lookup).
    final viewElement = tester.element(find.byType(Scaffold));
    final vm = viewElement.read<MenuScreenViewModel>();
    expect(vm.userData, const UserProfileData());

    // Gỡ cây → provider unmount → tự dispose VM (M11 phải tự tay).
    await tester.pumpWidget(const SizedBox());

    // ChangeNotifier đã dispose: addListener trên nó ném FlutterError.
    expect(
      () => vm.addListener(() {}),
      throwsA(isA<FlutterError>()),
    );
  });
}
