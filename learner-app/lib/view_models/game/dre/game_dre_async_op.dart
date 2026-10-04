import '../../../core/dre/dre.dart';

sealed class GameAsyncOp implements DreAsyncOp {
  const GameAsyncOp();
}

final class GameSaveResult extends GameAsyncOp {
  final int earnedAmount;
  final bool isWin;
  final int questionCount;

  const GameSaveResult({
    required this.earnedAmount,
    required this.isWin,
    required this.questionCount,
  });
}
