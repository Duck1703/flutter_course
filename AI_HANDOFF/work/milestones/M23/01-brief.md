# M23 BRIEF — Supabase bootstrap & first remote read (leaderboard)

Role: Atlas | Step: 18 | Baseline: 168/168 · analyze clean · web+site PASS · senior `main@c8eb860`

Roadmap M23, verbatim intent: configure Supabase through dart-defines,
initialize the client conditionally, implement `LeaderboardRepository`
(disabled-static first, Supabase second), read `public.leaderboard`
into loading/empty/error/success UI, make the menu leaderboard row
tappable, `refresh()` + stale-response guard.

---

## SENIOR FIDELITY CHECK

### Senior target (verified by direct source inspection @ `main@c8eb860`)

| Senior file | Key symbols | Role |
|---|---|---|
| `lib/core/supabase_environment.dart` | `SupabaseEnvironment.fromEnvironment()`, `supabaseUrl`, `supabasePublishableKey`, `googleWebClientId`, `googleIosClientId`, `isSupabaseConfigured`, `isGoogleConfigured`, `configurationError` | compile-time config via `String.fromEnvironment` |
| `lib/services/supabase_client_service.dart` | `SupabaseClientService.initialize(env)` → `SupabaseClient?`, `SupabaseNotConfigured` sentinel | conditional `Supabase.initialize` |
| `lib/repositories/leaderboard/leaderboard_repository_contract.dart` | `LeaderboardRepository.loadLeaderboard({String? currentUserId}) → Future<LeaderboardSnapshot>` | contract |
| `lib/repositories/leaderboard/leaderboard_repository.dart` | `LeaderboardSnapshot{entries,currentEntry}`, `SupabaseLeaderboardRepository` (`.from('leaderboard').select('rank,name,avatar_url,level,total_money_won').order('total_money_won',ascending:false).order('rank').limit(10)`; current row `.eq('auth_uuid',uid).maybeSingle()`), `DisabledLeaderboardRepository` | remote + static impls |
| `lib/data/leaderboard/leaderboard_entry_data.dart` | `LeaderboardEntryData` (rank/name/level/score/avatarAsset/avatarUrl/rankAsset/style/isCurrentUser), `LeaderboardPopupState` sealed: `Success{entries,currentEntry,isRefreshing}`/`Empty`/`Error`/`Loading` + `LeaderboardPopupMessage`, static `leaderboardEntries`/`currentLeaderboardEntry` | model + states + fallback data |
| `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart` | `LeaderboardDialogViewModel` — `_requestId` stale guard, `loadLeaderboard({isRefresh})`, `refresh()`, `retry()`, `_profileBackedCurrentLeaderboardEntry` (null remote → local-profile entry) | VM |
| `lib/view_models/menu/menu_dialog_state.dart` + `menu_screen_view_model.dart` | `MenuDialogLeaderboard`, `requestLeaderboardDialog()` | menu wiring |
| `lib/widgets/menu/leaderboard/` | `MenuLeaderboardDialogScope` (provider-scoped VM + post-frame `loadLeaderboard`), `MenuLeaderboardDialog`, `LeaderboardEntryCard(onTap)` | dialog + entry card |
| `lib/widgets/leaderboard/` | `LeaderboardPopupBody` (state switch + retry button `l10n.retryButton`), `LeaderboardList` (`RefreshIndicator.adaptive`), `LeaderboardRow`, `LeaderboardAvatar` | popup UI |
| `lib/main.dart` | env → `SupabaseClientService.initialize` → `supabaseClient==null ? Disabled… : Supabase…` → `AppDependencyScope` | DI bootstrap |
| `supabase/student-setup/01-setup-database.sql` | `public.users` + RLS owner policies + `public.leaderboard` `security_barrier` view (`row_number()` rank; `auth_uuid` visible only on caller row) + sort index + cron heartbeat | schema evidence |
| `test/view_models/leaderboard/`, `test/helpers/fake_leaderboard_repository.dart` | fake repo + harness + stale-request async test | test convention |

### Current learner form

- `_LeaderboardEntry` in `menu_screen.dart` — static, non-tappable (FR-14).
- Menu dialog transport: one-off `MenuScreenUiEvent` → `showDialog`
  (settings pattern, FR-29 → M29). No `MenuDialogLayer` — that is M29.
- No `supabase_flutter` dep, no `lib/services/`, no leaderboard files,
  no `AuthRepository` (M24).
- DI: `AppDependencyScope` MultiProvider, `Provider<CONTRACT>.value`.
- ARB: `leaderboardTitle`, `leaderboardSubtitle`,
  `leaderboardSemanticLabel`, `settingsGuestSyncHint` already exist.

### Senior target form → learner M23 form

| Element | Learner M23 | Convergence |
|---|---|---|
| `SupabaseEnvironment` | port verbatim (all 4 keys; Google pair documented as M24) | final |
| `SupabaseClientService` | port verbatim incl. `SupabaseNotConfigured` | final |
| `main()` bootstrap | env → conditional init → conditional repo construction → scope gains `LeaderboardRepository` entry | final |
| Repository contract + `LeaderboardSnapshot` | verbatim | final |
| `SupabaseLeaderboardRepository` | same query chain; mapping emits learner entry shape (no asset fields) | final semantics; fields M28 |
| `DisabledLeaderboardRepository` | static fallback, learner entry shape | final semantics |
| `LeaderboardEntryData` | `{rank,name,level,score,isCurrentUser}` — no `avatarAsset`/`avatarUrl`/`rankAsset`/`style` (asset pipeline + row chrome = M28); `avatarUrl` KEPT — it is remote data, not an asset | fields complete at M28 |
| `LeaderboardPopupState` family + `LeaderboardPopupMessage` | verbatim 4 variants incl. `Success.isRefreshing` | final |
| `LeaderboardDialogViewModel` | ctor `(leaderboardRepository, userProfileRepository)` — NO `AuthRepository` (M24); `_currentLeaderboardUserId()` returns `null` (guest seam, documented); `_requestId` guard + `refresh`/`retry` + profile-backed fallback verbatim | ctor gains `AuthRepository` at M24 |
| Menu wiring | `MenuViewModel.requestLeaderboardDialog()` (senior name) emits `MenuLeaderboardRequested` event → bridge `showDialog` — SAME transport as settings (FR-29) | method body swaps to `MenuDialogLeaderboard` state at M29 |
| Dialog UI | `MenuLeaderboardDialog` + scope widget — learner chrome (`MenuTokens` card + dialog pattern à la settings), state-driven body: loading spinner / empty msg / error msg + retry / success list + current-user row + `RefreshIndicator`; NO frame painters/SVG/avatar assets | visual parity M28 |
| `supabase/student-setup/01-setup-database.sql` | copied verbatim to learner repo (no secrets; it is instructional schema) | final |
| ARB | add `leaderboardEmptyMessage`, `leaderboardLoadErrorMessage`, `leaderboardLoadingMessage`, `retryButton`, `rankSemanticLabel`, `leaderboardLevelLabel`/`levelShort` as needed (senior values verbatim) | final |

### Register entries owned

- **FR-14** (leaderboard row static/non-tappable → tappable + real
  dialog + remote-capable data path): **CLOSES at M23** — the row
  becomes tappable and the dialog renders real repository data.
  The *visual* parity of rows stays under the M28 umbrella.
- **New row (FR-next)**: `LeaderboardDialogViewModel` guest seam —
  ctor lacks `AuthRepository`; `_currentLeaderboardUserId()` ≡ null.
  Converges **M24** when auth repo is injected and the senior
  `switch(authState)` returns.
- FR-29 (menu dialog transport `showDialog`→layer): remains ACTIVE →
  M29; leaderboard dialog joins settings under the same scaffold.
- FR-28 (account row/auth identity): ACTIVE → M24.
- FR-30 (icon pipeline `IconData`): remains ACTIVE; leaderboard uses
  `Icons.emoji_events`/`Icons.military_tech`-class icons, not senior
  SVG rank assets → M28.

### Permitted simplifications

- Learner `LeaderboardEntryData` omits `avatarAsset`/`rankAsset`/`style`
  (asset pipeline does not exist → M28). `avatarUrl` kept.
- Dialog chrome = learner `MenuTokens` card style; no SVG frame painter,
  no rank-badge images, no avatar images.
- Rank/level rendered as text (`rankSemanticLabel` + level label), not
  badge images.
- Retry = `FilledButton`-class learner button with `l10n.retryButton`;
  refresh = `RefreshIndicator.adaptive` on the list (senior parity).

### Forbidden alternatives

- NO auth repository / session model / sign-in UI (M24).
- NO `public.users` writes, upsert, or sync (M25).
- NO `MenuDialogLayer`/`MenuDialogLeaderboard` state (M29) — use the
  existing event+`showDialog` transport.
- NO `DreChangeNotifier`/`asyncOp`/DRE cancellation (M26).
- NO realtime subscriptions.
- NO `.env` file or committed config values; dart-define names only.
- NO error taxonomy beyond catch→`LeaderboardPopupError` (senior parity).
- NO mock package — handwritten fakes per repo convention.

### Remote-service assumptions

- No Supabase credentials exist in this environment →
  `LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED` (authoritative).
- All PASS criteria must be met by deterministic fakes + unconfigured
  runtime (`DisabledLeaderboardRepository`). A configured run is an
  OPTIONAL environment-dependent checkpoint, never a gate.
- `supabase_flutter: 2.14.2` — senior's exact pin; published well over
  7 days ago; required because `Supabase.initialize` + `SupabaseClient`
  types are senior-verbatim API.

---

## LEARNING DESIGN CHECK

### New Dart concepts
- `String.fromEnvironment` — compile-time constants injected via
  `--dart-define`; `isEmpty` config check.
- `maybeSingle()` — 0-or-1 row query result (`null` on absent).
- Mapping `Map<String,dynamic>` JSON rows → typed `LeaderboardEntryData`.
- `_requestId` monotonic guard — discard responses that arrive after a
  newer request started.

### New Flutter concepts
- `supabase_flutter`: `Supabase.initialize` + `SupabaseClient`.
- Conditional DI: `client == null ? Disabled… : Supabase…` in `main()`.
- `RefreshIndicator.adaptive` for pull-to-refresh on a remote list.

### New architecture concepts
- Remote repository implementation behind an existing M14 contract —
  UI dependency unchanged; only the impl source changes.
- Disabled/fallback implementation selected by configuration, not by
  UI branching.
- Dialog-scoped ViewModel created by `ChangeNotifierProvider` inside
  the dialog subtree + post-frame initial load.

### New Supabase/backend concepts
- What Supabase provides THIS app: hosted Postgres + auto Data API +
  auth (auth arrives M24).
- `public.leaderboard` is a *view*, not a table — reads ranked public
  fields while `public.users` stays owner-only under RLS.
- Anon/publishable key ≠ service-role secret; client code is public,
  authorization lives in RLS, never in hidden client code.
- `select/order/limit/eq/maybeSingle` query semantics at beginner depth.

### Prerequisites (verify closed)
- M14 repository contracts + `Provider<CONTRACT>` DI + fakes.
- M15 sealed state variants; M16 dialog surfaces + event transport.
- M19 `AppNavigationController`; M22 profile stream + `UserProfileData`
  (profile-backed current entry).

### Registry entries (to add)
- `String.fromEnvironment` / dart-define (Dart, guided).
- Remote repository impl behind contract (architecture, guided).
- Conditional DI by config (architecture, guided).
- `maybeSingle` + row mapping (Dart/backend, guided).
- Stale-response guard `_requestId` (Dart, applied).
- `RefreshIndicator` (Flutter, applied).
- RLS/anon-key security boundary (backend, awareness).
- View-vs-table read model (backend, awareness).

### Mental models
- "The contract doesn't know where data lives" — same `loadLeaderboard`
  call, three impls (fake/disabled/Supabase).
- "Config is plumbing, not state" — env values are compile-time;
  missing config → disabled impl, never a crash.
- "Old answers must not win" — `_requestId` makes only the latest
  request allowed to write state.

### Isolated example (before production code)
Tiny `ScoreRepository` contract → `FakeScoreRepository` →
`RemoteScoreRepository` sketch: same contract, different source. Then
map onto leaderboard. Plus a 15-line `String.fromEnvironment` demo.

### Independent exercises
- PRODUCE: implement a fake remote repository returning scripted
  snapshots; write ordering expectations for a raw-row→entry mapper.
- DEBUG/PREDICT: planted bug removes the `_requestId` check (or maps
  rows ignoring `total_money_won` order) → learner predicts which
  visible behavior breaks / which test fails, then runs it.

### Concept reinforcement
- M14 contract/DI reused as the *reason* remote impl needs no UI change.
- M15 sealed states reused for the 4-variant popup state.
- M16 event→dialog transport reused for menu wiring.

### Cognitive-load assessment
Backend milestone = expensive. Split config→client→repo→VM→UI into
separate lessons; security boundary gets its own short lesson; the SQL
file is reference material walked selectively (view + one policy), not
line-by-line.

### Lesson split (planned 5)
1. Supabase in this app + dart-define configuration + security boundary.
2. Conditional client init + disabled-vs-remote DI in `main()`.
3. `LeaderboardRepository` contract, snapshot, disabled impl, Supabase
   impl (query chain + row mapping + `maybeSingle`).
4. `LeaderboardDialogViewModel`: 4 states, `isRefreshing`, `retry`,
   `_requestId` guard; guest-seam note for M24.
5. Dialog UI + menu row wiring (`requestLeaderboardDialog` → event →
   `showDialog` + scoped VM + post-frame load) + `RefreshIndicator` +
   manual run with/without dart-defines.

### Sequential checkpoint strategy
Each lesson ends with a runnable checkpoint: `flutter analyze` /
`flutter test test/…` / a focused widget test — all deterministic,
all credential-free. L05's manual configured run is OPTIONAL and
labelled environment-dependent.

### Remote-runtime dependency strategy
Mandatory PASS path = fakes + unconfigured fallback. Live Supabase is
NOT a gate: no credentials exist. Lessons must teach the configured
command form with placeholders (`--dart-define=SUPABASE_URL=<…>`) and
state plainly that values come from the learner's own project.

---

## IMPLEMENTATION SCOPE (allow-list)

NEW: `lib/core/supabase_environment.dart`,
`lib/services/supabase_client_service.dart`,
`lib/data/leaderboard/leaderboard_entry_data.dart`,
`lib/repositories/leaderboard/leaderboard_repository_contract.dart`,
`lib/repositories/leaderboard/leaderboard_repository.dart`,
`lib/view_models/leaderboard/leaderboard_dialog_view_model.dart`,
`lib/widgets/menu/leaderboard/menu_leaderboard_dialog.dart`,
`lib/widgets/menu/leaderboard/menu_leaderboard_dialog_scope.dart`
(+ `leaderboard_list`/row widgets if the dialog splits),
`supabase/student-setup/01-setup-database.sql` (verbatim copy),
`test/helpers/fake_leaderboard_repository.dart`,
`test/view_models/leaderboard/leaderboard_dialog_view_model_test.dart`,
`test/widgets/menu_leaderboard_dialog_test.dart`.

EDIT: `pubspec.yaml` (+`supabase_flutter: 2.14.2`), `lib/main.dart`,
`lib/core/app_dependency_scope.dart`, `lib/screens/menu_screen.dart`,
`lib/view_models/menu/menu_view_model.dart`,
`lib/view_models/menu/menu_screen_ui_event.dart`
(+`MenuLeaderboardRequested`), ARB en+vi (+5-6 keys), menu tests.

## TEST PLAN (deterministic only)

- VM: loading→success; empty→`LeaderboardPopupEmpty`; throw→Error;
  `refresh()` keeps old entries + `isRefreshing:true`; **stale guard** —
  slow first request resolves after second → first must not overwrite;
  `retry()` reloads; guest `currentUserId` null → profile-backed
  current entry built from `UserProfileRepository`.
- Widget: success renders rows + current-user row; loading/error/empty
  branches render correct strings; retry button calls `retry()`;
  `RefreshIndicator` triggers `refresh()`; tap on `_LeaderboardEntry`
  opens the dialog.
- Repo: `DisabledLeaderboardRepository` returns static data; mapper
  unit test row→entry via a test-visible mapping seam (no network —
  DO NOT construct a real `SupabaseClient` in tests).
- Env: `SupabaseEnvironment` parse/`isSupabaseConfigured` behavior via
  constructor values (compile-time `fromEnvironment` can't be set in
  tests — test the ctor + predicates).

Expected delta: ~10–13 new tests → ~178–181 total.

## CREDENTIAL / SECURITY AUDIT SPEC (Argus-verified)

Grep all touched files for: service-role keys, `sbp_`/`eyJ` tokens,
DB passwords, OAuth client secrets, `.env` files, private keys,
committed credential files. Allowed: the four dart-define *names* and
placeholder `<your-…>` values. The learner SQL file is the senior
verbatim — verify it grants `anon`/`authenticated` only, uses
`security_barrier`, and contains no credentials.

## DEFINITION OF DONE (M23)

G16–G24 PASS · impl QA PASS · content QA PASS · site QA PASS ·
sequential replay PASS (physical, from M22 clone) · regression PASS ·
credential audit PASS · post-PASS mutation CLEAN/REVERIFIED ·
`LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED` recorded honestly ·
senior `main@c8eb860` unchanged · FR-14 closed + guest-seam row opened
(→M24) · M26 untouched.
