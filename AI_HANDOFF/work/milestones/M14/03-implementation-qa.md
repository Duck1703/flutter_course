# M14 — Implementation QA (Argus)

Milestone: M14 — Repository contracts & rxdart BehaviorSubject
Reviewer: Argus · Date: 2026-10-02 · Revision: r1
Under review: `02-implementation-evidence.md` r1 + learner-app on disk
Independence note: sequential role simulation (Devin) — this QA was
performed by re-reading artifacts + source from disk fresh and
re-running commands independently, per the Devin adapter. Not a
claim of subprocess isolation.

## Verdict: PASS

## Verified on disk (not from the evidence file)

| Check | Method | Result |
|---|---|---|
| `abstract interface class` ×3 contracts | grep lib/repositories | ✅ profile/settings/onboarding |
| `implements` impl classes | same | ✅ |
| `BehaviorSubject.seeded` | same | ✅ `UserProfileData()`/`UserSettingsData()`/`false` |
| `ValueStream<T>` getter exposure | same | ✅ |
| `isClosed` + `value !=` emit guards | read impls | ✅ all three |
| `resetUserProfile() => saveUserProfile(const UserProfileData())` | read | ✅ FR-24 preserved |
| `dispose()` → `close()` (`Future<void>`) | read | ✅ |
| `.create()` async factory + private `._` ctor | read | ✅ senior shape |
| `rxdart: ^0.28.0` | pubspec.yaml + senior pubspec | ✅ exact version match; lock resolved 0.28.0 |
| `MultiProvider` + `Provider<Contract>.value` | read scope | ✅ keyed by contract types |
| VM ctor: `.value` seed + ctor `listen` + `_isDisposed` + cancel | read VM | ✅ matches `MenuScreenViewModel` |
| `MenuLoadState`/`load()`/`_MenuLoading`/`_MenuErrorState` gone | grep lib/ | ✅ only retirement doc refs |
| `ProfileStore`/`profile_store.dart` gone | find lib/ | ✅ deleted; only doc references |
| `UserProfileData` +`totalEarnings`/`totalQuestionCount`, `?avatarUrl`, `_moneyFromDisplay`, `_isLegacyDemoProfile`, deep guards | read model | ✅ FR-19 substance present |
| `expForNextLevel`/`gainExp` retained | read model | ✅ FR-01/02 deferred correctly |
| Senior file layout mirrored (contract+impl one file) | dir listing | ✅ |
| Fakes `implements` + own seeded subject + counters | read test/helpers | ✅ senior fake pattern |
| No M15+ leakage: sealed/get_it/Bloc/Riverpod/switchMap/Retry/GameViewModel | grep lib/ | ✅ none |
| Reset button + snackbar emit retained (FR-11/12 → M24) | read | ✅ |
| `loadUserSettings()` in `main()` before runApp | read main | ✅ senior parity; no profile/onboarding preload (senior does neither there) |
| `?avatarUrl` omitted-key | test on disk | ✅ `toMap` drops key when null |
| Tests real + passing | independent `flutter test` | ✅ **69/69** |
| Analyze | independent `flutter analyze` | ✅ 0 issues |
| Senior repo unchanged | `git log -1` + `git status` | ✅ `c8eb860`, 0 modified |

## Findings

1. **QA-IMPL-014-01 (noted, non-blocking)** — `lib/view_models/menu/
   menu_ui_event.dart` was listed do-not-touch (event hierarchy sealed
   = M15). A doc-comment-only edit landed: it referenced the retired
   `loadState`/`profile` symbols as live examples, which would have
   left a false claim in source docs. Semantics unchanged; edit is
   consistency maintenance forced by the FR-08 retirement, not a
   behavior change. Accepted; recorded honestly.
2. **Timing/prefs-wipe first-run failures** — Flux recorded the real
   fixes (`pumpEventQueue`, no-reseed reuse) in §5. Verified the final
   state passes cleanly.

## G16 check

- FR-08, FR-09, FR-19: closure evidence complete → Atlas may flip to
  `CONVERGED` at canonical sync.
- FR-26 (`languageCode` whitelist → M17) declared in brief + evidence
  + source doc comment. Register row to be written at Atlas sync.
- No unregistered deviation found.

## Required re-checks for approval

None. Recommend Atlas `IMPLEMENTATION_APPROVED`.
