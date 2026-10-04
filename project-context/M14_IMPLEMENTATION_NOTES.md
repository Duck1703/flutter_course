# M14 Implementation Notes

Step 11 — Repository contracts & rxdart BehaviorSubject (first
milestone under the permanent G16 gate).
Date: 2026-10-02. Basis: end-of-M13/remediated learner app (52 tests
green). Work area: `AI_HANDOFF/work/milestones/M14/` (full audit
chain, all gates single-cycle PASS).

## What was built

| File | Change |
|------|--------|
| `pubspec.yaml` | + `rxdart: ^0.28.0` (senior version) |
| `lib/repositories/profile/user_profile_repository.dart` | NEW — `abstract interface class UserProfileRepository` + `UserProfileRepositoryImpl`: `BehaviorSubject.seeded(const UserProfileData())`, `ValueStream` getter, `loadUserProfile` (3 fallback branches), `saveUserProfile` (didSave throw + emit), `resetUserProfile` = save-default, `_emitUserProfile` (`isClosed` + `value !=` guards), `dispose()` → close |
| `lib/data/settings/user_settings_data.dart` | NEW — 7 senior fields/defaults; `_boundedInt` hour/minute; `hapticEnabled` absent→`true`; `languageCode` non-empty guard (FR-26 → M17 whitelist) |
| `lib/repositories/settings/user_settings_repository.dart` | NEW — same shape, key `'user_settings'` |
| `lib/repositories/onboarding/onboarding_repository.dart` | NEW — `ValueStream<bool>` seeded `false`, key `'onboarding_completed'`; no consumer until M18 |
| `lib/data/profile/user_profile_data.dart` | FR-19: +`totalEarnings`/`totalQuestionCount`; `default*` constants; `_stringValue`/`_intValue`(≥0)/`_nullableStringValue`/`_moneyFromDisplay`/`_isLegacyDemoProfile`; `toMap` → `Map<String, Object>` with `?avatarUrl`; `formatVnd`; `applyGameResult` writes new fields; `totalEarningsDisplay` removed |
| `lib/view_models/menu/menu_view_model.dart` | FR-08: `MenuLoadState`/`load()`/`loadState`/`_setLoadState` removed; ctor `required UserProfileRepository`, `_userData = stream.value` + ctor `listen(_handleUserProfile)`; `loadUserProfile()` delegates; writers save via repo (stream owns state); `_isDisposed` + cancel + close in dispose; `profile`→`userData` |
| `lib/screens/menu_screen.dart` | `context.read<UserProfileRepository>()` + `..loadUserProfile()`; direct content render; `_MenuLoading`/`_MenuErrorState` deleted; `userData`/`totalEarnings` renames applied |
| `lib/core/app_dependency_scope.dart` | `MultiProvider` + 3 `Provider<Contract>.value` |
| `lib/main.dart` | 3×`await Impl.create()` + `await loadUserSettings()` before `runApp` |
| `lib/data/profile/profile_store.dart` | **DELETED** — absorbed by impl (same key/codec/fallbacks) |
| `test/helpers/fake_{user_profile,user_settings,onboarding}_repository.dart` | NEW — `implements` contract + own seeded subjects + call counters (senior fake pattern) |
| `test/user_profile_repository_test.dart` | NEW — 8 tests incl. `.value` seed, disk round-trip, save→stream, guard-no-emit, reset write-default, late-subscriber replay, dispose guard |
| `test/user_settings_repository_test.dart` / `test/onboarding_repository_test.dart` | NEW — 4 + 4 tests |
| `test/profile_store_test.dart` | DELETED — superseded |
| `test/menu_view_model_test.dart` | rewritten — fake repo drives VM; stream propagation; delegate + dispose-cancel |
| `test/menu_provider_scope_test.dart` | 3-repo scope; +immediate-render (no loading surface) + mid-test repo save → UI update |
| `test/menu_ui_events_test.dart`, `test/widgets/game_screen_test.dart` | scope signature updated |
| `test/user_profile_data_test.dart` | new-field round-trip, `?avatarUrl` omission, ≥0/non-empty guards, `_moneyFromDisplay`, demo purge, applyGameResult new fields |

## Behavioural contract

- Menu always renders `userData` — seeded subject guarantees a value;
  no loading/error surface exists (senior truth).
- Any `saveUserProfile` — from VM or any future writer — propagates
  through `BehaviorSubject` → `_handleUserProfile` → `notifyListeners`.
- Save of an identical value emits nothing (emit guard).
- Reset writes defaults over the key (key survives) + snackbar event
  still emitted (FR-11/FR-12 → M24).
- `Provider.value` doesn't own repo lifecycle; `main()` does;
  `dispose()` exists for tests/hot-restart.

## Senior evidence mirrored

- `repositories/{profile,settings,onboarding}/*.dart` — contract+impl
  one-file layout, member sets, seeded subjects, emit guards,
  `create()` factory, `dispose()`.
- `view_models/menu/menu_screen_view_model.dart` — ctor `.value` seed +
  `listen`, `_handleUserProfile` (`_isDisposed` + compare-before-
  notify), `loadUserProfile()` delegation, dispose order.
- `core/app_dependency_scope.dart` + `main.dart` — `MultiProvider` of
  `Provider<Contract>.value`; `loadUserSettings()` before `runApp`.
- `data/profile/user_profile_data.dart` — field set, defaults,
  constants, parse helpers, demo purge, `?avatarUrl`, `formatVnd`.
- `test/widgets/game_screen_test_helpers.dart` —
  `FakeGameProfileRepository` pattern (implements + subject +
  counters).

## Deferred (named in lessons)

- `SupportedLanguageData` whitelist for `languageCode` → M17 (FR-26).
- `expForNextLevel` + `expPercent` → M22 (FR-01); `winRateDisplay`
  remains a learner display helper.
- `LevelConfig` curve + money ladder + EXP=earnedAmount → M19/M22
  (FR-02/FR-03).
- Game-side save + nav controller → M19/M22 (FR-04).
- Sealed UI/event states → M15 (FR-05/FR-07/FR-15).
- Settings UI → M16; onboarding flow → M18; dialogs layer → M21;
  leaderboard tap → M23; reset-button/sign-out ownership → M24.
- Advanced RxDart operators — roadmap-excluded from scope.

## Test-count ledger

52 → **69**. Store-era tests migrated to repo tests; +16 net new
covering impl round-trips, emit guards, replay, dispose, fake-driven
VM tests, and widget-level stream propagation.
