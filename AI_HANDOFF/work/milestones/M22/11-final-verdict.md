# M22 — FINAL VERDICT (Atlas)

## Verdict: `MILESTONE_COMPLETE`

M22 — Result Persistence / Profile Progression convergence is
complete under the canonical Agent Company pipeline. All stage
gates passed in order, each with independent QA before approval.

## Stage chain (all green)

| Stage | Result |
|---|---|
| Atlas brief | `01-brief.md` — senior evidence inspected live at `c8eb860` |
| Flux implementation | `02-implementation.md` — 168/168, analyze clean, `build web` PASS |
| Argus impl QA | PASS (0 blockers; 5 minors — 2 fixed, 3 dispositioned to M28) |
| Atlas impl approval | `IMPLEMENTATION_APPROVED` |
| Lumen content | 5 lessons + index; registry A-22/D-38/D-39; graph M22 section |
| Argus content QA | FAIL → remediated (4 rounds) → **REVERIFIED-PASS** |
| Atlas content approval | `CONTENT_APPROVED` |
| Forge site | 6 pages → `m22/`; sidebar/roadmap/state-progression/concepts; 120 pages built |
| Argus site QA | PASS (0 blockers) |
| Atlas site approval | `SITE_APPROVED` |
| Sequential replay | 5/5 on physical M21-end clone: **157→164→169→168→168**, byte-identical parity on all M22 files |

## What converged

- **FR-01** `expForNextLevel` field — dropped; cap derived.
- **FR-02** `gainExp` ×1.5 curve — replaced by senior `LevelConfig`.
- **FR-03** result→profile policy — EXP=`earnedAmount`,
  `totalQuestionCount`, `totalEarnings` via `formatVnd`, per senior.
- **FR-04** result transport — `GameResult` route-pop deleted;
  VM-side `_emitWithSaveResult` + `hasSavedResult` idempotence.
- FR-19 residual note updated (`expPercent` retired).

## Explicit non-goals (recorded, not defects)

- `_syncSavedGameResult` — `debugPrint` stub; real Supabase sync +
  auth check → **M24/M25** (repos not yet on ctor).
- DRE `GameSaveResult` asyncOp — learner keeps `unawaited` call;
  reducer queue → **M26**.
- `shareResult`/`GameShareResultEvent` → **M27** (FR-33).
- `LevelProgressCard` ring/glass/tier visuals + `menuMaxLevelReached`/
  `menuExpToNextLevel` labels → **M28**; cosmetic carryover: max-level
  bar text exposes raw `maxExpRequirement` — documented in L05.
- Menu `showDialog` → **M29**.

## Integrity

- Senior repo: `main@c8eb860`, clean — never modified.
- Learner app: analyze clean, **168/168**, `flutter build web` PASS.
- Website: 120 pages built, all `/m22/` routes live.
- Canonical state synced (CURRENT_STATE, CONTENT_STATUS,
  SENIOR_FIDELITY_REGISTER, registry, graph).
