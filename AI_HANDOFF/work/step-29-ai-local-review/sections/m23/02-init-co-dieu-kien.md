## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m23/02 — "Init có điều kiện & DI theo cấu hình" (SupabaseClientService.initialize→SupabaseClient? null-sentinel; cụm repository leaderboard: contract+Snapshot+EntryData+PopupState 4 variant+hai impl; main() chọn impl bằng MỘT ternary; scope +repo; 3 test call-site sửa → 171/171 không test mới).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa. KHÔNG cần credential thật — `supabase=false` là đường bắt buộc.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này là "tạo cụm file verbatim + nối bootstrap" — chưa có CONSUMER nào của `LeaderboardRepository` (dialog = BÀI 5); menu trông y hệt là ĐÚNG.

EXPECTED STATE SAU BÀI NÀY:
- `lib/services/supabase_client_service.dart` (FILE MỚI, STRICT verbatim): `class SupabaseClientService` + `const ._()`; `static Future<SupabaseClient?> initialize(SupabaseEnvironment)` — `!isSupabaseConfigured → return null` (sentinel nullable, KHÔNG throw, KHÔNG class NotConfigured); đủ → `await Supabase.initialize(url:, publishableKey:)` → `return supabase.client`.
- `lib/repositories/leaderboard/leaderboard_repository_contract.dart` (FILE MỚI, STRICT): `abstract interface class LeaderboardRepository { Future<LeaderboardSnapshot> loadLeaderboard({String? currentUserId}); }` + `class LeaderboardSnapshot{List<LeaderboardEntryData> entries, LeaderboardEntryData? currentEntry}` (FUTURE snapshot — KHÔNG Stream).
- `lib/data/leaderboard/leaderboard_entry_data.dart` (FILE MỚI ~132 dòng, STRICT): `LeaderboardEntryData{rank, name, level, score(String!), avatarUrl?, isCurrentUser}` — KHÔNG `avatarAsset`/`rankAsset`/`style` (divergence có chủ đích → M28; `avatarUrl` GIỮ vì remote data); `enum LeaderboardPopupMessage{empty, loadError, loading}`; `sealed class LeaderboardPopupState` đúng 4 variant `LeaderboardPopupSuccess{entries, currentEntry?, isRefreshing}`/`LeaderboardPopupEmpty{message}`/`LeaderboardPopupError{message}`/`LeaderboardPopupLoading{message}`; static `leaderboardEntries` (6 hàng) + `currentLeaderboardEntry` (rank 125, `isCurrentUser: true`, tên 'Tàu hủ đi chill').
- `lib/repositories/leaderboard/leaderboard_repository.dart` (FILE MỚI ~161 dòng, STRICT): `export 'leaderboard_repository_contract.dart'`; consts `_leaderboardView='leaderboard'`, `_leaderboardColumns='rank,name,avatar_url,level,total_money_won'`, `_topEntryCount=10`; `SupabaseLeaderboardRepository({required client})` — chuỗi query `from→select→order('total_money_won', ascending:false)→order('rank')→limit(10)` + `_loadCurrentEntry` (`eq('auth_uuid', uid).maybeSingle()`) + `@visibleForTesting static entryFromRow(row, {required isCurrentUser})` seam; `DisabledLeaderboardRepository` trả const static snapshot bỏ qua currentUserId; `_LeaderboardRecord` mapper phòng thủ (`_intValue` int/num→int/else fallback; `_stringValue` non-blank→trim else null; name fallback 'Player'; `_formatScore` = `formatVnd().replaceAll(' VNĐ','')`).
- `lib/core/app_dependency_scope.dart` (STRICT): field `final LeaderboardRepository leaderboardRepository` + ctor required + `Provider<LeaderboardRepository>.value` — kiểu CONTRACT, KHÔNG impl.
- `lib/main.dart` (STRICT thứ tự bootstrap): `SupabaseEnvironment.fromEnvironment()` → `debugPrint('[supabase] config supabase=… google=…')` → `await SupabaseClientService.initialize(env)` (SAU `ensureInitialized`) → 3 repo local y cũ → `final LeaderboardRepository leaderboardRepository = supabaseClient == null ? const DisabledLeaderboardRepository() : SupabaseLeaderboardRepository(client: supabaseClient)` → truyền vào `AppDependencyScope`.
- TEST (STRICT): 3 file `test/menu_provider_scope_test.dart` + `test/menu_screen_ui_events_test.dart` + `test/widgets/game_screen_test.dart` đều truyền `leaderboardRepository: const DisabledLeaderboardRepository()` + import đúng (compile-forced).
- `flutter analyze` sạch; `flutter test` → **171/171** (STRICT — KHÔNG test mới, chỉ compile-forced arg); `flutter run` không dart-define → console `[supabase] config supabase=false google=false`, app chạy bình thường.
- KHÔNG ĐƯỢC có (chưa đến): `LeaderboardDialogViewModel` (BÀI 4); `showLeaderboardDialog`/`MenuLeaderboardDialogScope`/`LeaderboardPopupBody`/`LeaderboardList`/`LeaderboardRow`/`MenuLeaderboardRequested`/`requestLeaderboardDialog`/hàng menu tappable (BÀI 5); `if(configured)` trong widget (anti-pattern); `Provider<SupabaseLeaderboardRepository>` (đăng ký impl = DIVERGED); `AuthRepository`/`SupabaseAuthRepository`/`DisabledAuthRepository` (M24); `try/catch` quanh `initialize` (null là sentinel hợp lệ — nuốt nhánh Disabled); realtime subscription (ngoài scope, senior cũng không dùng).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- `SupabaseEnvironment` + SQL file (Bài 1); M22 đỉnh (VM-save/`hasSavedResult`/9-field profile/`LevelConfig`/`MenuLevelProgress`); M21 layer; M20 lifelines; M14 contract+scope+BehaviorSubject; menu `_LeaderboardEntry` vẫn tĩnh.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m23/02
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
