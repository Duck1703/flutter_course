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

## Ví dụ độc lập — `Timer.periodic` trong DartPad

Trước khi gắn timer vào game, xem nó trần (pure Dart, `dart:async`):

```dart
import 'dart:async';

void main() {
  var remaining = 3;
  final timer = Timer.periodic(const Duration(seconds: 1), (t) {
    print(remaining);
    remaining--;
    if (remaining == 0) {
      print('GO!');
      t.cancel(); // callback nhận chính timer → tự tắt được
    }
  });
  print('main xong — timer vẫn sống');
}
```

Output:

```
main xong — timer vẫn sống
3
2
1
GO!
```

Ba điều cần thấy:

- `Timer.periodic` trả một object `Timer` — giữ nó (biến `timer`) vì
  chỉ qua nó mới `cancel()` được. Nó **không phải Stream**: không
  `listen`, không `await`, không `StreamSubscription`.
- `main` kết thúc không giết timer — callback cứ chạy theo nhịp cho tới
  khi `t.cancel()`. Đây chính là "chiếc đồng hồ bạn phải tự tắt".
- Callback nhận tham số `(Timer t)` — chính timer đó, nên trong callback
  vẫn `cancel()` được. (Biến `timer` ở ví dụ này chỉ giữ để bạn thấy
  kiểu trả về; app thật sẽ giữ nó trong field `_timer` của `State`.)

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
| --------- | ------- | ------- |
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

## Tự làm (PREDICT)

Ba quy tắc sống còn của timer — giờ **phá từng cái một** trên giấy và
dự đoán triệu chứng *nhìn thấy được*:

| Phá quy tắc | Dự đoán triệu chứng trên UI/console |
| --- | --- |
| 1. Không `cancel` timer cũ trong `_startTimer` (chuyển câu tạo timer mới) | ? |
| 2. Không `cancel` trong `dispose` (back về menu giữa đếm ngược) | ? |
| 3. Không guard `_phase != answering` trong `_onTick` | ? |

Viết dự đoán cho từng dòng trước. Sau đó chọn **một** dòng để kiểm
chứng thật trong app (dễ nhất: bỏ guard `_onTick`, chốt đáp án ở giây
cuối), quan sát, rồi sửa lại.

:::note[Gợi ý]
Quy tắc 1: hai `Timer.periodic` cùng gọi `_secondsLeft--` — mỗi giây
mất mấy đơn vị? Quy tắc 2: callback của timer chạy `setState` — `State`
đã dispose thì sao? Quy tắc 3: timer chạy đúng lúc vừa chốt xong —
`_onTick` sẽ làm gì ở phase `revealing`?
:::

<details><summary>Đáp án</summary>

1. **Hai timer song song:** mỗi giây `_secondsLeft` giảm 2 (hoặc nhiều
   hơn sau vài câu) — đồng hồ "chạy nhanh" bất thường, và hết giờ sớm
   gấp đôi. Triệu chứng đặc trưng: đếm lùi nhảy 2 số một lần.
2. **`setState() called after dispose()`:** back về menu mà timer còn
   sống → callback tiếp tục gọi `setState` trên `State` đã chết → lỗi
   trong console (và leak: State không được giải phóng).
3. **Double-finish / giảm lố:** `_onTick` chạy ở phase `revealing` vẫn
   trừ giây — và khi chạm 0 sẽ kích đường "hết giờ" *lần nữa*, gọi
   logic kết thúc một lần nữa (dialog trùng / phase nhảy sai). Guard
   là *an toàn kép* vì `cancel` và "tick đã lên lịch" có thể xảy ra
   cùng một frame.

Mẫu chung: lỗi timer không báo lúc compile — nó biểu hiện bằng *triệu
chứng thời gian* (nhanh bất thường, crash muộn, dialog trùng). Vì vậy
ba quy tắc là checklist, không phải gợi ý.

</details>

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

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m09/01 — "GamePhase & Timer đếm ngược".

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này thay bool M08 bằng enum phase + thêm Timer — `_finish`/dialog chưa nối (bài sau; `unused_element` tạm thời chấp nhận).

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/game/game_session_state.dart` tồn tại (STRICT path): `enum GamePhase { answering, revealing, finished }` + `enum GameEndReason { wrongAnswer, timeout, victory }` — 2 enum, đúng số giá trị (STRICT).
- Trong `_GameScreenState`: `static const int secondsPerQuestion = 15` (STRICT 15s — bài chọn 15 thay 30); field mới `GamePhase _phase = GamePhase.answering`, `GameEndReason? _endReason`, `int _secondsLeft = secondsPerQuestion`, `Timer? _timer` (STRICT); **không còn `_submitted`/`_quizFinished`** — chúng bị `_phase` thay thế hoàn toàn; `import 'dart:async'` + import enum file có mặt.
- `initState` gọi `_startTimer()`; `dispose` gọi `_timer?.cancel()` trước `super.dispose()` (STRICT — ba quy tắc sống còn của Timer).
- `_startTimer()`: `_timer?.cancel()` đầu tiên → `_secondsLeft = secondsPerQuestion` → `_timer = Timer.periodic(const Duration(seconds: 1), _onTick)` (STRICT luôn hủy cũ trước tạo mới).
- `_onTick(Timer)`: guard `if (_phase != GamePhase.answering) return;` → `setState(() => _secondsLeft--)` → `if (_secondsLeft <= 0) _finish(GameEndReason.timeout)` (STRICT thứ tự: guard → trừ trong setState → check ≤0 sau; `_finish` có thể là stub bài này).
- `_QuizBody` nhận thêm `secondsLeft`; header Row có `Icons.timer_outlined` + `'${secondsLeft}s'` đổi `accentRed` khi ≤5 (semantic: có đồng hồ UI đổi màu).
- `flutter analyze` → "No issues found!" (trừ `unused_element` tạm); chạy: đồng hồ đếm 15→0 (chưa có dialog — đúng).

INVARIANTS NỀN:
- Quiz chơi được M08: `quizQuestions`, `_questionIndex/_selectedIndex/_correctCount`, `_QuizBody`/options/enum `_AnswerVisualState`; route M07; menu + async M05–M06 nguyên vẹn.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (đã có dialog kết quả/reducer/VM) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m09/01
PROJECT_ALIGNMENT: ON_TRACK | NEEDS_FIX | DIVERGED | BLOCKED
COURSE_POSITION: ON_TRACK | BEHIND | AHEAD_COMPATIBLE | AHEAD_RISKY
READY_FOR_NEXT_LESSON: YES | YES_AFTER_FIXES | NO
VERIFICATION_PERFORMED:
WHAT_MATCHES:
GAPS:
AHEAD_OF_COURSE:
DIVERGENCES:
REQUIRED_FIXES_BEFORE_CONTINUING:
EVIDENCE: file/symbol → observation
FILES_MODIFIED_BY_REVIEW: NONE
```
