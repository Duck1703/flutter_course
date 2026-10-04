import '../../../data/game/game_quiz_question_data.dart';
import '../../../data/game/game_screen_data.dart';
import '../../../data/game/game_session_state_data.dart';

/// Hàm thuần của lifelines — verbatim senior
/// `view_models/game/support/game_lifeline_helper.dart` (M20).

/// 50:50 — *deterministic* theo senior (KHÔNG random): giữ đáp án đúng
/// và ô sai ĐẦU TIÊN (`firstWhere`), hai ô sai còn lại thành `''` —
/// chuỗi rỗng = ô bị xóa (mapper render idle, VM chặn submit rỗng).
List<String> applyGameFiftyFifty(GameQuizQuestionData question) {
  final wrong = question.options.firstWhere(
    (it) => it != question.correctOption,
  );
  return question.options
      .map((it) => it == question.correctOption || it == wrong ? it : '')
      .toList(growable: false);
}

/// Poll khán giả — % đáp án đúng theo độ khó (easy 68 / medium 52 /
/// hard 42); phần còn lại chia cho 3 ô sai qua [_splitWrongAudience]
/// (50% / 32% / phần dư → tổng luôn 100).
Map<String, int> buildGameAudiencePoll(GameQuizQuestionData question) {
  final correct = switch (question.difficulty) {
    GameQuestionDifficulty.easy => 68,
    GameQuestionDifficulty.medium => 52,
    GameQuestionDifficulty.hard => 42,
  };
  final wrongValues = _splitWrongAudience(100 - correct);
  var wrongIndex = 0;
  return {
    for (final option in question.options)
      option: option == question.correctOption
          ? correct
          : wrongValues[wrongIndex++],
  };
}

/// Map percentiles → hàng dialog (label + "%" + progress 0..1) —
/// verbatim senior `buildGameAudiencePollItems`.
List<GameAudiencePollItemData> buildGameAudiencePollItems(
  List<GameAnswerOptionData> answers,
) {
  return answers
      .map((answer) {
        final value = answer.audiencePercentile ?? 0;
        return GameAudiencePollItemData(
          option: answer.answerLabel,
          percentage: '$value%',
          progress: value / 100,
        );
      })
      .toList(growable: false);
}

List<int> _splitWrongAudience(int remaining) {
  final first = (remaining * 0.5).round();
  final second = (remaining * 0.32).round();
  return [first, second, remaining - first - second];
}
