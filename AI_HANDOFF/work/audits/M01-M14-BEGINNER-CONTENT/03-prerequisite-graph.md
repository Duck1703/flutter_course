# 03 — Prerequisite Graph (M01–M14)

## Main chains (verified against actual lesson order)

```
Widget → Widget tree / BuildContext → StatelessWidget → composition/layout
  → StatefulWidget → State<T>/createState → setState → lifecycle (init/dispose)
  → state ownership → (why setState fails) → ChangeNotifier → ListenableBuilder
  → Provider/InheritedWidget → read vs watch → ChangeNotifierProvider scope
  → MultiProvider-by-contract → stream-driven VM

model-first: class/null-safety → copyWith/== → enum → immutable models
  → JSON toMap/fromMap (factory!) → repository impl

async: Future<T> → async/await → error → FutureBuilder+stable-future → async main
  → Stream → listen/Subscription → StreamController/broadcast → StreamBuilder
  → event stream (M13) → BehaviorSubject/ValueStream (M14)

nav: route stack → push → pop → route-result Future → popUntil/dialog route
  → (named routes deferred — note: m09/03 labels this "M14", stale)

game: enum → phase machine → Timer.periodic+ownership → dialog
persistence: SharedPreferences → JSON → store class → repository contract
DI: constructor threading → InheritedWidget → Provider → MultiProvider contract
```

## Edges verified CLOSED

All of: widget→state→setState→lifecycle; Future→Stream; stack→dialog;
ChangeNotifier→Provider; event→bridge; contract→impl→MultiProvider.
Every "Bạn đã biết gì" section cross-references the correct prior milestone —
with the exceptions below.

## Broken / suspect edges (evidence)

| Edge | Evidence | Severity |
|------|----------|----------|
| `factory` ctor — M10/02 "Bạn đã biết gì" claims "đã thấy trong course Dart cơ bản" | `grep factory` over m01–m09 lesson files: **zero hits**. First real teaching is the M10/02 Hiểu-code paragraph itself. | MEDIUM — claim wrong, but point-of-use gloss exists |
| `async*`/`yield` — M13/01 lists them under "đã học M06" | M06 teaches listen/cancel/StreamController only; `async*` appears once in M06/03's **"cố ý chưa làm"** list — i.e. explicitly deferred, then claimed as known. | LOW (not actually needed in M13, but the claim is false) |
| `pumpEventQueue` — used in M14/02 test snippet, explained only in M14/04 | grep: no occurrence pre-M14. | LOW (order inversion inside one milestone) |
| M14/01 checkpoint: "`flutter analyze` sạch sau khi xoá `profile_store.dart`" | `MenuViewModel` still imports/uses `ProfileStore` until bài 4. Following the lesson order literally, the project **cannot compile/analyze-clean at the bài-1 checkpoint**. | MEDIUM — mid-milestone sequence gap; checkpoints not independently true |
| M09/03 "named routes — M14" (×2) | M14 is repository/RxDart. Named routes are a later milestone. Stale forward reference. | LOW |
| M10/01 checkpoint lists `load/save/clear` | Method renamed `reset()` in Step-10 remediation; body correct, checkpoint stale. | LOW |

## DEPENDENCY_BEFORE_PREREQUISITE: none critical

The important chains close correctly. The worst offender is M14's internal
density — not a missing node but a *collapsed* set of nodes (contract + impl +
subject + DI wiring + fakes across four dense lessons where earlier milestones
would have spent 6–8).
