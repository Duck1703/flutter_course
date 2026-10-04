---
title: "Bài 3 · GameState + actions + effects — hợp đồng game-DRE"
description: "Port `view_models/game/dre/`: `GameState` 13 field — `flowToken` thành state thay VM field cũ; unmodifiable collections; `initial` + `copyWith`/`clear*` — + 13 `GameAction` / 7 `GameEffect` / 1 `GameAsyncOp` sealed + barrel `game_dre_contract.dart`. Files compile nhưng chưa ai dùng — scaffold của migration. +0 → 241."
sidebar:
  label: "Bài 3 · state + actions + effects"
  order: 3
---

## Mục tiêu

- Tạo `lib/view_models/game/dre/game_dre_state.dart` — `GameState`
  13 field (session model chuyển nhà từ `data/` sang `dre/`, đổi
  tên từ `GameSessionState` → `GameState` đúng senior); thêm field
 `flowToken` **vào state**.
- Tạo `game_dre_action.dart` (13 variant), `game_dre_effect.dart`
  (7 variant), `game_dre_async_op.dart` (`GameSaveResult`),
  `game_dre_contract.dart` (barrel export).
- Giải thích được: vì sao `*Elapsed` action mang `flowToken` dạng
  data, và vì sao effect là object mô tả chứ không phải `Timer`.
- Chấp nhận trạng thái **unused-but-compiling**: năm file tồn tại,
  chưa ai import — đó là scaffold của migration; +0 test →
  **241/241**.

## Bạn đang ở đâu

- Bài 2: `core/dre` nền xong + 5 test → 241. `GameReducer` chưa có
  — nó cần `GameState`/`GameAction`/`GameEffect`/`GameAsyncOp` tồn
  tại trước (Bài 4); VM mới cần cả reducer lẫn contract (Bài 5).
- VM cũ vẫn đang chạy: `GameSessionState` trong
  `data/game/game_session_state_data.dart` vẫn được dùng — bài này
  **thêm** `GameState` mới, chưa xoá gì (xoá ở Bài 5).
- `GamePhase`/`GameDialogState`/`GameScreenUiEvent` **ở lại** data
  file — senior giữ chúng ở `data/`; chỉ session-model chuyển vào
  `dre/`.

## Vì sao việc này quan trọng ngay bây giờ

Hai quyết định thiết kế cần đặt nền trước khi reducer xuất hiện.
Một: `flowToken` — bản trung gian giữ `_flowToken` như *field tay
của VM* và guard delay chủ yếu bằng `phase`; senior đưa token vào
**state** để reducer tự quyết "callback này còn hợp lệ không" bằng
dữ liệu, không bằng may mắn đúng phase. Hai: effect
`GameScheduleAnswerReveal(flowToken)` là *object mô tả một lời
hẹn*, không chứa `Timer`/`Future` — reducer giữ purity và test
được đồng bộ. Thứ tự file trước — consumer sau là cố ý:
contract phải compile sạch trước khi ai dùng.

## Bạn đã biết gì

- `copyWith` + `clearSelectedAnswer`/`clearAudiencePercentiles`
 flag (khi field nullable, `?? this.x` không xoá được nên
  cần cờ clear).
- `sealed`/`final class` + `implements`;
 `List/Map/Set.unmodifiable` wrapper; `export`
  barrel (đã gặp ở contract files).
- `flowToken`-như-`_requestId`: loại kết quả cũ bằng con số tăng
 đơn điệu (M23); khác `_isSyncing` từ chối vào.
- `DreAction`/`DreEffect`/`DreAsyncOp` markers + `DreResult`
 (Bài 2).

## Mental model mới — "token trong state; effect là ý định" (CORE)

```text
BẢN TRUNG GIAN (M19–M25):
  VM._flowToken (field tay) ── tăng khi schedule
  _onRevealElapsed():  if (phase != answeredPending) return;
                       // token KHÔNG được check → stale có thể lọt

BẢN DRE (M26):
  state.flowToken (trong GameState) ── reducer tăng tại mọi
                                       transition tạo-delay
  GameAnswerRevealElapsed(token-đã-chụp) ── reducer:
       if (flowToken != state.flowToken) → _result(state) // no-op
  Stale = dữ-liệu lệch → action no-op, KHÔNG phải exception.

EFFECT LÀ DATA:
  effects: [GamePauseTimer(), GameScheduleAnswerReveal(token)]
       │                        │
       │                        └─ "hãy hẹn reveal với token này"
       │                           — không Timer bên trong
       └─ "hãy dừng timer" — reducer không gọi cancel()
  Ai thực hiện? VM bridge (Bài 5) — effects.listen(_handleEffect).
```

Điểm sâu của token-in-state: token đi theo `copyWith` như mọi
field → mọi transition đọc `state.flowToken` đều thấy cùng một
con số; không có "field VM" và "state" lệch nhau được nữa.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `sealed class GameAction implements DreAction` | sealed family gắn marker — + |
| `final class GameAnswerRevealElapsed extends GameAction { final int flowToken; }` | action mang payload — token là *data đi cùng intent* |
| `List.unmodifiable(...)`/`Map.unmodifiable`/`Set.unmodifiable` trong ctor | defensive view — state không bị sửa từ ngoài |
| `copyWith({…, bool clearSelectedAnswer = false, bool clearAudiencePercentiles = false})` | cờ clear cho field nullable |
| `factory GameState.initial({required timePerQuestion})` | named ctor — điểm khởi đầu duy nhất của session |
| `export 'game_dre_*.dart'` | barrel — một import cho cả contract |

## Flutter cần dùng

Không có Flutter API mới — cố ý: `dre/` chỉ import `core/dre/` +
`data/` files; không `material`, không `async` Timer. Đây là
bằng chứng "contract là pure Dart" — reducer Bài 4 test được mà
không dựng widget.

## Ví dụ độc lập — stale download bằng token-trong-state (DartPad)

```dart
class DownloadState {
  final int requestToken;
  final String? result;
  const DownloadState(this.requestToken, this.result);
}

sealed class DownloadAction {
  const DownloadAction();
}
final class DownloadRequested extends DownloadAction {
  const DownloadRequested();
}
final class DownloadFinished extends DownloadAction {
  final int token;
  final String data;
  const DownloadFinished(this.token, this.data);
}

DownloadState reduce(DownloadState s, DownloadAction a) => switch (a) {
  DownloadRequested() => DownloadState(s.requestToken + 1, null),
  DownloadFinished(:final token, :final data) =>
    token == s.requestToken
        ? DownloadState(s.requestToken, data)
        : s, // stale — lệch token → no-op, không exception
};

void main() {
  var s = const DownloadState(0, null);
  s = reduce(s, const DownloadRequested());        // click 1 → token 1
  s = reduce(s, const DownloadRequested());        // click 2 → token 2
  s = reduce(s, const DownloadFinished(1, 'OLD')); // A về muộn
  print(s.result); // null — bị loại bởi token, không phải catch
  s = reduce(s, const DownloadFinished(2, 'NEW'));
  print(s.result); // NEW
}
```

Đây chính là ý tưởng `_requestId` dời vào state: stale là
**dữ liệu lệch**, không phải lỗi cần bắt.

## Android / Compose bridge

**SIMILARITY — `requestId`/`job token` trong `UiState`.** Giữ một
int tăng đơn điệu trong state và drop kết quả cũ khi token lệch
giống pattern "latest wins" của `collectLatest`/job-cancellation
— chỉ khác ở đây huỷ bằng so sánh data, không huỷ coroutine.

**IMPORTANT DIFFERENCE — action mang token, state giữ token mới
nhất.** Trên Android thường giữ `job` và `cancel()`; ở đây không
huỷ `Future` (đơn luồng, delay không hủy được sau khi lên lịch) —
thay vào đó reducer bỏ qua action mang token cũ. Huỷ ảo bằng data.

**DO NOT ASSUME — `List.unmodifiable` ≠ immutable type.** Nó là
view ném `UnsupportedError` khi mutate — copyWith luôn tạo list
mới thay vì sửa tại chỗ.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/view_models/game/dre/game_dre_state.dart` | `GameState` 13 field + `initial` + `copyWith`/`clear*` — verbatim |
| `lib/view_models/game/dre/game_dre_action.dart` | `sealed GameAction` + 14 variant senior; learner **13** — trừ `GameShareRequested` (M27) |
| `lib/view_models/game/dre/game_dre_effect.dart` | 8 variant senior; learner **7** — trừ `GameShareResult` (M27) |
| `lib/view_models/game/dre/game_dre_async_op.dart` | `GameSaveResult{earnedAmount, isWin, questionCount}` — verbatim |
| `lib/view_models/game/dre/game_dre_contract.dart` | barrel 4 dòng — verbatim |

:::tip[Suy luận trước khi đọc code — DERIVE: kiểm kê contract]
Bốn file sắp port là *contract* của toàn bộ DRE — đừng port mù. Tự
kiểm kê bốn rổ trước (giấy / file nháp), dùng chính VM trung gian
733 dòng mà Bài 1–2 đã mổ:

1. **STATE — cái gì phải tồn tại?** Liệt kê field mà một trạng thái
   game phải mang để UI render được mọi màn hình đã build tới M25:
   câu hỏi hiện tại + index, tiền, timer, answer đã chọn, trạng thái
   reveal, lifeline còn/dùng, kết quả… Và — theo model trên — field
   nào thay thế `_flowToken` tay của VM?
2. **ACTION — cái gì *xin* reducer chuyển trạng thái?** Với mỗi hành
   động user/hệ thống bạn biết (tap đáp án, hết giờ, dùng 50:50, kết
   thúc game…), viết một tên action + payload cần mang. Nhớ luật:
   action chỉ *mô tả sự việc*, không chứa logic.
3. **EFFECT — cái gì phải *rời* phần reduce thuần?** Những việc nào
   reducer không được tự làm (đụng thời gian, I/O, điều hướng)? Liệt
   kê chúng như *dữ liệu ý định*.
4. **OP — việc async nào phải chạy *sau* reduce?** Từ các effect ở
   (3), nhóm những cái thành một tác vụ async duy nhất nếu chúng cùng
   phục vụ một mục đích.
5. **Ranhm giới ai-gọi-ai.** Ai dispatch action? Ai nhận effect? Ai
   chạy op? Vẽ một mũi tên một chiều cho mỗi quan hệ — nếu thấy mũi
   tên ngược (state gọi VM, effect gọi reducer) thì đánh dấu lại.

Sau đó mới mở các bước bên dưới và đối chiếu — đừng cố đoán trúng
từng tên variant của senior; đoán đúng *loại* và *vai trò* là đủ.

<details>
<summary>Đối chiếu sau khi tự kiểm kê</summary>

1. `GameState` 13 field: phase, questionIndex, earnings,
   remainingSeconds, selectedAnswer, revealToken→`flowToken`,
   lifeline flags, fiftyFiftyRemoved, audiencePercentiles, hasSaved…
   — field token chính là `flowToken` bạn đoán ở (1).
2. `GameAction` 13 variant: `GameStarted`, `GameAnswerSubmitted`,
   `GameAnswerRevealElapsed{flowToken}`, `GameTimerTicked`,
   `GameFeatureSelected{type}`, `GameWalkAwayConfirmed`,
   `GameBackToMenuRequested`… — mỗi variant là *một sự việc đã xảy
   ra hoặc được xin*, không phải lệnh.
3. `GameEffect` 7 variant: `GameStartTimer`, `GamePauseTimer`,
   `GameStopTimer`, `GameScheduleAnswerReveal{token}`,
   `GameScheduleExplanation`, `GameScheduleAIAssistant`,
   `GameNavigateToMenu` — toàn là *ý định*, không phải tác dụng phụ
   đã chạy.
4. `GameAsyncOp` gom phần async sau reduce — đúng một variant
   `GameSaveResult{earnedAmount, isWin, questionCount}` là op lưu
   kết quả một-lần.
5. UI/VM dispatch action → reducer (state,action)→(state,effects)
   → VM bridge nhận effect → op chạy → op phát action mới. Một
   chiều duy nhất: không có mũi tên ngược.

</details>
:::

## Build it step by step

**Bước 1 — `lib/view_models/game/dre/game_dre_state.dart`** (file
mới — verbatim senior; trích field block + ctor + `initial` +
`copyWith` signature):

```dart
import '../../../data/game/game_screen_data.dart';
import '../../../data/game/game_session_state_data.dart';

class GameState {
  final GamePhase phase;
  final int questionIndex;
  final int moneyEarned;
  final int guaranteedAmount;
  final int moneyAnimationTrigger;
  final bool hasSavedResult;
  final Duration remainingTime;
  final String? selectedAnswer;
  final List<String> visibleOptionTexts;
  final Map<String, int>? audiencePercentiles;
  final Set<GameFeatureButtonType> usedFeatureButtons;
  final GameDialogState dialogState;
  final int flowToken;

  GameState({
    required this.phase,
    // … 7 field còn lại required (questionIndex → selectedAnswer) …
    required List<String> visibleOptionTexts,
    required Map<String, int>? audiencePercentiles,
    required Set<GameFeatureButtonType> usedFeatureButtons,
    required this.dialogState,
    required this.flowToken,
  }) : visibleOptionTexts = List.unmodifiable(visibleOptionTexts),
       audiencePercentiles = audiencePercentiles == null
           ? null
           : Map.unmodifiable(audiencePercentiles),
       usedFeatureButtons = Set.unmodifiable(usedFeatureButtons);

  factory GameState.initial({required Duration timePerQuestion}) {
    return GameState(
      phase: GamePhase.notStarted,
      questionIndex: 0,
      moneyEarned: 0,
      guaranteedAmount: 0,
      moneyAnimationTrigger: 0,
      hasSavedResult: false,
      remainingTime: timePerQuestion,
      selectedAnswer: null,
      visibleOptionTexts: const [],
      audiencePercentiles: null,
      usedFeatureButtons: const {},
      dialogState: const GameDialogHidden(),
      flowToken: 0,
    );
  }
}
```

— kèm `copyWith` đủ 13 named params + hai cờ
`clearSelectedAnswer`/`clearAudiencePercentiles` (verbatim senior:
`clearX ? null : x ?? this.x`).

**Bước 2 — `game_dre_action.dart`** (file mới — verbatim senior
trừ share; 13 variant, trích hai variant mang token):

```dart
import '../../../core/dre/dre.dart';
import '../../../data/game/game_screen_data.dart';

sealed class GameAction implements DreAction {
  const GameAction();
}

final class GameAnswerSubmitted extends GameAction {
  final String answerText;

  const GameAnswerSubmitted(this.answerText);
}

final class GameAnswerRevealElapsed extends GameAction {
  final int flowToken;

  const GameAnswerRevealElapsed(this.flowToken);
}

// + GameStarted, GameDialogDismissed, GameExplanationElapsed(flowToken),
//   GameFeatureSelected(type: GameFeatureButtonType), GameMoneyLadderRequested,
//   GameConfirmExitRequested, GameConfirmWalkAwayRequested,
//   GameWalkAwayConfirmed, GameTimerTicked,
//   GameAIAssistantElapsed(flowToken), GameBackToMenuRequested
```

**Bước 3 — `game_dre_effect.dart` + `game_dre_async_op.dart`**
(hai file mới — verbatim senior trừ share):

```dart
// effect — 7 variant:
sealed class GameEffect implements DreEffect { const GameEffect(); }
final class GameStartTimer extends GameEffect { const GameStartTimer(); }
final class GamePauseTimer extends GameEffect { const GamePauseTimer(); }
final class GameStopTimer extends GameEffect { const GameStopTimer(); }
final class GameScheduleAnswerReveal extends GameEffect {
  final int flowToken;
  const GameScheduleAnswerReveal(this.flowToken);
}
final class GameScheduleExplanation extends GameEffect {
  final int flowToken;
  const GameScheduleExplanation(this.flowToken);
}
final class GameScheduleAIAssistant extends GameEffect {
  final int flowToken;
  const GameScheduleAIAssistant(this.flowToken);
}
final class GameNavigateToMenu extends GameEffect { const GameNavigateToMenu(); }
```

```dart
// async_op — đúng một variant:
sealed class GameAsyncOp implements DreAsyncOp { const GameAsyncOp(); }

final class GameSaveResult extends GameAsyncOp {
  final int earnedAmount;
  final bool isWin;
  final int questionCount;

  const GameSaveResult({
    required this.earnedAmount,
    required this.isWin,
    required this.questionCount,
  });
}
```

**Bước 4 — `game_dre_contract.dart`** (barrel — verbatim senior):

```dart
export 'game_dre_action.dart';
export 'game_dre_async_op.dart';
export 'game_dre_effect.dart';
export 'game_dre_state.dart';
```

## Hiểu code — bốn chi tiết dễ trượt

1. **`flowToken` trong state ≠ field VM.** Token đi theo `copyWith`
   như mọi field — reducer tăng tại mọi transition tạo delay
   (Bài 4); `*Elapsed` chỉ mang con số đã chụp, so sánh là việc của
 reducer. Không còn "field VM" lệch "state".
2. **Vì sao `GameScheduleAnswerReveal(flowToken)` chứ không phải
   `Timer`:** reducer phải thuần — không `dart:async` Timer, không
   delay; "hẹn 1500ms" là việc của bridge (Bài 5). Effect chỉ nói
 *hẹn cái gì với token nào*.
3. **`List.unmodifiable` trong ctor chặn sửa ngầm:** caller truyền
   `questions.first.options` — data bank; view unmodifiable chặn
   ai đó mutate state từ ngoài. Muốn đổi → `copyWith` list mới.
4. **`GameState` KHÔNG `==`:** `!=` trong dispatch (Bài 2) là
   identity → mọi instance mới đều notify, kể cả `copyWith` giữ
   nguyên field — đặt sẵn cho divergence `dismissDialog` ở Bài 5.

## Chạy và quan sát

```text
flutter analyze → No issues found!
flutter test    → +241: All tests passed!   (giữ nguyên — scaffold)
```

Năm file **chưa ai import** — đây là scaffold của migration:
contract compile sạch trước, consumer (`GameReducer` Bài 4, VM
Bài 5) nối sau. `flutter analyze` không flag "unused class" —
analyzer chỉ flag unused import/variable/local.

## Thử nghiệm

Đoán trước rồi kiểm trong DartPad (hoặc đọc lại `copyWith`):
`GameState.initial(timePerQuestion: const Duration(seconds: 30))
.copyWith(phase: GamePhase.playing, dialogState: const
GameDialogHidden())` — `flowToken` bằng mấy? `selectedAnswer`?
Và `flutter analyze` có báo unused class cho `GameState` không?

<details>
<summary>Đáp án</summary>

- `flowToken == 0`, `selectedAnswer == null` — `copyWith` chỉ đụng
  field được truyền; token chỉ đổi khi reducer truyền
  `flowToken:` (Bài 4). Đây là điểm mấu chốt: dialog đóng không
  tự động vô hiệu delay đã hẹn — guard khác (`dialogState is! …`)
  mới bắt ca đó (Bài 6, regression test 2).
- Analyzer **không** flag — class top-level không được import vẫn
  hợp lệ; "unused" chỉ áp cho import/variable/private-element.
</details>

## Lỗi hay gặp

1. **Thêm `==` cho `GameState` "cho sạch"** — senior không có;
   identity-diff là cố ý: mọi object mới notify, guard
   `_result(state)` same-instance im lặng (Bài 4).
2. **Đặt `Timer`/`Future` vào effect variant** — phá purity;
   effect chỉ payload `int` (và kiểu primitive khác).
3. **Sửa `visibleOptionTexts` in-place** — unmodifiable →
   `UnsupportedError`; đổi qua `copyWith`.
4. **Cho `GamePhase`/`GameDialogState` vào `dre/`** — senior giữ
   chúng trong `data/game/game_session_state_data.dart`; chỉ
   session-model `GameState` sống trong `dre/`.
5. **Tưởng `flowToken` reset về 0 mỗi ván** — `_startGame` (Bài 4)
   dùng `state.flowToken + 1` trên initial mới: token **monotonic
   qua restarts**, vô hiệu mọi delay còn lửng của ván trước.

## Tự làm — PRODUCE

Trên giấy/DartPad (chưa vào repo): viết chuỗi `copyWith` mô phỏng
"dismiss dialog khi đang playing" trên `GameState` — từ
`GameState.initial`, đặt `phase: GamePhase.playing` +
`dialogState: const GameDialogHidden()`. Trả lời: `flowToken`,
`selectedAnswer`, `remainingTime` đổi không? Vì sao?

:::note[Gợi ý]
`copyWith` chỉ thay field được truyền tên; `dialogState` là named
param thường.
:::

<details>
<summary>Đáp án</summary>

```dart
final next = GameState.initial(
  timePerQuestion: const Duration(seconds: 30),
).copyWith(
  phase: GamePhase.playing,
  dialogState: const GameDialogHidden(),
);
```

Chỉ hai field đổi; `flowToken` giữ (0), `selectedAnswer` giữ
(null), `remainingTime` giữ. Đây chính là lý do một delay đã hẹn
vẫn "hợp lệ token" sau khi dialog đóng — Bài 4–5 sẽ thấy guard
`dialogState is! …` là thứ bắt ca đó, không phải token.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao `*Elapsed` mang `flowToken` thay vì tự check
  `_isDisposed`? — **Đáp:** dispose-safety là việc của bridge
  (`_isDisposed` guard, Bài 5); token trong action giải bài toán
  *stale* — callback của flow cũ đến khi flow mới đã tăng token.
- **Hỏi:** `GameSaveResult` là effect hay asyncOp, vì sao? —
  **Đáp:** asyncOp — nó cần `await` IO với snapshot post-reduce;
 effect là ý định đồng bộ (timer/nav) fan qua stream.
- **Hỏi:** vì sao file chưa ai import vẫn được giữ? — **Đáp:**
  scaffold — contract phải tồn tại trước reducer (Bài 4) và VM
  (Bài 5); analyze sạch vì analyzer không flag unused top-level
  class.
- **Hỏi:** `GameShareRequested`/`GameShareResult` ở đâu? —
 **Đáp:** cố ý thiếu — M27/; reducer switch Bài 4 exhaustive
  trên 13 variant hiện có.

## Ta cố ý chưa thêm

- `GameReducer` + `GameScreenViewModel` mới — **Bài 4–5** (consumer
  của contract này).
- Xoá `GameSessionState` khỏi `data/` — **Bài 5** (vẫn đang được
  VM cũ dùng).
- Share plumbing `GameShareRequested`/`GameShareResult`/
 `GameShareResultEvent`/`shareResult` — **M27**.
- Platform extras — **M27**; visual parity — **M28**;
  `MenuDialogLayer` — **M29**.

## Checkpoint hoàn thành

- [ ] `lib/view_models/game/dre/` đủ 5 file: state/action/effect/
  asyncOp/contract — verbatim (trừ share).
- [ ] `GameState` 13 field đúng thứ tự; `initial` + `copyWith` +
  hai cờ `clear*`; unmodifiable wrappers.
- [ ] `flutter analyze` sạch; `flutter test` **241/241** (chưa ai
  import — scaffold).
- [ ] Liệt kê được 13 action / 7 effect / 1 asyncOp; giải thích
  token-in-state vs VM field và effect là data.
