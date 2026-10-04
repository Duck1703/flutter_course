## 🤖 AI Local — Kiểm tra project sau bài này (TỔNG HỢP M22)

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m22/05 — TỔNG HỢP M22 (grep-zero scaffold retired; parity 4 đường save; 168/168; biên M23 Supabase). Đây là cổng milestone — chứng minh cái cũ CHẾT HẲN và cái mới đúng hơn cái cũ.

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter build web` READ-ONLY, `grep`/`rg`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Exercise "thoát trước safe haven → save gamesJoined+1" là tự-làm sandbox (không merge bắt buộc); có thêm test đó là OK, thiếu không tính BEHIND.

EXPECTED STATE SAU BÀI NÀY (đỉnh M22 — GATE):
- GREP-ZERO SCAFFOLD (STRICT — declaration/reference thực thi = 0 trong `lib/`; comment milestone-tagged không tính): `GameResult` type (chỉ còn tên method `_saveGameResult`/`_syncSavedGameResult`), `expForNextLevel` (chỉ còn local var trong `_applyLevelProgression` — tên senior), `gainExp`, `expPercent` getter (chỉ còn local var trong `_LevelCard`), `applyGameResult`, `buildGameResult`, `resolvedResult`, `game_result.dart` import/file.
- SAVE-PATH PARITY (STRICT — đối chiếu code từng dòng): 4 transition → `_emitWithSaveResult` với payload đúng: victory-cuối (moneyEarned, true), `_endGame` (guaranteedAmount, false), `confirmWalkAway` (_walkAwayAmount, false), `backToMenu` (_walkAwayAmount, false); `questionCount = questionIndex + 1` ở cả 4; flag `hasSavedResult` set TRONG emit state' — guard đọc `_state.hasSavedResult` trước; `unawaited(_saveGameResult)` fire-and-forget + try/catch debugPrint; `gainedExp = earnedAmount`; `gamesWon` chỉ khi isWin; `LevelConfig` while-loop đốt ngưỡng; `_syncSavedGameResult` chỉ stub debugPrint.
- MODEL (STRICT): `UserProfileData` đúng 9 field (không còn `expForNextLevel`/`gainExp`/`expPercent`/`expPerCorrectAnswer`/`applyGameResult`); `LevelConfig` + `MenuLevelProgress` + `_LevelCard` đọc `progress` (Bài 2–3); `openGame → Future<void>` + pop trần; `menu_view_model` không còn `applyGameResult` — menu CHỈ đọc stream.
- VERIFY (STRICT): `flutter analyze` sạch; `flutter test` → **168/168**; `flutter build web` PASS. Đọc đúng 168 = 157 + 7 + 5 + 8 − 9 (test scaffold chết cùng scaffold — GIẢM là kỳ vọng, không phải hồi quy).
- HÀNH VI (semantic): chơi thua một ván → menu `gamesJoined` +1 NGAY qua stream (không cần restart); walk-away → `gamesJoined`+1, `gamesWon`+0, earned=_walkAwayAmount; bấm VỀ MENU sau game-over → saveCallCount vẫn 1; EXP lên cấp theo `LevelConfig` (seed 34000 + 1000 → L2 exp 1000); level cap 100.
- KHÔNG ĐƯỢC có (chưa đến — boundary M22): `_syncSavedGameResult` gọi Supabase/auth thật (M24/M25); `AuthRepository`/`UserProfileSyncRepository` trên ctor (M24/M25); Supabase package/`SUPABASE_URL` dart-define (M23); leaderboard repo/VM/dialog (M23); DRE `GameSaveResult` asyncOp/reducer/`DreChangeNotifier` (M26); `LevelProgressCard` ring/glass/tier visual + `menuMaxLevelReached`/`menuExpToNextLevel` (M28 — trần-level hiển thị "5 / 9e15 EXP" là cosmetic sót CỐ Ý, senior che ở M28, KHÔNG vá); `shareResult`/`GameShareResultEvent`/`share_plus` (M27).

INVARIANTS NỀN:
- M21 đỉnh: layer 9-variant in-tree + AnimatedSwitcher + `ValueKey(runtimeType)` + `PopScope`/`_handleRouteBack`/`_afterExit` + `GameNavigateToMenuEvent` duy nhất (giờ pop trần); M20 lifelines; M14 repo/BehaviorSubject/`ValueStream`/Fake; M15–M18 nền; `MenuLevelProgress.fromProfile` + `_LevelCard` rewire.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`/`AHEAD_RISKY`; thiếu bắt buộc hoặc scaffold còn sống → `BEHIND`/`NEEDS_FIX` + bằng chứng file/symbol. M23 mở Supabase bootstrap — chưa chấm.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m22/05
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
