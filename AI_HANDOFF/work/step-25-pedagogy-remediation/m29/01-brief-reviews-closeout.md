# M29 — Step-25 Brief + Dual Review + Atlas + Closeout

CONTENT_REVISION: `4d54ea6b52eacce6` (sha256 of m29/*.md, frozen post-edit)

## Audit (all 7 lessons)

All lessons already carry PREDICT/DEBUG/PRODUCE exercises. Interventions
target the derive-before-reveal band:

- 01 nen-mong-assets-tokens-arb (S, F-H3 process-as-model): mental model is
  a *process* (đọc→diff→port→verify) — learner must run it, not read it.
  Added mini-run derive: predict 45-vs-8 const count, classify the 37
  missing (incl. shipped-but-unreferenced), port one const unaided, pick
  the parity check. No senior-repo access required (answers embedded).
- 02 settings-chrome-iconasset (S): already strong (sealed iconAsset +
  monolith→layers) — noise only.
- 03 duong-ong-leaderboard (S): one-seam lesson — noise only.
- 04 be-mat-menu (S): added derive — decompose menu surface into
  profile/ files, content-vs-screen split, predict adapted-vs-verbatim
  diff locus.
- 05 lop-dialog-menu (S): added derive — enumerate MenuDialogState
  variants, predict payloads, sealed-vs-enum. Answer embedded:
  None/Leaderboard/Settings/Auth/SignOut, no payloads, sealed class.
- 06 visual-onboarding (S): added derive — design OnboardingHeaderConfig
  fields, key-vs-index, excluded fields. Answer embedded: title/color/
  badgeGradient/badgeAsset.
- 07 hoi-tu-quet-cuoi (S, capstone): added self-contained note — every
  verbatim excerpt needed is in-lesson; previews appendix explicitly
  optional (6/12, declared gap). Kept NOT_PERFORMED caveats verbatim.

## Interventions

- ADD_DERIVE_FIRST: m29/01, m29/04, m29/05, m29/06.
- ADD_SELF_CONTAINED_NOTE: m29/07 (capstone + appendix optionality).
- REMOVE_NOISE: ~225 prose ID tokens (heaviest band).
- ORTHOGRAPHY: plain-VN compounds normalized; tech compounds preserved.

## Argus Technical QA — PASS

- m29/05 derive answer verified vs `learner-app/lib/view_models/menu/
  menu_dialog_state.dart`: 5 variants (None/Leaderboard/Settings/Auth/
  SignOut), sealed class, no payloads — matches.
- m29/06 derive answer verified vs `learner-app/lib/data/onboarding/
  onboarding_header_config.dart`: 4 fields title/color/badgeGradient/
  badgeAsset — matches.
- m29/01 derive consistent with real `app_assets.dart` (45 const senior
  parity incl. unreferenced) and m29/07 caveats match canonical state.

## Pedagogy Reviewer — PEDAGOGY_PASS

- F-H3 at M29: process-as-model converted to learner-run derivation;
  three port-heavy lessons gain pre-reveal derivation.
- Capstone confirmed self-contained (P1) — no external repo access needed.

## Atlas — APPROVED

Dual review on `4d54ea6b52eacce6`; scope = m29/** + index only.

## Closeout

- Verdict: **COMPLETE**.
