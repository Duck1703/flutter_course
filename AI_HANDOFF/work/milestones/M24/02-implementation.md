# M24 IMPLEMENTATION — Authentication (guest mode + Supabase auth seams)

Role: FLUX | Baseline: 193/193 tests · analyze clean | Senior ref: `flutter-accelerator-ai` @ `main@c8eb860` (read-only, unchanged)

Result: **224/224 tests pass** (+31 net new) · `flutter analyze` clean (0 issues) · `flutter build web` PASS · `LIVE_AUTH_FLOW: NOT_PERFORMED` (no credentials/provider config — per M23 handoff, inherited `NOT_PERFORMED`; never a gate).

---

## 1. NEW FILES (allow-list)

| File | LOC | Port basis / notes |
|---|---|---|
| `lib/data/auth/auth_session_data.dart` | 58 | **Verbatim** senior — `sealed AuthSessionData` → `AuthSessionGuest` / `AuthSessionAuthenticated{uid,email,displayName,photoUrl}`; `isAuthenticated` getter; full `==`/`hashCode` on all fields. |
| `lib/repositories/auth/auth_repository_contract.dart` | 60 | **Verbatim** — `AuthActionResult{isSuccess,message}` (`success`/`failure` factories) + `abstract interface class AuthRepository` (`authStateStream` `ValueStream`, `loadAuthState`, signIn×3/signUp/signOut, `dispose`). |
| `lib/repositories/auth/auth_repository.dart` | 5 | Barrel — exports contract + disabled + impl (one import, same as senior barrel). |
| `lib/repositories/auth/disabled_auth_repository.dart` | 78 | **Verbatim** — seeded `BehaviorSubject(AuthSessionGuest())`; all sign-* → `AuthActionResult.failure(environment.configurationError ?? 'Sign in is unavailable.')`; `signOut` → success no-op (FR: "unconfigured runtime — guest mode must work"). |
| `lib/repositories/auth/supabase_auth_repository.dart` | 317 | **Verbatim** `AuthRepositoryImpl` incl. `_sessionFromUser` (metadata `full_name`/`name`, `avatar_url`/`picture`), `onAuthStateChange` listener w/ `onError → Guest`, `_sessionProfileOverride` + `_applySessionProfileOverride` (Apple first-login profile patch), top-level `authSessionFromAppleAuthResponse(response, tokens, {fallbackUser})` test seam. `GoogleSignInException.canceled` → 'Sign in was cancelled.' |
| `lib/services/google_auth_service.dart` | 101 | **v7 API** — `GoogleAuthTokens{idToken,accessToken?}` + `GoogleAuthService` contract + `GoogleAuthServiceImpl`: one-shot `GoogleSignIn.instance.initialize(clientId: iosId, serverClientId: webId)` (empty→null), `authenticate(scopeHint:['email','profile'])`, `authorizationForScopes ?? authorizeScopes` best-effort accessToken. **No legacy `signIn()`** (forbidden — verified absent). |
| `lib/services/apple_auth_service.dart` | 112 | **Verbatim** — `AppleAuthTokens` (+`displayName` join of given/family), `AppleAuthService` contract, `AppleCredentialRequester` typedef test seam, `AppleAuthServiceImpl`: 16-byte secure nonce → `sha256.convert(utf8.encode(rawNonce))` via `crypto` → `SignInWithApple.getAppleIDCredential(scopes:[email,fullName], nonce: hashed)`. |
| `lib/repositories/profile/user_profile_sync_repository_contract.dart` | 25 | **Verbatim** — `UserProfileSyncRepository.syncUserProfile(AuthSessionAuthenticated)` + `syncStateStream` + `dispose`. |
| `lib/data/profile/profile_sync_state_data.dart` | 44 | **Verbatim** — sealed `ProfileSyncStateData` → `ProfileSyncIdle`/`ProfileSyncInProgress`/`ProfileSyncFailed(message)`. |
| `lib/repositories/profile/user_profile_sync_repository.dart` | 34 | **Only `UserProfileSyncRepositoryDisabled`** (seeded `ProfileSyncIdle`, no-op `syncUserProfile`). `UserProfileSyncRepositoryImpl` (merge + upsert `public.users`) intentionally absent → **M25 seam**. |
| `lib/view_models/menu/menu_auth_action_coordinator.dart` | 154 | **Verbatim** senior behavior — `signInWithGoogle/Apple/Email`, `signUpWithEmail`, `signOut`; each wraps `authRepository.*` → `loadAuthState()` → on authenticated `profileSyncRepository.syncUserProfile(session)`; sign-out success → `userProfileRepository.resetUserProfile()` (FR-11 target); guard "success but no active session" → `'Sign in failed: no active session.'` |
| `lib/view_models/menu/menu_auth_dialog_view_model.dart` | 165 | **Verbatim** — `isLoading` flag, single-flight guard, sealed `MenuAuthDialogUiEvent` (`DismissRequested`/`SnackBarRequested(message)`), `continueAsGuest` → dismiss; failures emit snackbar only (dialog stays). |
| `lib/view_models/menu/menu_sign_out_dialog_view_model.dart` | 111 | **Verbatim** — `signOut()` → coordinator.signOut → success: dismiss+snackbar; failure: snackbar only; single-flight; `_isDisposed` guard. |
| `lib/widgets/menu/auth/menu_auth_dialog_scope.dart` | 136 | `showMenuAuthDialog(context)` reads 3 repos from context → `showDialog` → `MenuAuthDialogScope` (`ChangeNotifierProvider<MenuAuthDialogViewModel>`) + `_MenuAuthDialogBridge` (attach/guard/cancel; `DismissRequested`→`Navigator.pop`, `SnackBarRequested`→`ScaffoldMessenger`; `isLoading`→`MenuLoadingOverlay`). Transport = `showDialog`, not `MenuDialogLayer` → **M29**. |
| `lib/widgets/menu/auth/menu_auth_dialog.dart` | 234 | Senior structure in learner chrome (`AlertDialog`+`MenuTokens`, no `SettingsDialogShell`): `AnimatedSwitcher` between `_AuthMethodButtons` and `_EmailForm`; Apple button gated `Theme.of(context).platform == TargetPlatform.iOS`; `_canSubmitEmailForm`; validation verbatim senior (`_validateEmailForm`/`_validateRegisterForm`, `_minimumPasswordLength = 6`). |
| `lib/widgets/menu/auth/menu_auth_dialog_content.dart` | 331 | `part of` file — `_EmailAuthMode{signIn,register}`, `_MenuAuthActionButton` (`ElevatedButton.icon` w/ MenuTokens), `_AuthMethodButtons` (Google/Apple?/Email/Guest), `_EmailForm` (3 fields, animated confirm+error sections, mode toggle, back), `_AnimatedAuthSection` (`AnimatedCrossFade`), `_AuthTextField`. Keys: `menu-auth-dialog`, `auth-email-form`, `auth-method-buttons`, `auth-submit-button-{mode}`, `auth-mode-toggle-{mode}`. |
| `lib/widgets/menu/auth/menu_sign_out_dialog_scope.dart` | 127 | `showMenuSignOutDialog(context)` + scope + bridge; `PopScope(canPop: !isLoading)` (learner equivalent of senior `onDismissLockChanged`); cancel `null` while loading. |
| `lib/widgets/menu/auth/menu_sign_out_dialog.dart` | 102 | `AlertDialog` key `menu-sign-out-dialog`: `signOutPrompt` + red `signOutButton` (`ElevatedButton.icon`, logout icon) + `cancelButton`. |
| `lib/widgets/menu/auth/menu_loading_overlay.dart` | 18 | Opaque barrier + `CircularProgressIndicator` — dialog `isLoading` surface. |
| `test/helpers/fake_auth_repository.dart` | 164 | **Verbatim** senior fake (package renamed): per-method `…Result`/`…Session`/`…Completer` scripting, `…CallCount`, `lastEmail`/`lastPassword`, `_emitSessionIfSuccessful` on success. |
| `test/helpers/fake_profile_sync_repository.dart` | 41 | **Verbatim** senior fake: `syncCallCount`, `lastSyncedSession`, `syncError` throw scripting. |
| `test/menu_auth_dialog_view_model_test.dart` | 404 | **Verbatim** senior port (11 tests, see §4) + learner add-on test "success without session → 'no active session' guard". |
| `test/menu_sign_out_dialog_view_model_test.dart` | 167 | **Verbatim** senior port (3 tests, see §4). |
| `test/supabase_auth_repository_test.dart` | 183 | **Pure mapping tests only** (no `SupabaseClient`): 2 senior-verbatim `authSessionFromAppleAuthResponse` cases + folded `AuthSessionData` (2) + `DisabledAuthRepository` (4) per allow-list "or fold into repo test". |

## 2. EDITED FILES

| File | Change |
|---|---|
| `pubspec.yaml` | +`google_sign_in: ^7.2.0`, `sign_in_with_apple: ^8.1.0`, `crypto: ^3.0.7` — senior pins. `flutter pub get` resolved cleanly (google_sign_in 7.2.0). |
| `lib/main.dart` | env→`SupabaseClientService.initialize` (kept) → `supabaseClient == null ? DisabledAuthRepository(environment:) : AuthRepositoryImpl(client:, googleAuthService: GoogleAuthServiceImpl(environment:), appleAuthService: AppleAuthServiceImpl())`; `profileSyncRepository` **always `UserProfileSyncRepositoryDisabled()`** (M25 seam, explicit comment); both wired into `AppDependencyScope`; `[auth] repository=disabled/supabase` debugPrint mirrors senior. |
| `lib/core/app_dependency_scope.dart` | +`AuthRepository`, `+UserProfileSyncRepository` fields/ctor/`Provider.value` entries (8 providers total); doc comment notes M24 pair. |
| `lib/view_models/menu/menu_screen_ui_event.dart` | +`MenuAuthRequested`, +`MenuSignOutRequested`; `MenuSnackBarRequested` emit site removed (FR-12). **[AMENDMENT]: class + bridge case RESTORED post-impl-QA — senior keeps both with zero emit sites; FR-12 = emit-site move.** |
| `lib/view_models/menu/menu_view_model.dart` | ctor +`required AuthRepository`; seed `_authState = authStateStream.value` + subscribe `_handleAuthState` (compare-before-notify, `_isDisposed` guard); +`isAuthenticated` getter; +`requestAuthAction()` (`AuthSessionAuthenticated`→`MenuSignOutRequested`, else `MenuAuthRequested`); `loadUserProfile()` now also awaits `authRepository.loadAuthState()` (senior parity); **removed `resetProfile()`** (FR-11); cancel auth sub in `dispose`. |
| `lib/screens/menu_screen.dart` | `_ProfileHeader` +`isAuthenticated`+`onAccountTap`; pill `GestureDetector(key:'menu-profile-pill')` wrapped in `Semantics(button,label:accountSemanticLabel)`; name `isAuthenticated ? profile.username : l10n.menuGuestName`; subtitle `menuSyncedStatus`/`menuGuestSyncHint`; accent `statGreen`(authed)/`accentYellow`(guest); **reset button + plumbing removed**; `_handleUiEvent` +`MenuAuthRequested`→`_openAuthDialog()`→`showMenuAuthDialog`, +`MenuSignOutRequested`→`_openSignOutDialog()`→`showMenuSignOutDialog`; no snackbar emit site (FR-12; `MenuSnackBarRequested` case kept for parity per amendment). |
| `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart` | ctor +`required AuthRepository`; `_currentLeaderboardUserId()` now **senior-verbatim exhaustive switch** (`AuthSessionAuthenticated(:uid)`→`uid`, `AuthSessionGuest()`→`null`) — **FR-35 closed** (was guest-seam `null` in M23). |
| `lib/widgets/menu/leaderboard/menu_leaderboard_dialog_scope.dart` | `showLeaderboardDialog` reads `AuthRepository` from context; `MenuLeaderboardDialogScope` ctor +`required AuthRepository`; passes into `LeaderboardDialogViewModel` — FR-35 wiring. |
| `lib/l10n/app_en.arb` / `app_vi.arb` | +24 senior auth keys verbatim (en/vi): `accountSemanticLabel`, `menuGuestName`, `menuGuestSyncHint`, `menuSyncedStatus`, `syncProgressTitle`, `syncProgressDescription`, `signInWithGoogleButton`, `signInWithAppleButton`, `signInWithEmailButton`, `continueAsGuestButton`, `emailFieldLabel`, `passwordFieldLabel`, `confirmPasswordFieldLabel`, `backButton`, `signInButton`, `createAccountButton`, `enterEmailPasswordError`, `enterValidEmailError`, `confirmPasswordError`, `passwordMinLengthError`, `passwordsDoNotMatchError`, `accountTitle`, `signOutPrompt`, `signOutButton`. `cancelButton` reused (pre-existing). **Removed `resetProfileButton`** (unused after FR-11). |
| `lib/l10n/app_localizations*.dart` | Regenerated via `flutter gen-l10n` (checked-in output). |

## 3. SENIOR → LEARNER SYMBOL MAPPING

| Senior symbol | Learner M24 | Status |
|---|---|---|
| `AuthSessionData` sealed (guest/authed) | same | verbatim |
| `AuthActionResult` + `AuthRepository` contract | same | verbatim |
| `AuthRepositoryImpl` (Supabase + onAuthStateChange + override) | same | verbatim |
| `DisabledAuthRepository` (env.configurationError messages) | same | verbatim |
| `GoogleAuthServiceImpl` | `initialize`+`authenticate(scopeHint:)` v7 | verbatim API shape |
| `AppleAuthServiceImpl` (sha256 nonce seam) | same | verbatim |
| `UserProfileSyncRepository` contract + `ProfileSyncStateData` | same | verbatim |
| `UserProfileSyncRepositoryImpl` (public.users upsert/merge) | **`UserProfileSyncRepositoryDisabled` only** | **→ M25 seam** |
| `MenuAuthActionCoordinator` (sign-*→loadAuthState→sync; signOut→reset) | same | verbatim |
| `MenuAuthDialogViewModel` / `MenuSignOutDialogViewModel` + sealed events | same | verbatim |
| `MenuAuthDialog`/`MenuSignOutDialog`/`MenuLoadingOverlay` | `AlertDialog`+`MenuTokens` chrome; Apple iOS gate kept | visuals → M28 |
| `MenuScreenViewModel.requestAuthAction` (session-routed) | `MenuViewModel.requestAuthAction` emits events | transport FR-29 → M29 |
| `MenuDialogAuth`/`MenuDialogSignOut` states + `MenuDialogLayer` | `MenuAuthRequested`/`MenuSignOutRequested` + `showDialog` | → M29 |
| `LeaderboardDialogViewModel._currentLeaderboardUserId` switch | same | **FR-35 closed** |
| `main.dart` conditional auth DI + sync-disabled comment | same pattern | verbatim |

## 4. TEST DELTA — 193 → 224 (+31)

New tests:
- **`menu_auth_dialog_view_model_test.dart` (11)**: Google success→sync+dismiss+snackbar; Google failure→no dismiss/no sync; Apple success (uid+displayName through sync); Apple failure; duplicate-social single-flight (completer); email sign-in success/failure (call args asserted); email sign-up w/ session→sync; sign-up w/o session→dismiss-no-sync; sign-in completing after dispose→no notify; success-without-session→'no active session' guard.
- **`menu_sign_out_dialog_view_model_test.dart` (3)**: sign-out success → `resetUserProfile` applied (profile back to defaults) + Guest emitted + dismiss+snackbar (**FR-11 core**); failure → dialog stays, profile preserved, session still authed; duplicate-tap single-flight.
- **`supabase_auth_repository_test.dart` (8)**: Apple mapping preserves first-login fields; Apple mapping keeps Supabase metadata priority; `AuthSessionData.isAuthenticated` + equality; disabled repo — guest seed, `configurationError` message, fully-configured fallback 'Sign in is unavailable.', signOut success.
- **`menu_view_model_test.dart` (+6 auth tests; −2 retired reset/snackbar)**: guest seed→`isAuthenticated` false; authed seed→true; stream emit authed→flip+notify; guest `requestAuthAction`→`MenuAuthRequested`; authed→`MenuSignOutRequested`; **re-route by current session** (guest→auth→tap→sign-out event).
- **`menu_screen_ui_events_test.dart` (7, rewritten)**: play→GameScreen via `AppNavigationController`; leaderboard row→dialog loads repo; guest header shows 'Khách'+hint, hides local username; guest pill→auth dialog w/ method buttons, no Apple; 'Tiếp tục với khách'→dismiss; authed pill→sign-out dialog; Google failure→snackbar from dialog VM inside menu Scaffold (FR-12) w/ dialog staying open.
- **`leaderboard_dialog_view_model_test.dart` (+1)**: authenticated session→`lastCurrentUserId == 'auth-uid-1'` (**FR-35**).
- **`sealed_state_test.dart`**: exhaustive switch updated (−`MenuSnackBarRequested`, +auth/sign-out) — compile-level closure of event set.

Edited call sites (no test-count change): `menu_provider_scope_test.dart` (scope +2 deps; guest pill assertions → 'Khách'; authed sessions where username asserted), `menu_leaderboard_dialog_test.dart` (scope +`authRepository`, app scope +2), `game_screen_test.dart` (`menuApp` +2), `onboarding_overlay_test.dart` (`MultiProvider` +auth+sync fakes).

## 5. COMMAND EVIDENCE

```
flutter pub get    → OK; google_sign_in 7.2.0, sign_in_with_apple, crypto resolved
flutter gen-l10n   → OK (24 auth keys live in app_localizations*.dart)
flutter analyze    → "No issues found!" (2.6s)
flutter test       → "+224: All tests passed!" (baseline 193 → 224)
flutter build web  → "√ Built build\web" (~53s; Wasm dry-run + cupertino_icons
                     font notices are pre-existing platform messages, non-fatal)
Credential grep (sbp_|eyJ|service.?role|-----BEGIN|api_key=|.env files)
                   → clean; only doc prose + 'x.supabase.co'/'example.supabase.co'
                     test literals; no .env files
Senior repo        → git status clean; HEAD still c8eb860 (read-only)
```

## 6. DELIBERATE DIVERGENCES (per brief)

- **D1 — Profile-sync seam stays disabled**: `main()` always constructs `UserProfileSyncRepositoryDisabled()` even when Supabase is configured; `UserProfileSyncRepositoryImpl` (merge + `public.users` upsert) is **M25 by design** — call-site `coordinator.syncUserProfile(session)` already in place and covered by `FakeUserProfileSyncRepository` assertions (`syncCallCount`, `lastSyncedSession`). Continues to M25 unchanged.
- **D2 — Menu dialog transport**: `MenuAuthRequested`/`MenuSignOutRequested` one-shot events + `showDialog` routes — `MenuDialogLayer`/`MenuDialogAuth`/`MenuDialogSignOut` states are **M29** (same transport as settings/leaderboard). `PopScope(canPop: !isLoading)` replaces senior `onDismissLockChanged`+backdrop lock on sign-out.
- **D3 — Chrome**: `AlertDialog` + `MenuTokens` (`ElevatedButton.icon` pills, `TextField` w/ filled decoration) — no `SettingsDialogShell`/`OnboardingGameButton`/SVG/painter polish (→ M28). Dialog content keys keep senior parity where present.
- **D4 — Apple**: ported fully (service + repo path + dialog gate) although roadmap marks it appendix — user constraint requires senior-true port; button gated `Theme.of(context).platform == TargetPlatform.iOS` verbatim.
- **D5 — `loadUserProfile()`**: now also calls `authRepository.loadAuthState()` (senior parity — one loader fanning to both repos).
- **D6 — Header identity**: guest shows `menuGuestName` ('Khách') + `menuGuestSyncHint` accent-yellow; authed shows profile.username + 'Đã đồng bộ' statGreen — senior colors mapped to MenuTokens (`statGreen`/`accentYellow` ≈ mint500/qzdsYellow500).
- **D7 — Test placement**: session-model + disabled-repo cases folded into `supabase_auth_repository_test.dart` (allow-list "or fold into repo test"); widget-level dialog coverage folded into `menu_screen_ui_events_test.dart` rather than a new file.
- **D8 — Game VM seam**: pre-existing M22 stub `_syncSavedGameResult()` ("guest skip; auth/sync → M25") left untouched — documents where profile sync lands in M25.

## 7. NOT VERIFIED / KNOWN LIMITS

- **`LIVE_AUTH_FLOW: NOT_PERFORMED`** — no Supabase/Google/Apple credentials in this environment (inherited from M23 ledger; optional env-dependent checkpoint only). `AuthRepositoryImpl`/`GoogleAuthServiceImpl`/`AppleAuthServiceImpl` runtime paths are senior-verbatim source; covered by contract-level fakes + pure mapping tests.
- `SupabaseClient`-dependent code (`signInWithIdToken`, `onAuthStateChange` emission ordering) not executed — same constraint as M23 (no client construction in tests).
- `google_sign_in` v7 `initialize`/`authenticate` and `sign_in_with_apple` platform sheets not exercised (would need real plugin backends); service shapes verified at compile time.
- iOS-gated Apple button path covered by code inspection (test platform = Android/web → `findsNothing` asserted).
- `flutter build web` emitted benign pre-existing notices (Wasm dry-run suggestion; cupertino_icons font subsetting).
- Senior repo: read-only throughout; zero writes to `flutter-accelerator-ai` (`git status` clean @ `c8eb860`).

## 8. FR CLOSURE

| FR | Status | Evidence |
|---|---|---|
| **FR-11** (menu reset scaffold removed; sign-out resets profile) | CLOSED | `_ResetButton`/plumbing deleted from `menu_screen.dart`; `MenuViewModel.resetProfile()` deleted; `MenuAuthActionCoordinator.signOut`→`resetUserProfile()`; test "successful sign out resets profile" asserts `userProfileStream.value == UserProfileData()` + Guest emit. |
| **FR-12** (menu snackbar event removed; dialog VMs own snackbars) | CLOSED | `MenuSnackBarRequested` emit site deleted (class + bridge case kept senior-true with zero emit sites — restored post-impl-QA, see `03-implementation-qa.md` REVERIFY); dialog VMs emit `*SnackBarRequested` → bridge `ScaffoldMessenger`; widget test "sign-in failure → snackbar from dialog VM, dialog stays". |
| **FR-28** (account row identity + auth dialogs) | CLOSED | Pill `menu-profile-pill` → `requestAuthAction()` session-routes to `MenuAuthRequested`/`MenuSignOutRequested`; guest shows 'Khách'+hint, authed shows username+'Đã đồng bộ'; auth dialog (Google/Apple-iOS/Email/Guest + email form validation verbatim) + sign-out dialog + loading overlay + event bridges. |
| **FR-35** (leaderboard authed UID) | CLOSED | `LeaderboardDialogViewModel` ctor +`AuthRepository`; `_currentLeaderboardUserId()` exhaustive `switch(authState)` (authed→uid, guest→null); scope+`showLeaderboardDialog` wire repo; test asserts `lastCurrentUserId == 'auth-uid-1'`. |
