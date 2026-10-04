/// Trạng thái hiển thị của một ô đáp án — mapper suy ra từ
/// `GamePhase` + `selectedAnswer`, UI chỉ render.
enum GameAnswerState { idle, selected, correct, incorrect }

/// Năm nút lifeline của senior (`game_screen_data.dart`) — M20.
/// `exitGame` là nút ✕ trên top bar (không nằm trong thanh lifeline
/// — mapper senior cũng không đưa nó vào `featureButtons`); bốn nút
/// còn lại render ở thanh dưới màn.
enum GameFeatureButtonType {
  fiftyFifty,
  audiencePoll,
  aiAssistant,
  walkAway,
  exitGame,
}

/// Tiền hiển thị trên top bar — `animationTrigger` làm key để chơi
/// lại animation khi amount đổi.
class GameMoneyData {
  final String amount;
  final int animationTrigger;

  const GameMoneyData({required this.amount, this.animationTrigger = 0});
}

/// Khối câu hỏi — senior `GameQuestionData`.
class GameQuestionData {
  final String questionText;
  final int currentQuestionIndex;
  final int totalQuestions;
  final String category;
  final String difficulty;

  const GameQuestionData({
    required this.questionText,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    this.category = '',
    this.difficulty = '',
  });

  int get displayQuestionNumber => currentQuestionIndex + 1;
}

/// Một ô đáp án A–D — senior `GameAnswerOptionData` đầy đủ (M20 thêm
/// `audiencePercentile` + `copyWith`/`clearAudiencePercentile`).
class GameAnswerOptionData {
  final String answerLabel;
  final String answerText;
  final GameAnswerState state;

  /// % khán giả cho ô này khi poll đã dùng — `null` = không hiển thị.
  final int? audiencePercentile;

  const GameAnswerOptionData({
    required this.answerLabel,
    required this.answerText,
    this.state = GameAnswerState.idle,
    this.audiencePercentile,
  });

  GameAnswerOptionData copyWith({
    String? answerText,
    GameAnswerState? state,
    int? audiencePercentile,
    bool clearAudiencePercentile = false,
  }) {
    return GameAnswerOptionData(
      answerLabel: answerLabel,
      answerText: answerText ?? this.answerText,
      state: state ?? this.state,
      audiencePercentile: clearAudiencePercentile
          ? null
          : audiencePercentile ?? this.audiencePercentile,
    );
  }
}

/// Đồng hồ — senior `GameTimerData` (`mm:ss` + progress clamped).
class GameTimerData {
  final Duration totalTime;
  final Duration remainingTime;

  const GameTimerData({required this.totalTime, required this.remainingTime});

  double get progress {
    final totalMilliseconds = totalTime.inMilliseconds;

    if (totalMilliseconds <= 0) {
      return 0;
    }

    final ratio = remainingTime.inMilliseconds / totalMilliseconds;
    return ratio.clamp(0, 1).toDouble();
  }

  String get formattedTime {
    final maxSeconds = totalTime.inSeconds;
    final remainingSeconds = remainingTime.inSeconds;
    final safeSeconds = remainingSeconds < 0
        ? 0
        : (remainingSeconds > maxSeconds ? maxSeconds : remainingSeconds);
    final minutes = safeSeconds ~/ 60;
    final seconds = safeSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

/// Một nút trên thanh lifeline — senior `GameFeatureButtonData`.
/// M28 (FR-34 CONVERGED): `iconAsset` là `String` SVG path qua
/// `AppAssets` (pipeline `SvgPicture` đã port) — đúng shape senior.
class GameFeatureButtonData {
  final GameFeatureButtonType type;
  final String iconAsset;
  final String semanticLabel;
  final bool isEnabled;

  const GameFeatureButtonData({
    required this.type,
    required this.iconAsset,
    required this.semanticLabel,
    this.isEnabled = true,
  });

  GameFeatureButtonData copyWith({bool? isEnabled}) {
    return GameFeatureButtonData(
      type: type,
      iconAsset: iconAsset,
      semanticLabel: semanticLabel,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// Toàn bộ dữ liệu màn chơi cần render — senior `GameScreenData`
/// đầy đủ (M20 thêm `featureButtons`).
class GameScreenData {
  final GameMoneyData money;
  final GameQuestionData question;
  final List<GameAnswerOptionData> answers;
  final List<GameFeatureButtonData> featureButtons;
  final GameTimerData timer;

  const GameScreenData({
    required this.money,
    required this.question,
    required this.answers,
    required this.featureButtons,
    required this.timer,
  });
}
