# M27 — Step-25 Brief + Dual Review + Atlas + Closeout

CONTENT_REVISION: `f5b23cc45a884112` (sha256 of m27/*.md, frozen post-edit)

## Audit (all 6 lessons)

- 01 platform-boundary + dependencies (S): boundary ownership strong — noise.
- 02 local-notification-service (S): contract→impl→plugin→OS seam — noise.
- 03 settings-coordinator-permission-state (S, F-M2 flagged): 788-line lesson
  but already segmented (two mental-model subsections + DartPad isolate +
  Android bridge). P5 assessment: PASS_WITH_LOAD — added one pause-point
  mini-derive before Build (ownership map, AND-gate derived value, rollback
  order) instead of restructuring; invariant kept intact.
- 04 settings-wiring-version-onboarding (A): noise only.
- 05 share-chain-dre-effect (S): share-effect chain protected — noise.
- 06 regression-va-tong-ket (A→noise-heavy): learner-facing governance noise
  removed (FR table headers → human-readable Feature names; residual prose
  repaired); content unchanged otherwise.

## Interventions

- ADD_PAUSE_POINT + mini-DERIVE: m27/03.
- REMOVE_NOISE: ~164 prose ID tokens across m27 (heaviest count was 06 +
  index); FR bookkeeping out of learner prose; table headers renamed.
- ORTHOGRAPHY: plain-VN compounds normalized.

## Argus Technical QA — PASS

- m27/03 pause-point answers match impl: `SettingsNotificationCoordinator`
  owns orchestrate/rollback (`_saveSettingsWithRollback`), VM owns
  `_hasNotificationPermission` query + `effectiveNotificationEnabled` AND,
  OS owns truth; `Future.wait`×3 + `FlutterError.reportError` real.
- Noise pass prose-only; test names with FR-xx inside code spans preserved
  (they mirror real learner-app test groups).

## Pedagogy Reviewer — PEDAGOGY_PASS

- m27/03 P5: REMEDIATED (pause-point derive; no route split needed).
- F-H4 late portion: 06/index governance noise cleared.
- Highest exercise level unchanged (PREDICT/DEBUG) + one derived checkpoint.

## Atlas — APPROVED

Dual review on `f5b23cc45a884112`; scope = m27/** + index only.

## Closeout

- Verdict: **COMPLETE**.
