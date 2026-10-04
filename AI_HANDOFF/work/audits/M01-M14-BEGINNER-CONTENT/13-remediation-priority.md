# 13 — Remediation Priority & Proposed Gates

Not executed. For supervisor/human review.

## Priority tiers

### P0 — prerequisite blockers before ANY M15 work
*(M15+ milestones all build on the repository/stream/contract foundation —
under-taught M14 propagates copy-work into M16–M24)*

- **P0-1 (F-06/F-07/F-08/F-10): M14 depth remediation.** Restore the full
  lesson template; add isolated examples; split M14/03. Concretely:
  - M14/01+: teach `abstract interface class`/`implements` with a toy
    `interface Storage { get/set }` + two impls *before* the real repo; add
    mental-model (contract = what, impl = how), common-mistakes, run-observe.
  - M14/02+: a standalone `BehaviorSubject<int>` counter example with a
    timeline diagram showing replay-vs-broadcast; full sections; move the
    `pumpEventQueue` gloss earlier.
  - Split M14/03 → M14/03a (settings/onboarding repos + UserProfileData
    parity incl. `?element`) and M14/03b (MultiProvider-by-contract + async
    bootstrap + fakes, each with isolated example + why).
  - M14/04: keep the strong state-vs-event table; add the dropped sections.
  - Fix the F-02-adjacent issue inside M14: the bài-1 "analyze clean"
    checkpoint is unreachable mid-milestone — either reorder the deletion to
    bài 4 or mark the checkpoint "end-of-milestone" explicitly.
- **P0-2 (F-04): teach `factory`** in M10/02 + remove false claim.
- **P0-3 (F-11, forward-looking): exercise requirement must exist as a gate
  before M15 lessons are authored** — otherwise M15 inherits the same
  read-copy-run shape.

### P1 — foundational depth (before further milestones, not blocking M15 gate itself)
- F-05 scaffold labeling at introduction (M03, M06 edits).
- Concept-registry + glossary creation (also fixes F-12).

### P2 — milestone-specific theory enrichment
- F-04 covered above; switch-statement mini-treatment in M09/03.

### P3 — active learning / reinforcement
- F-11 retro-fit: "Tự làm" exercises for existing 48 lessons (can roll in
  batches — not all needed pre-M15 if the *gate* exists for new lessons).
- Milestone-end synthesis tasks.

### P4 — presentation / site learning UX
- F-12 concept index page; IA-2 progression-map; scaffold badge.

## Proposed permanent governance (NOT activated)

New artifacts:
- `LEARNER_CONCEPT_REGISTRY` — every concept → where taught → depth status.
- `PREREQUISITE_GRAPH` — machine-checkable edges; lessons may not use a
  concept before its teaching node.
- `CONTENT_GAP_REGISTER` — this register, made standing.
- `BEGINNER_CONTENT_STANDARD` — depth requirements per concept tier.

Proposed gates (each: PASS condition / FAIL example / evidence / owner):

| Gate | PASS | FAIL example | Evidence | Owner |
|------|------|--------------|----------|-------|
| BEGINNER_CONCEPT_DEPTH | every new concept hits required 10-level subset for its tier (core Flutter = L1–L8 + L10; isolated example L9 where non-obvious) | `factory` with a one-line gloss | coverage matrix row | Argus |
| PREREQUISITE_CLOSURE | every "Bạn đã biết gì" claim resolvable to a real earlier lesson | "đã học async* ở M06" | grep-verified ledger | Argus |
| MENTAL_MODEL | every core concept has an explicit mental-model section | M14/02's absent MM section | section presence + QA read | Argus |
| INDEPENDENT_TRANSFER | ≥1 isolated non-project example OR exercise per core concept | BehaviorSubject only inside repo | example exists in lesson | Lumen→Argus |
| ACTIVE_LEARNING | every lesson has ≥1 produce-something task (exercise, predict-and-verify, bug-spot) | read→copy→run only | exercise block present | Argus |
| LESSON_COGNITIVE_LOAD | ≤3 major new concepts per lesson; >3 requires split justification | M14/03's 5+ | concepts-listed vs threshold | Atlas |
| TEMPLATE_COMPLETENESS | all mandated sections present & non-empty | M14's dropped sections | template lint | Forge/Argus |
| SEQUENTIAL_EXECUTABILITY | each lesson's checkpoint reachable by following lessons in order | M14/01 "analyze clean" | simulated follow-along | Argus |

## Recommended rebuild strategy — **OPTION D (hybrid)**

Evidence: M01–M13 need only **targeted enrichment** (Option A: scaffold labels,
factory section, stale-ref fixes, retro exercises) — Option B/C's theory-first
restructure is already what those lessons mostly do. M14 alone needs **Option C**
treatment (theory → isolated example → project impl → exercise) plus the
M14/03 split. Future milestones adopt the full candidate model below.

## Recommended lesson model (for M15+)

Mục tiêu → vì sao → đã biết (verified) → **concept theory + mental model** →
syntax anatomy → **tiny isolated example** → Android bridge → senior evidence →
guided implementation → why-each-line → mistakes → experiment → **exercise
(produce, not just answer)** → recap/self-check → checkpoint → deferred list.
This is the existing template + 2 additions (isolated example, exercise) +
enforcement. Beginner-friendly means models/examples/recall, not more prose.
