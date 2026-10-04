# Artifact 10 — Sequential M14 Replay (Argus reproduction)

Date: Step-13. Mode: physical replay — real M13 baseline cloned to
`C:\Users\Lenovo\AppData\Local\Temp\m14-replay`, then each new M14
lesson applied in order, running the stated checkpoint after each.
NOT evaluated against final M14 state — each intermediate state was
compiled and tested on its own.

## Baseline

M13-state clone reconstructed: `ProfileStore` (sync load/save/reset),
`MenuViewModel({required ProfileStore store})` with `MenuLoadState`,
scope = `Provider<ProfileStore>.value`, `main` builds store inline.

Baseline validation: `flutter pub get` OK, `flutter analyze` clean,
`flutter test` 33/33 PASS.

## Per-lesson result

| Lesson | What learner does | Checkpoint | Result |
|---|---|---|---|
| 1 — Vì sao ProfileStore chưa đủ | read-only, no code | analyze stays clean | **PASS** |
| 2 — Contract | `rxdart: ^0.28.0` + write `user_profile_repository.dart` (contract only) | analyze clean | **PASS** — no issues |
| 3 — Stream-state model | theory-only (`dart run` snippets) | analyze stays clean | **PASS** — unchanged |
| 4 — Profile impl | append `UserProfileRepositoryImpl` + add repo test | analyze + repo test | **PASS** — 3/3 new tests, app still ProfileStore |
| 5 — 2 repo còn lại + parity | settings/onboarding repos, `UserSettingsData`, model fields (keeps `totalEarningsDisplay`) | analyze + all tests | **PASS** — 61 tests |
| 6 — DI by contract | fakes + 4-arg scope (3 contracts + ProfileStore bridge) + bootstrap | analyze + all tests | **PASS** — 60 tests |
| 7 — VM migration | swap VM to `UserProfileRepository`, `.value` seed, ctor subscription; remove `MenuLoadState`, bridge ctor arg, `ProfileStore` import/field, `totalEarningsDisplay`; delete `profile_store.dart` + `profile_store_test.dart` | analyze + all tests | **PASS** — 64 tests |

## Convergence check

`diff -rq` clone vs production learner-app after lesson 7:

- `lib/` — identical except `user_profile_repository.dart` (same
  contract members + impl logic; production file has fuller doc
  comments). Semantically equivalent.
- `test/` — identical except `user_profile_repository_test.dart`
  (lesson-shaped subset; production file carries 5 extra cases).
- `pubspec.yaml` — identical modulo line endings.

Every stated checkpoint was reachable at the page where it is stated —
the old defect (analyze-clean claimed mid-migration) is gone.

## Failures found and fixed during replay

- Reconstructed scope test initially read `store.load().username`
  synchronously — `load()` is `Future`; fixed to identity check.
  (Replay artifact defect, not a lesson defect.)
- Lesson 6 bridge requires touching 3 scope-constructing test call
  sites; the lesson text now lists them by name.

VERDICT: **7/7 lessons sequentially executable.**
