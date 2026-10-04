# 06 — Dart Foundation Audit

Question: does the course teach enough Dart before Flutter lessons rely on
complex Dart? (Not a generic Dart course — just no unexplained syntax.)

## Verdict: MOSTLY STRONG, two real gaps

Strong coverage: `final`/`const` (M01), named params/`required` (M01–M02),
null-safety family `T?`/`!`/`??` (M04 dedicated), classes/getters/private `_`
(M02–M03), enum (M08), copyWith + `==`/hashCode (M04), collections +
spread/collection-for (M02, M08), generics by absorption (M02, M05), closures
(M03), `Future`/`async`/`await` family (M05 — best-in-course), `Stream` family
(M06), `is` checks (M08, M13), `switch` expression (M11), `unawaited` (M13),
`abstract class`/`final class` (M13).

## Gap D-A — `factory` constructor (MEDIUM)

- First code: `factory UserProfileData.fromMap(Map ...)` in M10/02.
- M10/02 "Bạn đã biết gì" asserts the learner has seen factory constructors
  "trong course Dart cơ bản". `grep` over m01–m09 lessons: **zero
  occurrences** of `factory`. The claim is false.
- Mitigation: M10/02 "Hiểu code" does explain *why* a factory vs a normal ctor
  (needs logic before/instead of field init, returns cached/derived instance).
  So the concept isn't used blind — but there is no syntax anatomy
  (`factory X.y(...) { ... return ...; }`), no standalone mini-example, and the
  false prerequisite claim may alarm a careful learner.
- Fix location: a compact "factory constructor" section inside M10/02 (or a
  short pre-lesson), plus remove the false claim.

## Gap D-B — `abstract interface class` + `implements` (HIGH importance, thin depth)

- First code: M14/01. Taught in ~20 lines: signature-only, no body, no ctor;
  `implements` ≠ `extends`; compiler enforces members; multi-implement.
- Adequate *as a definition*, but this is the learner's first encounter with
  Dart 3 class modifiers AND the contract mechanism the whole repository
  architecture hangs on. No standalone example (e.g. a `Shape`/`Storage`
  interface with two toy impls), no "when NOT to use" (don't interface
  everything — senior uses it because multiple impls exist), no comparison to
  Kotlin `interface` depth beyond a single bullet.
- Given it unlocks fakes, DI, and testability, VERY_THIN is not acceptable here.

## Gap D-C — minor syntax thinness (LOW each)

- `switch` *statement*: first real use M09/03; only a table row + exhaustiveness
  note. Acceptable but thin for an Android learner who expects Java semantics.
- `cascade ..` : M12/03 table + one-line gloss. Acceptable.
- null-aware element `'k': ?v` (Dart 3.8): one paragraph inside the overloaded
  M14/03 — easily missed.
- `pumpEventQueue` (test API): used M14/02 snippet, explained M14/04 — order
  inverted inside the milestone.
- `addTearDown`: used since M05/11 tests; explained adequately at first use.

## Non-findings (checked, OK)

- `implements` vs `extends` vs `with`: `implements` covered (thin) at M14/01;
  `with`/mixins genuinely absent from learner code — correctly untaught.
- `async*`/`yield`: NOT used in learner code through M14 — correctly deferred
  (M06 lists them as deferred; the only defect is M13/01's false "đã học"
  claim, a wording bug not a teaching hole).
- Sealed classes: correctly deferred to M15 (explicit in M13/02, M14/04).

## Summary

Dart foundation through M13 is genuinely good — syntax is introduced before or
at point of use with meaning, not just shape. The two actionable items are
`factory` (claim + thinness) and the M14 Dart-3-modifier cluster, which belongs
to the M14 depth problem rather than a Dart-planning failure.
