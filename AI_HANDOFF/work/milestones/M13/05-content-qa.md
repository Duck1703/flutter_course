# CONTENT QA — M13: One-shot UI events from the VM

> Reviewer: Argus (`argus-course-qa-reviewer`) — independent
> Artifact under review: `04-content-draft.md` + `lessons/*.md` (r1)
> against IMPLEMENTATION_APPROVED `02-implementation-evidence.md` r2
> and the learner app on disk
> Review r1 verdict: **FAIL**

## Intake gate

| Required input | Present? |
|---|---|
| `04-content-draft.md` + lessons | Y (index + 3 lessons) |
| `01-brief.md` | Y |
| `02-*` with `IMPLEMENTATION_APPROVED` | Y (r2 + Atlas decision in `03-*`) |
| Roadmap M13 section + decisions | Y |
| Learner code on disk | Y |

## Gates applied (stage-6 set: G1 G2 G3 G6 G7 G8 G9 G10 G11 G15)

| Gate | Result | Evidence |
|------|--------|----------|
| G1 Roadmap compliance | PASS | Lessons cover exactly the M13 roadmap slice; `unawaited` taught in L2 at its real site; deferrals all named |
| G2 Prerequisite closure | FAIL | QA-CONTENT-001 — L3 claims SnackBar was used in M03; untrue |
| G3 Senior evidence | PASS | Opened `menu_screen_ui_event.dart` (sealed + two event classes — matches citations), `menu_screen_view_model.dart` (`_events` broadcast/`events`/`requestGame()`/`_events.close()` — all present), `menu_screen.dart` `_MenuScreenEventBridgeState` L40–76 (three duties as cited); labels used correctly (`DIRECT_EVIDENCE`, nav-controller cited as not-yet-introduced) |
| G6 Beginner followability | PASS | Every step names file path; sections present; visible results stated; language consistent with M01–M12 register |
| G7 First-appearance explanation | FAIL | QA-CONTENT-001 — `SnackBar`/`ScaffoldMessenger` are genuine first appearances with no proper explanation; `ScaffoldMessenger.of` appears in tables but `SnackBar` widget itself is unexplained |
| G8 No hidden steps | PASS | Lesson steps ↔ learner diff; `ensureVisible`, `import 'dart:async'` (L2 step 1 mentions it), test-file creation all present |
| G9 Premature-concept firewall | PASS | `sealed`/`rxdart`/nav-controller appear only inside "cố ý chưa thêm"/evidence contexts; grep of learner code remains clean |
| G10 Code↔lesson consistency | PASS-with-note | Spot-diffed: `menu_ui_event.dart` classes, VM `_events`/`events`/`requestGame`/`resetProfile`/`dispose`, bridge block, `_handleUiEvent` (incl. `unawaited`), `_onPlayTap`/`_openGame`, both test files — all code matches disk. NON-BLOCKING note below re: trimmed doc comments |
| G11 Android bridge | PASS | Three-line format used; SharedFlow/Channel and LaunchedEffect analogies accurate; auto-cancel vs manual-cancel difference correct; Turbine mention appropriate |
| G15 Canonical-state honesty | FAIL | QA-CONTENT-001 — false prerequisite claim is a factually wrong statement about course history |

## Findings

```text
ID:        QA-CONTENT-001
Severity:  BLOCKING
Artifact:  lessons/03-snackbar-event-va-test.md — "Bạn đã biết gì";
           also manifest §3 first-appearance table (missing SnackBar)
Evidence:  `grep -rn "SnackBar|ScaffoldMessenger" learner-app/lib/`
           → zero hits outside the M13 menu files. `grep` over
           web/src/content/docs/m01–m12 → only a passing
           `ScaffoldMessenger.of` name-drop in m07/01 (not taught
           usage). L3 line "SnackBar cơ bản (M03 dùng trực tiếp)"
           is therefore false — SnackBar has never been used or
           taught in this course.
Why it fails: G2 — a lesson may not claim a prerequisite that was
           never taught; G7 — `SnackBar`/`ScaffoldMessenger` are real
           first appearances and must be explained as such (what a
           SnackBar is, why the messenger — not the Scaffold — owns
           it); G15 — false history claim.
Owner:     Lumen
Required fix: remove the M03 claim; treat SnackBar + ScaffoldMessenger
           as first appearances — explain the widget (transient bottom
           bar message) and the messenger's role (app-level queue that
           finds the current Scaffold) in L2's Flutter table or L3's
           intro; add both to the manifest §3 table.
```

Non-blocking notes (recorded, no action required for PASS):
- Two lesson snippets trim doc comments vs disk without an elision
  marker (`menu_ui_event.dart` header in L1; bridge field doc in L2) —
  code identical, cosmetic only; recommend aligning or marking `// …`.
- L3 presents test-file excerpts without imports/`main()` — clearly
  framed as excerpts with helpers named; acceptable.

## Commands run by Argus (content QA)

```text
grep SnackBar/ScaffoldMessenger over learner-app/lib + web docs  [RUN]
grep "## " section audit over 3 lessons → 16/16 each            [RUN]
snippet↔disk spot-diffs on 5 code files                          [RUN]
senior source files re-opened and compared                       [RUN]
```

## Verdict rationale

Structure, coverage, fidelity, and pedagogy are otherwise sound — the
16-section shape is complete, snippets match disk, and the deferral
discipline is right. But a lesson claiming a non-existent prerequisite
teaches a falsehood and skips a real first-appearance explanation —
both blocking defects under this contract. FAIL → Lumen remediates.

---

# CONTENT QA — M13 (Review r2)

> Reviewer: Argus — independent re-review after Lumen remediation
> Artifact under review: `04-content-draft.md` + `lessons/*.md` r2
> Review r2 verdict: **PASS**

## Re-verification of QA-CONTENT-001

- L3 "Bạn đã biết gì" re-read from disk: the false claim
  "`SnackBar` cơ bản (M03 dùng trực tiếp)" is gone; prereqs now state
  SnackBar + ScaffoldMessenger are M13 first appearances explained in
  L2 — factually true (grep re-confirmed zero pre-M13 usage).
- L2 Flutter table (L75–76) marks both `SnackBar` and
  `ScaffoldMessenger.of` as "**Lần đầu trong course**" with real
  explanations; a new post-step paragraph (after the `_handleUiEvent`
  snippet) explains the widget + app-level messenger role.
- `04-content-draft.md` §3 now lists both as first appearances. **Resolved.**

## Non-blocking note disposition

Lumen also aligned the two trimmed doc-comment blocks verbatim with
disk (r1 note) — G10 gap closed, not merely waived.

## Gate re-check (changed surface only)

| Gate | Result | Evidence |
|------|--------|----------|
| G2 | PASS | prerequisite list now truthful; SnackBar/ScaffoldMessenger taught at first use |
| G7 | PASS | first-appearance table complete; explanations in place |
| G10 | PASS | doc comments now verbatim; spot-diff re-clean |
| G15 | PASS | false claim removed |

Unchanged gates carry forward from r1 (G1, G3, G6, G8, G9, G11).

## Verdict rationale (r2)

Blocking finding fixed exactly as required; the cosmetic fidelity
note was also closed voluntarily. Zero unresolved blockers → **PASS**.
QA verdict only — approval belongs to Atlas.

---

## ATLAS DECISION — CONTENT_APPROVED

Atlas reviewed: `04-content-draft.md` + `lessons/` r2, Argus content
QA r1 FAIL + r2 PASS, and the remediation diff. QA-CONTENT-001 was
correctly identified as a real teaching defect (false prerequisite +
unexplained first appearance) and fixed without scope creep.

- 16-section shape verified per lesson; decomposition matches brief §6.
- Snippet fidelity to approved implementation: clean (verbatim).
- Deferrals correctly named (sealed→M15, rxdart/repo→M14, nav
  controller→D20, game events→M19).

**Decision: CONTENT_APPROVED — 2026-10-05.** Forge may integrate
`04-content-draft.md` + `lessons/` exactly as approved.
