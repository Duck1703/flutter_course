# M19 — Content QA (Argus, independent)

## Round 1 — FAIL

3 MAJOR (learner-facing code defects):
- **M1** L05 taught `create:` without `..startNewGame()` and invented a
  `!_dirty`-in-create constraint — opposite of shipped code + senior
  verbatim shape.
- **M2** L02 teardown omitted `onboarding_content_data.dart` update →
  declared "analyze sạch" checkpoint unreachable.
- **M3** L02 used `sampleQuestions`/`sampleEasyQuestions` — real names
  are `gameSample*`.

10 MINOR: `_loadNextQuestionOrVictory` name; senior reducer path;
`questionCounter` placeholders + over-claimed senior parity; missing
`continuePlayingButton`; dead-key names; `_viewModel` guards dropped;
missing `dart:async` note; test helpers invented (`miniBank`/`option()`);
harness wiring under-specified; missing `fake_async` dev-dep step +
`FakeAsync().run` form; L02 anachronism; manifest skeleton claims.

## Round 2 — PASS (after remediation)

All r1 findings verified fixed. New findings: 6 MINOR + ~10 NIT —
flowToken "Thử nghiệm" experiment couldn't reproduce without the
session re-entry chain (phase guard blocks stale callback); L06 DEBUG
under-specified; `wrongOptionOf` undefined in Đáp án; old model field
count 4→3; L01 impossible-combo wording; bare enum names in L03
snippet; plus NITs (dead-key names, bank-test direction, `Future<void>`,
diagram timeout path, provenance fixes, stale internal counts).

## Post-PASS mutation re-verify — PASS (targeted)

All 6 MINORs + NITs fixed; 3 residual NITs (token ordinals wording,
`WidgetsBinding` import attribution, `quiz_questions.dart` literal
name) also fixed.

## Verified load-bearing claims

- Code snippets near-verbatim to shipped files (`GameSessionState`,
  mapper, VM bodies, bridge, nav controller, main.dart wiring).
- Checkpoint arithmetic reconciles exactly: M18 baseline 102 → L02 95
  → L03 99 → L04 116 → L05/L06 **126** (per-file counts verified on
  disk: bank 7 + mapper 4 + VM 17 + sealed 5 + widget 10 + unchanged
  rest).
- Deferred boundaries consistently labelled: M20 lifelines, M21
  `GameDialogLayer`, M22 pop-result retirement, M26 DRE, FR-33 share.
- Registry rows D-33/D-34/F-27/A-18/A-19/A-20 + prereq-graph M19
  section present.
- Vietnamese prose + `:::note`/`:::caution`/`<details><summary>Đáp
  án</summary>` conventions conform.

## Note

Host stale-read anomaly recurred during review (one `read` returned a
pre-fix snapshot); all verdicts grep-verified — treated as
authoritative, matching the anomaly documented in implementation QA.
