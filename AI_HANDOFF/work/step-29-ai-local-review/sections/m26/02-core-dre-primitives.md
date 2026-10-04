## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m26/02 — "core/dre — contract + DreChangeNotifier" (2 file nền generic verbatim senior; dispatch 5 nhịp: reduce → swap → != notify → effects broadcast → unawaited asyncOp snapshot POST-reduce; @protected; dispose-safe; +5 test qua harness private → 241; chưa có consumer production).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Hai file lib chưa có consumer production là ĐÚNG (test file là consumer đầu tiên chứng minh contract — consumer thật BÀI 3–5).

EXPECTED STATE SAU BÀI NÀY:
- `lib/core/dre/dre.dart` (FILE MỚI ~22 dòng, STRICT verbatim — KHÔNG doc comment, KHÔNG expansion "DRE"): `abstract interface class DreAction {}` + `DreEffect {}` + `DreAsyncOp {}` (STRICT marker — body rỗng, chỉ `implements` được); `abstract interface class DreReducer<S, A extends DreAction, E extends DreEffect, O extends DreAsyncOp>` + `DreResult<S, E, O> reduce(S state, A action)` (STRICT generic bounds); `final class DreResult<S, E extends DreEffect, O extends DreAsyncOp>{required state, effects = const [], asyncOp}` (`O?` — tối đa một op).
- `lib/core/dre/dre_change_notifier.dart` (FILE MỚI ~75 dòng, STRICT): `class DreChangeNotifier<S, A extends DreAction, E extends DreEffect, O extends DreAsyncOp> extends ChangeNotifier` — ctor `{required reducer, required S initialState}` seed `_state` + `StreamController<E>.broadcast()`; getter `state`/`effects`; `@protected void dispatch(A action)` STRICT 5 nhịp đúng thứ tự: ① `_isDisposed → return` ② `result = reducer.reduce(_state, action)` ③ `previousState = _state; _state = result.state` → `previousState != _state → notifyListeners()` (diff trước notify — identity hoặc ==) ④ `for e in result.effects → !_effects.isClosed → _effects.add` ⑤ `result.asyncOp != null → unawaited(_executeAsyncOp(asyncOp, _state))` (STRICT snapshot = `_state` SAU swap — post-reduce, không phải prev); `@protected Future<void> executeAsyncOp(O, S)` abstract; `onAsyncOpError(error, stackTrace) {}` no-op hook; `_executeAsyncOp` — try await executeAsyncOp; catch → `!_isDisposed → onAsyncOpError`; `dispose()` — `_isDisposed = true` + `_effects.close()` + `super.dispose()` (thứ tự).
- `test/core/dre/dre_change_notifier_test.dart` (FILE MỚI, STRICT 5 test + harness private cùng file): 'dispatch applies reducer state and notifies' (send(_Increment) → count 1 + notifyCount 1); 'effects without state change' (send(_EmitEffect) → emits(_TestEffect('saved')) + count 0); 'async op receives post-reduce state snapshot' (send(_StartAsync) → `asyncSnapshots` emits `_TestState(1)` — chứng minh nhịp 5); 'unchanged state does not notify' (_NoChange → notifyCount 0 — same instance); 'dispatch after dispose ignored without leaking effects' (dispose → send(_EmitEffect) → neverEmits). Harness: `_TestDreViewModel extends DreChangeNotifier<_TestState, _TestAction, _TestEffect, _TestAsyncOp>` + `send()` public wrapper + `executeAsyncOp` add vào `_asyncSnapshots` broadcast; `_TestReducer implements DreReducer<…>` switch 4 variant (`_Increment`/`_EmitEffect{message}`/`_StartAsync`/`_NoChange`); `_TestState`/`_TestEffect` có `==`; `sealed _TestAction`/`_TestAsyncOp`.
- `flutter analyze` sạch; `flutter test` → **241/241** (STRICT 236 + 5). Hai file lib KHÔNG có import trong production lib/ — ĐÚNG (chỉ test import).
- KHÔNG ĐƯỢC có (chưa đến): `lib/view_models/game/dre/*` (GameState/GameAction/GameEffect/GameAsyncOp — BÀI 3); `lib/view_models/game/reducer/*` + `game_reducer*.dart`/`part` (BÀI 4); VM `extends DreChangeNotifier`/rewrite game VM/`bridge/` parts/xoá `GameSessionState` (BÀI 5); doc comment viết "DRE = …" expansion (sai quy ước — DIVERGED nhẹ); `extends DreAction`/`extends DreEffect` (marker chỉ `implements` — compile error nếu extends); middleware/store/logging trong dispatch (senior không có — DIVERGED); `onAsyncOpError` override trong game VM (senior không override — BÀI 5); `BehaviorSubject` cho effects stream (broadcast không replay là ĐÚNG — DIVERGED nếu seeded/replay).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- M25 đỉnh 236 (sync pipeline + main 3-ternary + game VM 3-repo + 3 sync test); VM trung gian `extends ChangeNotifier` + `GameSessionState` trong data/ vẫn nguyên (retire BÀI 5); M24 auth; M23 leaderboard; M22 hasSavedResult; M14–M21 nền.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. Snapshot pre-reduce (`_executeAsyncOp(op, previousState)`) = DIVERGED (op không thấy quyết định đã commit).

OUTPUT (đúng format; mục trống → "None"):
LESSON: m26/02
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
