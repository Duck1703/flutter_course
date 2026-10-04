# 04 — Milestone-Level Learning Audit

| MS | Project outcome | New Dart | New Flutter | Arch. concepts | Theory depth | Active learning | Cognitive load | Independence | Verdict |
|----|----------------|----------|-------------|----------------|--------------|-----------------|----------------|--------------|---------|
| M01 | first app, widget tree | final/const, named params | Widget, tree, context, Stateless, MaterialApp, Scaffold | declarative UI | **Strong** (3-tree model, BuildContext caution) | SOME (predict + self-check) | WELL_SCOPED | PARTIAL | STRONG |
| M02 | menu skeleton, layout | required, collections | constraints, Row/Col/Expanded, ListView | composition | **Strong** (dedicated constraints lesson) | SOME | WELL_SCOPED | PARTIAL | STRONG |
| M03 | interactive menu (scaffolds) | `!`,`++`,`?:`,`'$x'`, closures, `_` private | Stateful, State, setState, lifecycle | state ownership, data-down/events-up | **Strong** | SOME–GOOD (predict questions) | WELL_SCOPED | PARTIAL | STRONG |
| M04 | `UserProfileData` + first test | null safety, copyWith, `==`/hashCode | model rendering | model-first, immutability | **Strong** | SOME | WELL_SCOPED | PARTIAL | STRONG |
| M05 | async loader scaffold | Future, async/await, delayed, throw | FutureBuilder, mounted, async main | eventual-result model | **Excellent** | SOME | WELL_SCOPED | YES-ish (tiny examples) | STRONG |
| M06 | session ticker scaffold | Stream, periodic, take, first, Controller, broadcast | StreamBuilder, listen/cancel | stream-vs-future, subscription ownership | **Excellent** | SOME | WELL_SCOPED | YES (non-project examples) | STRONG |
| M07 | navigation to game | route generics | Navigator, push/pop, MaterialPageRoute, GlobalKey | stack mental model | **Strong** | SOME | WELL_SCOPED | PARTIAL | STRONG |
| M08 | quiz engine + first widget tests | enum, collection-for/if | state-derived render, `onTap:null`, WidgetTester | data-before-UI, enum UI state | **Strong** | SOME (test writing is active) | WELL_SCOPED | PARTIAL | STRONG |
| M09 | phase machine + dialog | switch stmt (table), Timer | showDialog, AlertDialog, popUntil | phase machine, timer ownership | **Strong** | SOME | WELL_SCOPED | PARTIAL | STRONG |
| M10 | persistence + result | JSON, Map, factory(thin) | route-result Future | store boundary | **Strong** | SOME | WELL_SCOPED | PARTIAL | STRONG (one stale checkpoint) |
| M11 | MenuViewModel | switch expr, tear-off | ChangeNotifier, notifyListeners, ListenableBuilder | why-setState-fails, VM ownership | **Excellent** | SOME | WELL_SCOPED | YES (pure-Dart VM tests) | STRONG |
| M12 | Provider wiring | cascade `..` | InheritedWidget, Provider, read/watch, CNP | DI problem, scope | **Excellent** | SOME | WELL_SCOPED | PARTIAL | STRONG |
| M13 | event bridge | abstract+final classes | didChangeDependencies subscribe, SnackBar/Messenger | event≠state, bridge ownership | **Excellent** | SOME | WELL_SCOPED | PARTIAL | STRONG |
| M14 | 3 repos + MultiProvider + VM-on-stream | interface class, implements, `?element`, static create | MultiProvider, (RxDart subject) | repository, DI-by-contract, state-vs-event stream | **COMPRESSED** — named sections dropped | WEAK (self-check only, dense) | **OVERLOADED** (bài 3 severe) | NO→PARTIAL | **NEEDS_EXPANSION** |

## Notes

- M01–M13 are consistently strong: every lesson carries mental-model,
  Android-bridge (SIMILARITY/IMPORTANT DIFFERENCE/DO NOT ASSUME),
  senior-connection, mistakes, and self-check sections. The "code-first without
  understanding" pattern the human feared is **not** the norm here.
- M14 is the exception: 4 lessons, 163–222 lines each vs. the 250–400 line norm;
  missing named `Mental model mới`, `Lỗi hay gặp`, `Chạy và quan sát` sections;
  no isolated non-project example for BehaviorSubject/repository/DI; bài-3 packs
  5+ major new things (2 more repos, MultiProvider, async bootstrap, model
  parity incl. Dart-3.8 syntax, fakes) into 200 lines.
- The regression is therefore **localized and structural-template-driven**, not
  a uniform course-wide shallowness.
