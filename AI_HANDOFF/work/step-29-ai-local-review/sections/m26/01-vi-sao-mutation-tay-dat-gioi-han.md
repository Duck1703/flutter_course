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
