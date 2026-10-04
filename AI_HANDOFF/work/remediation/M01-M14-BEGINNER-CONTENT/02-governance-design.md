# 02 — Governance Design (Atlas)

## What was installed (all under `project-context/` unless noted)

| Artifact | Purpose |
|----------|---------|
| `LEARNER_CONCEPT_REGISTRY.md` | 60+ concept rows: depth level, first-taught milestone/lesson, first code, prereqs, reinforcement, exercise, status. Blocks code-before-theory. |
| `PREREQUISITE_GRAPH.md` | The real M01–M14 dependency chains (foundation/async/navigation/state/persistence) + edge rules + Step-13 repairs (factory, pumpEventQueue, async*). |
| `CONTENT_GAP_REGISTER.md` | Permanent gap ledger seeded with F-01…F-12 dispositions; blocking gaps can't vanish silently. |
| `BEGINNER_CONTENT_STANDARD.md` | LIGHT/NORMAL/CORE_CONCEPT depth; the 14-item CORE list; exercise policy; synthesis checkpoints; scaffold marker; load + sequencing rules. |
| `QUALITY-GATES.md` G17–G24 | BEGINNER_CONCEPT_DEPTH, PREREQUISITE_CLOSURE(learning), MENTAL_MODEL, INDEPENDENT_TRANSFER, ACTIVE_LEARNING, LESSON_COGNITIVE_LOAD, TEMPLATE_COMPLETENESS, SEQUENTIAL_EXECUTABILITY — each with PASS/FAIL/evidence/owner; wired into stage mapping. |
| `LESSON_TEMPLATE.md` → V2 | Adds isolated-example, experiment, `Tự làm`; depth-driven section requirements; declared merges for lighter lessons. |
| `TEACHING_STANDARD.md` | Pointer binding the new standard as co-equal. |
| `skills/course-content` (Lumen) | Registry/graph reading, depth assignment, decomposition cap, exercise rule, scaffold marking, sequential self-check. |
| `skills/course-qa` (Argus) | G1–G24; pedagogy pass: understand/explain/transfer/sequence/load/exercise. |
| `agents/lumen-*`, `agents/argus-*`, `agents/atlas-*` | Same duties encoded at identity level; forbidden-actions extended. |
| `templates/milestone-brief-template.md` §5c | Mandatory LEARNING DESIGN CHECK beside §5b SENIOR FIDELITY CHECK — co-equal approval dimensions. |

## Design choices

- **Registry is the single source of "where is X taught"** — fixes F-12's
  governance half and gives G18 something to check against.
- **Gates are enforceable, not advisory:** each names owner + evidence; Argus
  can FAIL a stage on any of G17–G24.
- **Scaffold rule lives in the standard + G16/G17** (not a separate gate):
  unmarked scaffold = blocking finding.
- **Sequential executability (G24)** is a real gate now: content QA must
  replay the sequence, closing the M14/01-class defect structurally.
- **Cognitive load (G22)** counts *new major concepts per page*, not lines —
  the metric that caught M14/03.

## Deliberately NOT done

- No gate added to `.claude/` adapter shims (they point at canonical files).
- No changes to senior repo, learner app behavior, or roadmap milestone
  semantics — governance wraps the pipeline, not the product.
