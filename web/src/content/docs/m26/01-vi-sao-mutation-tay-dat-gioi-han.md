---
title: "Bài 1 · Vì sao VM mutation tay đã đạt giới hạn"
description: "Felt problem: 733 dòng GameScreenViewModel trộn transition, timer, delay, repository, lifecycle guard trong một file. DRE trong repo này là gì: DreAction/DreEffect/DreAsyncOp/DreReducer + DreResult — repo không bao giờ mở rộng từ viết tắt, không phải Redux/MVI/Elm. Diagram trước/sau; counter reducer độc lập. +0 test → 236."
sidebar:
  label: "Bài 1 · giới hạn mutation tay"
  order: 1
---

## Mục tiêu

- Nêu được bài toán cảm nhận: `GameScreenViewModel` 733 dòng trộn
  bốn chủng việc — transition state, `Timer`/`Future.delayed`,
  repository IO, lifecycle/stale guard — và vì sao mỗi flow mới
 đều phải sửa nhiều chỗ trong cùng file.
- Phát biểu chính xác DRE là gì **trong repo này**: bốn vai —
  `DreAction`, `DreEffect`, `DreAsyncOp`, `DreReducer` — cộng
  `DreResult`. Repo **không bao giờ mở rộng từ viết tắt**: không
  comment, không doc nào định nghĩa ba chữ đó; không phải port
  Redux/MVI/Elm.
- Đọc được diagram trước/sau: bề mặt public (`startNewGame`,
  `submitAnswer`, `screenData`, `dialogState`, `uiEvents`) giữ
  nguyên — bên trong đổi chủ.
- Chạy được counter reducer độc lập — `reduce(state, action) →
  {state, effects}` — **không đụng production code**; +0 test →
  suite giữ **236/236**.

## Bạn đang ở đâu

- Cuối M25: `flutter test` 236/236. Game chơi đủ — máy 6 phase
, dialog in-tree từ `dialogState`, save + sync sau
 ván.
- VM hiện tại là bản trung gian cố ý từ M19: `extends
  ChangeNotifier`; session model `GameSessionState` sống trong
  `data/game/game_session_state_data.dart`; mutation bằng
  `_emit(state.copyWith(...))` rải trong từng public method; delay
  qua `_schedule*`; save qua `_emitWithSaveResult` +
  `unawaited(_saveGameResult)`.
- M26 đổi kiến trúc bên trong toàn bộ, **không đổi chữ ký
  public** — `game_screen.dart` và mọi test compile y nguyên.

## Vì sao việc này quan trọng ngay bây giờ

Mở `game_screen_view_model.dart` và đếm chủng việc trong một file:
(1) transition `copyWith` trên ~13 field; (2) `Timer.periodic` +
ba `Future.delayed` khác nhau; (3) `loadUserProfile`/
`saveUserProfile`/`syncUserProfile` IO; (4) `_isDisposed`/
`_flowToken`/`hasSavedResult` guard rải rác. Ba đau điểm cụ thể:
mọi guard nằm *trong method* nên một flow mới phải sửa đúng chỗ
trong 733 dòng; delay-check chủ yếu bằng `phase` — callback trễ
của flow cũ vẫn có thể chạy vào flow mới cùng phase; và transition
**không test được riêng** — muốn assert "submit ngoài playing bị
bỏ" phải dựng cả VM + 3 fake repo + FakeAsync, trong khi luật đó
thuần tuý không cần gì hết. Đây là giới hạn của "VM mutation tay",
không phải lỗi của cách M19–M25 đi — bản trung gian là scaffold có
chủ đích để tới đây mới trả.

## Bạn đã biết gì

- Máy 6 phase `GamePhase` + transition tay (M19);
  `copyWith` + `clearSelectedAnswer`/`clearAudiencePercentiles`
.
- Sealed `GameDialogState` + switch exhaustive (M15);
 dialog render in-tree từ state (M21); mapper
 `buildGameScreenPresentation`.
- Save boundary `hasSavedResult` + `unawaited` (M22);
 stale-result guard `_requestId` (M23); re-entrancy
 `_isSyncing` (M25).

## Mental model mới — "reducer trả về kết quả, không làm việc" (CORE)

```text
TRƯỚC (M19–M25, trung gian):
  submitAnswer(a) ──┬─ _emit(copyWith phase=answeredPending)
                    ├─ _pauseTimer()
                    └─ _schedule(reveal) → Future.delayed
                         → _onRevealElapsed()   guard: chỉ phase

SAU (M26):
  submitAnswer(a) → dispatch(GameAnswerSubmitted(a.answerText))
                          │
                          ▼
              GameReducer.reduce(state, action)   ← THUẦN
                          │
                          ▼
              DreResult { state, effects, asyncOp } ← "khai báo việc"
                          │
                          ▼
              DreChangeNotifier.dispatch:
                swap _state → notifyListeners() nếu previous != next
                for effect → _effects.add   (stream broadcast)
                asyncOp ≠ null → unawaited(executeAsyncOp(op, _state))
```

Ba kênh ra của một transition:
- **`state`** — cái UI vẽ: `screenData`/`dialogState` đọc qua
 mapper y như cũ.
- **`effects`** — *ý định* nằm ngoài reducer: bật/dừng timer, hẹn
 delay, điều hướng. Là **data**, không phải `Timer` thật.
- **`asyncOp`** — tối đa MỘT việc async per reduce: game có
  đúng một op — `GameSaveResult`.

Giới hạn của model: reducer không nhận kết quả-IO (save xong không
báo lại reducer); không rollback; và "DRE" chỉ là tên — repo không
định nghĩa expansion, đừng bịa.

## Dart cần dùng (bài đọc hiểu — chưa cần construct mới)

| Construct | Vai trò |
|---|---|
| `sealed class` + `final class` variant | tập đóng action/effect — reuse |
| `switch` expression exhaustive | reduce = bảng tra; Dart bắt đủ case |
| `implements` vs `extends` | reducer *implement* contract — không kế thừa code |

## Flutter cần dùng

| API | Vai trò |
|---|---|
| `ChangeNotifier` + `notifyListeners()` | contract `ListenableBuilder` giữ nguyên — UI không đổi |
| `StreamController.broadcast` | kênh effects — chi tiết Bài 2 |

## Ví dụ độc lập — counter reducer (DartPad chạy được)

```dart
class CounterState {
  final int count;
  const CounterState(this.count);
}

sealed class CounterAction {
  const CounterAction();
}
final class Increment extends CounterAction {
  const Increment();
}
final class Decrement extends CounterAction {
  const Decrement();
}

final class CounterResult {
  final CounterState state;
  final List<String> effects; // ý định — data, không phải Timer
  const CounterResult(this.state, [this.effects = const []]);
}

CounterResult reduce(CounterState s, CounterAction a) {
  return switch (a) {
    Increment() => CounterResult(CounterState(s.count + 1)),
    Decrement() => s.count > 0
        ? CounterResult(CounterState(s.count - 1))
        : CounterResult(s, const ['rejected']), // guard → cùng state
  };
}

void main() {
  var s = const CounterState(0);
  for (final a in [
    const Increment(), const Increment(),
    const Decrement(), const Decrement(), const Decrement(),
  ]) {
    final r = reduce(s, a);
    s = r.state;
    print('count=${s.count} effects=${r.effects}');
  }
  // 1 [] → 2 [] → 1 [] → 0 [] → 0 [rejected]  — guard không throw
}
```

Đây là `GameReducer` ở quy mô tối thiểu: state vào + action vào →
state mới + danh sách ý định ra; guard là nhánh trả state cũ,
không phải exception.

## Android / Compose bridge

**SIMILARITY — MVI/`reduce(state, intent)` của UDF.** Sealed
intent, state bất biến, reducer thuần trả state mới — cùng tư
tưởng; list effect ≈ mô tả side-effect một lần.

**IMPORTANT DIFFERENCE — DRE là project-local, không thư viện.**
Không `Store`, không middleware, không dispatch chuỗi, không
time-travel; async boundary là MỘT slot `asyncOp` + một broadcast
stream — tối giản hơn mọi MVI framework quen thuộc.

**DO NOT ASSUME — đừng tìm expansion cho "DRE".** Không có chữ
nào ẩn sau ba ký tự; cũng đừng cho rằng reducer "chạy" effect —
nó trả mô tả, executor sống ở notifier/bridge.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/core/dre/dre.dart` (22 dòng) | bốn vai + `DreResult` — zero doc, không expansion |
| `lib/core/dre/dre_change_notifier.dart` (75) | dispatch loop — reduce → diff → notify → effects → `unawaited` op |
| `lib/view_models/game/dre/game_dre_*.dart` | state + 13 action + 7 effect + 1 asyncOp của game |
| `lib/view_models/game/reducer/game_reducer*.dart` | reducer thuần chia 4 `part` theo flow domain |
| `lib/view_models/game/game_screen_view_model.dart` + `bridge/` | VM mỏng: dispatch wrappers + effect bridge + op executor |

## Build it step by step — đọc hiểu, không file mới

1. Mở `lib/view_models/game/game_screen_view_model.dart` (trạng
   thái cuối M25): đánh dấu bốn chủng việc — `_emit(copyWith)`
   transition, `_startTimer`/`_pauseTimer`/`_stopTimer`/`_schedule*`,
   `_saveGameResult`/`_syncSavedGameResult`, `_isDisposed`/
   `_flowToken` guards.
2. Chạy counter example trên DartPad — đối chiếu output comment.
3. Đọc senior `lib/core/dre/dre.dart` — 22 dòng, bốn vai trên một
   trang, không doc.
4. `flutter analyze` + `flutter test` → vẫn **236/236** (bài này
   cố ý không thêm code).

## Hiểu code — ba điểm dễ trượt

1. **Effect là data, không phải việc.** `'rejected'` trong counter
   ↔ `GamePauseTimer()` trong game — reducer không gọi
   `timer.cancel()`; nó trả object mô tả ý định. Ai thực hiện là
   chuyện của bridge (Bài 5). Delay không còn "chôn" trong method.
2. **Guard = trả state cũ, không throw.** `Decrement` ở count 0 →
   `CounterResult(s, …)` cùng instance → notifier không notify
   (chứng minh ở Bài 2). Action trở thành no-op có chủ đích.
3. **`asyncOp` chỉ một slot.** Reducer buộc chọn "việc async quan
   trọng nhất" — game chọn save result; save→sync vẫn nằm TRONG
   `_saveGameResult` (chuỗi nội bộ op, không phải hai op).

## Chạy và quan sát

```text
flutter analyze → No issues found!
flutter test    → +236: All tests passed!   (không đổi — đọc-hiểu)
```

## Thử nghiệm

Trong counter, đổi guard `s.count > 0` thành `s.count >= 0`: đoán
output của chuỗi `[const Decrement()]` từ `count=0`. Rồi thêm
variant `Reset` trả `CounterState(0)` + effect `['reset']` —
chuỗi `[Increment, Increment, Reset]` in gì?

<details>
<summary>Đáp án</summary>

- `>= 0`: count đi xuống âm — `Decrement` từ 0 → `count=-1`,
  effect `[]` (không còn `'rejected'` vì guard luôn đúng) — nhánh
  else trở thành dead code.
- `Reset`: `1 [] → 2 [] → 0 [reset]` — reset là transition
  thường, không đặc quyền.
</details>

## Lỗi hay gặp

1. **Bịa expansion cho "DRE"** — repo không định nghĩa; viết "DRE
   = …" trong code/comment/ghi chú là sai quy ước project.
2. **Cho rằng reducer chạy effect** — gọi `Timer`/`Future` trong
   `reduce` phá purity và không test được thuần.
3. **Đợi asyncOp "xong" trong reduce** — reduce đồng bộ; op chạy
 `unawaited` sau.
4. **Nghĩ phải refactor UI** — contract là `screenData`/
   `dialogState`/`uiEvents` + `ListenableBuilder`; giữ nguyên.

## Tự làm — PRODUCE

Thêm action `Multiply(int factor)` cho counter reducer (trên
DartPad, KHÔNG vào repo). Yêu cầu: `factor == 0` → trả state cũ +
effect `['noop']`; khác 0 → `count * factor`. Viết xong đoán
output `[Increment(), Multiply(3), Multiply(0)]` từ `count=0`.

:::note[Gợi ý]
Variant mới cần field `factor`; guard trong chính arm của switch
bằng ternary — mẫu y hệt `Decrement`.
:::

<details>
<summary>Đáp án</summary>

```dart
final class Multiply extends CounterAction {
  final int factor;
  const Multiply(this.factor);
}
// arm switch:
Multiply(:final factor) => factor == 0
    ? CounterResult(s, const ['noop'])
    : CounterResult(CounterState(s.count * factor)),
```

Chuỗi: `1 [] → 3 [] → 3 [noop]` — guard-zero giống hệt
guard-underflow: same-state + effect nói ý định.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** một `reduce` trả ba thứ gì, ai tiêu thụ từng thứ? —
  **Đáp:** `state` → notifier/UI; `effects` → bridge trong VM
  (Bài 5); `asyncOp` → `executeAsyncOp` (tối đa một).
- **Hỏi:** "DRE" viết tắt chữ gì? — **Đáp:** repo không định
  nghĩa — tên pattern project-local; câu trả lời đúng là "không
  expansion".
- **Hỏi:** guard trong reducer khác `throw`/early-return thế
  nào? — **Đáp:** trả cùng state instance → `previousState !=
  next` false → không notify; no-op có chủ đích, không phải lỗi.

## Ta cố ý chưa thêm

- Share plumbing `GameShareRequested`/`GameShareResult`/
 `GameShareResultEvent`/`shareResult` — **M27**.
- Platform extras (notification, version text) — **M27**.
- Visual parity — **M28**. `MenuDialogLayer` — **M29**.
- Bất kỳ file DRE nào vào learner — Bài 2 mới port; bài này cố ý
  chỉ đọc.

## Checkpoint hoàn thành

- [ ] Nói được bốn vai `DreAction`/`DreEffect`/`DreAsyncOp`/
  `DreReducer` + `DreResult` — và chính xác rằng repo không
  expansion.
- [ ] Chạy được counter reducer; giải thích
  guard-returns-same-state.
- [ ] `flutter analyze` sạch; `flutter test` **236/236** (không
  đổi).
- [ ] Chỉ được trên diagram: transition/timer/persistence/
  plumbing của VM 733 dòng sẽ đi về đâu sau refactor.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m26/01 — "Vì sao VM mutation tay đã đạt giới hạn" (bài ĐỌC-HIỂU: phân tích 4 chủng việc trộn trong GameScreenViewModel ~733 dòng; DRE = 4 vai DreAction/DreEffect/DreAsyncOp/DreReducer + DreResult — repo không expansion; counter reducer chỉ trên DartPad; CỐ Ý không đổi production code; +0 test → 236).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: bài này là NO-CODE-DELTA — bài học là đọc hiểu + DartPad ngoài repo. Nếu project đã có code DRE → đó là AHEAD (BÀI 2–5), không phải lỗi; nếu thiếu mọi thứ DRE = ĐÚNG trạng thái.

EXPECTED STATE SAU BÀI NÀY:
- `lib/` KHÔNG có gì mới (STRICT): không `lib/core/dre/`, không `lib/view_models/game/dre/`, không `lib/view_models/game/reducer/`, không `DreChangeNotifier`/`GameReducer`/`GameState`/`GameAction`/`GameEffect`/`GameAsyncOp` ở đâu trong lib. Có sớm = AHEAD (xem dưới).
- `game_screen_view_model.dart` vẫn là bản trung gian (STRICT — KHÔNG được viết lại): `extends ChangeNotifier`; `_emit(state.copyWith(...))` rải trong method; `_startTimer`/`_pauseTimer`/`_stopTimer`/`_schedule*` + `Timer.periodic` + `Future.delayed`; `_saveGameResult` + `_syncSavedGameResult` + `unawaited`; `_isDisposed`/guards rải; ctor `(userProfileRepository, authRepository, profileSyncRepository, {questions})` M25; session model `GameSessionState` vẫn trong `lib/data/game/game_session_state_data.dart` (chưa xoá).
- `flutter analyze` sạch; `flutter test` → **236/236** (STRICT — không đổi gì).
- Người học hiểu được (không kiểm được bằng file — ghi nhận trong WHAT_MATCHES nếu thấy note/commit): bốn vai DRE + `reduce(state, action) → {state, effects, asyncOp}`; effect là data không phải Timer; guard trả state cũ; "DRE" không expansion (comment nào trong repo viết "DRE = …" = sai quy ước project — báo DIVERGED nhẹ).
- KHÔNG ĐƯỢC có: bất kỳ file DRE nào (BÀI 2–5); `GameShareRequested`/`GameShareResult`/`shareResult` (M27); `MenuDialogLayer` (M29); `GameSessionState` đã xoá (BÀI 5 mới xoá — xoá sớm = AHEAD_RISKY vì VM cũ còn dùng).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- M25 đỉnh 236: AppUserData + merge + sync impl + main 3-ternary + game VM 3-repo ctor + `_syncSavedGameResult` thật + 3 sync test; M24 auth đầy đủ; M23 leaderboard + env; M22 `hasSavedResult` + `_emitWithSaveResult`; M21 layer; M20 lifelines; M19 game VM.

Nếu AHEAD (đã có code DRE): phân loại AHEAD_COMPATIBLE khi files khớp shape senior (marker interfaces, dispatch 5-nhịp, reducer thuần); AHEAD_RISKY khi VM đã migrate nhưng thiếu nền/test. Cái gì cũng KHÔNG là lý do xoá ngược.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m26/01
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
