import '../../../core/dre/dre.dart';

sealed class GameEffect implements DreEffect {
  const GameEffect();
}

final class GameStartTimer extends GameEffect {
  const GameStartTimer();
}

final class GamePauseTimer extends GameEffect {
  const GamePauseTimer();
}

final class GameStopTimer extends GameEffect {
  const GameStopTimer();
}

final class GameScheduleAnswerReveal extends GameEffect {
  final int flowToken;

  const GameScheduleAnswerReveal(this.flowToken);
}

final class GameScheduleExplanation extends GameEffect {
  final int flowToken;

  const GameScheduleExplanation(this.flowToken);
}

final class GameScheduleAIAssistant extends GameEffect {
  final int flowToken;

  const GameScheduleAIAssistant(this.flowToken);
}

final class GameNavigateToMenu extends GameEffect {
  const GameNavigateToMenu();
}

/// M27 — senior `GameShareResult`: bridge đổi thành
/// `GameShareResultEvent` cho screen mở share sheet.
final class GameShareResult extends GameEffect {
  final String text;

  const GameShareResult(this.text);
}
