# M24 → M25 HANDOFF — Remote Profile Sync

## What M25 inherits (verified, in place)

- `AuthSessionData` sealed family (`AuthSessionGuest` /
  `AuthSessionAuthenticated{uid, email, displayName…}`) with
  `BehaviorSubject`-backed `authStateStream` — seeded `.value` +
  broadcast emit (senior pattern).
- `AuthRepository` contract + `DisabledAuthRepository` +
  `AuthRepositoryImpl` (Supabase email + Google v7 + Apple appendix).
- **The sync seam (FR-36, intentionally temporary):**
  - `lib/data/profile/profile_sync_state_data.dart` — sealed sync-state
    family already exists.
  - `lib/repositories/profile/user_profile_sync_repository_contract.dart`
    — `UserProfileSyncRepository` contract already exists.
  - `lib/repositories/profile/user_profile_sync_repository.dart` —
    `UserProfileSyncRepositoryDisabled` no-op impl already exists.
  - `MenuAuthActionCoordinator` already calls `syncUserProfile` in its
    flow — the call-site is shaped correctly; it currently invokes the
    disabled no-op.
  - `app_dependency_scope.dart` + `main.dart` already provide
    `Provider<UserProfileSyncRepository>` (always-Disabled at M24).
  - `test/helpers/fake_profile_sync_repository.dart` already exists.
  - Game-save path already logs `result profile sync skipped;
    auth/sync → M25` — `_syncSavedGameResult` hook site exists in
    `game_screen_view_model.dart` (M22 stub).
- `FakeAuthRepository` supports `initialSession:` for authenticated
  test setups.

## What M25 must implement

- Real `UserProfileSyncRepositoryImpl` — remote merge + upsert
  `public.users` per senior (inspect senior impl + SQL/RLS first).
- Local/remote merge semantics on sign-in and on session restore.
- Post-game-result remote persistence (fill `_syncSavedGameResult`).
- Retry/error handling + observable sync state (existing sealed family).
- Conditional DI: Disabled when unauthenticated/unconfigured vs real
  impl — per senior's actual gating.
- Vietnamese lessons + site integration + sequential replay.

## Constraints carried forward

- `LIVE_PROFILE_SYNC` will be `NOT_PERFORMED` unless credentials appear —
  record honestly; do not weaken tests.
- Keep showDialog transport (M29); no DRE (M26); no M28 visual scope.
- Senior `main@c8eb860` read-only.
