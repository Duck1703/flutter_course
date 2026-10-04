import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/data/game/game_session_state_data.dart';
import 'package:ai_millionaire_course/view_models/game/game_screen_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_profile_sync_repository.dart';
import '../../widgets/game_screen_test_helpers.dart';

void main() {
  group('GameScreenViewModel regression coverage', () {
    late FakeGameProfileRepository profileRepository;
    late FakeAuthRepository authRepository;
    late FakeUserProfileSyncRepository syncRepository;
    late GameScreenViewModel viewModel;

    setUp(() {
      profileRepository = FakeGameProfileRepository();
      authRepository = FakeAuthRepository();
      syncRepository = FakeUserProfileSyncRepository();
      viewModel = GameScreenViewModel(
        userProfileRepository: profileRepository,
        authRepository: authRepository,
        profileSyncRepository: syncRepository,
      );
    });

    tearDown(() async {
      viewModel.dispose();
      await profileRepository.dispose();
      await authRepository.dispose();
      await syncRepository.dispose();
    });

    test('submit answer is ignored while intro ladder is visible', () {
      viewModel.startNewGame();

      viewModel.submitAnswer(viewModel.screenData.answers.first);

      expect(viewModel.dialogState, isA<GameMoneyLadderDialog>());
      expect(_answerState(viewModel, 'Hanoi'), GameAnswerState.idle);
      expect(viewModel.screenData.money.amount, r'$0');
      expect(profileRepository.saveCallCount, 0);
    });

    test('stale AI assistant result is ignored after dialog dismiss', () async {
      viewModel.startNewGame();
      viewModel.dismissDialog();

      viewModel.handleFeatureClick(_featureButton(viewModel, 'Ask AI'));
      expect(viewModel.dialogState, isA<GameAIAssistantDialog>());

      viewModel.dismissDialog();
      await Future<void>.delayed(const Duration(milliseconds: 800));

      expect(viewModel.dialogState, isA<GameDialogHidden>());
    });

    test(
      'terminal result is saved once across repeated menu actions',
      () async {
        viewModel.startNewGame();
        viewModel.dismissDialog();

        viewModel.submitAnswer(_answer(viewModel, 'Ho Chi Minh City'));
        await Future<void>.delayed(const Duration(milliseconds: 2600));
        viewModel.dismissDialog();
        await Future<void>.delayed(Duration.zero);

        expect(viewModel.dialogState, isA<GameEndedDialog>());
        expect(profileRepository.saveCallCount, 1);

        viewModel.backToMenu();
        viewModel.backToMenu();
        await Future<void>.delayed(Duration.zero);

        expect(profileRepository.saveCallCount, 1);
      },
    );
  });
}

GameAnswerOptionData _answer(GameScreenViewModel viewModel, String text) {
  return viewModel.screenData.answers.singleWhere(
    (answer) => answer.answerText == text,
  );
}

GameAnswerState _answerState(GameScreenViewModel viewModel, String text) {
  return _answer(viewModel, text).state;
}

GameFeatureButtonData _featureButton(
  GameScreenViewModel viewModel,
  String label,
) {
  return viewModel.screenData.featureButtons.singleWhere(
    (button) => button.semanticLabel == label,
  );
}
