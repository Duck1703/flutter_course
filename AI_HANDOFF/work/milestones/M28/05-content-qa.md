# M28 Content QA — Argus Report + Remediation

**Reviewer:** Argus (independent subagent, explore profile)
**Verdict:** `PASS_WITH_FINDINGS` → remediated → **PASS**

## Argus findings

| # | Severity | Finding | Remediation |
|---|----------|---------|-------------|
| 1 | MAJOR | L04 falsely claimed ladder rows are `GameDialogMoneyRow` — disk truth: private `_LadderItem` (128–209), no shell import | Fixed 3 sites (L04:223, :363-365, manifest:295) → `_LadderItem` + explicit "KHÔNG phải GameDialogMoneyRow" |
| 2 | MAJOR | L02 misdescribed test API (`getSemantics` vs `find.bySemanticsLabel`) + wrong PREDICT answer (claimed test stays green; truth: goes red — `Text('PLAY')` creates 2nd `'PLAY'` node → `findsOneWidget` fails) | Fixed API name + corrected answer to **test đỏ** with semantics-tree reasoning |
| 3 | MODERATE | Concept-ID misattributions (7 lesson sites + manifest roll): import/export cited D-05 (copyWith), gradients F-23 (Switch), constraints F-12 (Navigator), `@visibleForTesting` D-44 (AuthActionResult), `styleFrom` F-22 (GlobalKey), `RegExp` D-33/D-36, `CNP`+read/watch F-21 | F-12→F-07, F-21→F-18/F-17; unregistered items (`export` barrel, gradients, `DecoratedBox`, `@visibleForTesting`, `styleFrom`, `RegExp`) de-ID'd with "chưa có registry row" labels; manifest roll cleaned (D-44 removed) |
| 4 | MINOR | "8 case" — actual `GameDialogState` = 9 variants (8 display + Hidden) | Fixed L05:46 + manifest → "9 variant/nhánh" |
| 5 | MINOR | Evidence doc stale: test counts (flow 7/timer 7/money 6/answer 4/blink 3/panel 1), "width-390" → 375, "press-scale" → `QzdsButtonScale` preset | All corrected in `02-implementation-evidence.md` |
| 6 | MINOR | Small drifts: CTA described as leading-into dialog (it's inside, `ĐÃ HIỂU`); "four buttons" → 3–4 (walkAway conditional); manifest line refs (`_semanticLabel` 123–131, `Stack` 85–119, `_glitchLayers` 89–104, vm_test ~606/~782); index.md "30 verbatim" → 28+2 converged; `getSemantics` first-use gloss missing in L04 | All fixed; `:::note` gloss added in L04 explaining `getSemantics`/`matchesSemantics` debut (F-43 named at L05) |

## Argus-verified positives

- ~25 code excerpts spot-checked — all verbatim-faithful (elisions marked).
- Sequential executability: import DAG holds; L05's new-path layer
  coexists with old layer until L06 atomic swap; no file imports
  something created later.
- Checkpoints reconcile exactly: 259→263→270→276→289→309 (+50).
- Zero `::::`/`:::::` remnants; all `:::` blocks balanced (re-verified
  post-remediation: open=close per file).
- 5 isolated examples properly marked; parity disclosures present
  (pulse/sheen ignore disableAnimations; AppAssets subset-8;
  uppercase; money interpolated digits; GoogleFonts runtime fetch).
- New IDs correctly allocated: A-38/A-39, D-48, F-38–F-43 — all free,
  right lessons, never taught after first use.

## QA verdict

**PASS** — content is evidence-grounded, sequentially executable,
and honest about scaffolds/parity choices.
