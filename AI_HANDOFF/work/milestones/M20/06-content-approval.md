# M20 — ATLAS CONTENT APPROVAL

## Gate status

`CONTENT_QA: PASS` — Argus r2 (independent subagent), all r1
blocking findings verified fixed; residual MINOR/NITs closed in
the same pass.

## Review basis

- `04-content-draft.md` manifest (updated: variants-with-UI
  staging note, contract coverage §§2/4/5/6/7/10, drop
  declarations).
- `lessons/index.md` + `01–05` — Vietnamese, beginner-first,
  evidence-only code byte-identical to `learner-app` disk.
- `05-content-qa.md` — r1 FAIL record + r2 PASS verification.

## Ruling

**DONE: CONTENT_APPROVED.**

### Verified properties

- **Sequential executability (G24):** every lesson checkpoint is
  now reachable — L02 stays additive (plain classes/fields only;
  131/131), L03 adds `GameAudiencePollDialog` *with* its UI arms
  (141/141), L04 adds the two remaining variants *with* their
  arms (147/147). Sealed-test updates ride the same lessons that
  introduce the variants.
- **Evidence truthfulness:** Argus diffed every quoted snippet
  against disk — byte-identical (helper functions, VM methods,
  mapper, dialog arms, ARB keys, staged test code).
- **Senior honesty:** simulated AI framed as senior-real (not a
  stub of a "real" integration); deterministic 50:50 explicitly
  taught; walk-away `won:false`/`phase:victory` semantics
  preserved; `canWalkAway` vs `_canUseFeature` two-guard split
  explained; FR-34 IconData-flat declared with M28 convergence;
  `showDialog`→M21, `ChangeNotifier`→M26, `resolvedResult`→M22
  all declared in lessons + index.
- **Concept registry:** D-35 (CORE, `Set<T>` state — mental model
  + isolated `Wallet` + bridge + checkpoint), D-36, F-28 — all
  first appearances taught; prerequisite closure verified.
- **Exercises:** PRODUCE (L05 lifeline-6 skeleton, hidden
  solution), PREDICT, DEBUG present.

### Minor notes (non-blocking)

- Content QA detected in-flight file states during remediation
  (stale-write anomaly in the editor toolchain); final state
  verified consistent by re-grep. No behavioral impact — the
  learner repo code was untouched except one comment fix
  (`context.watch` → `ListenableBuilder` wording in
  `_onAIAssistantElapsed`), which Argus confirmed matches the
  lesson's quote.
- The mid-review file churn is noted for the supervisor: future
  content remediation should batch edits and let QA read a
  frozen snapshot.

## Next gate

Forge site integration — copy approved lessons to `website/`,
sidebar + routes + links, `astro build` validation, then Argus
site QA and Atlas site approval.
