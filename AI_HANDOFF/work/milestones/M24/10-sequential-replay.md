# M24 — Sequential Replay (Argus-witnessed physical replay)

> **Role:** Physical replay of the M24 lesson checkpoint sequence on a
> carried-forward clone. Verifies that a learner following the five
> lessons in order lands exactly on the M24 production state.

## Setup

- **Clone:** `C:\Users\Lenovo\AppData\Local\Temp\m16-replay`
  (carried forward from the M23 replay; starts at M23-end state).
- **Baseline:** `flutter test` → **193/193** (matches M23 end-state).
- **Method:** per-lesson file sets applied from production, with
  documented intermediate states where a lesson's in-flight code differs
  from the final file (see "Intermediate states" below). `flutter test`
  after each step.

## Checkpoint results

| Step | Lesson scope | Expected | Actual | Result |
| --- | --- | --- | --- | --- |
| Baseline | M23 end-state | 193 | 193/193 | PASS |
| L01 | Session model + contract + Disabled + barrel (auth-only) | 199 | 199/199 | PASS |
| L02 | `pubspec` deps + Google/Apple services + `SupabaseAuthRepository` + barrel export + DI (auth-only scope) + call-site updates | 201 | 201/201 | PASS |
| L03 | `ProfileSyncStateData` + sync contract + `UserProfileSyncRepositoryDisabled` + `MenuAuthActionCoordinator` + scope/main sync seam + `FakeUserProfileSyncRepository` + call-site updates | 201 | 201/201 | PASS |
| L04 | Auth/sign-out dialog VMs + `MenuViewModel` auth dep (seed+subscribe, no `requestAuthAction` yet) + leaderboard FR-35 uid wiring + `MenuLeaderboardDialogScope(authRepository:)` + menu-screen `create:` auth arg + dialog-VM/leaderboard/menu-VM tests | 219 | 219/219 | PASS |
| L05 | `MenuAuthRequested`/`MenuSignOutRequested` events + `requestAuthAction` + `resetProfile`/menu snackbar emit-site retirement (`MenuSnackBarRequested` class retained) + 6 `widgets/menu/auth/*` files + ARB (`menuGuestName` + auth strings) + regenerated localizations + full event/UI wiring | 224 | 224/224 | PASS |

Chain reproduced: **193 → 199 → 201 → 201 → 219 → 224** — identical to
the production ledger.

## Intermediate states (documented replay constructs)

The lessons intentionally land some files in an intermediate shape
before their final state. The replay synthesized these from the M23-end
file plus the lesson's delta (equivalent to what the lesson instructs):

- **L01 test file:** `supabase_auth_repository_test.dart` minus the two
  Apple-mapping tests + Apple import (Apple service arrives in L02).
- **L01 barrel:** exports `contract` + `disabled` only; the
  `supabase_auth_repository.dart` export lands in L02.
- **L02 scope/main:** `AppDependencyScope` + `main.dart` with
  `authRepository` only (sync seam is L03); call-sites pass
  `authRepository:` only.
- **L03 call-sites:** test scope calls gain `profileSyncRepository:` —
  `menu_screen_ui_events_test`/`menu_leaderboard_dialog_test` remain
  M23-shaped + the two new args (their L05 rewrites land later).
- **L04 `menu_view_model.dart`:** auth dep (seed `_authState` +
  `_handleAuthState` subscription + `isAuthenticated` +
  `loadAuthState` in `loadUserProfile`) but **without**
  `requestAuthAction`; `resetProfile` + `MenuSnackBarRequested` emit
  still present (retired in L05).
- **L04 `menu_view_model_test.dart`:** M23 tests + `authRepository:`
  ctor arg + the three auth-stream seed tests; the three
  `requestAuthAction` tests land in L05.
- **L04 `menu_screen.dart`:** only the `create:` auth arg (auth pill UI
  + dialog event routing are L05); `onboarding_overlay_test` gains a
  `Provider<AuthRepository>` because `MenuScreen.create` now reads it.

Argus physically verified the L04-end (219) and L05-end (224) states
compile and pass during content QA; this replay independently
reproduced all five checkpoints.

## Production/replay parity

After L05, all differing files were diffed against production:

- **M24-touched files** (`game_screen_test.dart`,
  `onboarding_overlay_test.dart`): replay intermediates were
  semantically equivalent but comment-level different → resynced to
  production end-state; now byte-identical.
- **Pre-existing non-M24 drift** (`menu_tokens.dart`,
  `game_screen_data.dart`, `user_settings_data.dart`,
  `game_screen_presentation_mapper.dart`,
  `game_screen_presentation_mapper_test.dart`,
  `game_dialog_layer_test.dart`): older doc-comment revisions on the
  clone from before M24 (not touched by any M24 lesson step; tests
  unaffected). Resynced to production for end-state fidelity.
- CRLF/LF normalization artifacts on `cp` copies — resolved by the
  same resync.

**Final state:** `diff -rq lib/ test/ pubspec.yaml` → **zero
differences** (only production's `lib/build` artifact dir). All 224
tests pass on the replayed tree.

## Verdict

`SEQUENTIAL_REPLAY: PASS` — the five M24 lessons, applied in order to an
M23-end clone, reproduce production exactly (test counts and file
content), including the documented two-step `MenuViewModel` split
(L04 dep → L05 `requestAuthAction`+retirement) and the FR-35 leaderboard
uid wiring order.
