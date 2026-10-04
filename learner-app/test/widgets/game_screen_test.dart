import 'package:ai_millionaire_course/core/app_dependency_scope.dart';
import 'package:ai_millionaire_course/data/game/game_quiz_question_data.dart';
import 'package:ai_millionaire_course/data/game/game_sample_questions_data.dart';
import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/navigation/app_navigation_controller.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository_contract.dart';
import 'package:ai_millionaire_course/repositories/leaderboard/leaderboard_repository.dart';
import 'package:ai_millionaire_course/repositories/onboarding/onboarding_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_sync_repository_contract.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:ai_millionaire_course/screens/game_screen.dart';
import 'package:ai_millionaire_course/screens/menu_screen.dart';
import 'package:ai_millionaire_course/widgets/menu/gradient_cta_button.dart';
import 'package:ai_millionaire_course/widgets/game/answers/game_answer_option.dart';
import 'package:ai_millionaire_course/widgets/game/dialogs/game_confirm_dialogs.dart';
import 'package:ai_millionaire_course/widgets/game/lifelines/game_feature_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_profile_sync_repository.dart';
import '../helpers/fake_user_profile_repository.dart';
import '../helpers/localized_test_app.dart';
import '../helpers/fake_local_notification_service.dart';

/// Widget test màn chơi — M19, VI-locale surface.
///
/// M28: `GameScreen` hội tụ senior (`const`, tự tạo VM qua
/// `ChangeNotifierProvider` + `context.read` repos) — không còn tham
/// số `viewModel:`/bank-mini. Host test = `MultiProvider` fakes +
/// `localizedTestApp(vi)`; flows drive qua UI + bank thật
/// (`gameSampleQuestions`, 15 câu). Flow cốt lõi EN-locale được
/// `game_screen_flow_test.dart` (senior-verbatim) phủ; file này giữ
/// các assertion tiếng Việt + coverage độc quyền learner (victory,
/// walk-away + save-once, timeout, menu→game→THOÁT).
///
/// Dialog titles/buttons giờ uppercase trong view (`title.toUpperCase`)
/// — assertion vi dùng dạng HOA ('THANG TIỀN THƯỞNG', 'ĐÃ HIỂU'…).
void main() {
  /// Pump `GameScreen` const (senior pattern): VM tự tạo qua
  /// `context.read` — fakes đi qua `MultiProvider`.
  Future<void> pumpGameVi(
    WidgetTester tester, {
    FakeUserProfileRepository? profileRepo,
    FakeAuthRepository? authRepo,
    FakeUserProfileSyncRepository? syncRepo,
  }) async {
    final nav = AppNavigationController();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppNavigationController>.value(value: nav),
          Provider<UserProfileRepository>.value(
            value: profileRepo ?? FakeUserProfileRepository(),
          ),
          Provider<AuthRepository>.value(
            value: authRepo ?? FakeAuthRepository(),
          ),
          Provider<UserProfileSyncRepository>.value(
            value: syncRepo ?? FakeUserProfileSyncRepository(),
          ),
        ],
        child: localizedTestApp(
          navigatorKey: nav.navigatorKey,
          home: const GameScreen(),
        ),
      ),
    );
  }

  /// Qua intro ladder: 'THANG TIỀN THƯỞNG' → tap 'ĐÃ HIỂU' → đang chơi.
  Future<void> dismissIntroLadder(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('THANG TIỀN THƯỞNG'), findsOneWidget);
    await tester.tap(find.text('ĐÃ HIỂU'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Finder answerOption(String text) => find.byWidgetPredicate(
        (w) => w is GameAnswerOption && w.data.answerText == text,
      );

  /// Tap đáp án đúng của `q` → chờ reveal+explanation → đóng 'ĐÃ HIỂU'
  /// (đang ở câu kế hoặc dialog kết thúc/victory). `ensureVisible`
  /// scroll option vào viewport — layout senior (SingleChildScrollView)
  /// có thể để option dưới cao hơn đáy màn test 800×600.
  Future<void> answerCorrectAndAdvance(
    WidgetTester tester,
    GameQuizQuestionData q,
  ) async {
    final option = answerOption(q.correctOption);
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2600)); // 1500+1000
    await tester.pump(); // post-frame mở dialog
    await tester.pump(const Duration(milliseconds: 300)); // entry
    expect(find.text('GIẢI THÍCH AI'), findsOneWidget);
    await tester.tap(find.text('ĐÃ HIỂU'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // outgoing
  }

  Finder featureButton(GameFeatureButtonType type) =>
      find.byWidgetPredicate(
        (w) => w is GameFeatureButton && w.data.type == type,
      );

  Future<void> unmount(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox());

  /// Host menu đầy đủ (repos + nav controller + navigatorKey).
  Future<AppDependencyScope> menuApp() async {
    SharedPreferences.setMockInitialValues(const {'onboarding_completed': true});
    final nav = AppNavigationController();
    return AppDependencyScope(
      userProfileRepository: await UserProfileRepositoryImpl.create(),
      userSettingsRepository: await UserSettingsRepositoryImpl.create(),
      onboardingRepository: await OnboardingRepositoryImpl.create(),
      leaderboardRepository: const DisabledLeaderboardRepository(),
      authRepository: FakeAuthRepository(),
      notificationService: FakeLocalNotificationService(),
      profileSyncRepository: FakeUserProfileSyncRepository(),
      navigationController: nav,
      child: localizedTestApp(
        navigatorKey: nav.navigatorKey,
        home: const MenuScreen(),
      ),
    );
  }

  testWidgets('mở màn → dialog thang tiền intro hiện, game chưa chạy',
      (tester) async {
    await pumpGameVi(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('THANG TIỀN THƯỞNG'), findsOneWidget);
    // Thang đảo: dòng đầu là level 15 = $1,000,000.
    expect(find.text(r'$1,000,000'), findsOneWidget);
    // Câu hỏi vẫn render phía sau nhưng timer chưa chạy.
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:30'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('đóng intro → câu hỏi + 4 đáp án + timer đếm', (tester) async {
    await pumpGameVi(tester);
    await dismissIntroLadder(tester);

    expect(find.text(gameSampleQuestions[0].question), findsOneWidget);
    expect(find.text('1/15'), findsOneWidget);
    for (final o in gameSampleQuestions[0].options) {
      expect(find.text(o), findsOneWidget);
    }
    expect(find.text(r'$0'), findsOneWidget); // money top bar

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:28'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('tap đáp án đúng → reveal → giải thích → câu 2',
      (tester) async {
    await pumpGameVi(tester);
    await dismissIntroLadder(tester);

    final first = answerOption(gameSampleQuestions[0].correctOption);
    await tester.ensureVisible(first);
    await tester.tap(first);
    await tester.pump();
    expect(find.text('00:30'), findsOneWidget); // timer dừng

    await tester.pump(const Duration(milliseconds: 1600)); // qua reveal

    await tester.pump(const Duration(milliseconds: 1100)); // explanation
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('GIẢI THÍCH AI'), findsOneWidget);

    await tester.tap(find.text('ĐÃ HIỂU'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // M28: money animation settle trong cửa sổ explanation → assert
    // SAU dismiss như senior flow test.
    expect(find.text(r'$1,000'), findsOneWidget); // money lên level 1
    expect(find.text(gameSampleQuestions[1].question), findsOneWidget);
    expect(find.text('2/15'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('tap sai → giải thích → đóng → dialog Kết thúc',
      (tester) async {
    await pumpGameVi(tester);
    await dismissIntroLadder(tester);

    final wrong = gameSampleQuestions[0]
        .options
        .firstWhere((o) => o != gameSampleQuestions[0].correctOption);
    await tester.ensureVisible(answerOption(wrong));
    await tester.tap(answerOption(wrong));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(); // post-frame mở explanation
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('ĐÃ HIỂU'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('KẾT THÚC'), findsOneWidget);
    expect(find.text('Bạn nhận được'), findsOneWidget);
    expect(find.text(r'$0'), findsNWidgets(2)); // top bar + dialog
    expect(find.text('CHƠI LẠI'), findsOneWidget);
    expect(find.text('MENU'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('đúng hết câu → dialog Chúc mừng + tiền thắng', (tester) async {
    await pumpGameVi(tester);
    await dismissIntroLadder(tester);
    for (final q in gameSampleQuestions) {
      await answerCorrectAndAdvance(tester, q);
    }
    await tester.pump(); // post-frame mở victory dialog
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('CHÚC MỪNG'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('hết giờ → auto flow → Kết thúc', (tester) async {
    await pumpGameVi(tester);
    await dismissIntroLadder(tester);

    await tester.pump(const Duration(seconds: 30)); // timeout
    await tester.pump(const Duration(milliseconds: 2600)); // reveal+expl
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('ĐÃ HIỂU'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('KẾT THÚC'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('tap tiền → thang tiền mở + timer dừng; đóng → timer chạy',
      (tester) async {
    await pumpGameVi(tester);
    await dismissIntroLadder(tester);
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text(r'$0'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('THANG TIỀN THƯỞNG'), findsOneWidget);

    await tester.pump(const Duration(seconds: 10)); // timer paused
    await tester.tap(find.text('ĐÃ HIỂU'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:27'), findsOneWidget); // 28s còn lại → -1
    await unmount(tester);
  });

  testWidgets('✕ → confirm-exit hiện số an toàn; TIẾP TỤC CHƠI đóng lại',
      (tester) async {
    await pumpGameVi(tester);
    await dismissIntroLadder(tester);

    await tester.tap(find.bySemanticsLabel('Thoát trò chơi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('THOÁT TRÒ CHƠI?'), findsOneWidget);
    expect(find.text(r'$0'), findsNWidgets(2)); // guaranteed $0
    await tester.tap(find.text('TIẾP TỤC CHƠI'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('THOÁT TRÒ CHƠI?'), findsNothing);
    expect(find.text(gameSampleQuestions[0].question), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('back hệ thống: confirm-exit đóng; dialog kết thúc bị '
      'BỎ QUA — đúng routing senior', (tester) async {
    await pumpGameVi(tester);
    await dismissIntroLadder(tester);

    // Back khi không có dialog → mở confirm-exit (đúng senior).
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('THOÁT TRÒ CHƠI?'), findsOneWidget);

    // Back trên confirm-exit → đóng dialog (senior dismiss).
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('THOÁT TRÒ CHƠI?'), findsNothing);

    // Sai câu 1 → explanation → Kết thúc → back trên dialog kết thúc
    // cũng bị bỏ qua (bắt buộc chọn nút, kết quả không mất).
    final wrong = gameSampleQuestions[0]
        .options
        .firstWhere((o) => o != gameSampleQuestions[0].correctOption);
    await tester.ensureVisible(answerOption(wrong));
    await tester.tap(answerOption(wrong));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('ĐÃ HIỂU'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('KẾT THÚC'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('KẾT THÚC'), findsOneWidget); // vẫn còn
    await unmount(tester);
  });

  testWidgets('menu → game → THOÁT → về menu, kết quả áp vào profile',
      (tester) async {
    await tester.pumpWidget(await menuApp());
    await tester.pump(const Duration(seconds: 1)); // load profile

    await tester.tap(find.byType(GradientCtaButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(); // post-frame A → startNewGame
    await tester.pump(); // post-frame B — dialog mở bằng dialogState
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('ĐÃ HIỂU'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(gameSampleQuestions[0].question), findsOneWidget);

    // ✕ → THOÁT TRÒ CHƠI → pop trần (VM đã save qua repo).
    await tester.tap(find.bySemanticsLabel('Thoát trò chơi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('THOÁT TRÒ CHƠI'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byType(GradientCtaButton), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('user_profile');
    // Thoát giữa ván: kết quả đã lưu qua repo (M22 VM-side save).
    expect(saved, contains('"gamesJoined":1'));
    expect(saved, contains('"gamesWon":0'));
    await unmount(tester);
  });

  testWidgets('bar lifeline: 3 nút playing; 50:50 xóa 2 ô + nút tắt '
      'sau khi dùng', (tester) async {
    await pumpGameVi(tester);
    await dismissIntroLadder(tester);

    // Ba nút (walkAway ẩn — chưa qua safe haven).
    expect(featureButton(GameFeatureButtonType.fiftyFifty), findsOneWidget);
    expect(featureButton(GameFeatureButtonType.audiencePoll), findsOneWidget);
    expect(featureButton(GameFeatureButtonType.aiAssistant), findsOneWidget);
    expect(featureButton(GameFeatureButtonType.walkAway), findsNothing);

    // Tap 50:50 → 2 ô sai bị xóa (đúng + 1 sai giữ lại).
    final q0 = gameSampleQuestions[0];
    final wrongCount = q0.options.where((o) => o != q0.correctOption).length;
    await tester.tap(find.bySemanticsLabel('50:50'));
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (w) => w is GameAnswerOption && w.data.answerText.isNotEmpty,
      ),
      findsNWidgets(4 - wrongCount + 1),
    );
    // Nút đã dùng → disabled.
    expect(
      tester.widget<GameFeatureButton>(
        featureButton(GameFeatureButtonType.fiftyFifty),
      ).data.isEnabled,
      isFalse,
    );
    await unmount(tester);
  });

  testWidgets('hỏi khán giả → dialog % hàng; ĐÃ HIỂU đóng', (tester) async {
    await pumpGameVi(tester);
    await dismissIntroLadder(tester);

    await tester.tap(find.bySemanticsLabel('Hỏi khán giả'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('HỎI KHÁN GIẢ'), findsOneWidget);
    expect(find.text('68%'), findsWidgets); // easy → đúng 68
    expect(find.byType(LinearProgressIndicator), findsNWidgets(4));

    await tester.tap(find.text('ĐÃ HIỂU'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('HỎI KHÁN GIẢ'), findsNothing);
    await unmount(tester);
  });

  testWidgets('hỏi AI → "đang suy nghĩ" → kết quả đúng + 85% + hint',
      (tester) async {
    await pumpGameVi(tester);
    await dismissIntroLadder(tester);

    await tester.tap(find.bySemanticsLabel('Hỏi AI'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('TRỢ LÝ AI'), findsOneWidget);
    expect(find.text('AI đang suy nghĩ...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800)); // qua 700ms
    await tester.pump();
    expect(find.text('AI đang suy nghĩ...'), findsNothing);
    expect(find.text('85%'), findsOneWidget);

    await tester.tap(find.text('ĐÃ HIỂU'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('TRỢ LÝ AI'), findsNothing);
    await unmount(tester);
  });

  testWidgets('walk-away sau safe haven → confirm → Chúc mừng; '
      'kết quả won=false, save đúng một lần', (tester) async {
    final repo = FakeUserProfileRepository();
    await pumpGameVi(tester, profileRepo: repo);
    await dismissIntroLadder(tester);

    // Qua 5 câu đúng → safe haven $20,000 → nút walkAway hiện.
    for (var i = 0; i < 5; i++) {
      await answerCorrectAndAdvance(tester, gameSampleQuestions[i]);
    }
    expect(featureButton(GameFeatureButtonType.walkAway), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Dừng cuộc chơi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('DỪNG CUỘC CHƠI?'), findsOneWidget);
    // '$20,000' hiện 2 chỗ (money pill + dialog) → scope trong dialog.
    expect(
      find.descendant(
        of: find.byType(GameConfirmWalkAwayDialogView),
        matching: find.text(r'$20,000'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('XÁC NHẬN DỪNG'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('CHÚC MỪNG'), findsOneWidget);
    // Kết quả đọc từ repo — save đúng MỘT lần, walk-away ≠ thắng
    // (senior isWin:false), earned = 20k walk-away.
    await tester.pump();
    expect(repo.saveCallCount, 1);
    expect(repo.value.gamesWon, 0);
    expect(repo.value.totalMoneyWon, 20000);
    await unmount(tester);
  });
}
