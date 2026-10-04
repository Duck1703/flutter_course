# STEP 25 — M23→M29 Derive-First + Late-Course Pedagogy Remediation

Branch: `remediation/step25-m23-m29-derive-first` (local only — not pushed)
Base: `c1b16dd` (accepted Step-24 checkpoint)

## Scope

Final band of the Step-21 `NEEDS_ENRICHMENT` findings: M23–M29 (40 lessons).
Companion steps: M01–M13 remediated at Step-23 (`529a544`); M16–M22 at
Step-24 (`c1b16dd`).

## Interventions per milestone

| M | Derive-first added | Structural | Noise removed |
|---|---|---|---|
| M23 | 02 — `initialize` signature, config matrix, contract surface, branch point | — | ~96 |
| M24 | 02 — AuthRepositoryImpl contract before 317-line port | — | ~143 |
| M25 | 03 — sync pipeline order/invariants before verbatim port | — | ~129 |
| M26 | 03 — DRE contract inventory (state/action/effect/op) | 04 — five-phase load map + pattern-scope callout | ~170 |
| M27 | 03 — ownership/AND-gate/rollback pause-point | — | ~164 |
| M28 | 01 — AppAssets/AppTokens lookup-layer design | 06 — PHẦN A/B/C atomic-swap markers | ~170 |
| M29 | 01,04,05,06 — process-as-model + decompose + sealed-family + config derives | 07 — self-contained capstone note | ~225 |

Total prose registry-ID noise removed band-wide: **~1,106 tokens → 0**
(lesson cross-references `B01`–`B06` preserved — they are meaningful).

## Orthography

Plain-Vietnamese hyphenated compounds normalized (~3,450 sites); ASCII
technical compounds (`vm-test`, `custom-painter`, `dart-define`…)
preserved.

## Answer-key verification (Argus)

All derive answer keys verified against shipped learner code:

- M23/02: `Future<SupabaseClient?> initialize(SupabaseEnvironment)`;
  null→`DisabledLeaderboardRepository`, configured→`SupabaseLeaderboardRepository`;
  branch in `main()`.
- M25/03: sync pipeline `_isSyncing` guard → `ProfileSyncInProgress` →
  local load → `maybeSingle` fetch → merge → local save → upsert
  `onConflict: auth_uuid` → `ProfileSyncIdle`; catch emits
  `ProfileSyncFailed` + rethrow; finally unlocks. Schema fix:
  `AppUserData.username` ↔ SQL `name` (not `display_name`).
- M26/03: `GameAction` 13 variants, `GameEffect` 7 variants,
  `GameAsyncOp` = `GameSaveResult{earnedAmount, isWin, questionCount}` —
  corrected against `learner-app/lib/view_models/game/dre/` real files
  (initial key had wrong variant inventory).
- M29/05: `MenuDialogState` = sealed, 5 variants
  (None/Leaderboard/Settings/Auth/SignOut), no payloads.
- M29/06: `OnboardingHeaderConfig` = title/color/badgeGradient/
  badgeAsset.

## Dual review + Atlas

Per-milestone artifacts at
`AI_HANDOFF/work/step-25-pedagogy-remediation/m2{3..9}/01-brief-reviews-closeout.md`,
each stamped with a frozen `CONTENT_REVISION` (sha256 of that
milestone's `*.md` post-edit):

| M | CONTENT_REVISION | Argus | Pedagogy | Atlas |
|---|---|---|---|---|
| M23 | `b0b66619a342abc4` | PASS | PEDAGOGY_PASS | APPROVED |
| M24 | `fcc253145a1b9591` | PASS | PEDAGOGY_PASS | APPROVED |
| M25 | `b35e885204d10a75` | PASS | PEDAGOGY_PASS | APPROVED |
| M26 | `4ebe64fd9ef79a77` | PASS | PEDAGOGY_PASS | APPROVED |
| M27 | `f5b23cc45a884112` | PASS | PEDAGOGY_PASS | APPROVED |
| M28 | `2c90711a178c8ad7` | PASS | PEDAGOGY_PASS | APPROVED |
| M29 | `4d54ea6b52eacce6` | PASS | PEDAGOGY_PASS | APPROVED |

## Final verification

- Astro site build: **167 pages** ✓
- `flutter analyze`: **no issues** ✓
- `flutter test`: **396/396** ✓
- `flutter build web`: **built** ✓
- `learner-app/` diff vs base: **none** ✓
- senior repo (`../flutter-accelerator-ai`): **clean at c8eb860** ✓
- Markdown fences/admonitions balanced across all 47 files ✓
- `SENIOR_FIDELITY_REGISTER.md`: **0 ACTIVE_TEMPORARY rows** ✓
- Cleanup damage repaired manually: orphaned parens/colons/dashes,
  `/-residual/` fragments, `(27 — M20/21)` → `D-26/27`, index
  description tails (`259/259., (version)` → human-readable).

## Constraints honoured

No learner-app changes, no senior-repo changes, no product behaviour
change, no push, no M30, no deployment.
