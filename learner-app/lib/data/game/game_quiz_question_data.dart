enum GameQuestionDifficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  final String displayName;

  const GameQuestionDifficulty(this.displayName);
}

class GameQuestionExplanationData {
  final String explainForTrueAnswer;
  final Map<String, String> explainForWrongAnswers;
  final String aiHintMessage;

  const GameQuestionExplanationData({
    required this.explainForTrueAnswer,
    required this.explainForWrongAnswers,
    required this.aiHintMessage,
  });
}

class GameQuizQuestionData {
  final int id;
  final String question;
  final List<String> options;
  final String correctOption;
  final String category;
  final String language;
  final GameQuestionDifficulty difficulty;
  final GameQuestionExplanationData explanation;

  const GameQuizQuestionData({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOption,
    required this.category,
    required this.language,
    required this.difficulty,
    required this.explanation,
  });
}
