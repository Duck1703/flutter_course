import '../../../core/dre/dre.dart';
import '../../../data/game/game_screen_data.dart';

sealed class GameAction implements DreAction {
  const GameAction();
}

final class GameStarted extends GameAction {
  const GameStarted();
}

final class GameDialogDismissed extends GameAction {
  const GameDialogDismissed();
}

final class GameAnswerSubmitted extends GameAction {
  final String answerText;

  const GameAnswerSubmitted(this.answerText);
}

final class GameAnswerRevealElapsed extends GameAction {
  final int flowToken;

  const GameAnswerRevealElapsed(this.flowToken);
}

final class GameExplanationElapsed extends GameAction {
  final int flowToken;

  const GameExplanationElapsed(this.flowToken);
}

final class GameFeatureSelected extends GameAction {
  final GameFeatureButtonType type;

  const GameFeatureSelected(this.type);
}

final class GameMoneyLadderRequested extends GameAction {
  const GameMoneyLadderRequested();
}

final class GameConfirmExitRequested extends GameAction {
  const GameConfirmExitRequested();
}

final class GameConfirmWalkAwayRequested extends GameAction {
  const GameConfirmWalkAwayRequested();
}

final class GameWalkAwayConfirmed extends GameAction {
  const GameWalkAwayConfirmed();
}

final class GameTimerTicked extends GameAction {
  const GameTimerTicked();
}

final class GameAIAssistantElapsed extends GameAction {
  final int flowToken;

  const GameAIAssistantElapsed(this.flowToken);
}

final class GameBackToMenuRequested extends GameAction {
  const GameBackToMenuRequested();
}

/// M27 — senior `GameShareRequested`: payload = chuỗi share ĐÃ build
/// sẵn tại UI layer (l10n + amount) — VM chỉ chuyển tiếp, reducer
/// phát effect ra platform.
final class GameShareRequested extends GameAction {
  final String text;

  const GameShareRequested(this.text);
}
