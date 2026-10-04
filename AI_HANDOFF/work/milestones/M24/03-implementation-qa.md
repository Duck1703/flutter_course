# M24 IMPLEMENTATION QA — Authentication (independent verify)

Role: ARGUS | Date: verify-run against learner-app HEAD (working tree) | Senior ref: `flutter-accelerator-ai` @ `main@c8eb860` (re-checked: `git log -1` = c8eb860, `git status` clean, read-only)

Method: re-ran gates myself; diffed every touched file against senior @c8eb860; grepped scope/credentials; read every new/changed test for real assertions. Evidence file claims verified, not trusted.

---

## 1. GATES RE-RUN

```
flutter analyze → "No issues found!" (1.8s)          CLEAN ✔ (evidence: clean)
flutter test    → "+224: All tests passed!"          224/224 ✔ (evidence: 224/224, baseline 193 → +31)
```

## 2. SENIOR FIDELITY — file-by-file

| File | Verdict | Evidence |
|---|---|---|
| `lib/data/auth/auth_session_data.dart` | VERBATIM | Sealed `AuthSessionGuest`/`AuthSessionAuthenticated{uid,email?,displayName?,photoUrl}`, `isAuthenticated` getter, full `==`/`hashCode` — identical to senior `lib/data/auth/auth_session_data.dart` (learner adds doc comments only) |
| `lib/repositories/auth/auth_repository_contract.dart` | VERBATIM | `AuthActionResult{isSuccess,message}` + `.success`/`.failure`; `AuthRepository`: `authStateStream` ValueStream, `loadAuthState`, signIn×3, signUp, signOut, dispose |
| `lib/repositories/auth/auth_repository.dart` | VERBATIM | Barrel = senior's 3 exports exactly |
| `lib/repositories/auth/disabled_auth_repository.dart` | VERBATIM | Seeded `BehaviorSubject(AuthSessionGuest())` (:26-28); all sign-* → `failure(configurationError ?? 'Sign in is unavailable.')` (:67-73); signOut → `success('Signed out successfully.')` (:63-65) |
| `lib/repositories/auth/supabase_auth_repository.dart` | VERBATIM | `BehaviorSubject` seeded from `client.auth.currentUser` (:49-51); `onAuthStateChange` w/ `onError → Guest` (:52-57); `signInWithIdToken(provider: OAuthProvider.google, idToken, accessToken)` (:86-90); apple path `nonce: tokens.rawNonce` (:112-116); `_sessionFromUser` metadata `full_name`/`name` + `avatar_url`/`picture` (:259-264); signUp confirm-email branch 'Check your email to confirm your account.' (:170-174); signOut clears `_sessionProfileOverride` + best-effort google signOut (:186-198); `_applySessionProfileOverride` (:239-251); top-level `authSessionFromAppleAuthResponse(response, tokens, {fallbackUser})` (:298-317). Line-for-line identical logic to senior |
| `lib/services/google_auth_service.dart` | VERBATIM (v7) | `GoogleSignIn.instance.initialize(clientId, serverClientId)` one-shot (:85-95); `authenticate(scopeHint:['email','profile'])` (:58-60); `authorizationForScopes ?? authorizeScopes` (:67-69); NO legacy `signIn()` (grep: only doc-comment mention) |
| `lib/services/apple_auth_service.dart` | VERBATIM | `AppleAuthTokens` + `displayName` join; `AppleCredentialRequester` typedef seam; 16-byte `Random.secure` nonce → `sha256.convert(utf8.encode(rawNonce))` → `getAppleIDCredential(scopes:[email,fullName], nonce: hashed)` |
| `lib/repositories/profile/user_profile_sync_repository_contract.dart` | VERBATIM | `syncStateStream`, `syncUserProfile(AuthSessionAuthenticated)`, `dispose` |
| `lib/data/profile/profile_sync_state_data.dart` | VERBATIM | Sealed `ProfileSyncIdle`/`InProgress`/`Failed{message}` |
| `lib/repositories/profile/user_profile_sync_repository.dart` | M24-CORRECT | ONLY `UserProfileSyncRepositoryDisabled` (seeded Idle, no-op `syncUserProfile`) + contract re-export. NO `Impl`/merge/`public.users` ops — M25 seam honored |
| `lib/view_models/menu/menu_auth_action_coordinator.dart` | VERBATIM | `_signInAndSync`: sign-in → `!isSuccess` early-return → `loadAuthState` → `session is! AuthSessionAuthenticated` → `failure('Sign in failed: no active session.')` → else `syncUserProfile(session)` (:103-129); `signUpWithEmail` same chain but returns original result when guest (:88-100); `signOut` → `resetUserProfile()` on success (:134-146) |
| `lib/view_models/menu/menu_auth_dialog_view_model.dart` | VERBATIM | Sealed `MenuAuthDialogUiEvent` (Dismiss/SnackBar); `_isLoading` single-flight (:110); `_isDisposed` guards on emit+notify; success → dismiss+snackbar, failure → snackbar only |
| `lib/view_models/menu/menu_sign_out_dialog_view_model.dart` | VERBATIM | Same shape; `signOut()` → coordinator → dismiss+snackbar / snackbar-only |
| `lib/view_models/menu/menu_view_model.dart` | CONVERGED | ctor +`required AuthRepository` (:32); seeds `_authState = authStateStream.value` (:36) + `_authStateSubscription` (:44-46); `isAuthenticated` (:85); `requestAuthAction()` session-routes guest→`MenuAuthRequested` / authed→`MenuSignOutRequested` (:170-176); `loadUserProfile()` awaits BOTH repos (:93-96); `resetProfile()` **GONE**; auth sub cancelled in dispose (:182). Events-vs-MenuDialogState is documented M29 transport |
| `lib/view_models/menu/menu_screen_ui_event.dart` | CONVERGED | `MenuAuthRequested`/`MenuSignOutRequested` present (:49-57); `MenuSnackBarRequested` **GONE** (sealed set = 5 variants; senior keeps its own copy because its settings flow still emits it — learner correctly removed since dialog VMs own snackbars now) |
| `lib/screens/menu_screen.dart` | CONVERGED | `_ProfileHeader` +`isAuthenticated`+`onAccountTap` (:245-253); pill `GestureDetector(key:'menu-profile-pill')` + Semantics button+`accountSemanticLabel` (:275-281); name `isAuthenticated ? profile.username : l10n.menuGuestName` (:307-309); subtitle `menuSyncedStatus`/`menuGuestSyncHint` (:319-321); accent statGreen/accentYellow (:261-263); reset button/plumbing **GONE** (grep: comments only); `_handleUiEvent` exhaustive switch has NO snackbar case; auth/sign-out routed via `showMenuAuthDialog`/`showMenuSignOutDialog` → `showDialog` (:119-128, :171-174) — NOT MenuDialogLayer (M29) |
| `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart` | FR-35 CLOSED | ctor +`required AuthRepository` (:41); `_currentLeaderboardUserId()` = senior-verbatim exhaustive `switch(authState)` → `AuthSessionAuthenticated(:uid)`/`AuthSessionGuest()→null` (:114-119) — byte-identical to senior :91-96 |
| `lib/widgets/menu/leaderboard/menu_leaderboard_dialog_scope.dart` | FR-35 WIRED | `showLeaderboardDialog` reads `context.read<AuthRepository>()` (:23); scope ctor +passes it (:44-61) |
| `lib/widgets/menu/auth/*` (6 files) | SEMANTIC VERBATIM | `showMenuAuthDialog`/`showMenuSignOutDialog` read 3 repos → `showDialog` → provider-scoped VMs; bridges map `DismissRequested`→`Navigator.pop`, `SnackBarRequested`→`ScaffoldMessenger`; `MenuLoadingOverlay` (`AbsorbPointer`+scrim) on `isLoading`; `showApple = Theme.of(context).platform == TargetPlatform.iOS` (:77); validation verbatim (`_validateEmailForm`/`_validateRegisterForm`, `_minimumPasswordLength=6`, same 5 l10n keys); `PopScope(canPop: !isLoading)` = documented learner equivalent of senior `onDismissLockChanged` (D2) |
| `lib/main.dart` + `lib/core/app_dependency_scope.dart` | CONVERGED | `supabaseClient == null ? DisabledAuthRepository(environment:) : AuthRepositoryImpl(client:, googleAuthService: GoogleAuthServiceImpl(environment:), appleAuthService: AppleAuthServiceImpl())` (:68-76); `profileSyncRepository` **always** `UserProfileSyncRepositoryDisabled()` (:80-81 — deliberate vs senior's conditional, M25 seam); both provided under CONTRACT types in MultiProvider (scope :83-84); `[auth] repository=disabled/supabase` debugPrint (:53) |

## 3. TEST QUALITY

- `test/helpers/fake_auth_repository.dart` — handwritten (no mock pkg); seeded subject; per-method `…Result`/`…Session`/`…Completer`/`…CallCount` + `lastEmail`/`lastPassword`; verbatim senior port (incl. its deferred-signOut quirk — faithful).
- `test/helpers/fake_profile_sync_repository.dart` — handwritten; `syncCallCount`/`lastSyncedSession`/`syncError`.
- `menu_auth_dialog_view_model_test.dart` (11 = senior 10 + 1): all assert concrete state — `syncCallCount`/`lastSyncedSession.uid`, event types+messages, call args, single-flight via Completer, dispose-guard (`notifications==1`). **'no active session' test is real**: `FakeAuthRepository(signInSession: AuthSessionGuest())` + default success result → coordinator's `loadAuthState` returns Guest → asserts `didSignIn==false`, `syncCallCount==0`, snackbar `'Sign in failed: no active session.'` (:374-403). Signup-without-session case scripts `emailSignUpSession: AuthSessionGuest()` → dismiss w/o sync, original message (:318-352).
- `menu_sign_out_dialog_view_model_test.dart` (3): uses REAL `UserProfileRepositoryImpl` (SharedPreferences mock) — success case saves `level:30` profile then asserts `userProfileStream.value == const UserProfileData()` + `authStateStream.value == AuthSessionGuest()` (FR-11 core); failure preserves profile+session; completer single-flight.
- `supabase_auth_repository_test.dart` (8): 2 senior-verbatim `authSessionFromAppleAuthResponse` mapping cases (token-enrichment + Supabase-metadata-priority) — uses `AuthResponse`/`User` data classes only, NO `SupabaseClient`/network; +2 session-model; +4 disabled-repo (guest seed; `'Supabase is not configured.'`; fully-configured fallback `'Sign in is unavailable.'`; signOut success).
- `menu_view_model_test.dart` +6 auth tests (seed/authed/stream-emit/both routes/re-route by live session); retired reset+snackbar tests removed.
- `menu_screen_ui_events_test.dart` 7 widget tests — real pumps: guest shows 'Khách'+'Đăng nhập để đồng bộ' and HIDES local username; guest pill→auth dialog (method buttons, Apple absent on non-iOS); continue-as-guest→dismiss; authed pill→sign-out dialog; Google-failure→SnackBar inside menu Scaffold with dialog staying (FR-12 widget proof).
- `leaderboard_dialog_view_model_test.dart` +1: authed session → `lastCurrentUserId == 'auth-uid-1'` (FR-35).
- `sealed_state_test.dart` — exhaustive switch updated (−snackbar +auth/sign-out) — compile-level closure.
- Call-site edits verified in `menu_provider_scope_test.dart`, `menu_leaderboard_dialog_test.dart`, `game_screen_test.dart`, `onboarding_overlay_test.dart` (scope +2 deps, fakes wired).
- No `SupabaseClient(`/`.initialize`/legacy `signIn()` in `test/` (grep clean).

## 4. SCOPE VIOLATIONS — CLEAN

Grep `lib/` for `UserProfileSyncRepositoryImpl|upsert|mergeUserProfile|public.users|MenuDialogAuth|MenuDialogSignOut|MenuDialogLayer|Dre|asyncOp|OTP|magic-link` → **all 28 hits are doc comments** (M25/M29 seam documentation); zero code-symbol hits. `public.users` in `leaderboard_repository.dart:14` is a pre-existing M23 RLS comment; `Dre`/`asyncOp` hit is a pre-existing M22 "not yet" comment. No OTP/magic-link/recovery/account-linking anywhere.

## 5. CREDENTIAL AUDIT — CLEAN

- `sbp_`/`eyJ`/service-role/`-----BEGIN`/`api_key=`/`clientSecret`/`apps.googleusercontent.com`: zero source hits (only generated `build/`+`.dart_tool/` JS artifacts — gitignored; learner-app has no VCS anyway).
- No `.env*` files in tree.
- Only dart-define NAMES read: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID` (`supabase_environment.dart`); `main.dart` documents `--dart-define=<name>` without values.
- Test fixtures synthetic: `'id-token'`, `'raw-nonce'`, `'user-1'`, `'auth-uid-1'`, `'https://example.supabase.co'`, `'x.supabase.co'`, `'password123'`, `'publishable-key'`, `'web-client-id'`.

## 6. PUBSPEC

`+google_sign_in: ^7.2.0`, `+sign_in_with_apple: ^8.1.0`, `+crypto: ^3.0.7` (lines 50-52) — exactly the senior pins, nothing else added. Dev-deps unchanged (`fake_async` pre-existing; no mockito/mocktail/build_runner).

## 7. ARB

- 24 senior auth keys verbatim in BOTH `app_en.arb`+`app_vi.arb` (machine-compared vs senior ARB — all 24 OK both locales).
- `resetProfileButton`: ABSENT in learner AND absent in senior — dead learner-scaffold key correctly removed.
- en/vi key sets identical (102/102, no drift); generated `app_localizations{,_en,_vi}.dart` in sync (all 102 keys present; `menuGuestName => 'Khách'`). Two flagged raw-string diffs (`walkAwayMessage`, `onboardingReadyTitle`) are `''`→`\'` escaping artifacts, pre-existing.
- FINDING (cosmetic, pre-existing): `cancelButton` learner `'CANCEL'`/`'HUỶ'` vs senior `'Cancel'`/`'Hủy'` — pre-existing learner key reused by the new sign-out dialog (evidence documents reuse); casing matches learner chrome convention. Not an M24 regression.

## 8. GUEST PATH — VERIFIED

`SupabaseClientService.initialize` returns `null` (no throw) when `!isSupabaseConfigured` (:19-21) → `main()` constructs `DisabledAuthRepository` (:68-69) → stream seeded `AuthSessionGuest` → menu renders 'Khách' + guest hint, play/leaderboard/settings unaffected (M22 game tests pass; `[game] result profile sync skipped; auth/sync → M25` seam logs during run). Sign-in attempts return `AuthActionResult.failure('Supabase is not configured.')` → snackbar, dialog stays — statically verified + covered by disabled-repo tests + widget test (Google failure → SnackBar shown, dialog open).

## 9. MINOR FINDINGS (non-blocking)

1. `cancelButton` casing differs from senior ('HUỶ' vs 'Hủy') — pre-existing learner key, documented reuse; cosmetic.
2. `FakeAuthRepository.signOut` deferred-completer path skips Guest emit — verbatim senior quirk, not a learner deviation.
3. `syncProgressTitle`/`syncProgressDescription` used as auth-dialog title/body (senior does the same — verified keys identical; intentional senior semantics).
4. Evidence's "+31" arithmetic: net adds ≈ +27–31 depending on retired-count bookkeeping; actual total **224 verified by re-run** — authoritative figure matches.

## VERDICT

```
ARGUS_M24_IMPLEMENTATION_QA: PASS
ANALYZE: CLEAN
TESTS: 224/224 PASS
FIDELITY: PASS (all rows §2 verbatim-or-converged; only documented divergences D1–D8 observed)
SCOPE: CLEAN (28 grep hits = comments only; no Impl/merge/MenuDialog*/DRE/asyncOp/OTP code)
CREDENTIAL_AUDIT: CLEAN (no secrets/.env; dart-define names + synthetic fixtures only)
FR_CLOSURES: FR-11 PASS | FR-12 PASS | FR-28 PASS | FR-35 PASS
BLOCKERS: none
```

## REVERIFY

Post-remediation re-verify of the `MenuSnackBarRequested` restore (run against learner-app working tree; senior re-read @ `c8eb860`, `git status` clean).

**Senior parity — VERIFIED directly.** Senior `menu_screen_ui_event.dart:9` keeps the class; senior `menu_screen.dart:71` keeps the bridge case; grep over senior `lib/` shows `MenuSnackBarRequested(` only at the ctor + case arm → **zero emit sites** (senior settings emits its own `SettingsSnackBarRequested` — `settings_view_model.dart:218`; auth/sign-out snackbars emit `MenuAuthDialog…`/`MenuSignOutDialogSnackBarRequested`). §2's earlier rationale "senior keeps its copy because its settings flow emits it" was **wrong**; the restore brings learner to exact parity (class + case + zero emits both sides).

- `menu_screen_ui_event.dart:37-41` — class restored in sealed family at senior position (immediately after `MenuGameRequested`), `message` payload intact; family = 6 variants. ✓
- `menu_screen.dart:109-117` — `case MenuSnackBarRequested(:final message)` arm restored, body senior-verbatim (`ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)))`), comment cites senior `:71` + zero-emit state. ✓
- `sealed_state_test.dart:24,33,40` — `'snackbar'` arm + `describe(const MenuSnackBarRequested('hi'))` + `.message` payload expect kept; comment (:14-16) corrected. ✓
- Comment corrections verified — all now read "emit site retired, class kept": `menu_view_model.dart:135-141`, `menu_auth_dialog_view_model.dart:11-13`, `menu_auth_dialog_scope.dart:110-112`, `menu_view_model_test.dart:256-260`, `menu_screen_ui_events_test.dart:28-30`. ✓
- Emit sites: **zero** in learner `lib/` for `MenuSnackBarRequested` (grep: ctor + case arm + test-construction only). FR-12 closure still correct — emit-site retirement, not class deletion. ✓
- Gates re-run: `flutter analyze` → **No issues found** (2.3s); `flutter test` → **224/224 All tests passed**. ✓
- §2 rows for `menu_screen_ui_event.dart`/`menu_screen.dart` are superseded by this section ("GONE"/"NO snackbar case" → RESTORED for parity).
- Residual (minor, non-lesson): stale "class deleted/removed" lines remain in `01-brief.md:65,78-81` and `02-implementation.md:45,82,126` — ledgers still describe the pre-restore state. Learner-facing lessons + registries already corrected; flagged for a one-line ledger amendment.

```
ARGUS_M24_IMPL_REVERIFY: PASS — analyze CLEAN / tests 224/224 / FR-12 closure correct (emit-site retirement only; class + bridge case kept = senior parity, zero emits both sides)
ARGUS_M24_CONTENT_REVERIFY: PASS
F1_RESOLVED: YES
F2_RESOLVED: YES
NO_NEW_DEFECTS: NO — stale ledger lines (minor, non-lesson): `01-brief.md:65,78-81`, `02-implementation.md:45,82,126` still claim MenuSnackBarRequested deleted/removed
```
