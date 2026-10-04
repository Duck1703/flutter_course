## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m25/05 — "Test sync VM-level + tổng kết " (group 'result profile sync' 3 test khóa call-path: authed→syncCallCount 1 + đúng uid; guest→sync skip + save vẫn 1; syncError→nuốt + save intact; suite 233 → 236; LIVE_PROFILE_SYNC NOT_PERFORMED — merge/schema/call-path gánh verify; converge senior trừ DRE M26/dialog transport M29/visual M28/version M27).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter build web`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Đây là milestone gate: kiểm TỔNG THỂ M25 tích luỹ + suite 236 + build web; live sync không bắt buộc.

EXPECTED STATE SAU BÀI NÀY:
- `test/game_screen_view_model_test.dart` (STRICT append group cuối `main`, cùng file — KHÔNG file mới): `group('result profile sync', …)` đúng 3 test FakeAsync:
  1. authed `initialSession: AuthSessionAuthenticated(uid: 'user-1')` → `vm.backToMenu()` + `async.flushMicrotasks()` → `repo.saveCallCount == 1` + `sync.syncCallCount == 1` + `sync.lastSyncedSession?.uid == 'user-1'`;
  2. guest (authRepo mặc định) → `saveCallCount == 1` + `syncCallCount == 0` (save local chạy, sync skip — guest là session hợp lệ không phải edge);
  3. `sync..syncError = StateError('network down')` → không throw + `saveCallCount == 1` + `syncCallCount == 1` (STRICT — đã gọi RỒI fail ≠ bị skip; assert == 0 ở đây = sai ngữ nghĩa);
  `addTearDown` cho vm + auth + sync fake (BehaviorSubject ownership); `flushMicrotasks()` SAU action (không trước — chuỗi unawaited chưa bắt đầu).
- `flutter analyze` sạch; `flutter test` → **236/236** (STRICT 233 + 3); `flutter build web` PASS (STRICT — milestone gate build).
- M25 TÍCH LUỸ — kiểm đủ 4 bài trước: `app_user_data.dart` DTO 8-field + 4 cửa + `mergeUserProfileForSync` + 5 helper; `02-verify-database.sql` byte-identical; `user_profile_sync_repository.dart` Impl + Disabled một file (pipeline _isSyncing→InProgress→fetch→merge→save→upsert→Idle, Failed+rethrow); `main()` 3 ternary cùng dáng (leaderboard/auth/sync); `GameScreenViewModel` ctor profile→auth→sync + `_syncSavedGameResult` thật (loadAuthState→is-check→sync/skip/nuốt); `game_screen.dart` create đọc 3 repo; scope doc đúng.
- KHÔNG ĐƯỢC có (chưa đến — divergence MỞ có chủ đích): `DreChangeNotifier`/`asyncOp`/`DataResponse` primitives (M26); `MenuDialogAuth`/`MenuDialogSignOut` state + `MenuDialogLayer` + `onDismissLockChanged` thay showDialog transport (M29); `SettingsDialogShell`/`OnboardingGameButton`/`LevelProgressCard`/icon pipeline visual (M28); version text `v$appVersion` + notification permission/scheduling (M27); UI consumer `syncStateStream` (senior không render); realtime/multi-tab sync (senior không có); repo-level test cho sync impl qua mock SupabaseClient (senior không có); live credential/dotenv trong code.
- Honesty check (STRICT): không comment/doc nào còn nói "sync sẽ làm M25"/"LUÔN Disabled"/"stub" sau khi đã converge; `LIVE_PROFILE_SYNC: NOT_PERFORMED` được ghi nhận ở lesson, không phải claim "remote đã ghi" trong code/test docstring.

INVARIANTS NỀN — phải CÒN NGUYÊN:
- M22 `hasSavedResult` (backToMenu lần 2 không save/sync lặp); M24 đỉnh auth đầy đủ (session model, impls, coordinator guard, dialog VMs, pill, events, PopScope); M23 leaderboard 4-state + row + env + `01-setup-database.sql`; M21 layer + PopScope + AnimatedSwitcher; M20 lifelines; M19 VM rebuild; M18 onboarding; M17 l10n; M16 settings dialog; M14/M15 repos + sealed.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. Suite ≠ 236 hoặc build web fail = NEEDS_FIX/BLOCKED theo bằng chứng.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m25/05
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
