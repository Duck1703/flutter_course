# M12 — PEDAGOGY REVIEW (Pedagogy Reviewer)

CONTENT_REVISION: `130f664d|c1c4b0c5|279597dc`
Companion technical review: not read.
Verdict: **PEDAGOGY_PASS**

## P1–P12 rows

| Lesson | CORE | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m12/01 | F-17 | 4 | 4 | 5 | 4 | 4 | 4 | 4 | 4 | 5 | 5 | 4 | 4 | PASS |
| m12/02 | F-18 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 5 | 5 | 4 | 4 | PASS |
| m12/03 | — | — | — | — | — | — | — | — | — | — | — | — | — | PASS (retained) |

## Instrument evidence

- **P9:** m12/01's 4-position lookup prediction separates "above the
  provider" from "outside build" — the two failure axes learners
  conflate. m12/02's call-site table requires the one-criterion
  decision ("does this site need re-run on notify?"), then forces the
  learner to explain *why* the crash is correct behavior.
- **P10:** the Hilt/DI false analogy (compile-time graph) and Compose
  auto-tracking assumption are targeted precisely.
- **Isolated example:** raw InheritedWidget exposes that `watch` is
  just `dependOnInheritedWidgetOfExactType` + `updateShouldNotify` —
  mechanism before package, zero deps.
- **P5:** ~160 added lines across 2 lessons.
- **P7/P11:** zero ports; zero governance noise; M13/M14 firewall
  clean.

## Findings

None above NOTE.

## Verdict rationale

Provider's two failure modes (wrong context, wrong phase) are
practised as predictions, not just listed as rules. `PEDAGOGY_PASS`.
