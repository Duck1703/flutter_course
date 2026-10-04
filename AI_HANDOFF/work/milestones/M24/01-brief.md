# M24 BRIEF — Authentication (contract → disabled → providers)

Role: Atlas | Step: 18 | Baseline: 193/193 · analyze clean · web+site PASS · senior `main@c8eb860`

Roadmap M24, verbatim intent: model auth as sealed session stream;
`AuthRepository`; disabled guest mode; Supabase email + Google
sign-in; sign-out with profile reset; auth dialog from menu avatar;
authenticated menu identity; FR-11/FR-12 convergence.

---

## SENIOR FIDELITY CHECK

### Senior target (verified @ `main@c8eb860`)

| Senior file | Key symbols | Role |
|---|---|---|
| `lib/data/auth/auth_session_data.dart` | `sealed AuthSessionData` → `AuthSessionGuest` / `AuthSessionAuthenticated{uid,email?,displayName?,photoUrl?}`; `isAuthenticated` getter | session model |
| `lib/repositories/auth/auth_repository_contract.dart` | `AuthActionResult{isSuccess,message}` + `.success`/`.failure`; `AuthRepository`: `authStateStream` (ValueStream), `loadAuthState`, `signInWithGoogle/Apple/Email`, `signUpWithEmail`, `signOut`, `dispose` | contract |
| `lib/repositories/auth/disabled_auth_repository.dart` | `DisabledAuthRepository(environment:)` — seeded `AuthSessionGuest`; sign-in → `AuthActionResult.failure(configurationError ?? 'Sign in is unavailable.')`; signOut → success | guest impl |
| `lib/repositories/auth/supabase_auth_repository.dart` | `AuthRepositoryImpl{client,googleAuthService,appleAuthService}` — `BehaviorSubject` seeded from `client.auth.currentUser`; `onAuthStateChange` listener; `signInWithIdToken(provider: OAuthProvider.google)`; `signInWithPassword`; `signUp`; `signOut` (+google signOut, clears `_sessionProfileOverride`); `_sessionFromUser` (userMetadata `full_name`/`name` + `avatar_url`/`picture`); `_applySessionProfileOverride` (Apple display-name enrichment); top-level `authSessionFromAppleAuthResponse` | provider impl |
| `lib/services/google_auth_service.dart` | `GoogleAuthService` contract + `GoogleAuthServiceImpl` — `GoogleSignIn.instance.initialize(clientId: googleIosClientId?, serverClientId: googleWebClientId?)`, `authenticate(scopeHint:['email','profile'])` (v7 — NOT legacy `signIn()`), `authorizationForScopes`/`authorizeScopes` → `GoogleAuthTokens{idToken,accessToken?}` | google v7 |
| `lib/services/apple_auth_service.dart` | `AppleAuthService` contract + impl — `AppleAuthTokens{idToken,rawNonce,email?,givenName?,familyName?,displayName}`; sha256 nonce (crypto) | apple (appendix) |
| `lib/repositories/profile/user_profile_sync_repository_contract.dart` | `UserProfileSyncRepository`: `syncStateStream`, `syncUserProfile(AuthSessionAuthenticated)`, `dispose` | sync contract (impl = M25) |
| `lib/data/profile/profile_sync_state_data.dart` | sealed `ProfileSyncIdle`/`ProfileSyncInProgress`/`ProfileSyncFailed{message}` | sync state (impl = M25) |
| `lib/repositories/profile/user_profile_sync_repository.dart` | `UserProfileSyncRepositoryDisabled` — seeded `ProfileSyncIdle`, `syncUserProfile` no-op | disabled impl (M24); `Impl` = M25 |
| `lib/view_models/menu/menu_auth_action_coordinator.dart` | `MenuAuthActionCoordinator` — `signIn*`/`signUp` → `_signInAndSync` (sign-in → `loadAuthState` → `AuthSessionAuthenticated` → `syncUserProfile(session)`; guest after "success" → `AuthActionResult.failure('no active session')`); `signOut` → repo → `resetUserProfile()` on success | coordinator |
| `lib/view_models/menu/menu_auth_dialog_view_model.dart` | `MenuAuthDialogViewModel` — `_isLoading` single-flight, `MenuAuthDialogUiEvent` sealed: `DismissRequested`/`SnackBarRequested{message}`; success → dismiss + snackbar | dialog VM |
| `lib/view_models/menu/menu_sign_out_dialog_view_model.dart` | same shape: `signOut()` → coordinator → dismiss + snackbar | sign-out VM |
| `lib/view_models/menu/menu_screen_view_model.dart` | `_authState` + `authStateStream` subscription + `isAuthenticated`; `requestAuthAction()` → auth vs sign-out by session; `_events` ONLY emits `MenuGameRequested` | menu VM |
| `lib/widgets/menu/auth/` | `MenuAuthDialogScope`/`MenuSignOutDialogScope` (provider-scoped VM + event bridge: dismiss→onDismiss, snackbar→ScaffoldMessenger; `MenuLoadingOverlay` while `isLoading`); `MenuAuthDialog` (method buttons → email form: sign-in/register toggle, controllers, validation); `showApple = Theme.of(context).platform == TargetPlatform.iOS` | dialogs |
| `lib/widgets/menu/profile/menu_profile_header.dart` | `isAuthenticated` + `onAccountTap`; name = `isAuthenticated ? data.username : l10n.menuGuestName`; pill accent swap | header |
| `test/helpers/fake_auth_repository.dart` | `FakeAuthRepository` — seeded subject, scriptable results + Completers + call counts | fake |
| `test/helpers/fake_profile_sync_repository.dart` | `FakeUserProfileSyncRepository` — records `lastSyncedSession`/`syncCallCount`, scriptable `syncError` | fake |
| `test/menu_auth_dialog_view_model_test.dart`, `test/menu_sign_out_dialog_view_model_test.dart` | VM tests: success→dismiss+snackbar, failure→snackbar only, single-flight | test model |
| `test/supabase_auth_repository_test.dart` | pure mapping tests (`authSessionFromAppleAuthResponse`) — no network | test seam |

### Current learner form

- `_ProfileHeader` — avatar icon + `profile.username` + gear; no
  `isAuthenticated`, no `onAccountTap` (FR-28).
- `MenuViewModel.resetProfile()` + menu reset button (`resetProfileButton`
  ARB) + `MenuSnackBarRequested('Đã đặt lại hồ sơ.')` emit —
  course-only scaffolds (FR-11/FR-12). Senior has NEITHER.
- `MenuViewModel` ctor: `userProfileRepository` only.
- `LeaderboardDialogViewModel` guest seam (FR-35): no `AuthRepository`,
  `_currentLeaderboardUserId()` ≡ `null`.
- No `AuthRepository`, session types, google/apple services, sync repo.
- `rxdart: ^0.28.0` already in pubspec (BehaviorSubject convention).
- Menu dialog transport: event+`showDialog` (FR-29 → M29).

### Senior target form → learner M24 form

| Element | Learner M24 | Convergence |
|---|---|---|
| `AuthSessionData` sealed family | verbatim | final |
| `AuthActionResult` + `AuthRepository` contract | verbatim | final |
| `DisabledAuthRepository` | verbatim | final |
| `AuthRepositoryImpl` (Supabase) | verbatim incl. `_sessionFromUser`, `onAuthStateChange` wiring, `_sessionProfileOverride`, `authSessionFromAppleAuthResponse` | final (Apple = appendix lesson) |
| `GoogleAuthService` + impl | verbatim (v7 `initialize`+`authenticate`) | final |
| `AppleAuthService` + impl | verbatim | final (appendix lesson) |
| `UserProfileSyncRepository` contract + `ProfileSyncStateData` + `UserProfileSyncRepositoryDisabled` | verbatim (disabled impl only — `Impl` is M25) | M25 fills impl |
| `MenuAuthActionCoordinator` | verbatim — `syncUserProfile` calls hit disabled impl (no-op) until M25 | final call sites; impl M25 |
| `MenuAuthDialogViewModel` / `MenuSignOutDialogViewModel` + sealed ui-events | verbatim | final |
| `MenuViewModel` | +`AuthRepository` ctor dep, `_authState` sub, `isAuthenticated`, `requestAuthAction()` → `MenuAuthRequested`/`MenuSignOutRequested` events (learner transport); `resetProfile()` + `MenuSnackBarRequested` emit site + reset button REMOVED (FR-11/FR-12 converge — class kept senior-true, see FR-12 amendment) | final |
| `LeaderboardDialogViewModel` | FR-35 convergence: ctor +`AuthRepository`; `_currentLeaderboardUserId()` → senior `switch(authState)`; scope passes `context.read<AuthRepository>()` | FR-35 closes |
| `_ProfileHeader` | +`isAuthenticated` + `onAccountTap`; name `isAuthenticated ? profile.username : l10n.menuGuestName`; MenuTokens pill accent | final semantics; visuals M28 |
| Auth dialog | learner chrome: method buttons (Google, Apple iff `TargetPlatform.iOS`, email) → email form (sign-in/register toggle + validation per senior rules) + `continueAsGuest` + loading overlay + `onDismiss`; event bridge maps `DismissRequested`→pop, `SnackBarRequested`→ScaffoldMessenger | final semantics; chrome M28 |
| Sign-out dialog | prompt + sign-out/cancel; success → dismiss + snackbar; profile reset via coordinator | final semantics; chrome M28 |
| `main()`/scope | +`authRepository` + `profileSyncRepository` under same `client==null?Disabled:Supabase` pattern | final |
| ARB | +~20 senior auth keys verbatim + `menuGuestName`; REMOVE `resetProfileButton` if dead | final |

### Register entries owned

- **FR-11** (menu reset button scaffold): **CLOSES** — button +
  `resetProfile()` + emit site removed; semantics live in sign-out
  coordinator (`resetUserProfile` after successful sign-out).
- **FR-12** (menu snackbar emit site): **CLOSES** —
  `MenuSnackBarRequested` *emit site* removed; snackbars emit
  from dialog VMs (`MenuAuthDialogSnackBarRequested`,
  `MenuSignOutDialogSnackBarRequested`).
  **[AMENDMENT — post-impl-QA parity fix]: the class itself + bridge
  case were RESTORED — senior keeps both with zero emit sites
  (`menu_screen_ui_event.dart:9`, `menu_screen.dart:71`). FR-12 =
  emit-site move only; class stays as channel contract.**
- **FR-28** (account row/auth identity): **CLOSES** — header pill
  tappable, `isAuthenticated` drives accent+name, `requestAuthAction`
  routes guest→auth dialog, authenticated→sign-out dialog.
- **FR-35** (leaderboard VM guest seam): **CLOSES** — `AuthRepository`
  injected; senior `switch(authState)` restored.
- New row: `MenuAuthActionCoordinator.syncUserProfile` hits
  `UserProfileSyncRepositoryDisabled` (no-op) — real sync → **M25**.
- FR-29 dialog transport stays ACTIVE →M29. FR-30 icon pipeline
  re-evaluated — auth icons stay `IconData` → M28 umbrella.

### Permitted simplifications

- Dialog chrome = MenuTokens (no senior SVG shell/button styles) → M28.
- `_sessionProfileOverride` + `authSessionFromAppleAuthResponse` ported
  verbatim (simplest senior-true path) but taught as APPENDIX, not
  core lesson content (roadmap).
- Email validation rules ported as-implemented (presence, `@`,
  confirm match, min-6, `passwordsDoNotMatchError`, `confirmPasswordError`).

### Forbidden alternatives

- NO `UserProfileSyncRepositoryImpl` / merge logic / `public.users`
  ops (M25). Coordinator's `syncUserProfile` MUST hit the disabled
  impl — do not fake sync success UI.
- NO `MenuDialogAuth`/`MenuDialogSignOut` state variants or layer (M29).
- NO DRE/asyncOp (M26).
- NO magic-link/OTP/recovery/account-linking (not in senior).
- NO committed credentials; dart-define names only.
- NO `google_sign_in` legacy `signIn()` API — v7 `initialize`+
  `authenticate` only.
- NO mock packages.

### Remote-service assumptions

- `LIVE_AUTH_FLOW: NOT_PERFORMED` — no credentials/provider config.
  Disabled guest mode + fakes cover all gates.
- `google_sign_in: ^7.2.0`, `sign_in_with_apple: ^8.1.0`,
  `crypto: ^3.0.7` — senior pins; all mature (>7 days).
- Apple button renders only on `TargetPlatform.iOS` (senior verbatim)
  — on web/Android it's absent by design.

---

## LEARNING DESIGN CHECK

### New Dart concepts
- Sealed session union (`AuthSessionGuest`/`Authenticated`) — reuse of
  M15 sealed-state concept for *identity*.
- `AuthActionResult` — success/failure value type instead of throw.
- `BehaviorSubject` reuse for `authStateStream` (same pattern as
  `userProfileStream` from M14).
- `userMetadata` map → session fields (defensive `_metadataString`).

### New Flutter/backend concepts
- Supabase Auth: `client.auth.currentUser`, `onAuthStateChange`,
  `signInWithPassword`, `signUp`, `signInWithIdToken(provider,
  idToken, accessToken)`, `signOut`.
- `google_sign_in` v7: `GoogleSignIn.instance.initialize` →
  `authenticate(scopeHint:)` → `authentication.idToken` →
  `authorizationForScopes`.
- Identity vs authorization vs profile (three different concepts).

### New architecture concepts
- Auth repository feeding a *session stream* consumed by menu VM —
  same subscribe-in-ctor pattern as profile stream.
- Action coordinator: dialog VM → coordinator → auth repo → loadAuthState
  → sync repo → result. (Sync call lands on disabled impl at M24.)
- Dialog-scoped VMs emitting their OWN sealed ui-events (dismiss +
  snackbar) — FR-12 convergence: snackbar ownership moves to dialogs.
- `requestAuthAction` routes on session: guest→auth, authed→sign-out.

### Prerequisites (verify closed)
- M14 repo contracts + `BehaviorSubject` + subscribe-in-ctor.
- M15 sealed variants. M16 event→dialog transport.
- M23 `SupabaseClient` + env (`isGoogleConfigured`,
  `configurationError`) + conditional DI.

### Registry entries (to add)
- Sealed session union (Dart, guided) — new concept application.
- `AuthActionResult` value-type (Dart, applied).
- Auth session stream (architecture, guided).
- Action coordinator + post-sign-in sync hook (architecture, guided —
  sync impl deferred M25).
- `signInWithIdToken` idToken flow (backend, guided).
- `google_sign_in` v7 initialize/authenticate (backend, guided).
- `onAuthStateChange` subscription (backend, applied).
- Auth-vs-authorization-vs-profile distinction (awareness).
- Apple appendix: sha256 nonce (awareness, appendix).

### Mental models
- "Session is state; sign-in is an action" — stream holds WHO you are;
  `AuthActionResult` reports HOW an attempt went.
- "Three different nouns": auth user (identity), authorization (RLS —
  server-side, learned M23), profile (app data — local now, remote M25).
- "Guest is a real session" — `AuthSessionGuest` is a first-class
  state, not null/error.

### Isolated example
Tiny `AuthState`-style sealed union demo (guest/authed switch
rendering) BEFORE the real repo — plus a 2-impl fake-vs-disabled
`AuthRepository` mini-comparison.

### Independent exercises
- PRODUCE: write a `FakeAuthRepository` behavior test — script
  success→session stream assert + coordinator `syncCallCount` assert
  on the fake sync repo.
- DEBUG/PREDICT: planted bug — remove the `loadAuthState`+
  `AuthSessionAuthenticated` check in `_signInAndSync` (return result
  directly) → a fake repo reporting success without emitting an
  authenticated session must produce the observable failure; learner
  predicts which test/behavior catches it.

### Concept reinforcement
- M14 BehaviorSubject/stream-value; M15 sealed; M16 event transport;
  M23 conditional DI + env + RLS boundary.

### Cognitive-load assessment
Heaviest milestone so far: session model + 3 repo impls + coordinator +
2 dialog VMs + 2 dialogs + header + register closures. Split into
5 lessons; Apple + `_sessionProfileOverride` quarantine to an appendix
section inside the repo lesson; validation stays in the dialog lesson.

### Lesson split (planned 5)
1. Session model + `AuthActionResult` + auth repo contract +
   `DisabledAuthRepository` (guest mode) + auth-vs-authz-vs-profile.
2. `GoogleAuthService` (v7) + `AuthRepositoryImpl` Supabase impl
   (currentUser, onAuthStateChange, signInWithPassword/signUp/
   signInWithIdToken/signOut) + `main()` conditional DI;
   Apple impl + override = appendix box.
3. `ProfileSync` contract + disabled impl seam (why the coordinator
   takes it now; real impl M25) + `MenuAuthActionCoordinator`
   (signIn→session-check→sync hook; signOut→reset = FR-11/FR-12).
4. `MenuAuthDialogViewModel` + `MenuSignOutDialogViewModel` sealed
   ui-events + `MenuViewModel` auth subscription + `requestAuthAction`
   + FR-35 leaderboard seam closure.
5. UI: header pill (guest/authed) + auth dialog (method buttons →
   email form + validation + loading overlay) + sign-out dialog +
   reset-button retirement + honest live-auth caveats.

### Sequential checkpoint strategy
193 baseline → per-lesson `flutter test` deltas; all deterministic
(fakes). Configured-provider smoke = OPTIONAL/environment-dependent.

### Remote-runtime dependency strategy
`LIVE_AUTH_FLOW: NOT_PERFORMED` expected; fakes verify all behavior
except real provider round-trips.

---

## IMPLEMENTATION SCOPE (allow-list)

NEW: `lib/data/auth/auth_session_data.dart`,
`lib/repositories/auth/auth_repository_contract.dart`,
`lib/repositories/auth/auth_repository.dart` (barrel),
`lib/repositories/auth/disabled_auth_repository.dart`,
`lib/repositories/auth/supabase_auth_repository.dart`,
`lib/services/google_auth_service.dart`,
`lib/services/apple_auth_service.dart`,
`lib/repositories/profile/user_profile_sync_repository_contract.dart`,
`lib/repositories/profile/user_profile_sync_repository.dart`
(`UserProfileSyncRepositoryDisabled` only),
`lib/data/profile/profile_sync_state_data.dart`,
`lib/view_models/menu/menu_auth_action_coordinator.dart`,
`lib/view_models/menu/menu_auth_dialog_view_model.dart`,
`lib/view_models/menu/menu_sign_out_dialog_view_model.dart`,
`lib/widgets/menu/auth/` (auth dialog + scope + sign-out dialog +
scope + loading overlay + content/form — split per learner file-size
convention),
`test/helpers/fake_auth_repository.dart`,
`test/helpers/fake_profile_sync_repository.dart`,
`test/menu_auth_dialog_view_model_test.dart`,
`test/menu_sign_out_dialog_view_model_test.dart`,
`test/auth_session_data_test.dart` (or fold into repo test),
`test/supabase_auth_repository_test.dart` (pure mapping tests only).

EDIT: `pubspec.yaml` (+`google_sign_in ^7.2.0`, `sign_in_with_apple
^8.1.0`, `crypto ^3.0.7`), `lib/main.dart`,
`lib/core/app_dependency_scope.dart`,
`lib/view_models/menu/menu_view_model.dart` (+auth dep/sub,
`requestAuthAction`, −`resetProfile`, −snackbar emit),
`lib/view_models/menu/menu_screen_ui_event.dart`
(−`MenuSnackBarRequested`, +`MenuAuthRequested`/`MenuSignOutRequested`),
`lib/screens/menu_screen.dart` (header auth props, −reset button,
+auth/sign-out dialog bridge),
`lib/view_models/leaderboard/leaderboard_dialog_view_model.dart`
(+`AuthRepository`, senior switch — FR-35),
`lib/widgets/menu/leaderboard/menu_leaderboard_dialog_scope.dart`
(+`authRepository:`),
`lib/l10n/app_{en,vi}.arb` (+~20 senior keys, −`resetProfileButton` if
dead), affected tests.

## TEST PLAN (deterministic only)

- `FakeAuthRepository`: seeded stream, scriptable results+completers,
  call counts.
- Auth dialog VM: google/email/apple success → dismiss+snackbar;
  failure → snackbar only, dialog stays; single-flight guard;
  `continueAsGuest` → dismiss.
- Sign-out VM: success → coordinator reset (`FakeUserProfileRepository`
  reset assert) + dismiss + snackbar; failure → snackbar only.
- Coordinator: success-no-session → `failure('no active session')`;
  success → `syncUserProfile` called with session (fake sync repo);
  signOut success → `resetUserProfile` called.
- Disabled repo: guest stream; sign-in → failure message ==
  `configurationError ?? 'Sign in is unavailable.'`; signOut → success.
- Session model: `isAuthenticated`, equality.
- Mapping: `authSessionFromAppleAuthResponse` port tests (senior's
  two cases verbatim).
- Menu VM: `isAuthenticated` reflects stream; `requestAuthAction`
  guest→`MenuAuthRequested`, authed→`MenuSignOutRequested`; NO
  `MenuSnackBarRequested` remains; NO `resetProfile`.
- Leaderboard VM: authed uid now passed as `currentUserId` (FR-35).
- Widget: header pill tap opens auth dialog (guest) / sign-out dialog
  (authed); dialog renders method buttons + email form; sign-out
  dialog renders prompt; loading overlay while `isLoading`.

Expected: ~25-30 new tests → ~218-223.

## CREDENTIAL AUDIT SPEC

Grep touched files for keys/tokens/secrets/`.env`/client-ids with
values. Allowed: dart-define names + placeholders. Auth test fixtures
may use synthetic `id-token`/`uid` strings — clearly fake.

## DEFINITION OF DONE (M24)

G16–G24 PASS · impl QA PASS · content QA PASS · site QA PASS ·
replay PASS (from M23 clone — physical) · regression PASS ·
credential audit PASS · post-PASS CLEAN/REVERIFIED ·
`LIVE_AUTH_FLOW: NOT_PERFORMED` · senior unchanged ·
FR-11/FR-12/FR-28/FR-35 closed · disabled-sync row opened →M25 ·
M26 untouched.
