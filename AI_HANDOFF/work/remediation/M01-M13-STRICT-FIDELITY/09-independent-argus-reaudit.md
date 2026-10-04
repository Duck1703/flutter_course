# 09 — Argus Independent Re-Verification

> Role: Argus — independent re-verification of the entire remediation.
> Simulated independence per D21: fresh greps/reads of disk state, not
> trusting upstream artifacts.

## Verdict: PASS (independent re-verification)

## Checks re-run independently

### Code surface
- `grep` learner `lib/`+`test/` for `_soundOn`, `_playTapCount`,
  `_toggleSound`, `menuSessionTicker`, `SessionTickerCard`,
  `demo_profile_loader`, `loadDemoProfile`, `.clear()` → **zero hits in
  source** (only stale `.dart_tool`/`build/` generated artifacts — not
  source, will refresh on next build).
- `profile_store.dart` on disk: `reset() => save(const UserProfileData())`
  — write-default, matches senior `resetUserProfile()` semantics
  (senior evidence: `user_profile_repository.dart` — reset writes
  `const UserProfileData()`, verified in Step-09 source map).
- `user_profile_data.dart` on disk: defaults `'0XFF'`/level 1/EXP 0/
  cap 35000/zeros — equals senior `UserProfileData` defaults; the
  FD-04 doc comment names senior fields arriving at M14 and
  `expForNextLevel` retirement at M22.
- `menu_view_model.dart` on disk: `MenuLoadState` doc carries the
  temporary/M14-retirement note; `resetProfile()` calls `_store.reset()`
  + compare-before-notify + `MenuSnackBarRequested` emit.
- No `BehaviorSubject`/`ValueStream`/`rxdart`/`abstract interface`
  **usage** — only doc comments (verified: 3 hits, all comments).
- `menu_screen.dart` scaffolds removed (verified in Flux QA + greps).

### Content surface
- All 44 lessons grepped; no present-tense claim that removed scaffolds
  still exist; no `'Khách'`/120/400 presented as product default;
  `57/57` replaced by honest `52/52` + explanation at m13/03.
- FD-01 site re-read: corrected senior description present.
- FD-09 site re-read: emit-site nuance present and accurate.

### Canonical/governance surface
- `project-context/SENIOR_FIDELITY_REGISTER.md` exists — 25 rows; every
  ACTIVE_TEMPORARY row has `Converges at` + senior evidence. **COMPLETE.**
- `MILESTONE_ROADMAP.md` — M09 as-shipped annotation (FD-12); M14/M16/
  M19/M22/M23/M24/M29 convergence bullets all present on disk.
- `QUALITY-GATES.md` — G16 added. `milestone-brief-template.md` — §5b
  SENIOR FIDELITY CHECK added. `DECISIONS.md` — D23 recorded.
- `CURRENT_STATE.md` updated honestly (52 tests, scaffolds removed,
  Steps 09–10 recorded).

### Process surface
- Role sequence honored: Atlas brief → Flux code → Argus impl QA →
  Atlas impl approval → Lumen content → Argus content QA (PASS with
  6 caught residuals fixed in-pass) → Atlas content approval → Forge
  site → Argus site QA → Atlas post-audit → this re-audit.
- No self-approval: each approval artifact cites the matching Argus PASS.

### Regression independently observed
- `flutter analyze` → clean; `flutter test` → 52/52; `flutter build web`
  → built; `npm run build` → 61 pages. Senior repo: `main` @ `c8eb860`,
  `git status` 0 changes.

## Challenges considered and resolved

- *"52 tests < 57 baseline — weakened?"* → No: the 5 removed tests
  covered deleted scaffold behavior (demo loader, ticker). Behavioral
  coverage of surviving features was updated, not weakened (the
  `gainExp` level-up test still asserts level-up — via explicit cap).
- *"Fields `totalEarnings`/`totalQuestionCount` not added now — is FD-04
  really resolved?"* → Resolved as RESOLVED_CODE_AND_CONTENT: the
  invented-defaults falsity (BR-01) is eliminated NOW; the field-set
  gap is registered (FR-19) with exact owner M14 — which is the correct
  milestone since those fields' writers (`_saveGameResult`, repository
  layer) arrive there/M22. Adding unused fields now would be premature
  scaffolding.
- *"Reset button still exists — invented behavior?"* → It is a
  registered temporary (FR-11 → M24); its semantics are now senior-true;
  lessons label it a scaffold. Per the audit's own rules this is
  VALID_TEMPORARY_SIMPLIFICATION_WITH_EXPLICIT_CONVERGENCE.

## Verdict

**PASS** — zero unresolved Step-09 findings; zero unregistered
simplifications; zero invented product behavior; register complete;
permanent gate active; senior unchanged; M14 unstarted.
