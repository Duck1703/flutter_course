part of 'game_reducer.dart';

extension _GameReducerFeatureFlow on GameReducer {
  DreResult<GameState, GameEffect, GameAsyncOp> _selectFeature(
    GameState state,
    GameFeatureButtonType type,
  ) {
    if (!_canUseFeature(state, type)) {
      return _result(state);
    }

    return switch (type) {
      GameFeatureButtonType.fiftyFifty => _useFiftyFifty(state),
      GameFeatureButtonType.audiencePoll => _showAudiencePoll(state),
      GameFeatureButtonType.aiAssistant => _showAIAssistant(state),
      GameFeatureButtonType.walkAway => _showConfirmWalkAway(state),
      GameFeatureButtonType.exitGame => _showConfirmExit(state),
    };
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _useFiftyFifty(
    GameState state,
  ) {
    return _result(
      state.copyWith(
        visibleOptionTexts: applyGameFiftyFifty(questions[state.questionIndex]),
        usedFeatureButtons: {
          ...state.usedFeatureButtons,
          GameFeatureButtonType.fiftyFifty,
        },
      ),
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _showAudiencePoll(
    GameState state,
  ) {
    final percentiles = buildGameAudiencePoll(questions[state.questionIndex]);
    return _result(
      state.copyWith(
        audiencePercentiles: percentiles,
        usedFeatureButtons: {
          ...state.usedFeatureButtons,
          GameFeatureButtonType.audiencePoll,
        },
        dialogState: GameAudiencePollDialog(
          items: _audiencePollItems(state, percentiles),
        ),
      ),
      effects: const [GamePauseTimer()],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _showAIAssistant(
    GameState state,
  ) {
    final token = state.flowToken + 1;
    return _result(
      state.copyWith(
        flowToken: token,
        usedFeatureButtons: {
          ...state.usedFeatureButtons,
          GameFeatureButtonType.aiAssistant,
        },
        dialogState: const GameAIAssistantDialog(
          selectedAnswer: '',
          confidencePercentage: 0,
          explanation: '',
          isLoading: true,
        ),
      ),
      effects: [const GamePauseTimer(), GameScheduleAIAssistant(token)],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _showMoneyLadder(
    GameState state,
  ) {
    if (state.phase != GamePhase.playing) {
      return _result(state);
    }

    return _result(
      state.copyWith(
        dialogState: GameMoneyLadderDialog(
          items: _moneyLadderItems(state.questionIndex),
        ),
      ),
      effects: const [GamePauseTimer()],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _showConfirmExit(
    GameState state,
  ) {
    if (state.phase != GamePhase.playing) {
      return _result(state);
    }

    return _result(
      state.copyWith(
        dialogState: GameConfirmExitDialog(
          guaranteedAmount: formatGameMoney(_walkAwayAmount(state)),
        ),
      ),
      effects: const [GamePauseTimer()],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _showConfirmWalkAway(
    GameState state,
  ) {
    final amount = _walkAwayAmount(state);
    if (state.phase != GamePhase.playing || amount <= 0) {
      return _result(state);
    }

    return _result(
      state.copyWith(
        dialogState: GameConfirmWalkAwayDialog(
          currentAmount: formatGameMoney(amount),
        ),
      ),
      effects: const [GamePauseTimer()],
    );
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _showAIAssistantResult(
    GameState state,
    int flowToken,
  ) {
    if (flowToken != state.flowToken ||
        state.dialogState is! GameAIAssistantDialog) {
      return _result(state);
    }

    final question = questions[state.questionIndex];
    return _result(
      state.copyWith(
        dialogState: GameAIAssistantDialog(
          selectedAnswer: question.correctOption,
          confidencePercentage: 85,
          explanation: question.explanation.aiHintMessage,
        ),
      ),
    );
  }

  bool _canUseFeature(GameState state, GameFeatureButtonType type) {
    if (state.phase != GamePhase.playing) {
      return false;
    }
    if (type == GameFeatureButtonType.walkAway) {
      return _walkAwayAmount(state) > 0;
    }
    if (type == GameFeatureButtonType.exitGame) {
      return true;
    }
    return !state.usedFeatureButtons.contains(type);
  }
}
