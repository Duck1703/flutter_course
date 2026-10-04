# M21 — Senior dialog layer & back handling

State: `MILESTONE_COMPLETE` — all stages green; M22 may begin per long-run contract.

## Ledger

- Baseline re-verified before brief: learner `flutter analyze` clean,
  `flutter test` 147/147, `flutter build web` PASS; site 108 pages;
  senior `main @ c8eb860` clean (read-only).
- Atlas brief written — `01-brief.md` (senior inspected live:
  `widgets/game/dialogs/game_dialog_layer.dart`,
  `screens/game_screen.dart` PopScope/`_handleRouteBack`/`_afterExit`,
  all 4 dialog-view files + `game_dialog_shell.dart`,
  `design_frame.dart`, `app_design_tokens.dart` dialog tokens,
  `test/widgets/game_dialog_layer_test.dart` 355-LOC model).
  Register: FR-16 (dialog mechanism — primary), FR-07 (in-Stack layer
  converges for game scope). **New row FR-33 formalized**
  (GameShareResultEvent/share_plus → M27 — was referenced but never
  registered). Excluded: `_afterExit` choreography optional→implemented,
  menu dialogs (M29), GameDialogShell visual depth (M28), DRE (M26).
- Flux implementation complete — `02-implementation.md`:
  `GameDialogLayer` (215 LOC) + `game_dialog_views.dart` (670 LOC)
  new; `game_screen.dart` rewritten 1095→588 LOC; VM event emissions
  removed (10 sites); `GameDialogRequested` retired; 10 new layer
  tests; `flutter analyze` clean, `flutter test` **157/157**,
  `flutter build web` PASS.
- Argus implementation QA — `03-implementation-qa.md`: **PASS** →
  **REVERIFIED-PASS** after comment/timing remediation.
- Lumen content draft complete — `04-content-draft.md` + 5 lessons
  + index (registry +A-21/D-37/F-29/F-30, graph M21 section).
- Argus content QA — r1 **FAIL** (4 blockers) → remediated →
  **REVERIFIED-PASS** → residual minors applied; `05-content-qa.md`.
- Forge site integration + Argus site QA **PASS** (114 pages) →
  SITE_APPROVED; sequential replay **PASS** 5/5 (147→150→153→153→157).
- Final verdict **MILESTONE_COMPLETE** — `11-final-verdict.md`;
  canonical sync done; handoff `12-m21-handoff-to-m22.md`.
- Remediation counters: impl 1 (comments+timing+evidence) · content 1 ·
  site 0.
