import 'package:ai_millionaire_course/data/game/game_quiz_question_data.dart';
import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/view_models/game/support/game_lifeline_helper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test hàm thuần lifelines — M20. `applyGameFiftyFifty` deterministic
/// (đúng senior: giữ correct + sai-đầu, KHÔNG random);
/// `buildGameAudiencePoll` percentiles theo độ khó, tổng luôn 100.
void main() {
  GameQuizQuestionData q(GameQuestionDifficulty difficulty) {
    return GameQuizQuestionData(
      id: 1,
      question: 'Q?',
      options: const ['W1', 'CORRECT', 'W2', 'W3'],
      correctOption: 'CORRECT',
      category: 'T',
      language: 'vi',
      difficulty: difficulty,
      explanation: const GameQuestionExplanationData(
        explainForTrueAnswer: 't',
        explainForWrongAnswers: {},
        aiHintMessage: 'h',
      ),
    );
  }

  group('applyGameFiftyFifty', () {
    test('giữ đáp án đúng + ô sai ĐẦU, hai ô sai còn lại thành rỗng', () {
      // 'W1' là ô sai đầu tiên → giữ; 'W2'/'W3' xóa → ''.
      expect(
        applyGameFiftyFifty(q(GameQuestionDifficulty.easy)),
        ['W1', 'CORRECT', '', ''],
      );
    });

    test('không mutate bank gốc — options nguyên vẹn', () {
      final question = q(GameQuestionDifficulty.medium);
      applyGameFiftyFifty(question);
      expect(question.options, ['W1', 'CORRECT', 'W2', 'W3']);
    });
  });

  group('buildGameAudiencePoll', () {
    test('easy: đúng 68%; wrongs 50%/32%/dư của 32 → tổng 100', () {
      final poll = buildGameAudiencePoll(q(GameQuestionDifficulty.easy));
      expect(poll['CORRECT'], 68);
      expect(poll.values.fold<int>(0, (s, v) => s + v), 100);
      // 32 chia: round(16) + round(10.24→10) + (32-16-10=6).
      expect([poll['W1'], poll['W2'], poll['W3']], [16, 10, 6]);
    });

    test('medium 52% / hard 42%; tổng luôn 100', () {
      expect(
        buildGameAudiencePoll(q(GameQuestionDifficulty.medium))['CORRECT'],
        52,
      );
      final hard = buildGameAudiencePoll(q(GameQuestionDifficulty.hard));
      expect(hard['CORRECT'], 42);
      expect(hard.values.fold<int>(0, (s, v) => s + v), 100);
    });
  });

  group('buildGameAudiencePollItems', () {
    test('map % sang item: label + "NN%" + progress 0..1; null → 0', () {
      const answers = [
        GameAnswerOptionData(
          answerLabel: 'A',
          answerText: 'x',
          audiencePercentile: 68,
        ),
        GameAnswerOptionData(answerLabel: 'B', answerText: 'y'),
      ];
      final items = buildGameAudiencePollItems(answers);
      expect(items[0].option, 'A');
      expect(items[0].percentage, '68%');
      expect(items[0].progress, closeTo(0.68, 0.001));
      expect(items[1].percentage, '0%');
      expect(items[1].progress, 0);
    });
  });
}
