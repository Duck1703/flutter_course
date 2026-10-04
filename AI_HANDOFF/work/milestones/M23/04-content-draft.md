# M23 — CONTENT DRAFT MANIFEST (Lumen)

## Intake gate

`IMPLEMENTATION_APPROVED` confirmed — `03-implementation-qa.md` on
disk (Argus PASS_WITH_FINDINGS, 0 blockers; F1–F4 informational).
Learner app verified on disk: `flutter analyze` clean, `flutter test`
**193/193**, `flutter build web` PASS (02-implementation §5).
Senior unchanged (`main@c8eb860` — `git rev-parse HEAD` re-verified
by Argus).

## Lessons authored (5 + index) — `AI_HANDOFF/work/milestones/M23/lessons/`

| File | Concepts (brief registry) | Exercise |
|---|---|---|
| `index.md` | milestone map + deferred table + synthesis | — |
| `01-supabase-va-dart-define.md` | **D-40** `String.fromEnvironment`/`--dart-define` (Dart, guided); **B-01** RLS/anon-key security boundary (backend, awareness); **B-02** view-vs-table read model (backend, awareness); "config is plumbing, not state" | Tự làm PREDICT: `isSupabaseConfigured`/`isGoogleConfigured`/`configurationError` under 4 define combos; Thử nghiệm PREDICT configurationError ordering |
| `02-init-co-dieu-kien.md` | **F-31** `Supabase.initialize`/`SupabaseClient` (Flutter, LIGHT); **A-24** conditional DI by config (architecture, guided); **A-23** remote repo impl behind contract (architecture, guided); `SupabaseClient?`-as-sentinel (documented: NO `SupabaseNotConfigured` symbol — brief overstatement verified by grep) | Tự làm PREDICT: ternary outcome table (configured vs not); Thử nghiệm PREDICT missing `await` type break |
| `03-leaderboard-repository.md` | **D-41** `maybeSingle` + JSON row→typed-entry defensive mapping (Dart/backend, guided); snapshot-vs-stream model; `_LeaderboardRecord`; `entryFromRow` `@visibleForTesting` seam; `FakeLeaderboardRepository` completers; `LeaderboardPopupState` 4-variant dictionary (D-26/A-14 reinforcement — consumers land L04/L05) | **Tự làm PRODUCE**: write `ScriptedLeaderboardRepository` (queue-pop fake) + ordering test; Thử nghiệm PREDICT score of negative amount |
| `04-viewmodel-va-stale-guard.md` | **D-42** `_requestId` monotonic stale guard (Dart, applied — "old answers must not win"); `isRefresh` keeps-entries transition; `retry()` unawaited; profile-backed current entry; guest seam `_currentLeaderboardUserId()→null` (register row → M24) | **Tự làm DEBUG**: delete post-await `_isLatestRequest` check → predict+observe stale test fail `'REMOTE PLAYER'` vs `'SECOND PLAYER'` |
| `05-dialog-va-menu-row.md` | **F-32** `RefreshIndicator.adaptive` + `AlwaysScrollableScrollPhysics` (Flutter, applied); dialog-scoped VM + post-frame load (A-15 reinforced); event→showDialog transport (FR-29 → M29); `MenuTokens` chrome | Tự làm PREDICT: remove `AlwaysScrollableScrollPhysics` → pull dies on short list, widget test stays green (calls `onRefresh` directly) |

## Concept → brief registry entry mapping

| Brief entry (LEARNING DESIGN CHECK) | Lesson | Registry row used in lessons |
|---|---|---|
| `String.fromEnvironment` / dart-define (Dart, guided) | L01 | **D-40** |
| RLS/anon-key security boundary (backend, awareness) | L01 | **B-01** |
| View-vs-table read model (backend, awareness) | L01 | **B-02** |
| `Supabase.initialize`/`SupabaseClient` (Flutter) | L02 | **F-31** |
| Conditional DI by config (architecture, guided) | L02 | **A-24** |
| Remote repository impl behind contract (architecture, guided) | L02/L03 | **A-23** |
| `maybeSingle` + row mapping (Dart/backend, guided) | L03 | **D-41** |
| Stale-response guard `_requestId` (Dart, applied) | L04 | **D-42** |
| `RefreshIndicator` (Flutter, applied) | L05 | **F-32** |

Mental models from brief placed: "contract doesn't know where data
lives" → L02 (tied to M14 A-06/A-07); "config is plumbing, not
state" → L01; "old answers must not win" → L04. Isolated examples
from brief placed: 15-line `String.fromEnvironment` demo → L01;
`ScoreRepository` contract/fake/remote sketch → L02; monotonic
counter `Fetcher` → L04.

## Depth assignments

- Guided/new: **D-40**, **D-41**, **D-42**, **A-23**, **A-24** —
  all NORMAL depth (bounded application of known contract/DI/async
  concepts; none is a new simultaneous mental model beyond the
  lesson's single focus).
- Awareness: **B-01**, **B-02** (backend, LIGHT); **F-31** SDK API
  (LIGHT); applied: **F-32** (NORMAL — physics detail earns it).
- No CORE_CONCEPT row is claimed for M23 — every new concept is an
  application of an existing CORE (A-07 DI, A-11 fakes, A-14 state
  UI, A-15 dialog scope, D-19 interface, D-26/27 sealed+switch).
- ≤3 new concepts per page: L01=3 (D-40+B-01+B-02, two awareness),
  L02=3 (F-31 light+A-24+A-23), L03=1 (D-41), L04=1 (D-42), L05=1
  (F-32 applied).

## Registry / graph updates (done before QA)

- `LEARNER_CONCEPT_REGISTRY.md`: +**D-40/D-41/D-42** (Dart),
  +**F-31/F-32** (Flutter), +**A-23/A-24** (Architecture) — all
  TAUGHT; new "Backend (Supabase)" section +**B-01/B-02**
  (INTRODUCED/awareness).
- `PREREQUISITE_GRAPH.md`: M23 section appended (D-40 → L01 →
  A-23/A-24 → L02 → D-41 → L03 → D-42 → L04 → F-32 → L05; feeds
  M24 auth ctor, M25 writes, M26 DRE, M28 assets, M29 dialog layer).
- `SENIOR_FIDELITY_REGISTER.md`: FR-14 → **CONVERGED at M23**;
  new row **FR-35** (leaderboard VM guest seam — ctor lacks
  `AuthRepository`, `_currentLeaderboardUserId()≡null` → M24).

## Checkpoint arithmetic (honest, from M22 final 168)

| Lesson end | Count | Delta | Test files touched |
|---|---|---|---|
| L01 | **171** | +3 | `test/core/supabase_environment_test.dart` (3) |
| L02 | **171** | +0 | 3 existing test files gain `leaderboardRepository:` arg (compile-forced: `menu_provider_scope_test.dart:33`, `menu_screen_ui_events_test.dart:29`, `widgets/game_screen_test.dart:130`) |
| L03 | **175** | +4 | `test/repositories/leaderboard_repository_test.dart` (4) + `test/helpers/fake_leaderboard_repository.dart` (helper) |
| L04 | **184** | +9 | `test/view_models/leaderboard/leaderboard_dialog_view_model_test.dart` (9) |
| L05 | **193** | +9 | `test/widgets/menu_leaderboard_dialog_test.dart` (8) + `menu_view_model_test.dart` (+1 event test) + `sealed_state_test.dart` (case, compile-forced, no count change) |

Cross-checked against impl QA: 9+8+4+3+1 = +25 → 168+25 = 193 ✓.

## Per-lesson checkpoint commands (all credential-free)

- L01: `flutter pub get`, `flutter analyze`, `flutter test`,
  `flutter test test/core/supabase_environment_test.dart`
- L02: `flutter analyze`, `flutter test`, `flutter run` (observe
  `[supabase] config supabase=false google=false`)
- L03: `flutter analyze`,
  `flutter test test/repositories/leaderboard_repository_test.dart`,
  `flutter test`
- L04: `flutter analyze`,
  `flutter test test/view_models/leaderboard/
  leaderboard_dialog_view_model_test.dart`, `flutter test`
- L05: `flutter gen-l10n`, `flutter analyze`, `flutter test`,
  `flutter build web`, `flutter run` (manual, no defines) —
  OPTIONAL `flutter run --dart-define=SUPABASE_URL=<your-project-url>
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-publishable-key>`
  labelled environment-dependent.

## Exercise inventory (milestone requirement: ≥1 PRODUCE + ≥1 DEBUG/PREDICT real defect)

| Lesson | Type | Task | Verifiability |
|---|---|---|---|
| L01 | PREDICT | env-combo → predicate values | verifiable vs test expectations |
| L02 | PREDICT | DI ternary outcome per config | verifiable by reading `main.dart` + run |
| L03 | **PRODUCE** | `ScriptedLeaderboardRepository` queue fake + test | runnable test, solution provided |
| L04 | **DEBUG** | delete `_isLatestRequest` post-await → which test fails / final state | REAL defect verified: stale request completes after fresh → state flips to `'REMOTE PLAYER'` → test `response STALE không được ghi đè…` fails at final `expect` (QA §3 confirmed: "Removing the `_requestId` check flips the final assertion to `REMOTE PLAYER`"); catch-path guard untouched so error test stays green — honest single-test failure |
| L05 | PREDICT | remove `AlwaysScrollableScrollPhysics` → pull-to-refresh dies; widget test still green (direct `onRefresh` call) | manually observable; test reasoning verified against test file `:129-133` |

## Senior citations used (all verified vs `main@c8eb860`)

| Lesson | Senior file · symbol |
|---|---|
| L01 | `lib/core/supabase_environment.dart` (verbatim port basis); `supabase/student-setup/01-setup-database.sql` (`public.users` RLS `users_select_own`/`insert_own`/`update_own`, `security_barrier` view, `row_number()` rank, `auth_uuid` masked, `grant select…to anon, authenticated`); `lib/main.dart:25` `SupabaseEnvironment.fromEnvironment()` |
| L02 | `lib/services/supabase_client_service.dart` `SupabaseClientService.initialize` (verbatim); `lib/main.dart:30-53` env→init→`supabaseClient == null ? Disabled… : Supabase…` (senior also has `DisabledAuthRepository`/`SupabaseAuthRepository` + `[auth]` prints — learner `[supabase]` divergence documented); absence of `SupabaseNotConfigured` verified by repo grep |
| L03 | `lib/repositories/leaderboard/leaderboard_repository_contract.dart` (verbatim); `lib/repositories/leaderboard/leaderboard_repository.dart` (query chain `from('leaderboard').select('rank,name,avatar_url,level,total_money_won').order('total_money_won',ascending:false).order('rank').limit(10)` + `.eq('auth_uuid',uid).maybeSingle()`, `DisabledLeaderboardRepository`); `test/helpers/fake_leaderboard_repository.dart` |
| L04 | `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart` (`_requestId` guard, `loadLeaderboard({isRefresh})`, `refresh`, `retry`, `_profileBackedCurrentLeaderboardEntry`, `_currentUserLeaderboardEntry`, `_currentLeaderboardUserId` senior `switch(authState)` → `AuthSessionAuthenticated(:final uid)`/`AuthSessionGuest`, `AuthRepository` ctor param — guest seam cited read-only); senior `_async_test.dart` completer choreography |
| L05 | `lib/widgets/menu/leaderboard/menu_leaderboard_dialog_scope.dart` (`MenuLeaderboardDialogScope` + `ChangeNotifierProvider` + `_didLoadLeaderboard` + post-frame, + `authRepository:` param deferred); `lib/widgets/leaderboard/` (`LeaderboardPopupBody` 4-state switch, `LeaderboardList` refresh+pinned row, `LeaderboardRow` semantics-on-leaf, `LeaderboardAvatar` M28); `lib/widgets/menu/leaderboard/leaderboard_entry_card.dart` (`LeaderboardEntryCard(onTap)`); `lib/view_models/menu/menu_screen_view_model.dart:90` `requestLeaderboardDialog()` → `MenuDialogLeaderboard` (M29); `lib/view_models/menu/menu_dialog_state.dart:19` `MenuDialogLeaderboard` |

## Remote-runtime honesty (hard requirement)

Every lesson states the mandatory path is deterministic fakes +
unconfigured fallback; `LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED`
appears verbatim in L02/L05/index. The configured command form is
taught with `<your-project-url>`/`<your-publishable-key>`
placeholders and values-from-own-project framing; never implies a
live backend was verified. No real URL/key/token anywhere — checked
L01 (uses `https://abc.supabase.co`, `https://x.supabase.co` fixture
form only), L03 (`https://example.com` fixture rows), L05
(placeholders only).

## Declared deviations from template

- Every lesson carries the full Template-V2 spine (Mục tiêu →
  Bạn-đang-ở-đâu → Vì-sao → Bạn-đã-biết-gì → Mental-model →
  construct table → steps → Chạy-và-quan-sát → Thử-nghiệm →
  Lỗi-hay-gặp → Tự-làm → Kiểm-tra-hiểu-biết → Ta-cố-ý-chưa-thêm →
  Checkpoint). Declared merges (gate G23):
  - **"Ví dụ độc lập"**: present in L01 (`String.fromEnvironment`
    scratch `main`), L02 (`ScoreRepository` contract→fake→remote),
    L04 (20-line `Fetcher` monotonic guard). L03 folds it — its
    "isolated example" *is* `FakeLeaderboardRepository` (test-layer
    code detached from app production, walked line-by-line) — and
    L05 drops it (applied lesson; every construct is a re-use —
    `showDialog` M09/F-13, event bridge M13/A-05, dialog-scope
    M16/A-15, `Semantics`+`GestureDetector` M16/F-23+F-28).
  - **"Android / Compose bridge"**: present in L01 (`BuildConfig`
    vs dart-define) and L02 (sentinel-null + DI selection). Omitted
    in L03 (backend-SDK internals — the useful bridge sits at the
    config/init boundary already covered in L01/L02), L04/L05
    (stale-guard + dialog transport are pattern applications whose
    bridges were made at M13–M16 for the same transports).
  - **Construct table**: L05 folds the F-32 row into the
    `LeaderboardList` step (one applied API, glossed at point of
    use) — every other construct there is already taught (LIGHT
    rule satisfied by naming at point of use).
- "Kiểm tra hiểu biết" is a real section in every lesson (2–3
  Q&A each).
- L02 creates production files verbatim then defers query-chain
  dissection to L03 — declared ordering; files compile green at L02
  checkpoint (no dangling references: contract→data→repo→scope→main
  all land in the same lesson).
- L03 is a "Hiểu code + test-locking" lesson (no new production
  file) — its production is `test/` artifacts; declared here.
- `SupabaseNotConfigured` is explicitly taught as NON-EXISTENT
  (L02 note box) — brief symbol overstated; Argus verified grep=0.
- L05 optional configured run uses `flutter run --dart-define=…`
  placeholders — labelled OPTIONAL/environment-dependent; the
  alternative `dart run --define=` spelling appears only inside the
  L01 scratch demo (Dart CLI verified: dart.dev environment-
  declarations doc).

## Verification before handoff

- Every quoted symbol grep-verified against learner source:
  `SupabaseEnvironment` 4 fields/predicates, `SupabaseClientService.
  initialize`, `SupabaseClient`, `LeaderboardRepository`,
  `LeaderboardSnapshot{entries,currentEntry}`, `LeaderboardEntryData`
  6-field shape, 4 `LeaderboardPopup*` + `LeaderboardPopupMessage`,
  `leaderboardEntries`(6)/`currentLeaderboardEntry`(125/`Tàu hủ đi
  chill`), `_leaderboardView`/`_leaderboardColumns`/`_topEntryCount`,
  `entryFromRow`, `DisabledLeaderboardRepository`, `LeaderboardDialogViewModel`
  members (`_requestId`,`_isDisposed`,`_setState`,`_isLatestRequest`,
  `_currentLeaderboardUserId`,`_profileBackedCurrentLeaderboardEntry`,
  `_currentUserLeaderboardEntry`,`_formatScore`), `FakeLeaderboardRepository`
  (`snapshot`/`error`/`completers`/`loadCallCount`/`lastCurrentUserId`),
  `showLeaderboardDialog`, `MenuLeaderboardDialogScope`,
  `_LeaderboardDialogBridge`/`_didLoadLeaderboard`,
  `MenuLeaderboardDialog`, `LeaderboardPopupBody`/`_messageText`,
  `LeaderboardList`/`_TopRowsScrollView`, `LeaderboardRow`,
  `MenuLeaderboardRequested`, `requestLeaderboardDialog`,
  `_openLeaderboard`, `_LeaderboardEntry`, widget keys
  (`leaderboard-dialog-shell`/`scrollable-top-rows`/`current-user-row`/
  `refresh-progress`/`loading-progress`/`retry-button`/`menu-leaderboard-entry`),
  ARB keys (`leaderboardSemanticLabel`/`leaderboardEmptyMessage`/
  `leaderboardLoadErrorMessage`/`leaderboardLoadingMessage`/
  `retryButton`/`rankSemanticLabel`/`profileLevel`/`leaderboardTitle`/
  `leaderboardSubtitle`), `MenuTokens` (`backgroundBottom`/`accentYellow`/
  `statGreen`/`cardBorder`/`textSecondary`/`spacingSm`/`spacingXs`/
  `spacingMd`/`spacingLg`/`radiusCard`), `UserProfileData.formatVnd`/
  `defaultUsername '0XFF'`, `localizedTestApp` helper signature.
- Senior symbols verified read-only: `MenuDialogLeaderboard`
  (`menu_dialog_state.dart:19`), senior `requestLeaderboardDialog`
  (`menu_screen_view_model.dart:90`), senior scope `authRepository:`
  line, senior `_currentLeaderboardUserId` switch (`:91-96`),
  `AuthSessionAuthenticated`/`AuthSessionGuest`,
  `LeaderboardRowStyle{first,second,third,glass,currentUser}`,
  `avatarAsset`/`rankAsset` fields, `[auth]` debugPrints, senior
  `main.dart` DI block — all cited as evidence, never as
  paste-target.
- Test-count arithmetic re-derived from `grep -c "test("` per file:
  9/8/4/3 + 1 = +25 → 193 ✓ (matches QA cross-check).
- No `dart test` anywhere — all suites are `flutter_test`.
