---
title: "Bài 4 · GameReducer — bảng transition thuần, chia theo flow"
description: "`reducer/game_reducer.dart` + `part`/`part of` + 4 private `extension _GameReducer*Flow` (`part`/`part of` reuse từ M24 — mới ở chỗ: private `extension` trên class qua part files, lần đầu trong course); switch exhaustive 13 arm; guard `_result(state)` same-instance; `flowToken` tăng tại mọi transition tạo delay; `_withSaveResult` → `GameSaveResult` op. 10 reducer test thuần — không Flutter, không fake → 241 → 251."
sidebar:
  label: "Bài 4 · GameReducer"
  order: 4
---

## Mục tiêu

- Tạo `lib/view_models/game/reducer/game_reducer.dart` + bốn
  `part` file — `game_reducer_answer_flow.dart`,
  `_feature_flow`, `_session_flow`, `_timer_flow` — mỗi file một
 `extension _GameReducer*Flow on GameReducer` private (`part`/`part of`
  đã gặp ở M24 auth dialog; mới ở private `extension` qua part
  files).
- Trace được `reduce`: switch exhaustive 13 arm → handler trong
  part file; guard trả `_result(state)` (same-instance → không
  notify); `flowToken` tăng tại mọi transition tạo delay *hoặc
  reset flow* (`_startGame`) và `*Elapsed` no-op khi
 `flowToken != state.flowToken`.
- `_withSaveResult` → `GameSaveResult` op: save là *kết quả của
 reduce*, idempotent qua `hasSavedResult` (→).
- `test/view_models/game/game_reducer_test.dart` — 10 test thuần,
  không Flutter/fake/`async`. +10 → **251/251**.

## Bạn đang ở đâu

- Bài 3: contract `dre/` compile sạch (241) — `GameReducer` là
  consumer đầu tiên của `game_dre_contract.dart`.
- VM cũ vẫn chạy; reducer mới chưa được cắm — test file là nơi
  duy nhất gọi `reduce` ở bài này.
- Toàn bộ *luật chơi* (transitions, guard, scoring, token) từ 733
  dòng VM cũ giờ được viết lại trong ~510 dòng thuần (5 file) —
  bài lớn nhất của milestone.

## Vì sao việc này quan trọng ngay bây giờ

Reducer là nơi duy nhất giữ *luật chuyển trạng thái* — phần trước
đây nằm rải trong ~15 method của VM. Gom về một hàm thuần mở khoá
ba thứ không làm được trước: (1) **test transition mà không dựng
VM** — `reducer.reduce(state, action)` trả `DreResult` assert
thẳng; (2) **guard tập trung** — mọi "điều kiện để chuyển" là một
nhánh `if` trả `_result(state)`; (3) **stale guard thành luật
data** — `flowToken != state.flowToken` nằm ngay đầu mỗi
`*Elapsed` handler. Và senior chia `part` theo *flow
domain* vì reducer được đọc theo miền — không phải theo
kiểu chữ.

## Bạn đã biết gì

- Toàn bộ contract Bài 3 (`GameState`/`GameAction`/`GameEffect`/
  `GameAsyncOp`/`DreResult`); 6 phase + sealed dialog family
; `copyWith` + cờ `clear*`.
- `hasSavedResult` idempotence; `flowToken`/`_requestId`
 ý tưởng stale (→); `isA<T>()`/`is!` + pattern
 `(final field)` destructure (nâng).
- Helpers sẵn: `calculateGameWalkAwayAmount`,
  `buildGameMoneyLadderItems`, `buildGameAudiencePoll`,
 `applyGameFiftyFifty`, `formatGameMoney` (M19/M20 — gia
  đình).

## Mental model mới — "một library, năm file" + "guard là data" (+, CORE)

```text
game_reducer.dart ── part 'game_reducer_answer_flow.dart'
                 ── part 'game_reducer_feature_flow.dart'
                 ── part 'game_reducer_session_flow.dart'
                 ── part 'game_reducer_timer_flow.dart'

mỗi part file mở đầu:  part of 'game_reducer.dart';
                       extension _GameReducer*Flow on GameReducer {
                         DreResult<…> _handler(GameState state, …) { … }
                       }
```

`part`/`part of` ghép nhiều file thành **một library**: chia sẻ
imports, chia sẻ private members — `_submitAnswer` định nghĩa ở
part answer nhưng `reduce` ở main file gọi được vì cùng library;
tên extension private `_GameReducer*Flow` nên không lộ ra ngoài.
Vì sao chia theo *flow domain*: mỗi file trả lời một câu
hỏi nghiệp vụ ("trả lời chạy thế nào?", "lifeline chạy thế
nào?") — ~510 dòng luật đọc như bốn chương.

Và nhịp của mọi handler:

```text
_handler(state, …):
  guard sai → return _result(state)          // same instance = no-op
  đúng → _result(state.copyWith(…),
                 effects: […],               // ý định — data
                 asyncOp: …)                  // tối đa một
```

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `part 'file.dart'` / `part of 'lib.dart'` | split một library thành nhiều file — chia sẻ import + private (mới) |
| `extension _Name on GameReducer` | method mở rộng private trong part — tên private nên không lộ ra ngoài |
| `GameAnswerSubmitted(final answerText) =>` | object pattern destructure ngay trong switch arm — nâng |
| `is! GameAIAssistantDialog` | negated type test — guard dialog đúng loại |
| `_result(state, {effects, asyncOp})` | helper private gói `DreResult` — điểm chung mọi nhánh |

## Flutter cần dùng

Không có API Flutter nào trong reducer — đó chính là điểm cốt lõi:
`GameReducer` là class Dart thuần (không `ChangeNotifier`, không
`Timer`, không `BuildContext`), nên `flutter_test` chỉ cung cấp
`test`/`group`/`expect`/`setUp`. `Timer`/`Future.delayed` sống ở
bridge phía VM — Bài 5. Test reducer không cần `FakeAsync` hay
pump: `final result = reducer.reduce(s, a)` → assert trực tiếp
`result.state`/`result.effects`/`result.asyncOp`.

## Ví dụ độc lập — pure reducer = deterministic (DartPad)

```dart
class S { final int score; const S(this.score); }
final class R {
  final S state;
  final List<String> effects;
  const R(this.state, [this.effects = const []]);
}

R reduce(S s, String action) => switch (action) {
  'hit'  => R(S(s.score + 10)),
  'bank' => R(s, const ['persist']), // khai báo ý định, không làm
  _      => R(s),                    // guard → same instance
};

void main() {
  const s = S(30);
  final a = reduce(s, 'hit'), b = reduce(s, 'hit');
  print(a.state.score == b.state.score);   // true — deterministic
  print(identical(a.state, b.state));      // false — instance mới
  print(reduce(s, '???').state.score);     // 30 — guard im lặng
}
```

Pure = cùng input → cùng output, không đồng hồ, không IO.

## Android / Compose bridge

**SIMILARITY — chia ViewModel-logic ra nhiều file theo feature.**
`part`/`part of` ≈ một class Kotlin + nhiều extension-function
file cùng package (nhưng `part` mạnh hơn: chia sẻ *private*).

**IMPORTANT DIFFERENCE — Dart `part` = một library.** Part file
không tự import — nó thấy mọi import của main file và mọi member
private.

**DO NOT ASSUME — extension ≠ subclass.** `extension _Flow on
GameReducer` thêm *method* không thêm field — reducer vẫn
stateless (`questions`/`timePerQuestion` là config bất biến), mọi
"biến" sống trong `state` param.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/view_models/game/reducer/game_reducer.dart` | class + switch + `_result` + `_walkAwayAmount`/`_moneyLadderItems`/`_audiencePollItems` — verbatim |
| `game_reducer_answer_flow.dart` | `_submitAnswer`/`_revealAnswer`/`_showExplanation` — verbatim |
| `game_reducer_feature_flow.dart` | `_selectFeature` + lifelines + dialogs + `_canUseFeature` — verbatim |
| `game_reducer_session_flow.dart` | `_startGame`/`_dismissDialog`/`_loadNextQuestionOrVictory`/`_endGame`/`_confirmWalkAway`/`_backToMenu`/`_withSaveResult` — verbatim |
| `game_reducer_timer_flow.dart` | `_tickTimer` — verbatim |
| `test/view_models/game/game_reducer_test.dart` | 10 test verbatim (đổi package import) |

:::note[Bản đồ bài dài — năm pha, không một mạch]
Bài này port một reducer ~4 file `part` + 10 test — đọc một hơi sẽ
quá tải. Đi theo pha, mỗi pha có mốc kiểm:

| Pha | Bạn đã biết | Model mới | Kiểm trước khi tiếp |
|---|---|---|---|
| **1 — transition thuần** | `copyWith`, sealed switch (Bài 2–3) | reducer = hàm thuần (state, action) → (state, effects) | DartPad mini-reducer chạy được |
| **2 — skeleton + flow đầu** | `part`/`part of` chưa gặp | một class rải qua nhiều file cùng-library | đọc được switch kiệt hợp trên `GameAction` |
| **3 — session flow + op** | effect là data (Bài 3) | action→effect→op→action mới | chỉ ra được op nào phát action nào |
| **4 — feature flow** | lifeline semantics (M19–M21) | guard tập trung trong reducer | nêu được vì sao guard không ở VM |
| **5 — regression + debug** | `expect`/`group` | reducer test = pure function test | phá một guard → đúng một test đỏ |
:::

:::caution[DRE là lựa chọn của project này — không phải luật Flutter]
Reducer/effect/op là *kiến trúc senior chọn* để quản một màn hình 733
dòng nhiều timer. Đa số app Flutter không cần nó — `ChangeNotifier`
đơn giản đã đủ khi state nhỏ. **Dùng khi:** nhiều nguồn thay đổi cùng
một state, transition phải test được mà không cần UI, async effect
phải tách khỏi logic. **Overkill khi:** một màn hình một stream,
không transition phức tạp. Đừng mang pattern này vào mọi project —
mang *cách suy luận* (state là data, side-effect là ý định) thì luôn
đúng.
:::

## Build it step by step

**PHA 2 — skeleton + flow đầu.**

**Bước 1 — `lib/view_models/game/reducer/game_reducer.dart`**
(file mới — verbatim senior; imports gồm `core/dre/dre.dart`,
data files, `../dre/game_dre_contract.dart`, ba support helpers;
trích `part` + `reduce` + `_result`):
**CHƯA COMPILE đến hết Bước 5** — bốn `part` file chưa tồn tại;
`flutter analyze` sẽ báo `uri_does_not_exist` tạm thời.

```dart
part 'game_reducer_answer_flow.dart';
part 'game_reducer_feature_flow.dart';
part 'game_reducer_session_flow.dart';
part 'game_reducer_timer_flow.dart';

class GameReducer
    implements DreReducer<GameState, GameAction, GameEffect, GameAsyncOp> {
  final List<GameQuizQuestionData> questions;
  final Duration timePerQuestion;

  const GameReducer({required this.questions, required this.timePerQuestion});

  @override
  DreResult<GameState, GameEffect, GameAsyncOp> reduce(
    GameState state,
    GameAction action,
  ) {
    return switch (action) {
      GameStarted() => _startGame(state),
      GameDialogDismissed() => _dismissDialog(state),
      GameAnswerSubmitted(:final answerText) =>
        _submitAnswer(state, answerText),
      GameAnswerRevealElapsed(:final flowToken) =>
        _revealAnswer(state, flowToken),
      GameExplanationElapsed(:final flowToken) =>
        _showExplanation(state, flowToken),
      GameFeatureSelected(:final type) => _selectFeature(state, type),
      GameMoneyLadderRequested() => _showMoneyLadder(state),
      GameConfirmExitRequested() => _showConfirmExit(state),
      GameConfirmWalkAwayRequested() => _showConfirmWalkAway(state),
      GameWalkAwayConfirmed() => _confirmWalkAway(state),
      GameTimerTicked() => _tickTimer(state),
      GameAIAssistantElapsed(:final flowToken) =>
        _showAIAssistantResult(state, flowToken),
      GameBackToMenuRequested() => _backToMenu(state),
    };
  }

  DreResult<GameState, GameEffect, GameAsyncOp> _result(
    GameState state, {
    List<GameEffect> effects = const [],
    GameAsyncOp? asyncOp,
  }) {
    return DreResult(state: state, effects: effects, asyncOp: asyncOp);
  }
  // + _walkAwayAmount / _moneyLadderItems / _audiencePollItems — verbatim
}
```

**Bước 2 — `game_reducer_timer_flow.dart`** (nguyên file — nhỏ
nhất, đọc được một hơi):

```dart
part of 'game_reducer.dart';

extension _GameReducerTimerFlow on GameReducer {
  DreResult<GameState, GameEffect, GameAsyncOp> _tickTimer(GameState state) {
    if (state.phase != GamePhase.playing) {
      return _result(state);
    }

    final nextTime = state.remainingTime - const Duration(seconds: 1);
    final remainingTime = nextTime.isNegative ? Duration.zero : nextTime;

    if (remainingTime > Duration.zero) {
      return _result(state.copyWith(remainingTime: remainingTime));
    }

    final token = state.flowToken + 1;
    return _result(
      state.copyWith(
        phase: GamePhase.answeredPending,
        selectedAnswer: '',
        remainingTime: Duration.zero,
        flowToken: token,
      ),
      effects: [const GamePauseTimer(), GameScheduleAnswerReveal(token)],
    );
  }
}
```

**Bước 3 — `game_reducer_answer_flow.dart`** (verbatim senior;
trích `_submitAnswer` — `_revealAnswer`/`_showExplanation` port
nguyên văn):

```dart
part of 'game_reducer.dart';

extension _GameReducerAnswerFlow on GameReducer {
  DreResult<GameState, GameEffect, GameAsyncOp> _submitAnswer(
    GameState state,
    String answerText,
  ) {
    if (state.phase != GamePhase.playing || answerText.isEmpty) {
      return _result(state);
    }

    final token = state.flowToken + 1;
    return _result(
      state.copyWith(
        phase: GamePhase.answeredPending,
        selectedAnswer: answerText,
        flowToken: token,
      ),
      effects: [const GamePauseTimer(), GameScheduleAnswerReveal(token)],
    );
  }
}
```

**PHA 3 — session flow + op.**

**Bước 4 — `game_reducer_session_flow.dart`** (verbatim senior;
trích `_withSaveResult` — bảng dưới map các handler còn lại):

```dart
  DreResult<GameState, GameEffect, GameAsyncOp> _withSaveResult(
    GameState state, {
    required int earnedAmount,
    required bool isWin,
    required List<GameEffect> effects,
  }) {
    if (state.hasSavedResult) {
      return _result(state, effects: effects);
    }

    return _result(
      state.copyWith(hasSavedResult: true),
      effects: effects,
      asyncOp: GameSaveResult(
        earnedAmount: earnedAmount,
        isWin: isWin,
        questionCount: state.questionIndex + 1,
      ),
    );
  }
```

| Handler | Guard | Transition chính | Effects/asyncOp |
|---|---|---|---|
| `_startGame` | — | `GameState.initial` + `flowToken: state.flowToken + 1` + options câu 1 + intro ladder | `[GameStopTimer]` |
| `_dismissDialog` | 3 nhánh theo `dialogState` | intro@notStarted → playing; `GameExplanationDialog` → next/victory hoặc endGame; default → hidden | `GameStartTimer` khi `playing` |
| `_loadNextQuestionOrVictory` | `index >= len-1` | next question (clear selected/audience, reset time) hoặc `victory`+`GameVictoryDialog` | `GameStartTimer` / `_withSaveResult`+`GameStopTimer` |
| `_endGame` | — | `gameOver` + `GameEndedDialog(guaranteedAmount)` | `_withSaveResult` + `GameStopTimer` |
| `_confirmWalkAway` | — (guard ở bước mở dialog) | `victory` + `GameVictoryDialog(walkAway)` | `_withSaveResult` + `GameStopTimer` |
| `_backToMenu` | — | `remainingTime: zero` | `_withSaveResult` + `[GameStopTimer, GameNavigateToMenu]` |

**PHA 4 — feature flow.**

**Bước 5 — `game_reducer_feature_flow.dart`** (verbatim senior;
trích `_selectFeature` + `_canUseFeature` — các handler
`_useFiftyFifty`/`_showAudiencePoll`/`_showAIAssistant`/
`_showMoneyLadder`/`_showConfirmExit`/`_showConfirmWalkAway`/
`_showAIAssistantResult` port nguyên văn):

```dart
  DreResult<GameState, GameEffect, GameAsyncOp> _selectFeature(
    GameState state,
    GameFeatureButtonType type,
  ) {
    if (!_canUseFeature(state, type)) {
      return _result(state);
    }
    return switch (type) {
      GameFeatureButtonType.fiftyFifty => _useFiftyFifty(state),
      GameFeatureButtonType.audiencePoll => _showAudiencePoll(state),
      GameFeatureButtonType.aiAssistant => _showAIAssistant(state),
      GameFeatureButtonType.walkAway => _showConfirmWalkAway(state),
      GameFeatureButtonType.exitGame => _showConfirmExit(state),
    };
  }

  bool _canUseFeature(GameState state, GameFeatureButtonType type) {
    if (state.phase != GamePhase.playing) {
      return false;
    }
    if (type == GameFeatureButtonType.walkAway) {
      return _walkAwayAmount(state) > 0;
    }
    if (type == GameFeatureButtonType.exitGame) {
      return true;
    }
    return !state.usedFeatureButtons.contains(type);
  }
```

**PHA 5 — regression + debug.**

**Bước 6 — `test/view_models/game/game_reducer_test.dart`** (file
mới — 10 test verbatim senior; trích 2 test + helpers):

```dart
    test('answer submit outside playing is ignored', () {
      final state = _started(reducer, initialState);

      final result = reducer.reduce(state, const GameAnswerSubmitted('Hanoi'));
      expect(result.state, same(state));
      expect(result.effects, isEmpty);
      expect(result.asyncOp, isNull);
    });

    test('wrong explanation dismissal emits terminal save async op', () {
      final explained = _explainedAnswer(
        reducer, _playing(reducer, initialState), 'Ho Chi Minh City');

      final result = reducer.reduce(explained, const GameDialogDismissed());

      expect(result.state.phase, GamePhase.gameOver);
      expect(result.state.dialogState, isA<GameEndedDialog>());
      expect(result.effects.single, isA<GameStopTimer>());
      expect(result.asyncOp, isA<GameSaveResult>());
      final save = result.asyncOp! as GameSaveResult;
      expect(save.earnedAmount, 0);
      expect(save.isWin, isFalse);
      expect(save.questionCount, 1);
    });
```

— setUp (`const GameReducer(questions: gameSampleQuestions,
timePerQuestion: Duration(seconds: 30))` + `GameState.initial`)
và ba helper tái dùng mọi test (port verbatim):

```dart
GameState _started(GameReducer reducer, GameState initialState) =>
    reducer.reduce(initialState, const GameStarted()).state;

GameState _playing(GameReducer reducer, GameState initialState) => reducer
    .reduce(_started(reducer, initialState), const GameDialogDismissed())
    .state;

GameState _explainedAnswer(GameReducer reducer, GameState state, String answer) {
  final submitted = reducer.reduce(state, GameAnswerSubmitted(answer));
  final revealed = reducer.reduce(
      submitted.state, GameAnswerRevealElapsed(submitted.state.flowToken));
  return reducer
      .reduce(revealed.state, GameExplanationElapsed(revealed.state.flowToken))
      .state;
}
```

Mười case phủ đủ các miền: session (start/dismiss-intro/
next-question/endGame), answer (submit-guard, reveal đúng/sai,
explanation→save op), feature (50:50 blank-2+disable-reuse,
audience+AI pause+schedule), timer (về-0 → timeout `''` + reveal
scheduled).

## Hiểu code — bốn chi tiết dễ trượt

1. **`same(state)` là assert "no-op thật".** Guard trả đúng
   instance cũ → `prev != next` false ở dispatch → không notify,
   không effect; `same()` khác `equals()` — `GameState` không
   `==` nên `same` là cách duy nhất nói "object y hệt".
2. **Token đi vòng state→effect→action→reducer.** `_submitAnswer`
   ghi `flowToken: token` vào state *và* vào
   `GameScheduleAnswerReveal(token)`; bridge re-dispatch
   `GameAnswerRevealElapsed(token)`; reducer check lệch → no-op
. Ba lần nhìn thấy cùng một con số trên ba loại.
3. **`_withSaveResult` — save được *khai báo* trong reduce.** Op
   `GameSaveResult` đi kèm state đã `hasSavedResult: true` → op
 chạy với snapshot post-reduce thấy flag bật. Khi đã
   saved, `_result(state, effects: effects)` vẫn để effects đi
   qua: `backToMenu` lần hai vẫn navigate, chỉ save bị chặn.
4. **`_dismissDialog` default-branch → +1 notify (divergence).**
   Dismiss khi dialog đã `GameDialogHidden` → default → `copyWith`
   instance mới → notify dù "không đổi" (identity diff); bản cũ
   early-return — senior giữ default verbatim. Và
   `_confirmWalkAway` không tự guard phase — guard nằm ở
   `_showConfirmWalkAway` (`phase` + `amount > 0`).

## Chạy và quan sát

```text
flutter analyze → No issues found!
flutter test test/view_models/game/game_reducer_test.dart → 10/10 xanh
flutter test    → +251: All tests passed!   (241 + 10)
```

Reducer chưa ai gọi trong `lib/` production — test file là
consumer duy nhất; VM mới cắm ở Bài 5.

## Thử nghiệm

Đoán `result` (state/effects/asyncOp) cho `reducer.reduce(
_playing(…), const GameBackToMenuRequested())` khi
`hasSavedResult` lần lượt `false` rồi `true` (ca hai:
`state.copyWith(hasSavedResult: true)`).

<details>
<summary>Đáp án</summary>

- `false` → state mới `remainingTime: zero` + `hasSavedResult:
  true`; effects `[GameStopTimer, GameNavigateToMenu]`; asyncOp
  `GameSaveResult(earnedAmount: walkAway, isWin: false,
  questionCount: index+1)`.
- `true` → state chỉ `remainingTime: zero` (flag giữ); effects y
  hệt (nav vẫn emit!); **asyncOp null** — save-once là
 reducer-guard, không phải VM-guard.
</details>

## Lỗi hay gặp

1. **Quên `part of` ở part file** — compile error; mọi part phải
   `part of 'game_reducer.dart';` đúng tên main file.
2. **Trả `state.copyWith()` cho guard** — instance mới → notify
   dư; guard phải `_result(state)` same-instance.
3. **Quên `flowToken: token` khi schedule** — token không tăng →
   stale guard mất nghĩa; mọi transition tạo delay phải bump.
4. **Hai async-op một reduce** — `asyncOp` là `O?` một slot;
   `_withSaveResult` là chỗ duy nhất quyết op của session.
5. **Đặt handler trong main file** — compile được nhưng mất
   layout senior: part files là cách đọc theo domain.

## Tự làm — PRODUCE + DEBUG

**PRODUCE:** viết reducer test cho `GameTimerTicked` khi `phase
!= playing` — mong đợi `same(state)`, effects empty, asyncOp
null. Dùng `initialState` (phase `notStarted`) là đủ.

:::note[Gợi ý]
Mẫu y hệt `'answer submit outside playing is ignored'` — guard
trả `_result(state)`.
:::

<details>
<summary>Đáp án</summary>

```dart
test('timer tick outside playing is ignored', () {
  final result = reducer.reduce(initialState, const GameTimerTicked());

  expect(result.state, same(initialState));
  expect(result.effects, isEmpty);
  expect(result.asyncOp, isNull);
});
```

`_tickTimer` guard `phase != GamePhase.playing` → `_result(state)`
— `notStarted` cũng bị chặn, không chỉ `gameOver`.
</details>

**DEBUG (planted bug):** trong `_showAIAssistantResult`, xoá điều
kiện `flowToken != state.flowToken` (giữ `dialogState is!
GameAIAssistantDialog`).
:::note[Gợi ý]
`GameAIAssistantElapsed(2)` mang token của flow AI; sau submit
`state.flowToken` đã là 3. Tự hỏi: guard còn lại (`dialogState is!
GameAIAssistantDialog`) có chặn được action lỗi thời này không —
dialog có bị đổi variant khi submit không?
:::
Scratch test: `_playing` (token=1 —
`_startGame` đã bump) → `GameFeatureSelected(aiAssistant)`
(token=2, dialog loading) → `GameAnswerSubmitted('Hanoi')`
(token=3, phase answeredPending, dialog VẪN là AIAssistant) →
`GameAIAssistantElapsed(2)`. Đoán kết quả có/không có token guard.

<details>
<summary>Đáp án — đã verify bằng đọc code</summary>

- **Có guard:** `flowToken 2 != state.flowToken 3` →
  `_result(state)` — stale bị loại.
- **Không token guard:** `dialogState is GameAIAssistantDialog`
  → true → dialog bị ghi đè thành kết quả AI (`selectedAnswer:
  correctOption`, `confidencePercentage: 85`) *giữa* flow trả
  lời — stale result lọt vào flow mới. Shipped suite **không
  bắt** (không test nào đi đúng chuỗi này) — bug chỉ lộ khi tự
  viết ca đó; đây là lý do guard-token tồn tại ở MỌI `*Elapsed`
  handler, kể cả khi guard thứ hai có vẻ đủ.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao senior chia reducer thành `part` theo flow? —
  **Đáp:** đọc theo miền nghiệp vụ; `part`/`part of` chia sẻ
  import + private members như một library — extension private
 không lộ ra ngoài.
- **Hỏi:** `same(state)` nghĩa gì trong guard test? — **Đáp:**
  identical object — `GameState` không `==` nên "giống hệt" =
  cùng instance; guard trả đúng instance → dispatch không notify.
- **Hỏi:** `backToMenu` hai lần — cái gì vẫn emit, cái gì bị
  chặn? — **Đáp:** effects `[GameStopTimer, GameNavigateToMenu]`
  vẫn emit cả hai; chỉ `GameSaveResult` op bị `hasSavedResult`
  chặn lần hai.
- **Hỏi:** vì sao `questionCount` là `state.questionIndex + 1`? —
  **Đáp:** index 0-based; save đếm câu đã chơi — câu hiện tại là
  câu vừa trả lời xong.

## Ta cố ý chưa thêm

- VM mới cắm reducer + bridge thực hiện effects — **Bài 5**.
- Share arm `GameShareRequested` → `GameShareResult` — **M27**;
  switch cố ý chỉ 13 arm.
- Platform extras — **M27**; visual parity — **M28**;
  `MenuDialogLayer` — **M29**.
- `==` cho `GameState`, middleware/logging — senior không có.

## Checkpoint hoàn thành

- [ ] `reducer/` đủ 5 file: `game_reducer.dart` + 4 `part of` —
  reduce là switch exhaustive 13 arm, mọi guard `_result(state)`.
- [ ] `flowToken` tăng tại mọi transition tạo delay hoặc reset
  flow; `*Elapsed` check `flowToken != state.flowToken` đầu
  handler.
- [ ] `test/view_models/game/game_reducer_test.dart` 10 test xanh
  — không Flutter/fake/async.
- [ ] `flutter analyze` sạch; `flutter test` **251/251**.
