import 'package:flutter_test/flutter_test.dart';
import 'package:ai_millionaire_course/data/game/game_money_ladder_data.dart';
import 'package:ai_millionaire_course/data/game/game_quiz_question_data.dart';
import 'package:ai_millionaire_course/data/game/game_sample_questions_data.dart';
import 'package:ai_millionaire_course/view_models/game/support/game_money_formatter.dart';

/// Ngân hàng câu hỏi + thang tiền là dữ liệu const — test kiểm tra
/// tính toàn vẹn (bank sai cấu hình = game hỏng ngay từ data).
/// M19: bank đổi từ mini-quiz sang đúng `gameSampleQuestions` của
/// senior — 15 câu, khớp 15 level thang tiền.
void main() {
  group('gameSampleQuestions bank (senior parity)', () {
    test('đúng 15 câu — khớp 15 level thang tiền', () {
      expect(gameSampleQuestions.length, gameMoneyLadderLevels.length);
    });

    test('mọi câu có đúng 4 đáp án và correctOption nằm trong options',
        () {
      for (final q in gameSampleQuestions) {
        expect(q.options.length, 4, reason: 'câu ${q.id}');
        expect(
          q.options,
          contains(q.correctOption),
          reason: 'correctOption của câu ${q.id} phải là một option',
        );
      }
    });

    test('id duy nhất và có difficulty hợp lệ', () {
      final ids = gameSampleQuestions.map((q) => q.id).toSet();
      expect(ids.length, gameSampleQuestions.length);
      for (final q in gameSampleQuestions) {
        expect(
          q.difficulty,
          isIn(GameQuestionDifficulty.values),
        );
      }
    });

    test('mọi câu đều có explanation đủ ba mảnh senior', () {
      for (final q in gameSampleQuestions) {
        expect(q.explanation.explainForTrueAnswer, isNotEmpty);
        expect(q.explanation.aiHintMessage, isNotEmpty);
        // Mọi đáp án sai đều có giải thích riêng.
        for (final wrong in q.options.where((o) => o != q.correctOption)) {
          expect(
            q.explanation.explainForWrongAnswers[wrong],
            isNotNull,
            reason: 'câu ${q.id} thiếu explain cho "$wrong"',
          );
        }
      }
    });
  });

  group('gameMoneyLadderLevels', () {
    test('15 level, đúng 3 mốc an toàn ở Q5/Q10/Q15', () {
      expect(gameMoneyLadderLevels.length, 15);
      final safeHavens =
          gameMoneyLadderLevels.where((l) => l.isSafeHaven).toList();
      expect(safeHavens.map((l) => l.level), [5, 10, 15]);
      expect(safeHavens.map((l) => l.amount), [20000, 400000, 1000000]);
    });

    test('tiền tăng nghiêm ngặt theo level', () {
      for (var i = 1; i < gameMoneyLadderLevels.length; i++) {
        expect(
          gameMoneyLadderLevels[i].amount,
          greaterThan(gameMoneyLadderLevels[i - 1].amount),
        );
      }
    });
  });

  group('formatGameMoney', () {
    test('format kiểu senior: dollar + phẩy ngàn', () {
      expect(formatGameMoney(0), r'$0');
      expect(formatGameMoney(20000), r'$20,000');
      expect(formatGameMoney(1000000), r'$1,000,000');
    });
  });
}
