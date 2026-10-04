import 'package:ai_millionaire_course/data/game/game_quiz_question_data.dart';
import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/data/game/game_session_state_data.dart';
import 'package:ai_millionaire_course/view_models/game/game_screen_presentation_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test mapper thuần — M19 L03. `buildGameScreenPresentation` không
/// có side effect: cùng input → cùng `GameScreenData`. Test truyền
/// state trực tiếp, không cần VM hay widget.
void main() {
  const question = GameQuizQuestionData(
    id: 1,
    question: 'Q?',
    options: ['A', 'B', 'C', 'D'],
    correctOption: 'B',
    category: 'Flutter',
    language: 'vi',
    difficulty: GameQuestionDifficulty.medium,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer: 't',
      explainForWrongAnswers: {},
      aiHintMessage: 'h',
    ),
  );

  GameScreenData build({
    GamePhase phase = GamePhase.playing,
    String? selectedAnswer,
    int moneyEarned = 0,
    Duration remaining = const Duration(seconds: 30),
    List<String>? visibleOptionTexts,
    Map<String, int>? audiencePercentiles,
    Set<GameFeatureButtonType> usedFeatureButtons = const {},
    bool canWalkAway = false,
  }) {
    return buildGameScreenPresentation(
      questions: const [question],
      questionIndex: 0,
      moneyEarned: moneyEarned,
      moneyAnimationTrigger: 0,
      totalTime: const Duration(seconds: 30),
      remainingTime: remaining,
      phase: phase,
      selectedAnswer: selectedAnswer,
      // M20: text hiển thị mặc định = options gốc (chưa 50:50).
      visibleOptionTexts: visibleOptionTexts ?? question.options,
      audiencePercentiles: audiencePercentiles,
      usedFeatureButtons: usedFeatureButtons,
      canWalkAway: canWalkAway,
    );
  }

  test('playing: mọi đáp án idle; counter + meta đúng', () {
    final data = build();
    expect(data.answers.map((a) => a.state),
        everyElement(GameAnswerState.idle));
    expect(data.question.displayQuestionNumber, 1);
    expect(data.question.totalQuestions, 1);
    expect(data.question.difficulty, 'Medium');
    expect(data.answers.map((a) => a.answerLabel), ['A', 'B', 'C', 'D']);
  });

  test('answeredPending: chỉ ô được chọn là selected', () {
    final data = build(
      phase: GamePhase.answeredPending,
      selectedAnswer: 'A',
    );
    expect(data.answers[0].state, GameAnswerState.selected);
    expect(data.answers[1].state, GameAnswerState.idle);
  });

  test('answeredRevealed: đúng xanh, chọn sai đỏ, còn lại idle', () {
    final data = build(
      phase: GamePhase.answeredRevealed,
      selectedAnswer: 'A', // sai — đúng là 'B'
    );
    expect(data.answers[1].state, GameAnswerState.correct);
    expect(data.answers[0].state, GameAnswerState.incorrect);
    expect(data.answers[2].state, GameAnswerState.idle);
  });

  test('timer: formattedTime mm:ss + progress clamp + money format',
      () {
    final data = build(
      moneyEarned: 20000,
      remaining: const Duration(seconds: 7),
    );
    expect(data.timer.formattedTime, '00:07');
    expect(data.timer.progress, closeTo(7 / 30, 0.001));
    expect(data.money.amount, r'$20,000');
    // Vượt total → progress vẫn ≤ 1 (clamp).
    final over = build(remaining: const Duration(seconds: 45));
    expect(over.timer.progress, 1);
  });

  // ------------------------------------------------------------------
  // M20 — lifelines trong mapper
  // ------------------------------------------------------------------

  test('50:50: text rỗng → ô render idle + audiencePercentile tra theo text',
      () {
    final data = build(
      // Sau 50:50: 'B' (đúng) + 'A' (sai đầu) giữ; 'C'/'D' bị xóa.
      visibleOptionTexts: const ['A', 'B', '', ''],
      audiencePercentiles: const {'A': 16, 'B': 52},
    );
    expect(data.answers.map((a) => a.answerText), ['A', 'B', '', '']);
    expect(data.answers[2].state, GameAnswerState.idle);
    expect(data.answers[0].audiencePercentile, 16);
    expect(data.answers[1].audiencePercentile, 52);
    expect(data.answers[2].audiencePercentile, isNull);
  });

  test('featureButtons: 3 nút khi playing, used → isEnabled=false; '
      'walkAway chỉ hiện khi canWalkAway', () {
    final data = build(
      usedFeatureButtons: const {GameFeatureButtonType.fiftyFifty},
      canWalkAway: true,
    );
    expect(
      data.featureButtons.map((b) => b.type),
      [
        GameFeatureButtonType.fiftyFifty,
        GameFeatureButtonType.audiencePoll,
        GameFeatureButtonType.aiAssistant,
        GameFeatureButtonType.walkAway,
      ],
    );
    expect(data.featureButtons[0].isEnabled, isFalse); // đã dùng
    expect(data.featureButtons[1].isEnabled, isTrue);
    // Không playing → mọi nút disable; không safe haven → không walkAway.
    final notPlaying = build(phase: GamePhase.answeredPending);
    expect(
      notPlaying.featureButtons.map((b) => b.isEnabled),
      everyElement(isFalse),
    );
    expect(
      notPlaying.featureButtons.map((b) => b.type),
      isNot(contains(GameFeatureButtonType.walkAway)),
    );
  });
}
