# M25 Implementation Notes — Remote Profile Sync

Senior baseline: `main@c8eb860` (read-only, unchanged).
Learner outcome: **224 → 236 tests**, analyze clean, `flutter build web` PASS,
site 132 → 138 pages, `LIVE_PROFILE_SYNC: NOT_PERFORMED`.

## Architecture landed

- **Boundary DTO** — `lib/data/profile/app_user_data.dart`:
  `AppUserData` (8 fields, snake↔domain mapping:
  `fromMap`/`fromProfile`/`toUpsertMap`/`toProfile` + defensive
  `_stringValue`/`_nullableStringValue`/`_intValue` parsers).
- **Merge policy** — `mergeUserProfileForSync` (top-level pure):
  progression leader = higher `level`, tiebreak higher `currentExp`;
  cumulative totals = per-field max (`totalMoneyWon`,
  `totalQuestionCount`, `gamesJoined`); session identity wins
  (`displayName`/`photoUrl` over remote names); `gamesWon` local-only
  (no `users` column); `_withoutDemoProgression` normalizes the legacy
  `'TÀU HỦ ĐI CHILL'` demo seed before merge.
- **Repo impl** — `UserProfileSyncRepositoryImpl` (same file as
  `Disabled`, senior shape): `_isSyncing` re-entrancy guard;
  `ProfileSyncInProgress` → local `loadUserProfile` →
  `from('users').select().eq('auth_uuid').maybeSingle()` → merge →
  local `saveUserProfile` FIRST →
  `upsert(toUpsertMap(), onConflict:'auth_uuid')` → `ProfileSyncIdle`;
  catch → `ProfileSyncFailed(error.toString())` + rethrow; `_emit`
  dedupe + `isClosed` guard.
- **Conditional DI** — `main.dart`: `supabaseClient == null ?
  Disabled : Impl(client, userProfileRepository)` — third use of the
  M23 pattern.
- **Game VM** — ctor gains `authRepository` + `profileSyncRepository`
  (senior order profile→auth→sync); `_syncSavedGameResult` now real:
  `loadAuthState` → `AuthSessionAuthenticated` → `syncUserProfile`
  (started/completed logs); guest → `skipped; session=guest`; error →
  `failed: $error` swallowed (local save is source of truth; next
  sign-in syncs again).
- **Callers unchanged** — `MenuAuthActionCoordinator` already invoked
  `syncUserProfile` post sign-in/sign-up; the M24 seam closed at the
  impl level (FR-36 converged).

## Tests (+12)

- `user_profile_sync_merge_test.dart` — 7 senior tests verbatim.
- `user_profile_sync_schema_test.dart` — 2 senior tests verbatim.
- `result profile sync (M25, FR-36)` — 3 VM-level tests: authed →
  `syncCallCount==1` + uid; guest → skip; syncError → swallowed +
  local save intact.
- Call-site updates: `startedVm`/`pumpGameScreen` optional
  `{authRepo, syncRepo}` params; all `GameScreenViewModel(` sites.

## Fidelity notes

- SQL: `01-setup-database.sql` (from M23) + `02-verify-database.sql`
  (new this milestone) both byte-identical to senior.
- No repo-level test for `UserProfileSyncRepositoryImpl` — concrete
  `SupabaseClient` has no fake; senior likewise untested at that level.
- Learner keeps the `UserProfileData.defaultUsername = '0XFF'`
  divergence (pre-existing, register-tracked).
- `notificationService` exists in senior `main` but not learner —
  pre-existing architectural divergence outside M25 scope.

## Sequential replay

`224 → 226 → 233 → 233 → 233 → 236` reproduced; end-state parity
byte-identical (`10-sequential-replay.md`).
