# IMPLEMENTATION QA — M13: One-shot UI events from the VM

> Reviewer: Argus (`argus-course-qa-reviewer`) — independent
> Artifact under review: `02-implementation-evidence.md` r1 +
> `learner-app/` diff
> Review r1 verdict: **FAIL**

## Intake gate

| Required input | Present? |
|---|---|
| `01-brief.md` | Y |
| `02-implementation-evidence.md` | Y |
| Roadmap M13 section + decisions | Y (roadmap §M13, D20) |
| Learner-app diff on disk | Y |

## Gates applied (stage-3 set: G1 G2 G3 G4 G5 G9 G12 G15)

| Gate | Result | Evidence |
|------|--------|----------|
| G1 Roadmap compliance | FAIL | Roadmap L731–733 lists `unawaited` in "Dart introduced" — see QA-IMPL-001 |
| G2 Prerequisite closure | PASS | M06 streams + M12 Provider shipped; code uses only taught concepts |
| G3 Senior evidence | PASS | Opened `flutter-accelerator-ai/lib/view_models/menu/menu_screen_ui_event.dart` (sealed `MenuScreenUiEvent`, `MenuGameRequested`, `MenuSnackBarRequested(message)` — exact match), `menu_screen_view_model.dart` (`StreamController<MenuScreenUiEvent>.broadcast()` ctor, `events` getter, `_events.add(const MenuGameRequested())` L107, `_events.close()` in dispose L86), `menu_screen.dart` `_MenuScreenEventBridgeState` (L40–76: `didChangeDependencies`→`context.read`→`_attachMenuViewModel` with `==` guard, `StreamSubscription`, `dispose` cancel — identical lifecycle to learner code) |
| G4 Implementation correctness | PASS-with-finding | Full diff review of the 5 changed files; lifecycle ordering correct, broadcast semantics correct, `is`-checks correct for non-sealed classes; the dropped-Future site flagged in QA-IMPL-001 |
| G5 Runnable transition | PASS | `MenuScreen` scope/provider wiring unchanged; `_onPlayTap` still called from `_PlayButton`; `onReset: viewModel.resetProfile` unchanged |
| G9 Premature-concept firewall | PASS | grep `sealed class|rxdart|BehaviorSubject|abstract interface class|ProxyProvider|MultiProvider|context.select` over `learner-app/lib` → only *comment* references (deferred-concept notes), zero code usage |
| G12 Test/build verification | PASS | Independently re-run: `flutter analyze` → "No issues found!"; `flutter test` → 57/57 passed. `flutter build web` output inspected from Flux run (not re-run by Argus — recorded honestly) |
| G15 State honesty | PASS | Evidence artifact reports actual outputs, records the two first-run test failures and their fixes; no fabricated claims found |

## Findings

```text
ID:        QA-IMPL-001
Severity:  BLOCKING
Artifact:  learner-app/lib/screens/menu_screen.dart — _handleUiEvent
           (also: roadmap compliance for evidence §6 concept table)
Evidence:  MILESTONE_ROADMAP.md L731–733 — M13 "Dart introduced" lists
           `unawaited` explicitly. In `_handleUiEvent` the line
           `_openGame()` (menu_screen.dart L99) drops a `Future<void>`
           silently — the exact site `unawaited` exists for. The
           concept is neither introduced nor exercised, so content
           would have to either teach `unawaited` on a code path that
           doesn't show it, or skip a roadmap-listed concept.
Why it fails: G1 — a roadmap-listed M13 concept is absent from the
           implementation; G15-adjacent — the code implies "fire and
           forget" without marking the discard, the sloppy pattern the
           milestone is meant to correct.
Owner:     Flux
Required fix: mark the discard with `unawaited(_openGame())` in
           `_handleUiEvent` (`dart:async` already imported), note the
           concept in evidence §6, re-run analyze + test.
```

Non-blocking notes (no action required):
- Bridge-in-State (vs senior's separate `_MenuScreenEventBridge` widget)
  is a declared `TEACHING_SIMPLIFICATION` in brief §5 — acceptable.
- The reset snackbar fires even when the profile was already default
  (event ≠ notify gating) — consistent with "reset always confirms";
  Lumen should not claim it's conditional.
- Evidence §10 honestly records the two first-run test failures —
  good provenance practice, keep it.

## Commands re-run by Argus

```text
$ flutter analyze → No issues found! (ran in 1.9s)      [RE-RUN]
$ flutter test    → 57/57 passed                        [RE-RUN]
$ grep scope/firewall checks                            [RUN]
Senior files opened and compared symbol-by-symbol        [RUN]
flutter build web — inspected recorded output only       [INSPECTED]
```

## Verdict rationale

Implementation is structurally correct — the broadcast channel, the
bridge lifecycle, the tests, and the senior citations all verify
independently. But M13's roadmap contract lists `unawaited` among the
Dart concepts it introduces, and the one site where it belongs ships a
bare dropped `Future` instead. That is a scope deviation the next
stage (content) cannot fix honestly. FAIL per G1 → back to Flux.

---

# IMPLEMENTATION QA — M13 (Review r2)

> Reviewer: Argus — independent re-review after Flux remediation
> Artifact under review: `02-implementation-evidence.md` r2 +
> `learner-app/` diff
> Review r2 verdict: **PASS**

## Re-verification of QA-IMPL-001

- `learner-app/lib/screens/menu_screen.dart` L99–103 read from disk:
  `unawaited(_openGame())` now wraps the deliberate discard inside
  `_handleUiEvent`, with a learner-facing comment explaining why.
  `dart:async` import already present (line 1, for
  `StreamSubscription`). **Resolved.**
- Evidence r2 §6 now lists `unawaited` as a first-appearance concept;
  §10 records the r2 re-run.

## Commands re-run by Argus (r2)

```text
$ flutter analyze → No issues found! (ran in 2.2s)   [RE-RUN]
$ flutter test    → 57/57 passed                     [RE-RUN]
```

## Gate re-check (changed surface only)

| Gate | Result | Evidence |
|------|--------|----------|
| G1 | PASS | `unawaited` now exercised at its natural site; all roadmap Dart-concept lines for M13 covered (plain event classes ✓, broadcast ✓, `StreamSubscription` ✓, `unawaited` ✓) |
| G4 | PASS | discard is now explicit; no behavior change (57/57) |
| G12 | PASS | re-run green (above) |

Unchanged gates carry forward from r1 (G2, G3, G5, G9, G15 — all PASS).

## Verdict rationale (r2)

Single blocking finding resolved with a minimal, on-concept change.
Zero unresolved blockers → **PASS**. Non-blocking notes from r1 stand
as guidance to Lumen. This PASS is a QA verdict only — approval
belongs to Atlas.

---

## ATLAS DECISION — IMPLEMENTATION_APPROVED

Atlas has reviewed: `01-brief.md` r1, `02-implementation-evidence.md`
r2, `03-implementation-qa.md` (r1 FAIL + r2 PASS), and the on-disk
learner-app diff. The remediation loop was exercised correctly —
finding recorded, routed, fixed, independently re-verified, history
preserved.

- Scope matches brief allow-list; no M14 leakage confirmed by Argus G9.
- Completion criteria demonstrable: CTA→event→navigate (widget test),
  reset→event→SnackBar (widget test), identity-guarded subscription
  (code + broadcast-semantics test).
- Findings: QA-IMPL-001 resolved at r2; non-blocking notes carried to
  Lumen guidance.

**Decision: IMPLEMENTATION_APPROVED — 2026-10-05.** Stage 5 (Lumen
content) may begin using `02-implementation-evidence.md` r2.
