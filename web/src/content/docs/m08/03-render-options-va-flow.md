---
title: "Bài 3 · Render danh sách & luồng tiếp"
description: "Collection-for sinh 4 ô đáp án từ model, nối select/submit/next vào UI, nút vô hiệu bằng onTap:null + Opacity, panel kết quả mini-quiz."
sidebar:
  label: "Bài 3 · Options & flow"
  order: 3
---

## Mục tiêu

Nối state của bài 2 vào UI: render `options` bằng collection-`for`, ô đáp
án bấm được và đổi màu theo trạng thái, nút CHỐT ĐÁP ÁN → TIẾP → XEM KẾT
QUẢ, và panel kết quả cuối quiz.

## Bạn đang ở đâu

- Milestone: **M08** (bài 3/4)
- App hiện tại: `GameScreen` là `StatefulWidget` với đủ handler
  (`_selectAnswer`/`_submitAnswer`/`_nextQuestion`/`_restart`) — chưa nối
  vào widget nào.

## Vì sao việc này quan trọng ngay bây giờ

Ở M07 ta viết tay 4 ô `_AnswerPlaceholder`. Với model, cách đó vỡ: số đáp
án nằm trong dữ liệu (`question.options`), UI phải *sinh ra* từ nó. Đây là
lần đầu "render một collection" — kỹ năng nền của mọi list UI.

## Bạn đã biết gì

- `Column`/`Row`/`Expanded`/`Opacity`/`GestureDetector` (M02–M03),
  `for`/`if` thường (lập trình), `List` index `options[i]` (Dart cơ bản),
  callbacks `void Function(int)` (kiểu `VoidCallback` có tham số — M03).

## Mental model mới

**Collection-`for` trong list literal: `[for (…) widget, …]`** — "với mỗi
phần tử của collection, sinh một widget con ngay trong `children`". Nó là
cú pháp của *literal*, chạy lúc build — không phải vòng lặp runtime đời
thường.

```
options = ['StatelessWidget', 'StatefulWidget', 'Scaffold', 'Container']
     │ i=0          i=1               i=2          i=3
     ▼
for (var i = 0; i < question.options.length; i++) ...[
  _AnswerOption(label: 'A'+i, text: options[i], state: _optionState(i), …),
  SizedBox(height: 8),
]
     │
     ▼ children thật: [OptionA, SizedBox, OptionB, SizedBox, …]
```

`...[` là **spread operator** (dàn một list con vào list cha) — cho phép
mỗi vòng for nhả ra *nhiều* widget (ô + khoảng cách).

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| collection-`for` | `for (var i = 0; i < n; i++) widget` | Vòng for ngay trong list literal |
| spread `...` | `for (…) ...[a, b]` | Chèn nhiều phần tử mỗi vòng lặp |
| collection-`if` | `if (submitted) widget` | Render có điều kiện trong literal |
| `String.fromCharCode` | `String.fromCharCode(65 + i)` | 65='A' → 'A','B','C','D' cho nhãn |
| callback có tham số | `void Function(int) onSelect` | Như `VoidCallback` nhưng mang index |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `onTap: null` trên `GestureDetector` | Vô hiệu nút: không gọi, không hiệu ứng |
| `Opacity` + `onTap: null` | Bộ đôi "nút tắt": vừa mờ vừa không bấm được |
| Ternary trong tham số | `submitted ? onNext : canSubmit ? onSubmit : null` — nút đổi vai trò theo state |

## Android / Compose bridge

- SIMILARITY: `for (…) widget` trong `children` ≈ `options.forEach { … }`
  trong `Column`/LazyColumn item scope.
- IMPORTANT DIFFERENCE: đây là *cú pháp collection literal* của Dart —
  không phải `map().toList()` trả về rồi truyền; nó chạy đúng lúc build.
- DO NOT ASSUME: `ListView.builder` là mặc định — với 4–5 item cố định,
  `Column` + collection-for đơn giản hơn và không cần scroll/lazy.

## Senior project connection

- `flutter-accelerator-ai/lib/widgets/game/answers/game_answer_option_list.dart`
  — senior render danh sách đáp án qua widget riêng với state từ
  ViewModel; ta render thẳng trong `Column` vì bank nhỏ.
- `lib/widgets/game/answers/game_answer_option.dart` — ô đáp án senior
  có idle/selected/correct/wrong riêng màu sắc + animation; bản learner
  chỉ đổi border/background/icon (không animation — M28).

## Build it step by step

### Bước 1 — `_QuizBody`: chỉ số câu + câu hỏi + options bằng collection-for

```dart
// lib/screens/game_screen.dart — trong build() của _GameScreenState,
// thay Column placeholder bằng widget mới:
child: _quizFinished
    ? _QuizResultPanel(
        correctCount: _correctCount,
        totalQuestions: quizQuestions.length,
        onPlayAgain: _restart,
      )
    : _QuizBody(
        question: _question,
        questionIndex: _questionIndex,
        questionCount: quizQuestions.length,
        selectedIndex: _selectedIndex,
        submitted: _submitted,
        onSelect: _selectAnswer,
        onSubmit: _submitAnswer,
        onNext: _nextQuestion,
      ),
```

```dart
// Cuối file — widget mới _QuizBody (phần Column chính):
class _QuizBody extends StatelessWidget {
  // …param y hệt 8 param ở trên (question/questionIndex/questionCount/
  // selectedIndex/submitted/onSelect/onSubmit/onNext)…

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Câu ${questionIndex + 1}/$questionCount', /* style nhỏ */),
        const SizedBox(height: MenuTokens.spacingXs),
        _QuestionCard(text: question.question),
        const SizedBox(height: MenuTokens.spacingMd),
        // Collection-for: mỗi option → _AnswerOption + SizedBox cách
        for (var i = 0; i < question.options.length; i++) ...[
          _AnswerOption(
            label: String.fromCharCode(65 + i),
            text: question.options[i],
            state: _optionState(i),
            onTap: () => onSelect(i),
          ),
          const SizedBox(height: MenuTokens.spacingXs),
        ],
        if (submitted)
          _FeedbackLine(isCorrect: question.isCorrect(selectedIndex ?? -1)),
        const Spacer(),
        _SubmitButton(
          submitted: submitted,
          canSubmit: selectedIndex != null,
          isLastQuestion: questionIndex == questionCount - 1,
          onSubmit: onSubmit,
          onNext: onNext,
        ),
      ],
    );
  }
}
```

- `for (var i = 0; …) ...[ … ]` — collection-for + spread: mỗi vòng nhả ra
  cặp `[option, spacer]`.
- `String.fromCharCode(65 + i)` — 65 là code của 'A' → nhãn A/B/C/D.
- `if (submitted) _FeedbackLine(…)` — collection-**if**: chỉ render khi
  đã chốt.
- `question.isCorrect(selectedIndex ?? -1)` — `??` fallback: chưa chọn
  (`null`) → `-1` → luôn sai/không-đúng, không crash (an toàn hơn `!`).

### Bước 2 — `_AnswerOption` theo state (enum điều khiển màu)

```dart
// lib/screens/game_screen.dart — widget mới thay _AnswerPlaceholder:
class _AnswerOption extends StatelessWidget {
  final String label;
  final String text;
  final _AnswerVisualState state;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.label,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = MenuTokens.cardBorder;
    Color background = MenuTokens.cardBackground;
    IconData icon = Icons.circle_outlined;
    Color iconColor = MenuTokens.textSecondary;
    if (state == _AnswerVisualState.selected) {
      borderColor = MenuTokens.accentCyan;
      background = const Color(0x1F00E0FF);
      icon = Icons.radio_button_checked;
      iconColor = MenuTokens.accentCyan;
    } else if (state == _AnswerVisualState.correct) {
      borderColor = MenuTokens.statGreen;
      background = const Color(0x2E89E87F);
      icon = Icons.check_circle;
      iconColor = MenuTokens.statGreen;
    } else if (state == _AnswerVisualState.wrong) {
      borderColor = MenuTokens.accentRed;
      background = const Color(0x2EFF5252);
      icon = Icons.cancel;
      iconColor = MenuTokens.accentRed;
    }

    return Opacity(
      opacity: state == _AnswerVisualState.dimmed ? 0.45 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(/* padding + BoxDecoration dùng 4 biến trên */,
          child: Row(children: [
            Text(label /* 'A'.., vàng */),
            const SizedBox(width: MenuTokens.spacingSm),
            Expanded(child: Text(text /* trắng */)),
            Icon(icon, size: 18, color: iconColor),
          ]),
        ),
      ),
    );
  }
}
```

Cần thêm `static const Color accentRed = Color(0xFFFF5252);` trong
`MenuTokens` (màu đáp án sai — tokens được dùng chung hai màn; sau này có
thể tách `GameTokens`, đổi tên khi cần).

### Bước 3 — `_SubmitButton` đổi vai trò theo state + `_FeedbackLine` + `_QuizResultPanel`

```dart
// _SubmitButton — một nút ba vai trò:
final label = !submitted ? 'CHỐT ĐÁP ÁN'
    : isLastQuestion ? 'XEM KẾT QUẢ' : 'TIẾP';
final enabled = submitted || canSubmit;
final onTap = submitted ? onNext : canSubmit ? onSubmit : null;
// render: Opacity(enabled ? 1 : 0.4) + GestureDetector(onTap) + pill gradient
```

```dart
// _FeedbackLine — 1 Text: 'Chính xác!' xanh / 'Chưa đúng…' đỏ
// _QuizResultPanel — icon cúp + 'MINI-QUIZ HOÀN TẤT' + 'Đúng X/4 câu'
//   + nút CHƠI LẠI (gradient, onTap: onPlayAgain)
```

`GestureDetector(onTap: null)` là hợp lệ: `onTap` nullable — `null` nghĩa
"không phản hồi chạm". Đây là *disabled pattern* gọn nhất trước khi học
`ElevatedButton`/`onPressed` (senior dùng button system riêng).

File hoàn chỉnh ~470 dòng — mở `lib/screens/game_screen.dart` đối chiếu
(mọi đoạn trên khớp code thật, chỉ rút gọn phần `style:` đã học ở M02).

## Hiểu code — một lượt chơi

```
tap ô 'StatefulWidget' (i=1)
  → onSelect(1) → _selectAnswer: setState(_selectedIndex = 1)
  → rebuild: ô 1 state=selected (icon radio, viền cyan)
tap CHỐT ĐÁP ÁN
  → _submitAnswer: _submitted=true, isCorrect(1)=true → _correctCount=1
  → rebuild: ô 1 = correct (xanh, check_circle); ô khác = dimmed;
    _FeedbackLine 'Chính xác!'; nút đổi thành TIẾP
tap TIẾP
  → _nextQuestion: _questionIndex=1, reset chọn/chốt
  → rebuild: 'Câu 2/4', câu hỏi + options của câu 2
… câu cuối: XEM KẾT QUẢ → _quizFinished=true → _QuizResultPanel
```

## Chạy và quan sát

- `flutter run -d chrome` → vào game:
  - Chọn đáp án → icon radio + viền cyan; nút CHỐT sáng lên.
  - Chốt đúng → ô đúng xanh, "Chính xác!", nút TIẾP.
  - Chốt sai → ô sai đỏ + ô đúng xanh + "Chưa đúng…".
  - Hết 4 câu → "Đúng X/4 câu" + CHƠI LẠI reset về câu 1.
- Nếu ô nào cũng không bấm được → check `onTap` bị `null` (nút) hoặc
  `_submitted` guard — đọc lại bước 3.

## Lỗi hay gặp

1. **Render options bằng `map().toList()`** — hoạt động nhưng rườm; Dart
   có collection-for sinh thẳng trong literal. (Không sai — chỉ chưa gọn;
   sau này `ListView.builder`/`List.generate` sẽ cần thiết cho list dài.)
2. **Quên `Expanded` cho Text đáp án dài** — overflow vàng/đen.
3. **Để `onTap: () {}` thay vì `null` cho nút tắt** — bấm "không có gì
   xảy ra" khó hiểu hơn nút tắt thật.
4. **`selectedIndex!` trong build của `_FeedbackLine`** — crash khi
   `submitted` mà `selectedIndex` lỡ null; dùng `?? -1` an toàn.

## Kiểm tra hiểu biết

1. Thêm option thứ 5 vào một câu trong bank — UI đổi gì? — *Tự render 5 ô
   + nhãn 'E' — collection-for đi theo dữ liệu, không cần sửa layout.*
2. `onTap` của nút khi `submitted=false, canSubmit=false`? — *`null` →
   nút mờ và không bấm được.*
3. Vì sao `correctIndex` vẫn hiện xanh cả khi user chọn đúng? — *`_optionState`
   ưu tiên `correctIndex` trước `selectedIndex` sau chốt — đúng luôn xanh.*

## Ta cố ý chưa thêm

- `ListView`/`ListView.builder` — bank cố định 4–5 item, `Column` đủ;
  list dài/scroll sẽ học khi cần.
- `Timer`/dialog/game-over — **M09**.
- Animation đổi màu — M28; `Opacity` tĩnh đủ rõ trạng thái.
- Tách widget ra file riêng — một file đọc được là ưu tiên M08; chia file
  khi màn hình lớn hơn (M19+).

## Checkpoint hoàn thành

- [ ] Chọn → cyan; chốt đúng → xanh + "Chính xác!"; chốt sai → đỏ+xanh.
- [ ] TIẾP qua đủ 4 câu → panel "Đúng X/4 câu"; CHƠI LẠI reset sạch.
- [ ] `flutter analyze` sạch; `flutter test` xanh (chưa cần test mới —
  widget test ở bài 4).
