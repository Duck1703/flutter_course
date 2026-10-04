---
title: "Bài 4 · GameScreenViewModel — trái tim máy trạng thái"
description: "CORE của M19: VM sở hữu Timer.periodic 30s, mọi transition 6 phase đi qua method-dispatch có guard, delay reveal/giải thích bảo vệ bằng flowToken, dismissDialog routing theo variant. +VM test → 116/116."
sidebar:
  label: "Bài 4 · GameScreenViewModel"
  order: 4
---

## Mục tiêu

- Viết được `GameScreenViewModel extends ChangeNotifier` — sở hữu
  `GameSessionState` duy nhất, đổi qua `copyWith` + `notifyListeners`.
- Sở hữu `Timer.periodic` trong VM: start khi `playing`, stop khi
  ra khỏi, cancel trong `dispose` — và hiểu vì sao nó không thể ở
  widget.
- Hiểu `flowToken`: token đơn điệu tăng vô hiệu hóa mọi
  `Future.delayed` callback cũ — không cần hủy từng future.
- Test VM không cần widget: `fakeAsync` lái timer và delay.

## Bạn đang ở đâu

- Bài 2–3: state machine data + mapper đã sẵn; `GameScreen` vẫn stub.
- Cuối bài này: `flutter test` = **116/116** (+17 test VM).

## Vì sao việc này quan trọng ngay bây giờ

Đây là "kiến trúc trung gian senior-style" mà roadmap chọn: senior
dùng `GameScreenViewModel extends DreChangeNotifier` + `GameReducer`
thuần, nhưng DRE có milestone riêng (M26). M19 giữ **cùng shape** —
một object state bất biến, transition có guard, timer/delay/event
trong VM — với `ChangeNotifier` quen thuộc từ M11. Sau bài này bạn
sẽ đọc được code senior M26 mà không học lại từ đầu, vì khác biệt
duy nhất là *ai viết transition* (method VM bây giờ → reducer sau).

## Bạn đã biết gì

- `ChangeNotifier` + `notifyListeners` + `dispose` (M11).
- `StreamController.broadcast` cho event một-lần (M13/M15).
- `Timer.periodic` (đã gặp ở timer cũ của game — M09) +
  `Future.delayed`/`unawaited` (M05/M06 async).
- `copyWith` + `clear*` (Bài 2); mapper `buildGameScreenPresentation`
  (Bài 3).

## Dart cần dùng

| API | Vai trò trong VM |
|-----|------------------|
| `Timer.periodic(d, cb)` / `timer.cancel()` | đồng hồ đếm ngược; "pause" = cancel |
| `Future.delayed(d, cb)` + `unawaited` | delay reveal/giải thích — không hủy được, dùng `flowToken` vô hiệu |
| `StreamController.broadcast` | `uiEvents` — listener mới không replay |
| `Duration` số học (`-`, `>`, `.zero`) | `remainingTime` trong state |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `ChangeNotifier` + `notifyListeners` | skeleton của VM — state đổi → báo UI |
| `dispose()` override | nơi cancel timer + đóng stream |

## Ví dụ độc lập — `Timer` trong một VM tối thiểu

Trước khi đụng VM thật, cầm đồng hồ 20 dòng chạy được trong DartPad
(dùng `dart:async` — không cần Flutter):

```dart
import 'dart:async';

class MiniTimer {
  Timer? _timer;
  int secondsLeft = 10;

  void start() {
    _timer?.cancel(); // chống 2 timer chồng nhau
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      secondsLeft--;
      if (secondsLeft <= 0) _timer?.cancel();
    });
  }

  void pause() => _timer?.cancel(); // "pause" = cancel, giữ secondsLeft
  void dispose() => _timer?.cancel();
}
```

Ba quy tắc y hệt `GameScreenViewModel` dùng: `cancel` trước khi tạo
timer mới (không bao giờ hai timer chồng); pause chỉ là cancel —
*state sống ngoài timer* nên resume đếm tiếp từ `secondsLeft`;
`dispose` phải cancel hay timer leak chạy ngầm mãi.

## Thử nghiệm — làm `flowToken` hỏng

Muốn *thấy* `flowToken` cứu cái gì: trong `_schedule`, bỏ check
`token != _state.flowToken`. Sau đó trong test: `startedVm` →
`submitAnswer` (token 1 được lên lịch) → `playAgain()` ngay →
`dismissDialog` (intro mới → `playing`) → `submitAnswer` lần hai
(token 2, phiên mới đã quay lại `answeredPending`) →
`async.elapse(1500ms)`. Không có token check, callback *ván cũ*
đến hạn trước và chạy trong ván mới: nó vượt qua phase guard (vì
phiên mới cũng đang `answeredPending`) và chấm điểm với
`selectedAnswer` của ván 2 — reveal lỗi thời "đánh cắp" lượt chấm;
reveal thật của ván mới đến sau lại bị phase-guard chặn vì state đã
qua `answeredRevealed`.

Cần chuỗi re-entry vì `_onRevealElapsed` còn một guard thứ hai
(`phase != answeredPending → return`): nếu ván mới vẫn `notStarted`,
callback cũ bị phase-guard chặn — token check là lớp phòng thủ khi
hai phiên trùng phase.

Đặt lại check → chạy lại → callback ván cũ bị vô hiệu.


## Dựng từng phần

### Bước 1 — Khung: một state, một stream event, một timer

`lib/view_models/game/game_screen_view_model.dart`:

File cần `import 'dart:async'` (cho `Timer`, `StreamController`,
`unawaited`) + `import 'package:flutter/foundation.dart'` (cho
`ChangeNotifier`):

```dart
class GameScreenViewModel extends ChangeNotifier {
  static const timePerQuestion = Duration(seconds: 30);
  static const _answerRevealDelay = Duration(milliseconds: 1500);
  static const _explanationDelay = Duration(milliseconds: 1000);

  /// Test truyền bank mini được — senior inject qua ctor.
  final List<GameQuizQuestionData> questions;

  final StreamController<GameScreenUiEvent> _events =
      StreamController<GameScreenUiEvent>.broadcast();

  Timer? _timer;
  var _isDisposed = false;
  GameSessionState _state;

  GameScreenViewModel({this.questions = gameSampleQuestions})
    : _state = GameSessionState.initial(timePerQuestion: timePerQuestion);
```

Ba cơ chế nền — `screenData`, `uiEvents`, `_emit`:

```dart
  /// DTO chỉ-đọc — rebuild mỗi notifyListeners qua mapper thuần.
  GameScreenData get screenData => buildGameScreenPresentation(
    questions: questions,
    questionIndex: _state.questionIndex,
    moneyEarned: _state.moneyEarned,
    moneyAnimationTrigger: _state.moneyAnimationTrigger,
    totalTime: timePerQuestion,
    remainingTime: _state.remainingTime,
    phase: _state.phase,
    selectedAnswer: _state.selectedAnswer,
  );

  Stream<GameScreenUiEvent> get uiEvents => _events.stream;
  GameDialogState get dialogState => _state.dialogState;

  void _emit(GameSessionState next) {
    _state = next;
    notifyListeners();
  }
```

Nhận ra hai đường "ra" khác nhau của VM: **state** (`_emit` →
`notifyListeners` → widget rebuild, `context.watch`) và **event**
(`_emitEvent` → stream → widget chạy một lần: `showDialog`, `pop`).
Bài 5 sẽ nối cả hai vào `GameScreen`.

### Bước 2 — Public API = "ý định UI" có guard

Mọi method public là một *dispatch*: "UI muốn X" → VM quyết định có
cho X xảy ra không, bằng guard trên `phase`/`dialogState`:

```dart
  /// Chọn = nộp (senior không có nút submit riêng).
  void submitAnswer(GameAnswerOptionData answer) {
    if (_state.phase != GamePhase.playing || answer.answerText.isEmpty) {
      return;
    }
    _stopTimer();
    final token = _state.flowToken + 1;
    _emit(_state.copyWith(
      phase: GamePhase.answeredPending,
      selectedAnswer: answer.answerText,
      flowToken: token,
    ));
    _schedule(_answerRevealDelay, token, _onRevealElapsed);
  }
```

Đọc mẫu chung: **guard → dừng timer → emit state mới (kèm token
mới) → lên lịch bước kế**. `showMoneyLadder`/`showConfirmExit` cùng
mẫu — guard `phase != playing → return`, stop timer, emit
`dialogState` mới, bắn `GameDialogRequested`:

```dart
  void showConfirmExit() {
    if (_state.phase != GamePhase.playing) return;
    _stopTimer();
    _emit(_state.copyWith(
      dialogState: GameConfirmExitDialog(
        guaranteedAmount: formatGameMoney(_walkAwayAmount(_state)),
      ),
    ));
    _emitEvent(const GameDialogRequested());
  }
```

`startNewGame` cũng thế — nhưng chú ý một chi tiết đã làm Argus bắt
được bug ở implementation-qa r1:

```dart
  void startNewGame() {
    _stopTimer();
    _emit(GameSessionState.initial(timePerQuestion: timePerQuestion).copyWith(
      flowToken: _state.flowToken + 1,   // ĐƠN ĐIỆU tăng — KHÔNG reset 0
      dialogState: GameMoneyLadderDialog(
        items: buildGameMoneyLadderItems(currentQuestionIndex: 0),
      ),
    ));
    _emitEvent(const GameDialogRequested());
  }
```

Vì sao `flowToken + 1` thay vì reset về 0? Vì `initial()` trả token
0 — nếu reset, delayed callback của phiên *cũ* (token 0) trùng token
của phiên mới (0) → callback lỗi thời chạy ngầm trong ván mới. Token
đơn điệu tăng suốt đời VM là bảo hiểm duy nhất chặn được chuyện đó.

### Bước 3 — `dismissDialog`: routing theo variant

`dialogState` là nguồn thật, `dismissDialog` là *router* — đóng
dialog không đơn giản là ẩn nó; tùy variant mà sang phase khác:

```dart
  void dismissDialog() {
    final dialog = _state.dialogState;
    if (dialog is GameDialogHidden) return;

    // Intro ladder lúc notStarted: dismiss = BẮT ĐẦU VÁN.
    if (dialog is GameMoneyLadderDialog &&
        _state.phase == GamePhase.notStarted) {
      _emit(_state.copyWith(
        phase: GamePhase.playing,
        dialogState: const GameDialogHidden(),
      ));
      _startTimer();
      return;
    }

    // Giải thích: đúng → câu kế/thắng; sai → thua.
    if (dialog is GameExplanationDialog) {
      if (dialog.isCorrect) {
        _loadNextQuestionOrVictory();
      } else {
        _endGame();
      }
      return;
    }

    // Còn lại (ladder giữa ván, confirm-exit): ẩn + hồi timer.
    _emit(_state.copyWith(dialogState: const GameDialogHidden()));
    if (_state.phase == GamePhase.playing) {
      _startTimer();
    }
  }
```

Đây là chỗ sealed family (Bài 2) phát huy: `is` trên variant quyết
định *toàn bộ hậu quả* của việc đóng. Lưu ý thiết kế: dialog kết
thúc (`GameEndedDialog`/`GameVictoryDialog`) **không** đi qua nhánh
này — chúng không được "dismiss" để tiếp tục, nút của chúng gọi
`backToMenu`/`playAgain` trực tiếp.

### Bước 4 — Transitions nội bộ: reveal → giải thích → kế/kết

`_onRevealElapsed` (chạy sau 1.5s `answeredPending`):

```dart
  void _onRevealElapsed(int token) {
    // Guard kép: token khớp VÀ phase vẫn pending.
    if (_state.phase != GamePhase.answeredPending) return;
    final question = questions[_state.questionIndex];
    final isCorrect = _state.selectedAnswer == question.correctOption;
    final level = gameMoneyLadderLevels[_state.questionIndex];
    final nextMoney = isCorrect ? level.amount : _state.moneyEarned;

    _emit(_state.copyWith(
      phase: GamePhase.answeredRevealed,
      moneyEarned: nextMoney,
      moneyAnimationTrigger: nextMoney != _state.moneyEarned
          ? _state.moneyAnimationTrigger + 1
          : _state.moneyAnimationTrigger,
      guaranteedAmount:
          isCorrect && level.isSafeHaven ? level.amount : _state.guaranteedAmount,
    ));
    _schedule(_explanationDelay, token, _onExplanationElapsed);
  }
```

Ba quy tắc game nằm đây: đúng → `moneyEarned` nhảy theo `level.amount`
(thang thật, không phải +1); trigger animation chỉ tăng khi tiền
đổi; `guaranteedAmount` chỉ nhảy khi vừa qua mốc `isSafeHaven`.

`_onExplanationElapsed` mở dialog giải thích với đúng chuỗi từ
`GameQuestionExplanationData` — `explainForTrueAnswer` khi đúng,
`explainForWrongAnswers[selected] ?? aiHintMessage` khi sai.
`_loadNextQuestionOrVictory` và `_endGame` đọc như tên: câu cuối
đúng → `victory` + `GameVictoryDialog`; còn lại → `playing` câu kế
+ `remainingTime` reset + `clearSelectedAnswer`; sai → `gameOver` +
`GameEndedDialog` mang `guaranteedAmount`. Cả hai terminal đều
`remainingTime: Duration.zero` (senior: đồng hồ về 0 khi ván kết).

### Bước 5 — Timer do VM sở hữu + `flowToken`

Đây là D-33 — `Timer.periodic` + `Duration` sống trong VM:

```dart
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    if (_isDisposed || _state.phase != GamePhase.playing) return;

    final remaining = _state.remainingTime - const Duration(seconds: 1);
    if (remaining > Duration.zero) {
      _emit(_state.copyWith(remainingTime: remaining));
      return;
    }

    // Timeout = "nộp đáp án rỗng" → reveal sẽ chấm sai.
    _stopTimer();
    final token = _state.flowToken + 1;
    _emit(_state.copyWith(
      phase: GamePhase.answeredPending,
      remainingTime: Duration.zero,
      selectedAnswer: '',
      flowToken: token,
    ));
    _schedule(_answerRevealDelay, token, _onRevealElapsed);
  }
```

Timer "pause" không phải là một API — **pause = `_stopTimer`,
resume = `_startTimer`** (đếm lại từ `remainingTime` đã giữ trong
state). Mọi `showDialog`-level pause đi qua hai method này.

`flowToken` — cơ chế chống callback lỗi thời:

```dart
  void _schedule(Duration delay, int token, void Function(int) onElapsed) {
    unawaited(Future.delayed(delay, () {
      if (_isDisposed || token != _state.flowToken) return;
      onElapsed(token);
    }));
  }
```

`Future.delayed` không hủy được — thay vì giữ `Future` để hủy, VM
lưu một số `flowToken`; mỗi lần state đổi sang flow mới (`submitAnswer`,
`_tick` timeout, `startNewGame`) token tăng → callback được lên lịch
với token *cũ* tự thấy `token != _state.flowToken` và bỏ chạy. Đây
là pattern của senior (`flowToken` trong `GameState`); về chất nó
giống "generation counter" hay "request id" trong async code.

Và `dispose` — lý do timer phải ở VM:

```dart
  @override
  void dispose() {
    _isDisposed = true;
    _stopTimer();
    _events.close();
    super.dispose();
  }
```

Widget chỉ *dựng* VM qua `ChangeNotifierProvider` — provider tự
`dispose` khi screen bị pop. Timer không còn cơ hội sót lại.

### Bước 6 — `buildGameResult`: đóng gói kết quả khi thoát

```dart
  GameResult buildGameResult() {
    final phase = _state.phase;
    final earned = switch (phase) {
      GamePhase.victory => _state.moneyEarned,
      GamePhase.gameOver => _state.guaranteedAmount,
      _ => _walkAwayAmount(_state), // thoát giữa ván
    };
    return GameResult(
      questionsAnswered: _state.questionIndex + 1, // câu đang dở cũng tính
      correctAnswers:
          phase == GamePhase.victory ? questions.length : _state.questionIndex,
      won: phase == GamePhase.victory,
      earnedAmount: earned,
    );
  }
```

`switch` kiệt hợp trên `GamePhase` — ba nhánh tiền khớp ba tình
huống kết thúc. Lưu ý `_` bắt cả `playing`/`notStarted`/pending —
đó là đường thoát giữa ván (✕/back confirm), tiền = walk-away.

### Bước 7 — Test VM bằng `FakeAsync` (concept mới: đồng hồ ảo)

Thêm dev-dependency trước:

```bash
flutter pub add fake_async --dev
```

`package:fake_async` cho một `FakeAsync` — đồng hồ *ảo* chạy trong
vùng `run()`: `Timer`/`Future.delayed` tạo bên trong không chờ thời
gian thật, bạn lái chúng bằng `async.elapse(duration)`. Với VM có
timer 30s + delay 1.5s + 1s, test thật sẽ mất ~30s/câu — đồng hồ ảo
nhảy thẳng tới đích.

`test/game_screen_view_model_test.dart` — 17 test, không pump một
widget nào. Ba helper giữ test ngắn:

```dart
GameQuizQuestionData makeQuestion(int i) => GameQuizQuestionData(
  id: i, question: 'Câu $i?',
  options: ['A$i', 'W${i}_1', 'W${i}_2', 'W${i}_3'],
  correctOption: 'A$i',            // đáp án đúng luôn là 'A$i'
  category: 'Test', language: 'vi',
  difficulty: GameQuestionDifficulty.easy,
  explanation: const GameQuestionExplanationData(
    explainForTrueAnswer: 'vì đúng',
    explainForWrongAnswers: {}, aiHintMessage: 'gợi ý'),
);
List<GameQuizQuestionData> bank(int n) =>
    [for (var i = 0; i < n; i++) makeQuestion(i)];
GameScreenViewModel startedVm(FakeAsync async, int questionCount) {
  final vm = GameScreenViewModel(questions: bank(questionCount));
  vm.startNewGame();
  vm.dismissDialog(); // đóng intro ladder → playing + timer chạy
  return vm;
}
```

```dart
test('submit đúng: pending → sau 1.5s revealed → tiền theo thang', () {
  FakeAsync().run((async) {
    final vm = startedVm(async, 3);          // bank 3 câu mini
    vm.submitAnswer(optionMatching(vm));     // đáp án đúng của câu 0
    expect(vm.state.phase, GamePhase.answeredPending);

    async.elapse(const Duration(milliseconds: 1500)); // reveal
    expect(vm.state.phase, GamePhase.answeredRevealed);
    expect(vm.state.moneyEarned, 1000);  // level 1

    async.elapse(const Duration(seconds: 1)); // giải thích mở
    expect(vm.dialogState, isA<GameExplanationDialog>());
  });
});
```

(`optionMatching` ở trên viết gọn cho lesson — file thật dùng
`vm.screenData.answers.firstWhere((a) => a.answerText ==
vm.currentCorrectOption)` qua helper `answerCorrectly`.)

Bộ 17 test bao phủ: initial state, startNewGame mở intro,
dismiss→playing + timer chạy, submit guard sai-phase, reveal
đúng/sai, safe-haven nâng `guaranteedAmount`, timeout→sai,
explanation→kế/victory/gameOver, `flowToken` vô hiệu callback cũ,
walk-away = 0 trước Q5 và = max sau, `dispose` dừng mọi callback.

## Android / Compose bridge

- **SIMILARITY:** `viewModelScope`+`delay` ↔ `Future.delayed`;
  `MutableStateFlow.update` ↔ `_state = copyWith + notifyListeners`.
- **IMPORTANT DIFFERENCE:** Dart/Flutter không có structured
  concurrency — `viewModelScope` tự hủy coroutine khi VM chết, còn
  `Future.delayed`/`Timer` phải tự guard bằng `_isDisposed` +
  `flowToken`. Không có "scope" nào lo cho bạn.
- **DO NOT ASSUME:** `ChangeNotifier` ≠ `ViewModel` Android về
  lifecycle — nó không có `onCleared` scope riêng; `dispose` chạy
  vì *provider* gọi, không phải vì VM "biết" mình chết.

## Senior project connection

- `lib/view_models/game/game_screen_view_model.dart` (senior) —
  `extends DreChangeNotifier<GameState, GameAction, GameEffect,
  GameAsyncOp>`; learner `extends ChangeNotifier`, cùng bề mặt
  `startNewGame`/`submitAnswer`/`dismissDialog`/`backToMenu`/
  `playAgain`/`screenData`/`dialogState`/`uiEvents`. DRE → M26.
- `lib/view_models/game/reducer/game_reducer.dart` (senior) —
  transition thuần; learner giữ trong method VM. Shape chuyển đổi
  giống hệt.
- `lib/view_models/game/dre/game_dre_state.dart` (senior) —
  `flowToken` sống trong `GameState` ở senior; learner đưa nó vào
  `GameSessionState` đúng vai trò.

## Chạy và quan sát

```bash
flutter analyze  # sạch
flutter test     # 116/116 — +17 VM test
```

Màn hình vẫn stub — VM đã có não nhưng chưa có mặt. Để "thấy" nó
chạy: trong test, `print(vm.screenData.timer.formattedTime)` sau
`async.elapse(Duration(seconds: 1))` → `00:29`.

## Kiểm tra hiểu biết

1. Vì sao `flowToken` phải **đơn điệu tăng** chứ không reset về 0
   trong `startNewGame`?
   → Reset làm token phiên mới trùng token callback delay cũ —
   callback lỗi thời chạy ngầm trong ván mới.
2. `submitAnswer` ở phase `answeredRevealed` → gì xảy ra?
   → Guard `phase != playing → return`, không gì đổi.
3. Pause timer = làm gì trong VM này?
   → `_stopTimer()` (cancel); `remainingTime` trong state giữ giá
   trị, resume bằng `_startTimer()` đếm tiếp từ đó.
4. Vì sao `submitAnswer` nhận `GameAnswerOptionData` chứ không
   nhận `String`?
   → Senior parity: UI forward object nó render (có `answerText`),
   VM tự lấy text — UI không bóc field.

## Sai lầm thường gặp

- **Gọi `_emit` sau `dispose`** — luôn check `_isDisposed` trong
  callback async (đã làm trong `_schedule`/`_tick`).
- **Quên `unawaited` trên `Future.delayed`** — analyzer
  `unawaited_futures` sẽ bắt; `unawaited` từ `dart:async` nói rõ
  "tôi cố ý không await".
- **`_timer` không null-out sau cancel** — `_stopTimer` phải
  `_timer = null`, nếu không `dispose` cancel hai lần (vô hại nhưng
  bẩn).
- **Guard thiếu ở delayed callback** — `_onRevealElapsed` phải kiểm
  cả `phase` lẫn token; chỉ token không đủ nếu một đường mutation
  khác đã đổi phase mà không tăng token.

## Tự làm (production) — test transition sai-phase

Viết test chứng minh `submitAnswer` bị bỏ qua khi đang `answeredPending`:

:::note[Gợi ý]
Dùng `FakeAsync().run` + `startedVm` → `submitAnswer` đáp án đúng (qua
`answers.firstWhere(answerText == vm.currentCorrectOption)` — token
phiên mới) →
→ assert `selectedAnswer` **không đổi** và phase vẫn `answeredPending`.
:::

<details><summary>Đáp án</summary>

```dart
test('submit lần hai trong answeredPending bị guard chặn', () {
  FakeAsync().run((async) {
    final vm = startedVm(async, 3);
    final correct = vm.screenData.answers
        .firstWhere((a) => a.answerText == vm.currentCorrectOption);
    final wrong = vm.screenData.answers
        .firstWhere((a) => a.answerText != vm.currentCorrectOption);
    vm.submitAnswer(correct);
    vm.submitAnswer(wrong); // phase != playing → phải bị bỏ
    expect(vm.state.selectedAnswer, correct.answerText);
    expect(vm.state.phase, GamePhase.answeredPending);
  });
});
```

(`currentCorrectOption` là extension test trong file: lấy
`questions[vm.state.questionIndex].correctOption`.)

</details>

## Ta cố ý chưa thêm

- `DreChangeNotifier`/`GameReducer`/effects — M26.
- `useFeatureButton`/`askAi`/`fiftyFifty`/`walkAway` — M20.
- `hasSavedResult` + VM-side save — M22 (giờ menu vẫn
  `applyGameResult`).
- `GameShareResultEvent` — FR-33.

## Checkpoint hoàn thành

- [ ] `lib/view_models/game/game_screen_view_model.dart` tồn tại,
  `extends ChangeNotifier`, API đúng tên senior.
- [ ] `test/game_screen_view_model_test.dart` — 17 test `fakeAsync`.
- [ ] `flutter analyze` sạch, `flutter test` = **116/116**.
- [ ] Vẽ được flow: `submitAnswer → pending → 1.5s → revealed →
  1s → explanation → dismiss → playing/gameOver/victory`.
