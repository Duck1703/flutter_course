part of 'game_reducer.dart';

extension _GameReducerSessionFlow on GameReducer {
  DreResult<GameState, GameEffect, GameAsyncOp> _startGame(GameState state) {
    return _result(
      GameState.initial(timePerQuestion: timePerQuestion).copyWith(
        visibleOptionTexts: questions.first.options,
        dialogState: GameMoneyLadderDialog(items: _moneyLadderItems(0)),
        flowToken: state.flowToken + 1,
      ),
      effects: const [GameStopTimer()],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _dismissDialog(
    GameState state,
  ) {
    final dialog = state.dialogState;

    if (dialog is GameMoneyLadderDialog &&
        state.phase == GamePhase.notStarted) {
      return _result(
        state.copyWith(
          phase: GamePhase.playing,
          dialogState: const GameDialogHidden(),
        ),
        effects: const [GameStartTimer()],
      );
    }

    if (dialog is GameExplanationDialog) {
      return dialog.isCorrect
          ? _loadNextQuestionOrVictory(state)
          : _endGame(state);
    }

    final nextState = state.copyWith(dialogState: const GameDialogHidden());
    return _result(
      nextState,
      effects: state.phase == GamePhase.playing
          ? const [GameStartTimer()]
          : const [],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _loadNextQuestionOrVictory(
    GameState state,
  ) {
    if (state.questionIndex >= questions.length - 1) {
      final nextState = state.copyWith(
        phase: GamePhase.victory,
        remainingTime: Duration.zero,
        dialogState: GameVictoryDialog(
          earnedAmount: formatGameMoney(state.moneyEarned),
          affirmationMessage:
              'Your knowledge is your superpower! Keep learning and growing!',
        ),
      );
      return _withSaveResult(
        nextState,
        earnedAmount: state.moneyEarned,
        isWin: true,
        effects: const [GameStopTimer()],
      );
    }

    return _result(
      state.copyWith(
        phase: GamePhase.playing,
        questionIndex: state.questionIndex + 1,
        clearSelectedAnswer: true,
        clearAudiencePercentiles: true,
        visibleOptionTexts: questions[state.questionIndex + 1].options,
        remainingTime: timePerQuestion,
        dialogState: const GameDialogHidden(),
      ),
      effects: const [GameStartTimer()],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _endGame(GameState state) {
    final nextState = state.copyWith(
      phase: GamePhase.gameOver,
      remainingTime: Duration.zero,
      dialogState: GameEndedDialog(
        earnedAmount: formatGameMoney(state.guaranteedAmount),
      ),
    );
    return _withSaveResult(
      nextState,
      earnedAmount: state.guaranteedAmount,
      isWin: false,
      effects: const [GameStopTimer()],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _confirmWalkAway(
    GameState state,
  ) {
    final amount = _walkAwayAmount(state);
    final nextState = state.copyWith(
      phase: GamePhase.victory,
      remainingTime: Duration.zero,
      dialogState: GameVictoryDialog(
        earnedAmount: formatGameMoney(amount),
        affirmationMessage:
            'Your knowledge is your superpower! Keep learning and growing!',
      ),
    );
    return _withSaveResult(
      nextState,
      earnedAmount: amount,
      isWin: false,
      effects: const [GameStopTimer()],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _backToMenu(GameState state) {
    final nextState = state.copyWith(remainingTime: Duration.zero);
    return _withSaveResult(
      nextState,
      earnedAmount: _walkAwayAmount(state),
      isWin: false,
      effects: const [GameStopTimer(), GameNavigateToMenu()],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _withSaveResult(
    GameState state, {
    required int earnedAmount,
    required bool isWin,
    required List<GameEffect> effects,
  }) {
    if (state.hasSavedResult) {
      return _result(state, effects: effects);
    }

    return _result(
      state.copyWith(hasSavedResult: true),
      effects: effects,
      asyncOp: GameSaveResult(
        earnedAmount: earnedAmount,
        isWin: isWin,
        questionCount: state.questionIndex + 1,
      ),
    );
  }
}
