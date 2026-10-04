# Content Gap Register (canonical)

Promoted from `AI_HANDOFF/work/audits/M01-M14-BEGINNER-CONTENT/12` at Step-13.
Tracks pedagogical gaps. No blocking gap may silently disappear: an entry is
RESOLVED only with QA evidence, or ACCEPTED_NONBLOCKING only with an explicit
Atlas decision recorded in DECISIONS.md.

Status: OPEN / IN_PROGRESS / RESOLVED / ACCEPTED_NONBLOCKING.

| ID | Concept | Lesson | Severity | Gap type | Learner risk | Required remediation | Status | Blocks | QA evidence |
|----|---------|--------|----------|----------|--------------|----------------------|--------|--------|-------------|
| F-01 | named-route label | m09/03 | LOW | stale reference | wrong roadmap expectation | fix label (senior has no named routes) | RESOLVED | — | Step-13 Argus QA |
| F-02 | `reset` name | m10/01 | LOW | stale checkpoint | nonexistent method in checklist | `clear`→`reset` | RESOLVED | — | Step-13 Argus QA |
| F-03 | async*/yield claim | m13/01 | LOW | false prereq | learner hunts missing lesson | remove claim | RESOLVED | — | Step-13 Argus QA |
| F-04 | `factory` ctor | m10/02 | MEDIUM | prereq missing + thin | syntax used untaught | dedicated factory section + example | RESOLVED | M15 prereq hygiene | Step-13 Argus QA |
| F-05 | scaffold visibility | m03/01, m06/01 | MEDIUM | scaffold unmarked | learner can't tell temp vs product | TEACHING SCAFFOLD callouts at introduction | RESOLVED | — | Step-13 Argus QA |
| F-06 | M14 template regression | m14/01–04 | HIGH | sections dropped | mental-model loss on hardest content | rebuild M14 under Template V2 | RESOLVED_BY_STRUCTURE | M15 | 10-sequential-replay + 13-reaudit |
| F-07 | no isolated examples | m14 | HIGH | example missing | concepts bound to production code | isolated example per CORE_CONCEPT | RESOLVED_BY_CONTENT | M15 | 08-argus-content-qa |
| F-08 | M14/03 overload | m14/03 | MEDIUM→HIGH | cognitive overload | working-memory failure | split into 2+ lessons | RESOLVED_BY_STRUCTURE | M15 | 05-m14-restructure-plan |
| F-09 | pumpEventQueue order | m14/02→/04 | LOW | use-before-teach | unexplained API in test | teach at first-use site (M14/06) | RESOLVED | — | Step-13 Argus QA |
| F-10 | `?element` + parity compressed | m14/03 | MEDIUM | theory shallow | new syntax buried | own room in M14/04 model-parity lesson | RESOLVED_BY_STRUCTURE | — | 08-argus-content-qa |
| F-11 | no independent production | all | HIGH | active learning missing | no transfer, no independence | exercise per milestone + synthesis checkpoints + gate | RESOLVED_BY_GOVERNANCE+CONTENT | M15 | 04-targeted + 11-smoke-test |
| F-12 | no concept index | site | LOW | IA gap | can't revisit concepts | concepts/ section + progression page | RESOLVED_BY_LEARNING_UX | — | 09-forge-learning-ux |

| F-13 | use-before-create `NotificationTimePicker` | m16/04→05 | HIGH | sequential executability | L04 code imports/uses a file only created in L05 → L04 `analyze` checkpoint unreachable | move `timePickerVisible` branch + import into L05; L04 omits them | RESOLVED | M16 | 09-sequential-replay (L04 82/82; L05 87/87) + Argus content re-verify r3 |
| F-14 | test files never created in lessons | m16/03–05 | HIGH | sequential executability | `settings_view_model_test.dart` required at L03 checkpoint and `settings_dialog_test.dart` at L04/L05 have no creation step; `sealed_state_test.dart` exhaustiveness broken by `MenuSettingsRequested` with no fix step | add creation steps: L03 (VM test), L04 (sealed-state arm + menu VM test), L05 (widget test) + guard L04 run-command | RESOLVED | M16 | 09-sequential-replay + Argus content re-verify r3 (residual L04 run-cmd guarded) |
| F-15 | `import supported_language_data.dart` missing in M17/03 Bước 1 | m17/03 | MEDIUM | sequential executability | learner applies whitelist helper → `SupportedLanguageData` undefined → L03 `analyze` checkpoint fails | add import instruction + `///`→`//` header note (dangling_library_doc_comments) | RESOLVED | M17 | M17 sequential replay (L03 clean+87/87 post-fix) |

| F-16 | M26 lesson concept-ID labels `F-33`/`F-34` vs registry `A-33`/`A-34` | m26/01–05 | LOW | label mismatch | learner tra cứu registry theo F-33/F-34 không thấy (canonical IDs là A-33/A-34 — effects-stream→bridge / async-op boundary) | mechanical rename F-33→A-33, F-34→A-34 trong m26 lesson pages tại M29 final-alignment pass (M27+ lessons already cite A-33/A-34 đúng); registry F-family IDs F-35..F-37 allocated to M27 — F-33/F-34 remain unregistered labels | OPEN | M29 | — |

## Register discipline (for all future work)

- Every QA finding about *teaching quality* gets a row here (in addition to
  the stage artifact).
- `Blocks milestone` names the earliest milestone the gap must precede;
  unresolved blockers hold that milestone.
- Argus verifies RESOLVED claims against the site/lessons, not the register's
  own assertions.
