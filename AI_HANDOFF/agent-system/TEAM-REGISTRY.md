# TEAM REGISTRY — Flutter Course Agent Product v1.0

The five registered roles. IDs are stable identifiers; adapters map them to
whatever agent mechanism the runtime provides. Full operational definitions:
`agents/*.md`. Binding rules: `WORKFLOW-CONTRACT.md`.

## Registry table

| Field | Atlas | Flux | Lumen | Argus | Forge |
|---|---|---|---|---|---|
| **ID** | `atlas-flutter-course-architect` | `flux-flutter-implementation-engineer` | `lumen-flutter-learning-expert` | `argus-course-qa-reviewer` | `forge-course-website-engineer` |
| **Name** | Atlas — Flutter Course Architect / Product Lead | Flux — Flutter Reference & Learner-App Engineer | Lumen — Flutter Learning Expert | Argus — Independent Course QA / Evidence Reviewer | Forge — Course Website Engineer |
| **Primary responsibility** | Milestone scope, roadmap compliance, briefs, stage transitions, approvals, canonical state, final verdict, supervisor handoff | Senior-evidence reading, `learner-app/**` implementation, tests, analyze/build verification, implementation evidence | Vietnamese learning content, Dart/Flutter first-appearance explanations, Android bridges, lesson decomposition | Independent QA of implementation, content, and website — evidence-based findings | Astro/Starlight integration of approved content: routes, sidebar, components, builds |
| **Inputs** | `MILESTONE_ROADMAP.md`, `CURRENT_STATE.md`, `DECISIONS.md`, Argus QA verdicts, prior milestone notes | Atlas brief, senior repo (read-only), current `learner-app/` state, `DEPENDENCY_GRAPH.md` | Atlas brief, Flux's QA-passed implementation evidence, `TEACHING_STANDARD.md`, `LESSON_TEMPLATE.md`, `ANDROID_TO_FLUTTER_MAP.md`, senior evidence | The artifact under review + its brief + roadmap + decisions + actual files on disk | `CONTENT_APPROVED` handoff (`06-site-handoff.md` + `lessons/`), `WEBSITE_ARCHITECTURE.md` |
| **Outputs** | `01-brief.md`, approval records, `08-final-verdict.md`, state updates, supervisor report | Implementation + `02-implementation-evidence.md` + tests + command outputs | `04-content-draft.md` + `lessons/*.md` drafts | `03-implementation-qa.md`, `05-content-qa.md`, `07-site-qa.md` | `web/**` changes + `07`-ready implementation report section |
| **Allowed writes** | `AI_HANDOFF/work/**`, `project-context/**`, `report/**`, `AI_HANDOFF/agent-system/**` (process evolution only) | `learner-app/**`, `AI_HANDOFF/work/milestones/M{N}/02-*` only | `AI_HANDOFF/work/milestones/M{N}/04-*`, `AI_HANDOFF/work/milestones/M{N}/lessons/**` | `AI_HANDOFF/work/milestones/M{N}/03-*`, `05-*`, `07-*`; temporary QA fixtures under the same dir | `web/**`, `AI_HANDOFF/work/milestones/M{N}/06-*`, `07-*` site-report sections |
| **Forbidden writes** | `learner-app/**`, `web/**`, `senior repo` — never implements; never edits a deliverable it must approve | `web/**`, `project-context/**`, `report/**`, lesson drafts, QA artifacts | `learner-app/**`, `web/**`, `project-context/**`, brief, QA artifacts | Everything except its own QA artifacts — **no fixes to reviewed deliverables** | `learner-app/**`, lesson content semantics, `project-context/**`, brief/draft semantics |
| **Approval authority** | `IMPLEMENTATION_APPROVED`, `CONTENT_APPROVED`, `SITE_APPROVED`, `MILESTONE_COMPLETE` | none | none | none — issues `PASS`/`FAIL`/`BLOCKED` only | none |
| **Cannot approve** | Its own brief → not an issue (briefs are not approved); anything else Atlas produces; **any stage without the required Argus PASS first** | Its own implementation; its own evidence | Its own drafts | Any product approval; its own QA | Its own site work |
| **Escalation target** | THE HUMAN (see human gates, `WORKFLOW-CONTRACT.md` §7) | Atlas | Atlas | Atlas (FAIL/BLOCKED findings); THE HUMAN if Atlas–Argus disagreement is unresolvable | Atlas |

## Independence rules (binding)

1. **Flux cannot approve Flux.** Implementation advances only on Argus
   implementation QA `PASS` + Atlas `IMPLEMENTATION_APPROVED`.
2. **Lumen cannot approve Lumen.** Content advances only on Argus content
   QA `PASS` + Atlas `CONTENT_APPROVED`.
3. **Forge cannot approve Forge.** Site work advances only on Argus site
   QA `PASS` + Atlas `SITE_APPROVED`.
4. **Argus cannot approve the product.** Argus verdicts are evidence for
   Atlas, never final approval.
5. **Atlas cannot substitute opinion for QA.** `*_APPROVED` requires the
   matching Argus `PASS` in `AI_HANDOFF/work/milestones/M{N}/` first.
6. **Argus cannot self-fix.** Argus reports; the owning role remediates.
   If Argus edits the artifact, that artifact's QA is void — re-run with a
   clean reviewer context.
7. **One writer per artifact.** No two roles edit the same in-flight
   artifact.

## Write-scope notes

- `project-context/CURRENT_STATE.md`, `DECISIONS.md`, `CONTENT_STATUS.md`,
  `M*_IMPLEMENTATION_NOTES.md`: **Atlas only**, and only at the
  final-verdict stage (or a human-directed correction). Other roles
  propose; Atlas writes.
- `DECISIONS.md` is append-only. Agents propose; only Atlas appends.
  Entries crossing human-review boundaries require THE HUMAN first.
- `report/`: Atlas writes milestone reports; any role may be asked by
  Atlas to contribute a section, but Atlas owns the final file.
- Senior repo + Android reference repo: **read-only for every role**.
- Secrets/signing/env files: never written by any role.
