# M24 — CONTENT DRAFT MANIFEST (Lumen)

## Intake gate

`IMPLEMENTATION_APPROVED` confirmed — `03-implementation-qa.md` on
disk (Argus PASS). Learner app verified on disk per implementation
ledger: `flutter analyze` clean, `flutter test` **224/224**,
`flutter build web` PASS (02-implementation §5). Senior unchanged
(`main@c8eb860`, read-only — verified by Argus).
`LIVE_AUTH_FLOW: NOT_PERFORMED` inherited from M23 handoff
(no credentials/provider config — never a gate).

## Lessons authored (5 + index) — `AI_HANDOFF/work/milestones/M24/lessons/`

| File | Concepts (brief registry) | Exercise |
|---|---|---|
| `index.md` | milestone map + deferred table + synthesis + FR-11/12/28/35 closure note | — |
| `01-session-model.md` | **D-43** sealed session union applied to identity (Dart, guided→applied); **D-44** `AuthActionResult` value-type + private ctor + redirecting ctor (Dart, applied); **A-25** auth state stream — BehaviorSubject reuse for session (architecture, guided); **B-06** auth ≠ authorization ≠ profile (backend, awareness) | Tự làm PREDICT: `isAuthenticated`+message under 3 env combos; Thử nghiệm PREDICT `configurationError` ordering (Supabase before Google) |
| `02-supabase-auth-impl.md` | **B-04** `google_sign_in` v7 `initialize`-once + `authenticate(scopeHint:)` (backend, guided); **B-03** `signInWithIdToken` two-leg provider→Supabase (backend, guided); **B-05** `onAuthStateChange` subscription + seeded `currentUser` (backend, applied); conditional DI reuse (A-24); **APPENDIX B-07** sha256 nonce + `AppleAuthService` + `_sessionProfileOverride` + `authSessionFromAppleAuthResponse` (awareness, quarantined) | Tự làm PREDICT: `main()` ternary → impl + initial session per define combo; Thử nghiệm PREDICT fake emit semantics (`…Session` on success only) |
| `03-sync-seam-va-coordinator.md` | **A-26** action coordinator + post-sign-in sync seam (architecture, guided); "contract trước, impl sau" seam doctrine; `ProfileSyncStateData`/`UserProfileSyncRepository`/`UserProfileSyncRepositoryDisabled` (D-43/A-25 reuse); guard `is! AuthSessionAuthenticated` → `'Sign in failed: no active session.'`; sign-up confirm-email branch; `signOut→resetUserProfile` (FR-11) | **Tự làm DEBUG**: planted bug — replace guard+sync with `if (session is AuthSessionAuthenticated)` → scratch coordinator test fails at `expect(result.isSuccess, isFalse)`; predict+observe+restore+delete scratch |
| `04-dialog-vms-va-menu.md` | Dialog-scoped VMs + sealed `…UiEvent` families (FR-12 converge — snackbar ownership moves to dialog VMs); `_isLoading` single-flight + `_isDisposed` guards; `MenuViewModel` +`AuthRepository` seed/sub/`isAuthenticated`/`loadUserProfile` dual; FR-35 leaderboard `switch(authState)` → uid (`AuthSessionAuthenticated(:final uid)` object pattern) | **Tự làm PRODUCE**: write scratch `MenuSignOutDialogViewModel` sign-out-failure behavior test (fake `signOutResult` failure + authed `initialSession` → assert profile preserved + no dismiss + callCount) |
| `05-auth-ui.md` | `_ProfileHeader` tappable pill (guest `menuGuestName`+hint / authed username+`menuSyncedStatus`, accent swap, che username local của guest); `requestAuthAction` session routing → `MenuAuthRequested`/`MenuSignOutRequested`; auth dialog 2-page `AnimatedSwitcher` + `_EmailAuthMode` + senior-verbatim validation + `showApple` iOS gate; `PopScope`/`AbsorbPointer`/`part`-file; retire `resetProfile`/`_ResetButton` + emit site `MenuSnackBarRequested` — class kept senior-true with zero emit sites (FR-11/12 physical closure) | Tự làm PREDICT: `requestAuthAction` ×3 (guest→authed→guest) event sequence; Thử nghiệm PREDICT: remove `if (showApple)` → which widget test fails (`findsNothing` assert) |

## Concept → brief registry entry mapping

| Brief entry (LEARNING DESIGN CHECK) | Lesson | Registry row used in lessons |
|---|---|---|
| Sealed session union (Dart, guided) | L01 | **D-43** |
| `AuthActionResult` value-type (Dart, applied) | L01 | **D-44** |
| Auth session stream (architecture, guided) | L01/L04 | **A-25** |
| Action coordinator + post-sign-in sync hook (architecture, guided) | L03 | **A-26** |
| `signInWithIdToken` idToken flow (backend, guided) | L02 | **B-03** |
| `google_sign_in` v7 initialize/authenticate (backend, guided) | L02 | **B-04** |
| `onAuthStateChange` subscription (backend, applied) | L02 | **B-05** |
| Auth-vs-authorization-vs-profile distinction (awareness) | L01 | **B-06** |
| Apple appendix: sha256 nonce (awareness, appendix) | L02 appendix | **B-07** |

Mental models placed: "session là state, sign-in là action" → L01;
"guest là session thật" → L01; "idToken là hộ chiếu, Supabase session
là visa" (two-leg) → L02; "contract trước impl sau" + "coordinator
giữ chuỗi, VM giữ event" → L03; "VM dịch result thành event, bridge
dịch event thành UI" → L04; "session → intent → transport → dialog
VM" + "UI chỉ render; session quyết mọi thứ" → L05. Isolated
examples placed: `DoorState` sealed mini-union + two impls → L01;
two-leg token sketch → L02; 20-line `signInAndSync` chain → L03;
single-flight `Gate` → L04; `accountTap` routing switch → L05.

## Depth assignments

- Guided/new: **D-43** (sealed applied to identity — second
  application after M15), **A-25**, **A-26**, **B-03**, **B-04** —
  all NORMAL.
- Applied: **D-44**, **B-05** — NORMAL.
- Awareness/LIGHT: **B-06** (three-noun distinction), **B-07**
  (nonce mechanics — appendix only, not core path).
- No CORE_CONCEPT row claimed for M24 — every concept is an
  application of existing COREs (D-26/27 sealed+switch, A-08
  BehaviorSubject, D-19 interface, A-06/A-07/A-24 repo+DI, A-11
  fakes, M13 broadcast-event).
- ≤3 new concepts per page (excluding LIGHT/awareness): L01=3
  (D-43+D-44+A-25; B-06 awareness declared separately), L02=3
  (B-03+B-04+B-05; B-07 appendix-light), L03=1 (A-26), L04=0 new
  (all reinforcement: sealed events, dialog-scope, stream sub),
  L05=0 new (composition: part-file + PopScope + AnimatedSwitcher
  glossed at point of use).

## Registry / graph updates (done before QA)

- `LEARNER_CONCEPT_REGISTRY.md`: +**D-43/D-44** (Dart),
  +**A-25/A-26** (Architecture), +**B-03…B-07** (Backend — B-06/B-07
  INTRODUCED/awareness, rest TAUGHT).
- `PREREQUISITE_GRAPH.md`: M24 section appended (D-43/D-44/A-25 →
  L01 → B-03/B-04/B-05(+B-07) → L02 → A-26 → L03 → L04 reinforcement
  → L05; feeds M25 sync impl, M26 DRE, M28 visual parity, M29 dialog
  layer).
- `SENIOR_FIDELITY_REGISTER.md`: **FR-11 → CONVERGED at M24**
  (`_ResetButton`/`resetProfile()`/`resetProfileButton` removed;
  `coordinator.signOut→resetUserProfile`), **FR-12 → CONVERGED**
  (emit site `MenuSnackBarRequested` retired — class + bridge case
  kept senior-true with zero emit sites, matching senior's own
  zero-emit state; dialog `…SnackBarRequested`
  events own snackbars), **FR-28 → CONVERGED** (pill +
  `requestAuthAction` + two dialogs; settings-dialog account-row
  visual → M28 umbrella; version `v$appVersion` text → M27 noted),
  **FR-35 → CONVERGED** (VM +`AuthRepository`, `switch(authState)`
  → uid/null, test `lastCurrentUserId == 'auth-uid-1'`); new row
  **FR-36** (ACTIVE_TEMPORARY: `UserProfileSyncRepository` seam =
  Disabled no-op; `UserProfileSyncRepositoryImpl` merge+upsert
  `public.users` → M25); FR-30 note → M28 icon pipeline.

## Checkpoint arithmetic (honest, from M23 final 193)

| Lesson end | Count | Delta | Test files touched |
|---|---|---|---|
| L01 | **199** | +6 | `test/supabase_auth_repository_test.dart` created — `AuthSessionData` (2: isAuthenticated, equality) + `DisabledAuthRepository` (4: guest seed, configurationError message, fully-configured fallback, signOut success) |
| L02 | **201** | +2 | same file +`authSessionFromAppleAuthResponse` group (2: first-login fields preserved, Supabase metadata priority) + `test/helpers/fake_auth_repository.dart` (helper) + 4 `AppDependencyScope` call-sites `+authRepository:` (compile-forced: `menu_provider_scope_test.dart:42`, `menu_screen_ui_events_test.dart` `appUnderTest`, `widgets/game_screen_test.dart:136`, `widgets/menu_leaderboard_dialog_test.dart:244`) |
| L03 | **201** | +0 | `test/helpers/fake_profile_sync_repository.dart` (helper) + same 4 scope call-sites `+profileSyncRepository:` (compile-forced); coordinator coverage intentionally deferred to L04 VM tests |
| L04 | **219** | +18 | `test/menu_auth_dialog_view_model_test.dart` (+11, new file: 10 senior-verbatim + 1 learner guard test) + `test/menu_sign_out_dialog_view_model_test.dart` (+3, new) + `menu_view_model_test.dart` (+3 auth-state: guest seed, authed seed, emit→flip+notify) + `view_models/leaderboard/leaderboard_dialog_view_model_test.dart` (+1 FR-35 `auth-uid-1`); compile-forced: `menu_view_model_test` `makeVm` +`authRepository`, leaderboard VM test `createViewModel` +`authRepository`, `widgets/menu_leaderboard_dialog_test.dart` 2 scope call-sites +`authRepository`, `widgets/onboarding_overlay_test.dart` MultiProvider +auth+sync providers, `menu_screen.dart` `create:` +`authRepository` |
| L05 | **224** | +5 net | `menu_view_model_test.dart` (+3 `requestAuthAction` incl. re-route-by-current-session; −2 retired reset/snackbar tests) + `menu_screen_ui_events_test.dart` rewritten → 7 testWidgets (net +4: guest-header 'Khách'+hint no-username-leak, guest pill→auth dialog+Apple-hidden, continue-as-guest→dismiss, authed pill→sign-out, sign-in failure→snackbar from dialog VM in menu Scaffold — net of retired snackbar/reset-path cases) + `sealed_state_test.dart` (±0: describe-switch +2 auth cases — `MenuSnackBarRequested` case + payload expects kept senior-true) + ARB `+24 −1` (`resetProfileButton` removed) |

Cross-checked against impl QA: 6+2+0+18+5 = **+31 net** → 193+31 =
**224** ✓ (matches `02-implementation.md` §4 test delta table).

## Per-lesson checkpoint commands (all credential-free)

- L01: `flutter analyze`, `flutter test`,
  `flutter test test/supabase_auth_repository_test.dart`
- L02: `flutter pub get`, `flutter analyze`,
  `flutter test test/supabase_auth_repository_test.dart`,
  `flutter test`, `flutter run` (observe `[auth] repository=disabled`)
- L03: `flutter analyze`, `flutter test` (+ scratch exercise
  `flutter test test/m24_coordinator_guard_exercise_test.dart`)
- L04: `flutter analyze`,
  `flutter test test/menu_auth_dialog_view_model_test.dart`,
  `flutter test test/menu_sign_out_dialog_view_model_test.dart`,
  `flutter test` (+ scratch exercise
  `flutter test test/m24_signout_exercise_test.dart`)
- L05: `flutter gen-l10n`, `flutter analyze`, `flutter test`,
  `flutter build web`, `flutter run` (manual, no defines — observe
  pill 'Khách' + dialog + snackbar-from-dialog-VM) — OPTIONAL
  `flutter run --dart-define=SUPABASE_URL=<your-project-url>
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-publishable-key>
  --dart-define=GOOGLE_WEB_CLIENT_ID=<your-web-client-id>` labelled
  environment-dependent.

## Exercise inventory (milestone requirement: ≥1 PRODUCE + ≥1 DEBUG/PREDICT real defect)

| Lesson | Type | Task | Verifiability |
|---|---|---|---|
| L01 | PREDICT | `isAuthenticated`+message under 3 env combos | verifiable vs `DisabledAuthRepository` + `configurationError` ordering (env predicates from M23) |
| L02 | PREDICT | `main()` DI ternary → impl + seed per define combo | verifiable by reading `main.dart:68-76` + `[auth] repository=` log |
| L03 | **DEBUG** | planted bug: replace `is!` guard + unconditional sync with `if (session is AuthSessionAuthenticated)` in `_signInAndSync` → scratch coordinator test (fake `signInSession: AuthSessionGuest()` + default success result) | REAL defect verified causal chain: guard removed → coordinator returns success → `expect(result.isSuccess, isFalse)` fails (Actual: `true`); message becomes `'Signed in successfully.'` not `'Sign in failed: no active session.'`; `syncCallCount` still 0 (guest fails the `is` check — honest partial-pass trap documented). Same defect caught by shipped test `menu_auth_dialog_view_model_test.dart:374` 'success without session → failure "no active session" (guard)' — cross-referenced in lesson |
| L04 | **PRODUCE** | write scratch `MenuSignOutDialogViewModel` sign-out-failure behavior test meeting 3 requirements (failure result + authed seed; profile preserved + `signOutCallCount==1`; snackbar-only event, no dismiss) | runnable test vs production classes; full solution in `<details>`; mirrors shipped test 'failed sign out keeps dialog and preserves profile' |
| L05 | PREDICT | `requestAuthAction` ×3 event sequence (guest→authed→guest) + remove `showApple` gate → which test fails | verifiable vs shipped test 'requestAuthAction route theo session HIỆN TẠI' and ui-events test 'Apple ẩn trên non-iOS' `findsNothing` assert |

Scratch-exercise convention declared in both lessons: files
`test/m24_*_exercise_test.dart` are run with explicit `flutter test
<path>`, then deleted — the milestone suite contract stays 224/224
senior-parity (exercise files are not part of the senior test set).

## Senior citations used (all verified vs `main@c8eb860`)

| Lesson | Senior file · symbol |
|---|---|
| L01 | `lib/data/auth/auth_session_data.dart` (`AuthSessionData` sealed, `AuthSessionGuest`, `AuthSessionAuthenticated{uid,email,displayName,photoUrl}`, `isAuthenticated`); `lib/repositories/auth/auth_repository_contract.dart` (`AuthActionResult._`/`.success`/`.failure`, contract 8 members); `lib/repositories/auth/disabled_auth_repository.dart` (seeded Guest, `configurationError ?? 'Sign in is unavailable.'`, signOut success no-op); `lib/repositories/auth/auth_repository.dart` barrel |
| L02 | `lib/services/google_auth_service.dart` (`GoogleAuthTokens`, `GoogleSignIn.instance.initialize(clientId,serverClientId)`, `authenticate(scopeHint:['email','profile'])`, `authorizationForScopes ?? authorizeScopes`, `GoogleSignInException`/`canceled`, `_isInitialized` once-guard); `lib/repositories/auth/supabase_auth_repository.dart` (`AuthRepositoryImpl` seed `client.auth.currentUser`, `onAuthStateChange` onError→Guest, `signInWithIdToken(OAuthProvider.google)`, `signInWithPassword`, `signUp` confirm-email branch, `signOut` two-layer, `_sessionFromUser`/`_metadataString` full_name→name / avatar_url→picture, `_emit` compare-guard, `_sessionProfileOverride`/`_applySessionProfileOverride`, top-level `authSessionFromAppleAuthResponse(response,tokens,{fallbackUser})`); `lib/services/apple_auth_service.dart` appendix (`AppleAuthTokens.displayName`, `AppleCredentialRequester` typedef, 16-byte `Random.secure` nonce → `sha256.convert(utf8.encode(rawNonce))` → `nonce:` raw to Supabase) |
| L03 | `lib/repositories/profile/user_profile_sync_repository_contract.dart` (verbatim); `lib/data/profile/profile_sync_state_data.dart` (3 variants verbatim); `lib/repositories/profile/user_profile_sync_repository.dart` (`UserProfileSyncRepositoryDisabled` — senior file also hosts `UserProfileSyncRepositoryImpl`/`_upsertRemoteProfile`/`public.users` upsert cited as M25 target); `lib/view_models/menu/menu_auth_action_coordinator.dart` (verbatim: `_signInAndSync` guard `'Sign in failed: no active session.'`, sign-up branch, `signOut→resetUserProfile`, `_sessionLabel` switch, `[auth]` debugPrint labels); senior `main.dart` conditional `client == null ? UserProfileSyncRepositoryDisabled() : UserProfileSyncRepositoryImpl(client)` — learner divergence (always Disabled) documented |
| L04 | `lib/view_models/menu/menu_auth_dialog_view_model.dart` (verbatim: `MenuAuthDialogUiEvent`+2 variants, `_runAuthAction(label,failurePrefix,action)`, `continueAsGuest`, `_isLoading`/`_isDisposed`, dismiss-before-snackbar); `lib/view_models/menu/menu_sign_out_dialog_view_model.dart` (verbatim: `MenuSignOutDialogUiEvent`, `signOut`, `'Sign out failed: '); `lib/view_models/menu/menu_screen_view_model.dart` (auth seed+sub, `isAuthenticated`, `loadUserProfile` dual-call, `requestAuthAction`); `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart` (`AuthRepository` ctor param, `_currentLeaderboardUserId` `switch(authState)`); `test/menu_auth_dialog_view_model_test.dart` + `test/menu_sign_out_dialog_view_model_test.dart` + `test/helpers/fake_auth_repository.dart` + `test/helpers/fake_profile_sync_repository.dart` (verbatim ports) |
| L05 | `lib/widgets/menu/menu_profile_header.dart` (pill semantics: tappable, accent by session, guest-name masking, `Semantics` button); `lib/widgets/menu/auth/menu_auth_dialog.dart` + `menu_auth_dialog_content.dart` (structure verbatim: `_minimumPasswordLength=6`, `_EmailAuthMode`, `_authFadeDuration` 380ms, `_AuthMethodButtons`/`_EmailForm`/`_AnimatedAuthSection`/`_AuthTextField`, `_canSubmitEmailForm`, `_validateEmailForm`/`_validateRegisterForm`, `showApple` iOS gate, `continueAsGuest`); `lib/widgets/menu/auth/menu_sign_out_dialog.dart` (`signOutPrompt`, signOut/cancel buttons, cancel-disabled-on-loading); `lib/widgets/menu/auth/menu_loading_overlay.dart` (verbatim `AbsorbPointer`+`0x8C000000`+spinner); `lib/widgets/menu/auth/menu_auth_dialog_scope.dart`/`menu_sign_out_dialog_scope.dart` (`MenuAuthDialogScope`/`MenuSignOutDialogScope` — senior uses `onDismiss`/`onDismissLockChanged` callback transport + `SettingsDialogShell`; learner `showDialog`+`PopScope` divergence documented FR-29→M29); `lib/view_models/menu/menu_dialog_state.dart` (`MenuDialogAuth`/`MenuDialogSignOut` cited as M29 targets); 24 ARB keys verbatim + `cancelButton` casing delta (learner `HUỶ` vs senior `Hủy` — pre-existing cosmetic, documented non-blocking) |

## Remote-runtime honesty (hard requirement)

Every lesson states the mandatory path is deterministic fakes +
unconfigured Disabled fallback; **`LIVE_AUTH_FLOW: NOT_PERFORMED`**
appears verbatim in L02 (caution box), L05 (caution box), and
index.md (note + deferred table). The configured command form is
taught ONLY in L05 with `<your-…>` placeholders and values-from-own-
project framing; never implies a live provider flow was verified.
No real URL/key/token/nonce anywhere — only synthetic fixture
literals already present in the codebase (`'id-token'`, `'raw-nonce'`,
`'user-1'`, `'auth-uid-1'`, `'https://example.supabase.co'`,
`'publishable-key'`, `'web-client-id'`, `'password123'`).
Client-side code/publishable keys explicitly taught as NOT the
security boundary — RLS server-side is (reinforces M23 B-01).

## Declared deviations from template

- Lessons carry the Template-V2 spine (Mục tiêu → Bạn-đang-ở-đâu →
  Vì-sao → Bạn-đã-biết-gì → Mental-model → construct table → Ví dụ
  độc lập → Android bridge → Senior connection → Build steps →
  Hiểu code → Chạy-và-quan-sát → Thử nghiệm → Lỗi-hay-gặp →
  Tự-làm → Kiểm-tra-hiểu-biết → Ta-cố-ý-chưa-thêm → Checkpoint)
  **with two declared section merges** (gate G23):
  - **L02**: `## Senior project connection` is FOLDED into
    `## Đọc impl — AuthRepositoryImpl theo nhịp` — that walkthrough
    already cites senior file·symbol per impl beat
    (`supabase_auth_repository.dart` method-by-method,
    `google_auth_service.dart` v7 calls, appendix
    `apple_auth_service.dart`), so a second table would duplicate
    the same citations. All other spine sections present
    (incl. `## Hiểu code — hai câu hỏi hay hỏi`).
  - **L05**: `## Hiểu code` is FOLDED into `## Build it step by
    step` — the build steps themselves are the code-reading
    (per-file walk + senior-verbatim validation excerpt + bridge
    surgery notes); a separate Hiểu-code heading would re-walk the
    same lines. All other spine sections present (incl. the
    `## Senior project connection` table).
  - **L03** lands 4 production files + coordinator as "new seam" —
    its isolated example is the 20-line `signInAndSync` sketch;
    the DEBUG exercise uses a scratch test file because the
    catching shipped test (`menu_auth_dialog_view_model_test.dart`)
    doesn't exist until L04 — declared ordering, cross-referenced.
  - **L05** is a composition lesson: `part`/`part of`,
    `PopScope`, `AnimatedSwitcher`/`AnimatedCrossFade`,
    `AbsorbPointer` glossed in the construct table without separate
    registry rows (all LIGHT/first-use, applied composition —
    consistent with BEGINNER_CONTENT_STANDARD naming-at-point-of-use
    rule).
- Apple content deliberately quarantined to an `:::note[APPENDIX]`
  box in L02 (non-required path) — per brief; the 2 Apple mapping
  tests land in the same file as session/disabled tests
  (`supabase_auth_repository_test.dart`) per allow-list "fold into
  repo test".
- L04 `MenuViewModel` step intentionally does NOT include
  `requestAuthAction` (lands L05 with the event-set change) —
  declared two-step; the shipped file has it, and L05 brings the
  file to shipped state. Intermediate L04 VM keeps pre-existing
  `resetProfile()` + `MenuSnackBarRequested` emit site until the
  L05 retirement batch (the class itself stays in the sealed
  family — senior-true, zero emit sites thereafter).
- `main()` sync repo is **always** `UserProfileSyncRepositoryDisabled()`
  (shipped code, deliberate divergence vs senior conditional) —
  taught as divergence-with-reason in L03, not papered over.
- Scratch exercise files (`test/m24_*_exercise_test.dart`) are
  explicitly deleted after running — keeps the 224/224 senior-parity
  suite count honest.
- `cancelButton` vi casing (`HUỶ` vs senior `Hủy`) documented as
  pre-existing cosmetic difference, not introduced by M24.

## Verification before handoff

- Every quoted symbol grep-verified against learner source:
  `AuthSessionData`/`AuthSessionGuest`/`AuthSessionAuthenticated`
  (`data/auth/auth_session_data.dart`), `AuthActionResult._`/
  `.success`/`.failure` + contract 8 members
  (`repositories/auth/auth_repository_contract.dart`),
  `DisabledAuthRepository` (`configurationError ?? 'Sign in is
  unavailable.'`), `AuthRepositoryImpl` (`supabase_auth_repository.
  dart`: seed, `onAuthStateChange` onError→Guest, `signInWithIdToken`,
  `signInWithPassword`, `signUp`, `signOut`, `_sessionFromUser`,
  `_metadataString`, `_emit`, `_sessionProfileOverride`,
  `_applySessionProfileOverride`, `authSessionFromAppleAuthResponse`),
  `GoogleAuthServiceImpl` (`GoogleSignIn.instance.initialize`,
  `authenticate(scopeHint:)`, `authorizationForScopes`,
  `authorizeScopes`, `_isInitialized`, `supportsAuthenticate`,
  `GoogleSignInException`/`GoogleSignInExceptionCode.canceled`),
  `AppleAuthServiceImpl` (`sha256`, `Random.secure`, `nonce`),
  `UserProfileSyncRepository`/`UserProfileSyncRepositoryDisabled`/
  `ProfileSyncIdle`/`ProfileSyncInProgress`/`ProfileSyncFailed`,
  `MenuAuthActionCoordinator` (`_signInAndSync:103-129`,
  `signUpWithEmail:69-101`, `signOut:134-146`, `_sessionLabel`),
  `MenuAuthDialogViewModel` + `MenuAuthDialogUiEvent` +
  `DismissRequested`/`SnackBarRequested` + `_runAuthAction` +
  `continueAsGuest`, `MenuSignOutDialogViewModel` +
  `MenuSignOutDialogUiEvent`, `MenuViewModel` (`isAuthenticated`,
  `loadUserProfile`, `_handleAuthState`, `requestAuthAction`),
  `MenuScreenUiEvent` 6-variant set (`MenuSnackBarRequested` kept
  senior-true — zero emit sites; +2 learner-only auth variants),
  `LeaderboardDialogViewModel._currentLeaderboardUserId` switch,
  `MenuLeaderboardDialogScope` `+authRepository`,
  `showMenuAuthDialog`/`showMenuSignOutDialog`/`MenuAuthDialogScope`/
  `MenuSignOutDialogScope`/`_MenuAuthDialogBridge`/`PopScope`,
  `MenuAuthDialog`/`_MenuAuthDialogState` (`_minimumPasswordLength`,
  `_EmailAuthMode`, `_canSubmitEmailForm`, `_validateEmailForm`,
  `_validateRegisterForm`, `showApple`, `_setAuthFormState`,
  `continueAsGuest`), `MenuSignOutDialog`, `MenuLoadingOverlay`
  (`AbsorbPointer`,`0x8C000000`), `_ProfileHeader` (`isAuthenticated`,
  `onAccountTap`, `ValueKey('menu-profile-pill')`, `Semantics`,
  accent `statGreen`/`accentYellow`), `AppDependencyScope`
  `authRepository`/`profileSyncRepository` fields+providers,
  `main.dart` `[auth] repository=` + auth ternary + always-Disabled
  sync, `FakeAuthRepository` (`…Result`/`…Session`/`…Completer`/
  `…CallCount`/`lastEmail`/`lastPassword`/`initialSession`/
  `_emitSessionIfSuccessful`), `FakeUserProfileSyncRepository`
  (`syncCallCount`/`lastSyncedSession`/`syncError`),
  `FakeLeaderboardRepository.lastCurrentUserId`,
  ARB keys (24 new + `cancelButton` reuse − `resetProfileButton`).
- Senior symbols verified read-only: `MenuDialogAuth`/
  `MenuDialogSignOut` (`menu_dialog_state.dart`), senior
  `requestAuthAction` + `MenuDialogLayer` callback transport,
  senior `UserProfileSyncRepositoryImpl`/`_upsertRemoteProfile`/
  `public.users` upsert (M25 target), senior `SettingsDialogShell`/
  `OnboardingGameButton`/`MenuDialogBackdrop` chrome, senior
  `main.dart` conditional sync DI — all cited as evidence, never
  as paste-target.
- Test-count arithmetic re-derived from implementation §4 delta
  table + file greps: 8 (session/disabled/apple file) + 11 + 3 +
  4 (menu VM net) + 4 (ui-events net) + 1 (FR-35) = +31 → 224 ✓.
- No `dart test` anywhere — all suites are `flutter_test`/
  `flutter test`. `flutter analyze` referenced, never `dart analyze`.
- `flutter gen-l10n` required after ARB edit — stated in L05 +
  command list.
