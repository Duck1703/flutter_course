# M23 CONTENT QA — Supabase bootstrap & Leaderboard

Role: ARGUS | Review: `lessons/` (5 + index) vs `01-brief.md`, Template V2,
learner-app source @ 193/193, senior `main@c8eb860` (read-only, re-verified
`git rev-parse HEAD` = `c8eb860ed9f4dbcda176c8282a9feb4d2d70d1d3`).

Verdict: **PASS_WITH_FINDINGS** — content is accurate, spine-complete, honest,
and secure. Two non-blocking defects: one wrong literal output in a collapsed
answer key (L03), one inaccurate merge-declaration in the draft ledger (L02
Android bridge). Both are fix-in-place items for Lumen; neither misleads a
learner about a construct that exists.

---

## 1. TEMPLATE V2 SPINE — PASS (with ledger inaccuracy, F2)

Per-lesson section audit (headings grepped, cross-checked vs `04-content-draft.md`
§"Declared deviations"):

| Lesson | Spine verdict |
|---|---|
| L01 | **Full spine** — Mục tiêu / Bạn-đang-ở-đâu / Vì-sao / Bạn-đã-biết-gì / Mental-model (×2 declared, ≤3 rule ok: D-40 + awareness B-01/B-02) / construct table / **Ví dụ độc lập** (`String.fromEnvironment` scratch) / **Android bridge** (`BuildConfig` vs dart-define) / **Senior project connection** table / SQL walk (extra, brief-sanctioned selective read) / steps / Hiểu-code / Chạy-và-quan-sát / Thử-nghiệm / Lỗi-hay-gặp (5) / Tự-làm PREDICT / Kiểm-tra (3 Q&A) / Ta-cố-ý-chưa-thêm / Checkpoint ✓ |
| L02 | Spine present EXCEPT named headings `## Android / Compose bridge` and `## Senior project connection` — **see F2/F3**. Construct table, isolated `ScoreRepository` example, steps, all tail sections present. |
| L03 | `Ví dụ độc lập` folded → declared in ledger (isolated example = `FakeLeaderboardRepository` test-layer walk `:218-257`) ✓; bridge omitted → declared ✓; backend construct table present. |
| L04 | `Ví dụ độc lập` present (20-line `Fetcher` guard) ✓; bridge omitted → declared ✓; guest-seam senior code cited read-only. |
| L05 | `Ví dụ độc lập` dropped → declared (applied lesson, all constructs re-uses) ✓; F-32 folded into `LeaderboardList` step → declared ✓ (named at point of use `:216`). |
| Index | Required 4 sections all present: `## Bản đồ bài học` (map table w/ per-lesson checkpoint) / `## Điều milestone này cố ý chưa làm` (deferred table + owner milestones M24/M25/M26/M28/M29) / `## Checkpoint tổng kết` / `## Tổng kết milestone` (5 synthesis Qs). |

`Kiểm tra hiểu biết` is a real 3-Q&A section in every lesson; `Lỗi hay gặp` = 5
items each; every `Tự làm` hides its solution in `<details><summary>Đáp án`.
No scaffold presented as senior behavior; guest-seam divergence marked at
point of use (L02 `:::caution`, L04 dedicated section, register FR-35).

## 2. SYMBOL TRUTH — PASS

~80 quoted symbols/paths grep-verified against learner source; senior-side
citations verified read-only @c8eb860. No fabricated symbol (Step-17 class:
none). Spot record:

- `SupabaseEnvironment` 4 fields + `fromEnvironment` + `isSupabaseConfigured`/`isGoogleConfigured`/`configurationError` + exact error strings — `learner-app/lib/core/supabase_environment.dart:19-72`, senior `:1-51` identical. L01's "isGoogleConfigured chỉ check googleWebClientId" claim exact (`:59`).
- `SupabaseClientService.initialize(env) → SupabaseClient?` w/ `publishableKey:` named arg — `lib/services/supabase_client_service.dart:16-29`. **`SupabaseNotConfigured` taught as NON-EXISTENT (L02:83-86) — senior grep = 0 matches** ✓.
- Contract `loadLeaderboard({String? currentUserId})`, `LeaderboardSnapshot{entries,currentEntry}` — verbatim.
- Query chain `.order('total_money_won',ascending:false).order('rank').limit(10)` + `.eq('auth_uuid',uid).maybeSingle()` — learner `leaderboard_repository.dart:35-59`, senior `:24-48` identical. `_LeaderboardRecord`/`_intValue`/`_stringValue`/`_formatScore`/`entryFromRow @visibleForTesting` all present.
- `LeaderboardEntryData{rank,name,level,score,avatarUrl?,isCurrentUser=false}`, `LeaderboardPopupMessage{empty,loadError,loading}`, 4 variants, `leaderboardEntries`(6), `currentLeaderboardEntry` rank 125 `'Tàu hủ đi chill'` — names/scores byte-equal to senior `:72-130`.
- VM: `_requestId`/`_isDisposed`/`_setState`/`_isLatestRequest`/`_currentLeaderboardUserId()→null`/`_profileBackedCurrentLeaderboardEntry`/`_currentUserLeaderboardEntry`/`_formatScore`/`retry→unawaited`/`refresh→isRefresh:true` — `leaderboard_dialog_view_model.dart:28-172`. L04's code block = source `:46-94` modulo formatting.
- Widgets: `showLeaderboardDialog`, `MenuLeaderboardDialogScope` (2-repo ctor, `ChangeNotifierProvider`), `_LeaderboardDialogBridge` (`_didLoadLeaderboard` + post-frame), `MenuLeaderboardDialog` (`AlertDialog`, key `leaderboard-dialog-shell`, `backgroundBottom`, title `toUpperCase`, `_contentHeight=380`), `LeaderboardPopupBody` exhaustive switch + `_messageText`, `Icons.cloud_off` + `leaderboard-retry-button` + `retryButton.toUpperCase()`, `_TopRowsScrollView` physics ternary + `RefreshIndicator.adaptive`, keys `leaderboard-scrollable-top-rows`/`leaderboard-current-user-row`/`leaderboard-refresh-progress`/`leaderboard-loading-progress`/`menu-leaderboard-entry` — all verified.
- Menu wiring: `MenuLeaderboardRequested` (`menu_screen_ui_event.dart:46`), `requestLeaderboardDialog()` (`menu_view_model.dart:131`), `case MenuLeaderboardRequested(): unawaited(_openLeaderboard())` (`menu_screen.dart:113-117`), `_openLeaderboard→showLeaderboardDialog` (`:154`), `_LeaderboardEntry` `Semantics(button)+GestureDetector(HitTestBehavior.opaque)→requestLeaderboardDialog` (`:508-516`) — L05 code blocks verbatim.
- Senior-side: `MenuDialogLeaderboard` (`menu_dialog_state.dart:19`), `requestLeaderboardDialog` (`menu_screen_view_model.dart:90`), senior `_currentLeaderboardUserId` switch (`:91-96`) quoted verbatim in L04 guest-seam, `AuthSessionAuthenticated`/`AuthSessionGuest`, `avatarAsset`/`rankAsset`/`LeaderboardRowStyle`, `LeaderboardEntryCard` (`leaderboard_entry_card.dart:9`), senior scope `authRepository:` line (`:23`), senior `[auth]` prints (`main.dart:27,34`), `DisabledAuthRepository` (`:43`). All cited as evidence, none as paste-target.
- Test claims: stale test name verbatim `'response STALE không được ghi đè kết quả request mới hơn'` (test `:156`); assertions 'SECOND PLAYER'/'REMOTE PLAYER' real (`:179,192`); fake members `snapshot`/`error`/`completers`/`loadCallCount`/`lastCurrentUserId`; `tester.widget<RefreshIndicator>` + direct `onRefresh()` call (widget test `:129-133`) — the basis of L05's PREDICT answer; `'Hạng 125'`/`'CẤP 12'`/`'0XFF'` assertions real; `localizedTestApp(navigatorKey:)` helper signature real; `users_total_money_won_nonnegative` SQL check real (`01-setup-database.sql:46`).
- ARB values claimed in L05 byte-equal (en+vi, all 6 keys + `@rankSemanticLabel`); `profileLevel` "CẤP {level}"; `leaderboardTitle`/`leaderboardSubtitle`/`settingsGuestSyncHint` pre-existing.
- File-LOC claims (132/161/173/57/181/97/104/181-line SQL) all match.

**F1 (defect, non-blocking):** L03 `03-leaderboard-repository.md:343-345` —
Thử-nghiệm answer claims `entryFromRow({...,'total_money_won': -500})` yields
`entry.score` = `'-500'`. **Actual = `'-.500'`**: `UserProfileData.formatThousands`
(`user_profile_data.dart:204-218`) inserts `'.'` whenever `remaining % 3 == 1`;
for `'-500'` (len 4) index 0 (`'-'`, remaining 4) qualifies → `'-.500'`.
Physically executed: `formatVnd(-500).replaceAll(' VNĐ','')` → `-.500`.
Pedagogical point (mapper doesn't validate domain) is intact — the odd output
is actually a *stronger* illustration — but the literal answer is wrong and a
learner verifying will see a different string. Fix the answer (and the
"formatVnd đã xử lý số âm" hint framing).

## 3. COMMAND TRUTH — PASS

Every command block is a real, env-correct command; zero `dart test` (all
suites are `flutter_test` — verified imports). Record:

- `flutter pub get`, `flutter analyze`, `flutter test`, `flutter test <file>` — re-executed on real learner-app: analyze-equivalent suite `+193: All tests passed!` (this QA run).
- `flutter gen-l10n` — correct (`l10n.yaml` + checked-in `lib/l10n/app_localizations*.dart` contain all 6 getters).
- `flutter build web` — claimed PASS, consistent with impl evidence.
- `dart run --define=FLAVOR=prod --define=API_URL=https://x scratch.dart` — **physically executed**: prints `flavor=prod api="https://x"`; bare run prints `flavor=dev api="<chưa cấu hình>"` — L01's claimed outputs exact.
- dart-define examples: only names + `<your-project-url>`/`<your-publishable-key>` placeholders — zero real values.
- L02 `Thử nghiệm` answer (missing `await` → `Future<SupabaseClient?>` breaks ternary + arg type) — type reasoning verified against `main.dart:53-56`.

## 4. DEBUG EXERCISE — REAL (physically verified)

Protocol: copied `learner-app` → `%TEMP%\m23-content-qa\learner-app`,
`flutter pub get` OK, applied the planted bug **exactly as L04 describes** —
deleted the post-await `if (!_isLatestRequest(requestId)) { return; }` block
(try branch only; catch guard kept), then ran
`flutter test test/view_models/leaderboard/leaderboard_dialog_view_model_test.dart`:

```
+5 -1: response STALE không được ghi đè kết quả request mới hơn [E]
  Expected: 'SECOND PLAYER'
    Actual: 'REMOTE PLAYER'
  test\view_models\leaderboard_dialog_view_model_test.dart 192:5
… final: +8 -1 — exactly ONE failure, other 8 green.
```

Matches the answer key precisely: single-test failure, verbatim test name,
`'REMOTE PLAYER'` overwriting `'SECOND PLAYER'` at the final expect (`:192`),
error test stays green via the retained catch guard.
**DEBUG_BUG_REAL: YES.**

## 5. CHECKPOINT ARITHMETIC — PASS

| Claim | Verified |
|---|---|
| L01 end: 168→171 (+3 env) | `test/core/supabase_environment_test.dart` = exactly 3 `test(` — lesson's code block is verbatim the file ✓ |
| L02 end: 171 (+0, compile-forced) | Exactly 3 call-sites carry `leaderboardRepository: const DisabledLeaderboardRepository()` — `menu_provider_scope_test.dart:33`, `menu_screen_ui_events_test.dart:29`, `widgets/game_screen_test.dart:130` ✓ |
| L03 end: 175 (+4 repo) | `test/repositories/leaderboard_repository_test.dart` = 4 tests (2 disabled + 2 `entryFromRow`) ✓ |
| L04 end: 184 (+9 VM) | `leaderboard_dialog_view_model_test.dart` = 9 tests; all 9 map to L04's description table ✓ |
| L05 end: 193 (+9 = 8 widget + 1 menu-VM) | `menu_leaderboard_dialog_test.dart` = 8 `testWidgets`; `menu_view_model_test.dart:148-161` +1 event test (`events.first` subscribed before `requestLeaderboardDialog()`) ✓ |

168 + 3 + 4 + 9 + 9 = **193 — re-executed this QA run: `+193: All tests passed!`.**
Index arithmetic line (168→+3→+4→+9→+8+1=193) consistent.

## 6. HONESTY — PASS

`LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED` verbatim at L02:35, L05:328,
index:45+62; L03:181 "đường remote vẫn NOT_PERFORMED về live". Mandatory path
= fakes + unconfigured fallback stated in every lesson; L05's configured run
labelled OPTIONAL + environment-dependent with a `:::caution` explicitly saying
it is not a pass condition and values come from the learner's own project.
No implication anywhere that a live backend was verified.

## 7. SECURITY — CLEAN

Grep of all 6 lesson files: **zero** `sbp_`/`eyJ`/`.env` content/real URLs/
passwords/keys. `service-role` appears only in pedagogical prose explaining
the anon-vs-service-role boundary (correct: publishable key is public-by-design,
RLS+grants are the wall — explicitly kills the "hide the key in the client"
misconception at L01:83-102 + Lỗi-hay-gặp #3). `https://x.supabase.co` is a
declared fixture matching the real test file. `flutter_dotenv`/`.env` taught
as never-used (senior doesn't). SQL grants shown correct (`anon, authenticated`
on view only; `revoke` + owner RLS on `users`).

## 8. PEDAGOGY — PASS

Beginner-safe Vietnamese; glossary tables per new construct; Android bridges
where declared. Backend rubric covered across the set: problem (each Vì-sao),
responsibility (contract/DI/VM-vs-UI), data-crossing (row→record→entry, view
column contract, `auth_uuid` masking), failure (error branch, `maybeSingle`
null semantics, stale guard), persisted-vs-remote (SharedPrefs vs Postgres,
profile-vs-remote avatar priority), identity (`auth_uuid`/uid, guest seam),
deterministic-vs-env (fakes/`entryFromRow` seam/compile-time untestability).
M24+ concepts (auth session, `switch(authState)`, sync/upsert, DRE, realtime,
`MenuDialogLayer`) appear ONLY in deferred lists or explicitly-labelled
senior read-only blocks — zero leakage as taught-now content. Isolated
example precedes production in every lesson that carries one.

## 9. REGISTRY EDITS — PASS

- `LEARNER_CONCEPT_REGISTRY.md`: rows **D-40/D-41/D-42** (Dart, NORMAL,
  TAUGHT), **F-31** (LIGHT)/ **F-32** (NORMAL), **A-23/A-24** (NORMAL),
  new **Backend (Supabase)** section +**B-01/B-02** (LIGHT awareness,
  INTRODUCED) — all at `:57-59,95-96,124-125,127-132`; depth classifications
  sane and consistent with ledger.
- `PREREQUISITE_GRAPH.md` `:234-269`: M23 section closed — `D-40/B-01/B-02 →
  M23/01 → A-23/A-24/F-31 → M23/02 → D-41 → M23/03 → D-42 → M23/04 → F-32 →
  M23/05`; every `needs` ID resolves (33/33 exist in registry); forward edges
  to M24/M25/M26/M28/M29 recorded.
- `SENIOR_FIDELITY_REGISTER.md`: FR-14 → **CONVERGED at M23** (mechanics
  accurate, transport FR-29→M29 + visuals→M28 noted) `:38`; new row **FR-35**
  guest seam — ctor lacks `AuthRepository`, `_currentLeaderboardUserId()≡null`
  → M24, ACTIVE_TEMPORARY `:52`.

## 10. FRONTMATTER + LINKS — PASS

All 6 files carry Starlight frontmatter (`title`/`description`/`sidebar.label`
+`order`; index `order: 0` + `Tổng quan M23`) identical in shape to M22.
Internal links `/m23/01-supabase-va-dart-define/` … `/m23/05-dialog-va-menu-row/`
match actual file names.

---

## FINDINGS

- **F1 (minor, fix-in-place):** L03 `03-leaderboard-repository.md:343-345` —
  Thử-nghiệm answer's literal output wrong: claimed `entry.score = '-500'`,
  actual `'-.500'` (`formatThousands` inserts `'.'` after `'-'`; physically
  verified). Concept (no domain validation) intact; the literal is wrong —
  learners verifying get a different string.
- **F2 (minor, ledger):** `04-content-draft.md` §Declared deviations claims
  Android/Compose bridge "present in L02 (sentinel-null + DI selection)" —
  `02-init-co-dieu-kien.md` has **no** bridge heading and zero
  SIMILARITY/DIFFERENCE/DO-NOT-ASSUME content (grep-verified). Either add the
  bridge to L02 or correct the declaration to "omitted L02–L05".
- **F3 (informational):** Named `## Senior project connection` heading absent
  in L02–L05 (present only in L01). Senior citations are pervasive inline and
  verified accurate; identical convention passed in M22 (0/6 headings). Not a
  defect under precedent — optionally declare the merge in the ledger.
- `LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED` recorded honestly — consistent
  with 00-status + impl QA.

## EVIDENCE / COMMANDS RUN (this QA)

- `flutter test` on real `learner-app` → `+193: All tests passed!`
- `%TEMP%\m23-content-qa` copy → planted `_isLatestRequest` removal → 1-fail
  stale test (exact predicted assertion).
- `dart run scratch.dart` + `dart run --define=…` → both claimed outputs
  reproduced; `formatVnd(-500)` → `'-.500'` reproduced.
- Repo-wide greps: symbols, ARB keys, credentials (clean), `SupabaseNotConfigured`
  (0 hits senior), section headings, prerequisite IDs (33/33 resolve).
- Senior `git rev-parse HEAD` = `c8eb860…` (unchanged, read-only).

```
ARGUS_M23_CONTENT_QA: PASS_WITH_FINDINGS
TEMPLATE_V2: PASS
SYMBOL_TRUTH: PASS(+F1: L03 answer '-500'→actual '-.500')
COMMAND_TRUTH: PASS
DEBUG_BUG_REAL: YES(1-fail stale test 'REMOTE PLAYER' vs 'SECOND PLAYER' — verbatim name, other 8 green)
CHECKPOINT_ARITHMETIC: PASS
HONESTY: PASS
SECURITY: CLEAN
REGISTRY_EDITS: PASS
BLOCKERS: none
```

---

## REVERIFY (post-remediation, scoped to F1/F2 only)

- **F1 — RESOLVED.** `03-leaderboard-repository.md:344` answer now reads
  `entry.score == '-.500'` — the exact output `formatThousands` produces for
  `-500` (re-verified: `'-500'` is 4 chars; index 0 `'-'` has
  `remaining == 4`, `4 % 3 == 1` → `'.'` inserted → `'-.500'`). Explanation
  text correctly describes the mechanism (minus counts as a character). Hint
  at `:338-339` nudges toward the mechanism ("dấu trừ cũng là một ký tự")
  without leaking the literal `-.500` — coherent PREDICT framing, answer still
  hidden in `<details>`. `users_total_money_won_nonnegative` citation still
  accurate (`01-setup-database.sql:46`).
- **F2 — RESOLVED.** `02-init-co-dieu-kien.md:138-157` now carries
  `## Android / Compose bridge` in correct template position (after `Ví dụ
  độc lập`, before `Build it step by step`) with proper SIMILARITY /
  IMPORTANT DIFFERENCE / DO NOT ASSUME framing: SIMILARITY = Hilt/Koin
  `@Provides` choosing impl at composition root; DIFFERENCE = hand-rolled
  `main()` composition root + `?:` vs DI framework (true — no DI framework in
  learner app); DO NOT ASSUME correctly *negates* `BuildConfig.FLAVOR`/`isDebug`
  (config is dart-define-only — no fake claim), covers sentinel-null
  (`SupabaseClient?` = `null`, no `Result`/`Either` wrapper — true per
  `supabase_client_service.dart:16-29`). Content matches the ledger's
  declared description "(sentinel-null + DI selection)" — `04-content-draft.md`
  `:149-151` is now accurate as-is; no edit needed.
- **Sanity:** L02 fences balanced (16, even), details 2/2, heading order intact
  (insert at :138, all later sections shifted cleanly); L03 fences balanced
  (18), details 2/2; zero new links introduced; no typos spotted in inserted
  text.

```
ARGUS_M23_CONTENT_REVERIFY: PASS
F1_RESOLVED: YES
F2_RESOLVED: YES
NO_NEW_DEFECTS: YES
```
