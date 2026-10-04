# M18 — CONTENT DRAFT MANIFEST (Lumen)

## Intake gate

`IMPLEMENTATION_APPROVED` confirmed — `00-status.md` + `03-…-qa.md`
PASS on disk; learner app verified: analyze clean, 102/102 tests,
gen-l10n + build web pass.

## Lessons authored (5 + index)

| File | Concepts | Exercise |
|---|---|---|
| `index.md` | milestone map + 5-question synthesis checkpoint | — |
| `01-vi-sao-overlay-khong-phai-route.md` | F-26 (overlay≠route mental model) | comprehension checkpoint |
| `02-step-state-sealed-onboarding.md` | sealed step family (M15 reuse) + D-31 reuse (16 senior keys + gen-l10n) + content data | PRODUCE: 4th variant (no stepOrder) |
| `03-onboarding-view-model.md` (CORE) | D-32 `listEquals`/`List.unmodifiable`; A-17 guarded async + stream sub; D-30 reuse | DEBUG: remove `_languageSelectionInProgress` guard |
| `04-overlay-scope-va-menu-stack.md` | F-26 applied (scope gating, Positioned.fill, opaque absorber); A-17 overlay-scoped VM; FutureBuilder gate | PREDICT: completed-flag visibility |
| `05-hoan-thien-tests-tu-lam.md` | widget-test integration + regression | PRODUCE: skip-at-notification test |

## Registry / graph updates (done before QA)

- `LEARNER_CONCEPT_REGISTRY.md`: +D-32, +F-26, +A-17 (all TAUGHT).
- `PREREQUISITE_GRAPH.md`: M18 section appended.

## Declared section merges/drops (template V2)

- L01 (LIGHT/theory, no code changes): drops "Dart/Flutter cần
  dùng", "Build it step by step", "Hiểu code", "Thử nghiệm",
  "Lỗi hay gặp", "Tự làm" — nothing to run yet; checkpoint is
  comprehension. Keeps Mục tiêu / Bạn đang ở đâu / Vì sao / Bạn đã
  biết / Mental model / Ví dụ độc lập (mini Stack sketch) / Bridge /
  Senior connection / Chạy (observation-only) / Kiểm tra / Ta cố ý /
  Checkpoint.
- L02 (NORMAL): drops "Mental model mới" (the queue model lives in
  L03; L02 is mechanical data+keys). `Ví dụ độc lập` present as a
  declared fold ("không cần — step data chính là mẫu"). Everything
  else present incl. Bridge + Tự làm (PRODUCE, scoped to L02, with
  explicit revert-before-L04 constraint).
- L03 (CORE): **full skeleton** — incl. "Dart cần dùng", "Flutter
  cần dùng", "Ví dụ độc lập" (queue mini), "Thử nghiệm" (seeding
  assert flip), "Tự làm" (DEBUG the re-entrancy guard).
- L04 (NORMAL): "Mental model mới" + "Ví dụ độc lập" present as
  declared folds (application of F-26/A-17, not new concepts).
  Everything else present incl. Bridge, Thử nghiệm, Tự làm
  (PREDICT). Bước 2 labelled non-compiling (imports overlay file
  created at Bước 3).
- L05 (NORMAL): "Mental model mới" + "Ví dụ độc lập" present as
  declared folds. Everything else present incl. Bridge, Thử nghiệm,
  Tự làm (PRODUCE skip-at-notification test).

## Known sequencing guarantees

- ARB keys + gen-l10n land in **L02** (before any `l10n.onboarding*`
  call site appears in L04) — brief had them at L05; moved up to
  keep every checkpoint compilable.
- VM test file created in L03 (its own checkpoint);
  overlay widget test in L05.
- L04 checkpoint = 97/97; L05 end = 102/102.
- `gameNextButton` rename + completed-flag test-host patches are
  taught explicitly (L02 caution + L04 Bước 5).

## Fidelity statements to verify (QA)

- Sealed step data + VM are senior-identical (modulo doc comments).
- Scope = senior-shaped minus inner StreamBuilder (FR-32).
- Overlay visuals simplified (FR-32); notification grant simulated
  (FR-27 extension); `LanguageChipRow` promoted to senior file path.
- No route/showDialog for onboarding; quiz-bank/repo strings stay
  literal (FR-31).
