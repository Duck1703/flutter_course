# M25 — Implementation (Flux evidence)

## Result

`flutter test`: **224 → 236** (+12) · `flutter analyze`: clean ·
`flutter build web`: PASS · SQL `01` + `02`: byte-identical to senior.

## Files

### New

| File | Content |
|------|---------|
| `lib/data/profile/app_user_data.dart` | `AppUserData` (8 fields; `fromMap`/`fromProfile`/`toUpsertMap`/`toProfile` + defensive `_stringValue`/`_nullableStringValue`/`_intValue`) + `mergeUserProfileForSync` + `_higherLevelProgressionProfile`/`_maxInt`/`_nonEmpty`/`_withoutDemoProgression`/`_hasDemoProgression` — senior-verbatim port |
| `test/user_profile_sync_merge_test.dart` | 7 senior merge tests (leader progression / max-totals / session-identity / zero-starter / demo-normalize) |
| `test/user_profile_sync_schema_test.dart` | 2 senior schema tests (`toUpsertMap` column parity, `fromMap` no-email) |
| `supabase/student-setup/02-verify-database.sql` | ported byte-identical (users-table verification script; `01` was already identical from M23 — re-verified) |

### Modified

| File | Change |
|------|--------|
| `lib/repositories/profile/user_profile_sync_repository.dart` | prepended `UserProfileSyncRepositoryImpl` (senior-verbatim: `_isSyncing` guard, `ProfileSyncInProgress`→fetch→merge→local save→`upsert(onConflict:'auth_uuid')`→`ProfileSyncIdle`; catch→`ProfileSyncFailed`+rethrow; `_emit` isClosed+dedupe guard); Disabled kept + comment updated |
| `lib/main.dart` | conditional sync DI: `supabaseClient == null ? Disabled : Impl(client, userProfileRepository)` — same pattern as auth/leaderboard |
| `lib/view_models/game/game_screen_view_model.dart` | ctor gains `required authRepository` + `required profileSyncRepository` (senior order: profile→auth→sync); `_syncSavedGameResult` stub → real senior logic (`loadAuthState` → authenticated → `syncUserProfile` + started/completed logs; guest → `skipped; session=guest`; catch → `failed: $error` swallowed) |
| `lib/screens/game_screen.dart` | `create:` passes `context.read<AuthRepository>()` + `context.read<UserProfileSyncRepository>()` (+2 imports) |
| `lib/core/app_dependency_scope.dart` | comment: disabled/no-op is now conditional, not "LUÔN" |
| `lib/view_models/menu/menu_auth_action_coordinator.dart` | doc comment: contract-based, impl chosen in `main()` |
| `lib/data/profile/profile_sync_state_data.dart` | doc comment: states now emitted for real (M25) |
| `test/game_screen_view_model_test.dart` | +`authRepo`/`syncRepo` params on `startedVm`, 5 VM-create sites gain the two fakes, imports, new `result profile sync (M25, FR-36)` group (3 tests: authed→sync called w/ uid; guest→skip; syncError→swallowed + local save intact) |
| `test/widgets/game_screen_test.dart` | `pumpGameScreen` gains `authRepo`/`syncRepo` + ctor args |

## Senior-parity decisions

- `gamesWon` kept local-only (no `users` column) — senior merge line
  `gamesWon: normalizedLocalProfile.gamesWon` ported verbatim.
- `_hasDemoProgression`/`_withoutDemoProgression` ported even though
  the learner never shipped the demo seed — defensive parity, and the
  learner already knows the `'TÀU HỦ ĐI CHILL'` legacy username
  (`user_profile_data.dart` `_legacyDemoUsername`).
- Sync errors in the game VM are caught + logged (not surfaced) —
  local save is the source of truth; next sign-in syncs again.
- `LIVE_PROFILE_SYNC`: `NOT_PERFORMED` — no Supabase credentials in
  this environment; merge/schema/call-path/fake-repo coverage carries
  verification weight per brief.

## Deferred / untouched

- No DRE (M26), no `MenuDialogLayer` (M29), no visual parity (M28),
  no leaderboard changes (view already keys `auth_uuid`).
- `MenuAuthActionCoordinator`/`MenuAuthDialogViewModel` call-sites
  already invoked `syncUserProfile` — verified correct, not rewired.
