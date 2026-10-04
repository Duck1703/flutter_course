# M22 — CONTENT DRAFT MANIFEST (Lumen)

## Intake gate

`IMPLEMENTATION_APPROVED` confirmed — `03-implementation-qa.md` on
disk (Argus PASS, 0 blockers, minors dispositioned). Learner app
verified: `flutter analyze` clean, `flutter test` **168/168**,
`flutter build web` PASS. Senior unchanged (`main@c8eb860`).

## Lessons authored (5 + index) — `AI_HANDOFF/work/milestones/M22/lessons/`

| File | Concepts | Exercise |
|---|---|---|
| `index.md` | milestone map + checkpoint arithmetic + deferred list | — |
| `01-ket-qua-la-ghi-db.md` | **A-22** VM-side async save boundary (CORE home): save = side-effect of terminal transition; `hasSavedResult` idempotence; 4-site payload table; `questionCount`=reached-not-correct; walk-away `isWin:false`; stream→menu | Tự làm PREDICT: payload + saveCallCount của walk-away→menu |
| `02-level-config.md` | **D-38** config-table progression: `_milestoneMultipliers` map, `getExpRequiredForLevel` = `(base + level×growth) × mult(level+1)`, `getCumulative…`, milestone helpers; JS-safe `maxExpRequirement` divergence documented; +7 tests | Tự làm PREDICT: 3 threshold computations by hand |
| `03-menu-level-progress.md` | **D-39** derived view-model: `fromProfile` factory, `tier`/`ratio`/`remainingExp`/`formatted*`; `_LevelCard` rewire to `progress` (level label reads `progress.level`); "derived-don't-store" lesson; +5 tests | RECOGNIZE tier+requiredExp; MODIFY add maxLevel test (sandbox) |
| `04-vm-save-mot-lan.md` | atomic cut: ctor `required UserProfileRepository`, `_emitWithSaveResult` at 4 sites, `_saveGameResult`/`_applyLevelProgression`/`_normalizedLevel`/`_syncSavedGameResult`(M25 stub); `hasSavedResult`↔`resolvedResult` swap; delete `game_result.dart`; `openGame`→void, bare `goBack`, `_openGame` bare, `MenuViewModel.applyGameResult` deleted; `UserProfileData` 9-field surgery; −9 scaffold / +8 persistence test arithmetic | Tự làm DEBUG: emit `next` quên `copyWith(hasSavedResult: true)` → cờ mãi false → 3 test đỏ |
| `05-regression-va-m23-boundary.md` | grep-zero verification, senior↔learner save-path parity table, 168 math explained (157+7+5+8−9), M22 non-goals table (M24/M25/M26/M27/M28 boundaries) | Tự làm PRODUCE: pre-safe-haven walk-away save test |

## Registry / graph updates (done before QA)

- `LEARNER_CONCEPT_REGISTRY.md`: +**A-22** (CORE, M22/01+04),
  +**D-38** (NORMAL, M22/02), +**D-39** (NORMAL, M22/03) — all TAUGHT.
- `PREREQUISITE_GRAPH.md`: M22 section appended (edges A-18+A-08+D-17
  → L01→L02→L03→L04→L05; feeds M23/M24/M25/M26/M28).
- `SENIOR_FIDELITY_REGISTER.md`: M22 rows converge at closeout
  (FR-01/FR-03/FR-04 → CONVERGED; FR-19 note `expPercent` retired).

## Depth assignments (per brief Learning Design Check)

- CORE: **A-22** (L01 mental-model lesson, no code — ownership +
  idempotence is the felt problem).
- NORMAL: **D-38** (L02 — read-the-table, not memorize), **D-39**
  (L03 — derived-view pattern already familiar from A-20 mapper).
- Reuse: D-17 `unawaited`, D-23 test APIs, D-34 copyWith flags,
  A-07/A-11 DI+fakes, A-18 machine, A-20 mapper, F-25/D-31 l10n.

≤3 major new concepts per page: L01=1 (A-22), L02=1 (D-38), L03=1
(D-39), L04=0 new (A-22 application), L05=0.

## Checkpoint arithmetic (honest, from M21 final 157)

| Lesson end | Count | Delta |
|---|---|---|
| L01 | **157** | mental model — no code |
| L02 | **164** | +7 `level_config_test` |
| L03 | **169** | +5 `menu_level_progress_test` |
| L04 | **168** | +8 persistence, −9 scaffold (6 user_profile + 1 menu_vm + 2 buildGameResult) |
| L05 | **168** | regression sweep only |

Non-monotonic dip at L04 is *taught* in the lesson ("test scaffold
chết cùng scaffold — dấu hiệu sạch").

## Known cosmetic carryover (documented in lessons + M28 note)

- `_LevelCard` at `isMaxLevel` displays raw `maxExpRequirement`
  (`9e15`) — senior hides via `menuMaxLevelReached`/`LevelProgressCard`
  at M28. Flagged in L05; not fixed at M22 scope.

## Verification before handoff

- `flutter analyze` clean; `flutter test` 168/168; `build web` PASS
  (post-implementation, unchanged by content).
- Every lesson snippet spot-checked against on-disk code (VM L575–667,
  level_config, menu_level_progress, `_LevelCard` block, nav/screen
  hunks). File:line references embedded where load-bearing.

## Declared deviations from template

- L01 is a mental-model lesson (no code) — M20/L01 and M21/L01
  precedent; A-22 is CORE so it gets its own isolated-concept page.
- L02–L05 fold the "Kiểm tra hiểu biết" self-check into the lesson
  Checkpoint (PREDICT/RECOGNIZE exercises) rather than a separate
  Q&A section; "Lỗi hay gặp" is covered inline (L02 lỗi-phổ-biến
  note, L04 caution box, L05 DEBUG exercise). Declared here per
  content-protocol merge rule.
- L02/L03 code blocks are full verbatim file content (post-QA
  sync); earlier draft condensed them — Argus M2 flagged, fixed.
