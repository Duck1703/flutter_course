/// Phase của một phiên chơi — M19: máy trạng thái đầy đủ theo senior
/// (`lib/data/game/game_session_state_data.dart`). Sáu giá trị loại
/// trừ lẫn nhau; mọi chuyển trạng thái đi qua `GameScreenViewModel`.
enum GamePhase {
  /// Ván chưa bắt đầu — intro (thang tiền) đang mở.
  notStarted,

  /// Đang chơi — timer chạy, có thể bấm đáp án.
  playing,

  /// Đã bấm đáp án — chờ delay reveal (1.5s).
  answeredPending,

  /// Đã reveal đúng/sai — chờ delay trước dialog giải thích (1s).
  answeredRevealed,

  /// Ván thua kết thúc.
  gameOver,

  /// Thắng trọn câu cuối.
  victory,
}

/// Trạng thái dialog của màn chơi — tập đóng các variant (M15).
/// M19 mở rộng theo senior: thêm thang tiền, xác nhận thoát, giải
/// thích; `GameEndedDialog`/`GameVictoryDialog` mang `earnedAmount`
/// thay `GameEndReason` (senior không phân biệt lý do thua).
/// M20 thêm bộ lifeline: `GameConfirmWalkAwayDialog`,
/// `GameAudiencePollDialog`, `GameAIAssistantDialog` — đủ 9 variant,
/// khớp senior 1:1 (đã tính `GameDialogHidden`).
sealed class GameDialogState {
  const GameDialogState();
}

/// Không có dialog nào đang mở.
final class GameDialogHidden extends GameDialogState {
  const GameDialogHidden();
}

/// Dialog thang tiền — danh sách level đã format sẵn.
final class GameMoneyLadderDialog extends GameDialogState {
  const GameMoneyLadderDialog({required this.items});

  /// Các hàng thang tiền (đã đảo — giải lớn trên cùng).
  final List<GameMoneyLadderItemData> items;
}

/// Một hàng trong thang tiền.
final class GameMoneyLadderItemData {
  const GameMoneyLadderItemData({
    required this.index,
    required this.amount,
    required this.isCurrent,
    required this.isSpecial,
  });

  /// Số level (1–15).
  final int index;

  /// Tiền đã format (`$20,000`).
  final String amount;

  /// Level hiện tại của ván.
  final bool isCurrent;

  /// Mốc an toàn (safe haven) — Q5/Q10/Q15.
  final bool isSpecial;
}

/// Dialog xác nhận thoát giữa ván (back/✕) — hiện mốc an toàn đang có.
final class GameConfirmExitDialog extends GameDialogState {
  const GameConfirmExitDialog({required this.guaranteedAmount});

  /// Số tiền chắc chắn giữ lại nếu thoát (đã format).
  final String guaranteedAmount;
}

/// Dialog xác nhận "dừng cuộc chơi" (walk-away) — M20.
/// Senior `GameConfirmWalkAwayDialog`: mang số tiền sẽ mang về.
final class GameConfirmWalkAwayDialog extends GameDialogState {
  const GameConfirmWalkAwayDialog({required this.currentAmount});

  /// Số tiền mang về nếu dừng — `formatGameMoney(walkAwayAmount)`.
  final String currentAmount;
}

/// Dialog "hỏi khán giả" — M20. Senior `GameAudiencePollDialog`:
/// danh sách hàng đã format sẵn (option + % + progress).
final class GameAudiencePollDialog extends GameDialogState {
  const GameAudiencePollDialog({required this.items});

  /// Các hàng poll — một hàng mỗi đáp án.
  final List<GameAudiencePollItemData> items;
}

/// Một hàng trong dialog poll — senior `GameAudiencePollItemData`.
final class GameAudiencePollItemData {
  const GameAudiencePollItemData({
    required this.option,
    required this.percentage,
    required this.progress,
  });

  /// Nhãn đáp án (`A`–`D`).
  final String option;

  /// Phần trăm đã format (`"68%"`).
  final String percentage;

  /// Giá trị 0..1 cho thanh progress.
  final double progress;
}

/// Dialog "hỏi AI" — M20. Senior `GameAIAssistantDialog`: hai trạng
/// thái trong một variant — `isLoading` (spinner) → kết quả
/// (`selectedAnswer` + `confidencePercentage` + `explanation`).
final class GameAIAssistantDialog extends GameDialogState {
  const GameAIAssistantDialog({
    required this.selectedAnswer,
    required this.confidencePercentage,
    required this.explanation,
    this.isLoading = false,
  });

  /// Đáp án AI "chọn" — trong bản senior luôn là `correctOption`
  /// (AI mô phỏng, không gọi mạng).
  final String selectedAnswer;

  /// Độ tin cậy hiển thị — senior hardcode `85`.
  final int confidencePercentage;

  /// Gợi ý hiển thị — `question.explanation.aiHintMessage`.
  final String explanation;

  /// `true` trong 700ms chờ mô phỏng (`_aiAssistantDelay`).
  final bool isLoading;
}

/// Dialog giải thích sau khi reveal — hiện tự động sau
/// `_explanationDelay`, đóng để sang câu tiếp (hoặc kết thúc).
final class GameExplanationDialog extends GameDialogState {
  const GameExplanationDialog({
    required this.question,
    required this.correctAnswer,
    required this.explanation,
    required this.isCorrect,
  });

  /// Đề câu hỏi vừa trả lời.
  final String question;

  /// Đáp án đúng (text).
  final String correctAnswer;

  /// Giải thích theo đúng/sai (`explainForTrueAnswer` hoặc
  /// `explainForWrongAnswers[selected] ?? aiHintMessage`).
  final String explanation;

  /// Người chơi trả lời đúng không.
  final bool isCorrect;
}

/// Ván thua — sai đáp án hoặc hết giờ. Senior chỉ mang `earnedAmount`:
/// dialog kết thúc giống nhau, khác số tiền.
final class GameEndedDialog extends GameDialogState {
  const GameEndedDialog({required this.earnedAmount});

  /// Số tiền nhận được = `guaranteedAmount` (đã format).
  final String earnedAmount;
}

/// Thắng trọn câu cuối.
final class GameVictoryDialog extends GameDialogState {
  const GameVictoryDialog({
    required this.earnedAmount,
    required this.affirmationMessage,
  });

  /// Tiền thắng — luôn `$1,000,000` trong bank mẫu.
  final String earnedAmount;

  /// Câu chúc mừng (senior: chuỗi cứng English).
  final String affirmationMessage;
}

/// Event một-lần của màn chơi (M13/M15: khác hẳn state — listener mới
/// không được replay).
///
/// M21: `GameDialogRequested` (scaffold của bản `showDialog`) RETIRE —
/// dialog đã render in-tree từ `dialogState`, không cần event "xin mở".
/// M27: `GameShareResultEvent` land — family khớp senior đủ.
sealed class GameScreenUiEvent {
  const GameScreenUiEvent();
}

/// Xin điều hướng về menu — UI tự pop. M22: không còn `GameResult`
/// đi kèm — kết quả đã được VM lưu thẳng vào repository trước đó
/// (senior parity: route pop trần, stream repo là nguồn truth).
final class GameNavigateToMenuEvent extends GameScreenUiEvent {
  const GameNavigateToMenuEvent();
}

/// Xin mở share sheet với nội dung đã build — M27 (FR-33 converge):
/// screen thực hiện `SharePlus.instance.share`, lỗi → clipboard.
final class GameShareResultEvent extends GameScreenUiEvent {
  final String text;

  const GameShareResultEvent(this.text);
}
