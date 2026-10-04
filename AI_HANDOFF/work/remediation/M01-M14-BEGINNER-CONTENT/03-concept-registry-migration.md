# Artifact 03 — Concept Registry Migration

Maps the Step-12 concept inventory (76 concepts) into the permanent
`project-context/LEARNER_CONCEPT_REGISTRY.md`, with first-taught /
first-code-use / reinforcement / status columns.

## Migration rules applied

- Every concept gets: ID, category, first-introduced (lesson), first
  code-use, prerequisites, depth level, teaching status, reinforcement
  milestones, independent-exercise link, senior usage, status.
- Depth levels per BEGINNER_CONTENT_STANDARD: LIGHT / NORMAL /
  CORE_CONCEPT.
- Status after remediation (post-Lumen pass):
  - `factory` — INTRODUCED at M10/02 (was USED_BEFORE_TAUGHT).
  - `async*`/`yield` — stays PLANNED (never taught, never used; M13
    false claim removed).
  - `abstract interface class`, `implements`, `create()` —
    INTRODUCED M14/02 (isolated example before production code).
  - `BehaviorSubject`, `ValueStream`, `.value`, `isClosed`, `close()` —
    INTRODUCED M14/03 (isolated subject demo before repo code).
  - `MultiProvider`, DI-by-contract, `Provider<Contract>.value` —
    INTRODUCED M14/06 (bad-direction contrast + fake payoff).
  - `pumpEventQueue` — INTRODUCED M14/04 at first use in repo test.
  - Repository boundary mental model — INTRODUCED M14/01 as dedicated
    theory lesson (was embedded inside production-code prose).

## Registry → lesson enforcement

- `PREREQUISITE_GRAPH.md` carries the edges; the registry carries the
  status. Argus gate G18 fails any "Bạn đã biết gì" line citing a
  concept whose teaching node is later.
- "cố ý chưa làm" entries are NOT teaching nodes — enforced in graph
  edge rules.
- Scaffold fields (`_soundOn`, `_playTapCount`, `menuSessionTicker`)
  are recorded as INTRODUCED-scaffolds with retirement milestone
  (M13/M14) — visible at first appearance via TEACHING SCAFFOLD
  callout added in this remediation.

## Counts

- 76 concepts inventoried at Step 12 → all carried into registry.
- USED_BEFORE_TAUGHT at Step 12: 3 → post-remediation: 0
  (`factory` taught at first use; `async*`/`yield` claim removed;
  `pumpEventQueue` glossed at first use in M14/04).
