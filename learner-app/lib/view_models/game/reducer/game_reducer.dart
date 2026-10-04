import '../../../core/dre/dre.dart';
import '../../../data/game/game_money_ladder_data.dart';
import '../../../data/game/game_quiz_question_data.dart';
import '../../../data/game/game_screen_data.dart';
import '../../../data/game/game_session_state_data.dart';
import '../dre/game_dre_contract.dart';
import '../support/game_lifeline_helper.dart';
import '../support/game_money_formatter.dart';
import '../support/game_money_ladder_mapper.dart';

part 'game_reducer_answer_flow.dart';
part 'game_reducer_feature_flow.dart';
part 'game_reducer_session_flow.dart';
part 'game_reducer_timer_flow.dart';

class GameReducer
    implements DreReducer<GameState, GameAction, GameEffect, GameAsyncOp> {
  final List<GameQuizQuestionData> questions;
  final Duration timePerQuestion;

  const GameReducer({required this.questions, required this.timePerQuestion});

  @override
  DreResult<GameState, GameEffect, GameAsyncOp> reduce(
    GameState state,
    GameAction action,
  ) {
    return switch (action) {
      GameStarted() => _startGame(state),
      GameDialogDismissed() => _dismissDialog(state),
      GameAnswerSubmitted(:final answerText) => _submitAnswer(
        state,
        answerText,
      ),
      GameAnswerRevealElapsed(:final flowToken) => _revealAnswer(
        state,
        flowToken,
      ),
      GameExplanationElapsed(:final flowToken) => _showExplanation(
        state,
        flowToken,
      ),
      GameFeatureSelected(:final type) => _selectFeature(state, type),
      GameMoneyLadderRequested() => _showMoneyLadder(state),
      GameConfirmExitRequested() => _showConfirmExit(state),
      GameConfirmWalkAwayRequested() => _showConfirmWalkAway(state),
      GameWalkAwayConfirmed() => _confirmWalkAway(state),
      GameTimerTicked() => _tickTimer(state),
      GameAIAssistantElapsed(:final flowToken) => _showAIAssistantResult(
        state,
        flowToken,
      ),
      GameBackToMenuRequested() => _backToMenu(state),
      // M27 — senior verbatim: share không đổi state, chỉ phát effect.
      GameShareRequested(:final text) => _result(
        state,
        effects: [GameShareResult(text)],
      ),
    };
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _result(
    GameState state, {
    List<GameEffect> effects = const [],
    GameAsyncOp? asyncOp,
  }) {
    return DreResult(state: state, effects: effects, asyncOp: asyncOp);
  }

  int _walkAwayAmount(GameState state) {
    return calculateGameWalkAwayAmount(
      guaranteedAmount: state.guaranteedAmount,
      moneyEarned: state.moneyEarned,
    );
  }

  List<GameMoneyLadderItemData> _moneyLadderItems(int questionIndex) {
    return buildGameMoneyLadderItems(currentQuestionIndex: questionIndex);
  }

  List<GameAudiencePollItemData> _audiencePollItems(
    GameState state,
    Map<String, int> percentiles,
  ) {
    return List.generate(state.visibleOptionTexts.length, (index) {
      final option = state.visibleOptionTexts[index];
      final value = option.isEmpty ? 0 : percentiles[option] ?? 0;
      return GameAudiencePollItemData(
        option: String.fromCharCode(65 + index),
        percentage: '$value%',
        progress: value / 100,
      );
    }, growable: false);
  }
}
