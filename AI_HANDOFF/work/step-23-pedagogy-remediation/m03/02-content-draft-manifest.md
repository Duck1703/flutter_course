# M03 — CONTENT DRAFT MANIFEST (Lumen)

## CONTENT_REVISION (frozen)

| File | Blob SHA |
|---|---|
| `m03/01-stateless-va-stateful.md` | `11c6b2b0e659ec9e3b0495c51ba479c529da0ffe` |
| `m03/02-setstate-va-rebuild.md` | `937d4b675dc7a78d8f2cb6aacd4b95fc89352d58` |
| `m03/03-lifecycle-callbacks-va-state-ownership.md` | `2b7695c0d53adfbda8523360dd748a82d18eb4ca` |

## Per-lesson delta

| Lesson | Strengths preserved | Missing V2 element | Change type | CORE | Level | Learner decision | Verification | Tech/senior claims |
|---|---|---|---|---|---|---|---|---|
| m03/01 | widget-vs-State table (course's strongest model), scaffold caution (FR-20/21 untouched), Compose bridge | isolated example + `Tự làm` | ISOLATED_EXAMPLE + TỰ_LÀM | F-04, D-08 | MODIFY | source-state vs derived-state decision + where to compute | parity caption in `_PlayButton` shows chẵn/lẻ on taps | NONE (scaffold preserved) |
| m03/02 | 3-experiment structure, mechanism model, Compose bridge | `Tự làm` | TỰ_LÀM | F-05 | PREDICT | 4 edge cases: mutation-outside-closure, double-setState, setState-in-build, setState-in-initState | verify each via debugPrint/DartPad | NONE |
| m03/03 | lifecycle model, ownership diagram, existing Tự làm | CORE lesson lacked domain-neutral example | ISOLATED_EXAMPLE | F-06, A-02 | (existing activity retained) | — | — | NONE |

## Isolated examples

- `m03/01` — `LightSwitch`: ~25 lines, complete Widget+State pair,
  domain-neutral, DartPad-runnable.
- `m03/03` — `ScoreBoard`/`ScoreChip`: ~30 lines demonstrating data-down/
  events-up ownership before the ownership section.
