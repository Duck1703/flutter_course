# M20 — CONTENT QA (Argus, independent)

## Round 1 — VERDICT: FAIL (remediated)

Independent content QA (subagent) reviewed `04-content-draft.md`,
`lessons/index.md`, `lessons/01–05` against `02-implementation.md`,
`01-brief.md`, on-disk learner app, senior `main@c8eb860`, and
`project-context/` contracts. Deep snippet-level diffing verified
**all quoted code byte-identical to disk** and senior citations
honest. The blocking findings were staging defects, not content
truthfulness:

### MAJOR-1 — L02 checkpoint unreachable (sealed exhaustiveness)

L02 Step 1 added 3 sealed subclasses to `GameDialogState`
(`GameConfirmWalkAwayDialog`, `GameAudiencePollDialog`,
`GameAIAssistantDialog`) while the lesson never touched
`game_screen.dart`, whose `_title` (659) / `_content` (677) /
`_actions` (979) are all-explicit switch **expressions** with no
`_` arm (`_titleColor` alone survives via `_`). Result: immediate
compile errors + `sealed_state_test.dart` also breaks → the
lesson-promised `analyze sạch` + `131/131` checkpoint was
unreachable. The lesson's own caution even claimed the opposite
("mọi thứ vẫn compile").

**Fix applied:** variants now land **with their UI** —
- L02 keeps only `GameAudiencePollItemData` (plain class, additive,
  needed by `buildGameAudiencePollItems`).
- L03 Step 1 adds `GameAudiencePollDialog` + Bước 5 adds its 3
  arms + Bước 6 updates the sealed test (7 variants).
- L04 new Bước 1 adds `GameConfirmWalkAwayDialog` +
  `GameAIAssistantDialog` + Bước 6 adds their arms + Bước 7
  updates the sealed test (9 variants, senior parity).
- L02 caution rewritten as TEACHING SCAFFOLD explaining *why*
  sealed variants must travel with arms; checkpoint bullet now
  says sealed test is *unchanged* at L02.

### MAJOR-2 — L03 `_actions` poll arm falsely claimed unnecessary

L03 Step 5(d) showed only `_content` + `_title` arms and claimed
"generic arm của `dismissDialog` … không cần code thêm". False on
two counts: the `_actions` switch needs the explicit
`GameAudiencePollDialog() => [ĐÃ HIỂU button]` arm for
exhaustiveness, and the widget test's "ĐÃ HIỂU đóng" assertion
needs that button.

**Fix applied:** `_actions` arm added to L03 Bước 5(d) with the
two-layer explanation (VM `dismissDialog` is generic — no new
method; UI `_actions` switch still needs its arm).

### MINOR fixes applied

- **MINOR-3** — `GameAnswerOptionData.copyWith` doesn't exist at
  M19; L02 now teaches the *whole method* including the
  `clearAudiencePercentile` flag (D-34 pattern), instead of
  pretending a method exists to add one line to.
- **MINOR-4** — `submitAnswer`'s `answerText.isEmpty` guard
  existed since M19 (verbatim `_submitAnswer` port); L03 step (d)
  reworded to "đọc lại/verify", not "add". Manifest claim fixed.
- **MINOR-5** — L04 now shows the `showDialog` builder call-site
  change (`dialog:` → `viewModel:` + `AppLocalizations.of(
  dialogContext)`) and names the real dispatch site (`switch
  (action)` inside `_showCurrentDialog`, not a nonexistent
  `_onDialogAction`).
- **MINOR-6** — `lessons/index.md` gained the mandated
  `## Tổng kết milestone (synthesis)` 5-question section matching
  M18/M19 form.
- **MINOR-7** — `Android / Compose bridge` + `Senior project
  connection` added to L02, L03, L04 (required sections, not
  droppable); `Thử nghiệm` added to L01 (CORE requires), L02, L03,
  L04. L05 (LIGHT) drops declared in manifest.
- **MINOR-8** — manifest gained the missing contract sections:
  per-lesson goals, prerequisites, ≤30-line confirmation,
  code-explanation coverage, per-lesson bridges, per-lesson common
  mistakes; last self-check item ticked.

### NITs fixed

- `unawaited` attribution: M19 → **M11/D-17** (correct per
  registry).
- `fold<int>` and `find.descendant` now named as first-appearance
  APIs in their lessons.
- L02 typos (stray backtick, `?? ` space) fixed.
- Stale quoted comment `(context.watch)` → matches fixed
  production comment `(ListenableBuilder — host đọc live)`;
  production comment itself corrected in the same pass.
- Brief/registry ID drift (F-29 vs D-35/D-36/F-28) documented in
  manifest "Notes for QA".

### Post-PASS-mutation note

One production file touched during remediation:
`lib/view_models/game/game_screen_view_model.dart` — comment-only
fix (context.watch → ListenableBuilder wording). No behavior
change. Test count arithmetic unchanged (sealed-test updates are
modifications: 6-arm switch grows arms, not new tests).

## Round 2 — VERDICT: PASS (independent re-verify)

Fresh Argus subagent re-verified all r1 findings against live disk:

| Finding | Result |
|---|---|
| MAJOR-1 sealed-variant staging | **VERIFIED FIXED** — no `extends GameDialogState` in L02; L03 adds poll variant + 3 UI arms + sealed-test update (7); L04 adds walk-away+AI variants + arms + sealed update (9); arithmetic 131/141/147 consistent; L04 renumbering internally consistent |
| MAJOR-2 `_actions` poll arm | **VERIFIED FIXED** — arm shown byte-identical to disk:1012-1017; two-layer VM-vs-UI explanation correct |
| MINOR-3 copyWith whole method | **VERIFIED FIXED** — full method incl. `clearAudiencePercentile`, byte-identical disk:64-78 |
| MINOR-4 submitAnswer guard | **VERIFIED FIXED** — "không sửa gì, chỉ đọc lại"; claim true (M19 L04:179, VM disk:110) |
| MINOR-5 call-site + dispatch | **VERIFIED FIXED** — `viewModel:` call-site shown byte-identical to disk:166-174; dispatch correctly named `switch (action)` in `_showCurrentDialog` |
| MINOR-6 index synthesis | **VERIFIED FIXED** — `## Tổng kết milestone (synthesis)` 5-question section, M19 format |
| MINOR-7 template sections | **VERIFIED FIXED** — bridge + senior-connection in L01-L04; `Thử nghiệm` in L01-L04; L05 drops declared |
| MINOR-8 manifest coverage | **VERIFIED FIXED** — all contract sections present; self-checks ticked |
| NITs | **VERIFIED FIXED** — `unawaited`→M11/D-17; `fold`/`find.descendant` named; typos gone; prod comment updated on disk |

### Residual (post-PASS remediation, non-blocking)

- MINOR L04:50 stale bullet → **fixed** (restored M15/M19/D-27
  prereq + self-reference to Bước 1).
- NIT sealed-test `expect` lines in L04 Bước 7 → **fixed**
  (both constructs now quoted verbatim, diffed vs disk).
- NIT manifest "Checkpoint + Tự làm" vs L01 drop → **fixed**
  (reworded Checkpoint / DEBUG+PRODUCE).

Process note: three file states observed mid-review due to
in-flight remediation; final state verified consistent via
multiple live greps. All edits confirmed persisted post-fix.

**FINAL: CONTENT QA PASS — all blocking findings resolved.**
