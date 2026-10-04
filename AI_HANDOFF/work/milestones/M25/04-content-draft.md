# M25 — CONTENT DRAFT MANIFEST (Lumen)

## Intake gate

`IMPLEMENTATION_APPROVED` confirmed — `03-implementation-qa.md` on
disk (Argus PASS_WITH_FINDINGS → remediated → reverify PASS). Learner
app verified on disk: `flutter analyze` clean, `flutter test`
**236/236**, `flutter build web` PASS (02-implementation §5 /
03-qa gates). Senior unchanged (`main@c8eb860`, read-only — verified
by Argus, `git status` clean). `LIVE_PROFILE_SYNC: NOT_PERFORMED`
inherited (no Supabase credentials — never a gate; merge/schema/
call-path tests carry verification weight per brief).
SQL `01-setup-database.sql` + `02-verify-database.sql` re-verified
byte-identical vs senior during content authoring (`diff -q` clean).

## Lessons authored (5 + index) — `AI_HANDOFF/work/milestones/M25/lessons/`

| File | Concepts (brief registry) | Exercise |
|---|---|---|
| `index.md` | milestone map + deferred table + synthesis + FR-36 closure note | — |
| `01-app-user-data-va-schema.md` | **A-27** boundary DTO — `AppUserData` 8 field theo cột `public.users`, 4 cửa dịch (`fromMap`/`fromProfile`/`toUpsertMap`/`toProfile`), parse phòng thủ (architecture, guided); **B-08** `public.users` write model — schema 11 cột/`auth_uuid` unique FK/CHECKs/RLS own-row, payload↔cột contract, `02-verify-database.sql` (backend, guided — upsert call lands L03); ba-thứ-remote-không-có (`email`/`gamesWon`/`totalEarnings`) awareness via B-06 | Thử nghiệm PREDICT `fromMap` bad-row → defaults; Tự làm PREDICT `fromProfile().toUpsertMap()` ×3 (incl. no-normalize trap) |
| `02-merge-user-profile-for-sync.md` | **A-28** merge/conflict-resolution policy — deterministic pure function: session-wins identity (3-tier username, asymmetric avatar), leader progression level→exp tiebreak nguyên khối, totals max per-field, `gamesWon` local-only, `_withoutDemoProgression`/`_hasDemoProgression` `==`-match (architecture, guided) | **Tự làm DEBUG** (verified): `_withoutDemoProgression(localProfile)` → `localProfile` → `'merge normalizes legacy demo progression…'` ĐỎ at `expect(merged.level, 1)` Actual 12, username assert passes (partial-pass trap); Thử nghiệm PREDICT tie-break + remote-name-wins-username |
| `03-sync-repository-impl.md` | **A-29** sync orchestration — `_isSyncing` re-entrancy guard (≠ `_requestId` D-42, ≠ `_isLoading` dialog VM), `InProgress → load → fetch maybeSingle → merge → save local → upsert → Idle`, catch→`Failed`+rethrow, `_emit` isClosed+dedupe; **B-08** phần call — `upsert(toUpsertMap(), onConflict:'auth_uuid')` insert-or-update | Tự làm PREDICT emit-sequence ×3 (success/fetch-throw/re-entrant); Thử nghiệm PREDICT stream values per scenario |
| `04-main-di-va-game-vm.md` | **A-24** conditional DI reinforcement (lần 3 — leaderboard M23, auth M24, sync M25); **A-30** post-save best-effort sync — `_syncSavedGameResult`: `loadAuthState` → `is AuthSessionAuthenticated` → sync + started/completed; guest `skipped; session=guest`; catch nuốt + `failed:` (architecture, guided); `is` vs `isAuthenticated` (promote để gọi hàm kiểu-hẹp) | **Tự làm PRODUCE**: scratch `m25_result_sync_exercise_test.dart` — authed→save→sync (`saveCallCount==1`, `syncCallCount==1`, `uid=='user-1'`), solution provided, file deleted after; Thử nghiệm PREDICT DI ternary ×3 env (incl. Google-missing vẫn Impl) |
| `05-sync-tests-va-tong-ket.md` | "test ở đúng tầng" mental model — pure (7) / contract (2) / call-path (3) / wire (NOT_PERFORMED); group `result profile sync (M25, FR-36)` 3 test; `syncError` assert `syncCallCount==1` ("đã gọi rồi fail" ≠ skip); `hasSavedResult` idempotence reuse (A-22); FR-36 closure | Thử nghiệm PREDICT counts ×4 (incl. double-backToMenu idempotence); Tự làm PREDICT failing-assert map ×3 (sync-call removal → test 1 red; inner-catch removal → NO test red, log tells wrong story — verified; hardcoded session → uid assert red) |

## Concept → brief registry entry mapping

| Brief entry (LEARNING DESIGN CHECK) | Lesson | Registry row used in lessons |
|---|---|---|
| `AppUserData` boundary DTO (architecture, guided) | L01 | **A-27** (new) |
| `public.users` write model / upsert `onConflict` (backend, guided) | L01 (payload+schema) → L03 (call) | **B-08** (new) |
| Merge semantics: leader/max/session-wins/gamesWon/demo (architecture, guided) | L02 | **A-28** (new) |
| `_isSyncing` guard + emit pipeline + seeded BehaviorSubject (architecture, guided) | L03 | **A-29** (new; A-08/A-10/D-05 reinforcement) |
| Conditional DI reuse (reinforcement) | L04 | **A-24** (reinforced — 3rd application) |
| `_syncSavedGameResult` post-save best-effort sync (architecture, guided) | L04 | **A-30** (new) |

Reinforcement rows cited (no new rows): D-41 (defensive map parsing +
`maybeSingle`), D-42 (contrast guard loại), D-43 (`is
AuthSessionAuthenticated` promote), D-05 (emit dedupe via `==`),
D-34 (`copyWith` merge writes), A-08/A-10 (subject emit discipline),
A-11 (fakes `syncCallCount`/`syncError`), A-22 (`hasSavedResult`
idempotence bảo vệ sync không lặp), B-01/B-02 (RLS `auth_uid() =
auth_uuid`), B-06 (email/gamesWon absence = identity/profile
distinction), F-31 (`SupabaseClient`), D-40 (dart-define), A-26
(coordinator call-site verified-not-rewired).

Mental models placed: "DTO biên — hai thế giới, một lớp dịch" +
"schema là contract thật" + "ba thứ remote cố ý không có" → L01;
"ba lớp luật, ba chủng loại" (identity/progression/totals) +
"không đẩy tiến trình fake lên remote" → L02; "repo điều phối
pipeline, stream kể chuyện" + "`_isSyncing` là khoá cửa, finally là
chìa" + "upsert một câu lệnh hai vai, rethrow vì caller quyết" → L03;
"conditional DI lần ba cùng một dáng" + "save là bổn phận, sync là
best-effort" → L04; "test ở đúng tầng, tin ở đúng chỗ" (4-tier
evidence model) → L05. Isolated examples: `WalletRow` DTO mini →
L01; `P(level,exp,coins)` leader/merge → L02; `_syncing` pipeline
log → L03; `afterSave` swallow-vs-rethrow → L04; `saveAndSync`
count-asserts → L05.

## Depth assignments

- Guided/new: **A-27, A-28, A-29, A-30, B-08** — all NORMAL.
- Awareness (no new row): three-absences (`email`/`gamesWon`/
  `totalEarnings`-String) folded under B-06; RLS under B-01.
- Reinforcement only: D-41, D-42 (contrast), D-43, D-05, D-34, A-08,
  A-10, A-11, A-22, A-24, B-01, B-02, B-06, F-31, D-40, A-26.
- ≤3 new concepts per page (excluding LIGHT/awareness): L01=2
  (A-27+B-08), L02=1 (A-28), L03=2 (A-29+B-08-call), L04=1 (A-30;
  A-24 is reinforcement), L05=0 new.
- No CORE_CONCEPT row claimed for M25 — every concept is an
  application of existing COREs (D-05/D-34 copyWith+equality, D-41
  map parsing, A-08 BehaviorSubject, A-11 fakes, A-22 save boundary,
  A-24 conditional DI, A-26 coordinator seam, B-01 RLS).

## Registry / graph updates (done)

- `LEARNER_CONCEPT_REGISTRY.md`: +**A-27/A-28/A-29/A-30**
  (Architecture), +**B-08** (Backend — TAUGHT); reinforcement column
  touched on A-24 (M25 landed 3rd use), D-41 (`_fetchRemoteProfile`
  same builder), A-22 (`_syncSavedGameResult` landed), A-26 (impl
  replaced Disabled — landed).
- `PREREQUISITE_GRAPH.md`: M25 section appended (A-27/B-08 → L01 →
  A-28 → L02 → A-29 → L03 → A-24-reinforce+A-30 → L04 → L05
  synthesis; feeds M26 DRE ops, M28 visuals, M29 dialog layer).
- `SENIOR_FIDELITY_REGISTER.md`: **FR-36 → CONVERGED at M25**
  (`UserProfileSyncRepositoryImpl` verbatim + conditional DI +
  `_syncSavedGameResult` real branch; `main()` no longer always-
  Disabled).

## Checkpoint arithmetic (honest, from M24 final 224)

| Lesson end | Count | Delta | Test files touched |
|---|---|---|---|
| L01 | **226** | +2 | `test/user_profile_sync_schema_test.dart` created — `toUpsertMap` 8-key column parity + `fromMap` row-without-email |
| L02 | **233** | +7 | `test/user_profile_sync_merge_test.dart` created — 7 senior merge tests (local-wins, remote-wins, tie-exp, session-identity, zero-starter, demo-normalize ×2 semantics) |
| L03 | **233** | +0 | impl only — `UserProfileSyncRepositoryImpl` needs concrete `SupabaseClient` (no in-process fake; senior also has no repo-level test); coverage deferred to L05 |
| L04 | **233** | +0 | production wiring + compile-forced call-site updates: `main.dart` ternary, `game_screen_view_model.dart` ctor+`_syncSavedGameResult`, `game_screen.dart` create, `game_screen_view_model_test.dart` `startedVm` +4 sites, `widgets/game_screen_test.dart` `pumpGameScreen` |
| L05 | **236** | +3 | `game_screen_view_model_test.dart` +`result profile sync (M25, FR-36)` group (authed→sync+uid; guest→0; syncError→swallowed+save intact) |

Cross-checked against impl ledger: 2+7+0+0+3 = **+12** → 224+12 =
**236** ✓ (matches `02-implementation.md` result line "224 → 236 (+12)"
and `03-implementation-qa.md` "236/236").

## Per-lesson checkpoint commands (all credential-free)

- L01: `flutter analyze`, `flutter test`,
  `flutter test test/user_profile_sync_schema_test.dart`;
  `diff -q` learner-vs-senior `02-verify-database.sql` (informational)
- L02: `flutter analyze`,
  `flutter test test/user_profile_sync_merge_test.dart`,
  `flutter test`
- L03: `flutter analyze`, `flutter test` (+0)
- L04: `flutter analyze`, `flutter test` (+0) +
  scratch exercise `flutter test
  test/m25_result_sync_exercise_test.dart` (then delete)
- L05: `flutter analyze`,
  `flutter test test/game_screen_view_model_test.dart`,
  `flutter test` (236), `flutter build web`;
  OPTIONAL env-dependent `flutter run --dart-define=SUPABASE_URL=
  <your-project-url> --dart-define=SUPABASE_PUBLISHABLE_KEY=
  <your-publishable-key>` labelled NOT-verified (`LIVE_PROFILE_SYNC:
  NOT_PERFORMED`).

## Exercise inventory (milestone requirement: ≥1 PRODUCE + ≥1 DEBUG/PREDICT real defect)

| Lesson | Type | Task | Verifiability |
|---|---|---|---|
| L01 | PREDICT | `fromMap` bad-row → defaults; `fromProfile().toUpsertMap()` ×3 | verifiable vs shipped `AppUserData` code + schema tests |
| L02 | **DEBUG** | planted bug: `_withoutDemoProgression(localProfile)` → `localProfile` in `mergeUserProfileForSync` | **REAL defect VERIFIED by running**: `flutter test test/user_profile_sync_merge_test.dart` → exactly 1 red: `'merge normalizes legacy demo progression before first remote upsert'` at `expect(merged.level, 1)` Expected `<1>` Actual `<12>` (line 208); username assert passes — partial-pass trap documented; restored + re-verified 7/7 green |
| L03 | PREDICT | emit-sequence under success/fetch-throw/re-entrant + dispose/Failed-tail scenarios | verifiable by reading `syncUserProfile`/`_emit` code paths; matches shipped impl verbatim |
| L04 | **PRODUCE** | write scratch `test/m25_result_sync_exercise_test.dart` meeting 3 reqs (FakeAsync+started VM; authed seed; `saveCallCount==1`+`syncCallCount==1`+`uid`) | runnable vs production classes + shipped fakes; full solution in `<details>`; mirrors shipped test 1 which lands L05 |
| L05 | PREDICT | per-scenario `saveCallCount`/`syncCallCount`/`uid` ×4 (incl. double `backToMenu` idempotence) + failing-assert map ×3 | verifiable vs shipped group; inner-catch-removal outcome **verified by running** (36/36 still green — outer `_saveGameResult` catch absorbs `StateError`, log changes to `'Failed to save game result: Bad state: network down'`) |

Scratch-exercise convention declared in both lessons: files
`test/m25_*_exercise_test.dart` are run with explicit `flutter test
<path>`, then deleted — the milestone suite contract stays 236/236
senior-parity (exercise files are not part of the shipped test set).

## Senior citations used (all verified vs `main@c8eb860`)

| Lesson | Senior file · symbol |
|---|---|
| L01 | `lib/data/profile/app_user_data.dart` (`AppUserData` 8 fields, `fromMap`, `fromProfile{session,profile}`, `toUpsertMap`, `toProfile`, `_stringValue`/`_nullableStringValue`/`_intValue`); `supabase/student-setup/01-setup-database.sql` (`public.users` 11 cols, `users_auth_uuid_key` unique + `users_auth_uuid_fkey`, CHECKs `users_name_not_blank`/`users_level_range`/`users_*_nonnegative`, `users_set_updated_at` trigger, RLS `users_select_own`/`users_insert_own`/`users_update_own`, `leaderboard` view `security_barrier`); `supabase/student-setup/02-verify-database.sql` (11 required_columns, metadata-only verify) |
| L02 | `lib/data/profile/app_user_data.dart` (`mergeUserProfileForSync` signature + body, `_higherLevelProgressionProfile` `>=` tiebreak, `_maxInt` `>=`, `_nonEmpty`, `_withoutDemoProgression`, `_hasDemoProgression` demo constant `'TÀU HỦ ĐI CHILL'`/lv12/`'1.000.000 VNĐ'`/1M/20/12); `test/user_profile_sync_merge_test.dart` (7 cases verbatim) |
| L03 | `lib/repositories/profile/user_profile_sync_repository.dart` (`UserProfileSyncRepositoryImpl` verbatim: `_isSyncing`, `BehaviorSubject.seeded(ProfileSyncIdle)`, `_fetchRemoteProfile` `from('users').select().eq('auth_uuid').maybeSingle()`, `_upsertRemoteProfile` `upsert(toUpsertMap(), onConflict:'auth_uuid')` + `[sync]` debugPrint, `_emit` isClosed+value-equality, catch→Failed+rethrow, finally; `UserProfileSyncRepositoryDisabled` same-file); `user_profile_sync_repository_contract.dart` unchanged seam |
| L04 | `lib/main.dart` (`supabaseClient == null ? UserProfileSyncRepositoryDisabled() : UserProfileSyncRepositoryImpl(client, userProfileRepository)`); `lib/view_models/game/bridge/game_screen_view_model_result_persistence.dart` (`_syncSavedGameResult` verbatim incl. 4 debugPrints); `lib/view_models/game/game_screen_view_model.dart` ctor order `profile→auth→sync→{questions}`; `lib/screens/game_screen.dart` `create:` + `context.read` ×2 |
| L05 | `test/widgets/game_screen_result_flow_test.dart` (senior asserts `syncCallCount == 1` after authenticated result save — learner port to VM level via `startedVm`+`FakeAsync`); `test/user_profile_sync_merge_test.dart` + `user_profile_sync_schema_test.dart` (9 verbatim ports); SQL 01+02 byte-identical |

## Remote-runtime honesty (hard requirement)

Every lesson states the mandatory path is deterministic
merge/schema/call-path tests; **`LIVE_PROFILE_SYNC:
NOT_PERFORMED`** appears verbatim in L01 (caution box), L05
(caution box — full OPTIONAL live-run recipe with `<your-…>`
placeholders only), and index.md (note + deferred table + synthesis).
No real URL/key/token anywhere — only synthetic fixture literals
already present in the codebase (`'user-1'`, `'user-2'`,
`'https://example.com/avatar.png'`, `'PLAYER'`, `'LOCAL PLAYER'`,
`'REMOTE PLAYER'`, `'SESSION PLAYER'`, `'network down'`).
`02-verify-database.sql` taught as byte-identical port + what it
checks — never claimed executed in this environment. RLS own-row
policies cited as the server-side write boundary (B-01) — client
code is not the security boundary.

## Declared deviations from template

- Lessons carry the Template-V2 spine (Mục tiêu → Bạn-đang-ở-đâu →
  Vì-sao → Bạn-đã-biết-gì → Mental-model → construct table → Ví dụ
  độc lập → Android bridge → Senior connection → Build steps →
  Hiểu code → Chạy-và-quan-sát → Thử nghiệm → Lỗi-hay-gặp →
  Tự-làm → Kiểm-tra-hiểu-biết → Ta-cố-ý-chưa-thêm → Checkpoint).
  All five lessons carry **all** spine sections — no merges needed
  this milestone (unlike M24's two declared folds).
- `app_user_data.dart` lands in **two versions**: L01 ships
  `AppUserData` + 3 private parsers (all referenced → analyze
  clean), L02 appends `mergeUserProfileForSync` + 5 helpers (helpers
  arrive with their sole consumer → no `unused_element` warnings).
  Declared explicitly in L01 "Ta cố ý chưa thêm" + build step —
  same file-versioning pattern as M24 barrel/VM two-steps.
- Index file named `index.md` (matches M21–M24 lessons convention +
  `web/src/content/docs/mNN/index.md` site slot; the task brief
  said "00-index.md" — `index.md` chosen for format parity).
- L03 is +0 coverage by design (impl can't be unit-tested without
  a concrete `SupabaseClient`; senior itself has no repo-level
  test) — stated honestly in-lesson rather than inventing a fake
  the codebase doesn't have; call-path coverage lands L05 like
  M24's seam→coverage deferral.
- L05 exercise is PREDICT (not DEBUG) because the milestone's one
  required DEBUG landed in L02 (verified); L05's failing-assert map
  includes one non-obvious verified outcome (inner-catch removal →
  zero red tests, log lies) — labelled with the verification note.
- Learner has no `bridge/`/`part` structure for game VM —
  `_syncSavedGameResult` taught as "senior extension logic, inline
  in the VM" (declared divergence, consistent with impl ledger).
- Scratch exercise file (`test/m25_result_sync_exercise_test.dart`)
  explicitly deleted after running — keeps the 236/236
  senior-parity suite count honest.

## Verification before handoff

- Every quoted symbol grep-verified against learner source:
  `AppUserData` 8 fields + 4 members + 3 parsers
  (`data/profile/app_user_data.dart`), `mergeUserProfileForSync` +
  `_higherLevelProgressionProfile`/`_maxInt`/`_nonEmpty`/
  `_withoutDemoProgression`/`_hasDemoProgression` + demo constant,
  `UserProfileSyncRepositoryImpl` (`repositories/profile/
  user_profile_sync_repository.dart`: `_isSyncing`, seeded subject,
  `_fetchRemoteProfile`, `_upsertRemoteProfile` `onConflict:
  'auth_uuid'`, `[sync]` print, `_emit` isClosed+dedupe, catch→
  Failed+rethrow→finally), `UserProfileSyncRepositoryDisabled`
  same-file, `main.dart` ternary (lines 82–88), game VM ctor
  profile→auth→sync + `_syncSavedGameResult` 3-branch + prints
  (lines ~646–666), `game_screen.dart` `create:` `context.read`
  (lines 51–55), `startedVm`/`pumpGameScreen` optional
  `{authRepo, syncRepo}`, shipped group `result profile sync
  (M25, FR-36)` 3 tests (lines 836–914), contract doc + scope doc
  + state doc updated comments, `FakeUserProfileSyncRepository`
  (`syncCallCount`/`lastSyncedSession`/`syncError`),
  `FakeAuthRepository(initialSession:)`.
- Senior symbols verified read-only: `UserProfileSyncRepositoryImpl`
  + `UserProfileSyncRepositoryDisabled` one-file (lines 16–123),
  `_syncSavedGameResult` bridge (lines 33–48), `public.users` DDL +
  RLS policies, `02-verify-database.sql` `required_columns` list.
- Planted-bug verification performed on the real learner codebase:
  (1) `_withoutDemoProgression` removal → `flutter test
  test/user_profile_sync_merge_test.dart` → 1 red at line 208
  (`Expected: <1>, Actual: <12>`) → restored → 7/7 green;
  (2) `_syncSavedGameResult` inner-try/catch removal →
  `flutter test test/game_screen_view_model_test.dart` → 36/36
  green (outer catch absorbs; log message changes) → restored →
  `flutter test` 236/236 + `flutter analyze` clean confirmed
  post-restore.
- Test-count arithmetic re-derived: 224 + 2 + 7 + 0 + 0 + 3 = 236
  ✓ matches `02-implementation.md` + `03-implementation-qa.md`.
- No `dart test` anywhere — all suites `flutter_test`/`flutter
  test`; `flutter analyze` referenced, never `dart analyze`.
- No ARB/gen-l10n step needed — M25 adds zero localization keys.
