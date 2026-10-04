---
title: "Bài 5 · `GameDialogState` — dialog render theo state (state-driven UI)"
description: "Sealed GameDialogState 3-variant; `_endReason` enum → `_dialogState`; `_dialogTitle`/`_resultText` thành switch expression kiệt hợp; một phần của dialog-state senior."
sidebar:
  label: "Bài 5 · GameDialogState"
  order: 5
---

## Mục tiêu

Sau bài này bạn **mô hình hoá được** một nhóm UI state bằng sealed
hierarchy trong app thật: `GameDialogState` 3-variant thay
`GameEndReason? _endReason`, và hai hàm nội dung dialog trở thành
`switch` expression kiệt hợp. Đây là đỉnh của M15 — **state-driven
UI**: nội dung dialog = hàm của state.

## Bạn đang ở đâu

- Milestone: **M15** (bài 5/5 — bài cuối).
- Vào bài: `_endReason` là `GameEndReason?` + `AlertDialog` đọc
  trực tiếp; `won:` lấy từ so sánh enum.
- Ra bài: `_dialogState` là sealed `GameDialogState`; mọi nội dung
  dialog là `switch(state)` kiệt hợp; `showDialog` cơ chế giữ nguyên
  (M21 mới đổi sang in-Stack layer).

## Vì sao việc này quan trọng ngay bây giờ

`_endReason` nullable là dạng "state nửa vời" (bài 1): `null` nghĩa
"chưa có dialog" nhưng compiler không biết điều đó — `_dialogTitle`
phải tự phòng thủ bằng `case null`. Với `GameDialogState`, "không có
dialog" là **một variant thật** (`GameDialogHidden`) — không còn
`null` lẩn trong hệ thống type, và mọi `switch` trên dialog-state
phải trả lời hẳn hoi cho nó.

## Bạn đã biết gì

- `GamePhase` enum + `showDialog` route + `_ResultAction` (M09–M10).
- `sealed class` + `switch` expression + `(:final field)` + `_`
  (bài 2–3).
- Event sealed (bài 4) — bài này là cùng pattern, *cho state*.

## Mental model — "state hỏi, UI trả lời"

Trước: dialog builder đọc `_endReason` rồi *suy ra* nên hiện gì.
Sau: UI hỏi "`_dialogState` đang là variant nào?" — và mỗi variant
**tự mang đủ dữ kiện** để trả lời (`GameEndedDialog` mang `reason`;
`GameVictoryDialog` không cần gì; `GameDialogHidden` = không render).

Đây là bản chất "state-driven UI" mà senior dùng khắp nơi: **render =
f(state)**. UI không lập luận từ cờ — nó dịch state thành pixels.

## Dart cần dùng

Không có syntax mới — bài này áp dụng bài 2–3 ở quy mô lớn hơn.

## Flutter cần dùng

Không có API mới — `showDialog`/`AlertDialog`/route-pop giữ nguyên từ
M07–M10. Chỉ *cách chọn nội dung* của dialog đổi sang `switch` trên
state.

## Ví dụ độc lập

Pattern "state → nội dung" đã có ví dụ độc lập ở bài 3 (`label(
PaymentState)` trả chuỗi theo variant). Bài này là cùng hàm đó, nhưng
chuỗi trả về là nội dung dialog của app thật — không cần ví dụ thứ
hai.

## Android / Compose bridge

- **SIMILARITY**: Compose làm đúng việc này — `when(state)` chọn
  composable; Flutter `switch(state)` chọn nội dung/widget.
- **IMPORTANT DIFFERENCE**: senior Flutter render dialog *trong
  `Stack`* bằng switch trả widget (M21); learner M15 vẫn dùng
  `showDialog` route — chỉ nội dung bên trong là state-driven.

## Senior project connection

- `lib/data/game/game_session_state_data.dart`: `sealed class
  GameDialogState` + 9 variant — learner giữ **3** đúng UX hiện có.
- `lib/widgets/game/dialogs/game_dialog_layer.dart::_dialogBody`:
  `switch (dialog)` expression → widget tương ứng (senior render
  trong `Stack` — M21; ta giữ `showDialog`).
- Lưu ý senior `GamePhase` vẫn là **enum** — không phải mọi tập
  đều sealed. Phase là máy trạng thái tuần tự (M19), dialog state
  là *variant UI* — hai loại khác nhau.

## Build it step by step

Bốn bước đổi **cùng lúc** (atomic như bài 4 — sửa lẻ sẽ không
compile vì import/enum/call-site lệch nhau):

**Bước 1** — đổi tên `lib/data/game/game_session_state.dart` →
`game_session_state_data.dart` (khớp senior), sửa import ở
`game_screen.dart` (`import '../data/game/game_session_state_data.dart';`),
thêm hierarchy:

```dart
enum GameEndReason {
  wrongAnswer,
  timeout,
}

sealed class GameDialogState {
  const GameDialogState();
}

final class GameDialogHidden extends GameDialogState {
  const GameDialogHidden();
}

final class GameEndedDialog extends GameDialogState {
  const GameEndedDialog({required this.reason});
  final GameEndReason reason;
}

final class GameVictoryDialog extends GameDialogState {
  const GameVictoryDialog();
}
```

`GameEndReason` mất `victory`: chiến thắng giờ là **variant riêng**
(đúng senior — `GameVictoryDialog` tách khỏi `GameEndedDialog`).

**Bước 2** — `game_screen.dart`: đổi field + call sites:

```dart
GameDialogState _dialogState = const GameDialogHidden();
```

`_finish` nhận variant hẳn:

```dart
void _finish(GameDialogState dialog) {
  _timer?.cancel();
  final result = GameResult(
    questionsAnswered: _answeredCount,
    correctAnswers: _correctCount,
    won: dialog is GameVictoryDialog,
  );
  setState(() {
    _phase = GamePhase.finished;
    _dialogState = dialog;
  });
  _showResultDialog(result);
}
```

Ba call site: timeout → `GameEndedDialog(reason: GameEndReason
.timeout)`; sai → `...wrongAnswer`; cuối đúng → `GameVictoryDialog()`.

**Bước 3** — nội dung dialog thành switch expression:

```dart
String _dialogTitle() {
  return switch (_dialogState) {
    GameVictoryDialog() => 'CHIẾN THẮNG!',
    GameEndedDialog(:final reason) => switch (reason) {
      GameEndReason.timeout => 'HẾT GIỜ!',
      GameEndReason.wrongAnswer => 'KẾT THÚC',
    },
    GameDialogHidden() => '',
  };
}
```

(`_resultText` cùng shape — chuỗi khác nhau.) Màu tiêu đề cũng là
switch có wildcard `_` cho "còn lại":

```dart
color: switch (_dialogState) {
  GameVictoryDialog() => MenuTokens.statGreen,
  _ => MenuTokens.accentRed,
},
```

`_restart` đặt lại `_dialogState = const GameDialogHidden()`.

**Bước 4** — test mới `test/sealed_state_test.dart`: 5 test — payload
event, switch kiệt hợp trên cả hai hierarchy, `is` discrimination.

## Hiểu code

- `GameEndedDialog(:final reason)` — pattern bóc `reason` ngay trong
  case, rồi *switch lồng* trên enum `GameEndReason` (đã học M09) cho
  phần lỗi-thua.
- `GameDialogHidden() => ''` — trông "thừa" vì dialog không mở lúc
  hidden, nhưng **compiler bắt buộc** liệt kê: đó là điểm kiệt hợp.
- `won: dialog is GameVictoryDialog` — `is` vẫn hợp lệ trên sealed;
  dùng khi cần một câu trả lời bool, không cần switch.

## Chạy và quan sát

- `flutter analyze` → sạch.
- `flutter test` → **74 xanh** (69 cũ + 5 test sealed mới).
- Chơi thử: sai → KẾT THÚC; hết giờ → HẾT GIỜ!; thắng hết → CHIẾN
  THẮNG! — hành vi nguyên vẹn, cơ chế trong đổi.

## Thử nghiệm

Xoá `GameDialogHidden() => ''` trong `_dialogTitle` →
`non_exhaustive_switch_expression` ngay. Restore. Đây là demo
"compiler refuses"
mà milestone hứa trong roadmap.

## Lỗi hay gặp

- **Để `victory` lại trong `GameEndReason`** — hai nơi biểu diễn cùng
  một sự thật (enum + variant) → mâu thuẫn. Tách variant riêng.
- **Switch thiếu `GameDialogHidden`** → compile error — đó là điểm.
- **Đưa chữ UI vào variant** (`GameEndedDialog(title: ...)`) — state
  nên mang *dữ kiện domain* (`reason`), render layer dịch ra chữ.
  Senior mang `earnedAmount` — dữ kiện game, không phải caption sẵn.
- **Bỏ `showDialog` sang Stack sớm** — chưa đến M21; giữ mechanism,
  chỉ đổi cách *chọn nội dung*.

## Tự làm

**DEBUG** — đoạn này lỗi biên dịch, tìm vì sao và sửa:

```dart
String dialogLabel(GameDialogState s) {
  return switch (s) {
    GameVictoryDialog() => 'win',
    GameEndedDialog() => 'ended',   // không bóc reason — hợp lệ?
  };
}
```

:::note[Gợi ý]
Có bao nhiêu variant trong file `game_session_state_data.dart`? Đếm
lại rồi so với số case.
:::

<details><summary>Đáp án</summary>

Thiếu `GameDialogHidden()`. `GameEndedDialog()` không cần pattern
payload nếu không dùng `reason` — hợp lệ cú pháp, nhưng switch thiếu
một variant nên vẫn `non_exhaustive_switch_expression`. Sửa:

```dart
return switch (s) {
  GameVictoryDialog() => 'win',
  GameEndedDialog() => 'ended',
  GameDialogHidden() => 'hidden',
};
```

</details>

## Kiểm tra hiểu biết

1. `GameDialogHidden` không bao giờ mở dialog — vì sao vẫn phải liệt
   kê trong switch?
2. `reason` là payload của variant — vì sao không để sẵn `title`/
   `body` làm payload?
3. Vì sao `GamePhase` giữ enum mà `GameDialogState` thành sealed?

<details><summary>Đáp án</summary>

1. Sealed = tập đóng — compiler yêu cầu mọi `switch` trả lời cho mọi
   variant, kể cả "không xảy ra". Trả `''` là câu trả lời hợp lệ.
2. State nên chứa *dữ kiện domain*; chữ hiển thị là quyết định render.
   `earnedAmount` của senior là dữ kiện (số tiền), không phải caption.
3. Phase là máy trạng thái tuần tự không payload — enum đủ. Dialog
   state có variant mang dữ liệu — enum không làm được.

</details>

## Ta cố ý chưa thêm

- 6 variant còn lại của `GameDialogState` (ladder/confirm/explanation/
  lifelines) — theo feature, **M19–M21**.
- `GameDialogLayer` trong `Stack` + `AnimatedSwitcher` + `ValueKey
  (runtimeType)` — **M21**.
- `MenuDialogState` learner — M16+ khi menu có dialog thật.
- `GamePhase` 6-value + reducer + GameViewModel — **M19**.

## Checkpoint hoàn thành

- [ ] `flutter analyze` sạch.
- [ ] `flutter test` → 74 green.
- [ ] Demo compile-error khi xoá một case của `switch(_dialogState)`.
- [ ] Tự làm DEBUG làm được không nhìn đáp án.
