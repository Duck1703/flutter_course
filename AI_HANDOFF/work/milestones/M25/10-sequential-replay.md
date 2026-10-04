# M25 — Sequential Replay (Atlas-witnessed physical replay)

> **Role:** Physical replay of the M25 lesson checkpoint sequence on the
> carried-forward clone. Verifies the five lessons land exactly on the
> M25 production state.

## Setup

- **Clone:** `C:\Users\Lenovo\AppData\Local\Temp\m16-replay`
  (M24-end state, byte-identical to production after M24 replay).
- **Baseline:** `flutter test` → **224/224** (matches M24 end-state).

## Checkpoint results

| Step | Lesson scope | Expected | Actual | Result |
| --- | --- | --- | --- | --- |
| Baseline | M24 end-state | 224 | 224/224 | PASS |
| L01 | `app_user_data.dart` v1 (`AppUserData` + 3 parsers, no merge) + `supabase/student-setup/02-verify-database.sql` + `user_profile_sync_schema_test.dart` | 226 | 226/226 | PASS |
| L02 | merge fn + 5 helpers appended (=production file) + `user_profile_sync_merge_test.dart` (7 tests) | 233 | 233/233 | PASS |
| L03 | `UserProfileSyncRepositoryImpl` prepended + contract/`profile_sync_state_data` doc updates — no new tests | 233 | 233/233 | PASS |
| L04 | `main.dart` conditional DI + game VM (`authRepository`+`profileSyncRepository` ctor, real `_syncSavedGameResult`) + `game_screen.dart` create + scope/coordinator/VM doc updates + compile-forced test call-sites (`startedVm`/`pumpGameScreen` params + VM-create args) | 233 | 233/233 | PASS |
| L05 | `result profile sync (M25, FR-36)` group (3 tests) appended | 236 | 236/236 | PASS |

Chain reproduced: **224 → 226 → 233 → 233 → 233 → 236** — identical to
the ledger arithmetic.

## Intermediate states (documented replay constructs)

- **L01 `app_user_data.dart`:** production file truncated before the
  `/// Merge local` doc — `AppUserData` + `_stringValue`/
  `_nullableStringValue`/`_intValue` only (merge + helpers arrive L02).
- **L04 test call-sites:** clone's M24 files patched with the same
  arg additions production received (compile-forced `required`
  params); the M25 test group lands only at L05.

## Production/replay parity

`diff -rq lib/ test/ supabase/student-setup/02-verify-database.sql` →
**zero differences** (only production's `lib/build` artifact dir).
All 236 tests pass on the replayed tree.

## Verdict

`SEQUENTIAL_REPLAY: PASS` — the five M25 lessons, applied in order to an
M24-end clone, reproduce production exactly, including the documented
two-step `app_user_data.dart` split (DTO at L01 → merge at L02) and the
L03/L04 no-new-test wiring plateaus.
