# M23 IMPLEMENTATION QA — Supabase bootstrap + Leaderboard

Role: ARGUS | Baseline claim: 168/168 · analyze clean | Senior ref: `flutter-accelerator-ai` @ `main` — verified `git rev-parse HEAD` = `c8eb860ed9f4dbcda176c8282a9feb4d2d70d1d3` ✓

Verdict: **PASS_WITH_FINDINGS** — all gates verified green; findings are environmental/documentation notes, zero implementation defects. `LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED` — no credentials exist in this environment; PASS path is deterministic fakes + unconfigured fallback per brief §Remote-service assumptions.

---

## 1. COMMAND EVIDENCE (re-run, not trusted from §02)

| Command | Result |
|---|---|
| `flutter analyze` (learner-app) | **"No issues found!"** (1.7s) — CLEAN |
| `flutter test` (learner-app) | **"+193: All tests passed!"** — 193/193, matches claimed delta 168→193 |
| `git status` / `git diff --stat` | **NOT RUNNABLE** — `learner-app` and `flutter-course-accelerator-ai` root are *not git repositories* (`fatal: not a git repository`). Scope verified by manual file inventory instead (§5). Finding F1. |

Test-count arithmetic cross-check: 9 VM + 8 widget + 4 repo + 3 env + 1 menu-VM = **+25** → 168+25 = **193** ✓ (verified by `grep -c "test("` per file: 9/8/4/3 + `menu_view_model_test.dart:149`).

## 2. SENIOR FIDELITY — verified file-by-file

| Senior file @c8eb860 | Learner file | Result |
|---|---|---|
| `core/supabase_environment.dart` | `lib/core/supabase_environment.dart` | **VERBATIM** modulo doc comments — same 4 dart-define keys (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID`), same field names, same `isSupabaseConfigured`/`isGoogleConfigured`/`configurationError` incl. identical error strings + ordering. |
| `services/supabase_client_service.dart` | `lib/services/supabase_client_service.dart` | **VERBATIM** — `initialize(env) → SupabaseClient?`, null-on-unconfigured, `Supabase.initialize(url, publishableKey)` → `supabase.client`. |
| `repositories/leaderboard/…_contract.dart` | same | **VERBATIM** — `loadLeaderboard({String? currentUserId})`, `LeaderboardSnapshot{entries,currentEntry}`. |
| `repositories/leaderboard/leaderboard_repository.dart` | same | **SEMANTIC VERBATIM** — query chain identical at `leaderboard_repository.dart:35-40`: `from('leaderboard').select('rank,name,avatar_url,level,total_money_won').order('total_money_won',ascending:false).order('rank').limit(10)`; current row `:55-59` `.eq('auth_uuid',uid).maybeSingle()`; `DisabledLeaderboardRepository` static fallback `:85-95`; defensive `_stringValue`/`_intValue`/`_formatScore` byte-equal to senior. Deltas: `@visibleForTesting entryFromRow` seam `:71-79` (test-plan-mandated, documented D4) and `toEntry` omits `avatarAsset`/`rankAsset`/`style` (permitted → M28). |
| `data/leaderboard/leaderboard_entry_data.dart` | same | **FIELD-SET AS SPEC'D** — `{rank,name,level,score,avatarUrl,isCurrentUser}` (asset fields deferred → M28, `avatarUrl` kept ✓); 4 sealed states + `LeaderboardPopupMessage{empty,loadError,loading}` + `Success.isRefreshing` verbatim `:38-82`; static 6-row table + rank-125 `currentLeaderboardEntry` keep senior names/scores `:86-132`. |
| `view_models/leaderboard/leaderboard_dialog_view_model.dart` | same | **VERBATIM MINUS AUTH** — `_requestId` guard identical (`:51` capture before await, `:71`/`:89` `_isLatestRequest` post-await + in catch — old request resolving after newer returns without `_setState`); `isRefreshing` keeps-entries semantics `:54-64`; `retry()`→`unawaited(loadLeaderboard())`; profile-backed fallback `_currentUserLeaderboardEntry`/`_profileBackedCurrentLeaderboardEntry` (profile-avatar priority) verbatim minus asset fields. Ctor `(leaderboardRepository, userProfileRepository)` — **no `AuthRepository`** ✓; `_currentLeaderboardUserId()→null` guest seam marked for M24 `:107-112`. |
| `main.dart` DI section | `lib/main.dart` | **VERBATIM PATTERN** — `env → SupabaseClientService.initialize (null-on-unconfigured) → supabaseClient == null ? DisabledLeaderboardRepository() : SupabaseLeaderboardRepository(client:)` `:40-56` → `leaderboardRepository` arg to `AppDependencyScope`. `[supabase] config …` debugPrint replaces senior `[auth]` prints (auth n/a — documented D9). |
| `core/app_dependency_scope.dart` | same | `Provider<LeaderboardRepository>.value` under **contract type** `:68`; ctor param required `:52`. |
| menu wiring | `menu_screen.dart`, `menu_view_model.dart`, `menu_screen_ui_event.dart` | `MenuLeaderboardRequested` sealed event `:46-48`; `requestLeaderboardDialog()` (senior method name) emits event `menu_view_model.dart:131-133`; bridge `case MenuLeaderboardRequested(): unawaited(_openLeaderboard())` `menu_screen.dart:113-117` → `showLeaderboardDialog(context)` `:154` — **settings `showDialog` transport, NOT MenuDialogLayer** ✓; `_LeaderboardEntry` tappable `Semantics(button)+GestureDetector('menu-leaderboard-entry')→requestLeaderboardDialog()` `:508-516`. |
| dialog scope/widgets | `widgets/menu/leaderboard/*`, `widgets/leaderboard/*` | `showLeaderboardDialog` context-reads both repos → `showDialog` (settings pattern); `MenuLeaderboardDialogScope` dialog-scoped `ChangeNotifierProvider<LeaderboardDialogViewModel>` + `_LeaderboardDialogBridge` `_didLoadLeaderboard`+post-frame-once `loadLeaderboard()` — senior bridge pattern preserved; `LeaderboardPopupBody` exhaustive 4-state switch + `l10n.retryButton` error retry; `LeaderboardList` `RefreshIndicator.adaptive`+`AlwaysScrollableScrollPhysics`+pinned current row+`isRefreshing` progress; `LeaderboardRow` `#N` rank + `rankSemanticLabel` Semantics-on-leaf + `profileLevel` + score — learner `MenuTokens` chrome, no SVG/painter/avatar (permitted → M28). |
| `supabase/student-setup/01-setup-database.sql` | same | **BYTE-IDENTICAL** — `diff -q` → IDENTICAL (181 lines both). Grants `anon`/`authenticated` select only on `public.leaderboard` view; `security_barrier=true`; `public.users` revoked from anon/authenticated; no credentials. |
| senior `test/view_models/leaderboard/_async_test.dart` | learner VM test `:156-193` | Stale test is a faithful port — same completer-pair choreography, same assertions. |

`SupabaseNotConfigured` divergence (D1): **VERIFIED LEGITIMATE** — repo-wide grep of senior @c8eb860 returns 0 matches; the brief's symbol table overstated. Flux correctly did not invent the symbol; the `SupabaseClient?` null-return is the actual senior sentinel. Good adversarial catch, properly documented.

## 3. TEST QUALITY

- **Stale-race test is REAL** (`leaderboard_dialog_view_model_test.dart:156-193`): two completers popped in call order; request 2 completes first → asserts `SECOND PLAYER` written; then request 1 (stale, id=1 vs `_requestId`=2) completes → asserts state still `SECOND PLAYER`. Removing the `_requestId` check flips the final assertion to `REMOTE PLAYER` → genuinely guards the race; verified against senior's identical test (`_async_test.dart:56-89`). **STALE_RACE_TEST_REAL: YES.**
- Fake repo is handwritten (`test/helpers/fake_leaderboard_repository.dart`) — `snapshot`/`error`/`completers` scriptable + `loadCallCount`/`lastCurrentUserId` interaction recording; no mock package anywhere (pubspec dev_deps: `flutter_test`,`flutter_lints`,`fake_async` only).
- **No test constructs `SupabaseClient`** — grep confirms `SupabaseClient`/`supabase_flutter` appear in test files only inside doc comments; remote impl covered via `entryFromRow` seam; env tested via ctor+predicates (compile-time `fromEnvironment` untestable — correct approach per plan).
- Widget tests cover all 4 state branches, retry wiring (counter), `RefreshIndicator.onRefresh` invocation + `isRefreshing` progress, scope post-frame auto-load (`loadCallCount==1`, `lastCurrentUserId==null` guest), error→retry 2nd load, and full menu-tap→event→`showDialog`→repo-data path.
- `menu_view_model_test.dart:149-160` event test subscribes `events.first` before `requestLeaderboardDialog()` — proper broadcast-stream assertion. `sealed_state_test.dart:27,34` exhaustive switch gained the new case (compile-forced).

## 4. SCOPE VIOLATIONS — `lib/` grep audit

`AuthRepository|AuthSession|google_sign_in|GoogleSignIn|signInWithApple|upsert|UserProfileSync|MenuDialogLayer|MenuDialogLeaderboard|Dre|asyncOp|\.env` → **all 19 hits are doc comments** referencing senior constructs marked for M24/M26/M29 (e.g. `leaderboard_dialog_view_model.dart:18,23,107-108` guest-seam notes; `menu_screen.dart:115-116`). Zero code symbols, zero imports of auth/google/mock frameworks. No `menu_dialog*` or `auth*` files exist under `lib/`. **SCOPE: CLEAN.**

## 5. FILE INVENTORY vs ALLOW-LIST (manual — no git, see F1)

NEW (all within allow-list incl. the "leaderboard_list/row if the dialog splits" clause): `lib/core/supabase_environment.dart`, `lib/services/supabase_client_service.dart`, `lib/data/leaderboard/leaderboard_entry_data.dart`, `lib/repositories/leaderboard/{_contract,}.dart` (2), `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart`, `lib/widgets/menu/leaderboard/{menu_leaderboard_dialog,menu_leaderboard_dialog_scope}.dart`, `lib/widgets/leaderboard/{leaderboard_popup_body,leaderboard_list,leaderboard_row}.dart`, `supabase/student-setup/01-setup-database.sql`, `test/helpers/fake_leaderboard_repository.dart`, `test/view_models/leaderboard/leaderboard_dialog_view_model_test.dart`, `test/widgets/menu_leaderboard_dialog_test.dart`, `test/repositories/leaderboard_repository_test.dart`, `test/core/supabase_environment_test.dart` (last two satisfy TEST-PLAN repo/env items — documented D10; allow-list test files marked non-exhaustively).

EDITED: `pubspec.yaml`, `lib/main.dart`, `lib/core/app_dependency_scope.dart`, `lib/screens/menu_screen.dart`, `lib/view_models/menu/{menu_view_model,menu_screen_ui_event}.dart`, `lib/l10n/app_{en,vi}.arb` + 3 generated `app_localizations*.dart`, `test/{sealed_state,menu_view_model,menu_screen_ui_events,menu_provider_scope}_test.dart`, `test/widgets/game_screen_test.dart` (compile-forced `leaderboardRepository:` arg — verified `:130`).

No stray new files found outside `build/`/`.dart_tool` artifacts. Directory listing confirms `lib/services/` contains only `supabase_client_service.dart`; no config/secret files.

## 6. CREDENTIAL AUDIT

Grepped `lib/ test/ supabase/ pubspec.yaml` for `sbp_`, `eyJ` (JWT prefix), `service_role`/`service-role`, `password`, `secret`, `api_key`, `anon_key`, `*.supabase.co`, token assignments, `.env` files:
- **Zero secrets.** No `.env` file exists; no tokens; no real project refs.
- `service-role` appears once — doc comment in `supabase_environment.dart:16` *explaining* publishable-vs-service-role boundary (allowed prose).
- `https://x.supabase.co` in `supabase_environment_test.dart` — placeholder fixture, not a real project ref.
- `SUPABASE_*`/`GOOGLE_*` appear only as dart-define **names** + `<key>`/`<url>` placeholders (`main.dart:37-38`).
- `build/` + `.dart_tool/` JS artifacts contain `weak_password`/`PASSWORD_RECOVERY`/autofill strings — compiled `supabase_flutter` SDK internals in build output, not source leaks.
- SQL file: `grant select … to anon, authenticated` on the view only; `revoke` on `public.users`; `security_barrier=true`; comment explicitly documents no secrets.

**CREDENTIAL_AUDIT: CLEAN.**

## 7. PUBSPEC + ARB

- `pubspec.yaml:46` — `supabase_flutter: 2.14.2` exact pin, identical to senior `pubspec.yaml:47`. Only new dependency; no mockito/mocktail/build_runner/codegen added.
- ARB keys added — all values **verbatim senior** in en+vi: `leaderboardSemanticLabel` ("Leaderboard"/"Bảng xếp hạng"), `leaderboardEmptyMessage`, `leaderboardLoadErrorMessage`, `leaderboardLoadingMessage`, `retryButton` ("Retry"/"Thử lại"), `rankSemanticLabel` ("Rank {rank}"/"Hạng {rank}") + `@rankSemanticLabel` ICU `int` placeholder. `leaderboardTitle` pre-existing and matches senior; `leaderboardSubtitle` is a learner-only pre-existing key (senior lacks it — used by menu card; not a violation).
- Generated `app_localizations{,_en,_vi}.dart` in sync — abstract getters + both impls contain all 6 keys; `rankSemanticLabel(int)` signature generated correctly.

## 8. UNCONFIGURED RUN — static verification

`main()`: `SupabaseEnvironment.fromEnvironment()` → `isSupabaseConfigured` false when dart-defines absent (both empty → `trim().isNotEmpty` fails) → `SupabaseClientService.initialize` returns `null` at `supabase_client_service.dart:19-20` without calling `Supabase.initialize` → `main.dart:53-56` selects `const DisabledLeaderboardRepository()` → static snapshot, no network. Dialog path (`menu tap → event → showLeaderboardDialog → scope → VM → repo`) works fully unconfigured — widget test proves it end-to-end against a fake. **Confirmed.**

## FINDINGS

- **F1 (environmental, informational):** `learner-app` is not a git repository — `git status`/`git diff --stat` scope check is not runnable. Mitigated by manual file inventory (§5); recommend Flux/Atlas treat milestone file lists as the scope record. Not an implementation defect.
- **F2 (minor hygiene, pre-existing):** `lib/build/.last_build_id` (32-byte hash, dated Oct 2 — predates M23) — build artifact inside `lib/`; not created by this milestone, no action required for M23; flag for repo hygiene later.
- **F3 (documentation, resolved correctly):** Brief listed `SupabaseNotConfigured` sentinel and pre-existing `leaderboardSemanticLabel`; neither was true in senior/learner. Flux verified by grep, did not invent the symbol, added the ARB key verbatim — divergences D1/D2 documented. No defect.
- **F4 (informational):** `leaderboardSubtitle` learner-only ARB key (senior has no equivalent) — pre-existing, used for menu card text; acceptable.
- **Deltas intentionally deferred per brief, verified absent-not-broken:** `avatarAsset`/`rankAsset`/`LeaderboardRowStyle`/`LeaderboardAvatar` (M28), `AuthRepository` + `switch(authState)` (M24), `MenuDialogLayer`/`MenuDialogLeaderboard` state (M29), `DreChangeNotifier`/`asyncOp` (M26), realtime subscriptions, `public.users` writes/upsert (M25).
- `LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED` recorded honestly — network path `SupabaseLeaderboardRepository.loadLeaderboard` covered by source-verbatim query chain + mapper seam tests only; per brief this is never a gate.

```
ARGUS_M23_IMPLEMENTATION_QA: PASS_WITH_FINDINGS
ANALYZE: CLEAN
TESTS: 193/193 PASS
FIDELITY: PASS
SCOPE: CLEAN
CREDENTIAL_AUDIT: CLEAN
STALE_RACE_TEST_REAL: YES
BLOCKERS: none
```
