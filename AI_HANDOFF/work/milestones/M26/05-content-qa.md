# M26 — Content QA (Argus)

## Round 1 — verdict FAIL (1 BLOCKING + 3 NON-BLOCKING + 4 NIT)

| # | Severity | Finding | Disposition |
|---|---|---|---|
| 1 | BLOCKING | L01 counter example claimed `1→2→1→1[rejected]` — guard never fired | FIXED: added third `Decrement`; claimed output `1 [] → 2 [] → 1 [] → 0 [] → 0 [rejected]` now verified by trace |
| 2 | NON-BLOCKING | `unawaited` cited as D-24 → must be D-17 (3 lessons + brief) | FIXED all sites; `addTearDown` cite → D-23 |
| 3 | NON-BLOCKING | "`part`/`part of` first in course" false — M24 auth dialog used it | FIXED: L04 desc + goal bullet + index now credit M24; new element = private `extension` |
| 4 | BOOKKEEPING | New concept IDs (D-45/D-46/F-33/F-34/A-31/A-32) + FR-37 not yet in registries | Deferred to Atlas canonical sync (planned step) |
| 5–8 | NIT | L03 ctor excerpt order/elision; L04+L05 non-compiling mid-step labels; L04 DEBUG missing hint; loose IDs (D-10→D-23, D-05→D-32/D-35, D-33→D-09) | ALL FIXED |

Per-gate R1: G16 PASS, G17 PASS, G18 PASS_WITH_FINDINGS, G19 PASS,
G20 PASS, G21 PASS_WITH_FINDINGS, G22 PASS, G23 PASS_WITH_FINDINGS,
G24 FAIL (finding 1).

## Round 2 — targeted re-verify: 4/7 verified; 3 leftover defects
(edit-race stale writes detected — `05:60` D-24, `04:14-15` part-claim,
`05:95` "lần hai", `03` ctor excerpt regressed)

## Round 3 — targeted re-verify: **PASS**

- `05:60` → D-17; zero `D-24` in folder.
- `04:14-16` credits M24; `05:95` "lần ba" chain correct.
- `03` ctor excerpt matches `game_dre_state.dart` (7 elided, dialogState, flowToken last).
- `:::` pairs balanced (2 hint pairs in L04); `<details>` balanced.

## Final per-gate results

G16 PASS · G17 PASS · G18 PASS · G19 PASS · G20 PASS · G21 PASS ·
G22 PASS · G23 PASS · G24 PASS

## Remediation lesson (process)

Two `edit`-tool writes to the same file in one batch raced with a
prior python rewrite and silently reverted fixes; a subagent `read`
cache also served stale content. Mitigation used: all subsequent
fixes applied via python + grep verification immediately after write.
Recorded so future milestones prefer single-write paths per file.
