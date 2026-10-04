# M14 — Milestone Brief (Atlas)

Milestone: **M14 — Repository contracts & rxdart BehaviorSubject**
Issued by: Atlas · Date: 2026-10-02 · Revision: r1
State after issue: `BRIEF_READY`

---

## 1. Objective (from roadmap, verified on disk)

`MILESTONE_ROADMAP.md` §M14 (lines 788–860): the learner crosses from
concrete local persistence + the temporary menu-loading abstraction
into the senior repository/stream foundation. Deliverables:

- `abstract interface class` contracts for three repositories;
- `ValueStream<T>` state exposed via `BehaviorSubject.seeded`;
- SharedPreferences-backed implementations (contract + impl in one
  file, senior layout);
- VMs consuming `.value` + `.stream`;
- `Fake*` repositories enabling UI-free VM tests;
- menu profile state driven by the repository stream — a save from
  any writer propagates to the UI with no manual reload.

## 2. Architecture transition

**Before (M13 state):**

```text
MenuViewModel ──► concrete ProfileStore ──► manual load()/save()
                       │                        │
                  MenuLoadState enum      notifyListeners
                  (loading/ready/failed)
```

**After (senior-aligned):**

```text
SharedPreferences ──► UserProfileRepositoryImpl ──► BehaviorSubject.seeded
        ▲                                                  │ ValueStream
        └──────────── saveUserProfile ◄── writes ──► MenuViewModel
                                ctor: .value + .listen(handler)
                                handler → notifyListeners → UI
```

## 3. Learner file scope (allow-list)

### NEW files

| File | Content |
|---|---|
| `lib/repositories/profile/user_profile_repository.dart` | `abstract interface class UserProfileRepository` + `UserProfileRepositoryImpl` — one file, senior layout |
| `lib/data/settings/user_settings_data.dart` | `UserSettingsData` model (7 senior fields) |
| `lib/repositories/settings/user_settings_repository.dart` | contract + `UserSettingsRepositoryImpl` |
| `lib/repositories/onboarding/onboarding_repository.dart` | contract + `OnboardingRepositoryImpl` |
| `test/helpers/fake_user_profile_repository.dart` | `implements` contract, own `BehaviorSubject.seeded` |
| `test/helpers/fake_user_settings_repository.dart` | same pattern |
| `test/helpers/fake_onboarding_repository.dart` | same pattern |
| `test/user_profile_repository_test.dart` | replaces `profile_store_test.dart` |
| `test/user_settings_repository_test.dart` | basic impl coverage |
| `test/onboarding_repository_test.dart` | basic impl coverage |

### MODIFIED files

| File | Change |
|---|---|
| `pubspec.yaml` | add `rxdart: ^0.28.0` (senior version, verified in senior `pubspec.yaml`) |
| `lib/data/profile/user_profile_data.dart` | FR-19: +`totalEarnings` (String, `'0 VNĐ'`), +`totalQuestionCount` (0); senior `defaultX` constants; deepened `fromMap` (non-empty strings, non-negative ints, `_nullableStringValue`, `_moneyFromDisplay`, `_isLegacyDemoProfile` purge); `toMap` writes all senior fields + `?avatarUrl` omission; `formatVnd` static; `applyGameResult` writes the two new fields; `totalEarningsDisplay` getter removed (field replaces it). `expForNextLevel`/`expPercent`/`winRateDisplay`/`gainExp` retained (FR-01/FR-02 → M22) |
| `lib/view_models/menu/menu_view_model.dart` | ctor takes `UserProfileRepository` contract; `_userData` seeded from `.value`; ctor subscribes to `userProfileStream`; `load()` → `loadUserProfile()` (delegates to repo); `MenuLoadState`/`loadState`/`setLoadState` removed; `applyGameResult`/`resetProfile` write via repo — state propagates through stream handler; `_isDisposed` + subscription cancel + `_events.close()` in dispose; getter `profile`→`userData` |
| `lib/screens/menu_screen.dart` | create: `context.read<UserProfileRepository>()` + `..loadUserProfile()`; remove `switch(loadState)` — render content directly; delete `_MenuLoading`/`_MenuErrorState`; `profile.` refs → `userData.`; `totalEarningsDisplay` → `totalEarnings` |
| `lib/core/app_dependency_scope.dart` | `MultiProvider` with three `Provider<Contract>.value` entries |
| `lib/main.dart` | `await XxxRepositoryImpl.create()` ×3; `await userSettingsRepository.loadUserSettings()` (senior-parity bootstrap); scope ctor args updated |
| `test/menu_view_model_test.dart` | rewritten against contract + fake; stream-driven assertions |
| `test/menu_provider_scope_test.dart` | scope signature; `loadState` assertion removed |
| `test/menu_ui_events_test.dart` | scope signature |
| `test/widgets/game_screen_test.dart` | scope signature (`menuApp()` helper) |
| `test/user_profile_data_test.dart` | new fields/parse-depth/omit-avatar assertions |

### DELETED files (explicit — lessons must instruct the deletion)

| File | Reason |
|---|---|
| `lib/data/profile/profile_store.dart` | FR-09 — absorbed by `UserProfileRepositoryImpl`; no hidden deletion |
| `test/profile_store_test.dart` | superseded by `user_profile_repository_test.dart` |

### FORBIDDEN — do not touch

`lib/screens/game_screen.dart`, `lib/view_models/menu/menu_ui_event.dart`
(event hierarchy stays plain — sealed = M15, FR-15), everything under
`lib/data/game/`, `lib/core/menu_tokens.dart`, `quiz_questions_test.dart`
and any file outside the allow-list. No edits inside
`flutter-accelerator-ai` (read-only).

## 4. Senior source evidence (inspected 2026-10-02, `main` @ `c8eb860`)

| Senior file | Symbols / semantics to mirror |
|---|---|
| `repositories/profile/user_profile_repository.dart` | `abstract interface class UserProfileRepository` {`ValueStream<UserProfileData> get userProfileStream`, `loadUserProfile()`, `saveUserProfile()`, `resetUserProfile()`, `dispose()`}; impl: private `._(SharedPreferences)` ctor + `static Future<Impl> create()`; `BehaviorSubject.seeded(const UserProfileData())`; `userProfileStream => _subject.stream`; `_emit` guards `isClosed` + `value !=`; `resetUserProfile()` → `saveUserProfile(const UserProfileData())`; `dispose()` → `_subject.close()`; key `user_profile`, JSON codec |
| `repositories/settings/user_settings_repository.dart` | same shape; `ValueStream<UserSettingsData>`; key `user_settings` |
| `repositories/onboarding/onboarding_repository.dart` | `ValueStream<bool> get onboardingCompletedStream`; `BehaviorSubject<bool>.seeded(false)`; key `onboarding_completed`; `setOnboardingCompleted(bool)` |
| `data/profile/user_profile_data.dart` | field set + `defaultUsername='0XFF'`, `defaultTotalEarnings='0 VNĐ'`; `_stringValue`/`_intValue`/`_nullableStringValue`/`_moneyFromDisplay`/`_isLegacyDemoProfile`; `toMap` `?avatarUrl`; `formatVnd` |
| `view_models/menu/menu_screen_view_model.dart` | ctor: `_userData = repo.userProfileStream.value`; `_subscription = repo.userProfileStream.listen(_handleUserProfile)`; `_isDisposed` guard; dispose: cancel + `_events.close()` + `super.dispose()`; `loadUserProfile()` delegates |
| `screens/menu_screen.dart` | `ChangeNotifierProvider(create: (_) => MenuScreenViewModel(...)..loadUserProfile())`; no loading/error surface |
| `core/app_dependency_scope.dart` + `main.dart` | `MultiProvider` of `Provider<Contract>.value`; `await Impl.create()`; `await userSettingsRepository.loadUserSettings()` before runApp |
| `test/helpers/fake_user_profile_repository.dart` | `implements` contract; own `BehaviorSubject.seeded`; `loadUserProfile` returns `.value`; `dispose()` closes |
| `view_models/game/bridge/game_screen_view_model_result_persistence.dart` | senior result write: `totalEarnings: formatVnd(nextMoneyWon)`, `totalMoneyWon`, `totalQuestionCount += questionCount` — learner keeps its flat reward policy (FR-03→M19/M22) but now writes all three fields |

## 5. Implementation directives (Flux)

1. `pubspec.yaml`: `rxdart: ^0.28.0` under `dependencies:` then
   `flutter pub get`.
2. Repositories: mirror the senior files' shape exactly — private
   `._(SharedPreferences)` ctor + `static Future<Impl> create()`
   (create calls `SharedPreferences.getInstance()` — tests therefore
   seed via `SharedPreferences.setMockInitialValues` + `create()`).
   `dispose()` returns `Future<void>` (senior signature) and closes
   the subject.
3. `UserSettingsData`: all 7 senior fields. `languageCode` guard:
   non-empty string only — the supported-language whitelist
   (`SupportedLanguageData`) is M17 localization vocabulary. Register
   as FR-26 `ACTIVE_TEMPORARY` → M17.
4. `UserProfileData`: adopt senior field order with `expForNextLevel`
   retained after `currentExp` (learner-only, FR-01). Apply senior
   parse helpers verbatim shape. `toMap` now omits `avatarUrl` when
   null (`?avatarUrl` null-aware element — Dart 3.8+, SDK ≥3.11 ok).
   `applyGameResult` keeps flat reward + count-based EXP (FR-02/FR-03)
   and additionally writes `totalEarnings`/`totalQuestionCount`.
5. `MenuViewModel`: rename `profile`→`userData`; ctor subscription
   before any other work; `applyGameResult`/`resetProfile` no longer
   call `notifyListeners()` directly for profile changes — the stream
   handler owns state transitions (compare-before-notify stays in the
   handler). `resetProfile` still emits `MenuSnackBarRequested`
   (FR-12 → M24) and the reset button stays (FR-11 → M24).
6. `menu_screen.dart`: build renders the profile content
   unconditionally — the seeded subject guarantees a value. Delete
   `_MenuLoading`, `_MenuErrorState`, the `loadState` switch, and the
   FD-06 comment. Update stale doc references.
7. `AppDependencyScope`: `MultiProvider` — explain in a doc comment
   that this is senior's exact mechanism (`Provider<Contract>.value`
   keyed by the interface type, not the impl).
8. `main()`: create the three repos; call
   `await userSettingsRepository.loadUserSettings()` before `runApp`
   (senior does this so settings state is real before first build;
   learner records same call — onboarding load is NOT called, the M18
   gate will own it; senior doesn't call it in main either).
9. Ownership comment: `Provider.value` does not dispose the repos —
   `main()` owns them for the app's lifetime (same as senior).

## 6. §5b — SENIOR FIDELITY CHECK (mandatory)

- **Senior source target:** the repository/stream layer —
  `UserProfileRepository`, `UserSettingsRepository`,
  `OnboardingRepository` contracts + SharedPreferences impls +
  `MenuScreenViewModel`'s stream subscription + `AppDependencyScope`
  MultiProvider wiring + `UserProfileData` full field set.
- **Senior files:** `repositories/{profile,settings,onboarding}/*.dart`,
  `data/profile/user_profile_data.dart`,
  `data/settings/user_settings_data.dart`,
  `view_models/menu/menu_screen_view_model.dart`,
  `core/app_dependency_scope.dart`, `main.dart`,
  `test/helpers/fake_*.dart`, `pubspec.yaml`.
- **Senior symbols:** `abstract interface class`, `implements`,
  `BehaviorSubject.seeded`, `ValueStream`, `.value`, `isClosed`,
  `loadUserProfile`/`saveUserProfile`/`resetUserProfile`/`dispose`,
  `MultiProvider`, `Provider<T>.value` keyed by contract type.
- **Current learner form:** concrete `ProfileStore` (no contract),
  `MenuLoadState{loading,ready,failed}` + manual `load()` +
  `_MenuLoading`/`_MenuErrorState`, 8-field `UserProfileData` missing
  `totalEarnings`/`totalQuestionCount`, shallow `fromMap`, single
  `Provider<ProfileStore>.value` scope.
- **Current deviations:** FR-08, FR-09, FR-19 (all `ACTIVE_TEMPORARY`,
  `Converges at: M14`).
- **Register entries expected to CLOSE:** FR-08 → `CONVERGED`;
  FR-09 → `CONVERGED`; FR-19 → `CONVERGED` (field set + parse depth —
  residual `expForNextLevel` stays tracked under FR-01 → M22, and the
  additive display helpers `expPercent`/`winRateDisplay` are noted in
  the closure text, `expPercent` converging with FR-01 at M22).
- **Register entries that remain ACTIVE:** FR-01, FR-02, FR-03, FR-04
  (menu VM still applies `GameResult` — stream propagation now real,
  VM-side game save → M19/M22), FR-05, FR-06, FR-07, FR-10, FR-11,
  FR-12, FR-13, FR-14, FR-15 (sealed events → M15), FR-16, FR-17,
  FR-18. FR-25 stays as documented senior-source concern.
- **New register entries opened:** **FR-26** —
  `UserSettingsData.languageCode` guarded by non-empty check only;
  senior whitelists via `SupportedLanguageData.isSupportedCode`;
  converges **M17** when localization lands.
- **Permitted teaching simplifications:** learner `applyGameResult`
  keeps flat money/count EXP (FR-02/FR-03 — unchanged scope);
  `expForNextLevel` retained (FR-01); settings/onboarding repos ship
  without consumers (consumers land M16/M18 — roadmap-explicit);
  fakes are handwritten (no mockito — senior uses handwritten fakes).
- **Forbidden alternatives (explicit):** Riverpod/Bloc/Cubit/GetX/
  get_it/MobX/custom event bus/"service layer"/Clean-Architecture
  layers absent from senior; a different stream library; stream
  libraries other than rxdart; sealed UI state (M15); settings UI
  (M16); localization (M17); onboarding UI/flow (M18); GameViewModel /
  DRE / nav controller (M19); dialogs layer (M21); LevelConfig
  integration (M22); leaderboard dialog (M23); auth/sign-out (M24);
  Supabase; notifications; `Retry`/`switchMap` and other advanced
  RxDart operators (roadmap-excluded); deleting the reset button or
  its snackbar event (M24 owns that).

## 7. Test plan (Flux)

- `user_profile_repository_test.dart`: seeded `.value` == defaults;
  `loadUserProfile` round-trip from seeded prefs; `saveUserProfile`
  writes disk + emits on stream + updates `.value`; repeated identical
  save emits nothing (equality guard); `resetUserProfile` writes
  default (key present, default payload — FR-24 semantics preserved);
  late subscriber receives current value (BehaviorSubject replay);
  `dispose` → `isClosed`.
- `user_settings_repository_test.dart` /
  `onboarding_repository_test.dart`: seeded defaults, save/set→stream,
  load round-trip, dispose.
- `menu_view_model_test.dart`: ctor seeds `userData` from fake repo
  `.value`; fake repo save → VM notifies + `userData` updates;
  `loadUserProfile` delegation; `applyGameResult` persists through the
  real impl (disk check) and updates via stream (1 notify);
  `resetProfile` → stream-driven reset + snackbar event; M13 event
  tests unchanged (broadcast semantics preserved); dispose cancels
  subscription (no notify after dispose).
- Widget tests: scope ctor updated; menu renders profile immediately
  after first pump (no loading phase); a repo save during the test
  updates rendered profile (stream propagation proof); existing event
  flow tests unchanged.
- `user_profile_data_test.dart`: round-trip incl. new fields; defaults
  `'0XFF'`/`'0 VNĐ'`/zeros; negative ints → defaults; empty strings →
  defaults; `_moneyFromDisplay` recovery; legacy-demo purge;
  `avatarUrl` key omitted when null; `applyGameResult` writes
  `totalEarnings`+`totalQuestionCount`.
- Expected test-count change: `profile_store_test.dart` (tests move
  to repo test) + new files; net count may rise modestly — record the
  real number, don't target one.

## 8. Lesson decomposition (Lumen)

`web/src/content/docs/m14/` — index + 4 lessons (Vietnamese):

1. `01` — Why `ProfileStore` isn't enough: storage primitive vs
   application boundary; repository contract concept ("in THIS senior
   project, the boundary exists because…"); `abstract interface class`
   + `implements` taught at first use (Kotlin-analogy allowed per
   roadmap bridge rules — SIMILARITY/DIFFERENCE/DO-NOT-ASSUME);
   explicit instruction to delete `profile_store.dart` (no hidden
   deletion) and what moved into `UserProfileRepositoryImpl`.
2. `02` — RxDart: `rxdart: ^0.28.0`; `BehaviorSubject` vs Dart SDK
   `StreamController.broadcast`; `.seeded`; `ValueStream`; `.value` vs
   `.stream`; replay semantics; `isClosed`; why senior chose it;
   Kotlin `MutableStateFlow` analogy with the mandated caveats
   (not the same type; manual close; `.value` exists only on value
   streams). Repository lifecycle + `dispose()`.
3. `03` — The three repositories + `AppDependencyScope`→`MultiProvider`;
   contract-typed `Provider<T>.value`; bootstrap `create()` +
   `loadUserSettings()`; why settings loads at startup and profile
   loads via the VM (senior truth); `FakeUserProfileRepository` and
   contract-first testing; `UserProfileData` parity work (new fields,
   defensive parsing, `?avatarUrl`, `totalEarningsDisplay`→field).
4. `04` — `MenuViewModel` transition: ctor `.value` seed + `listen`;
   state stream vs M13 event stream (occurrence vs latest value —
   explicit contrast, do NOT teach "everything is just a Stream");
   retirement of `MenuLoadState`/`load()`/`_MenuLoading`/
   `_MenuErrorState` with the senior justification (seeded subject
   guarantees a value); widget update for stream propagation;
   register truth: FR-08/FR-09 closed, FR-26 opened, `expForNextLevel`
   still temporary → M22.

## 9. Verification gates

- Flux: `flutter pub get`, `flutter analyze`, `flutter test`,
  `flutter build web` — paste real output in `02`.
- Argus impl QA: senior-shape verification vs disk; FR-08/09/19
  closure evidence; FR-26 registered; no M15+ leakage; tests real.
- Lumen/Forge per contract; Argus site QA runs `npm run build`.
- M15 must not be started; no `web/src/content/docs/m15/`, no sealed
  event/state refactor, no settings/onboarding UI.

## 10. Exit criteria for this brief

Atlas re-reads this brief plus the Flux evidence before approving.
Approval requires Argus `03-implementation-qa.md` = PASS first.
