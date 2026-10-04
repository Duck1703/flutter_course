# M25 BRIEF — Remote Profile Sync

## Objective

Replace the M24 `UserProfileSyncRepositoryDisabled` seam with the real
remote sync: senior `UserProfileSyncRepositoryImpl` (fetch → merge →
local save → remote upsert `public.users`), senior merge semantics in a
new `AppUserData`/`mergeUserProfileForSync` file, conditional DI in
`main.dart`, and the real `_syncSavedGameResult` branch in the game VM
(auth + sync repo injection). FR-36 converges.

## Senior source of truth (main@c8eb860)

- `lib/data/profile/app_user_data.dart` — `AppUserData` (9 fields,
  `fromMap`/`fromProfile`/`toUpsertMap`/`toProfile` + defensive
  `_stringValue`/`_nullableStringValue`/`_intValue`) +
  `mergeUserProfileForSync` (top-level, pure) + private helpers
  `_higherLevelProgressionProfile`, `_maxInt`, `_nonEmpty`,
  `_withoutDemoProgression`, `_hasDemoProgression` (demo profile:
  `'TÀU HỦ ĐI CHILL'`, lv12, `'1.000.000 VNĐ'`, 1M, 20 games, 12 won).
- `lib/repositories/profile/user_profile_sync_repository.dart` —
  ONE file holds `UserProfileSyncRepositoryImpl` + `UserProfileSyncRepositoryDisabled`:
  `_isSyncing` re-entrancy guard; emit `ProfileSyncInProgress` →
  `loadUserProfile` → `_fetchRemoteProfile` (`from('users').select().eq
  ('auth_uuid', uid).maybeSingle()`) → `mergeUserProfileForSync` →
  local `saveUserProfile` → `_upsertRemoteProfile`
  (`from('users').upsert(toUpsertMap(), onConflict: 'auth_uuid')` +
  `[sync]` debugPrint) → emit `ProfileSyncIdle`; catch → emit
  `ProfileSyncFailed(error.toString())` + rethrow; `_emit` guards
  `isClosed` + value-equality.
- `lib/main.dart` — `supabaseClient == null ? Disabled : Impl(client, userProfileRepository)`.
- `lib/view_models/menu/menu_auth_action_coordinator.dart` — already
  calls `syncUserProfile(session)` after successful sign-in/sign-up
  (learner call-sites already correct — verify, don't rewire).
- `lib/view_models/game/bridge/game_screen_view_model_result_persistence.dart`
  — senior `_syncSavedGameResult`: `loadAuthState()` →
  `AuthSessionAuthenticated` → `profileSyncRepository.syncUserProfile`
  with `[game] result profile sync started/completed` prints;
  guest → `skipped; session=guest`; catch → `failed: $error`.
- `lib/view_models/game/game_screen_view_model.dart` ctor —
  `required this.userProfileRepository, required this.authRepository,
  required this.profileSyncRepository, {this.questions = …}`.
- `lib/screens/game_screen.dart` — `create:` reads
  `context.read<AuthRepository>()` + `context.read<UserProfileSyncRepository>()`.
- `supabase/student-setup/01-setup-database.sql` — `public.users`
  table + constraints + `users_set_updated_at` trigger + RLS
  (select/insert/update own) + `leaderboard` view — **already ported
  byte-identical at M23**; re-verify byte equality, no re-write.
- Tests: `test/user_profile_sync_merge_test.dart` (7 tests),
  `test/user_profile_sync_schema_test.dart` (2 tests),
  `test/widgets/game_screen_result_flow_test.dart` (syncCallCount==1
  after authenticated result save) — learner ports at VM level.

## Learner starting state (verified)

- Seam exists: `profile_sync_state_data.dart` (identical sealed family),
  `user_profile_sync_repository_contract.dart` (identical contract),
  `user_profile_sync_repository.dart` (Disabled only), DI field +
  `Provider` already in scope, `FakeUserProfileSyncRepository` with
  `syncCallCount`/`lastSyncedSession`/`syncError` already exists,
  `FakeAuthRepository(initialSession:)` exists.
- Coordinator already calls `syncUserProfile` post-sign-in (lines ~96,126).
- Game VM `_syncSavedGameResult` is an explicit M25 STUB printing
  `skipped; auth/sync → M25`; ctor has only `userProfileRepository` +
  `questions`.
- `UserProfileData` has `==`, `copyWith`, `defaultUsername`/`defaultLevel`,
  `formatVnd`, `avatarUrl`, `gamesWon` — all merge dependencies exist.
- `AuthSessionAuthenticated` has `uid`/`email`/`displayName`/`photoUrl`.

## Implementation tasks

1. `lib/data/profile/app_user_data.dart` — verbatim senior port
   (adjust only import paths to learner package).
2. `lib/repositories/profile/user_profile_sync_repository.dart` —
   prepend `UserProfileSyncRepositoryImpl` (senior-verbatim, incl.
   `// ignore_for_file: prefer_initializing_formals`, imports, exports);
   keep `UserProfileSyncRepositoryDisabled`; update the file's header
   comment (no longer "CHỈ phần Disabled").
3. `lib/main.dart` — conditional sync DI per senior (`supabaseClient ==
   null ? Disabled : Impl(client: …, userProfileRepository: …)`);
   update the M24 "LUÔN Disabled" comment.
4. `lib/view_models/game/game_screen_view_model.dart` — ctor gains
   `required this.authRepository` + `required this.profileSyncRepository`
   (senior order: profile, auth, sync); replace stub with the real
   `_syncSavedGameResult` (senior extension logic, inline in the VM —
   learner has no bridge/part structure); update class doc.
5. `lib/screens/game_screen.dart` — `create:` passes both repos.
6. Call-site updates — every `GameScreenViewModel(` creation
   (`test/game_screen_view_model_test.dart` ×~5,
   `test/widgets/game_screen_test.dart` `pumpGameScreen`) gains the two
   fakes; `pumpGameScreen` accepts optional `authRepo`/`syncRepo`
   params for the new sync tests.
7. New tests —
   `test/user_profile_sync_merge_test.dart` (7 senior tests, verbatim
   semantics; note `AiMillionaire` → learner package imports) +
   `test/user_profile_sync_schema_test.dart` (2 senior tests) +
   VM-level result-sync tests (authenticated session → result save →
   `syncCallCount==1` + `lastSyncedSession.uid`; guest → 0).
8. Update stale M24-seam comments that now claim sync is always disabled
   (`app_dependency_scope.dart`, coordinator doc, game-VM doc, debug
   print `skipped; auth/sync → M25` → senior `skipped; session=guest`).

## Non-goals / constraints

- No DRE (`dre_async_op`) — M26. No `MenuDialogLayer`/in-Stack menu
  dialogs — M29. No visual parity — M28. No leaderboard UI changes
  (already consumes `auth_uuid`-keyed view; sync only writes `users`).
- Keep `Disabled` path working when unauthenticated-unconfigured
  (widget tests already cover guest flows).
- `LIVE_PROFILE_SYNC`: record `NOT_PERFORMED` if no credentials —
  merge/schema/call-path tests must carry the verification weight.
- Do not weaken any existing test; add `addTearDown`/`dispose` for new
  fake instances where the pattern requires.
- `UserProfileData` field `gamesWon`: remote has no column → merge keeps
  local (senior does this — `gamesWon: normalizedLocalProfile.gamesWon`).
