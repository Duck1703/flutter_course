import 'package:ai_millionaire_course/data/game/game_sample_questions_data.dart';
import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/data/game/game_session_state_data.dart';
import 'package:ai_millionaire_course/view_models/game/dre/game_dre_contract.dart';
import 'package:ai_millionaire_course/view_models/game/reducer/game_reducer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameReducer', () {
    const timePerQuestion = Duration(seconds: 30);
    late GameReducer reducer;
    late GameState initialState;

    setUp(() {
      reducer = const GameReducer(
        questions: gameSampleQuestions,
        timePerQuestion: timePerQuestion,
      );
      initialState = GameState.initial(timePerQuestion: timePerQuestion);
    });

    test('start game opens intro money ladder and resets timer', () {
      final result = reducer.reduce(initialState, const GameStarted());

      expect(result.state.phase, GamePhase.notStarted);
      expect(result.state.dialogState, isA<GameMoneyLadderDialog>());
      expect(result.state.remainingTime, timePerQuestion);
      expect(
        result.state.visibleOptionTexts,
        gameSampleQuestions.first.options,
      );
      expect(result.effects, hasLength(1));
      expect(result.effects.single, isA<GameStopTimer>());
    });

    test('dismiss intro moves to playing and starts timer', () {
      final result = reducer.reduce(
        _started(reducer, initialState),
        const GameDialogDismissed(),
      );
      expect(result.state.phase, GamePhase.playing);
      expect(result.state.dialogState, isA<GameDialogHidden>());
      expect(result.effects.single, isA<GameStartTimer>());
    });

    test('answer submit outside playing is ignored', () {
      final state = _started(reducer, initialState);

      final result = reducer.reduce(state, const GameAnswerSubmitted('Hanoi'));
      expect(result.state, same(state));
      expect(result.effects, isEmpty);
      expect(result.asyncOp, isNull);
    });

    test('correct answer reveal updates money and schedules explanation', () {
      final submitted = reducer.reduce(
        _playing(reducer, initialState),
        const GameAnswerSubmitted('Hanoi'),
      );

      final result = reducer.reduce(
        submitted.state,
        GameAnswerRevealElapsed(submitted.state.flowToken),
      );
      expect(result.state.phase, GamePhase.answeredRevealed);
      expect(result.state.moneyEarned, 1000);
      expect(result.state.moneyAnimationTrigger, 1);
      expect(result.effects.single, isA<GameScheduleExplanation>());
    });

    test('wrong answer reveal leaves money unchanged', () {
      final submitted = reducer.reduce(
        _playing(reducer, initialState),
        const GameAnswerSubmitted('Ho Chi Minh City'),
      );

      final result = reducer.reduce(
        submitted.state,
        GameAnswerRevealElapsed(submitted.state.flowToken),
      );
      expect(result.state.phase, GamePhase.answeredRevealed);
      expect(result.state.moneyEarned, 0);
      expect(result.state.moneyAnimationTrigger, 0);
    });

    test('correct explanation dismissal advances to next question', () {
      final explained = _explainedAnswer(
        reducer,
        _playing(reducer, initialState),
        'Hanoi',
      );

      final result = reducer.reduce(explained, const GameDialogDismissed());
      expect(result.state.phase, GamePhase.playing);
      expect(result.state.questionIndex, 1);
      expect(result.state.selectedAnswer, isNull);
      expect(result.state.visibleOptionTexts, gameSampleQuestions[1].options);
      expect(result.effects.single, isA<GameStartTimer>());
    });

    test('wrong explanation dismissal emits terminal save async op', () {
      final explained = _explainedAnswer(
        reducer,
        _playing(reducer, initialState),
        'Ho Chi Minh City',
      );

      final result = reducer.reduce(explained, const GameDialogDismissed());

      expect(result.state.phase, GamePhase.gameOver);
      expect(result.state.dialogState, isA<GameEndedDialog>());
      expect(result.effects.single, isA<GameStopTimer>());
      expect(result.asyncOp, isA<GameSaveResult>());
      final save = result.asyncOp! as GameSaveResult;
      expect(save.earnedAmount, 0);
      expect(save.isWin, isFalse);
      expect(save.questionCount, 1);
    });

    test('50:50 blanks two options and disables reuse', () {
      final result = reducer.reduce(
        _playing(reducer, initialState),
        const GameFeatureSelected(GameFeatureButtonType.fiftyFifty),
      );

      expect(
        result.state.visibleOptionTexts.where((it) => it.isEmpty),
        hasLength(2),
      );
      expect(
        result.state.usedFeatureButtons,
        contains(GameFeatureButtonType.fiftyFifty),
      );
      expect(result.effects, isEmpty);
    });

    test('audience and AI actions pause timer and set dialog state', () {
      final audience = reducer.reduce(
        _playing(reducer, initialState),
        const GameFeatureSelected(GameFeatureButtonType.audiencePoll),
      );

      expect(audience.state.dialogState, isA<GameAudiencePollDialog>());
      expect(audience.effects.single, isA<GamePauseTimer>());

      final ai = reducer.reduce(
        _playing(reducer, initialState),
        const GameFeatureSelected(GameFeatureButtonType.aiAssistant),
      );

      expect(ai.state.dialogState, isA<GameAIAssistantDialog>());
      expect(ai.effects.whereType<GamePauseTimer>(), hasLength(1));
      expect(ai.effects.whereType<GameScheduleAIAssistant>(), hasLength(1));
    });

    test('timer tick at zero selects timeout answer and schedules reveal', () {
      final state = _playing(
        reducer,
        initialState,
      ).copyWith(remainingTime: const Duration(seconds: 1));

      final result = reducer.reduce(state, const GameTimerTicked());

      expect(result.state.remainingTime, Duration.zero);
      expect(result.state.phase, GamePhase.answeredPending);
      expect(result.state.selectedAnswer, '');
      expect(result.effects.whereType<GamePauseTimer>(), hasLength(1));
      expect(
        result.effects.whereType<GameScheduleAnswerReveal>(),
        hasLength(1),
      );
    });
  });
}

GameState _started(GameReducer reducer, GameState initialState) {
  return reducer.reduce(initialState, const GameStarted()).state;
}

GameState _playing(GameReducer reducer, GameState initialState) {
  return reducer
      .reduce(_started(reducer, initialState), const GameDialogDismissed())
      .state;
}

GameState _explainedAnswer(
  GameReducer reducer,
  GameState state,
  String answer,
) {
  final submitted = reducer.reduce(state, GameAnswerSubmitted(answer));
  final revealed = reducer.reduce(
    submitted.state,
    GameAnswerRevealElapsed(submitted.state.flowToken),
  );
  return reducer
      .reduce(revealed.state, GameExplanationElapsed(revealed.state.flowToken))
      .state;
}
