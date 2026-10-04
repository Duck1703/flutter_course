# MILESTONE BRIEF — M{N}: ⟨name⟩

> Produced by: Atlas (`atlas-flutter-course-architect`)
> Basis: `project-context/MILESTONE_ROADMAP.md` + `CURRENT_STATE.md` + `DECISIONS.md`
> State on creation: `BRIEF_READY`

---

## 1. Scope (hard boundaries)

**This milestone does only:** ⟨one sentence⟩

**This milestone does not do:**
- ⟨excluded item — and the milestone that owns it⟩
- ⟨excluded item⟩

**Absolutely forbidden:**
- introducing future-milestone concepts as dependencies
- code/features not grounded in senior evidence or a recorded
  `IMPLEMENTATION DECISION`
- touching files outside the allow-list below

**Write allow-list (Flux):** ⟨paths/dirs Flux may change⟩

## 2. Roadmap contract

| Field | Value |
|-------|-------|
| Learner outcome | ⟨from roadmap⟩ |
| Visible project result | ⟨from roadmap⟩ |
| Prerequisites (must be closed) | ⟨roadmap prereqs + confirmation they're met⟩ |
| Dart introduced | ⟨list⟩ |
| Flutter introduced | ⟨list⟩ |
| Test targets | ⟨required test coverage⟩ |
| Completion criteria | ⟨from roadmap⟩ |

## 3. Starting state (verified, not remembered)

- End-of-M{N-1} learner app: ⟨what exists on disk⟩
- Test count entering: ⟨count⟩
- Known carryovers: ⟨any⟩

## 4. Senior evidence to inspect

| Topic | Path + symbol | What to verify |
|-------|---------------|----------------|
| ⟨feature⟩ | `lib/⟨path⟩` — `⟨symbol⟩` | ⟨what it demonstrates⟩ |

**Known unknowns** (must not be invented): ⟨list⟩

## 5. Simplification guidance

| Senior approach | Learner approach | Label |
|-----------------|------------------|-------|
| ⟨senior pattern⟩ | ⟨learner simplification⟩ | `TEACHING_SIMPLIFICATION` / keep |

## 5b. SENIOR FIDELITY CHECK (mandatory — gate G16)

| Field | Value |
|-------|-------|
| Senior source target | ⟨feature/surface this milestone converges toward⟩ |
| Files/symbols | ⟨senior `lib/…` paths + symbols inspected⟩ |
| Current learner difference | ⟨what learner does today vs senior⟩ |
| Permitted simplifications | ⟨explicitly allowed deviations, each labeled⟩ |
| Fidelity-register entries opened | ⟨new FR IDs added to `project-context/SENIOR_FIDELITY_REGISTER.md`, or NONE⟩ |
| Entries expected to close | ⟨FR IDs this milestone converges/removes, or NONE⟩ |
| Forbidden alternatives | ⟨senior behaviors that must NOT be replaced by course inventions⟩ |

Atlas must consult `SENIOR_FIDELITY_REGISTER.md` before writing this
section; Flux updates the register in `02-implementation-evidence.md`;
Argus independently verifies every row at QA.

## 5c. LEARNING DESIGN CHECK (mandatory — Step-13; gates G17–G24)

| Field | Value |
|-------|-------|
| New Dart concepts | ⟨each + depth LIGHT/NORMAL/CORE_CONCEPT⟩ |
| New Flutter concepts | ⟨each + depth⟩ |
| New architecture concepts | ⟨each + depth⟩ |
| Prerequisites | ⟨registry/graph nodes that must already be TAUGHT⟩ |
| Concepts being reinforced | ⟨registry IDs this milestone deepens⟩ |
| Independent exercise plan | ⟨≥1 production task per milestone; which lesson⟩ |
| Cognitive-load risk | ⟨concept count per planned lesson; split decisions⟩ |
| Lesson split decision | ⟨why this count; justification if any page >3 new majors⟩ |
| Sequential checkpoint strategy | ⟨what compiles/verifies at each lesson boundary⟩ |

Atlas consults `LEARNER_CONCEPT_REGISTRY.md` + `PREREQUISITE_GRAPH.md`
before writing this section; Lumen executes it; Argus enforces G17–G24.
Senior fidelity (§5b) and beginner learning (§5c) are **co-equal approval
dimensions** — a milestone cannot PASS one and fail the other.

## 6. Lesson-count guidance

⟨Expected lesson count + rough split, e.g. "3–4 lessons: setup / core /
verification"⟩ — Lumen owns final decomposition.

## 7. Done criteria (stage 2 exit)

- [ ] `flutter analyze` clean
- [ ] `flutter test` green: ⟨target⟩ tests total, incl. ⟨new coverage⟩
- [ ] `flutter build web` passes
- [ ] `02-implementation-evidence.md` complete per contract
- [ ] Completion criteria from §2 demonstrable in the app

## 8. Next step

```text
NEXT STEP (INTERNAL)
  Who: Flux
  Input: this brief + STATE: BRIEF_READY
  Output: learner-app changes + 02-implementation-evidence.md
```
