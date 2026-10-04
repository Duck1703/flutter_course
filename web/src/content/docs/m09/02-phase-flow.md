---
title: "Bài 2 · Máy trạng thái của phiên chơi"
description: "Viết lại handler theo phase machine: submit→revealing, ba nhánh sau TIẾP, _finish với GameEndReason, _restart, và guard bằng phase."
sidebar:
  label: "Bài 2 · Phase flow"
  order: 2
---

## Mục tiêu

Viết lại toàn bộ luồng chơi của M08 theo `GamePhase`: mọi hành vi người
dùng trở thành **transition** giữa các phase, và ba cách một ván có thể
kết thúc (sai đáp án, hết giờ, thắng) đều hội tụ vào một `_finish`.

## Bạn đang ở đâu

- Milestone: **M09** (bài 2/4)
- App hiện tại: `GamePhase`/`GameEndReason` đã có, timer đếm ngược chạy
  (bài 1), nhưng handler còn theo kiểu M08 (`_submitted` bool, panel
  kết quả inline) và `_finish` chưa được viết.

## Vì sao việc này quan trọng ngay bây giờ

Khi "phase" trở thành khái niệm chính, mọi handler đều nên trả lời cùng
một câu hỏi: **"đang ở phase nào, được làm gì, đi đâu?"** Handler theo
phase dễ đọc hơn hẳn handler theo flag bool — và dễ mở rộng (thêm
phase `paused`/`review` sau này không phải tìm bool nào cần lật).

## Bạn đã biết gì

- `setState` + guard clause (M08), enum + switch (M08/bài 1),
  `Timer` + cancel (bài 1), getter suy ra (M04/M08).

## Mental model mới

**Mỗi handler = một transition có tên:**

```
_selectAnswer(i)      answering  → answering   (đổi lựa chọn)
_submitAnswer()       answering  → revealing   (dừng đồng hồ + chấm)
_advanceAfterReveal() revealing  → answering   (đúng + còn câu)
                      revealing  → finished    (sai / đúng câu cuối)
_onTick đến 0         answering  → finished    (timeout)
_restart()            finished   → answering   (chơi lại)
```

Nhìn kỹ: **không có transition nào quay lại `revealing` hay rời
`finished` trừ `_restart`** — bảng này chính là spec của game. Code chỉ
viết lại bảng.

**`revealed` không phải state — nó suy ra từ phase:**

```dart
revealed = _phase != GamePhase.answering
```

M08 lưu `_submitted` bool; M09 UI chỉ cần biết "đang hiển thị kết quả
câu này không" — đó là mọi phase trừ `answering`. Một phép suy, không
field mới.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
| --------- | ------- | ------- |
| guard bằng enum | `if (_phase != GamePhase.answering) return;` | Chặn hành vi sai phase — thay cho `if (_submitted)` |
| `?? -1` | `_selectedIndex ?? -1` | Fallback an toàn: chưa chọn → index -1 không trùng `correctIndex` nào |
| early return + else-free | `if (!wasCorrect) { _finish(...); return; }` | Nhánh kết thúc viết trước, nhánh tiếp tục không lồng else |

## Flutter cần dùng

Không có widget mới — bài này thuần logic transition.

## Android / Compose bridge

- SIMILARITY: phase machine ≈ state machine trong ViewModel game
  (`when(phase)` trong reducer Kotlin); `_finish(reason)` ≈ phát event
  terminal.
- IMPORTANT DIFFERENCE: transition ở đây nằm trực tiếp trong `State` —
  không có reducer/MVI. Senior project có tầng đó (M15+); bây giờ đừng
  mô phỏng.
- DO NOT ASSUME: `revealed` phải là biến riêng. Nó là *hàm của phase* —
  trùng lưu sẽ lệch.

## Senior project connection

- `flutter-accelerator-ai/lib/view_models/game/reducer/` — senior chuyển
  phase trong một **reducer** thuần (state mới = f(state cũ, event)). Ta
  viết transition trực tiếp trong `State` — cùng bảng chuyển, chưa có
  tầng trừu tượng. Khi nào cần test transition tách khỏi widget, reducer
  sẽ xuất hiện (M15+).
- `flutter-accelerator-ai/lib/data/game/game_session_state_data.dart` —
  senior cũng tách "phase" và "kết quả/dialog state" — ý tưởng
  `GameEndReason` của ta tương đương.

## Build it step by step

### Bước 1 — `_selectAnswer` guard bằng phase

```dart
// _GameScreenState — THAY handler M08:
void _selectAnswer(int index) {
  if (_phase != GamePhase.answering) return;
  setState(() {
    _selectedIndex = index;
  });
}
```

Cùng một quy tắc "khoá sau chốt" của M08 — giờ đọc là "chỉ chọn khi
đang answering". Guard theo phase bao trọn luôn phase `finished` (dialog
đang mở thì tap đáp án phía sau không làm gì).

### Bước 2 — `_submitAnswer`: answering → revealing

```dart
/// Chốt đáp án: dừng đếm ngược, qua phase revealing, chấm điểm.
void _submitAnswer() {
  if (_phase != GamePhase.answering || _selectedIndex == null) return;
  _timer?.cancel();
  setState(() {
    _phase = GamePhase.revealing;
    if (_question.isCorrect(_selectedIndex!)) {
      _correctCount++;
    }
  });
}
```

Ba điểm cần thấy:

- `_timer?.cancel()` **trước** `setState` — rời `answering` là đồng hồ
  phải dừng (quy tắc 3 của bài 1).
- Điều kiện guard gộp: sai phase *hoặc* chưa chọn → không chốt được.
- `_correctCount++` vẫn cộng lúc chốt (giống M08) — kết quả được ghi
  ngay, dialog sau chỉ đọc lại.

### Bước 3 — `_advanceAfterReveal`: ba nhánh

```dart
/// Nút TIẾP sau reveal: sai → game over; đúng câu cuối → victory;
/// còn lại → câu tiếp + timer mới.
void _advanceAfterReveal() {
  final wasCorrect = _question.isCorrect(_selectedIndex ?? -1);
  if (!wasCorrect) {
    _finish(GameEndReason.wrongAnswer);
    return;
  }
  if (_isLastQuestion) {
    _finish(GameEndReason.victory);
    return;
  }
  setState(() {
    _phase = GamePhase.answering;
    _questionIndex++;
    _selectedIndex = null;
  });
  _startTimer();
}
```

- `wasCorrect` đọc **lại** từ `correctIndex` + `_selectedIndex` — không
  cần field "vừa đúng hay sai" lưu sẵn. `?? -1` xử trường hợp hiếm
  (chưa chọn mà tới đây) bằng index không hợp lệ → `false`.
- Hai nhánh kết thúc viết trước bằng early `return` — nhánh "chơi tiếp"
  ở cuối phẳng, không `else`.
- `_startTimer()` sau `setState` — câu mới vào là đồng hồ mới chạy.
- `_finish` được gọi từ cả `_onTick` (timeout) lẫn đây — một cửa kết
  thúc duy nhất.

### Bước 4 — `_finish` + `_restart`

```dart
/// Kết thúc phiên: hủy timer, lưu lý do, mở dialog kết quả.
/// Dialog là một route trên stack (M07): [Menu] [Game] [Dialog].
void _finish(GameEndReason reason) {
  _timer?.cancel();
  setState(() {
    _phase = GamePhase.finished;
    _endReason = reason;
  });
  _showResultDialog();
}

/// Chơi lại: reset toàn bộ session về câu 1.
void _restart() {
  setState(() {
    _phase = GamePhase.answering;
    _questionIndex = 0;
    _selectedIndex = null;
    _correctCount = 0;
    _endReason = null;
  });
  _startTimer();
}
```

`_showResultDialog` là bài 3 — tạm để trống `void _showResultDialog()
{}` để analyze xanh nếu cần chạy giữa chừng.

### Bước 5 — Truyền `revealed`/`secondsLeft` xuống body

```dart
// build() — _QuizBody được gọi như sau:
_QuizBody(
  question: _question,
  questionIndex: _questionIndex,
  questionCount: quizQuestions.length,
  secondsLeft: _secondsLeft,
  selectedIndex: _selectedIndex,
  revealed: _phase != GamePhase.answering,
  onSelect: _selectAnswer,
  onSubmit: _submitAnswer,
  onNext: _advanceAfterReveal,
),
```

Và `_QuizBody` đổi field tương ứng: bỏ `submitted`/`quizFinished`,
thêm `secondsLeft: int` + `revealed: bool`. `_optionState` đổi guard đầu
từ `!submitted` thành `!revealed` — phần còn lại giữ nguyên.

## Hiểu code

- Vì sao `revealed` truyền xuống body thay vì truyền `phase`? — Body là
  widget "vẽ": nó chỉ cần biết *có đang hiển thị kết quả không*. Truyền
  ít thông tin hơn = ít coupling hơn; phase tổng là chuyện của `State`.
- `setState` trong `_advanceAfterReveal` chỉ chứa field thay đổi;
  `_startTimer()` đứng *ngoài* vì nó không phải "dữ liệu hiển thị" —
  Timer ảnh hưởng callback tương lai, không phải lần vẽ này. Riêng
  `_secondsLeft = secondsPerQuestion` được `_startTimer` gán lại *trong
  cùng frame* trước khi build chạy, nên đồng hồ câu mới vẽ `15s` mà
  không cần setState riêng.
- `finished` không có transition ra ngoài `_restart`/pop route — UI sau
  dialog không còn tương tác với body.

## Chạy và quan sát

- `flutter analyze` — sạch.
- `flutter run` → chơi: chọn → CHỐT (đồng hồ dừng) → TIẾP. Để sai một
  câu → chưa thấy dialog (bài 3) nhưng phase đã `finished` — đồng hồ
  dừng hẳn.
- Để ý đồng hồ: sau CHỐT nó đứng yên — đúng "chỉ đếm trong answering".

## Lỗi hay gặp

1. **`_advanceAfterReveal` quên `_startTimer()` cho câu mới** — câu 2
   không có đồng hồ. Quy tắc: transition vào `answering` ⇒ timer chạy.
2. **`_submitAnswer` không cancel timer** — đã reveal mà tick vẫn
   `setState` mỗi giây (guard phase chặn được — đúng, nhưng timer vẫn
   tốn pin chạy vô nghĩa). Cancel khi rời phase, không chỉ nhờ guard.
3. **`wasCorrect` đọc `_selectedIndex` không `??`** — `isCorrect(null)`
   crash. `?? -1` là fallback an toàn một dòng.
4. **Lưu `revealed` thành field mới** — trùng với `phase != answering`,
   dễ lệch. Suy ra, đừng lưu.

## Kiểm tra hiểu biết

1. Vì sao `_finish` nhận `reason` thay vì tự suy lý do? — *Cùng một phase
   `finished` có thể tới từ 3 đường; caller (đường đi) biết rõ lý do —
   truyền vào rõ ràng hơn suy ngược.*
2. `setState` của `_advanceAfterReveal` không đụng `_secondsLeft` — vậy
   đồng hồ câu mới vẽ `15s` nhờ đâu? — *`_startTimer()` gán
   `_secondsLeft = secondsPerQuestion` ngay trong cùng frame, trước khi
   build lại chạy.*
3. Guard `_phase != GamePhase.answering` trong `_selectAnswer` có cần
   nếu dialog `finished` đã chắn tap? — *Vẫn cần: phase `revealing` đã
   khoá chọn *trước khi* dialog xuất hiện.*

## Tự làm (PREDICT)

Điền bảng chuyển phase bằng tay — 6 tình huống, mỗi dòng ghi **phase
trước → phase sau** + **timer chạy hay dừng**:

| Tình huống | Phase trước → sau | Timer |
| --- | --- | --- |
| 1. Người chơi chọn rồi bấm CHỐT | ? | ? |
| 2. Đang reveal, bấm TIẾP (đúng, còn câu) | ? | ? |
| 3. Đang reveal, bấm TIẾP (sai — ván thua) | ? | ? |
| 4. Đang reveal, bấm TIẾP (đúng câu cuối — thắng) | ? | ? |
| 5. Đếm ngược chạm 0 lúc chưa chốt | ? | ? |
| 6. Back về menu giữa lúc đang đếm | ? | ? |

Sau đó chơi một ván thật (cố ý trả lời sai một câu, để hết giờ một câu)
và đối chiếu.

:::note[Gợi ý]
Timer chỉ sống trong `answering`. "TIẾP khi đúng" quay về `answering`
cho câu mới — vậy thì timer cũ phải… và timer mới phải…?
:::

<details><summary>Đáp án</summary>

| Tình huống | Phase | Timer |
| --- | --- | --- |
| 1. Chốt | answering → revealing | dừng (cancel — đã xong lượt) |
| 2. TIẾP đúng, còn câu | revealing → answering | restart: cancel cũ + timer mới 15s |
| 3. TIẾP sai | revealing → finished | dừng (hết ván) |
| 4. TIẾP đúng câu cuối | revealing → finished | dừng |
| 5. Hết giờ | answering → finished | tự kết thúc lượt tick cuối |
| 6. Back giữa chừng | (route pop — State dispose) | `dispose` cancel — không phase nào nhận event |

Hai điểm cần nhấn: (a) "TIẾP đúng" là transition **quay về** `answering`
— không phải đi tới; máy trạng thái có cạnh lùi. (b) Dòng 6 không có
"phase sau" — thoát màn hình không qua máy trạng thái mà qua lifecycle;
đó là lý do `dispose` phải tự dọn timer thay vì trông chờ một
transition.

</details>

## Ta cố ý chưa thêm

- Score/tiền thưởng theo câu — senior có **money ladder**; bản learner
  chỉ đếm đúng/sai (ladder là milestone sau).
- Lifeline (50:50, hỏi khán giả…) — tính năng game sau khi kiến trúc VM
  đã có (M14+).
- Transition giữa phase qua reducer/unit test thuần — M15+.
- `TickerMode`/pause-resume khi app backgrounded — sau.

## Checkpoint hoàn thành

- [ ] Không còn `_submitted`/`_quizFinished` — mọi logic đọc `_phase`.
- [ ] `_submitAnswer` cancel timer + `revealing` + chấm điểm.
- [ ] `_advanceAfterReveal` đủ 3 nhánh; `_finish`/`_restart` đúng.
- [ ] `flutter analyze` sạch; chơi tay: đồng hồ dừng sau chốt, chạy lại
  ở câu mới.
