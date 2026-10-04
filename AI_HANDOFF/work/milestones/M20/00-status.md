# M20 — Lifelines & feature buttons

State: `MILESTONE_COMPLETE` — Step-16 long run ends here; hard stop
before M21 observed.

## Ledger

- Atlas brief written — `01-brief.md` (senior inspected live at
  c8eb860: `game_reducer_feature_flow.dart`, `game_lifeline_helper.dart`,
  `game_dre_state.dart`, `game_screen_data.dart`, `game_session_state_data.dart`,
  mapper `_buildFeatureButtons`/`_answerState`, VM `_aiAssistantDelay=700ms`,
  `handleFeatureClick` API, lifeline + help/confirm dialog widgets,
  ARB keys en+vi). Register: FR-07 advances (lifeline variants);
  FR-34 opened (icon/visual depth → M28); FR-33 stays reserved
  (GameShareResultEvent, unassigned). DRE stays M26; in-Stack
  dialogs stay M21; VM-side save stays M22.
- Flux implemented — `02-implementation.md`: 147/147 tests,
  analyze clean, web build green; verbatim senior ports
  (helper, poll math, `_canUseFeature`, AI 700ms+token guard,
  walk-away `won:false` via `resolvedResult`).
- Argus impl QA **PASS** — `03-implementation-qa.md`
  (FR-34 row registered, NITs remediated).
- Atlas **IMPLEMENTATION_APPROVED** — `04-implementation-approval.md`.
- Lumen authored 5 lessons + index + manifest — `04-content-draft.md`.
- Argus content QA r1 **FAIL** → remediated (sealed-variant
  staging redesigned: variants land with their UI arms; `_actions`
  poll arm; template sections; manifest coverage) → r2 **PASS** —
  `05-content-qa.md`.
- Atlas **CONTENT_APPROVED** — `06-content-approval.md`.
- Forge site integrated — `07-site-integration.md` (6 `/m20/`
  routes; sidebar Phase F; roadmap/homepage/state-progression/
  concepts updated; 108 pages).
- Argus site QA — r1 flagged FAIL on L04 source-vs-web divergence;
  reconciled as **stale-read artifact** via md5 (all 6 pairs
  byte-identical); residual `|| | |` nit fixed → **PASS** —
  `08-site-qa.md`.
- Atlas **SITE_APPROVED** — `09-site-approval.md`.
- Sequential replay **4/4 PASS** — `10-sequential-replay.md`
  (physical M19 clone: 126 → L02 131 → L03 141 → L04 147;
  build web green; final = production modulo comments/labels).
- Atlas final verdict **MILESTONE_COMPLETE** — `11-final-verdict.md`.
- Canonical sync — `CURRENT_STATE`, `CONTENT_STATUS` (M20 row),
  `SENIOR_FIDELITY_REGISTER` (FR-07 advanced; FR-34 open),
  `LEARNER_CONCEPT_REGISTRY` (D-35/D-36/F-28 TAUGHT),
  `M20_IMPLEMENTATION_NOTES.md` — all updated.
