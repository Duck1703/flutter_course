import 'package:ai_millionaire_course/data/game/game_money_ladder_data.dart';
import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/data/game/game_quiz_question_data.dart';
import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/data/game/game_session_state_data.dart';
import 'package:ai_millionaire_course/view_models/game/game_screen_view_model.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_profile_sync_repository.dart';
import 'helpers/fake_user_profile_repository.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit test cho GameScreenViewModel — M19. Toàn bộ luồng thời gian
/// (Timer.periodic + Future.delayed) được lái bằng `FakeAsync`:
/// `async.elapse(d)` nhảy đồng hồ ảo qua `d` mà không chờ thật.
void main() {
  /// Bank mini: câu i có correctOption 'A$i', ba đáp án sai 'W${i}_x'.
  /// Test truyền bank ngắn để đi hết phiên nhanh — contract giống
  /// bank thật (4 options, correctOption ∈ options).
  GameQuizQuestionData makeQuestion(int i) {
    return GameQuizQuestionData(
      id: i,
      question: 'Câu $i?',
      options: ['A$i', 'W${i}_1', 'W${i}_2', 'W${i}_3'],
      correctOption: 'A$i',
      category: 'Test',
      language: 'vi',
      difficulty: GameQuestionDifficulty.easy,
      explanation: const GameQuestionExplanationData(
        explainForTrueAnswer: 'vì đúng',
        explainForWrongAnswers: {},
        aiHintMessage: 'gợi ý',
      ),
    );
  }

  /// Bank n câu (đủ dài để chạm safe haven khi cần).
  List<GameQuizQuestionData> bank(int n) =>
      [for (var i = 0; i < n; i++) makeQuestion(i)];

  /// VM đang chơi: startNewGame → dismiss intro ladder → `playing`.
  /// `repo`: fake để assert persistence M22 — mặc định fake rỗng.
  GameScreenViewModel startedVm(
    FakeAsync async,
    int questionCount, {
    FakeUserProfileRepository? repo,
    FakeAuthRepository? authRepo,
    FakeUserProfileSyncRepository? syncRepo,
  }) {
    final vm = GameScreenViewModel(
      userProfileRepository: repo ?? FakeUserProfileRepository(),
      authRepository: authRepo ?? FakeAuthRepository(),
      profileSyncRepository:
          syncRepo ?? FakeUserProfileSyncRepository(),
      questions: bank(questionCount),
    );
    vm.startNewGame();
    vm.dismissDialog(); // đóng intro ladder → playing + timer chạy
    return vm;
  }

  /// Tap đáp án đúng → để reveal + explanation tới hạn, rồi dismiss.
  void answerCorrectly(GameScreenViewModel vm, FakeAsync async) {
    final option = vm.screenData.answers
        .firstWhere((a) => a.answerText == vm.currentCorrectOption);
    vm.submitAnswer(option);
    async.elapse(const Duration(milliseconds: 1600)); // qua reveal
    async.elapse(const Duration(milliseconds: 1100)); // qua explanation
    expect(vm.dialogState, isA<GameExplanationDialog>());
    vm.dismissDialog();
  }

  group('khởi tạo + intro ladder', () {
    test('state ban đầu: notStarted, ẩn dialog, timer đầy 30s', () {
      final vm = GameScreenViewModel(
        userProfileRepository: FakeUserProfileRepository(),
        authRepository: FakeAuthRepository(),
        profileSyncRepository: FakeUserProfileSyncRepository(),
        questions: bank(3),
      );
      addTearDown(vm.dispose);
      expect(vm.state.phase, GamePhase.notStarted);
      expect(vm.state.remainingTime, const Duration(seconds: 30));
      expect(vm.dialogState, isA<GameDialogHidden>());
    });

    // M21: dialog là STATE, không còn event `GameDialogRequested` —
    // "intro hiện" chứng minh bằng `dialogState`, và `uiEvents` vắng
    // mọi event dialog (senior `GameScreenUiEvent` chỉ có nav/share).
    test('startNewGame → dialog thang tiền intro trong state, '
        'uiEvents không phát event dialog', () {
      FakeAsync().run((async) {
        final vm = GameScreenViewModel(
        userProfileRepository: FakeUserProfileRepository(),
        authRepository: FakeAuthRepository(),
        profileSyncRepository: FakeUserProfileSyncRepository(),
        questions: bank(3),
      );
        addTearDown(vm.dispose);
        final events = <GameScreenUiEvent>[];
        vm.uiEvents.listen(events.add);

        vm.startNewGame();
        async.flushMicrotasks();

        expect(vm.state.phase, GamePhase.notStarted); // chưa playing
        final dialog = vm.dialogState;
        expect(dialog, isA<GameMoneyLadderDialog>());
        // Thang đảo ngược: giải lớn nhất trên cùng.
        expect(
          (dialog as GameMoneyLadderDialog).items.first.index,
          gameMoneyLadderLevels.length,
        );
        expect(events, isEmpty); // M21: không còn GameDialogRequested
      });
    });

    test('dismiss intro ladder → playing và timer bắt đầu tick', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 3);
        addTearDown(vm.dispose);
        expect(vm.state.phase, GamePhase.playing);
        async.elapse(const Duration(seconds: 3));
        expect(vm.state.remainingTime, const Duration(seconds: 27));
      });
    });
  });

  group('submitAnswer → reveal → explanation', () {
    test('đáp án đúng: pending → revealed, moneyEarned lên level',
        () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 3);
        addTearDown(vm.dispose);

        final correct = vm.screenData.answers
            .firstWhere((a) => a.answerText == 'A0');
        vm.submitAnswer(correct);
        expect(vm.state.phase, GamePhase.answeredPending);
        expect(vm.state.selectedAnswer, 'A0');
        // Timer đã dừng — thời gian không còn trôi.
        async.elapse(const Duration(milliseconds: 900));
        expect(vm.state.phase, GamePhase.answeredPending);

        async.elapse(const Duration(milliseconds: 700)); // đủ 1500ms
        expect(vm.state.phase, GamePhase.answeredRevealed);
        expect(
          vm.state.moneyEarned,
          gameMoneyLadderLevels[0].amount, // level 1 = $1,000
        );
        expect(vm.state.moneyAnimationTrigger, 1);

        async.elapse(const Duration(milliseconds: 1100));
        final dialog = vm.dialogState;
        expect(dialog, isA<GameExplanationDialog>());
        expect((dialog as GameExplanationDialog).isCorrect, isTrue);
        expect(dialog.explanation, 'vì đúng');
      });
    });

    test('đáp án sai → explanation isCorrect=false → dismiss → gameOver',
        () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 3);
        addTearDown(vm.dispose);
        final events = <GameScreenUiEvent>[];
        vm.uiEvents.listen(events.add);

        final wrong = vm.screenData.answers
            .firstWhere((a) => a.answerText == 'W0_1');
        vm.submitAnswer(wrong);
        async.elapse(const Duration(milliseconds: 2600));

        final explanation = vm.dialogState as GameExplanationDialog;
        expect(explanation.isCorrect, isFalse);
        // explainForWrongAnswers không có key 'W0_1' → fallback
        // aiHintMessage (đúng semantic senior).
        expect(explanation.explanation, 'gợi ý');

        vm.dismissDialog();
        expect(vm.state.phase, GamePhase.gameOver);
        final ended = vm.dialogState as GameEndedDialog;
        expect(ended.earnedAmount, r'$0'); // chưa qua safe haven nào
      });
    });

    test('submitAnswer bị bỏ qua khi không ở phase playing', () {
      FakeAsync().run((async) {
        final vm = GameScreenViewModel(
        userProfileRepository: FakeUserProfileRepository(),
        authRepository: FakeAuthRepository(),
        profileSyncRepository: FakeUserProfileSyncRepository(),
        questions: bank(3),
      );
        addTearDown(vm.dispose);
        vm.startNewGame(); // vẫn notStarted (intro đang mở)
        final option = vm.screenData.answers.first;
        vm.submitAnswer(option);
        expect(vm.state.phase, GamePhase.notStarted);
        expect(vm.state.selectedAnswer, isNull);
      });
    });

    test('đúng câu giữa → dismiss explanation → câu kế + timer reset',
        () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 3);
        addTearDown(vm.dispose);
        async.elapse(const Duration(seconds: 4)); // câu 1 tốn 4s
        answerCorrectly(vm, async);

        expect(vm.state.phase, GamePhase.playing);
        expect(vm.state.questionIndex, 1);
        expect(vm.state.selectedAnswer, isNull);
        expect(vm.state.remainingTime, const Duration(seconds: 30));
        async.elapse(const Duration(seconds: 2));
        expect(vm.state.remainingTime, const Duration(seconds: 28));
      });
    });
  });

  group('timeout + safe haven + victory', () {
    test('hết 30s → auto pending(selected:"") → reveal sai → gameOver',
        () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 3);
        addTearDown(vm.dispose);
        async.elapse(const Duration(seconds: 30));
        expect(vm.state.phase, GamePhase.answeredPending);
        expect(vm.state.selectedAnswer, '');
        async.elapse(const Duration(milliseconds: 2600));
        vm.dismissDialog();
        expect(vm.state.phase, GamePhase.gameOver);
      });
    });

    test('đúng Q5 (safe haven) → guaranteedAmount = 20k; sai Q6 → '
        'ended vẫn mang về 20k', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 6);
        addTearDown(vm.dispose);
        for (var i = 0; i < 5; i++) {
          answerCorrectly(vm, async);
        }
        expect(
          vm.state.guaranteedAmount,
          20000,
          reason: 'Q5 là mốc an toàn',
        );

        // Sai câu 6 → mất về guaranteed.
        final wrong = vm.screenData.answers
            .firstWhere((a) => a.answerText != vm.currentCorrectOption);
        vm.submitAnswer(wrong);
        async.elapse(const Duration(milliseconds: 2600));
        vm.dismissDialog();

        expect(vm.state.phase, GamePhase.gameOver);
        expect(
          (vm.dialogState as GameEndedDialog).earnedAmount,
          r'$20,000',
        );
        // `moneyEarned` đứng ở level 5 (không bị reset về 0).
        expect(vm.state.moneyEarned, 20000);
      });
    });

    test('đúng câu cuối → victory + dialog mang tiền thắng', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 2);
        addTearDown(vm.dispose);
        answerCorrectly(vm, async); // câu 1 → sang câu 2
        answerCorrectly(vm, async); // câu 2 = cuối → victory

        expect(vm.state.phase, GamePhase.victory);
        final dialog = vm.dialogState as GameVictoryDialog;
        expect(dialog.earnedAmount, r'$2,000'); // level 2 của bank 2 câu
        expect(dialog.affirmationMessage, isNotEmpty);
      });
    });
  });

  group('dialog giữa ván: pause/resume + exit', () {
    test('showMoneyLadder khi playing → dừng timer; dismiss → chạy lại',
        () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 3);
        addTearDown(vm.dispose);
        vm.showMoneyLadder();
        expect(vm.dialogState, isA<GameMoneyLadderDialog>());
        async.elapse(const Duration(seconds: 10));
        expect(
          vm.state.remainingTime,
          const Duration(seconds: 30),
          reason: 'timer tạm dừng khi dialog mở',
        );
        vm.dismissDialog();
        async.elapse(const Duration(seconds: 2));
        expect(vm.state.remainingTime, const Duration(seconds: 28));
      });
    });

    test('showConfirmExit → dialog mang walk-away amount; '
        'backToMenu → navigate event', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 6);
        addTearDown(vm.dispose);
        final events = <GameScreenUiEvent>[];
        vm.uiEvents.listen(events.add);

        // Qua Q5 (safe haven) → guaranteed=20k; senior semantics:
        // walkAway = guar>0 ? max(guar, moneyEarned) : 0 — trước mốc
        // an toàn đầu tiên thoát trắng tay.
        for (var i = 0; i < 5; i++) {
          answerCorrectly(vm, async);
        }
        vm.showConfirmExit();
        async.flushMicrotasks();
        final dialog = vm.dialogState as GameConfirmExitDialog;
        expect(dialog.guaranteedAmount, r'$20,000');

        vm.backToMenu();
        async.flushMicrotasks();
        expect(events, contains(isA<GameNavigateToMenuEvent>()));
      });
    });

    test('confirm-exit khi notStarted bị bỏ qua (guard phase)', () {
      FakeAsync().run((async) {
        final vm = GameScreenViewModel(
        userProfileRepository: FakeUserProfileRepository(),
        authRepository: FakeAuthRepository(),
        profileSyncRepository: FakeUserProfileSyncRepository(),
        questions: bank(3),
      );
        addTearDown(vm.dispose);
        vm.showConfirmExit();
        expect(vm.dialogState, isA<GameDialogHidden>());
      });
    });
  });

  group('flowToken + playAgain + dispose', () {
    test('playAgain giữa reveal → callback cũ bị flowToken vô hiệu', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 3);
        addTearDown(vm.dispose);
        final option = vm.screenData.answers.first;
        vm.submitAnswer(option);
        expect(vm.state.phase, GamePhase.answeredPending);

        vm.playAgain(); // phiên mới — flowToken tăng lên, callback cũ lỗi thời
        expect(vm.state.phase, GamePhase.notStarted);
        expect(vm.dialogState, isA<GameMoneyLadderDialog>());

        // Delay cũ (token 1) đến hạn → phải bị bỏ qua, không reveal
        // vào phiên mới.
        async.elapse(const Duration(seconds: 5));
        expect(vm.state.phase, GamePhase.notStarted);
        expect(vm.state.moneyEarned, 0);
      });
    });

    test('dispose: timer hủy, events đóng, callback trễ không nổ', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 3);
        final option = vm.screenData.answers.first;
        vm.submitAnswer(option);
        vm.dispose();
        // Mọi timer/delay cũ phải im lặng — elapse không ném lỗi.
        async.elapse(const Duration(minutes: 5));
      });
    });
  });

  // ------------------------------------------------------------------
  // M22 — result persistence (FR-01/03/04 converge): save sống trong
  // VM qua `userProfileRepository`, guard `hasSavedResult` chặn lặp;
  // senior `test/widgets/game_screen_result_flow_test.dart` assert
  // `repository.saveCallCount` + `repository.value` — cùng pattern.
  // `_saveGameResult` là `unawaited` → `flushMicrotasks` cho save chạy.
  // ------------------------------------------------------------------
  group('result persistence (M22)', () {
    test('thua câu 2 → save 1 lần: earned=guaranteed(0), isWin=false, '
        'questionCount=2 (số câu đã đến, không phải số câu đúng)', () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository();
        final vm = startedVm(async, 3, repo: repo);
        addTearDown(vm.dispose);
        answerCorrectly(vm, async);
        final wrong = vm.screenData.answers
            .firstWhere((a) => a.answerText != vm.currentCorrectOption);
        vm.submitAnswer(wrong);
        async.elapse(const Duration(milliseconds: 2600));
        vm.dismissDialog(); // → gameOver → save
        async.flushMicrotasks();

        expect(vm.state.hasSavedResult, isTrue);
        expect(repo.saveCallCount, 1);
        expect(repo.value.gamesJoined, 1);
        expect(repo.value.gamesWon, 0);
        expect(repo.value.totalMoneyWon, 0); // guaranteed=0 trước safe haven
        expect(repo.value.totalEarnings, '0 VNĐ');
        expect(repo.value.totalQuestionCount, 2);
        expect(repo.value.currentExp, 0); // EXP = earnedAmount = 0
      });
    });

    test('thoát giữa ván sau safe haven → backToMenu save '
        'walkAway amount + stats; gọi lại → vẫn 1 lần', () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository();
        final vm = startedVm(async, 6, repo: repo);
        addTearDown(vm.dispose);
        for (var i = 0; i < 5; i++) {
          answerCorrectly(vm, async);
        }
        // Đang câu 6: walkAway = max(guaranteed, earned) = 20k.
        vm.backToMenu();
        async.flushMicrotasks();

        expect(repo.saveCallCount, 1);
        expect(repo.value.totalMoneyWon, 20000);
        expect(repo.value.gamesJoined, 1);
        expect(repo.value.gamesWon, 0); // walk-away ≠ thắng (isWin:false)
        expect(repo.value.totalQuestionCount, 6); // questionIndex 5 + 1
        expect(repo.value.totalEarnings, '20.000 VNĐ');
        expect(repo.value.currentExp, 20000); // EXP = earnedAmount

        // Idempotence: backToMenu lần 2 (vd double-tap ✕) không save.
        vm.backToMenu();
        async.flushMicrotasks();
        expect(repo.saveCallCount, 1);
      });
    });

    test('victory câu cuối → save moneyEarned + isWin=true '
        '(gamesWon +1)', () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository();
        final vm = startedVm(async, 2, repo: repo);
        addTearDown(vm.dispose);
        answerCorrectly(vm, async); // câu 1 → sang câu 2
        answerCorrectly(vm, async); // câu 2 = cuối → victory → save
        async.flushMicrotasks();

        expect(vm.state.phase, GamePhase.victory);
        expect(repo.saveCallCount, 1);
        expect(repo.value.gamesJoined, 1);
        expect(repo.value.gamesWon, 1);
        expect(repo.value.totalMoneyWon, 2000); // level 2 của bank
        expect(repo.value.totalQuestionCount, 2);
        expect(repo.value.currentExp, 2000);
      });
    });

    test('confirmWalkAway → save walkAway amount, isWin=false', () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository();
        final vm = startedVm(async, 6, repo: repo);
        addTearDown(vm.dispose);
        for (var i = 0; i < 5; i++) {
          answerCorrectly(vm, async);
        }
        vm.handleFeatureClick(
          vm.screenData.featureButtons.firstWhere(
            (b) => b.type == GameFeatureButtonType.walkAway,
          ),
        );
        vm.confirmWalkAway();
        async.flushMicrotasks();

        expect(vm.state.phase, GamePhase.victory);
        expect(repo.saveCallCount, 1);
        expect(repo.value.totalMoneyWon, 20000);
        expect(repo.value.gamesWon, 0);
        expect(repo.value.totalQuestionCount, 6);
      });
    });

    test('gameOver rồi backToMenu → hasSavedResult chặn save lần 2', () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository();
        final vm = startedVm(async, 3, repo: repo);
        addTearDown(vm.dispose);
        final wrong = vm.screenData.answers
            .firstWhere((a) => a.answerText != vm.currentCorrectOption);
        vm.submitAnswer(wrong);
        async.elapse(const Duration(milliseconds: 2600));
        vm.dismissDialog(); // gameOver → save #1
        async.flushMicrotasks();
        expect(repo.saveCallCount, 1);

        vm.backToMenu(); // terminal action sau gameOver
        async.flushMicrotasks();
        expect(repo.saveCallCount, 1);
      });
    });

    test('playAgain → phiên mới reset hasSavedResult → save lại được',
        () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository();
        final vm = startedVm(async, 3, repo: repo);
        addTearDown(vm.dispose);
        vm.backToMenu(); // phiên 1: save #1 (0 câu → earned 0)
        async.flushMicrotasks();
        expect(repo.saveCallCount, 1);

        vm.playAgain(); // initial → hasSavedResult=false
        expect(vm.state.hasSavedResult, isFalse);
        vm.dismissDialog(); // qua intro
        vm.backToMenu(); // phiên 2: save #2
        async.flushMicrotasks();
        expect(repo.saveCallCount, 2);
        expect(repo.value.gamesJoined, 2); // cộng dồn trên profile cũ
      });
    });

    test('EXP = earnedAmount: tràn ngưỡng LevelConfig → lên cấp, '
        'giữ EXP dư (senior _applyLevelProgression)', () {
      FakeAsync().run((async) {
        // Seed exp 34000 (ngưỡng L1→L2 = 35000): victory bank(2)
        // earned 2000 → 36000 → cấp 2 dư 1000.
        final repo = FakeUserProfileRepository(
          initialProfile: const UserProfileData(currentExp: 34000),
        );
        final vm = startedVm(async, 2, repo: repo);
        addTearDown(vm.dispose);
        answerCorrectly(vm, async);
        answerCorrectly(vm, async);
        async.flushMicrotasks();

        expect(repo.value.level, 2);
        expect(repo.value.currentExp, 1000);
      });
    });

    test('level trần 100: save vẫn cộng EXP, không vượt maxLevel', () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository(
          initialProfile: const UserProfileData(
            level: 100,
            currentExp: 5,
          ),
        );
        final vm = startedVm(async, 6, repo: repo);
        addTearDown(vm.dispose);
        for (var i = 0; i < 5; i++) {
          answerCorrectly(vm, async);
        }
        vm.backToMenu();
        async.flushMicrotasks();

        expect(repo.value.level, 100);
        expect(repo.value.currentExp, 20005);
      });
    });
  });
  // ------------------------------------------------------------------
  // M20 — lifelines (senior game_reducer_feature_flow.dart)
  // ------------------------------------------------------------------

  /// Tìm button data theo type trong `screenData.featureButtons`.
  GameFeatureButtonData feature(
    GameScreenViewModel vm,
    GameFeatureButtonType type,
  ) => vm.screenData.featureButtons.firstWhere((b) => b.type == type);

  group('lifelines — khả dụng + single-use', () {
    test('playing: 3 nút trong bar (walkAway ẩn khi guaranteed=0); '
        'không playing → không nút nào dùng được', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 6);
        addTearDown(vm.dispose);
        expect(
          vm.screenData.featureButtons.map((b) => b.type),
          [
            GameFeatureButtonType.fiftyFifty,
            GameFeatureButtonType.audiencePoll,
            GameFeatureButtonType.aiAssistant,
          ],
        );
        // handleFeatureClick trên nút disabled → no-op.
        vm.submitAnswer(vm.screenData.answers.first);
        vm.handleFeatureClick(
          feature(vm, GameFeatureButtonType.fiftyFifty),
        );
        expect(vm.state.usedFeatureButtons, isEmpty);
      });
    });

    test('feature ở mọi phase khác playing bị _canUseFeature chặn', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 6);
        addTearDown(vm.dispose);
        // answeredPending → mọi feature bị chặn (kể cả exitGame theo
        // senior: `phase != playing → false` kiểm trước).
        vm.submitAnswer(vm.screenData.answers.first);
        for (final type in GameFeatureButtonType.values) {
          vm.handleFeatureClick(
            GameFeatureButtonData(
              type: type,
              iconAsset: 'test/icon.svg',
              semanticLabel: 'x',
            ),
          );
        }
        expect(vm.state.usedFeatureButtons, isEmpty);
        expect(vm.dialogState, isA<GameDialogHidden>());
      });
    });
  });

  group('50:50', () {
    test('xóa 2 ô sai (giữ đúng + sai-đầu), single-use, ô trống '
        'không submit được', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 6);
        addTearDown(vm.dispose);

        vm.handleFeatureClick(feature(vm, GameFeatureButtonType.fiftyFifty));

        expect(vm.state.visibleOptionTexts, ['A0', 'W0_1', '', '']);
        expect(
          vm.state.usedFeatureButtons,
          contains(GameFeatureButtonType.fiftyFifty),
        );
        // Button giờ disabled trong screenData.
        expect(
          feature(vm, GameFeatureButtonType.fiftyFifty).isEnabled,
          isFalse,
        );
        // Bấm lại → no-op.
        vm.handleFeatureClick(feature(vm, GameFeatureButtonType.fiftyFifty));
        expect(vm.state.visibleOptionTexts, ['A0', 'W0_1', '', '']);

        // Ô rỗng không submit được (guard `answerText.isEmpty` — đúng
        // senior `_submitAnswer`).
        vm.submitAnswer(
          const GameAnswerOptionData(answerLabel: 'C', answerText: ''),
        );
        expect(vm.state.phase, GamePhase.playing);
      });
    });

    test('sang câu mới: visibleOptionTexts reset về options đầy đủ', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 6);
        addTearDown(vm.dispose);
        vm.handleFeatureClick(feature(vm, GameFeatureButtonType.fiftyFifty));
        answerCorrectly(vm, async);
        expect(vm.state.visibleOptionTexts, ['A1', 'W1_1', 'W1_2', 'W1_3']);
        // usedFeatureButtons KHÔNG reset — senior giữ nguyên ván.
        expect(
          vm.state.usedFeatureButtons,
          contains(GameFeatureButtonType.fiftyFifty),
        );
      });
    });
  });

  group('hỏi khán giả', () {
    test('mở dialog + percentiles theo độ khó + timer pause + '
        'single-use; dismiss → timer chạy lại', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 6);
        addTearDown(vm.dispose);

        vm.handleFeatureClick(
          feature(vm, GameFeatureButtonType.audiencePoll),
        );
        final dialog = vm.dialogState;
        expect(dialog, isA<GameAudiencePollDialog>());
        final items = (dialog as GameAudiencePollDialog).items;
        expect(items.length, 4);
        // easy → đúng 68%.
        expect(
          items.firstWhere((i) => i.option == 'A').percentage,
          '68%',
        );
        expect(vm.state.audiencePercentiles?['A0'], 68);
        expect(
          vm.state.usedFeatureButtons,
          contains(GameFeatureButtonType.audiencePoll),
        );

        // Timer đang pause — elapse không trừ remainingTime.
        async.elapse(const Duration(seconds: 5));
        expect(vm.state.remainingTime, const Duration(seconds: 30));

        vm.dismissDialog();
        expect(vm.dialogState, isA<GameDialogHidden>());
        async.elapse(const Duration(seconds: 1));
        expect(vm.state.remainingTime, const Duration(seconds: 29));

        // Percentile tồn trên ô đáp án cho tới khi sang câu.
        expect(vm.screenData.answers[0].audiencePercentile, 68);
      });
    });

    test('sang câu mới: percentiles xóa về null', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 6);
        addTearDown(vm.dispose);
        vm.handleFeatureClick(
          feature(vm, GameFeatureButtonType.audiencePoll),
        );
        vm.dismissDialog();
        answerCorrectly(vm, async);
        expect(vm.state.audiencePercentiles, isNull);
      });
    });
  });

  group('hỏi AI (mô phỏng)', () {
    test('loading 700ms → dialog đổi sang kết quả: correctOption + '
        '85% + aiHintMessage; timer pause', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 6);
        addTearDown(vm.dispose);

        vm.handleFeatureClick(
          feature(vm, GameFeatureButtonType.aiAssistant),
        );
        var dialog = vm.dialogState as GameAIAssistantDialog;
        expect(dialog.isLoading, isTrue);
        expect(
          vm.state.usedFeatureButtons,
          contains(GameFeatureButtonType.aiAssistant),
        );

        async.elapse(const Duration(milliseconds: 700));
        dialog = vm.dialogState as GameAIAssistantDialog;
        expect(dialog.isLoading, isFalse);
        expect(dialog.selectedAnswer, 'A0');
        expect(dialog.confidencePercentage, 85);
        expect(dialog.explanation, 'gợi ý');

        // Dismiss → timer chạy lại.
        vm.dismissDialog();
        async.elapse(const Duration(seconds: 1));
        expect(vm.state.remainingTime, const Duration(seconds: 29));
      });
    });

    test('đóng giữa lúc loading → kết quả trễ bị bỏ qua (dialog '
        'không còn là AI) — guard đúng senior', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 6);
        addTearDown(vm.dispose);
        vm.handleFeatureClick(
          feature(vm, GameFeatureButtonType.aiAssistant),
        );
        vm.dismissDialog(); // đóng trong 700ms loading
        async.elapse(const Duration(seconds: 1));
        expect(vm.dialogState, isA<GameDialogHidden>()); // không mở lại
      });
    });
  });

  group('walk-away + thoát', () {
    test('walk-away trước safe haven: nút ẩn + _canUseFeature chặn; '
        'sau Q5: mở dialog → xác nhận → victory + result won=false', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 6);
        addTearDown(vm.dispose);

        // guaranteed=0 → bar không có nút walkAway (mapper); guard
        // state-level vẫn chặn nếu bấm tay.
        expect(
          vm.screenData.featureButtons
              .map((b) => b.type)
              .contains(GameFeatureButtonType.walkAway),
          isFalse,
        );
        vm.handleFeatureClick(
          const GameFeatureButtonData(
            type: GameFeatureButtonType.walkAway,
            iconAsset: 'test/icon.svg',
            semanticLabel: 'x',
          ),
        );
        expect(vm.dialogState, isA<GameDialogHidden>());

        // Qua safe haven Q5 (guaranteed=20k) → nút hiện.
        for (var i = 0; i < 5; i++) {
          answerCorrectly(vm, async);
        }
        final walkBtn = feature(vm, GameFeatureButtonType.walkAway);
        expect(walkBtn.isEnabled, isTrue);

        vm.handleFeatureClick(walkBtn);
        expect(vm.dialogState, isA<GameConfirmWalkAwayDialog>());
        expect(
          (vm.dialogState as GameConfirmWalkAwayDialog).currentAmount,
          r'$20,000',
        );
        // Timer pause trong dialog.
        async.elapse(const Duration(seconds: 3));
        expect(vm.state.remainingTime, const Duration(seconds: 30));

        vm.confirmWalkAway();
        expect(vm.state.phase, GamePhase.victory);
        expect(vm.state.remainingTime, Duration.zero);
        expect(vm.dialogState, isA<GameVictoryDialog>());
        expect(
          (vm.dialogState as GameVictoryDialog).earnedAmount,
          r'$20,000',
        );
      });
    });

    test('walk-away KHÔNG bị đánh dấu usedFeatureButtons (senior: '
        'chỉ 3 lifeline ghi used)', () {
      FakeAsync().run((async) {
        final vm = startedVm(async, 6);
        addTearDown(vm.dispose);
        for (var i = 0; i < 5; i++) {
          answerCorrectly(vm, async);
        }
        vm.handleFeatureClick(feature(vm, GameFeatureButtonType.walkAway));
        expect(vm.state.usedFeatureButtons, isEmpty);
      });
    });
  });
  // ------------------------------------------------------------------
  // M25 (FR-36 converge) — result → remote sync: `_syncSavedGameResult`
  // đọc auth session sau save local; senior assert cùng điều này qua
  // `syncRepository.syncCallCount` trong
  // `test/widgets/game_screen_result_flow_test.dart` — ở đây ở tầng VM.
  // ------------------------------------------------------------------
  group('result profile sync (M25, FR-36)', () {
    test('authenticated → save xong gọi syncUserProfile đúng session',
        () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository();
        final auth = FakeAuthRepository(
          initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
        );
        final sync = FakeUserProfileSyncRepository();
        final vm = startedVm(
          async,
          3,
          repo: repo,
          authRepo: auth,
          syncRepo: sync,
        );
        addTearDown(vm.dispose);
        addTearDown(auth.dispose);
        addTearDown(sync.dispose);

        vm.backToMenu(); // save → sync
        async.flushMicrotasks();

        expect(repo.saveCallCount, 1);
        expect(sync.syncCallCount, 1);
        expect(sync.lastSyncedSession?.uid, 'user-1');
      });
    });

    test('guest → save local vẫn chạy, sync bị skip (session=guest)',
        () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository();
        final sync = FakeUserProfileSyncRepository();
        final vm = startedVm(
          async,
          3,
          repo: repo,
          syncRepo: sync,
        ); // authRepo mặc định = guest
        addTearDown(vm.dispose);
        addTearDown(sync.dispose);

        vm.backToMenu();
        async.flushMicrotasks();

        expect(repo.saveCallCount, 1);
        expect(sync.syncCallCount, 0);
      });
    });

    test('sync throw → nuốt lỗi + log; save local vẫn thành công '
        '(retry ở lần sync sau — senior cũng catch+print)', () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository();
        final auth = FakeAuthRepository(
          initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
        );
        final sync = FakeUserProfileSyncRepository()
          ..syncError = StateError('network down');
        final vm = startedVm(
          async,
          3,
          repo: repo,
          authRepo: auth,
          syncRepo: sync,
        );
        addTearDown(vm.dispose);
        addTearDown(auth.dispose);
        addTearDown(sync.dispose);

        vm.backToMenu();
        async.flushMicrotasks(); // không throw — catch trong VM

        expect(repo.saveCallCount, 1); // local save đã xong
        expect(sync.syncCallCount, 1); // sync ĐÃ được gọi rồi fail
      });
    });
  });

}

/// Lookup nhỏ cho test — đáp án đúng của câu hiện tại.
extension on GameScreenViewModel {
  String get currentCorrectOption => questions[state.questionIndex].correctOption;
}
