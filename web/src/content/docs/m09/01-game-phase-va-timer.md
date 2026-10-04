---
title: "Bài 1 · GamePhase & Timer đếm ngược"
description: "Enum GamePhase/GameEndReason trong data/game, Timer.periodic đếm ngược mỗi giây, và ba quy tắc sống còn khi sở hữu một Timer."
sidebar:
  label: "Bài 1 · GamePhase & Timer"
  order: 1
---

## Mục tiêu

Thay bộ bool rời rạc của M08 (`_submitted`, `_quizFinished`) bằng **enum
phase** gọn và an toàn, và thêm **đồng hồ đếm ngược** — tài nguyên đầu
tiên của course mà `State` phải chủ động quản lý vòng đời.

## Bạn đang ở đâu

- Milestone: **M09** (bài 1/4)
- App hiện tại: `GameScreen` là quiz 4 câu chơi được (M08) — chọn → chốt →
  tiếp → panel kết quả, nhưng chưa có giới hạn thời gian và chưa có
  "game over thật" (sai chỉ bị ghi nhận, ván vẫn chạy tiếp).

## Vì sao việc này quan trọng ngay bây giờ

Hai điểm yếu của M08 nổ ra khi ván game thật xuất hiện:

1. **Bool không diễn tả được phase.** Với `_submitted` + `_quizFinished`
   ta phải suy "đang ở đâu" từ tổ hợp hai bool. Khi thêm "hết giờ" và
   "dialog đang mở", tổ hợp bool nở thành ma trận lỗi. `GamePhase` enum
   nói thẳng: một biến — đúng 3 giá trị hợp lệ.
2. **Timer không nằm trong widget tree.** `Timer.periodic` sống ngoài
   build; nếu `State` chết mà quên `cancel()`, callback vẫn chạy và gọi
   `setState` trên State đã dispose → **crash**. Đây là bài học vòng đời
   quan trọng nhất khi viết game.

## Bạn đã biết gì

- `enum` (M08 — `_AnswerVisualState`), `StatefulWidget` lifecycle
  `initState`/`dispose` (M03, M06), `Stream`/subscription (M06) —
  `Timer` *không* phải Stream nhưng cùng pattern "đăng ký → phải hủy".

## Mental model mới

**Máy trạng thái phiên chơi (3 phase):**

```
        chốt đáp án              bấm TIẾP (đúng)
┌─────────────┐   ────────►   ┌─────────────┐   ────────►  ┌──────────┐
│  answering  │               │  revealing  │              │ finished │
│ đếm ngược,  │               │ hiện đúng/  │              │ dialog   │
│ chọn/chốt   │   ◄────────   │ sai, khoá   │              │ kết quả  │
└─────────────┘  câu tiếp     └─────────────┘              └──────────┘
      │                              │
      │ hết giờ                      │ TIẾP khi sai / đúng câu cuối
      └──────────────┬───────────────┘
                     ▼
               finished (dialog)
```

`answering` và `revealing` của M08 vốn đã tồn tại ngầm dưới dạng
`_submitted = false/true` — giờ chỉ là *đặt tên* cho chúng và thêm
`finished`.

**Timer = chiếc đồng hồ đếm ngược bạn phải tự tắt.** Ba quy tắc sống còn:

```
1. Hủy timer cũ TRƯỚC khi tạo timer mới  (_startTimer)
2. Hủy trong dispose()                    (rời màn hình)
3. Hủy khi rời phase answering            (chốt xong / kết thúc)
   + guard trong callback                 (an toàn kép)
```

Bỏ sót bất kỳ quy tắc nào → hai timer chạy song song, hoặc `setState`
sau `dispose`.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `Timer.periodic` | `Timer.periodic(const Duration(seconds: 1), _onTick)` | Từ `dart:async`; gọi callback mỗi chu kỳ — **không** phải Stream, không `listen` |
| `timer.cancel()` | `_timer?.cancel();` | Dừng hẳn; `?.` vì timer có thể chưa được tạo |
| `Timer?` field | `Timer? _timer;` | Nullable: "chưa có/đã hủy" là trạng thái hợp lệ |
| callback `(Timer)` | `void _onTick(Timer timer)` | Timer truyền chính nó vào callback — ít dùng, nhưng chữ ký bắt buộc |
| enum riêng file | `enum GamePhase { answering, revealing, finished }` | Đặt trong `data/game/` — state-data, không phải code UI |

## Flutter cần dùng

Không có widget mới — bài này thuần `dart:async` + lifecycle.

## Android / Compose bridge

- SIMILARITY: `Timer.periodic` ≈ `handler.postDelayed` lặp hoặc
  `viewModelScope` + `delay` trong loop; guard phase ≈ check `isActive`.
- IMPORTANT DIFFERENCE: không có `viewModelScope` tự hủy ở đây — `State`
  của widget **là** scope, và bạn tự hủy bằng `dispose()`. Compose dùng
  `LaunchedEffect`+`DisposableEffect`; Flutter cho bạn `initState`/`dispose`.
- DO NOT ASSUME: `Timer` là Stream. Không `listen`, không `await`, không
  `cancel()` subscription — API khác hẳn, chỉ cùng "triết lý phải hủy".

## Senior project connection

- `flutter-accelerator-ai/lib/data/game/game_session_state_data.dart` —
  senior định nghĩa `enum GamePhase { notStarted, playing,
  answeredPending, answeredRevealed, gameOver, victory }` — 6 phase vì có
  màn chờ, lifeline pending… Ta gộp còn 3: đủ cho ván 4 câu, vẫn là cùng
  ý tưởng *phase machine*.
- `flutter-accelerator-ai/lib/widgets/game/timer/game_countdown_timer.dart` —
  senior render đồng hồ với progress ring; timer vẫn là `Timer.periodic`
  gốc. Phiên bản learner chỉ cần `Icon + Text 'Xs'`.
- Senior dùng **30s/câu**; learner dùng **15s** — cùng cơ chế, hằng số
  nhỏ hơn để test quay nhanh (`pump(16s)` thay `pump(31s)`).

## Build it step by step

### Bước 1 — File enum mới trong `data/game/`

```dart
// lib/data/game/game_session_state.dart — FILE MỚI
/// Phase của một phiên chơi — M09 thay bộ `_submitted`/`_quizFinished`
/// rời rạc của M08 bằng enum: các phase loại trừ lẫn nhau, enum chỉ cho
/// phép đúng 3 giá trị hợp lệ.
///
/// Phiên bản rút gọn của `GamePhase` trong senior
/// (`lib/data/game/game_session_state_data.dart` có 6 phase).
enum GamePhase {
  /// Đang đếm ngược — có thể chọn và chốt đáp án.
  answering,

  /// Đã chốt — đáp án đúng/sai đang hiển thị, chờ bấm Tiếp.
  revealing,

  /// Phiên kết thúc — dialog kết quả đang mở.
  finished,
}

/// Lý do phiên chơi kết thúc — quyết định nội dung dialog kết quả.
enum GameEndReason {
  /// Chốt đáp án sai.
  wrongAnswer,

  /// Hết giờ trước khi chốt.
  timeout,

  /// Trả lời đúng câu hỏi cuối cùng.
  victory,
}
```

- `GameEndReason` là enum riêng: "kết thúc" có *nhiều lý do* — tách khỏi
  phase để dialog hỏi "vì sao" thay vì "đang ở đâu".
- Đặt ở `data/game/` (cùng chỗ `quiz_question.dart` của M08) — đây là
  *dữ liệu mô tả trạng thái*, không phải widget.

### Bước 2 — State field mới trong `_GameScreenState`

```dart
// lib/screens/game_screen.dart — trong _GameScreenState, THAY
// _submitted/_quizFinished của M08:
/// Giây cho mỗi câu hỏi — senior dùng 30s; bản learner 15s để
/// code/test/vọc nhanh hơn (cùng cơ chế, khác hằng số).
static const int secondsPerQuestion = 15;

int _questionIndex = 0;
int? _selectedIndex;
int _correctCount = 0;

/// Phase hiện tại — một enum thay cho _submitted/_quizFinished của M08.
GamePhase _phase = GamePhase.answering;

/// Lý do kết thúc — chỉ có giá trị khi `_phase == finished`.
GameEndReason? _endReason;

/// Giây còn lại của câu hiện tại; giảm 1 mỗi tick của [_timer].
int _secondsLeft = secondsPerQuestion;

/// Timer đếm ngược — một owner duy nhất là State này.
/// Quy tắc: hủy timer cũ trước khi tạo mới; hủy trong dispose;
/// hủy khi rời phase `answering`.
Timer? _timer;
```

Thêm `import 'dart:async';` đầu file (cho `Timer`) và
`import '../data/game/game_session_state.dart';`.

Lưu ý hai bool cũ của M08 (`_submitted`, `_quizFinished`) **biến mất** —
chúng được `_phase` thay thế hoàn toàn.

### Bước 3 — Vòng đời Timer

```dart
// _GameScreenState — THÊM/THAY:
@override
void initState() {
  super.initState();
  _startTimer();
}

@override
void dispose() {
  // Timer không tự hủy khi State chết — bỏ sót dòng này là timer vẫn
  // chạy ngầm và callback sẽ gọi setState trên State đã dispose (crash).
  _timer?.cancel();
  super.dispose();
}

/// (Re)start đếm ngược cho câu hiện tại. Luôn hủy timer cũ trước —
/// không bao giờ cho hai timer chạy song song.
void _startTimer() {
  _timer?.cancel();
  _secondsLeft = secondsPerQuestion;
  _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
}

void _onTick(Timer timer) {
  // Guard: chỉ đếm trong phase answering — an toàn kép sau cancel().
  if (_phase != GamePhase.answering) return;
  setState(() {
    _secondsLeft--;
  });
  if (_secondsLeft <= 0) {
    _finish(GameEndReason.timeout);
  }
}
```

- `initState` chạy timer ngay khi vào màn — câu 1 bắt đầu đếm ngay.
- `_onTick` **guard bằng phase**, không chỉ tin `cancel()`: nếu một tick
  đã được lên lịch trước khi cancel, guard chặn nó chạy tiếp. Đây là
  "defense in depth" rẻ tiền.
- `_secondsLeft--` phải nằm trong `setState` — UI đồng hồ đọc field này.
  `_finish` chưa viết — bài 2.

### Bước 4 — Đồng hồ trên UI

Trong `_QuizBody` (signature có thêm `secondsLeft`, `revealed` — bài 2
nối đủ), header `Row` thêm đồng hồ cạnh chỉ số câu:

```dart
// _QuizBody.build — trong Row đầu Column:
Row(
  children: [
    Text(
      'Câu ${questionIndex + 1}/$questionCount',
      style: const TextStyle(
        color: MenuTokens.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    ),
    const Spacer(),
    // Đồng hồ đếm ngược — đổi màu khi sắp hết giờ.
    Icon(
      Icons.timer_outlined,
      size: 16,
      color: secondsLeft <= 5
          ? MenuTokens.accentRed
          : MenuTokens.accentCyan,
    ),
    const SizedBox(width: 4),
    Text(
      '${secondsLeft}s',
      style: TextStyle(
        color: secondsLeft <= 5
            ? MenuTokens.accentRed
            : MenuTokens.accentCyan,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),
```

`Spacer` đẩy đồng hồ sang phải; `<= 5` đổi đỏ — feedback "gần hết giờ"
không cần widget mới, chỉ cần một so sánh.

## Hiểu code

- Vì sao `_secondsLeft` reset trong `_startTimer` thay vì mỗi tick? —
  "Câu mới = timer mới = đếm lại từ đầu" là một hành vi của *vòng đời
  timer*, gom hết vào chỗ tạo timer cho dễ kiểm chứng.
- `_endReason` là `GameEndReason?` — `null` suốt hai phase đầu, chỉ set
  khi `finished`. Đây là M04-quy-định: null = "chưa có", không phải lỗi.
- `Timer` giữ trong field, không trong local — vì `dispose` cần chạm tới
  nó. Field là cách `State` "sở hữu" tài nguyên.

## Chạy và quan sát

- `flutter analyze` — sạch (nếu `_finish`/`revealed` chưa nối, có thể
  thấy `unused_element` tạm — bài 2 nối đủ).
- `flutter run` → BẮT ĐẦU CHƠI → đồng hồ chạy 15→0. Để ý: hết giờ hiện
  chỉ dừng ở 0 (chưa có `_finish` — bài 2 mới kết thúc ván).

## Lỗi hay gặp

1. **Quên `_timer?.cancel()` trong `dispose`** — timer chạy ngầm sau
   khi pop về menu; quay lại menu rồi… `setState` sau dispose → crash
   (hoặc state nhiễu nếu may mắn). Đây là lỗi kinh điển nhất của
   `Timer` trong `State`.
2. **Tạo timer mới mà không hủy cũ** — hai timer đồng hồ cùng trừ
   `_secondsLeft` → đếm nhanh gấp đôi. `_startTimer` luôn `cancel()` đầu
   tiên.
3. **`_secondsLeft--` ngoài `setState`** — biến đổi nhưng UI không vẽ
   lại; đồng hồ "đứng hình".
4. **Check `<= 0` trước khi trừ** — đồng hồ hiện "-1s". Trừ trước, check
   sau, kết thúc đúng lúc số 0 vừa hiện.

## Kiểm tra hiểu biết

1. Vì sao `Timer` phải là field của `State` chứ không phải biến local
   trong `initState`? — *`dispose()` cần gọi `cancel()` trên nó; local
   mất reference ngay khi `initState` return.*
2. Guard `if (_phase != GamePhase.answering) return;` trong `_onTick`
   có thừa không nếu đã `cancel()`? — *Không thừa: tick cuối có thể đã
   được lên lịch trước lúc cancel; guard chặn nó đụng state sau khi
   phase đã chuyển.*
3. `GamePhase` và `GameEndReason` tách hai enum — gộp 4 giá trị
   (`answering, revealing, endedWrong, endedTimeout, endedVictory`)
   được không? — *Được nhưng xấu: `_endReason` lúc đó không còn nghĩa và
   "finished" mất tính chất "có lý do đi kèm". Tách cho phép phase và
   lý do biến thiên độc lập.*

## Ta cố ý chưa thêm

- Progress ring / animation cho đồng hồ — senior có, nhưng đó là
  `CustomPaint`/animation, rẽ nhánh sang M26–M27.
- Pause khi dialog mở / app backgrounded — lifecycle app (M15+).
- `TickerProvider`/`AnimationController` — `Timer` đủ cho đếm ngược rời
  rạc 1s; animation framework là chủ đề riêng.

## Checkpoint hoàn thành

- [ ] `lib/data/game/game_session_state.dart` tồn tại với 2 enum.
- [ ] `_GameScreenState` có `_phase`, `_endReason`, `_secondsLeft`,
  `_timer` — không còn `_submitted`/`_quizFinished`.
- [ ] `initState` gọi `_startTimer`; `dispose` gọi `_timer?.cancel()`.
- [ ] Đồng hồ UI hiện `Xs` và đổi đỏ khi ≤5s; `flutter analyze` sạch
  (trừ warning tạm `unused_element` chờ bài 2).
