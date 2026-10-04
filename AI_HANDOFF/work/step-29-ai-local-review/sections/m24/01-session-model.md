## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m24/01 — "Session model, AuthActionResult & guest mode" (sealed AuthSessionData 2 variant: Guest là session thật không phải null; AuthActionResult value-type kết-quả-action; AuthRepository contract; DisabledAuthRepository guest impl; barrel 2 export; +6 test → 199; chưa có impl remote).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này chỉ có model + contract + disabled impl — KHÔNG có Supabase/Google impl là ĐÚNG (BÀI 2); guest mode là nhánh hợp lệ không phải lỗi.

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/auth/auth_session_data.dart` (FILE MỚI ~58 dòng, STRICT verbatim): `@immutable sealed class AuthSessionData` + `bool get isAuthenticated => this is AuthSessionAuthenticated`; `final class AuthSessionGuest` (== `other is AuthSessionGuest`, hashCode 0); `final class AuthSessionAuthenticated{required uid, email?, displayName?, photoUrl?}` (==/hashCode trên cả 4 field — uid là field bắt buộc duy nhất). KHÔNG có variant thứ ba, KHÔNG `User?`-style nullable model.
- `lib/repositories/auth/auth_repository_contract.dart` (FILE MỚI ~60 dòng, STRICT): `class AuthActionResult{final bool isSuccess, final String message}` + `const ._()` private ctor + 2 redirecting ctor `const .success(msg) : this._(isSuccess: true,…)` / `const .failure(msg) : this._(isSuccess: false,…)` (STRICT — bên ngoài không tự tạo `AuthActionResult(isSuccess:…)`); `abstract interface class AuthRepository` đúng 6 member: `ValueStream<AuthSessionData> get authStateStream` (STRICT ValueStream KHÔNG Stream — `.value` phải tồn tại), `Future<AuthSessionData> loadAuthState()`, `signInWithGoogle/Apple/Email` + `signUpWithEmail` trả `Future<AuthActionResult>`, `Future<AuthActionResult> signOut()`, `Future<void> dispose()`. KHÔNG `currentUser` getter/`User?`.
- `lib/repositories/auth/disabled_auth_repository.dart` (FILE MỚI ~78 dòng, STRICT): ctor `required SupabaseEnvironment` + `BehaviorSubject<AuthSessionData>.seeded(const AuthSessionGuest())` (seed Guest ngay từ ctor); `authStateStream => subject.stream`; `loadAuthState => subject.value` ngay; `_unavailableMessage = _environment.configurationError ?? 'Sign in is unavailable.'`; `_unavailableResult(action)` → `debugPrint('[auth] …')` + `AuthActionResult.failure(_unavailableMessage)` — mọi sign-* trả failure này, KHÔNG emit stream; `signOut` trả `AuthActionResult.success('Signed out successfully.')` (no-op vô hại — guest sign-out thành công là đúng); `dispose => subject.close()`; đầu file `// ignore_for_file: prefer_initializing_formals` (senior verbatim).
- `lib/repositories/auth/auth_repository.dart` (FILE MỚI barrel, STRICT 2 export lúc này): `export 'auth_repository_contract.dart';` + `export 'disabled_auth_repository.dart';` — export thứ ba `supabase_auth_repository.dart` là BÀI 2 (có sớm = AHEAD nếu file tồn tại, DIVERGED nếu export file không tồn tại → compile đỏ).
- `test/supabase_auth_repository_test.dart` (FILE MỚI, STRICT 6 test): AuthSessionData — isAuthenticated guest↔authed + equality (guest==guest, authed so 4 field, uid khác → isNot, authed ≠ guest); DisabledAuthRepository — stream seed Guest ngay + isAuthenticated false; signInWithGoogle → `isSuccess false` + message `'Supabase is not configured.'` (env rỗng) + stream VẪN Guest sau call; env đủ → fallback `'Sign in is unavailable.'`; signOut → success `'Signed out successfully.'`; `addTearDown(repo.dispose)` trên mọi repo.
- `flutter analyze` sạch; `flutter test` → **199/199** (STRICT 193 + 6). `rxdart` đã có sẵn (M14) — KHÔNG thêm dep.
- KHÔNG ĐƯỢC có (chưa đến): `AuthRepositoryImpl`/`supabase_auth_repository.dart`/`GoogleAuthService`/`apple_auth_service.dart`/`google_sign_in`/`sign_in_with_apple`/`crypto` dep (BÀI 2); `AppDependencyScope.authRepository` + main ternary (BÀI 2); `MenuAuthActionCoordinator`/`UserProfileSyncRepository`/`ProfileSyncStateData` (BÀI 3); `MenuAuthDialogViewModel`/`MenuSignOutDialogViewModel`/`requestAuthAction`/pill tap/`MenuAuthRequested`/`MenuSignOutRequested` (BÀI 4–5); `_currentLeaderboardUserId` đổi khỏi `→ null` (BÀI 4); `MenuSnackBarRequested` emit site MỚI trên menu VM (đã retire M22-era — emit mới = lộn pattern).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- M23 đỉnh 193/193: env + SQL + leaderboard cluster + VM + dialog + row + `main` ternary leaderboard; `SupabaseEnvironment` 4-key + `configurationError` (auth Bài 1 dùng nó); M22 VM-save; M21 layer; `_LeaderboardEntry` tappable + leaderboard hoạt động; pill tài khoản trên menu vẫn UI tĩnh (BÀI 5).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. `User?`/nullable session model thay sealed = DIVERGED.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m24/01
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
