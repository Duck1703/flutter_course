# M18 — Argus content QA

## QA round 1 — FAIL

Findings (all remediated):

- **MAJOR**: all 5 lessons + index used a compressed custom skeleton
  instead of Template V2; non-droppable sections omitted without
  manifest declaration (manifest falsely claimed all present).
- MINOR: Tự làm lacked `Gợi ý`/`Đáp án` hidden formatting; L03
  exercise too revealing; index missing canonical
  `## Tổng kết milestone` synthesis; L04 unlabeled non-compiling
  step; frontmatter missing `description`/`sidebar.label`.

Lumen remediation: full rewrite of all 6 files to the canonical V2
skeleton; manifest drops declaration corrected to match reality;
Tự làm re-shaped with `:::note[Gợi ý]` + `<details>Đáp án`; index
5-question synthesis added; frontmatter completed; L04 Bước 2
labelled non-compiling.

## QA round 2 — PASS

Full re-verification on disk: all 5 lessons carry canonical `##`
sections (L01: 12; L02–L05: 17–18 each); manifest drops match
reality exactly; L03 CORE has full skeleton incl. `Thử nghiệm` +
genuine `Tự làm`; index `Tổng kết milestone` answers all 5
synthesis questions; frontmatter complete on all 6 files.

Verified TRUE claims: VM byte-identical to senior modulo doc
comments; scope = senior minus inner `StreamBuilder` +
`LocalNotificationService`; 16 ARB keys verbatim both locales;
`menu_screen_view.dart:95` citation exact; test counts
90→97→102 arithmetically correct; test-host patches match disk;
registry D-32/F-26/A-17 TAUGHT; FR-27/FR-31/FR-32 entries updated;
`gameNextButton` rename consistent; `LanguageChipRow` promoted to
senior path.

Findings (remediated): MINOR-1 `D-12`→`D-18` cascade citation;
MINOR-2 `F-11`→`F-10` FutureBuilder citations (×2); MINOR-3 hint
format → `:::note[Gợi ý]` + answer label → `Đáp án`; NIT-3 L04
experiment wording corrected; NIT-4 L01 widget-chain precision.

Accepted as-is: NIT-1 section order (matches M17 shipped
convention); NIT-2 transient duplicate key between Bước 2→3 (no
command runs between — benign).

## Targeted re-verify — PASS

All 5 post-PASS mutations verified on disk; sanity sweep clean (no
`D-12`/`F-11`/`tham khảo` remnants; `:::note`/`details` blocks
balanced). Cosmetic: L04's `:::` closer lacks a preceding blank
line (valid syntax, non-blocking).

## Verdict

**CONTENT QA: PASS.** Implementation claims truthful; template V2
compliant; register/prereq references correct; sequencing sound.
