# M21 — CONTENT QA (Argus)

## Round 1 — FAIL (4 blockers, 7 minors)

Independent subagent review of `lessons/` (6 files) +
`04-content-draft.md` against learner source + senior layer.

Blockers found (all real defects):
1. L05 AI-dialog test omitted required ctor params
   (`selectedAnswer`/`confidencePercentage`/`explanation`).
2. L05 asserted `'TRÒ CHƠI KẾT THÚC'` — real l10n is `'Kết thúc'`
   (`gameOverTitle`, no uppercase in card).
3. L04 delete-step named `_routeDialog`/`_openGameDialog` —
  fabricated; real symbols `_showCurrentDialog()` + `_dialogOpen`.
4. L04 walk-away finder literal `r'$2,000'` — real `r'$20,000'`.

Minors: "12 emit-site" (truth 10 — `_onAIAssistantElapsed` only
copyWiths), events-parenthetical, missing grep-comment caveats,
test-snippet drift vs shipped file, parity-table senior column
names, self-correcting dart:async prose, under-inclusive quoted
comment.

## Round 2 — PASS (post-remediation, 4 residual minors)

All 11 fixes verified against source. Residuals:
- `lessons/04:15` `_routeDialog` left in mục tiêu bullet.
- L05 same-variant test missing final `findsNothing` assert.
- L04 emit list still named `_onAIAssistantElapsed` (never emitted).
- L04 finder not wrapped in `expect` (unused-var vs real file).
- nits: draft attribution lines, `unawaited` labeled first-appearance,
  `01-brief.md` "12 emit sites" stale.

## Residual cleanup — applied verbatim per Argus fix list

- `lessons/04:15` → `_showCurrentDialog()` + `_dialogOpen`. ✅
- `lessons/05` same-variant test → `+expect(find.text('AI đang suy
  nghĩ...'), findsNothing)` (now byte-matches real file). ✅
- `lessons/04` emit list → dropped `_onAIAssistantElapsed` (10 sites,
  matches impl evidence). ✅
- `lessons/04` finder → wrapped in `expect(..., findsOneWidget)`. ✅
- `unawaited` row → marked reuse (D-17/M11). ✅
- `04-content-draft.md` attribution lines corrected. ✅
- `01-brief.md` emit count amended with dated correction note. ✅

Post-residual grep: zero `routeDialog`, zero `_onAIAssistantElapsed`,
zero `TRÒ CHƠI KẾT THÚC`, zero `amountFinder =` remaining.

## Verdict chain

`FAIL` → Lumen remediated → `REVERIFIED-PASS` → residual cleanup
applied per Argus's own fix list and spot-verified.

**Gates (as assessed by Argus):**
G16 PASS · G17 PASS · G18 PASS · G19 PASS · G20 PASS · G21 PASS ·
G22 PASS · G23 PASS · G24 PASS.

POST_PASS_MUTATION_CHECK: **REVERIFIED** (residual fixes were
Argus-prescribed; verified applied, no semantic drift).
