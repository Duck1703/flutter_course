# M14 — Content QA (Argus)

Milestone: M14 — Repository contracts & rxdart BehaviorSubject
Reviewer: Argus · Date: 2026-10-02 · Revision: r1
Under review: `04-content-draft.md` r1 + `lessons/` (index + 4 files)
Independence: sequential role simulation — re-read on disk, claims
checked against learner source + senior source, not against the
author's intent.

## Verdict: PASS

## Per-lesson verification

### index.md
- Lesson table, concept list, completion criteria all match the real
  file set and VM/scope/main shapes. Deferred-list is accurate
  (M15 sealed, M16 settings UI, M18 onboarding, M19 game VM/nav).

### 01 — ProfileStore chưa đủ
- `abstract interface class` / `implements` explanation correct:
  interface = signature-only, `implements` ≠ `extends` (no code
  inheritance). Verified against Dart semantics and the on-disk
  contract.
- `Impl._` private ctor + `static Future create()` snippet matches
  `user_profile_repository.dart` verbatim.
- `loadUserProfile` snippet (three fallback branches) verbatim.
- Explicit deletion instruction for `profile_store.dart` +
  `profile_store_test.dart` present — satisfies no-hidden-deletion
  rule. Reset semantics (write-default, not key removal) stated
  correctly.
- Repository-not-dogma framing present ("cách *project này* chia
  ranh giới") — matches pedagogy contract.

### 02 — BehaviorSubject & ValueStream
- `rxdart: ^0.28.0` — matches senior pubspec and learner pubspec.
- `.seeded`, `.value`, replay-on-late-subscribe, `isClosed` +
  `value !=` emit guard, `dispose() => close()` — all match the impl
  on disk and senior semantics.
- `ValueStream` as the read face (subject stays private) — correct;
  mirrors senior getter.
- Kotlin bridge uses SIMILARITY/DIFFERENCE/DO-NOT-ASSUME; does NOT
  claim `BehaviorSubject == StateFlow`. The two explicit differences
  (manual close; `.value` only on value streams) are accurate.
- Replay test snippet matches `user_profile_repository_test.dart`.
- Advanced operators (`switchMap`/`Retry`) excluded — named as
  deliberately absent per roadmap.

### 03 — Ba repository & MultiProvider
- Three-repo table accurate: streams, seeds, keys, consumers
  (settings→M16, onboarding→M18) — matches code + roadmap.
- `hapticEnabled` absent→`true` fallback claim verified in
  `user_settings_data.dart` (senior-identical behavior).
- FR-26 (`languageCode` non-empty-only guard → M17) disclosed.
- `MultiProvider` + contract-keyed `Provider<Contract>.value` snippet
  verbatim from `app_dependency_scope.dart`; "8 entries senior / 3
  learner" framing accurate.
- `main()` order (3×`create()` + `loadUserSettings()` before runApp,
  profile NOT preloaded — VM owns it) verified against senior main +
  learner main.
- FR-19 content: `totalEarnings`/`totalQuestionCount` as stored
  fields, `totalEarningsDisplay` getter retirement, `?avatarUrl`
  null-aware element, `_moneyFromDisplay` recovery, legacy-demo
  purge — all verified in `user_profile_data.dart`.
- `FakeUserProfileRepository` snippet matches `test/helpers/` file;
  senior fake reference (`FakeGameProfileRepository` in
  `game_screen_test_helpers.dart`) verified to exist.
- FR-01 residual (`expForNextLevel` → M22) flagged.

### 04 — MenuViewModel nối vào stream
- Ctor snippet (`required UserProfileRepository`, `.value` in
  initializer list, `listen` in body) verbatim from disk.
- `_handleUserProfile` (`_isDisposed` + compare-before-notify) and
  dispose order (cancel → close → super) verified verbatim.
- `applyGameResult`/`resetProfile` "writer no longer sets state" —
  verified; stream is single source of truth. FR-04 partial-
  convergence nuance stated correctly.
- State-vs-event table is accurate: BehaviorSubject/ValueStream
  replay vs broadcast no-buffer; who subscribes where — all correct.
- Retirement list (enum, `load()`, `loadState`, `_setLoadState`,
  `_MenuLoading`, `_MenuErrorState`, build switch) verified — nothing
  remains in `lib/` except doc references.
- `..loadUserProfile()` cascade + `userData`/`totalEarnings` renames
  verified in `menu_screen.dart`.
- Test snippets match real tests (`pumpEventQueue`, double-pump
  comments) — including the honest microtask-flush note.
- Deferred items named (sealed→M15, settings→M16, auth dep→M24).

## Cross-checks

- No false runtime claims: lessons describe verified static behavior
  and test assertions, not invented observations.
- No premature-concept teaching (no sealed/di framework/auth code).
- Older-milestone lessons remain consistent: M10–M13 lessons teach
  the state built at those milestones; M14 lessons carry the
  retirement notices (same convention as Step-10 remediation).
- Vietnamese, beginner-first tone consistent; all first appearances
  explained.

## Findings

None blocking. Non-blocking note: `index.md` and lesson 4 assert
"69 tests" context indirectly via evidence; lesson bodies avoid
hardcoding the count — good (counts drift).

## Required re-checks for approval

None. Recommend Atlas `CONTENT_APPROVED`.
