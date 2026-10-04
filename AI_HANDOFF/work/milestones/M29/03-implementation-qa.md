# M29 — Implementation QA (Argus)

## Verdict: PASS_WITH_FINDINGS → remediated → **PASS**

Independent Argus review (fresh context, no authoring-state access)
verified all 8 implementer claims with concrete evidence:

| Claim | Verified by |
|-------|-------------|
| State-driven dialogs, zero `showDialog` | grep → 1 comment-only hit; sealed 5-variant `MenuDialogState` byte-identical; layer/view/VM byte-identical; 87-line screen, 2-event bridge |
| `MenuScreenViewModel` rename + 2-variant event family | byte-identical; retired classes 0 hits |
| Settings/leaderboard/onboarding/menu parity | ~25 files diffed byte-identical (mod rename); `iconAsset`, `LeaderboardRowStyle`, avatar/rank assets all present |
| `MenuTokens` retired | 0 matches lib+test; file absent; auth content uses `AppTokens`/`OnboardingTokens` |
| FR-31 ARB parity | 119 keys each side, sets identical; only `appTitle` diffed (pre-remediation) |
| `main.dart`/scope/nav verbatim | byte-identical |
| Structure | zero learner-only files; 6 intentional preview-catalog absences; `lib/build/` gone |
| Tests not weakened | ported files byte-identical (705-ln layer test, 332-ln VM test, 201-ln scope test, 400-ln widget_test); zero `skip:`/`anything` weakening; `sealed_state_test` still asserts real exhaustiveness |

## Findings & remediation

| # | Sev | Issue | Fix |
|---|-----|-------|-----|
| 1 | NIT | `settings_view_model.dart:25` stale "MenuViewModel" | renamed → `MenuScreenViewModel` |
| 2 | NIT | `menu_auth_dialog_view_model.dart:12` stale name | renamed |
| 3 | NIT | `app_vi.arb` extra `@profileLevel` metadata + key order | vi.arb realigned to senior order/metadata (only `appTitle` + product-rename deltas remain) |
| 4 | NIT | `pubspec.yaml` stale M28 asset comment | updated to reflect M29 full parity |
| 5 | NIT | ui_events doc muddle | tidied |
| 6 | OBS | share messages still said "Flutter Accelerator AI" | **product decision: extended documented rename** — share strings now "AI Millionaire" (en+vi); senior uses own product name |

Post-remediation: `flutter analyze` clean, **396/396** tests.
(Argus environment lacks shell; regression re-run by parent — confirmed.)

## Sign-off

- Argus verdict: PASS_WITH_FINDINGS (all NIT)
- Remediation: complete, regression green
- **Atlas: IMPLEMENTATION_APPROVED** — recorded 00-status.md
