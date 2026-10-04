import 'dart:math' as math;

import '../../../data/game/game_money_ladder_data.dart';
import '../../../data/game/game_session_state_data.dart';
import 'game_money_formatter.dart';

/// Số tiền mang về khi dừng/thoát giữa ván — verbatim senior
/// `calculateGameWalkAwayAmount`: trước mốc an toàn đầu tiên
/// (`guaranteedAmount == 0`) thoát trắng tay; sau đó lấy
/// `max(guaranteed, moneyEarned)`.
int calculateGameWalkAwayAmount({
  required int guaranteedAmount,
  required int moneyEarned,
}) {
  return guaranteedAmount > 0 ? math.max(guaranteedAmount, moneyEarned) : 0;
}

/// Thang tiền cho dialog — senior `buildGameMoneyLadderItems`:
/// đảo thứ tự (giải lớn trên cùng), đánh dấu level hiện tại và
/// mốc an toàn.
List<GameMoneyLadderItemData> buildGameMoneyLadderItems({
  required int currentQuestionIndex,
}) {
  final currentLevel = currentQuestionIndex + 1;
  return gameMoneyLadderLevels.reversed
      .map((level) {
        return GameMoneyLadderItemData(
          index: level.level,
          amount: formatGameMoney(level.amount),
          isCurrent: level.level == currentLevel,
          isSpecial: level.isSafeHaven,
        );
      })
      .toList(growable: false);
}
