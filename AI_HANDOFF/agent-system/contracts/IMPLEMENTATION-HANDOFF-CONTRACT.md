# IMPLEMENTATION HANDOFF CONTRACT — Flux → (Argus, Lumen)

Flux produces `AI_HANDOFF/work/milestones/M{N}/02-implementation-evidence.md`
using `templates/implementation-evidence-template.md`. **Lumen may not
write final lessons until this artifact exists and has Argus `PASS` +
Atlas `IMPLEMENTATION_APPROVED`.**

## Required sections (all mandatory, in order)

1. **Milestone & scope** — milestone ID, roadmap line(s), brief allow-list.
2. **Starting learner state** — files/state at end of previous milestone
   (from disk, not memory).
3. **Target learner state** — what exists after this milestone.
4. **Senior evidence used** — path + symbol + evidence class
   (`SENIOR-EVIDENCE-CONTRACT.md`).
5. **Files changed** — table: path | new/modified | purpose.
6. **Concepts introduced** — each new Dart/Flutter concept now present in
   learner code, with whether it's a first course appearance.
7. **Deliberate simplifications** — each deviation from senior, labelled
   `TEACHING_SIMPLIFICATION`, naming the milestone where the real version
   arrives.
8. **Deferred concepts** — what was intentionally NOT introduced.
9. **Tests added/changed** — files, counts, what each proves.
10. **Verification commands + results** — exact commands and real outputs:
    `flutter pub get`, `flutter analyze`, `flutter test` (with count),
    `flutter build web`. Every performance/behavior claim here is
    `VERIFIED`/`NOT VERIFIED` explicitly.
11. **Known limitations** — honest list.
12. **Code snapshot notes** — how Lumen should present evolution vs prior
    milestone (what changed shape, what is new).
13. **Content-author guidance** — suggested lesson decomposition, first
    appearances needing explanation, bridge opportunities, traps to warn
    about. Guidance only — Lumen owns content decisions within the brief.

## Hard rules

- No `VERIFIED` without the command's actual output in the artifact.
- Every file in "files changed" must exist on disk at the stated path.
- If the implementation had to deviate from the brief, the deviation is
  recorded here and routed to Atlas — never silently absorbed.
- The artifact is Flux's only handoff channel: Lumen codes from this +
  the repo, not from asking Flux informally.
