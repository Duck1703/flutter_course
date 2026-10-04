# 08 — State-Management Learning Progression (M03 → M14)

Required check: does the learner understand WHY the architecture evolves —
setState → ChangeNotifier → Provider → UI events → repository state stream?

## The five transitions

| Transition | Problem stated first? | What new concept solves | Same/moves-ownership | Trade-offs | Why senior uses it | Rating |
|-----------|----------------------|------------------------|----------------------|------------|--------------------|--------|
| setState (M03) | n/a (baseline) | local ephemeral UI state | widget owns | "when this stops working" seeded | n/a — baseline | GOOD |
| setState → ChangeNotifier (M11) | **YES — entire lesson** M11/01 "vì sao setState không scale" | shared/async state outlives widget, notify decoupled | state moves widget→VM | boilerplate, manual dispose | explicit | **Excellent** |
| ChangeNotifier → Provider (M12) | YES — constructor-threading problem M12/01 | tree lookup instead of threading; scope + disposal | ownership moves to provider slot | magic lookup, read/watch discipline | explicit | **Excellent** |
| state → event bridge (M13) | YES — "navigation/snackbar are events not state" M13/01 | one-off actions via broadcast stream; VM can't hold context | intent in VM, execution in State | manual subscribe/cancel, no replay | explicit (senior bridge) | **Excellent** |
| VM/store → repository stream (M14) | PARTIAL — M14/01 frames storage-vs-repo well | contract + replay state stream; load-state enum retired | truth moves to repo subject; VM subscribes | rxdart dep, subject lifecycle | explicit per-site | **PARTIAL** — right ideas, compressed |

## Findings

1. The progression is **conceptually coherent and deliberate** — each
   transition is motivated by a stated failure of the previous form, not a
   gratuitous refactor. M11/01 ("vì sao setState không scale") is the model
   the whole course should imitate: problem → why previous broke → new concept.
2. M14 **does** continue the pattern correctly in substance (M14/01 opens with
   "vì sao ProfileStore chưa đủ"; M14/04 shows writers no longer assign state
   by hand, stream is source of truth). The weakness is **compression**, not
   absent reasoning.
3. The end-state understanding ("VM now lives on repo stream; writers don't
   setState") is reachable — the state-vs-event table in M14/04 is genuinely
   good — but a beginner gets there via the densest, least-scaffolded lessons.

**Progression verdict: STRONG in design, THIN in final-milestone delivery.**
