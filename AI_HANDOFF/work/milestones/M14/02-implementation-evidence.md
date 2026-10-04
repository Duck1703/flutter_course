# M14 — Implementation Evidence (Flux)

Milestone: M14 — Repository contracts & rxdart BehaviorSubject
Author: Flux · Date: 2026-10-02 · Revision: r1
Brief: `01-brief.md` r1 (Atlas) — allow-list honored; no out-of-scope
files touched.

---

## 1. What changed

### New files

| File | Content |
|---|---|
| `lib/repositories/profile/user_profile_repository.dart` | `abstract interface class UserProfileRepository` + `UserProfileRepositoryImpl` (senior layout: contract + impl in one file) |
| `lib/data/settings/user_settings_data.dart` | `UserSettingsData` — 7 senior fields, senior defaults, `_boundedInt` hour/minute guards, `hapticEnabled` absent→`true` fallback |
| `lib/repositories/settings/user_settings_repository.dart` | contract + `UserSettingsRepositoryImpl`, key `'user_settings'` |
| `lib/repositories/onboarding/onboarding_repository.dart` | contract + `OnboardingRepositoryImpl`, `ValueStream<bool>` seeded `false`, key `'onboarding_completed'` |
| `test/helpers/fake_user_profile_repository.dart` | `implements` contract, own `BehaviorSubject.seeded`, `saveCallCount`/`loadCallCount` (senior fake pattern) |
| `test/helpers/fake_user_settings_repository.dart` | same pattern |
| `test/helpers/fake_onboarding_repository.dart` | same pattern |
| `test/user_profile_repository_test.dart` | 8 tests — seeded value, load round-trip, save→disk+stream+`.value`, equality guard, reset write-default, late-subscriber replay, dispose guard |
| `test/user_settings_repository_test.dart` | 4 tests |
| `test/onboarding_repository_test.dart` | 4 tests |

### Modified files

| File | Change |
|---|---|
| `pubspec.yaml` | `rxdart: ^0.28.0` — senior version, verified in senior `pubspec.yaml` |
| `lib/data/profile/user_profile_data.dart` | **FR-19**: +`totalEarnings` (String, default `'0 VNĐ'`), +`totalQuestionCount` (0); senior `default*` constants + `_legacyDemo*` constants; `fromMap` deepened: `_stringValue` (non-empty), `_intValue` (≥0), `_nullableStringValue`, `_moneyFromDisplay`, `_isLegacyDemoProfile` purge; `toMap` → `Map<String, Object>` with `?avatarUrl` null-aware element; `formatVnd` added (wraps `formatThousands`); `applyGameResult` now writes `totalEarnings`+`totalQuestionCount` (flat money policy retained — FR-03); `totalEarningsDisplay` getter removed. `expForNextLevel`/`gainExp`/`expPercent`/`winRateDisplay` retained (FR-01/FR-02 → M22) |
| `lib/view_models/menu/menu_view_model.dart` | **FR-08**: `MenuLoadState`/`loadState`/`load()`/`_setLoadState` deleted. Ctor: `required UserProfileRepository` → `_userData = repo.userProfileStream.value` + ctor `listen(_handleUserProfile)` (senior `MenuScreenViewModel` shape). `loadUserProfile()` delegates to repo. `applyGameResult`/`resetProfile` write via repo — state updates flow through `_handleUserProfile` (compare-before-notify). `profile` getter → `userData`. `_isDisposed` guard; dispose cancels subscription + closes `_events` |
| `lib/screens/menu_screen.dart` | `create:` → `context.read<UserProfileRepository>()` + `..loadUserProfile()`; `switch(loadState)` removed — renders profile directly; `_MenuLoading`/`_MenuErrorState` widgets deleted; `viewModel.profile`→`userData`; `totalEarningsDisplay`→`totalEarnings` field |
| `lib/core/app_dependency_scope.dart` | `MultiProvider` + three `Provider<Contract>.value` entries (senior `AppDependencyScope` mechanism) |
| `lib/main.dart` | `await Impl.create()` ×3; `await userSettingsRepository.loadUserSettings()` before `runApp` (senior parity); no profile/onboarding load at bootstrap (senior: profile via VM `..loadUserProfile()`, onboarding unused until M18) |
| `test/menu_view_model_test.dart` | rewritten — fake repo drives VM; stream-propagation + delegate + dispose-cancel assertions; M13 event group unchanged |
| `test/menu_provider_scope_test.dart` | scope 3-repo signature; `loadState` assertion → seeded `userData`; NEW widget tests: immediate render (no loading surface) + repo save mid-test updates UI via stream |
| `test/menu_ui_events_test.dart` | scope signature |
| `test/widgets/game_screen_test.dart` | scope signature |
| `test/user_profile_data_test.dart` | new-field defaults/round-trip, `?avatarUrl` omission, negative-int + empty-string guards, `_moneyFromDisplay` recovery, legacy-demo purge, `applyGameResult` writes new fields |

### Deleted files

| File | Disposition |
|---|---|
| `lib/data/profile/profile_store.dart` | **FR-09** — absorbed by `UserProfileRepositoryImpl` (same key, same JSON codec, same fallback branches). Lessons instruct the deletion explicitly |
| `test/profile_store_test.dart` | superseded by `user_profile_repository_test.dart` |

## 2. Senior correspondence (verified against `main` @ `c8eb860`)

| Learner | Senior | Match |
|---|---|---|
| `abstract interface class UserProfileRepository` | identical | ✅ verbatim member set |
| `BehaviorSubject<UserProfileData>.seeded(const UserProfileData())` | identical | ✅ |
| `userProfileStream => _subject.stream` (`ValueStream`) | identical | ✅ |
| `loadUserProfile` null/FormatException/non-Map → emit defaults | identical | ✅ all three fallback branches |
| `saveUserProfile` → `setString` → `!didSave` throw `StateError` → emit | identical | ✅ |
| `resetUserProfile() => saveUserProfile(const UserProfileData())` | identical | ✅ FR-24 preserved |
| `_emitUserProfile` `isClosed` + `value !=` guard | identical | ✅ |
| `dispose() => _subject.close()` (`Future<void>`) | identical | ✅ |
| `..loadUserProfile()` in provider `create:` | identical | ✅ |
| `MultiProvider` + `Provider<Contract>.value` | identical mechanism | ✅ (3 entries vs senior's 8 — scope = what exists) |
| `await userSettingsRepository.loadUserSettings()` in `main()` | identical | ✅ |
| `FakeUserProfileRepository implements` + own seeded subject | `test/widgets/game_screen_test_helpers.dart` `FakeGameProfileRepository` | ✅ same pattern incl. `saveCallCount` |
| VM `_handleUserProfile` `_isDisposed` + compare-before-notify | senior `MenuScreenViewModel` | ✅ |
| `UserProfileData` fields/defaults/parse helpers/demo-purge/`?avatarUrl`/`formatVnd` | senior model | ✅ + `expForNextLevel` (FR-01 → M22) |

## 3. Register disposition

- **CLOSED — FR-08** `CONVERGED`: `MenuLoadState`, `load()`,
  `_MenuLoading`, `_MenuErrorState` retired; stream-seeded state +
  ctor subscription replaces manual load surface.
- **CLOSED — FR-09** `CONVERGED`: `ProfileStore` deleted; contract +
  impl + `BehaviorSubject`/`ValueStream` per senior.
- **CLOSED — FR-19** `CONVERGED`: senior field set + parse depth
  landed. Residual: `expForNextLevel` stays under **FR-01** → M22;
  additive display getters `expPercent`/`winRateDisplay` remain
  learner-side (`expPercent` converges with FR-01 at M22).
- **OPENED — FR-26** `ACTIVE_TEMPORARY` → **M17**:
  `UserSettingsData.languageCode` guard is non-empty-string only;
  senior whitelists via `SupportedLanguageData.isSupportedCode`
  (localization vocabulary — arrives M17). Reason: pulling
  `SupportedLanguageData` now would import M17 concepts early.
- **Still ACTIVE (untouched, by design):** FR-01–FR-07, FR-10–FR-18,
  FR-25 (documented concern). FR-04 partially improved — the profile
  stream propagation half is now real; the `GameResult` route +
  menu-side apply remain until M19/M22.

## 4. Deviation/premature-concept audit (self-check)

- No sealed UI state / sealed events (M15) — event classes untouched.
- No settings/onboarding UI (M16/M18) — repos exist, no consumers.
- No localization code (M17) — `languageCode` carried as plain field.
- No GameViewModel/DRE/nav-controller/LevelConfig/dialog-layer changes
  (M19–M22). `game_screen.dart` untouched.
- No auth/Supabase/notifications/advanced RxDart (`Retry`/`switchMap`).
- DI keyed on contract type; no service-locator/get_it introduced.

## 5. Verification (real commands, 2026-10-02)

```text
$ flutter pub get
Changed 1 dependency!            (rxdart 0.28.0 resolved)

$ flutter analyze
Analyzing learner-app...
No issues found! (ran in 2.0s)

$ flutter test
00:02 +69: All tests passed!     (was 52 — +17 net: +16 repo/scope
                                 tests incl. new stream-propagation
                                 coverage, −5 store-era tests moved
                                 into repo test, balance from split)

$ flutter build web
√ Built build\web                 (43.0s; pre-existing font-tree-
                                  shake + wasm-dry-run notes only)
```

First-run failures fixed during this pass (honest record):
- 3 tests failed on stream timing — `subject.add` delivers on a later
  microtask; added `pumpEventQueue()`/extra `pump()` before asserts.
- 3 tests + 1 widget test failed on prefs wipe — second
  `setMockInitialValues` resets the mock store; fixed by reusing
  `Impl.create()` without reseeding for "reopen app" scenarios.
- 2 analyze errors — `ValueStream` doesn't expose `isClosed` (it
  lives on the subject); dispose tests now assert the guard's
  observable behavior (post-dispose load returns defaults, no throw).

## 6. Notes for Lumen

- Learner-visible renames: `ProfileStore`→repository,
  `profile`→`userData`, `load()`→`loadUserProfile()`,
  `totalEarningsDisplay` getter→`totalEarnings` field.
- Explicit deletions to instruct: `profile_store.dart` (absorbed),
  `_MenuLoading`/`_MenuErrorState` (retired with FR-08).
- The "no loading screen" behavior is senior truth — seeded subject
  guarantees a value; don't teach it as a defect.
