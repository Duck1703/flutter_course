---
title: "Bài 2 · core/dre — contract + DreChangeNotifier"
description: "Port `lib/core/dre/dre.dart` + `dre_change_notifier.dart`: `abstract interface class` markers + generic bounds `A extends DreAction`; dispatch 5 nhịp — reduce → swap → `!=` notify → effects broadcast → `unawaited` asyncOp post-reduce snapshot + `onAsyncOpError`; `@protected`; dispose-safe. +5 test → 236 → 241."
sidebar:
  label: "Bài 2 · core/dre primitives"
  order: 2
---

## Mục tiêu

- Tạo `lib/core/dre/dre.dart` — ba marker `DreAction`/`DreEffect`/
  `DreAsyncOp` + interface `DreReducer` + `DreResult` (verbatim
  senior, 22 dòng, không doc comment).
- Tạo `lib/core/dre/dre_change_notifier.dart` —
  `DreChangeNotifier<S,A,E,O> extends ChangeNotifier` (75 dòng).
- Thêm `test/core/dre/dre_change_notifier_test.dart` — 5 test qua
  harness private `_TestDreViewModel`/`_TestReducer`; +5 →
  **241/241**.
- Trace được dispatch algorithm đúng nhịp senior: reduce → swap
  `_state` → `previousState != _state` → `notifyListeners()` →
  add effects → `unawaited(_executeAsyncOp(op, _state))` với
 snapshot POST-reduce.

## Bạn đang ở đâu

- Bài 1 đã có mental model + counter reducer — giờ port tầng nền
  generic.
- Hai file `core/dre/` không biết gì về game — `S/A/E/O` là type
  params; game chỉ là consumer đầu tiên (Bài 3–5).
- Chưa ai import → app không đổi; test file là consumer đầu tiên
  chứng minh contract.

## Vì sao việc này quan trọng ngay bây giờ

Toàn bộ "máy" DRE chỉ 97 dòng — viết một lần, mọi state-machine
sau dùng lại. Quan trọng hơn: `dispatch` là **nơi duy nhất**
quyết định notify/effect/async — trước đây logic đó rải qua
`_emit` (notify), `_schedule` (delay), `_emitWithSaveResult`
(`unawaited` save) trong 733 dòng; giờ nó là ~20 dòng
đọc một lần.

## Bạn đã biết gì

- `ChangeNotifier` + `notifyListeners()` + `addListener` (nền
); `StreamController.broadcast` + `listen`/
  `expectLater(emits)` (M13/M15).
- `unawaited` (M22); `_isDisposed` lifecycle +
 `addTearDown`; `==`/identity.
- `sealed` + `final class` + `implements` + `switch` exhaustive
; `_requestId`/`_isSyncing`.

## Mental model mới — "dispatch là thuật toán năm nhịp" 

```text
dispatch(action):
 1. _isDisposed → return                     // dispose-safety trước hết
 2. result = reducer.reduce(_state, action)  // THUẦN — không IO/timer
 3. prev = _state; _state = result.state
    prev != _state → notifyListeners()        // diff identity hoặc ==
 4. for e in result.effects → _effects.add   // broadcast, guard isClosed
 5. result.asyncOp ≠ null →
      unawaited(_executeAsyncOp(op, _state))  // snapshot SAU reduce
```

Hai điểm khoá: (a) snapshot của asyncOp là state **đã swap** —
reducer commit xong mới chạy op, op nhìn thấy kết quả cuối
(`hasSavedResult: true`, phase terminal); (b) `effects` là
broadcast stream — listener đến sau **không được replay**: effect
là sự kiện một lần, khác `BehaviorSubject.seeded`/`ValueStream`
 vốn replay state hiện tại.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `abstract interface class DreAction {}` | type thuần — không instantiate, không `extends`, chỉ `implements`; không member → **marker interface** (mới) |
| `class N<S, A extends DreAction, E extends DreEffect, O extends DreAsyncOp>` | generic bounds — type param phải implement marker |
| `final class DreResult{state, effects: List<E> = const [], asyncOp: O?}` | value carrier; `O?` → tối đa một op per reduce |
| `@protected void dispatch(A action)` | meta annotation — "chỉ subclass dùng"; analyzer warn nếu gọi ngoài |
| `unawaited(future)` (`dart:async`) | fire-and-forget — reuse, lần đầu trong infrastructure class |
| `StreamController<E>.broadcast()` | multi-listener, không replay |
| `Future<void> executeAsyncOp(O, S)` abstract | lỗ hổng bắt buộc cho subclass — VM implement ở Bài 5 |
| `void onAsyncOpError(...) {}` no-op | hook tối thiểu — chỉ gọi khi `!_isDisposed` |

## Flutter cần dùng

| API | Vai trò |
|---|---|
| `ChangeNotifier`/`notifyListeners()` | UI contract `ListenableBuilder` không đổi |
| `@protected` (`package:flutter/foundation.dart`) | annotation cùng nguồn meta |

## Ví dụ độc lập — dispatch loop thu nhỏ (DartPad, bỏ Flutter)

```dart
int reduceCount(int s, String a) => a == 'inc' ? s + 1 : s;

void main() {
  var state = 0;
  final effects = <String>[];
  var notified = 0;

  void dispatch(String action, {List<String> fx = const []}) {
    final prev = state;
    state = reduceCount(state, action);   // nhịp 2 — reduce
    if (prev != state) notified++;        // nhịp 3 — diff + notify
    effects.addAll(fx);                   // nhịp 4 — fan effects
  }

  dispatch('inc', fx: ['beep']);
  dispatch('same');                       // guard → cùng state
  dispatch('inc');
  print('state=$state notified=$notified effects=$effects');
  // state=2 notified=2 effects=[beep] — 'same' KHÔNG notify
}
```

Đây đúng nhịp `DreChangeNotifier.dispatch`: diff trước notify là
lý do guard trả state cũ (Bài 1) im lặng hoàn toàn.

## Android / Compose bridge

**SIMILARITY — `Channel`/`SharedFlow` cho one-shot events.** Effect
stream ≈ `Channel` hoặc `SharedFlow(replay = 0)` — listener mới
không nhận sự kiện cũ; `state` ≈ `StateFlow`.

**IMPORTANT DIFFERENCE — không coroutine scope.** Async op là
`unawaited` future + `onAsyncOpError` hook; cancel/dispose qua
`_isDisposed` flag tay — không `viewModelScope` huỷ job tự động.

**DO NOT ASSUME — `!=` trên object Dart.** `==` chỉ là
value-equal khi class override; `GameState` không override (Bài
3) → diff của dispatch là identity → mọi instance mới notify kể
cả khi field giống — hiểu trước khi thắc mắc "notify dư".

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/core/dre/dre.dart` | 22 dòng verbatim — marker + generic bound + `DreResult` |
| `lib/core/dre/dre_change_notifier.dart` | 75 dòng verbatim — dispatch + `executeAsyncOp` + `onAsyncOpError` + dispose |
| `test/core/dre/dre_change_notifier_test.dart` | 5 test verbatim (đổi package import) — harness `_Test*` private |
| `lib/view_models/menu|settings|onboarding/*.dart` | vẫn `ChangeNotifier` tay — senior chỉ áp DRE cho game VM |

## Build it step by step

**Bước 1 — `lib/core/dre/dre.dart`** (file mới — verbatim senior,
22 dòng, không doc comment):

```dart
abstract interface class DreAction {}

abstract interface class DreEffect {}

abstract interface class DreAsyncOp {}

abstract interface class DreReducer<
  S,
  A extends DreAction,
  E extends DreEffect,
  O extends DreAsyncOp
> {
  DreResult<S, E, O> reduce(S state, A action);
}

final class DreResult<S, E extends DreEffect, O extends DreAsyncOp> {
  final S state;
  final List<E> effects;
  final O? asyncOp;

  const DreResult({required this.state, this.effects = const [], this.asyncOp});
}
```

**Bước 2 — `lib/core/dre/dre_change_notifier.dart`** (file mới —
verbatim senior; trích `dispatch` + cụm async-op/dispose, phần còn
lại là ctor `{required reducer, required S initialState}` seed
`_state` + `StreamController<E>.broadcast()`, getter `state`/
`effects`):

```dart
  @protected
  void dispatch(A action) {
    if (_isDisposed) {
      return;
    }

    final result = reducer.reduce(_state, action);
    final previousState = _state;
    _state = result.state;

    if (previousState != _state) {
      notifyListeners();
    }

    for (final effect in result.effects) {
      if (!_effects.isClosed) {
        _effects.add(effect);
      }
    }

    final asyncOp = result.asyncOp;
    if (asyncOp != null) {
      unawaited(_executeAsyncOp(asyncOp, _state));
    }
  }

  @protected
  Future<void> executeAsyncOp(O asyncOp, S stateSnapshot);

  @protected
  void onAsyncOpError(Object error, StackTrace stackTrace) {}

  Future<void> _executeAsyncOp(O asyncOp, S stateSnapshot) async {
    try {
      await executeAsyncOp(asyncOp, stateSnapshot);
    } catch (error, stackTrace) {
      if (!_isDisposed) {
        onAsyncOpError(error, stackTrace);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _effects.close();
    super.dispose();
  }
```

**Bước 3 — `test/core/dre/dre_change_notifier_test.dart`** (file
mới — 5 test verbatim senior; trích test trục nhất):

```dart
test('async op receives post-reduce state snapshot', () async {
  final viewModel = _TestDreViewModel();
  addTearDown(viewModel.dispose);
  final snapshotExpectation = expectLater(
    viewModel.asyncSnapshots,
    emits(const _TestState(1)),
  );

  viewModel.send(const _StartAsync());

  await snapshotExpectation;
});
```

Bốn test còn lại (port verbatim): `'dispatch applies reducer
state and notifies listeners'` (`send(_Increment())` → `count ==
1`, `notifyCount == 1`); `'dispatch delivers effects without
requiring state change'` (`send(_EmitEffect('saved'))` → `emits(
_TestEffect('saved'))`, `count == 0`); `'unchanged state does not
notify listeners'` (`send(_NoChange())` → `notifyCount == 0`);
`'dispatch after dispose is ignored without leaking effects'`
(`dispose()` → `send(_EmitEffect('ignored'))` → `neverEmits`).

— và harness private (cùng file, dưới `main`; port verbatim — sân
chơi của cả 5 test):

```dart
final class _TestDreViewModel
    extends
        DreChangeNotifier<_TestState, _TestAction, _TestEffect, _TestAsyncOp> {
  _TestDreViewModel()
    : _asyncSnapshots = StreamController<_TestState>.broadcast(),
      super(reducer: const _TestReducer(), initialState: const _TestState(0));

  final StreamController<_TestState> _asyncSnapshots;

  Stream<_TestState> get asyncSnapshots => _asyncSnapshots.stream;

  void send(_TestAction action) => dispatch(action);

  @override
  Future<void> executeAsyncOp(
    _TestAsyncOp asyncOp,
    _TestState stateSnapshot,
  ) async {
    _asyncSnapshots.add(stateSnapshot);
  }

  @override
  void dispose() {
    _asyncSnapshots.close();
    super.dispose();
  }
}

final class _TestReducer
    implements DreReducer<_TestState, _TestAction, _TestEffect, _TestAsyncOp> {
  const _TestReducer();

  @override
  DreResult<_TestState, _TestEffect, _TestAsyncOp> reduce(
    _TestState state,
    _TestAction action,
  ) {
    return switch (action) {
      _Increment() => DreResult(state: _TestState(state.count + 1)),
      _EmitEffect(:final message) => DreResult(
        state: state,
        effects: [_TestEffect(message)],
      ),
      _StartAsync() => DreResult(
        state: _TestState(state.count + 1),
        asyncOp: const _LoadAsync(),
      ),
      _NoChange() => DreResult(state: state),
    };
  }
}
```

— phần còn lại của file: `_TestState` (có `==`/`hashCode`),
`_TestEffect` (có `==`), `sealed _TestAction` + 4 variant
(`_Increment`/`_EmitEffect`/`_StartAsync`/`_NoChange`), `sealed
_TestAsyncOp` + `_LoadAsync` — port verbatim.

## Hiểu code — ba chi tiết dễ trượt

1. **Test 'post-reduce snapshot' chứng minh nhịp 5.** `_StartAsync`
   reduce `count 0→1` + op → `executeAsyncOp` nhận `_TestState(1)`,
   KHÔNG phải state cũ — `_executeAsyncOp(op, _state)` được gọi sau
 khi `_state` đã swap. Op nhìn thấy quyết định đã commit.
2. **'unchanged state does not notify' chứng minh nhịp 3.**
   `_NoChange` trả cùng instance → `prev != next` false →
   `notifyCount == 0`. `GameState` không `==` (Bài 3) vẫn hưởng
   đúng semantics này — guard của `GameReducer` luôn trả đúng
   `state` cũ, không bản copy.
3. **`onAsyncOpError` chỉ gọi khi `!_isDisposed`.** Hook no-op mặc
   định — game VM không override (senior): `_saveGameResult` tự
   try/catch nuốt+log. Và dispatch-sau-dispose: `_isDisposed`
   return sớm → không reduce, không effect leak — test 5 khoá.

## Chạy và quan sát

```text
flutter analyze → No issues found!
flutter test test/core/dre/dre_change_notifier_test.dart → 5/5 xanh
flutter test    → +241: All tests passed!   (236 + 5)
```

Hai file lib chưa có consumer production — test file là chứng
minh contract đầu tiên, y hệt cách senior verify tầng nền.

## Thử nghiệm

Trên `_TestDreViewModel`, đoán `state.count` / `notifyCount` /
effects nhận được sau chuỗi: `send(_Increment())` →
`send(_EmitEffect('a'))` → `send(_EmitEffect('b'))` →
`send(_NoChange())`.

<details>
<summary>Đáp án</summary>

`count == 1` (chỉ `_Increment` đổi), `notifyCount == 1` (một lần
duy nhất — `_EmitEffect`/`_NoChange` trả same state), effects
`['a','b']` — effect không cần state đổi (test 2 đã chứng minh).
Đây là điểm tách: state-diff và effect-fan-out là hai kênh độc
lập.
</details>

## Lỗi hay gặp

1. **`extends DreAction`** — marker là `abstract interface class`:
   chỉ `implements` được; `extends` → compile error "can't be
   extended outside of its library".
2. **Thiếu bound** trên generic param — `DreReducer<GameState,
   GameAction, …>` chỉ hợp lệ khi `GameAction implements DreAction`.
3. **Gọi `dispatch` từ ngoài subclass** — `@protected` warn; public
   API của VM là method cụ thể (`send` ở test, `submitAnswer` ở
   game).
4. **Tưởng broadcast stream replay** — listener trễ không nhận
   effect đã add; cần "giá trị hiện tại" thì đó là `state`.
5. **`executeAsyncOp` đọc `_state` trực tiếp thay snapshot** —
   op chạy `unawaited`, `_state` có thể đã đổi tiếp; dùng param
   `stateSnapshot`.

## Tự làm — PREDICT

Không viết code — đọc `_TestReducer` và trả lời trên giấy:

| # | Nếu dispatch … | `state.count` | `notifyCount` | effects | op? |
|---|---|---|---|---|---|
| a | `_EmitEffect('x')` ×3 | ? | ? | ? | — |
| b | `_StartAsync` rồi `_NoChange` | ? | ? | — | ? |
| c | `_Increment` sau `dispose()` | ? | ? | — | — |

:::note[Gợi ý]
Lần theo đúng 5 nhịp dispatch cho TỪNG `send`: state-diff quyết
`notifyCount`, `effects` fan độc lập — một action có thể phát
effect mà không đổi state.
:::

<details>
<summary>Đáp án</summary>

- a → `0 / 0 / ['x','x','x']` — ba effect emit, state không đổi,
  không notify: effect-fan độc lập state-diff.
- b → `1 / 1` + op chạy với snapshot `_TestState(1)` — `_NoChange`
  không notify và không ảnh hưởng op đã phát `unawaited`.
- c → `0 / 0` — `_isDisposed` return sớm ở nhịp 1: không reduce,
  không notify, không effect (test 5 khoá đúng điều này).
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao `DreAction` là `abstract interface class` chứ
  không phải `abstract class`? — **Đáp:** marker thuần — cấm
  instantiate và cấm `extends` (subclass phải `implements`), ép
 vai "nhãn type" chứ không "chia sẻ code".
- **Hỏi:** `executeAsyncOp` nhận snapshot nào và vì sao
  post-reduce? — **Đáp:** `_state` sau swap — op nhìn thấy quyết
  định đã commit (`hasSavedResult`, phase terminal); đó là ý
  nghĩa test 3.
- **Hỏi:** `effects` broadcast khác `userProfileStream` seeded
  thế nào? — **Đáp:** không replay — effect là sự kiện một lần;
 stream seeded replay state hiện tại cho listener mới.
- **Hỏi:** ai gọi `onAsyncOpError`, và game có override không? —
  **Đáp:** `_executeAsyncOp` gọi khi op throw và VM chưa dispose;
  game KHÔNG override (senior) — `_saveGameResult` tự nuốt+log.

## Ta cố ý chưa thêm

- `GameReducer`/consumer production đầu tiên — **Bài 4–5**.
- `onAsyncOpError` override — senior game không override;
  `_saveGameResult` tự xử (Bài 5).
- Share plumbing — **M27**; platform extras — **M27**;
  visual parity — **M28**; `MenuDialogLayer` — **M29**.
- Middleware/store/logging trong dispatch — senior không có; DRE
  là project-local, không port framework.

## Checkpoint hoàn thành

- [ ] `lib/core/dre/dre.dart` + `dre_change_notifier.dart` tồn
  tại verbatim (không doc comment, không expansion "DRE").
- [ ] `test/core/dre/dre_change_notifier_test.dart` 5 test xanh
  qua harness `_TestDreViewModel`/`_TestReducer`.
- [ ] `flutter analyze` sạch; `flutter test` **241/241**.
- [ ] Kể được 5 nhịp dispatch và tại sao asyncOp snapshot là
  post-reduce.
