# Artifact 06 — Lumen Content Output

## M01–M13 targeted remediation (wholesale rewrite refused — Step-12
verdict was NEEDS_SYSTEMATIC_ENRICHMENT, and 44/48 lessons were
already strong)

| Fix | File | Change |
|---|---|---|
| F-01 stale named-route | `m09/03` | wording corrected — senior has no named routes; label no longer promises a later milestone |
| F-02 `clear`→`reset` | `m10/01` | checkpoint now names `reset()` — matches the post-Step-10 method name the body already used |
| F-03 false async*/yield prereq | `m13/01` | claim removed — M06 only listed `async*` under "cố ý chưa làm"; sentence now says stream-listen was taught, not async generation |
| F-04 `factory` first-use | `m10/02` | deleted false "đã thấy ở course Dart" claim; added dedicated section: generative vs factory, returns-existing, why `create()`/`fromMap` fit, Kotlin companion-object bridge, when NOT to use, tiny non-project example |
| F-05 scaffold visibility | `m03/01`, `m06/01` | TEACHING SCAFFOLD callouts at introduction (not only at M13 retirement): why it exists, what it teaches, how it differs from senior, convergence milestone |
| F-09 pumpEventQueue | `m14/06` | first-use site now carries the API explanation inline before the test code |
| F-11 independent production | last lesson of M01–M13 | `Tự làm` block appended to each: m01/03, m02/04, m03/03, m04/04, m05/03, m06/03, m07/03, m08/04, m09/04, m10/04, m11/03, m12/03, m13/03 — progression RECOGNIZE→PREDICT→MODIFY→PRODUCE→DEBUG; hint-then-solution pattern, no instant answers |
| synthesis checkpoints | `m01`–`m14` `index.md` | 5-question checkpoint appended: what did I learn / can I explain / can I write without copying / what-if / which concept returns later |

## M14 structural rebuild (4 → 7 lessons)

Full sequence in `05-m14-restructure-plan.md`. Every new lesson runs
Template V2 CORE_CONCEPT sections where required:

- `01` motivation — storage primitive vs application boundary
- `02` `abstract interface class`/`implements`/contract-first +
  **isolated `Counter` example before production code** (F-07)
- `03` state-stream mental model — plain Stream vs broadcast event vs
  `BehaviorSubject`/`ValueStream`; replay semantics; `.value`;
  ownership/dispose; **isolated `dart run` example** (F-07)
- `04` `UserProfileRepositoryImpl` — private ctor + async `create()`,
  emit guards; additive (app still on ProfileStore → compiles)
- `05` settings/onboarding repetition + model parity — `?element`,
  language whitelist marked temporary→M17, `expForNextLevel`→M22
- `06` DI by contract — bad-direction vs contract-direction sketch,
  `Provider<Contract>.value`, `MultiProvider`, create-vs-value,
  bridge scope state (fakes + 4-arg ctor)
- `7` VM migration — `.value` seed + ctor subscription, delete
  `MenuLoadState`/`ProfileStore`/`totalEarningsDisplay`, test
  convergence. Deletion last → every mid-milestone checkpoint
  compiles (fixes the old F-06/F-08 defect).

Each M14 lesson carries `Tự làm`: contract-writing (2), late-
subscriber prediction (3), emit-guard reasoning (5), fake-wiring (6),
data-flow narration without reading code (7).

## Voice rules applied

Vietnamese teacher-register; no "simply/obviously"; Android as bridge
not substitute; general-Dart vs senior-implementation claims kept
distinct; temporary scaffolds carry convergence milestones.
