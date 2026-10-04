# M24 Implementation Notes — Authentication

Senior baseline: `main@c8eb860` (read-only, unchanged).
Learner outcome: **193 → 224 tests**, analyze clean, `flutter build web` PASS,
site 126 → 132 pages, `LIVE_AUTH_FLOW: NOT_PERFORMED`.

## Architecture landed

- **Session model** — sealed `AuthSessionData`:
  `AuthSessionGuest` / `AuthSessionAuthenticated{uid,email,displayName,…}`;
  `AuthActionResult` for action outcomes. Guest is a real state, never null.
- **Repository layer** — `AuthRepository` contract;
  `DisabledAuthRepository` (guest session, sign-in returns failure carrying
  `configurationError`); `AuthRepositoryImpl` = Supabase email sign-in/up
  (incl. confirm-email branch) + `GoogleAuthServiceImpl` (google_sign_in v7)
  + `AppleAuthServiceImpl` (response-mapping helpers, appendix path).
  `authStateStream` is `BehaviorSubject`-backed: seeded `.value` + emit on
  `onAuthStateChange`; `loadAuthState` hydrates from current session.
- **DI** — conditional on `SupabaseClient?` sentinel, same pattern as
  leaderboard: unconfigured → `DisabledAuthRepository`; configured → impl.
- **Coordinator** — `MenuAuthActionCoordinator` owns sign-in/sign-out
  orchestration; `signOut` success → `resetUserProfile()` (FR-11) then
  `syncUserProfile` call-site (disabled seam).
- **ViewModels** — `MenuViewModel` gains `AuthRepository` (seed `_authState`
  + `_handleAuthState` subscription + `isAuthenticated` + `loadAuthState`
  inside `loadUserProfile`, `requestAuthAction` → session-routed event);
  dialog VMs own their snackbar events (FR-12).
- **UI** — `widgets/menu/auth/` (6 files): auth dialog (email + Google +
  Apple appendix), sign-out dialog, scopes, loading overlay; profile pill
  guest (`menuGuestName`) ↔ authenticated (username).
- **Leaderboard FR-35** — current-user uid now read from
  `authStateStream.value` inside `MenuLeaderboardDialogScope`; the M23
  guest seam is closed.

## Corrected-in-QA detail (senior parity)

`MenuSnackBarRequested` was initially deleted at implementation. Senior
inspection showed the class + screen-bridge case are retained upstream
with zero emit sites. Restored: class stays in the sealed family and in
`menu_screen.dart`'s bridge; only the menu-VM emit site retired (moved to
dialog VMs). `MenuAuthRequested`/`MenuSignOutRequested` are documented
learner-only transport until M29 (senior uses `MenuDialogAuth`/
`MenuDialogSignOut` state).

## Temporary / deferred (register-bounded)

- FR-36: `UserProfileSyncRepositoryDisabled` no-op + `Provider` wiring +
  `_syncSavedGameResult` stub + `FakeUserProfileSyncRepository` — seam only;
  real remote sync is **M25**.
- `showDialog` transport → M29; DRE → M26; visual parity → M28.
- Apple sign-in is appendix/non-core; live OAuth untested (no credentials).

## Sequential replay

`193 → 199 → 201 → 201 → 219 → 224` reproduced on the carried-forward
clone; end-state parity byte-identical across `lib/`, `test/`,
`pubspec.yaml` (`10-sequential-replay.md`).
