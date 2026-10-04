part of 'game_reducer.dart';

extension _GameReducerAnswerFlow on GameReducer {
  DreResult<GameState, GameEffect, GameAsyncOp> _submitAnswer(
    GameState state,
    String answerText,
  ) {
    if (state.phase != GamePhase.playing || answerText.isEmpty) {
      return _result(state);
    }

    final token = state.flowToken + 1;
    return _result(
      state.copyWith(
        phase: GamePhase.answeredPending,
        selectedAnswer: answerText,
        flowToken: token,
      ),
      effects: [const GamePauseTimer(), GameScheduleAnswerReveal(token)],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _revealAnswer(
    GameState state,
    int flowToken,
  ) {
    if (flowToken != state.flowToken ||
        state.phase != GamePhase.answeredPending) {
      return _result(state);
    }

    final question = questions[state.questionIndex];
    final isCorrect = state.selectedAnswer == question.correctOption;
    var moneyEarned = state.moneyEarned;
    var guaranteedAmount = state.guaranteedAmount;
    var moneyAnimationTrigger = state.moneyAnimationTrigger;

    if (isCorrect) {
      final level = gameMoneyLadderLevels[state.questionIndex];
      if (level.amount != moneyEarned) {
        moneyAnimationTrigger++;
      }
      moneyEarned = level.amount;
      if (level.isSafeHaven) {
        guaranteedAmount = level.amount;
      }
    }

    return _result(
      state.copyWith(
        phase: GamePhase.answeredRevealed,
        moneyEarned: moneyEarned,
        guaranteedAmount: guaranteedAmount,
        moneyAnimationTrigger: moneyAnimationTrigger,
      ),
      effects: [GameScheduleExplanation(flowToken)],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _showExplanation(
    GameState state,
    int flowToken,
  ) {
    if (flowToken != state.flowToken ||
        state.phase != GamePhase.answeredRevealed) {
      return _result(state);
    }

    final question = questions[state.questionIndex];
    final isCorrect = state.selectedAnswer == question.correctOption;
    return _result(
      state.copyWith(
        dialogState: GameExplanationDialog(
          question: question.question,
          correctAnswer: question.correctOption,
          explanation: isCorrect
              ? question.explanation.explainForTrueAnswer
              : question.explanation.explainForWrongAnswers[state
                        .selectedAnswer] ??
                    question.explanation.aiHintMessage,
          isCorrect: isCorrect,
        ),
      ),
    );
  }
}
