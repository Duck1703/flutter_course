# M14 — Content Draft (Lumen)

Milestone: M14 — Repository contracts & rxdart BehaviorSubject
Author: Lumen · Date: 2026-10-02 · Revision: r1
Basis: `02-implementation-evidence.md` r1 (Argus PASS +
IMPLEMENTATION_APPROVED recorded in 00-status.md). All code snippets
quoted verbatim from the learner app on disk.

## Deliverables

`AI_HANDOFF/work/milestones/M14/lessons/`:

| File | Route (after Forge) | Scope |
|---|---|---|
| `index.md` | `/m14/` | overview, lesson table, concepts, completion criteria |
| `01-vi-sao-profilestore-chua-du.md` | `/m14/01-vi-sao-profilestore-chua-du/` | contract vs storage; `abstract interface class`+`implements`; `create()` async factory; explicit `profile_store.dart` deletion |
| `02-rxdart-behavior-subject-valuestream.md` | `/m14/02-rxdart-behavior-subject-valuestream/` | rxdart `^0.28.0`; `BehaviorSubject.seeded`; `ValueStream`; `.value` vs `.stream`; replay; `isClosed`+equality emit guards; `dispose` |
| `03-ba-repository-va-multiprovider.md` | `/m14/03-ba-repository-va-multiprovider/` | 3 repos table; `MultiProvider`+`Provider<Contract>.value`; `main()` bootstrap + `loadUserSettings`; `UserProfileData` parity (fields, `?avatarUrl`, deep parse, legacy purge); `FakeUserProfileRepository` |
| `04-menuviewmodel-noi-vao-stream.md` | `/m14/04-menuviewmodel-noi-vao-stream/` | ctor `.value`+`listen`; `_handleUserProfile` guards; writers no longer set state; **state stream ≠ event stream** table; `MenuLoadState`/`_MenuLoading`/`_MenuErrorState` retirement; stream-propagation tests |

## Fidelity & framing rules applied

- **First-appearance teaching:** `abstract interface class`,
  `implements`, `BehaviorSubject`, `ValueStream`, `.value`,
  `isClosed`, `MultiProvider`, `?avatarUrl` null-aware element —
  each explained at first real use (Kotlin analogy used per roadmap
  bridge format: SIMILARITY + IMPORTANT DIFFERENCE + DO NOT ASSUME;
  `BehaviorSubject` never equated to `StateFlow`).
- **Honest evolution narrative:** M10 `ProfileStore` framed as the
  storage *primitive* that M14's repository absorbs; deletions are
  explicit instructions (profile_store.dart, profile_store_test.dart,
  `_MenuLoading`, `_MenuErrorState`, `MenuLoadState`, `load()`).
- **Register truth:** FR-08/FR-09/FR-19 marked CONVERGED in lessons;
  FR-26 (`languageCode` whitelist → M17) named; `expForNextLevel`
  still flagged temporary → M22 (FR-01); reset button/snackbar still
  temporary → M24 (FR-11/FR-12); FR-04 noted as partially improved.
- **Event-vs-state distinction** taught as a two-column table (M13
  broadcast controller vs M14 BehaviorSubject/ValueStream) — the
  milestone's most confusion-prone point.
- **No invented senior claims:** every senior reference cites the
  verified file/symbol (`MenuScreenViewModel`, `AppDependencyScope`
  MultiProvider, `FakeGameProfileRepository` in
  `game_screen_test_helpers.dart`, `..loadUserProfile()` cascade).
- **No premature content:** no sealed types beyond the "still M15"
  note, no settings/onboarding UI, no GameViewModel/DRE, no auth,
  no advanced RxDart operators — each deferred item is named in a
  "Ta cố ý chưa thêm" section.
- Language: Vietnamese, beginner-first, consistent with M01–M13 tone;
  code fences carry the real M14 snippets.

## Known editorial notes

- `main()` doc comment says the profile repo is not preloaded (senior
  parity: menu VM owns it) — lessons repeat this to avoid the learner
  "fixing" it.
- Test-count change (52 → 69) explained in impl evidence §5; lesson 4
  attributes the new tests to stream-propagation coverage.
