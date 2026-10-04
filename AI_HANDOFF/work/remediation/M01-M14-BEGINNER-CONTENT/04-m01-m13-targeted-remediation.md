# Artifact 04 — M01–M13 Targeted Remediation (Lumen pass)

Targeted enrichment only — Step 12 found M01–M13 pedagogically strong;
no wholesale rewrite. Changes applied:

## F-01 — M09/03 stale named-route reference → RESOLVED_BY_CONTENT

`m09/03-showdialog-va-popuntil.md`: corrected the named-route wording.
Senior app has NO named routes (M07 explicitly excludes them); the
forward reference now points at the navigation-controller concept
instead of "named routes in M14" (M14 is the repository milestone).

## F-02 — M10/01 stale `clear` → `reset` → RESOLVED_BY_CONTENT

`m10/01-sharedpreferences-va-profile-store.md`: checkpoint now says
`reset()` matching the actual `ProfileStore.reset()` API (renamed
during Step-10 remediation).

## F-03 — M13/01 false `async*`/`yield` prerequisite → RESOLVED_BY_CONTENT

`m13/01-event-khong-phai-state.md`: the "Bạn đã biết gì" bullet claimed
`async*`/`yield` was taught in M06 — it was only listed under M06's
"cố ý chưa làm". Rewritten to not claim prior teaching; PREREQUISITE_GRAPH
records `async*`/`yield` as PLANNED (first real teaching node = first
milestone needing it).

## F-04 — `factory` first-appearance gap → RESOLVED_BY_CONTENT

`m10/02-json-tomap-frommap.md`:
- Fixed "Bạn đã biết gì" bullet — `factory` is first-appearance, not
  prior knowledge.
- Added a full `## Dart mới: factory constructor` section before first
  use: generative ctor recap, what `factory` changes (can return
  existing/precomputed instance), `Point.fromList` isolated example,
  private `._` companion ctor, when NOT to use factory, Kotlin bridge
  (≈ companion `fun fromX`), connection to `fromMap`.

## F-05 — scaffolds not visibly temporary at introduction → RESOLVED_BY_CONTENT

Added `:::caution[TEACHING SCAFFOLD]` callouts at the *first
introduction* of each scaffold:

- `m03/01-stateless-va-stateful.md` — `_soundOn`/`_playTapCount`:
  explains senior has neither (sound = settings switch M16; play opens
  game), retirement at M13, FR-20/FR-21 register links.
- `m06/01-stream-la-gi.md` — `menuSessionTicker`: artificial stream
  whose real successor is the repository `userProfileStream` (M14),
  FR-22.

Both callouts state: why it exists, what concept it teaches, how it
differs from senior product, and the exact retirement milestone.

## F-11 — no independent-production exercises → RESOLVED_BY_CONTENT

Added `## Tự làm` to the final lesson of each milestone M01–M13
(M14 exercises embedded in the rebuilt lessons). Progression follows
RECOGNIZE → PREDICT → MODIFY → PRODUCE → DEBUG:

| Milestone | Type | Task |
|---|---|---|
| M01 | PREDICT | hot-reload vs restart for `main()` change |
| M02 | MODIFY | 4th `_StatTile`, spacing — constraint reasoning |
| M03 | PRODUCE | `_MuteDot` widget (value + callback) from scratch |
| M04 | PRODUCE | new `copyWith` tests incl. fail-first regression |
| M05 | PRODUCE | `loadCoinBonus()` Future; `await` vs `.then` |
| M06 | PREDICT | broadcast add/listen/cancel output |
| M07 | MODIFY | second pop button + stack prediction + `maybePop` |
| M08 | PRODUCE | widget test CHƠI→route via `NavigatorObserver` |
| M09 | DEBUG | timer-leak `setState() after dispose` fix |
| M10 | PRODUCE/DEBUG | `reset()` + corrupt-json tests |
| M11 | PRODUCE | `notifyListeners` count test; silent-state bug |
| M12 | MODIFY | `FakeClock` ChangeNotifier + watch vs read |
| M13 | PREDICT | late-listener on broadcast vs BehaviorSubject |
| M14 | PRODUCE×3+ | `CounterRepository`/`StopwatchRepository` contracts (L2), replay prediction (L3), corrupt-json repo test (L4), `OnboardingRepository` from memory (L5), `FakeOnboardingRepository` + DI-direction reasoning (L6), data-flow explanation + late-subscriber widget test (L7) |

All exercises use the hint → `<details>` collapsible-answer policy
(static site, no backend).

## Synthesis checkpoints

Added `## Tổng kết M0x — tự kiểm tổng hợp` to all 14 milestone index
pages: learned / can-explain / can-write-without-copying / what-if /
needed-later, each tailored to the milestone's concepts.

## Files touched

- `web/src/content/docs/m03/01-stateless-va-stateful.md` (scaffold badge)
- `web/src/content/docs/m06/01-stream-la-gi.md` (scaffold badge)
- `web/src/content/docs/m09/03-showdialog-va-popuntil.md` (F-01)
- `web/src/content/docs/m10/01-sharedpreferences-va-profile-store.md` (F-02)
- `web/src/content/docs/m10/02-json-tomap-frommap.md` (F-04 + section)
- `web/src/content/docs/m13/01-event-khong-phai-state.md` (F-03)
- `web/src/content/docs/m01..m13/index.md` (synthesis ×13)
- Tự làm blocks: m01/03, m02/04, m03/03, m04/04, m05/03, m06/03,
  m07/03, m08/04, m09/04, m10/04, m11/03, m12/03, m13/03.

**No learner-app changes.** No senior-repo changes.
