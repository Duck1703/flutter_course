---
title: "Bài 5 · VM migration + bridges — DreChangeNotifier thật"
description: "Rewrite `game_screen_view_model.dart` 733→166 dòng: `extends DreChangeNotifier<GameState,GameAction,GameEffect,GameAsyncOp>`; ctor wire `GameReducer` + `GameState.initial`; `effects.listen(_handleEffect)` → timers/delay/nav; `executeAsyncOp` → `_saveGameResult`; 2 `part 'bridge/…'`; xoá `GameSessionState` khỏi `data/`. Public API giữ nguyên → zero call-site edits → 251 xanh nguyên."
sidebar:
  label: "Bài 5 · VM migration + bridges"
  order: 5
---

## Mục tiêu

- Rewrite `lib/view_models/game/game_screen_view_model.dart` →
  `extends DreChangeNotifier<GameState, GameAction, GameEffect,
  GameAsyncOp>` (166 dòng): ctor wire `GameReducer(questions:,
  timePerQuestion:)` + `GameState.initial`; `_effectSubscription =
  effects.listen(_handleEffect)`; mọi public method là `dispatch`
  one-liner; `dispose` cancel timer/subscription/events → `super`.
- Tạo hai `part 'bridge/…'`: `game_screen_view_model_effects.dart`
  (`_handleEffect` switch → `_startTimer`/`_pauseTimer`/
 `_stopTimer`/`_schedule*`/`_events.add`) và
  `game_screen_view_model_result_persistence.dart`
  (`_saveGameResult`/`_syncSavedGameResult`/`_applyLevelProgression`/
 `_normalizedLevel` verbatim — giữ).
- Xoá `GameSessionState` khỏi `data/game/
  game_session_state_data.dart` (+ unused import) — senior giữ
  session-model trong `dre/`.
- Public API không đổi một chữ → **zero call-site edits** → 251
  test xanh nguyên (behavior-preserving refactor).

## Bạn đang ở đâu

- Bài 4: `GameReducer` + 10 test thuần → 251. Mọi mảnh DRE đã có:
  primitives (Bài 2), contract (Bài 3), reducer (Bài 4) — bài này
  thay "động cơ" của VM: đổi `extends ChangeNotifier` thành
  `extends DreChangeNotifier`, và chuyển timer/delay/persistence
  thành bridge cho effects/asyncOp.
- `game_screen.dart` + widget tests + `game_screen_view_model_
  test.dart` (`startedVm` + FakeAsync) **không sửa** — public
  surface đông cứng: refactor là việc bên trong.
- `GameSessionState` chỉ được xoá *sau khi* VM chuyển — hai
  session-model không được phép song song.

## Vì sao việc này quan trọng ngay bây giờ

Đây là khoảnh khắc "đổi chủ" của milestone: VM ngừng *làm*
transition và trở thành *bộ chuyển tiếp* — UI gọi method public,
method dispatch action, reducer quyết transition, effects/asyncOp
quay lại VM dưới dạng `Timer`/`Future`/repository-call. Điểm
mạnh của refactor đúng kiểu: `game_screen.dart` không đổi một
dòng, `startedVm` không đổi, 251 test xanh nguyên — vì contract
với thế giới bên ngoài (`screenData`, `dialogState`, `uiEvents`,
public methods, `ListenableBuilder`) được giữ nguyên trong khi
toàn bộ cơ chế bên trong đổi chủ.

## Bạn đã biết gì

- `DreChangeNotifier` + dispatch loop + `executeAsyncOp` +
 `onAsyncOpError` (Bài 2); `GameReducer` + effects +
  `GameSaveResult` op (Bài 3–4).
- `part`/`part of` + private extension (Bài 4); `unawaited`
; `_isDisposed` guard trên delayed callback (M13/M19);
  `StreamController.broadcast` + `_events` kênh UI-event (M13).
- `_saveGameResult`/`_syncSavedGameResult`/`_applyLevelProgression`
 từ bản trung gian (M22/M25): code *giữ verbatim*,
  chỉ đổi *chỗ đứng* (part file) và *đường gọi* (op thay
  `_emitWithSaveResult`).

## Mental model — "VM = bộ chuyển tiếp hai chiều" (NORMAL)

```text
UI tap ──→ public method ──→ dispatch(GameAction)
                                  │
                                  ▼
                            GameReducer.reduce      (Bài 4 — THUẦN)
                                  │
        ┌─────────────────────────┼──────────────────────────┐
        ▼                         ▼                          ▼
     result.state             result.effects            result.asyncOp
  notifyListeners → UI    _effects stream ──→ _handleEffect   executeAsyncOp
  redraw (mapper)             │  GameStartTimer  → _startTimer  │ GameSaveResult
                            │  GameSchedule*   → Future.delayed→ _saveGameResult
                            │    → dispatch(*Elapsed)         │  (snapshot post-reduce)
                            │  GameNavigateToMenu→ _events.add│
                            └─ bridge = phần VM LÀM việc —    └─ op = IO boundary
                               Timer/Future/repo/stream
```

Hai `part 'bridge/…'` chính là nơi *ý định thành hành động*:
reducer không biết `Timer` tồn tại — bridge biết, và đó là lý
do bridge sống ở VM.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `part 'bridge/game_screen_view_model_effects.dart'` | part lần ba trong course (sau M24 dialog, Bài 4 reducer) — VM-side bridges (reuse) |
| `super(reducer: …, initialState: …)` | base ctor named args — wire reducer + state khởi đầu |
| `effects.listen(_handleEffect)` trong ctor + `late final StreamSubscription` | subscribe ngay khi tạo; cancel ở dispose |
| `case GameSaveResult(final earnedAmount, :final isWin, :final questionCount)` | object pattern destructure op |
| `void _dispatchGameAction(GameAction a) => dispatch(a)` | private helper: bridge re-dispatch `*Elapsed`/`GameTimerTicked` (dispatch là `@protected`) |
| `switch (effect)` / `switch (asyncOp)` | exhaustive trên sealed family — Dart bắt đủ case |

## Flutter cần dùng

Không API mới — chỉ là *chỗ đứng mới* cho API cũ: `Timer` +
`Timer.periodic` (M19/M20), `Future.delayed` + `_isDisposed`
guard (M13/M19), `StreamController.broadcast` + `StreamSubscription`
(M13 — kênh `uiEvents`), `debugPrint` (logging M22). Điểm mới là
chúng tập trung trong hai `part 'bridge/…'` thay vì rải trong
method — effect object quyết *việc gì*, bridge quyết *bằng cách nào*.

## Ví dụ độc lập — effect bridge thu nhỏ (DartPad, `dart:async`)

```dart
import 'dart:async';

void main() {
  final effects = StreamController<String>.broadcast();
  final log = <String>[];

  // "bridge": effect data → hành động thật — đúng shape _handleEffect
  final sub = effects.listen((e) {
    switch (e) {
      case 'start':
        log.add('timer started');
      case 'nav':
        log.add('event emitted');
    }
  });

  effects
    ..add('start')
    ..add('nav')
    ..add('start');
  Future<void>.delayed(Duration.zero, () {
    print(log); // [timer started, event emitted, timer started]
    sub.cancel();
    effects.close();
  });
}
```

Map trực tiếp: `String` ↔ `GameEffect` sealed; listener ↔
`_handleEffect` switch; `effects.listen(...)` trong `main` ↔
ctor VM gọi `effects.listen(_handleEffect)`.

## Android / Compose bridge

**SIMILARITY — `viewModelScope` + effect channel collector.** Hai
bridge part ≈ một `collect { when (effect) … }` trong init block;
`executeAsyncOp` ≈ `viewModelScope.launch` trên một sealed
`SideEffect` — chỉ khác Dart chạy `unawaited` thay coroutine.

**IMPORTANT DIFFERENCE — dispatch là đồng bộ.** `dispatch` chạy
hết trong lời gọi (không suspend); phần async chỉ là op
`unawaited` + delayed re-dispatch — không `MutableStateFlow.update`
cần CAS-loop.

**DO NOT ASSUME — bridge không phải nơi đặt luật.** `_handleEffect`
chỉ *thực hiện*; quyết định "khi nào pause timer" đã chốt trong
reducer. Logic nghiệp vụ lọt vào bridge = reducer mất vai.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/view_models/game/game_screen_view_model.dart` | VM 152 dòng senior (learner 166 — doc VI) trừ `shareResult`/`GameShareRequested` → M27 |
| `bridge/game_screen_view_model_effects.dart` | `_handleEffect` + `_startTimer`/`_pauseTimer`/`_stopTimer` + 3 `_schedule*` — verbatim |
| `bridge/game_screen_view_model_result_persistence.dart` | `_saveGameResult`/`_syncSavedGameResult`/`_applyLevelProgression`/`_normalizedLevel` — verbatim |
| `lib/data/game/game_session_state_data.dart` | senior file giữ `GamePhase`+`GameDialogState`+`GameScreenUiEvent` — session model KHÔNG ở `data/` |

## Build it step by step

**Bước 1 — rewrite `lib/view_models/game/game_screen_view_model.dart`**
(verbatim senior + doc VI; trích ctor + wrappers + `executeAsyncOp`
+ `dispose` — `screenData`/`dialogState`/`uiEvents` giữ nguyên đọc
từ `state`). **CHƯA COMPILE đến hết Bước 3** — hai `part
'bridge/…'` file chưa tồn tại.

```dart
part 'bridge/game_screen_view_model_effects.dart';
part 'bridge/game_screen_view_model_result_persistence.dart';

class GameScreenViewModel
    extends DreChangeNotifier<GameState, GameAction, GameEffect, GameAsyncOp> {
  static const timePerQuestion = Duration(seconds: 30);
  static const _answerRevealDelay = Duration(milliseconds: 1500);
  static const _explanationDelay = Duration(milliseconds: 1000);
  static const _aiAssistantDelay = Duration(milliseconds: 700);

  final UserProfileRepository userProfileRepository;
  final AuthRepository authRepository;
  final UserProfileSyncRepository profileSyncRepository;
  final List<GameQuizQuestionData> questions;
  final _events = StreamController<GameScreenUiEvent>.broadcast();
  late final StreamSubscription<GameEffect> _effectSubscription;
  Timer? _timer;
  var _isDisposed = false;

  GameScreenViewModel({
    required this.userProfileRepository,
    required this.authRepository,
    required this.profileSyncRepository,
    this.questions = gameSampleQuestions,
  }) : super(
         reducer: GameReducer(
           questions: questions,
           timePerQuestion: timePerQuestion,
         ),
         initialState: GameState.initial(timePerQuestion: timePerQuestion),
       ) {
    _effectSubscription = effects.listen(_handleEffect);
  }
```

— phần còn lại của file (verbatim senior):

```dart
  void startNewGame() {
    dispatch(const GameStarted());
  }

  void submitAnswer(GameAnswerOptionData answer) {
    dispatch(GameAnswerSubmitted(answer.answerText));
  }

  void handleFeatureClick(GameFeatureButtonData button) {
    if (!button.isEnabled) return;

    dispatch(GameFeatureSelected(button.type));
  }

  // … showMoneyLadder/showConfirmExit/showConfirmWalkAway/
  //   dismissDialog/confirmWalkAway/backToMenu — đều dispatch(const …())
  void playAgain() {
    startNewGame();
  }

  void _dispatchGameAction(GameAction action) {
    dispatch(action);
  }

  @override
  Future<void> executeAsyncOp(
    GameAsyncOp asyncOp,
    GameState stateSnapshot,
  ) async {
    switch (asyncOp) {
      case GameSaveResult(
        :final earnedAmount,
        :final isWin,
        :final questionCount,
      ):
        await _saveGameResult(
          earnedAmount: earnedAmount,
          isWin: isWin,
          questionCount: questionCount,
        );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _effectSubscription.cancel();
    _events.close();
    super.dispose();
  }
```

**Bước 2 — `lib/view_models/game/bridge/game_screen_view_model_effects.dart`**
(file mới — verbatim senior):

```dart
part of '../game_screen_view_model.dart';

extension _GameScreenViewModelEffects on GameScreenViewModel {
  void _handleEffect(GameEffect effect) {
    switch (effect) {
      case GameStartTimer():
        _startTimer();
      case GamePauseTimer():
        _pauseTimer();
      case GameStopTimer():
        _stopTimer();
      case GameScheduleAnswerReveal(:final flowToken):
        _scheduleAnswerReveal(flowToken);
      case GameScheduleExplanation(:final flowToken):
        _scheduleExplanation(flowToken);
      case GameScheduleAIAssistant(:final flowToken):
        _scheduleAIAssistant(flowToken);
      case GameNavigateToMenu():
        _events.add(const GameNavigateToMenuEvent());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _dispatchGameAction(const GameTimerTicked());
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _scheduleAnswerReveal(int flowToken) {
    Future<void>.delayed(GameScreenViewModel._answerRevealDelay, () {
      if (!_isDisposed) {
        _dispatchGameAction(GameAnswerRevealElapsed(flowToken));
      }
    });
  }
  // _scheduleExplanation / _scheduleAIAssistant — cùng mẫu, delay khác — verbatim
}
```

**Bước 3 — `lib/view_models/game/bridge/game_screen_view_model_result_persistence.dart`**
(file mới — verbatim senior; code giữ y từ bản trung gian, chỉ
đổi chỗ đứng + đường gọi):

```dart
part of '../game_screen_view_model.dart';

extension _GameScreenViewModelResultPersistence on GameScreenViewModel {
  Future<void> _saveGameResult({
    required int earnedAmount,
    required bool isWin,
    required int questionCount,
  }) async {
    try {
      final current = await userProfileRepository.loadUserProfile();
      // … leveledProfile + savedProfile copyWith + saveUserProfile
      //     + debugPrint + _syncSavedGameResult() — verbatim M22/M25
    } catch (error) {
      debugPrint('Failed to save game result: $error');
    }
  }

  Future<void> _syncSavedGameResult() async {
    try {
      final session = await authRepository.loadAuthState();
      if (session is AuthSessionAuthenticated) {
        debugPrint('[game] result profile sync started');
        await profileSyncRepository.syncUserProfile(session);
        debugPrint('[game] result profile sync completed');
        return;
      }
      debugPrint('[game] result profile sync skipped; session=guest');
    } catch (error) {
      debugPrint('[game] result profile sync failed: $error');
    }
  }
  // _applyLevelProgression / _normalizedLevel — verbatim M22
}
```

**Bước 4 — `lib/data/game/game_session_state_data.dart`**: xoá
class `GameSessionState` (session model đã chuyển thành `GameState`
trong `dre/`) + bỏ import không còn dùng. File giữ đúng layout
senior: `GamePhase` + `GameDialogState` family +
`GameScreenUiEvent`/`GameNavigateToMenuEvent`.

**Bước 5 — `flutter analyze` + `flutter test`** → 251 xanh nguyên:
không một dòng test/call-site nào phải sửa.

## Hiểu code — năm chi tiết dễ trượt

1. **`GameState` không `==` → mọi instance mới notify.** `!=`
   trong dispatch là identity → chỉ guard `_result(state)`
   same-instance im lặng. Hệ quả (divergence chấp nhận):
   `dismissDialog` khi dialog đã `GameDialogHidden` rơi default
   branch → `copyWith` tạo instance mới → +1 notify — verbatim
   senior, bản cũ early-return.
2. **Delayed re-dispatch là vòng kín data.** `_scheduleAnswerReveal`
   → `Future.delayed(1500ms)` → `_isDisposed` check →
   `_dispatchGameAction(GameAnswerRevealElapsed(token))` — token
 đi state→effect→action→reducer check. `Timer.periodic`
   cũng vậy: tick → `GameTimerTicked` — mọi "sự kiện ngoài" quay
   lại là *action*, không phải mutation trực tiếp.
3. **`handleFeatureClick` giữ `if (!button.isEnabled) return;`**
   — guard ngoài dispatch (senior verbatim): `_canUseFeature`
   vẫn chặn bên trong reducer; guard ngoài là fast-path + giữ
   contract UI quen thuộc.
4. **`executeAsyncOp` nhận snapshot POST-reduce.** Op
   `GameSaveResult` mang `earnedAmount/isWin/questionCount` trong
   *payload* — `_saveGameResult` đọc từ op chứ không đọc `state`
 (state có thể đã đổi tiếp khi op chạy `unawaited`).
5. **Dispose order:** `_isDisposed = true` → `_timer?.cancel()` →
   `_effectSubscription.cancel()` → `_events.close()` →
   `super.dispose()` (đóng effects stream + flag base). Quên
   cancel subscription = listener sống sau VM chết.

## Chạy và quan sát

```text
flutter analyze → No issues found!
flutter test    → +251: All tests passed!   (KHÔNG sửa test nào)
```

`game_screen_test.dart` (widget) xanh nguyên chứng tỏ UI contract
đông cứng; `game_screen_view_model_test.dart` (`startedVm` +
FakeAsync) xanh nguyên chứng tỏ mọi nhịp delay/timer đi qua
bridge đúng `Future.delayed`/`Timer.periodic` như cũ.

## Thử nghiệm

Đoán: nếu xoá `if (!button.isEnabled) return;` khỏi
`handleFeatureClick`, behavior đổi gì, test nào đỏ?

<details>
<summary>Đáp án</summary>

**Không test nào đỏ** — `_canUseFeature` trong reducer vẫn chặn
(`usedFeatureButtons`/`walkAwayAmount > 0`/`phase == playing`).
Guard ngoài là verbatim senior: fast-path UX (không dispatch một
action vô nghĩa) + giữ shape public quen thuộc — hai lớp guard,
hai vai khác nhau: UI-guard (không nên bấm được) vs reducer-guard
(không được chuyển).
</details>

## Lỗi hay gặp

1. **Gọi `dispatch` từ UI/widget** — `@protected` + chỉ VM gọi;
   UI đi qua public methods (contract không đổi).
2. **Giữ `GameSessionState` "dự phòng"** — hai session-model song
   song = drift; senior chỉ một `GameState` trong `dre/`.
3. **Quên `_effectSubscription.cancel()`** — listener sống sau
   dispose; dù `_isDisposed` chặn dispatch, subscription vẫn giữ
   reference (leak).
4. **Đọc `state` trực tiếp trong `_saveGameResult` thay payload
   op** — op-snapshot là điểm đóng băng post-reduce; state có thể
   đổi tiếp trước khi op chạy.
5. **Để `onAsyncOpError` throw ngầm** — game không override hook
   (senior); `_saveGameResult` tự try/catch nuốt+log. Override
   khi VM khác cần báo lỗi op lên trên.

## Tự làm — DEBUG (planted bug)

Trong `_handleEffect`, đổi nhánh `GameNavigateToMenu()` từ
`_events.add(const GameNavigateToMenuEvent())` thành
`_dispatchGameAction(const GameBackToMenuRequested())` — tức
effect re-dispatch lại action cha. Đoán: `backToMenu()` một lần
xảy ra gì? `saveCallCount` có vượt 1 không?

:::note[Gợi ý]
`_backToMenu` emit `GameNavigateToMenu` trong effects — và
`_withSaveResult` khi `hasSavedResult` vẫn trả `effects: effects`.
:::

<details>
<summary>Đáp án — đã verify bằng đọc code</summary>

Vòng lặp vô hạn: `backToMenu` → effect `GameNavigateToMenu` →
bridge re-dispatch `GameBackToMenuRequested` → reducer lại emit
`GameNavigateToMenu` (effects pass-through kể cả khi
`hasSavedResult` đã true) → lại dispatch… qua stream listener,
không bao giờ settle — app đơ. `saveCallCount` vẫn `== 1` nhờ
guard `hasSavedResult` — save-once được giữ, nhưng guard không
cứu được vòng lặp effect→action→effect. Bài học: effect là
*điểm cuối* (hành động), không phải đầu vào — re-dispatch effect
về action cha phá chiều dữ liệu.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** `executeAsyncOp` nhận snapshot nào, và op đọc data từ
  đâu? — **Đáp:** `_state` post-reduce; op mang payload riêng
  (`earnedAmount`/`isWin`/`questionCount`) — `_saveGameResult`
  đọc payload, không đọc `state`.
- **Hỏi:** `GameNavigateToMenu` khác `GameNavigateToMenuEvent`
  thế nào? — **Đáp:** effect (reducer→VM, stream `effects`) vs
  UI-event (VM→widget, stream `uiEvents`); bridge dịch một thành
  một — hai bus cho hai hướng.
- **Hỏi:** vì sao `GameSessionState` bị xoá khỏi `data/`? —
  **Đáp:** senior giữ session-model cùng contract trong `dre/`;
  `data/` chỉ còn `GamePhase`/`GameDialogState`/`GameScreenUiEvent`
  — type dùng chung UI + VM.
- **Hỏi:** vì sao 251 test không cần sửa? — **Đáp:** public API
  giữ nguyên (`startNewGame`…`uiEvents`, `state`, `dialogState`,
  `screenData`); refactor đổi cơ chế bên trong, contract đông cứng.

## Ta cố ý chưa thêm

- `shareResult` + `GameShareRequested`/`GameShareResult`/
 `GameShareResultEvent` — **M27**.
- `onAsyncOpError` override — senior game không override;
  `_saveGameResult` tự xử.
- Platform extras (notification/version) — **M27**; visual parity
  — **M28**; `MenuDialogLayer` — **M29**.
- DRE hoá menu/settings/onboarding VMs — senior chỉ áp cho game.

## Checkpoint hoàn thành

- [ ] `game_screen_view_model.dart` `extends DreChangeNotifier<…>`,
  166 dòng; mọi public method là `dispatch` one-liner; `dispose`
  cancel đủ timer/subscription/events.
- [ ] Hai `part 'bridge/…'` tồn tại: effects (timer/delay/nav) +
  result persistence (`_saveGameResult`/`_syncSavedGameResult`
  verbatim).
- [ ] `GameSessionState` không còn trong `data/game/
  game_session_state_data.dart`.
- [ ] `flutter analyze` sạch; `flutter test` **251/251** — không
  sửa một dòng test nào.
