---
title: "Bài 3 · Mapper thuần: state → GameScreenData"
description: "Presentation mapper: buildGameScreenPresentation suy GameScreenData từ session state + bank câu hỏi. Màu đáp án là hàm của phase — widget chỉ render, không tự suy."
sidebar:
  label: "Bài 3 · presentation mapper"
  order: 3
---

## Mục tiêu

- Hiểu `GameScreenData` là **DTO chỉ-đọc cho UI** — mọi thứ widget
  cần, không thừa không thiếu, đã format sẵn.
- Viết được `buildGameScreenPresentation` — hàm *thuần*
  (input → output, không side effect, không nhớ gì).
- Test mapper trực tiếp bằng unit test — không cần pump widget.

## Bạn đang ở đâu

- Bài 2: `GameSessionState`, question model, thang tiền đã có;
  `game_screen.dart` đang là stub.
- Cuối bài này: `flutter test` = **99/99** (+4 test mapper).

## Vì sao việc này quan trọng ngay bây giờ

Hỏi: ô đáp án A hiển thị màu gì? Câu trả lời "tuỳ" — tuỳ phase
(`pending`/`revealed`), tuỳ `selectedAnswer`, tuỳ `correctOption`.
Nếu widget tự ghép ba thứ đó → logic hiển thị rải trong `build()` và
không test được mà không dựng cả màn. Senior tách ra thành một hàm
mapper thuần: *bất cứ ai* muốn biết ô A màu gì đều gọi cùng một
hàm — widget render `data.answers[i].state`, test assert thẳng trên
`GameScreenData`.

## Bạn đã biết gì

- `GameSessionState`/`GamePhase`/`GameDialogState` (Bài 2).
- `String.fromCharCode`/`List.generate`/`clamp`.
- Unit test `flutter_test` cơ bản (mọi milestone trước).

## Dựng từng phần

### Bước 1 — `GameScreenData`: DTO của toàn màn

`lib/data/game/game_screen_data.dart` — bốn khối khớp bốn vùng UI
(top bar tiền, câu hỏi, lưới đáp án, đồng hồ):

```dart
enum GameAnswerState { idle, selected, correct, incorrect }

class GameMoneyData {
  final String amount;          // đã format: '$20,000'
  final int animationTrigger;   // key phát lại animation khi đổi
}

class GameQuestionData {
  final String questionText;
  final int currentQuestionIndex;
  final int totalQuestions;
  final String category;
  final String difficulty;
  int get displayQuestionNumber => currentQuestionIndex + 1;
}

class GameAnswerOptionData {
  final String answerLabel;  // 'A'..'D'
  final String answerText;
  final GameAnswerState state;
}

class GameTimerData {
  final Duration totalTime;
  final Duration remainingTime;

  double get progress {
    final total = totalTime.inMilliseconds;
    if (total <= 0) return 0;
    return (remainingTime.inMilliseconds / total).clamp(0, 1).toDouble();
  }

  String get formattedTime {
    // clamp trước, rồi pad 2 chữ số: '00:07'
    final maxSeconds = totalTime.inSeconds;
    final rem = remainingTime.inSeconds;
    final safe = rem < 0 ? 0 : (rem > maxSeconds ? maxSeconds : rem);
    return '${(safe ~/ 60).toString().padLeft(2, '0')}:'
        '${(safe % 60).toString().padLeft(2, '0')}';
  }
}

class GameScreenData {
  final GameMoneyData money;
  final GameQuestionData question;
  final List<GameAnswerOptionData> answers;
  final GameTimerData timer;
}
```

Ba quyết định thiết kế đáng để ý:

- **`amount` là String đã format**, không phải `int` — UI không được
  tự format tiền (format là *quyết định hiển thị*, thuộc mapper).
- **`animationTrigger` là `int` tăng dần**, không phải `bool
  animate` — UI dùng nó làm `ValueKey` để animation chơi lại mỗi
  khi số đổi (senior pattern; widget trigger-side ở Bài 5).
- **`formattedTime`/`progress` là getter trên DTO** — logic format
  `mm:ss` và clamp vẫn nằm ở data, không tràn vào widget.

### Bước 2 — `formatGameMoney` + mapper thang tiền

`lib/view_models/game/support/game_money_formatter.dart` — tiện ích
nhỏ format `$20,000` (dấu phẩy ngăn nghìn, senior parity).

`lib/view_models/game/support/game_money_ladder_mapper.dart` — hai
hàm senior verbatim (file cần `import 'dart:math' as math` cho
`math.max`):

```dart
/// Trước mốc an toàn đầu → thoát trắng tay; sau đó lấy
/// max(guaranteed, moneyEarned).
int calculateGameWalkAwayAmount({
  required int guaranteedAmount,
  required int moneyEarned,
}) {
  return guaranteedAmount > 0 ? math.max(guaranteedAmount, moneyEarned) : 0;
}

/// 15 hàng cho dialog thang tiền — đảo thứ tự (giải lớn trên cùng),
/// đánh dấu level hiện tại + mốc an toàn.
List<GameMoneyLadderItemData> buildGameMoneyLadderItems({
  required int currentQuestionIndex,
}) {
  final currentLevel = currentQuestionIndex + 1;
  return gameMoneyLadderLevels.reversed.map((level) {
    return GameMoneyLadderItemData(
      index: level.level,
      amount: formatGameMoney(level.amount),
      isCurrent: level.level == currentLevel,
      isSpecial: level.isSafeHaven,
    );
  }).toList(growable: false);
}
```

`calculateGameWalkAwayAmount` dễ viết sai — **không** phải
`max(0, moneyEarned − guaranteed)`: luật senior là trước mốc an
toàn đầu tiên (chưa qua Q5) thì dừng = 0 đồng, sau đó mới lấy max.
VM Bài 4 dùng hàm này cho `GameConfirmExitDialog.guaranteedAmount`…
đúng hơn là cho số tiền "chắc chắn giữ lại nếu thoát".

### Bước 3 — `buildGameScreenPresentation`

`lib/view_models/game/game_screen_presentation_mapper.dart` — hàm
trung tâm:

```dart
GameScreenData buildGameScreenPresentation({
  required List<GameQuizQuestionData> questions,
  required int questionIndex,
  required int moneyEarned,
  required int moneyAnimationTrigger,
  required Duration totalTime,
  required Duration remainingTime,
  required GamePhase phase,
  required String? selectedAnswer,
}) {
  final question = questions[questionIndex];
  return GameScreenData(
    money: GameMoneyData(
      amount: formatGameMoney(moneyEarned),
      animationTrigger: moneyAnimationTrigger,
    ),
    question: GameQuestionData(
      questionText: question.question,
      currentQuestionIndex: questionIndex,
      totalQuestions: questions.length,
      category: question.category,
      difficulty: question.difficulty.displayName,
    ),
    answers: _buildAnswers(question: question, phase: phase,
        selectedAnswer: selectedAnswer),
    timer: GameTimerData(totalTime: totalTime, remainingTime: remainingTime),
  );
}
```

Và trái tim của nó — màu đáp án là **hàm của phase**:

```dart
GameAnswerState _answerState({...}) {
  if (phase == GamePhase.answeredPending) {
    return optionText == selectedAnswer
        ? GameAnswerState.selected
        : GameAnswerState.idle;
  }
  if (phase == GamePhase.answeredRevealed) {
    if (optionText == correctOption)  return GameAnswerState.correct;
    if (optionText == selectedAnswer) return GameAnswerState.incorrect;
    return GameAnswerState.idle;
  }
  return GameAnswerState.idle; // mọi phase khác
}
```

Đọc chậm: `answeredPending` chỉ tô màu ô *đã chọn* (chờ chấm);
`answeredRevealed` mới lộ đáp án đúng (xanh) + ô sai đã chọn (đỏ);
phase `playing`/`notStarted`/kết thúc → tất cả `idle`. Không có
boolean "isSelected"/"isCorrect" nào trong widget — toàn bộ *suy ra*.

Lưu ý input của hàm: nó nhận **field riêng lẻ**, không nhận
`GameSessionState` — caller (VM, Bài 4) unpack state trước khi gọi.
Đó là lựa chọn của senior: mapper giữ chữ ký phẳng, dễ test.

### Bước 4 — Test mapper trực tiếp

`test/game_screen_presentation_mapper_test.dart` — 4 test, không
pump widget:

```dart
const question = GameQuizQuestionData(
  id: 1, question: 'Q?', options: ['A','B','C','D'],
  correctOption: 'B', category: 'Flutter', language: 'vi',
  difficulty: GameQuestionDifficulty.medium,
  explanation: GameQuestionExplanationData(
    explainForTrueAnswer: 't', explainForWrongAnswers: {},
    aiHintMessage: 'h'),
);

test('answeredRevealed: đúng xanh, chọn sai đỏ, còn lại idle', () {
  final data = build(phase: GamePhase.answeredRevealed,
      selectedAnswer: 'A'); // sai — đúng là 'B'
  expect(data.answers[1].state, GameAnswerState.correct);
  expect(data.answers[0].state, GameAnswerState.incorrect);
  expect(data.answers[2].state, GameAnswerState.idle);
});
```

Đây là điểm kiến trúc trả hứng: *toàn bộ* luật màu đáp án test được
bằng hàm thuần — không widget, không VM, không giờ giấc. Bốn test
bao phủ: `playing` → mọi ô idle + counter/meta; `answeredPending` →
chỉ ô chọn là selected; `answeredRevealed` → xanh/đỏ/idle; timer →
`formattedTime` `mm:ss` + `progress` clamp ≤ 1 + format tiền.

## Android / Compose bridge

- **SIMILARITY:** đúng vai trò "UiState mapper" — ViewModel emit
  state domain, một bước map sang state hiển thị trước khi UI
  consume.
- **IMPORTANT DIFFERENCE:** ở Compose mapper hay là extension trên
  state (`state.toUi()`); senior chọn *top-level function* nhận
  field lẻ — không method trên `GameSessionState`.
- **DO NOT ASSUME:** "mapper" ở đây không phải JSON/entity mapper
  (M05) — nó map *state* → *DTO hiển thị*, cùng process, không
  serialize gì.

## Senior project connection

- `lib/view_models/game/game_screen_presentation_mapper.dart`
  (senior) — bản gốc; learner giữ chữ ký trừ `visibleOptionTexts`/
  `audiencePercentiles`/`usedFeatureButtons`/`canWalkAway` (M20).
- `lib/data/game/game_screen_data.dart` (senior) — learner thiếu
  đúng 2 thứ: `GameAnswerOptionData.audiencePercentile` và
  `GameScreenData.featureButtons` — cả hai đều của thanh lifeline
  M20.
- `lib/view_models/game/support/game_money_ladder_mapper.dart` +
  `game_money_formatter.dart` (senior) — port verbatim.

## Chạy và quan sát

```bash
flutter analyze  # sạch
flutter test     # 99/99 — +4 mapper test
```

Không có gì trên màn hình mới — stub vẫn là stub. "Đầu ra" của bài
là bốn test xanh chứng minh mapper đúng.

## Kiểm tra hiểu biết

1. Vì sao `GameMoneyData.amount` là `String` thay vì `int`?
   → Format là quyết định hiển thị; giữ `int` sẽ đẩy format xuống
   widget (và mỗi widget format một kiểu).
2. `answeredPending` khác `answeredRevealed` ở màu sắc thế nào?
   → Pending: chỉ ô chọn → `selected`, không lộ đáp án. Revealed:
   ô đúng → `correct`, ô chọn-sai → `incorrect`.
3. Vì sao mapper nhận field lẻ chứ không nhận `GameSessionState`?
   → Senior parity + chữ ký phẳng dễ test; VM unpack khi gọi.
4. `GameScreenData` có nên chứa `phase` không?
   → Không — DTO chỉ chứa thứ UI *render*; phase là state domain,
   đã được "tiêu hóa" thành `answer.state` rồi.

## Sai lầm thường gặp

- **Truyền `phase` vào widget** để widget tự suy màu — phá vỡ toàn
  bộ mục đích của mapper.
- **Quên `clamp`** trong `progress` — `remaining > total` (vừa reset
  câu mới) sẽ trả > 1 và vỡ `LinearProgressIndicator`.
- **`String.fromCharCode(65 + index)`** hardcode 'A' — chấp nhận
  được cho 4 option (senior làm thế), nhưng phải nhận ra giới hạn.

## Ta cố ý chưa thêm

- `visibleOptionTexts`/`audiencePercentiles`/`usedFeatureButtons`/
  `canWalkAway` trong chữ ký mapper — M20 mở rộng.
- `featureButtons` trong `GameScreenData` — M20.
- `GameResult` trong DTO — DTO chỉ phục vụ render, result là
  transport khác.

## Checkpoint hoàn thành

- [ ] `lib/data/game/game_screen_data.dart` + `game_screen_presentation_mapper.dart`
  + `support/game_money_ladder_mapper.dart` + `support/game_money_formatter.dart` tồn tại.
- [ ] `test/game_screen_presentation_mapper_test.dart` — 4 test.
- [ ] `flutter analyze` sạch, `flutter test` = **99/99**.
- [ ] Giải thích được: vì sao widget không cần biết `phase`?
