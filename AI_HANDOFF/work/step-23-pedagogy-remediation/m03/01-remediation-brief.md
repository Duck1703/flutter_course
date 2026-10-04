# M03 — STEP-23 REMEDIATION BRIEF (Atlas)

## Step-21 findings

F-H1: 1/3 lessons with `Tự làm`; zero isolated examples. M03 prose
audited STRONG (the widget-vs-State model is one of the course's best).
Preserve; add machinery only. **TEACHING SCAFFOLD `_soundOn`/`_playTapCount`
must be preserved intact** (FR-20/FR-21; retires M13) — new exercises use
it, never reframe it.

## Lessons

| Lesson | Depth | CORE first-teaching | V2 gaps | Action |
|---|---|---|---|---|
| `m03/01` Stateless vs Stateful | CORE_CONCEPT | F-04, D-08 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE +TỰ_LÀM (MODIFY, derived-state decision) |
| `m03/02` setState mechanism | CORE_CONCEPT | F-05 | no `Tự làm` (3 guided experiments exist but are guided, not unaided) | +TỰ_LÀM (PREDICT mechanism edge cases) |
| `m03/03` lifecycle + ownership | CORE_CONCEPT | F-06, A-02 | `Tự làm` exists; CORE lesson lacks domain-neutral isolated example (inline demo is minimal but production-coupled) | +ISOLATED_EXAMPLE (ownership) |

## Isolated examples

- `m03/01` — `LightSwitch`: standalone StatefulWidget (tap → `_on` flips
  icon). ~25 lines DartPad-Flutter; exercises createState/mutable State
  field/setState→rebuild without Millionaire names.
- `m03/03` — `ScoreBoard`/`ScoreChip`: parent-State-owns-`score` +
  stateless child (~30 lines); the ownership rule (A-02) demonstrated
  domain-neutral before the ownership section.

## Constraints

- No Provider/ChangeNotifier (M11/M12 firewall); no `initState`/`dispose`
  usage beyond what's shown; no Navigator.
- New widgets in exercises must be added/removed by the learner with
  restore instructions; scaffold fields `_soundOn`/`_playTapCount` keep
  exact semantics.
- Files allowed: `web/src/content/docs/m03/{01,02,03}*.md`.
