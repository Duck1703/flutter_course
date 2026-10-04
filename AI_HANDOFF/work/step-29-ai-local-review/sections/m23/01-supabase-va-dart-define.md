## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m23/01 — "Supabase, dart-define & bức tường bảo mật" (thêm supabase_flutter dep + lib/core/supabase_environment.dart 4 dart-define keys + copy file SQL schema; chưa init, chưa có consumer).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa. ĐẶC BIỆT: không được yêu cầu credential Supabase thật — môi trường khóa không có; thiếu dart-define là NHÁNH HỢP LỆ.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Config là compile-time plumbing — KHÔNG có `.env`/`flutter_dotenv`/file JSON assets là ĐÚNG (senior không dùng); chưa `Supabase.initialize` là ĐÚNG (BÀI 2).

EXPECTED STATE SAU BÀI NÀY:
- `pubspec.yaml` (STRICT): `supabase_flutter: 2.14.2` sau `shared_preferences`; `flutter pub get` xanh (kéo `supabase 2.12.2` + transitive).
- `lib/core/supabase_environment.dart` (FILE MỚI, STRICT verbatim): 4 `static const` `String.fromEnvironment` keys `SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY`/`GOOGLE_WEB_CLIENT_ID`/`GOOGLE_IOS_CLIENT_ID`; 4 field final + const ctor; `factory fromEnvironment()` trả const instance; `isSupabaseConfigured` = url.trim() && key.trim() non-empty (AND); `isGoogleConfigured` = CHỈ googleWebClientId non-empty; `configurationError` — `!isSupabaseConfigured → 'Supabase is not configured.'` trước, `!isGoogleConfigured → 'Google sign-in is not configured.'` sau, đủ → `null` (thứ tự STRICT). Cặp GOOGLE_* giữ shape dù chưa có consumer (M24).
- `supabase/student-setup/01-setup-database.sql` (STRICT): file tồn tại copy nguyên văn (~181 dòng) — schema `public.users` + RLS owner policies + view `public.leaderboard` (security_barrier, row_number rank, auth_uuid chỉ lộ trên hàng caller, grant select anon+authenticated); KHÔNG chứa secret.
- `test/core/supabase_environment_test.dart` (FILE MỚI, STRICT 3 test): thiếu url/key → false + 'Supabase is not configured.'; đủ url+key → true + 'Google sign-in is not configured.'; đủ 4 → null + isGoogleConfigured true (webId đủ, iosId không ảnh hưởng).
- `flutter analyze` sạch; `flutter test` → **171/171** (STRICT 168 + 3).
- KHÔNG ĐƯỢC có (chưa đến): `Supabase.initialize`/`SupabaseClient`/`supabase_client_service.dart` (BÀI 2); `LeaderboardRepository`/`leaderboard_*`/`SupabaseLeaderboardRepository`/`DisabledLeaderboardRepository` (BÀI 2); `AppDependencyScope.leaderboardRepository` (BÀI 2); `main()` đổi bootstrap (BÀI 2); `.env`/`flutter_dotenv`/dotenv loading (không bao giờ — DIVERGED nếu có); URL/key THẬT hardcode trong file Dart (commit secret — DIVERGED/báo ngay); `AuthRepository`/`GoogleSignIn` (M24); `avatarAsset`/`rankAsset`/`LeaderboardRowStyle` (M28).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- M22 đỉnh: VM-side save + `hasSavedResult` + `UserProfileData` 9 field + `LevelConfig`/`MenuLevelProgress` + transport-retired `openGame→Future<void>`; M21 layer; menu `_LeaderboardEntry` là card TĨNH chưa tap được (BÀI 5 mới nối); mọi repo LOCAL SharedPreferences; `flutter test` nền 168 còn nguyên trong 171.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m23/01
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
