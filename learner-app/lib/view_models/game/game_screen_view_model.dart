import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/dre/dre_change_notifier.dart';
import '../../data/auth/auth_session_data.dart';
import '../../data/game/level_config.dart';
import '../../data/game/game_quiz_question_data.dart';
import '../../data/game/game_sample_questions_data.dart';
import '../../data/game/game_screen_data.dart';
import '../../data/game/game_session_state_data.dart';
import '../../data/profile/user_profile_data.dart';
import '../../repositories/auth/auth_repository_contract.dart';
import '../../repositories/profile/user_profile_repository.dart';
import '../../repositories/profile/user_profile_sync_repository_contract.dart';
import 'dre/game_dre_contract.dart';
import 'reducer/game_reducer.dart';
import 'game_screen_presentation_mapper.dart';

part 'bridge/game_screen_view_model_effects.dart';
part 'bridge/game_screen_view_model_result_persistence.dart';

/// ViewModel của màn chơi — M26 (DRE converge, FR-37).
///
/// `GameScreenViewModel extends DreChangeNotifier<GameState, GameAction,
/// GameEffect, GameAsyncOp>` đúng senior: mọi transition chạy qua
/// [GameReducer] thuần; timer/delay/navigation là [GameEffect] đi qua
/// [_handleEffect] bridge; persistence là async-op [GameSaveResult] đi
/// qua [executeAsyncOp]. Bản trung gian M19–M25 (`extends
/// ChangeNotifier` + `_emit`/`_schedule`/`_emitWithSaveResult` tay) đã
/// retire — `flowToken` giờ nằm TRONG `GameState` và reducer guard
/// `flowToken != state.flowToken` cho mọi delayed callback.
///
/// Bề mặt public giữ đúng tên senior (`shareResult` landed M27):
/// `startNewGame`, `submitAnswer`, `handleFeatureClick`,
/// `showMoneyLadder`, `showConfirmExit`, `showConfirmWalkAway`,
/// `confirmWalkAway`, `dismissDialog`, `backToMenu`, `playAgain`,
/// `screenData`, `dialogState`, `uiEvents`.
class GameScreenViewModel
    extends DreChangeNotifier<GameState, GameAction, GameEffect, GameAsyncOp> {
  static const timePerQuestion = Duration(seconds: 30);
  static const _answerRevealDelay = Duration(milliseconds: 1500);
  static const _explanationDelay = Duration(milliseconds: 1000);
  static const _aiAssistantDelay = Duration(milliseconds: 700);

  final UserProfileRepository userProfileRepository;
  final AuthRepository authRepository;
  final UserProfileSyncRepository profileSyncRepository;
  final List<GameQuizQuestionData> questions;
  final _events = StreamController<GameScreenUiEvent>.broadcast();
  late final StreamSubscription<GameEffect> _effectSubscription;
  Timer? _timer;
  var _isDisposed = false;

  GameScreenViewModel({
    required this.userProfileRepository,
    required this.authRepository,
    required this.profileSyncRepository,
    this.questions = gameSampleQuestions,
  }) : super(
         reducer: GameReducer(
           questions: questions,
           timePerQuestion: timePerQuestion,
         ),
         initialState: GameState.initial(timePerQuestion: timePerQuestion),
       ) {
    _effectSubscription = effects.listen(_handleEffect);
  }

  /// Kênh event một-lần — nav (`GameNavigateToMenuEvent`); dialog là
  /// state. `GameShareResultEvent` → FR-33/M27.
  Stream<GameScreenUiEvent> get uiEvents => _events.stream;

  GameDialogState get dialogState => state.dialogState;

  GameScreenData get screenData {
    return buildGameScreenPresentation(
      questions: questions,
      questionIndex: state.questionIndex,
      moneyEarned: state.moneyEarned,
      moneyAnimationTrigger: state.moneyAnimationTrigger,
      totalTime: timePerQuestion,
      remainingTime: state.remainingTime,
      phase: state.phase,
      selectedAnswer: state.selectedAnswer,
      visibleOptionTexts: state.visibleOptionTexts,
      audiencePercentiles: state.audiencePercentiles,
      usedFeatureButtons: state.usedFeatureButtons,
      canWalkAway: state.guaranteedAmount > 0,
    );
  }

  void startNewGame() {
    dispatch(const GameStarted());
  }

  void submitAnswer(GameAnswerOptionData answer) {
    dispatch(GameAnswerSubmitted(answer.answerText));
  }

  void handleFeatureClick(GameFeatureButtonData button) {
    if (!button.isEnabled) return;

    dispatch(GameFeatureSelected(button.type));
  }

  void showMoneyLadder() {
    dispatch(const GameMoneyLadderRequested());
  }

  void showConfirmExit() {
    dispatch(const GameConfirmExitRequested());
  }

  void showConfirmWalkAway() {
    dispatch(const GameConfirmWalkAwayRequested());
  }

  void dismissDialog() {
    dispatch(const GameDialogDismissed());
  }

  void confirmWalkAway() {
    dispatch(const GameWalkAwayConfirmed());
  }

  void backToMenu() {
    dispatch(const GameBackToMenuRequested());
  }

  /// M27 — senior `shareResult`: wrapper dispatch `GameShareRequested`
  /// — UI (dialog layer) build sẵn chuỗi share từ l10n + số tiền.
  void shareResult(String text) {
    dispatch(GameShareRequested(text));
  }

  void playAgain() {
    startNewGame();
  }

  void _dispatchGameAction(GameAction action) {
    dispatch(action);
  }

  @override
  Future<void> executeAsyncOp(
    GameAsyncOp asyncOp,
    GameState stateSnapshot,
  ) async {
    switch (asyncOp) {
      case GameSaveResult(
        :final earnedAmount,
        :final isWin,
        :final questionCount,
      ):
        await _saveGameResult(
          earnedAmount: earnedAmount,
          isWin: isWin,
          questionCount: questionCount,
        );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _effectSubscription.cancel();
    _events.close();
    super.dispose();
  }
}
