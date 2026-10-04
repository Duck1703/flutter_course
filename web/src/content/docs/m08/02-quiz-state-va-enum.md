---
title: "Bài 2 · State của quiz & enum trạng thái"
description: "GameScreen thành StatefulWidget: _questionIndex/_selectedIndex/_submitted/_correctCount, enum _AnswerVisualState, và quy tắc khoá chọn sau chốt."
sidebar:
  label: "Bài 2 · Quiz state & enum"
  order: 2
---

## Mục tiêu

Chuyển `GameScreen` thành `StatefulWidget` với state lượt chơi nằm gọn
trong `State`, và dùng **enum đầu tiên của course** để mô tả trạng thái
hiển thị của từng ô đáp án.

## Bạn đang ở đâu

- Milestone: **M08** (bài 2/4)
- App hiện tại: `quizQuestions` bank đã có (bài 1); `GameScreen` là
  `StatelessWidget` render layout tĩnh.

## Vì sao việc này quan trọng ngay bây giờ

"Chọn đáp án" là *state*: cùng một ô, lúc chưa chọn là xám, lúc chọn là
cyan, lúc chốt sai là đỏ. Bốn trạng thái loại trừ lẫn nhau — viết bằng 3
biến `bool` (`_isSelected`, `_isCorrect`, `_isDimmed`) sẽ cho phép tổ hợp
vô nghĩa (`true,true,false`?). Đây là lúc `enum` tỏa sáng: **một biến, một
trong N giá trị hợp lệ**.

## Bạn đã biết gì

- `StatefulWidget`/`createState`/`setState` (M03), `int?` nullable (M04),
  `VoidCallback` + `GestureDetector` (M03), model `QuizQuestion` (bài 1).

## Mental model mới

**State màn quiz = 4 field trong `_GameScreenState`:**

```
_questionIndex : int   — đang ở câu mấy
_selectedIndex : int?  — đang chọn ô nào (null = chưa chọn)
_submitted     : bool  — đã chốt câu này chưa
_correctCount  : int   — đếm số câu đúng
_quizFinished  : bool  — đã hết câu chưa
```

Quy tắc vàng của screen-state: **mọi thứ UI cần để vẽ phải suy ra được từ
state**. Trạng thái hiển thị của ô đáp án không phải field mới — nó *suy
ra* từ `_selectedIndex` + `_submitted` + `correctIndex`:

```
chưa chốt:   index == selected → selected | else → idle
đã chốt:     index == correctIndex → correct
             index == selected    → wrong
             else                 → dimmed
```

**Enum = "một biến chỉ nhận đúng N giá trị đặt tên".** Thay cho 3 bool
rời rạc: `_AnswerVisualState { idle, selected, correct, wrong, dimmed }`.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `enum` | `enum _AnswerVisualState { idle, selected, correct, wrong, dimmed }` | Kiểu riêng chứa đúng 5 giá trị; so sánh bằng `==` |
| `int?` field | `int? _selectedIndex;` | `null` = "chưa chọn" — null safety làm *đặc điểm* state |
| `!` sau khi check | `_selectedIndex!` khi đã `!= null` | Khẳng định non-null — hợp lệ vì vừa kiểm tra |
| getter | `QuizQuestion get _question => quizQuestions[_questionIndex]` | Cú pháp M04 — câu hỏi hiện tại |
| `get` boolean | `bool get _isLastQuestion => _questionIndex == quizQuestions.length - 1` | Thuộc tính suy ra, không lưu |

## Flutter cần dùng

Không có widget mới — bài này thuần state + enum.

## Android / Compose bridge

- SIMILARITY: enum UI-state ≈ enum/sealed trong Compose state; `_selectedIndex`
  `int?` ≈ `var selected by remember { mutableStateOf<Int?>(null) }`.
- IMPORTANT DIFFERENCE: Dart enum ở đây chỉ là tập giá trị có tên — sealed
  class (enum có payload, như `GameDialogState` của senior) là chuyện M15+;
  đừng nhảy tới.
- DO NOT ASSUME: null = "lỗi". Ở đây `null` là *trạng thái hợp lệ*
  ("chưa chọn") — đúng tinh thần M04.

## Senior project connection

- `flutter-accelerator-ai/lib/data/game/game_session_state_data.dart` —
  `enum GamePhase { notStarted, playing, answeredPending,
  answeredRevealed, gameOver, victory }`: senior cũng mô hình hoá game
  bằng enum — chi tiết hơn (6 phase), ta mới cần 5 trạng thái *hiển thị*
  ô đáp án. `GamePhase` phiên bản learner sẽ xuất hiện ở M09.
- `flutter-accelerator-ai/lib/widgets/game/answers/game_answer_option.dart`
  + `game_answer_option_colors.dart` — ô đáp án senior cũng có state
  selected/correct/wrong với màu riêng; cùng ý tưởng, nhiều layer hơn.

## Build it step by step

### Bước 1 — `GameScreen` → `StatefulWidget` (y hệt cú pháp M03)

```dart
// lib/screens/game_screen.dart — THAY class GameScreen
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _questionIndex = 0;
  int? _selectedIndex;
  bool _submitted = false;
  bool _quizFinished = false;
  int _correctCount = 0;

  QuizQuestion get _question => quizQuestions[_questionIndex];
  bool get _isLastQuestion => _questionIndex == quizQuestions.length - 1;
}
```

Thêm imports đầu file:

```dart
import '../data/game/quiz_question.dart';
import '../data/game/quiz_questions.dart';
```

- `int? _selectedIndex` — nullable: `null` mang nghĩa "chưa chọn" (dùng
  null safety đúng bản chất, M04).
- `_question`, `_isLastQuestion` — getter suy ra; không lưu trùng.

### Bước 2 — Ba handler: chọn / chốt / tiếp / chơi lại

```dart
// _GameScreenState — THÊM:
void _selectAnswer(int index) {
  if (_submitted) return;            // đã chốt → khoá, không đổi được
  setState(() => _selectedIndex = index);
}

void _submitAnswer() {
  if (_selectedIndex == null || _submitted) return;
  setState(() {
    _submitted = true;
    if (_question.isCorrect(_selectedIndex!)) _correctCount++;
  });
}

void _nextQuestion() {
  setState(() {
    if (_isLastQuestion) {
      _quizFinished = true;
    } else {
      _questionIndex++;
      _selectedIndex = null;         // reset cho câu mới
      _submitted = false;
    }
  });
}

void _restart() {
  setState(() {
    _questionIndex = 0;
    _selectedIndex = null;
    _submitted = false;
    _quizFinished = false;
    _correctCount = 0;
  });
}
```

- `if (_submitted) return` trong `_selectAnswer` — "khoá sau chốt" là một
  **guard clause** ở đầu hàm; không thay đổi state ngoài `setState`.
- `_selectedIndex!` — `!` hợp lệ duy nhất của file: đã check `== null`
  return ngay trước đó.

### Bước 3 — Enum trạng thái ô đáp án

```dart
// lib/screens/game_screen.dart — THÊM ở cuối file (top-level, private):
/// Trạng thái hiển thị của một ô đáp án — 5 giá trị loại trừ lẫn nhau.
enum _AnswerVisualState { idle, selected, correct, wrong, dimmed }
```

Và trong `_QuizBody` (phần render — bài 3 làm đủ), một method suy state:

```dart
// trong _QuizBody:
_AnswerVisualState _optionState(int index) {
  if (!submitted) {
    return index == selectedIndex
        ? _AnswerVisualState.selected
        : _AnswerVisualState.idle;
  }
  if (index == question.correctIndex) return _AnswerVisualState.correct;
  if (index == selectedIndex) return _AnswerVisualState.wrong;
  return _AnswerVisualState.dimmed;
}
```

Mọi quyết định màu sắc gom **một chỗ** — widget con chỉ "vẽ theo state".

## Hiểu code

- `_submitted` còn đóng vai trò "phase đơn giản" (đang trả lời / đã chốt).
  M09 sẽ thay bộ bool này bằng `enum GamePhase` khi phase tăng lên
  (reveal, finished) — đó là lúc enum-cho-phase xứng đáng.
- Tại sao `_correctCount` là field chứ không tính lại? — Vì sau khi sang
  câu mới, thông tin "câu trước đúng" biến mất khỏi state; cộng dồn lúc
  chốt là lưu kết quả tối giản.

## Chạy và quan sát

- `flutter analyze` — sạch (handler chưa được nối → không warning nếu đặt
  tên `_` đúng… thật ra method private chưa gọi sẽ **không** báo lỗi nhưng
  analyzer `unused_element` có thể cảnh báo — bài 3 nối UI ngay sau; nếu
  thấy warning `unused_element` tạm thời, nó biến mất ở bài 3).
- `flutter run` → vào game → vẫn layout tĩnh (chưa nối handler).

## Lỗi hay gặp

1. **`_selectAnswer` không guard `_submitted`** — sau chốt vẫn đổi được
   chọn → màu loạn. Guard clause đầu hàm.
2. **Quên reset `_selectedIndex`/`_submitted` khi qua câu** — câu 2 hiện
   sẵn feedback câu 1.
3. **Dùng nhiều bool thay enum** — 5 trạng thái ô đáp án cần ~3 bool →
   8 tổ hợp trong đó có tổ hợp vô nghĩa; enum chỉ cho 5 hợp lệ.
4. **`_selectedIndex!` không check null** — crash `Null check operator`.
   Chỉ `!` ngay sau guard `== null → return`.

## Kiểm tra hiểu biết

1. Vì sao `_selectedIndex` là `int?` chứ không `int = -1`? — *`null` là
   giá trị "chưa chọn" có nghĩa; `-1` là số ngụy trang, null-safety được
   sinh ra để tránh kiểu đó.*
2. `_submitted == true` mà tap đáp án khác thì sao? — *Không gì: guard
   return sớm, `setState` không chạy.*
3. Tại sao `_question` là getter chứ không phải field? — *Vì nó suy ra từ
   `_questionIndex`; field riêng sẽ phải đồng bộ tay → dễ lệch.*

## Ta cố ý chưa thêm

- `GamePhase` enum cho toàn phiên — **M09** (khi phase > 2: answering /
  revealing / finished).
- Timer countdown — **M09**; Dialog kết quả — **M09**.
- ViewModel/ChangeNotifier tách state — M11+ (bây giờ tách sẽ không hiểu
  nỗi đau nó giải quyết).

## Checkpoint hoàn thành

- [ ] `GameScreen` là `StatefulWidget` với 5 field state + 2 getter.
- [ ] `_optionState` trả đúng 5 trạng thái theo `submitted`/selection.
- [ ] `_AnswerVisualState` enum tồn tại; `flutter analyze` sạch.
