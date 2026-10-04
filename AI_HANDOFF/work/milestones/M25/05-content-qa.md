# M25 — Content QA (Argus)

## Verdict: `PASS_WITH_FINDINGS` → remediated → `CONTENT_APPROVED`

## Findings + remediation

| # | Severity | Finding | Fix |
|---|----------|---------|-----|
| 1 | BLOCKING | `lessons/01…schema.md:146-160` — `WalletRow.fromMap` mini-parser only checked `is String`/`is int`, so the claimed `→ guest/0` output was false (`''`/`-7` pass those checks) | Tightened the mini-parser to mirror the real guards (`trim().isNotEmpty`, `>= 0`); **physically re-ran** → output now exactly `{owner_name: A, coin_count: 5} → guest/0` |
| 2 | NON-BLOCKING | `02-merge…:11` said "bốn helper" — actual 5 | `bốn` → `năm` |
| 3 | NON-BLOCKING | `03-sync…:440` wrote `auth_uid()` | corrected to `auth.uid()` (matches SQL) |
| 4 | NON-BLOCKING | `05-…:389` lesson-level `## Tổng kết milestone` section — M24 L05 spine has none | CONFIRMED intentional: L05 is the synthesis lesson (title `…-va-tong-ket`); content consistent with `index.md` synthesis — documented here + ledger |

## Argus physical verification (all re-run on real code)

- DEBUG L02: planted bug → exactly 1 red (`demo normalize` test,
  `Expected <1> Actual <12>` at `:208`, username assert still green —
  partial-pass trap confirmed); restored byte-identical.
- PRODUCE L04: scripted scratch test compiled + passed with
  `started/completed` logs; deleted.
- PREDICT spot-checks: idempotent save, DI gate on
  `isSupabaseConfigured` only, inner-try/catch removal keeps suite
  green (log message shifts) — all physically verified.
- All verbatim excerpts diffed vs learner + senior sources — matched.
- Checkpoint arithmetic 224→226→233→233→233→236 consistent;
  sequential compile coherent (schema test needs only `AppUserData`).
- Honesty: `LIVE_PROFILE_SYNC: NOT_PERFORMED` ×4 sites; no live-test
  claims; impl-has-no-unit-test stated (concrete `SupabaseClient`,
  senior likewise untested at repo level).
- Scope: no DRE/`MenuDialogLayer`/M28 teaching; deferred-tagged only.
- Registry: A-27..A-30 + B-08 rows accurate; FR-36 → CONVERGED entry
  correct; prerequisite edges honest.
- Impl state confirmed pristine post-audit (md5-identical restores;
  no stray scratch files).

## Gates

- `flutter analyze` clean · `flutter test` **236/236** after fixes.
- Senior `main@c8eb860` untouched.

## CONTENT_APPROVED — Atlas
