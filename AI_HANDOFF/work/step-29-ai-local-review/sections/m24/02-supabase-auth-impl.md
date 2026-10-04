## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m24/02 — "AuthRepositoryImpl trên Supabase + Google v7" (google_sign_in V7 API: instance.initialize một lần + authenticate(scopeHint) — KHÔNG legacy signIn(); AuthRepositoryImpl 3-nguồn→1-subject + 4 đường sign-in + _sessionFromUser; main conditional DI + scope authRepository; +2 test → 201).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa. `LIVE_AUTH_FLOW: NOT_PERFORMED` — không yêu cầu đường đăng nhập thật chạy được; hành vi khóa bằng fake + test mapping thuần.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Apple path là APPENDIX verbatim (compile cho main, không học sâu); nút Apple chỉ iOS (BÀI 5 UI).

EXPECTED STATE SAU BÀI NÀY:
- `pubspec.yaml` (STRICT +3 pin): `google_sign_in: ^7.2.0`, `sign_in_with_apple: ^8.1.0`, `crypto: ^3.0.7`; `flutter pub get` xanh.
- `lib/services/google_auth_service.dart` (FILE MỚI ~101 dòng, STRICT V7): `GoogleAuthTokens{idToken, accessToken?}`; `abstract interface class GoogleAuthService{signIn()→GoogleAuthTokens?, signOut()}`; `GoogleAuthServiceImpl` — `_scopes = ['email','profile']`, env field, `var _isInitialized`; `signIn` → `await _initialize()` + `supportsAuthenticate()` check (throw StateError nếu không) + `GoogleSignIn.instance.authenticate(scopeHint: _scopes)` + `account.authentication.idToken` null/blank check → throw StateError + `authorizationForScopes ?? authorizeScopes` → `GoogleAuthTokens`; `_initialize` — `_isInitialized → return` + `GoogleSignIn.instance.initialize(clientId: _emptyToNull(googleIosClientId), serverClientId: _emptyToNull(googleWebClientId))` + set flag (STRICT serverClientId = WEB client id; `_emptyToNull` ''→null). KHÔNG `GoogleSignIn().signIn()`/`signIn()` legacy v6 đâu trong code (có = DIVERGED v6 API).
- `lib/repositories/auth/supabase_auth_repository.dart` (FILE MỚI ~317 dòng, STRICT): `AuthRepositoryImpl implements AuthRepository` — ctor `BehaviorSubject.seeded(_sessionFromUser(client.auth.currentUser))` (nguồn 1: session sót) + `_client.auth.onAuthStateChange.listen(state → _emit(_applySessionProfileOverride(_sessionFromUser(state.session?.user))), onError: (_) => _emit(AuthSessionGuest()))` (nguồn 2, lỗi→Guest); `signInWithGoogle` — `await _googleAuthService.signIn()` + `tokens == null → failure('Sign in was cancelled.')` + `client.auth.signInWithIdToken(provider: OAuthProvider.google, idToken:, accessToken:)` + `_emit(_sessionFromAuthResponse(response))` + success 'Signed in successfully.'; catch thứ tự `GoogleSignInException`(canceled→cancelled msg, else description)→`AuthException`(message)→generic; `signInWithPassword` email.trim() → emit; `signUp` — `_sessionFromActiveSession(response.session)` chỉ lấy session (có thể null confirm-email → success 'Check your email to confirm your account.'); `signOut` — `client.auth.signOut()` + xoá `_sessionProfileOverride` + emit Guest + `googleAuthService.signOut()` best-effort try lồng (lỗi không làm fail); `_sessionFromUser` static — null→Guest + `userMetadata` map `_metadataString` ('full_name'??'name', 'avatar_url'??'picture') → AuthSessionAuthenticated(uid, email, displayName, photoUrl); `_emit` chỉ `!isClosed && value != state` (compare-before-add); `dispose` cancel subscription → close subject (thứ tự); phần Apple `_sessionFromAppleAuthResponse` + top-level `authSessionFromAppleAuthResponse(response, tokens, {fallbackUser})` seam test + `_sessionProfileOverride`/`_applySessionProfileOverride`.
- `lib/services/apple_auth_service.dart` (FILE MỚI ~112 dòng, STRICT verbatim appendix): `AppleAuthTokens{idToken, rawNonce, email?, givenName?, familyName?}` + `displayName` getter join non-empty; `AppleCredentialRequester` typedef seam; sha256 nonce (`Random.secure()` 16-byte → base64url rawNonce; gửi `sha256.convert(utf8.encode(rawNonce))`; repo truyền rawNonce cho `signInWithIdToken(nonce:)`).
- `lib/repositories/auth/auth_repository.dart` (STRICT): + dòng thứ ba `export 'supabase_auth_repository.dart';`.
- `lib/core/app_dependency_scope.dart` (STRICT): `final AuthRepository authRepository` + required ctor + `Provider<AuthRepository>.value` giữa leaderboard và navigationController.
- `lib/main.dart` (STRICT): `debugPrint('[auth] repository=${supabaseClient == null ? 'disabled' : 'supabase'}')` + `final AuthRepository authRepository = supabaseClient == null ? DisabledAuthRepository(environment: supabaseEnvironment) : AuthRepositoryImpl(client: supabaseClient, googleAuthService: GoogleAuthServiceImpl(environment: supabaseEnvironment), appleAuthService: …)` + truyền scope — CÙNG dấu `?:` của leaderboard.
- TEST (STRICT): `test/supabase_auth_repository_test.dart` +2 test Apple mapping (top-level `authSessionFromAppleAuthResponse` — enrich email/displayName từ tokens khi Supabase thiếu; fallbackUser); call-site scope truyền `authRepository` đủ (compile-forced mọi AppDependencyScope test dựng — menu_provider_scope, ui_events, game_screen, leaderboard dialog, onboarding).
- `flutter analyze` sạch; `flutter test` → **201/201** (STRICT 199 + 2). `flutter run` → console `[auth] repository=disabled` (không dart-define).
- KHÔNG ĐƯỢC có (chưa đến): `MenuAuthActionCoordinator`/`UserProfileSyncRepository`/`ProfileSyncStateData`/`profileSyncRepository` trên scope (BÀI 3); `MenuAuthDialogViewModel`/`MenuSignOutDialogViewModel`/dialog UI/`requestAuthAction`/pill tappable/`MenuAuthRequested`/`MenuSignOutRequested` (BÀI 4–5); `_currentLeaderboardUserId` switch authState (BÀI 4 — giờ vẫn `→ null`); AI dùng `GoogleSignIn().signIn()` v6 (DIVERGED); hardcode clientId thật (secret — DIVERGED); `try/catch` quanh `initialize` nuốt nhánh (null là sentinel — đã học M23).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- Bài 1: session model + contract + DisabledAuthRepository + barrel 2-export giờ 3-export; M23 đỉnh (leaderboard cluster + dialog + row + main ternary leaderboard + env/SQL); M22 VM-save; M21 layer; M20 lifelines; M14–M18 nền.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m24/02
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
