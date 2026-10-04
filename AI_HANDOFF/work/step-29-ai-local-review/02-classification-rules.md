# Step 29 · 02 — Classification Rules (internal)

## REVIEW_REQUIRED vs NO_REVIEW

REVIEW_REQUIRED iff the lesson creates a MANDATORY observable delta in
the learner project: source file added/edited, widget/class/contract
added, state ownership changed, navigation/dependency/config/test
change, or runtime behavior introduced.

NO_REVIEW iff the lesson is purely: mental model / analogy / syntax
reading / observation of senior code / knowledge check / discussion —
with NO mandatory project delta. Not chosen for convenience.

## Review modes

- DELTA_REVIEW — focused change (model, field, widget, method, test file).
- INTEGRATION_REVIEW — connects multiple previously taught parts
  (DI wiring, stream→VM, navigation integration, repo wiring).
- MILESTONE_GATE — broader cumulative checkpoint at end-of-stage where
  drift risk is high. Not automatically every last lesson; evidence-based.
  Gates selected: m05/03 (Phase A end), m10/04 (persisted playable game),
  m12/03 (Provider DI seam), m14/07 (repo+DI complete), m19/06 (game VM),
  m22/05 (local feature-complete), m25/05 (sync), m26/06 (DRE), m28/06
  (visual), m29/07 (final cumulative gate).

## Strict vs semantic contract

STRICT = name/signature/location later lessons build on (class names,
method signatures, file paths the course references, sealed variants,
provider keys). SEMANTIC = equivalent implementation acceptable.

## Prompt anatomy (REVIEW_REQUIRED)

Heading `## 🤖 AI Local — Kiểm tra project sau bài này` + one-line intro
+ single ```text fence containing: role line (Bạn là Project Alignment
Reviewer…), read-only contract (được/cấm lists), project-root rule
(BLOCKED_PROJECT_ROOT), scope rule (only EXPECTED STATE + INVARIANTS),
EXPECTED STATE bullets (3–10, verifiable), INVARIANTS NỀN (0–5),
strict/semantic + ahead/diverged classification rule, fixed OUTPUT
contract (lesson id locked, alignment/position/readiness, evidence,
FILES_MODIFIED_BY_REVIEW: NONE). No placeholders, no future lesson IDs,
no governance terms, no exercise solutions.

## NO_REVIEW presentation

Same heading + `**Không cần review project ở bài này.**` + one concise
honest reason. No fence.
