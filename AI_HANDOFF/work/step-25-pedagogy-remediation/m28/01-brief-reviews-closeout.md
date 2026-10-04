# M28 — Step-25 Brief + Dual Review + Atlas + Closeout

CONTENT_REVISION: `2c90711a178c8ad7` (sha256 of m28/*.md, frozen post-edit)

## Audit (all 6 lessons)

- 01 nen-mong-tokens-assets (S, F-H3): `AppTokens` 318d + `AppAssets`
  verbatim revealed immediately. Intervention: derive-first admonition —
  learner designs the lookup layer (const path shape, why-not-raw-strings,
  token-vs-parameter ownership, IconAsset→SvgPicture mapping site) before
  the verbatim port.
- 02 chrome-chung-pill-kinh-nen (S): noise only.
- 03 custompainter-animationcontroller-dong-ho (S): new-concept lesson
  (CustomPainter) — protected, noise only.
- 04 trigger-motion-so-tien-nhay (S): noise only.
- 05 be-mat-game-va-lop-dialog (S): noise only.
- 06 hoi-tu-iconasset-atomic-swap (S, F-M2): atomic migration — added
  PHẦN A (prep contract) / PHẦN B (atomic flip, red-by-design) /
  PHẦN C (cleanup + verify) markers over existing Bước 1–7; the
  mid-way-red caution already present and preserved.

## Interventions

- ADD_DERIVE_FIRST: m28/01 (lookup-layer design).
- ADD_PHASE_MARKERS: m28/06 (A/B/C over existing steps).
- REMOVE_NOISE: ~170 prose ID tokens.
- ORTHOGRAPHY: heavy hyphenation normalized (plain-VN compounds only;
  ASCII tech compounds like `vm-test`, `custom-painter` preserved).

## Argus Technical QA — PASS

- m28/01 derive prompts consistent with real code: `AppAssets` 8 const
  String subset, `screenDesignWidth` in `AppTokens`, `IconAsset` →
  `SvgPicture` resolved in mapper/widget boundary as learner impl shows.
- m28/06 markers match actual step boundaries; atomic-red semantics
  preserved verbatim.

## Pedagogy Reviewer — PEDAGOGY_PASS

- F-H3 at M28: design-layer derivation precedes reveal.
- F-M2 at m28/06: A/B/C chunking makes the atomic boundary legible.
- Highest exercise levels unchanged; protected new-concept lesson intact.

## Atlas — APPROVED

Dual review on `2c90711a178c8ad7`; scope = m28/** + index only.

## Closeout

- Verdict: **COMPLETE**.
