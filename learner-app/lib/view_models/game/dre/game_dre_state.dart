import '../../../data/game/game_screen_data.dart';
import '../../../data/game/game_session_state_data.dart';

class GameState {
  final GamePhase phase;
  final int questionIndex;
  final int moneyEarned;
  final int guaranteedAmount;
  final int moneyAnimationTrigger;
  final bool hasSavedResult;
  final Duration remainingTime;
  final String? selectedAnswer;
  final List<String> visibleOptionTexts;
  final Map<String, int>? audiencePercentiles;
  final Set<GameFeatureButtonType> usedFeatureButtons;
  final GameDialogState dialogState;
  final int flowToken;

  GameState({
    required this.phase,
    required this.questionIndex,
    required this.moneyEarned,
    required this.guaranteedAmount,
    required this.moneyAnimationTrigger,
    required this.hasSavedResult,
    required this.remainingTime,
    required this.selectedAnswer,
    required List<String> visibleOptionTexts,
    required Map<String, int>? audiencePercentiles,
    required Set<GameFeatureButtonType> usedFeatureButtons,
    required this.dialogState,
    required this.flowToken,
  }) : visibleOptionTexts = List.unmodifiable(visibleOptionTexts),
       audiencePercentiles = audiencePercentiles == null
           ? null
           : Map.unmodifiable(audiencePercentiles),
       usedFeatureButtons = Set.unmodifiable(usedFeatureButtons);

  factory GameState.initial({required Duration timePerQuestion}) {
    return GameState(
      phase: GamePhase.notStarted,
      questionIndex: 0,
      moneyEarned: 0,
      guaranteedAmount: 0,
      moneyAnimationTrigger: 0,
      hasSavedResult: false,
      remainingTime: timePerQuestion,
      selectedAnswer: null,
      visibleOptionTexts: const [],
      audiencePercentiles: null,
      usedFeatureButtons: const {},
      dialogState: const GameDialogHidden(),
      flowToken: 0,
    );
  }

  GameState copyWith({
    GamePhase? phase,
    int? questionIndex,
    int? moneyEarned,
    int? guaranteedAmount,
    int? moneyAnimationTrigger,
    bool? hasSavedResult,
    Duration? remainingTime,
    String? selectedAnswer,
    bool clearSelectedAnswer = false,
    List<String>? visibleOptionTexts,
    Map<String, int>? audiencePercentiles,
    bool clearAudiencePercentiles = false,
    Set<GameFeatureButtonType>? usedFeatureButtons,
    GameDialogState? dialogState,
    int? flowToken,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      questionIndex: questionIndex ?? this.questionIndex,
      moneyEarned: moneyEarned ?? this.moneyEarned,
      guaranteedAmount: guaranteedAmount ?? this.guaranteedAmount,
      moneyAnimationTrigger:
          moneyAnimationTrigger ?? this.moneyAnimationTrigger,
      hasSavedResult: hasSavedResult ?? this.hasSavedResult,
      remainingTime: remainingTime ?? this.remainingTime,
      selectedAnswer: clearSelectedAnswer
          ? null
          : selectedAnswer ?? this.selectedAnswer,
      visibleOptionTexts: visibleOptionTexts ?? this.visibleOptionTexts,
      audiencePercentiles: clearAudiencePercentiles
          ? null
          : audiencePercentiles ?? this.audiencePercentiles,
      usedFeatureButtons: usedFeatureButtons ?? this.usedFeatureButtons,
      dialogState: dialogState ?? this.dialogState,
      flowToken: flowToken ?? this.flowToken,
    );
  }
}
