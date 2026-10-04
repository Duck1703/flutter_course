# M23 IMPLEMENTATION NOTES — Supabase bootstrap & leaderboard

## What changed (learner `learner-app/`)

### New files
- `lib/core/supabase_environment.dart` — senior verbatim: 4
  `String.fromEnvironment` dart-defines (`SUPABASE_URL`,
  `SUPABASE_PUBLISHABLE_KEY`, `GOOGLE_WEB_CLIENT_ID`,
  `GOOGLE_IOS_CLIENT_ID`), `isSupabaseConfigured`,
  `isGoogleConfigured` (M24), `configurationError`.
- `lib/services/supabase_client_service.dart` — senior verbatim:
  `initialize(env)` → `SupabaseClient?`; null when unconfigured.
  (No `SupabaseNotConfigured` type exists in senior — the nullable
  client IS the sentinel.)
- `lib/data/leaderboard/leaderboard_entry_data.dart` —
  `LeaderboardEntryData{rank,name,level,score,avatarUrl?,
  isCurrentUser}` (learner field set — `avatarAsset`/`rankAsset`/
  `style` deferred to M28 asset pipeline); sealed
  `LeaderboardPopupState` verbatim: `Success{entries,currentEntry,
  isRefreshing}`/`Empty`/`Error`/`Loading` + `LeaderboardPopupMessage`;
  static `leaderboardEntries`/`currentLeaderboardEntry` fallback data.
- `lib/repositories/leaderboard/leaderboard_repository_contract.dart` —
  `loadLeaderboard({String? currentUserId}) → Future<LeaderboardSnapshot>`.
- `lib/repositories/leaderboard/leaderboard_repository.dart` —
  `LeaderboardSnapshot{entries,currentEntry}`;
  `SupabaseLeaderboardRepository` verbatim query chain
  (`from('leaderboard').select('rank,name,avatar_url,level,
  total_money_won').order('total_money_won',ascending:false)
  .order('rank').limit(10)` + `.eq('auth_uuid',uid).maybeSingle()`);
  `@visibleForTesting static entryFromRow` mapping seam;
  `DisabledLeaderboardRepository` static fallback.
- `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart` —
  `_requestId` stale-response guard, `loadLeaderboard({isRefresh})`,
  `refresh()`, `retry()`, `_profileBackedCurrentLeaderboardEntry`.
  **FR-35 guest seam**: ctor omits `AuthRepository`;
  `_currentLeaderboardUserId()` ≡ `null` — converges M24.
- `lib/widgets/leaderboard/` — `leaderboard_popup_body` (state switch +
  retry), `leaderboard_list` (`RefreshIndicator.adaptive`), `leaderboard_row`.
- `lib/widgets/menu/leaderboard/` — `menu_leaderboard_dialog` (MenuTokens
  chrome, states→body) + `menu_leaderboard_dialog_scope`
  (`ChangeNotifierProvider` scoped VM + post-frame load).
- `supabase/student-setup/01-setup-database.sql` — senior verbatim
  (byte-identical): `public.users` + owner RLS + `public.leaderboard`
  `security_barrier` view + sort index + cron heartbeat.
- Tests: `test/core/supabase_environment_test.dart` (3),
  `test/helpers/fake_leaderboard_repository.dart`,
  `test/repositories/leaderboard_repository_test.dart` (4),
  `test/view_models/leaderboard/leaderboard_dialog_view_model_test.dart`
  (9, incl. 2-Completer stale-race), `test/widgets/
  menu_leaderboard_dialog_test.dart` (8, incl. FR-14 tap→dialog).

### Rewritten
- `lib/main.dart` — env → `SupabaseClientService.initialize` →
  `supabaseClient == null ? DisabledLeaderboardRepository :
  SupabaseLeaderboardRepository(client:)` → scope entry.
- `lib/core/app_dependency_scope.dart` — +`Provider<LeaderboardRepository>.value`.
- `lib/view_models/menu/menu_view_model.dart` — +`requestLeaderboardDialog()`
  (senior name) emitting `MenuLeaderboardRequested`.
- `lib/view_models/menu/menu_screen_ui_event.dart` — +`MenuLeaderboardRequested`.
- `lib/screens/menu_screen.dart` — `_LeaderboardEntry` tappable
  (`Semantics(button)+GestureDetector`, key `menu-leaderboard-entry`);
  event bridge + `showLeaderboardDialog` (event+`showDialog` transport —
  FR-29 → M29).
- `lib/l10n/app_{en,vi}.arb` — +6 senior keys (`leaderboardEmptyMessage`,
  `leaderboardLoadErrorMessage`, `leaderboardLoadingMessage`,
  `retryButton`, `rankSemanticLabel` ICU, `leaderboardSemanticLabel`).
- `pubspec.yaml` — +`supabase_flutter: 2.14.2` (senior exact pin).

### Deliberate divergences (registered)
- FR-35: VM guest seam (no AuthRepository) → M24.
- LeaderboardEntryData omits asset/style fields; dialog chrome is
  MenuTokens (no SVG frame painter/rank badges/avatars) → M28.
- Dialog transport is event+`showDialog`, not `MenuDialogLeaderboard`
  state → M29.

## Senior source

`main@c8eb860` — files listed in `AI_HANDOFF/work/milestones/M23/01-brief.md`
SENIOR FIDELITY CHECK table.

## Fidelity rows

FR-14 CONVERGED (row tappable + real data + dialog). FR-35 opened
(guest seam → M24). FR-29 transport note updated (leaderboard joins
settings under showDialog scaffold).

## Verification

```
flutter analyze   → No issues found!
flutter test      → 193/193 (168 baseline + 25)
flutter build web → PASS
website build     → 126 pages
LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED (no credentials — never a gate)
```
