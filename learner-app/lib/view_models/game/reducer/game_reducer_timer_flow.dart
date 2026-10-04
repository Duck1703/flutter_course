part of 'game_reducer.dart';

extension _GameReducerTimerFlow on GameReducer {
  DreResult<GameState, GameEffect, GameAsyncOp> _tickTimer(GameState state) {
    if (state.phase != GamePhase.playing) {
      return _result(state);
    }

    final nextTime = state.remainingTime - const Duration(seconds: 1);
    final remainingTime = nextTime.isNegative ? Duration.zero : nextTime;

    if (remainingTime > Duration.zero) {
      return _result(state.copyWith(remainingTime: remainingTime));
    }

    final token = state.flowToken + 1;
    return _result(
      state.copyWith(
        phase: GamePhase.answeredPending,
        selectedAnswer: '',
        remainingTime: Duration.zero,
        flowToken: token,
      ),
      effects: [const GamePauseTimer(), GameScheduleAnswerReveal(token)],
    );
  }
}
