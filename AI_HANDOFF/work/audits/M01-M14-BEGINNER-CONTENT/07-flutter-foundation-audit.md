# 07 — Flutter Foundation Audit

Question: does a true Flutter beginner learn what Flutter is, how it renders,
widgets, trees, State, build, context, setState, rebuild semantics,
composition, constraints — before the course builds project screens?

## Verdict: STRONG (early foundations are the course's best work)

| Required foundation | Where | Quality |
|---------------------|-------|---------|
| What Flutter is / renders UI | M01/01–02 | GOOD — framework + 3-tree model |
| What a Widget is / why everything is one | M01/02, M02 | GOOD |
| Widget tree (+ Element, render trees) | M01/02 | **Excellent** — rare at this level |
| StatelessWidget | M01/02, M03/01 | GOOD |
| StatefulWidget / State<T> / createState | M03/01 | **Excellent** — ownership table, lifetime |
| build() | M01–M03 | GOOD |
| BuildContext (location + upward lookup) | M01/02, M03, M12 | GOOD — lookup direction revisited at Provider |
| setState() — what it does and doesn't do | M03/02 | **Excellent** — "signal, not mutate" |
| Rebuild ≠ reload; hot-reload keeps state | M03/02–03 | GOOD — demonstrated |
| Identity/lifecycle basics (initState/dispose/dCD) | M03/03, M13/02 | GOOD; dCD as subscribe-site is M13's best section |
| Declarative UI, parent/child composition | M01–M02 | GOOD |
| Layout constraints | M02/01 | **Excellent** — dedicated mental-model lesson |

No structural foundation problem: the early course does **not** jump into
project screens before establishing the widget/State/rebuild model. M03's
Widget-vs-State teaching is above typical beginner-course depth.

## Mental-model roll call (required list)

| Model | Rating |
|-------|--------|
| Declarative UI | GOOD |
| Widget tree | GOOD |
| Widget vs State | GOOD |
| Rebuild | GOOD |
| BuildContext | GOOD |
| State ownership | GOOD |
| async/event-loop intuition | GOOD (single-isolate model, M05) |
| Future | GOOD |
| Stream | GOOD |
| Navigation stack | GOOD |
| Dependency injection | **PARTIAL** — tree-lookup mechanics strong (M12); "why invert dependencies" compressed (M14) |
| ChangeNotifier | GOOD |
| Provider scope | GOOD |
| UI event vs UI state | GOOD (M13/01 dedicated) |
| Repository | **PARTIAL** — boundary framing good (M14/01) but no isolated example |
| BehaviorSubject / ValueStream | **PARTIAL** — semantics taught, mental-model section absent |

MENTAL_MODEL_GAPS: 3 (DI inversion, repository, BehaviorSubject/ValueStream —
all in M14).

## async/Foundation chain (checked strictly)

- Future: eventual-result model, async/await suspension, error completion,
  event-loop intuition, `Future<T>`, FutureBuilder + the new-Future-per-build
  trap — all taught (M05). GOOD.
- Stream: sequence-over-time, listen/subscription, single vs broadcast,
  StreamBuilder, lifecycle/cancel, Stream-vs-Future, Stream-vs-later-RxDart —
  all taught (M06), with the M13 broadcast-no-replay proof test and M14
  state-vs-event contrast table reinforcing it. GOOD.
- Navigation (M07+): stack mental model, Route, MaterialPageRoute, push/pop,
  route-result Future, dialog-as-route, why-context, Android back-stack analogy
  *with stated limits* — all taught. GOOD.

## The one Flutter-side soft spot

`ScaffoldMessenger`/SnackBar (M13/02–03) is handled *well* precisely because
the lesson flags it "first time in course" and explains the messenger/app-level
mechanism — evidence that flagging first-appearances works, and proof-by-
contrast that M14's unflagged compression is the anomaly.
