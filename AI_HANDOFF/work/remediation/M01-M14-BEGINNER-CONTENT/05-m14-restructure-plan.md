# Artifact 05 — M14 Restructure Plan & Execution

## Before (Step-12 state)

Four production lessons, ~150–220 lines each, no `Mental model`/
`Lỗi hay gặp`/`Chạy và quan sát`/`Tự làm` sections, and one broken
sequential checkpoint (L1 deleted `profile_store.dart` then claimed
`flutter analyze` clean while `MenuViewModel` still imported it).

## After — 7-lesson sequence

| # | File | Concepts carried | Load |
|---|------|------------------|------|
| 1 | `01-vi-sao-profilestore-chua-du` | Repository mental model: storage vs boundary, dependency direction | 1 major (architecture) — theory only, no code changes |
| 2 | `02-contract-abstract-interface-implements` | `abstract interface class`, `implements` vs `extends`, `static Future create()` (factory-for-async); writes contract file + rxdart dep | 2 Dart concepts, isolated CounterRepository example first |
| 3 | `03-stream-state-behavior-subject-value-stream` | `BehaviorSubject.seeded`, `.value` vs `.stream`, `ValueStream` read-face, `isClosed`/`close`, state-vs-event table | 1 concept-family, isolated counter demo + prediction exercise |
| 4 | `04-user-profile-repository-impl` | impl: private `._` + `create()`, seeded subject, `_emitUserProfile` guards, load/save/reset/dispose; repo test file | Application — no new concepts |
| 5 | `05-hai-repo-con-lai-va-model-parity` | settings+onboarding repos (pattern repetition), `UserSettingsData`, `UserProfileData` FR-19 parity | Repetition + data-model work |
| 6 | `06-di-theo-contract-multiprovider-va-fake` | DI by contract (`Provider<Contract>.value`), `MultiProvider`, bootstrap ordering, fake repositories | 1 major (DI) + fakes |
| 7 | `07-menuviewmodel-noi-vao-stream` | VM ctor `.value` seed + `listen`, handler/dispose, writers-via-repo, retire `MenuLoadState`, delete `profile_store.dart`, stream-propagation tests | Application + integration |

Maps to the supervisor's suggested A–G sequence ~1:1
(A→1, B→2, C→3, D→4, E→6(+5), F→7, G→7).

## Sequential-executability design (the F-critical fix)

| After lesson | learner-app state | analyze |
|---|---|---|
| 1 | unchanged | clean |
| 2 | +rxdart dep, +contract file only | clean (additive) |
| 3 | unchanged (theory) | clean |
| 4 | +impl in same file (unreferenced by app) | clean; repo test green |
| 5 | +settings/onboarding repos, +UserSettingsData, UserProfileData parity (`totalEarnings` added WITH default; `totalEarningsDisplay` kept until L7) | clean |
| 6 | scope = MultiProvider[3 contracts + ProfileStore BRIDGE]; main creates repos AND store; fakes added; scope-signature tests updated | clean; app runs on old path |
| 7 | VM→contract; scope/main drop ProfileStore; `profile_store.dart` + its test deleted LAST; event/VM/widget tests updated to fake | clean; full suite green |

Key ordering rule now explicit in lessons: **delete only after no
consumer remains** — migrate → withdraw bridge → delete. The old
L1 deletion+analyze-clean checkpoint is gone.

## Concept load check (G-gate LESSON_COGNITIVE_LOAD)

- No lesson carries > 2 new major concepts.
- L4–L7 carry zero NEW concept families — application/integration.
- Isolated examples precede production use for: `abstract interface
  class`/`implements` (L2 CounterRepository), `factory`-async (L2),
  `BehaviorSubject`/`ValueStream`/`.value` (L3 counter demo), DI by
  contract (L6 bad-direction contrast), `MultiProvider` (L6 nested
  vs gom), fake repos (L6 before VM test use in L7).
- Independent production: L2 (contract for a new domain), L3 (replay
  prediction), L4 (corrupt-json test), L5 (onboarding repo from
  memory), L6 (fake + DI-direction reasoning), L7 (data-flow
  explanation + late-subscriber widget test).

## What changed vs old content

- Repository mental model promoted from a paragraph inside old L1 to
  a dedicated theory lesson (L1) with isolated CounterRepository
  thought exercise.
- `ValueStream` forward-referenced in L2 ("bài sau mở nó") — taught
  fully in L3 before impl writes it.
- `pumpEventQueue` glossed at first use in L4 test (was unexplained
  until L4/04).
- MultiProvider/DI gets its own lesson (L6) with bad-direction
  contrast — was compressed into old L3 alongside model parity.
- Deletion moved to L7 — the sequential-executability fix.
