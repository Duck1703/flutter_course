# 12 — Content Gap Register

Severity: CRITICAL / HIGH / MEDIUM / LOW. Categories: THEORY_MISSING,
THEORY_TOO_SHALLOW, MENTAL_MODEL_MISSING, DART_PREREQUISITE_MISSING,
FLUTTER_PREREQUISITE_MISSING, USED_BEFORE_TAUGHT, CODE_FIRST,
PROJECT_ONLY_KNOWLEDGE, COGNITIVE_OVERLOAD, EXAMPLE_MISSING,
ACTIVE_LEARNING_MISSING, CHECKPOINT_WEAK, ANDROID_ANALOGY_OVERUSED,
TERMINOLOGY_INCONSISTENT, CURRICULUM_SEQUENCE_GAP, CONTENT_MANAGEMENT_GAP.

---

## F-01 — Stale milestone reference (named routes "M14")

- **Milestone/Lesson:** M09/03 (×2)
- **Severity:** LOW · **Category:** TERMINOLOGY_INCONSISTENT
- **Concept:** named routes / deferred-topics bookkeeping
- **Current teaching:** "cố ý chưa" list defers named routes to "M14".
- **Expected to infer:** nothing — learner just remembers a wrong milestone.
- **Why insufficient:** M14 is repository/RxDart; named routes land later.
  A reader cross-checking the roadmap finds a contradiction.
- **Missing:** none (content-wise); correctness of deferral labels.
- **Remediation:** change the deferral label to the correct milestone (or
  "a later navigation milestone"). ~1 line.
- **Fix before:** M15 (cheap correctness).

## F-02 — Stale method name in M10/01 checkpoint

- **Milestone/Lesson:** M10/01
- **Severity:** LOW · **Category:** TERMINOLOGY_INCONSISTENT
- **Concept:** `ProfileStore` API (`load`/`save`/`reset`)
- **Current teaching:** body correctly uses `reset()`; the checkpoint lists
  `load/save/clear` — `clear` was renamed `reset` in Step-10 remediation.
- **Why insufficient:** learner ticking the checkpoint looks for a method
  that doesn't exist; erodes trust in checkpoints.
- **Remediation:** update checkpoint to `reset`. ~1 line.
- **Fix before:** M15.

## F-03 — False prerequisite claim (`async*`/`yield`)

- **Milestone/Lesson:** M13/01 "Bạn đã biết gì"
- **Severity:** LOW · **Category:** USED_BEFORE_TAUGHT (claim-reversed)
- **Concept:** `async*`/`yield`
- **Current teaching:** section lists `async*`/`yield` as learned in M06.
- **Evidence:** `grep` — the only M06 mention is inside "cố ý chưa làm".
- **Why insufficient:** false "you already know this" makes a careful learner
  hunt for a lesson that doesn't exist; silently wrong prerequisite ledger.
- **Remediation:** remove the two tokens from the "đã biết" list (they aren't
  used in M13) or restate as "bạn đã *nghe* có `async*` — chưa cần".
- **Fix before:** M15.

## F-04 — `factory` constructor: never taught, claimed as known

- **Milestone/Lesson:** M10/02
- **Severity:** MEDIUM · **Category:** DART_PREREQUISITE_MISSING + USED_BEFORE_TAUGHT
- **Concept:** `factory` constructors
- **Current teaching:** `factory UserProfileData.fromMap(...)` is the first
  use; "Bạn đã biết gì" claims it was seen "trong course Dart cơ bản" —
  verified false (0 hits m01–m09). A "Hiểu code" paragraph explains *why*
  factory at point of use.
- **Expected to infer:** factory syntax anatomy, what distinguishes it from
  a named/generative ctor, when a factory is the right tool.
- **Why insufficient:** definition-level gloss only; no syntax walkthrough,
  no standalone example; the false prior-knowledge claim papers over a real
  first-appearance.
- **Missing:** syntax anatomy (L4), standalone mini-example (L9), usage
  boundaries (L7).
- **Remediation:** add a compact "factory constructor" section to M10/02 —
  `factory X.name(...) { return ...; }` anatomy, vs-generative-ctor table,
  tiny non-map example (`Logger.instance()`-style), fix the prereq line.
- **Fix before:** M15 (it's a load-bearing Dart concept reused in M14 create()).

## F-05 — Scaffolds taught as features; temporary nature invisible until M13

- **Milestone/Lesson:** M03 (sound toggle, play-tap counter), M06 (session
  ticker), revealed only at M13/03 "Scaffold đã retire"
- **Severity:** MEDIUM · **Category:** CONTENT_MANAGEMENT_GAP
- **Concept:** teaching-scaffold lifecycle
- **Current teaching:** each scaffold is built as a normal feature; only at
  M13/03 is the learner told they were temporary and removed.
- **Expected to infer:** which patterns are permanent vs. disposable.
- **Why insufficient:** a learner invests learning effort without knowing the
  artifact is ephemeral; worse, may carry scaffold habits forward. The
  *retirement* documentation is excellent — the gap is at **introduction**.
- **Missing:** a one-line "scaffold" banner at each introduction ("this is a
  teaching scaffold; it will be retired in M13/M14 — here's the senior
  equivalent").
- **Remediation:** add scaffold labels at M03 & M06 introduction points +
  keep M13/03 retirement section. Optionally a site-wide "scaffold" badge.
- **Fix before:** M15 (pattern repeats in later milestones).

## F-06 — M14 lesson-template regression

- **Milestone/Lesson:** all of M14/01–04
- **Severity:** HIGH · **Category:** THEORY_TOO_SHALLOW + MENTAL_MODEL_MISSING
- **Concept:** everything M14 introduces
- **Current teaching:** 4 lessons of 163–222 lines drop the named sections
  every prior lesson carried — `Mental model mới`, `Lỗi hay gặp`, `Chạy và
  quan sát`; Android-bridge reduced to blockquote; no `Flutter cần dùng` table.
- **Why insufficient:** the course's own template exists precisely to force
  depth; it was abandoned on the hardest material. The depth gap is real —
  not just formatting (see F-07/F-08).
- **Remediation:** restore full section set in all four lessons; add the
  missing mental-model/mistakes/experiment content (not just headers).
- **Fix before:** M15 (P0).

## F-07 — No isolated example for repository contract / BehaviorSubject / DI

- **Milestone/Lesson:** M14/01, /02, /03
- **Severity:** HIGH · **Category:** EXAMPLE_MISSING + PROJECT_ONLY_KNOWLEDGE
- **Concept:** `abstract interface class`, `implements`, BehaviorSubject/
  ValueStream replay, DI-by-contract, MultiProvider
- **Current teaching:** every concept is introduced *inside* production code
  (repo contract = the real `UserProfileRepository`; BehaviorSubject = the
  real `_userProfileSubject`; MultiProvider = the real app wiring).
- **Expected to infer:** the concept abstracted away from SharedPreferences,
  UserProfileData, and the app.
- **Why insufficient:** cognitive load — the learner must parse concept AND
  production context simultaneously; nothing lets them see e.g. a
  `BehaviorSubject<int>` counting clicks before the profile subject. M05/M06
  proved the isolated-example-first pattern works (Future.delayed,
  Stream.periodic counters) — M14 skipped it.
- **Missing:** L9 independent example for each of: interface/implements,
  BehaviorSubject replay, contract-vs-impl, MultiProvider.
- **Remediation:** see artifact 13 — recommended split/new theory pages.
- **Fix before:** M15 (P0).

## F-08 — M14/03 severe cognitive overload

- **Milestone/Lesson:** M14/03
- **Severity:** HIGH (within-M14) · **Category:** COGNITIVE_OVERLOAD
- **Concept:** 2 new repos + MultiProvider + async bootstrap + UserProfileData
  parity (incl. Dart-3.8 `?element`, `_moneyFromDisplay`, `_isLegacyDemoProfile`)
  + fake repositories — in one ~200-line lesson.
- **Why insufficient:** 5+ major items share one page where the template's
  sections don't even survive; the parity/parsing material alone merits a
  lesson; DI-by-contract (the conceptual heart) is a bullet list.
- **Remediation:** split — (a) repositories + model parity, (b) MultiProvider
  + bootstrap + fakes. Both need expanded theory.
- **Fix before:** M15 (P0).

## F-09 — `pumpEventQueue` used before explained

- **Milestone/Lesson:** used M14/02 test snippet; explained M14/04
- **Severity:** LOW · **Category:** USED_BEFORE_TAUGHT (ordering)
- **Remediation:** one-line gloss at first use or reorder.
- **Fix before:** M15.

## F-10 — Dart-3.8 `?element` & parity helpers compressed inside F-08 lesson

- **Milestone/Lesson:** M14/03
- **Severity:** MEDIUM (folds into F-08; kept separate for the register)
  · **Category:** THEORY_TOO_SHALLOW
- **Concept:** `'k': ?v`, `_moneyFromDisplay`, `_isLegacyDemoProfile`
- **Remediation:** covered by the M14/03 split — the parity lesson gives
  these room.
- **Fix before:** M15.

## F-11 — No independent-production exercises anywhere (systemic)

- **Milestone/Lesson:** all 48
- **Severity:** HIGH · **Category:** ACTIVE_LEARNING_MISSING
- **Concept:** learner transfer / independence
- **Current teaching:** read → guided copy → run → self-check Q&A. Predict
  and break-it-observe steps exist and are good.
- **Why insufficient:** nothing ever asks the learner to produce code the
  lesson didn't show — the only way to know they can use the concept outside
  the Millionaire app. Directly undermines goal B (independent capability).
- **Remediation:** add a short "Tự làm" exercise to each lesson's end
  (1 small task, not graded); add a milestone-end synthesis exercise.
  Lightweight — no grader needed, model answer collapsible.
- **Fix before:** start adding at remediation; **required** in every lesson
  from M15 onward (gate).

## F-12 — No concept registry / glossary / revisit path (governance+IA)

- **Milestone/Lesson:** site-wide
- **Severity:** LOW (P4) · **Category:** CONTENT_MANAGEMENT_GAP
- **Remediation:** generate a `concepts.md` index (concept → milestone/lesson);
  add per-lesson "khái niệm" metadata so it stays current.
- **Fix before:** not blocking; opportunistic.

## Summary counts

- CRITICAL: 0
- HIGH: 3 (F-06, F-07, F-11)
- MEDIUM: 4 (F-04, F-05, F-08, F-10)
- LOW: 5 (F-01, F-02, F-03, F-09, F-12)
- USED_BEFORE_TAUGHT instances: 3 (F-03 claim, F-04 claim+use, F-09 order)
- MISSING concept explanations (never explained): 0 (`factory` is THIN not absent)
- CODE_FIRST_MAJOR findings: 1 (M14/03; M14/01–02 are CODE_FIRST_MINOR)
- MENTAL_MODEL_GAPS (required list PARTIAL): 3 (DI, repository, BehaviorSubject/ValueStream)
