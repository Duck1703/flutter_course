part of '../game_screen_view_model.dart';

extension _GameScreenViewModelEffects on GameScreenViewModel {
  void _handleEffect(GameEffect effect) {
    switch (effect) {
      case GameStartTimer():
        _startTimer();
      case GamePauseTimer():
        _pauseTimer();
      case GameStopTimer():
        _stopTimer();
      case GameScheduleAnswerReveal(:final flowToken):
        _scheduleAnswerReveal(flowToken);
      case GameScheduleExplanation(:final flowToken):
        _scheduleExplanation(flowToken);
      case GameScheduleAIAssistant(:final flowToken):
        _scheduleAIAssistant(flowToken);
      case GameNavigateToMenu():
        _events.add(const GameNavigateToMenuEvent());
      // M27 — senior `game_screen_view_model_effects.dart`: effect
      // share → uiEvent cho screen (`SharePlus` + clipboard fallback).
      case GameShareResult(:final text):
        _events.add(GameShareResultEvent(text));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _dispatchGameAction(const GameTimerTicked());
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _scheduleAnswerReveal(int flowToken) {
    Future<void>.delayed(GameScreenViewModel._answerRevealDelay, () {
      if (!_isDisposed) {
        _dispatchGameAction(GameAnswerRevealElapsed(flowToken));
      }
    });
  }

  void _scheduleExplanation(int flowToken) {
    Future<void>.delayed(GameScreenViewModel._explanationDelay, () {
      if (!_isDisposed) {
        _dispatchGameAction(GameExplanationElapsed(flowToken));
      }
    });
  }

  void _scheduleAIAssistant(int flowToken) {
    Future<void>.delayed(GameScreenViewModel._aiAssistantDelay, () {
      if (!_isDisposed) {
        _dispatchGameAction(GameAIAssistantElapsed(flowToken));
      }
    });
  }
}
