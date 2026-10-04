import '../../core/app_assets.dart';
import '../../data/game/game_quiz_question_data.dart';
import '../../data/game/game_screen_data.dart';
import '../../data/game/game_session_state_data.dart';
import 'support/game_money_formatter.dart';

/// Mapper thuần: state + questions → `GameScreenData` (DTO chỉ-đọc
/// cho UI). Bản senior (`buildGameScreenPresentation`) — M20 đủ
/// signature: `visibleOptionTexts`/`audiencePercentiles`/
/// `usedFeatureButtons`/`canWalkAway`.
GameScreenData buildGameScreenPresentation({
  required List<GameQuizQuestionData> questions,
  required int questionIndex,
  required int moneyEarned,
  required int moneyAnimationTrigger,
  required Duration totalTime,
  required Duration remainingTime,
  required GamePhase phase,
  required String? selectedAnswer,
  required List<String> visibleOptionTexts,
  required Map<String, int>? audiencePercentiles,
  required Set<GameFeatureButtonType> usedFeatureButtons,
  required bool canWalkAway,
}) {
  final question = questions[questionIndex];

  return GameScreenData(
    money: GameMoneyData(
      amount: formatGameMoney(moneyEarned),
      animationTrigger: moneyAnimationTrigger,
    ),
    question: GameQuestionData(
      questionText: question.question,
      currentQuestionIndex: questionIndex,
      totalQuestions: questions.length,
      category: question.category,
      difficulty: question.difficulty.displayName,
    ),
    answers: _buildAnswers(
      question: question,
      phase: phase,
      selectedAnswer: selectedAnswer,
      visibleOptionTexts: visibleOptionTexts,
      audiencePercentiles: audiencePercentiles,
    ),
    featureButtons: _buildFeatureButtons(
      phase: phase,
      usedFeatureButtons: usedFeatureButtons,
      canWalkAway: canWalkAway,
    ),
    timer: GameTimerData(totalTime: totalTime, remainingTime: remainingTime),
  );
}

/// Verbatim senior `_buildAnswers`: text ô lấy từ `visibleOptionTexts`
/// (50:50 đã thay ô bị xóa bằng `''`), % khán giả tra theo text.
List<GameAnswerOptionData> _buildAnswers({
  required GameQuizQuestionData question,
  required GamePhase phase,
  required String? selectedAnswer,
  required List<String> visibleOptionTexts,
  required Map<String, int>? audiencePercentiles,
}) {
  return List.generate(question.options.length, (index) {
    final optionText = visibleOptionTexts[index];
    return GameAnswerOptionData(
      answerLabel: String.fromCharCode(65 + index),
      answerText: optionText,
      state: _answerState(
        optionText: optionText,
        correctAnswer: question.correctOption,
        phase: phase,
        selectedAnswer: selectedAnswer,
      ),
      audiencePercentile: audiencePercentiles?[optionText],
    );
  });
}

/// Verbatim senior `_buildFeatureButtons`: ba nút luôn có, `walkAway`
/// chỉ thêm khi `canWalkAway` (guaranteedAmount > 0 — senior tính ở
/// VM), `exitGame` KHÔNG nằm trong thanh (nút ✕ top bar gọi
/// `showConfirmExit` riêng). `isEnabled = canPlay && !used`.
List<GameFeatureButtonData> _buildFeatureButtons({
  required GamePhase phase,
  required Set<GameFeatureButtonType> usedFeatureButtons,
  required bool canWalkAway,
}) {
  final canPlay = phase == GamePhase.playing;
  final buttons = [
    _feature(
      GameFeatureButtonType.fiftyFifty,
      AppAssets.iconGameFiftyFifty,
      '50:50',
      canPlay,
      usedFeatureButtons,
    ),
    _feature(
      GameFeatureButtonType.audiencePoll,
      AppAssets.iconGameAudience,
      'Ask the Audience',
      canPlay,
      usedFeatureButtons,
    ),
    _feature(
      GameFeatureButtonType.aiAssistant,
      AppAssets.iconGameSparkle,
      'Ask AI',
      canPlay,
      usedFeatureButtons,
    ),
  ];
  if (canWalkAway) {
    buttons.add(
      _feature(
        GameFeatureButtonType.walkAway,
        AppAssets.iconGameTrophy,
        'Walk Away',
        canPlay,
        usedFeatureButtons,
      ),
    );
  }
  return buttons;
}

/// M28 (FR-34 CONVERGED): `iconAsset` đúng senior — `String` path
/// qua `AppAssets`, render bằng `SvgPicture.asset` ở widget.
GameFeatureButtonData _feature(
  GameFeatureButtonType type,
  String icon,
  String label,
  bool canPlay,
  Set<GameFeatureButtonType> usedFeatureButtons,
) {
  return GameFeatureButtonData(
    type: type,
    iconAsset: icon,
    semanticLabel: label,
    isEnabled: canPlay && !usedFeatureButtons.contains(type),
  );
}

/// Verbatim senior `_answerState` — ô text rỗng (50:50 đã xóa) luôn
/// idle; `answeredPending` tô ô đã chọn; `answeredRevealed` tô đúng/
/// sai; mọi phase khác giữ idle.
GameAnswerState _answerState({
  required String optionText,
  required String correctAnswer,
  required GamePhase phase,
  required String? selectedAnswer,
}) {
  if (optionText.isEmpty) return GameAnswerState.idle;
  if (phase == GamePhase.answeredPending && optionText == selectedAnswer) {
    return GameAnswerState.selected;
  }
  if (phase != GamePhase.answeredRevealed) return GameAnswerState.idle;
  if (optionText == correctAnswer) return GameAnswerState.correct;
  return optionText == selectedAnswer
      ? GameAnswerState.incorrect
      : GameAnswerState.idle;
}
