# 02 — Concept Coverage Matrix (10-level depth check)

For each important concept: which of the 10 teaching layers are actually
present? L1 Definition · L2 Purpose · L3 Mental model · L4 Syntax/anatomy ·
L5 Runtime behavior · L6 Lifecycle/ownership · L7 Usage boundaries ·
L8 Common mistakes · L9 Independent example · L10 Project application.

## Core Flutter concepts (required to be deep)

| Concept | L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9 | L10 | Verdict |
|---------|----|----|----|----|----|----|----|----|----|-----|---------|
| Widget / tree (3-tree model) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | WELL_TAUGHT |
| StatelessWidget | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ~ | ✓ | WELL_TAUGHT |
| StatefulWidget + State | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ~ | ✓ | WELL_TAUGHT |
| setState / rebuild | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ~ | ✓ | WELL_TAUGHT |
| BuildContext | ✓ | ✓ | ✓ | ✓ | ✓ | ~ | ✓ | ✓ | ~ | ✓ | WELL_TAUGHT |
| Layout constraints | ✓ | ✓ | ✓ | ✓ | ✓ | – | ✓ | ✓ | ✓ | ✓ | WELL_TAUGHT |
| Future / async / await | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | WELL_TAUGHT |
| Stream / listen / cancel | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | WELL_TAUGHT |
| FutureBuilder / StreamBuilder | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ~ | ✓ | WELL_TAUGHT |
| Navigator / route stack | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ~ | ✓ | WELL_TAUGHT |
| ChangeNotifier / notifyListeners | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ~ | ✓ | WELL_TAUGHT |
| Provider / read / watch / scope | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ~ | ✓ | WELL_TAUGHT |
| UI event vs UI state | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | WELL_TAUGHT |
| Widget testing | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ~ | ✓ | WELL_TAUGHT |
| **abstract interface class / implements** | ✓ | ✓ | ~ | ~ | ✓ | ~ | ✓ | – | ✗ | ✓ | **THIN** |
| **BehaviorSubject / ValueStream** | ✓ | ✓ | ~ | ✓ | ✓ | ✓ | ~ | ~ | ✗ | ✓ | **THIN** |
| **Repository boundary / DI-by-contract** | ✓ | ✓ | ~ | ✓ | ~ | ✓ | ~ | ~ | ✗ | ✓ | **THIN** |
| **MultiProvider** | ✓ | ✓ | ~ | ~ | ~ | ✓ | ~ | – | ✗ | ✓ | **THIN** |

Legend: ✓ present · ~ partial · ✗ absent · – not applicable at this depth.

## Dart syntax (only needs to support Flutter work)

| Concept | Coverage | Status |
|---------|----------|--------|
| final/const, named params, required, null-safety family | M01–M04 dedicated | WELL_TAUGHT |
| copyWith, ==/hashCode, enum, collections | M04, M08 | WELL_TAUGHT |
| switch expression / statement | M09 (stmt, table), M11 (expr) | ADEQUATE |
| cascade `..`, tear-off, `unawaited`, `is` | point-of-use glosses | ADEQUATE |
| **factory constructor** | M10/02 "Hiểu code" paragraph only; "Bạn đã biết gì" claims it was already seen — **it was not** | **THIN + false claim** |
| **null-aware element `?v` in map** | M14/03 one paragraph inside overloaded lesson | **THIN** |
| abstract interface class | M14/01 ~20 lines | **VERY_THIN for its importance** |
| implements | same | THIN |
| `pumpEventQueue`, `addTearDown` | used M14; gloss exists only M14/04 | THIN/order-inverted |

## Systemic pattern visible in the matrix

Every concept rated WELL_TAUGHT sits in M01–M13, where the lesson template
enforces mental-model + mistakes + run-observe sections. Every THIN/VERY_THIN
rating sits in M14, where the four lessons dropped the named sections —
**the template weakened exactly when concept complexity peaked.** This is the
single most important matrix-level finding and corroborates the human review.
