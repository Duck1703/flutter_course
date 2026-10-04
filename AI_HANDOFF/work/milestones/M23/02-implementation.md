# M23 IMPLEMENTATION — Supabase bootstrap + Leaderboard

Role: FLUX | Baseline: 168/168 tests · analyze clean | Senior ref: `flutter-accelerator-ai` @ `main` (read-only, unchanged)

Result: **193/193 tests pass** (+25 net new) · `flutter analyze` clean · `flutter build web` PASS · `LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED` (no credentials in env — per brief, never a gate).

---

## 1. NEW FILES (allow-list)

| File | LOC | Port basis / notes |
|---|---|---|
| `lib/core/supabase_environment.dart` | 73 | **Verbatim** senior — all 4 dart-define keys (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID`), `isSupabaseConfigured`, `isGoogleConfigured`, `configurationError`. Google pair documented as M24. Comments in Vietnamese. |
| `lib/services/supabase_client_service.dart` | 30 | **Verbatim** senior `SupabaseClientService.initialize(env) → SupabaseClient?`. |
| `lib/data/leaderboard/leaderboard_entry_data.dart` | 132 | Learner-shape `LeaderboardEntryData{rank,name,level,score,avatarUrl?,isCurrentUser}` (no `avatarAsset`/`rankAsset`/`style` — M28); `LeaderboardPopupState` sealed 4 variants + `LeaderboardPopupMessage` **verbatim**; static `leaderboardEntries` (6 rows) + `currentLeaderboardEntry` (rank 125) keep senior names/scores. |
| `lib/repositories/leaderboard/leaderboard_repository_contract.dart` | 23 | **Verbatim**: `LeaderboardRepository.loadLeaderboard({String? currentUserId})`, `LeaderboardSnapshot{entries,currentEntry}`. |
| `lib/repositories/leaderboard/leaderboard_repository.dart` | 161 | `SupabaseLeaderboardRepository` — senior query chain verbatim: `.from('leaderboard').select('rank,name,avatar_url,level,total_money_won').order('total_money_won',ascending:false).order('rank').limit(10)` + `.eq('auth_uuid',uid).maybeSingle()`; `_LeaderboardRecord` private mapper (parse phòng thủ `_stringValue`/`_intValue`, `_formatScore` strips ' VNĐ' via `UserProfileData.formatVnd`); `DisabledLeaderboardRepository` → static snapshot. Mapper emits learner entry shape. Added `@visibleForTesting static entryFromRow(row,{isCurrentUser})` seam for deterministic mapper tests (no `SupabaseClient` in tests). |
| `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart` | 173 | Senior VM verbatim minus `AuthRepository`: `_requestId` stale guard, `loadLeaderboard({isRefresh})`, `refresh()`, `retry()`, `_profileBackedCurrentLeaderboardEntry`/`_currentUserLeaderboardEntry` profile-backed fallback. Ctor `(leaderboardRepository, userProfileRepository)`. `_currentLeaderboardUserId()` returns `null` — marked: "M24: inject AuthRepository, restore senior switch(authState) → uid". |
| `lib/widgets/menu/leaderboard/menu_leaderboard_dialog.dart` | 57 | `MenuLeaderboardDialog{state,onRefresh,onRetry}` — learner chrome: `AlertDialog` + `MenuTokens` (settings-dialog style), title `leaderboardTitle.toUpperCase()`, content 380px hosting `LeaderboardPopupBody`. No frame painter/SVG (M28). Key `leaderboard-dialog-shell` kept for parity. |
| `lib/widgets/menu/leaderboard/menu_leaderboard_dialog_scope.dart` | 111 | `showLeaderboardDialog(context)` (reads both repos from context → `showDialog`) + `MenuLeaderboardDialogScope` (`ChangeNotifierProvider<LeaderboardDialogViewModel>`) + `_LeaderboardDialogBridge` (senior verbatim pattern: didChangeDependencies attach + `_didLoadLeaderboard` flag + post-frame `loadLeaderboard()`). |
| `lib/widgets/leaderboard/leaderboard_popup_body.dart` | 181 | Senior `LeaderboardPopupBody` state-switch ported to `MenuTokens`: Success→`LeaderboardList`, Empty→message, Error→`Icons.cloud_off`+message+`leaderboard-retry-button` `TextButton.icon` (`l10n.retryButton`), Loading→`leaderboard-loading-progress` spinner+message. |
| `lib/widgets/leaderboard/leaderboard_list.dart` | 97 | Senior semantics: scrollable top rows in `RefreshIndicator.adaptive` (`leaderboard-scrollable-top-rows` key, `AlwaysScrollableScrollPhysics` when refresh non-null) + pinned current row (`leaderboard-current-user-row`) + `leaderboard-refresh-progress` LinearProgressIndicator. Learner uses `Column`+`Expanded` instead of senior Stack+mask (no frame assets yet). |
| `lib/widgets/leaderboard/leaderboard_row.dart` | 104 | Learner row: rank badge as `#N` text inside `Semantics(label: rankSemanticLabel, image, excludeSemantics)` (senior puts label on SVG badge leaf — same technique so label stays exact), name, `profileLevel(level)` text, score. `isCurrentUser` → `statGreen` accent border/tint via `MenuTokens`. |
| `supabase/student-setup/01-setup-database.sql` | 181 | **Verbatim byte-identical copy** (verified `diff -q` → IDENTICAL). `public.users` + RLS owner policies + `public.leaderboard` `security_barrier` view + sort index + cron heartbeat. Grants `anon`/`authenticated` only; no secrets. |
| `test/helpers/fake_leaderboard_repository.dart` | 47 | **Verbatim** senior fake: `snapshot`/`error`/`completers` scriptable, `loadCallCount`, `lastCurrentUserId`. |
| `test/view_models/leaderboard/leaderboard_dialog_view_model_test.dart` | 281 | 9 tests (see §4). Merges senior `_test` + `_async_test`; auth cases replaced by guest-seam assertions. |
| `test/widgets/menu_leaderboard_dialog_test.dart` | 259 | 8 tests — 4 state branches, retry wiring, RefreshIndicator, scope auto-load (post-frame), error+retry via scope, menu-row tap opens dialog. |
| `test/repositories/leaderboard_repository_test.dart` | 72 | 4 tests — disabled repo static data (×2) + mapper seam row→entry (full row + defensive fallbacks). |
| `test/core/supabase_environment_test.dart` | 56 | 3 tests — ctor + `isSupabaseConfigured`/`isGoogleConfigured`/`configurationError` predicates (compile-time `fromEnvironment` untestable per plan). |

## 2. EDITED FILES

| File | Change |
|---|---|
| `pubspec.yaml` | `+ supabase_flutter: 2.14.2` (senior pubspec line 47 exact pin). Resolved cleanly — `supabase_flutter 2.14.2`, `supabase 2.12.2`, +46 transitive deps. |
| `lib/main.dart` | env → `SupabaseClientService.initialize` (conditional, returns null unconfigured) → `supabaseClient == null ? DisabledLeaderboardRepository() : SupabaseLeaderboardRepository(client:)` → new `leaderboardRepository` arg to `AppDependencyScope`. `[supabase] config …` debugPrint mirrors senior `[auth]` prints (auth doesn't exist yet). |
| `lib/core/app_dependency_scope.dart` | +`leaderboardRepository` field/ctor param + `Provider<LeaderboardRepository>.value` entry; doc comment updated (4 repos). |
| `lib/screens/menu_screen.dart` | `import` scope file; `_handleUiEvent` +`case MenuLeaderboardRequested(): unawaited(_openLeaderboard())`; `_openLeaderboard()` → `showLeaderboardDialog(context)`; `_LeaderboardEntry` → `Semantics(button,label: leaderboardSemanticLabel)` + `GestureDetector(key:'menu-leaderboard-entry', onTap: context.read<MenuViewModel>().requestLeaderboardDialog())`; FR-14 doc comment updated to CONVERGED (transport FR-29 → M29 noted). |
| `lib/view_models/menu/menu_view_model.dart` | +`requestLeaderboardDialog()` (senior method name) emitting `MenuLeaderboardRequested`. |
| `lib/view_models/menu/menu_screen_ui_event.dart` | +`final class MenuLeaderboardRequested`. |
| `lib/l10n/app_en.arb` / `app_vi.arb` | +`leaderboardSemanticLabel`, `leaderboardEmptyMessage`, `leaderboardLoadErrorMessage`, `leaderboardLoadingMessage`, `retryButton`, `rankSemanticLabel` (+`@rankSemanticLabel` ICU int placeholder) — senior values verbatim. Level text reuses existing `profileLevel`. |
| `lib/l10n/app_localizations*.dart` | Regenerated via `flutter gen-l10n` (checked-in output dir `lib/l10n`). |
| `test/sealed_state_test.dart` | exhaustive switch +`MenuLeaderboardRequested` case (compile requirement). |
| `test/menu_view_model_test.dart` | +`requestLeaderboardDialog → MenuLeaderboardRequested` event test. |
| `test/menu_screen_ui_events_test.dart`, `test/menu_provider_scope_test.dart`, `test/widgets/game_screen_test.dart` | `AppDependencyScope` call sites +`leaderboardRepository: const DisabledLeaderboardRepository()`. |

## 3. SENIOR → LEARNER SYMBOL MAPPING

| Senior symbol | Learner M23 | Status |
|---|---|---|
| `SupabaseEnvironment` (all members) | same | verbatim |
| `SupabaseClientService.initialize` | same | verbatim |
| `SupabaseNotConfigured` sentinel | n/a — **see divergence D1** | — |
| `LeaderboardRepository.loadLeaderboard` | same | verbatim |
| `LeaderboardSnapshot` | same | verbatim |
| `SupabaseLeaderboardRepository` query chain | same + `entryFromRow` @visibleForTesting seam | verbatim + seam |
| `DisabledLeaderboardRepository` | same | verbatim |
| `LeaderboardEntryData` | minus `avatarAsset`/`rankAsset`/`style` | fields → M28 |
| `LeaderboardPopupState`/`Message` (4 variants) | same | verbatim |
| `LeaderboardDialogViewModel` | ctor −`AuthRepository`; `_currentLeaderboardUserId()→null` | seam → M24 |
| `MenuLeaderboardDialogScope`/bridge | same shape, repos passed in (settings-style) | transport FR-29 → M29 |
| `MenuLeaderboardDialog` + `LeaderboardPopupBody`/`List`/`Row`/`Avatar` | `MenuTokens` chrome; no painter/SVG/avatar | visuals → M28 |
| `requestLeaderboardDialog()` | same method name; emits event not dialog-state | body → M29 |
| `LeaderboardEntryCard(onTap)` | merged into `_LeaderboardEntry` (menu_screen.dart) + tap wiring | FR-14 closed |
| `main.dart` DI section | env→init→conditional repo→scope | verbatim pattern |

## 4. TEST DELTA — 168 → 193 (+25)

New test cases:
- VM (9): initial Loading; success w/ entries+currentEntry + `lastCurrentUserId==null` guest seam; empty→`LeaderboardPopupEmpty`; throw→`LeaderboardPopupError(loadError)`; refresh keeps entries + `isRefreshing:true` then `false`; **stale-request** (completer-controlled slow-first resolves after second → second wins); `retry()` reloads; guest profile-backed current entry (name/level/score/avatar from `FakeUserProfileRepository`); remote currentEntry + profile avatar priority.
- Widget dialog (8): success rows + pinned current row + `Hạng 125` semantics + `CẤP 12` level; empty; error+retry counter; loading; `RefreshIndicator.onRefresh` + `isRefreshing` progress; scope auto-load from fake repo; scope error→retry→2nd load; **menu row tap → event → showDialog with repo data**.
- Repo (4): disabled static snapshot ×2; mapper seam full-row + defensive fallbacks.
- Env (3): unconfigured/configured predicates + `configurationError` ordering; Google pair.
- Menu VM (1): `requestLeaderboardDialog` → `MenuLeaderboardRequested`.
- (sealed_state_test edited in place — not a new test count.)

## 5. COMMAND EVIDENCE

```
flutter pub get    → OK; "supabase_flutter 2.14.2", "supabase 2.12.2", Changed 48 deps
flutter gen-l10n   → OK (l10n.yaml used; getters verified in app_localizations.dart)
flutter analyze    → "No issues found!" (4.2s / 1.9s)
flutter test       → "+193: All tests passed!" (baseline 168 → 193)
flutter build web  → "√ Built build\web" (56.6s; Wasm dry-run note + cupertino_icons
                     font notice are pre-existing platform messages, non-fatal)
diff -q senior/learner 01-setup-database.sql → IDENTICAL
Credential grep (sbp_|eyJ|service.?role|password|secret|api_key|.env)
                   → clean; only doc-comment prose mentions; no .env files
```

## 6. DELIBERATE DIVERGENCES (per brief)

- **D1 — `SupabaseNotConfigured` sentinel**: brief said "port verbatim incl. `SupabaseNotConfigured` sentinel pattern". Senior source @ main has **no such symbol** (verified by repo-wide grep: 0 matches). The senior sentinel pattern is the `SupabaseClient?` null return → conditional `Disabled…` impl. Ported verbatim; documented here. No `SupabaseNotConfigured` class invented.
- **D2 — `leaderboardSemanticLabel`**: brief claimed learner ARB already had it; it did not (only `leaderboardTitle`/`leaderboardSubtitle`). Added verbatim senior values (en "Leaderboard" / vi "Bảng xếp hạng") — needed by the row `Semantics(button)` parity.
- **D3 — level label**: senior `LeaderboardRow` shows name+score only; brief requires learner rows to show level text. Reused existing `profileLevel` ("LEVEL {n}"/"CẤP {n}") — no new key needed.
- **D4 — seam `entryFromRow`**: `@visibleForTesting static` on `SupabaseLeaderboardRepository` exposing `_LeaderboardRecord.fromMap(...).toEntry(...)` — mandated by test plan (no `SupabaseClient` in tests).
- **D5 — learner entry shape**: no `avatarAsset`/`rankAsset`/`style`; `avatarUrl` kept (remote data, not asset).
- **D6 — guest seam**: `_currentLeaderboardUserId()` ≡ `null` with M24 code comment; ctor lacks `AuthRepository`.
- **D7 — transport**: `MenuLeaderboardRequested` event + `showDialog` (FR-29 → M29), not `MenuDialogState`/`MenuDialogLayer`.
- **D8 — chrome**: `AlertDialog`/`MenuTokens`; `Icons.emoji_events`-class icons; `#N` rank text; no SVG/painters/avatars.
- **D9 — debugPrint tag**: learner prints `[supabase] config …` (senior prints `[auth]` twice — auth lines n/a until M24).
- **D10 — file count**: repo+env tests live in `test/repositories/leaderboard_repository_test.dart` + `test/core/supabase_environment_test.dart` (allow-list marked test files non-exhaustively; these satisfy the TEST PLAN repo/env items).

## 7. NOT VERIFIED / KNOWN LIMITS

- `LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED` — no Supabase credentials in this environment; configured run is an optional env-dependent checkpoint only (brief §Remote-service assumptions).
- `SupabaseEnvironment.fromEnvironment()` compile-time reads can't be exercised in tests (dart-define) — ctor+predicates tested per plan.
- `SupabaseLeaderboardRepository.loadLeaderboard` network path not executed (no client construction in tests) — query chain is senior-verbatim source; mapper covered via `entryFromRow`.
- `flutter build web` on Windows emitted two benign notices (Wasm dry-run suggestion; cupertino_icons font subsetting note) — build succeeded; recorded verbatim above.
- Senior repo: read-only throughout; zero writes to `flutter-accelerator-ai`.
