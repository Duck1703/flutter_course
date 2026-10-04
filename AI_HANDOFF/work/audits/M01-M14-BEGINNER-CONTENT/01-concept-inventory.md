# 01 — Concept Inventory: Dart/Flutter/Architecture concepts actually encountered M01–M14

Derived from learner-app code + all 48 lessons. "First code" = first milestone
where the learner writes the concept. "First taught" = first lesson that
explains it (P = point-of-use explanation, not a dedicated section).

## Dart language

| # | Concept | First code | First taught | Depth note |
|---|---------|-----------|--------------|------------|
| D1 | `final` / immutability | M01 | M01/02 | Good — tied to widget immutability |
| D2 | `const` constructors/literals | M01 | M01/02 + M04 | Good; const-for-performance explained |
| D3 | Named parameters `{...}` | M01 | M01/02 | Good |
| D4 | `required` | M02 | M02 | Adequate (point-of-use) |
| D5 | Null safety `T?`, `!`, `??` | M04 | M04/01 | Good — dedicated lesson |
| D6 | Classes, fields, methods, getters | M02–M04 | M02/M04 | Good |
| D7 | `private _` members | M03 | M03/01 | Good |
| D8 | Enums | M08 | M08/02 | Good — dedicated section |
| D9 | `copyWith` | M04 | M04/02 | Good |
| D10 | `==`/`hashCode` equality | M04 | M04/02 | Good |
| D11 | Collections, spread, collection-for/if | M02, M08 | M02 + M08/03 | Good |
| D12 | `Map<String, Object?>` + JSON | M10 | M10/02 | Good |
| D13 | `Future<T>` vs `T` | M05 | M05/01 | Excellent (eventual-result model) |
| D14 | `async`/`await` | M05 | M05/01 | Excellent (suspend-continuation model) |
| D15 | `Future.delayed`, `throw` | M05 | M05/01 | Good |
| D16 | `Stream<T>`, `listen`, `StreamSubscription` | M06 | M06/01–03 | Good incl. cancel ownership |
| D17 | `Stream.periodic`, `take`, `first` | M06, M13 | M06/01, M13/03 | Good |
| D18 | `StreamController`, broadcast | M06, M13 | M06/03, M13/01 | Good |
| D19 | `Timer.periodic`, `cancel` | M09 | M09/01 | Good (ownership rules explicit) |
| D20 | `is` type check | M08/M13 | M08 + M13/02 | Adequate |
| D21 | `switch` statement on enum | M09 | M09/03 (table only) | Thin |
| D22 | `switch` expression | M11 | M11/02 | Adequate |
| D23 | Cascade `..` | M12 | M12/03 | Thin-but-explained |
| D24 | `factory` constructor | M10 | M10/02 (Hiểu-code only) | **THIN — never formally taught; M10/02 falsely claims prior coverage** |
| D25 | `abstract class` vs `abstract interface class` | M13/M14 | M13/01 + M14/01 | `abstract` good; `interface` compressed |
| D26 | `implements` | M14 | M14/01 | Thin — ~20 lines, no standalone example |
| D27 | Generics `<T>` | throughout | M02/M05 implied | Adequate for level |
| D28 | Closures/callbacks `VoidCallback` | M03 | M03 | Good |
| D29 | `unawaited` | M13 | M13/02 | Good (purpose + why) |
| D30 | `static` + async `create()` factory method | M14 | M14/01 | Adequate |
| D31 | Null-aware element `'k': ?v` (Dart 3.8) | M14 | M14/03 | Thin — one paragraph in dense lesson |
| D32 | `addTearDown`, `throwsStateError` | M05, M11 | M05/01, M11/03 | Good |
| D33 | `pumpEventQueue` | M14 | M14/04 | Thin — used M14/02, explained M14/04 (order inverted) |

## Flutter framework

| # | Concept | First code | First taught | Depth note |
|---|---------|-----------|--------------|------------|
| F1 | Widget / everything-is-widget | M01 | M01/01–02 | Good |
| F2 | Widget tree / Element tree / render | M01 | M01/02 | **Excellent — 3-tree model** |
| F3 | `BuildContext` (location + lookup) | M01 | M01/02 + M12 | Good incl. lookup direction |
| F4 | `StatelessWidget` | M01–M02 | M01/02, M03/01 | Good |
| F5 | `StatefulWidget` + `State<T>` + `createState` | M03 | M03/01 | **Excellent — ownership table** |
| F6 | `setState` semantics | M03 | M03/02 | Excellent ("signal, not mutate") |
| F7 | Rebuild ≠ reload | M03 | M03/02–03 | Good; hot-reload state survival covered |
| F8 | Lifecycle `initState`/`dispose`/`didChangeDependencies` | M03, M13 | M03/03, M13/02 | Good; dCD subscribe-site taught M13 |
| F9 | `mounted` guard | M05 | M05/02 | Good |
| F10 | `MaterialApp`, `Scaffold`, `AppBar` | M01–M02 | M01/02, M02 | Good |
| F11 | Layout constraints ("constraints go down…") | M02 | M02/01 | **Excellent — dedicated lesson** |
| F12 | `Row`/`Column`/`Expanded`/`Padding`/`SizedBox` | M02 | M02 | Good |
| F13 | `ListView`/scroll/`SingleChildScrollView` | M02/M08 | M02, M08 | Good |
| F14 | `GestureDetector`/buttons/`onTap` | M02–M03 | M02–M03 | Good; `onTap: null` disabled trick M08 |
| F15 | `FutureBuilder` + stable Future identity | M05 | M05/02 | **Excellent — "new Future per build" trap taught** |
| F16 | `StreamBuilder` + `initialData` | M06 | M06/02 | Good |
| F17 | Navigator stack, `push`/`pop`/`popUntil` | M07 | M07/01–02 | **Excellent — stack model + Android bridge with limits** |
| F18 | `MaterialPageRoute<T>`, route result `Future` | M07, M10 | M07 + M10/03 | Good |
| F19 | `showDialog`, `AlertDialog`, `barrierDismissible`, dialog-as-route | M09 | M09/03 | Good |
| F20 | `GlobalKey<NavigatorState>` | M07 | M07/03 | Adequate (checkpoint lesson) |
| F21 | Widget testing: `pumpWidget`, `pump`, `tap`, finders, virtual time | M08 | M08/04, M09/04 | Good; `ensureVisible` M13 |
| F22 | `ChangeNotifier`, `notifyListeners` | M11 | M11/02 | **Excellent — who-notifies-whom model** |
| F23 | `ListenableBuilder` | M11 | M11/02 | Good |
| F24 | `InheritedWidget`/tree lookup | M12 | M12/01 | Good |
| F25 | `Provider`, `.value` vs `create`, `ChangeNotifierProvider` | M12 | M12/01–03 | **Excellent — ownership/scope explicit** |
| F26 | `context.read` vs `context.watch` | M12 | M12/02 | **Excellent — dedicated lesson** |
| F27 | `MultiProvider` | M14 | M14/03 | Thin — ~1 paragraph + code |
| F28 | `SnackBar`, `ScaffoldMessenger` | M13 | M13/02–03 | Good ("first time in course" flagged) |
| F29 | `CircularProgressIndicator` | M05/M11 | M05, M11 | Adequate (retired M14 — noted) |
| F30 | `WidgetsFlutterBinding.ensureInitialized` | M05 | M05/03 | Good |
| F31 | Async `main()` | M05 | M05/03 | Good |

## Architecture / patterns

| # | Concept | First code | First taught | Depth note |
|---|---------|-----------|--------------|------------|
| A1 | Declarative UI (UI = f(state)) | M01–M03 | M01/02, M03/02 | Good |
| A2 | Data-before-UI / model-first | M04, M08 | M04, M08/01 | Good |
| A3 | State ownership & lifting | M03 | M03/03 | Good |
| A4 | Data-down/events-up | M03 | M03/03 | Good |
| A5 | UI state vs UI event | M13 | M13/01 | **Excellent — dedicated lesson** |
| A6 | Phase/state machine (enum states) | M08–M09 | M08/02, M09/01–02 | Good |
| A7 | Why setState doesn't scale | M11 | M11/01 | **Excellent — motivation-first** |
| A8 | ViewModel + manual lifecycle | M11 | M11/02–03 | Good |
| A9 | Dependency threading problem → DI | M12 | M12/01 | Good |
| A10 | App-level vs screen-level scope | M12 | M12/03 | Good |
| A11 | Event bridge (VM→State subscribe) | M13 | M13/02 | **Excellent — 3-step contract** |
| A12 | Repository boundary vs storage primitive | M14 | M14/01 | PARTIAL — good framing, thin example |
| A13 | Dependency inversion (depend on contract) | M14 | M14/01 + /03 | PARTIAL — compressed, no isolated example |
| A14 | `BehaviorSubject`, `.seeded`, replay | M14 | M14/02 | PARTIAL — compressed |
| A15 | `ValueStream`, `.value` | M14 | M14/02 | PARTIAL |
| A16 | State stream vs event stream | M14 | M14/04 | Good (explicit table) |
| A17 | Read/write boundary (subject in, stream out) | M14 | M14/02 | Adequate |
| A18 | Fake repository (contract-first payoff) | M14 | M14/03 | Adequate — code shown, thin theory |
| A19 | Persistence via SharedPreferences | M10 | M10/01 | Good |
| A20 | Async bootstrap ordering | M05/M14 | M05/03, M14/03 | Good→thin at M14 |
| A21 | Resource ownership/dispose chains | M03→M14 | recurring | Good — reinforced each milestone |
| A22 | Temporary scaffold governance | M03→M13 | M13/03 retirement | PARTIAL — flagged only at retirement, not at introduction |

**Total distinct concepts inventoried: 76** (33 Dart, 31 Flutter, 22
architecture — some double-counted across categories where a concept is both;
the working count used for reporting is 76 rows).

## Status roll-up

- WELL_TAUGHT: ~46
- ADEQUATE: ~20
- THIN: 7 (switch stmt, cascade, `implements`, MultiProvider, `?element`,
  `pumpEventQueue`, `ValueStream` depth)
- VERY_THIN: 1 (`abstract interface class` as a usable concept — ~20 lines)
- USED_BEFORE_TAUGHT (claim or order): 3 (`factory` claimed-taught-not;
  `pumpEventQueue` used before explained; `async*`/`yield` falsely claimed as
  prerequisite knowledge in M13/01)
- MISSING (never explained anywhere): 0 hard-missing; `factory` is the closest
  (point-of-use gloss only, false prior-knowledge claim)
- MISLEADING: 0
