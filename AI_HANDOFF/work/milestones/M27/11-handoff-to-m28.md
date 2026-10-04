# M27 → M28 Handoff

## State entering M28

- analyze clean, **259/259** tests, `flutter build web` PASS,
  site **152 pages**, senior `main@c8eb860` clean.
- M27 shipped: notification service+coordinator+permission state,
  share chain via M26 effects-stream, `v$appVersion`, manifest
  platform declarations.

## M28 scope (roadmap + register)

Visual parity convergence: countdown `CustomPainter` ring +
low-time pulse, money-amount animation, `GameDialogButton`/
sheen/glow/gradient + dialog styling, design-token consolidation,
selected SVG assets, `AnimationController`/`AnimatedBuilder`/
`Tween`/`CurvedAnimation`, `MediaQuery.disableAnimations`;
widget assertions (no golden tests).

## Known scaffold to retire in M28

- `_DialogShareButton` (game_dialog_views.dart) — learner chrome;
  senior uses `GameDialogButton` + `shareColor` (0xFF325DFA ended /
  green victory). TEACHING SCAFFOLD callout already shipped in
  M27/L05.

## Open register rows M28 owns

- FR-28 residual: `_SettingsAccountRow` visual parity.
- FR-30 `iconAsset` String+SvgPicture; FR-32 onboarding visuals;
  FR-34 `GameFeatureButton` painter/SVG/press-scale.
- Design tokens: `OnboardingTokens`/`GameDialogShell` gradients.

## Watch items

- `REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` (M27 carry-forward —
  honest notation, not a defect).
- M26 concept-label mismatch (lessons cite F-33/F-34; registry
  A-33/A-34) — gap register F-16, mechanical rename owned by M29.
- Do NOT touch: `MenuDialogLayer`/menu transport (M29), l10n
  coverage expansion (FR-31), `onAsyncOpError` override.
