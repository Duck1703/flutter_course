# M17 HANDOFF TO M18

| Item | State |
|------|-------|
| M17 final verdict | **MILESTONE_COMPLETE** |
| Tests | 90/90 (87 M16 → +3 M17) |
| Website pages | 89 (83 + 6 m17) |
| Register changes | FR-26 → CONVERGED at M17; FR-31 OPEN (ACTIVE_TEMPORARY — quiz-bank, repo errors, **onboarding l10n → M18**) |
| Concept registry | D-31 (`.arb`/`@key`), F-25 (gen-l10n/`MaterialApp.locale`), A-16 (locale=derived state; UI-owns-strings) |
| Prereq graph | M17 nodes closed; M18 onboarding l10n prereq (l10n infra) satisfied |
| Content gaps | F-15 RESOLVED; register otherwise non-blocking |
| Active fidelity entries into M18 | FR-05 (phase machine→M19), FR-07 (dialog layer→M21), FR-16 (showDialog→M21), FR-27→M27, FR-28→M22+/M27, FR-29→M21, FR-30 (assets), **FR-31** (onboarding l10n portion due in M18) |
| M18 prerequisites | YES — `OnboardingRepository` contract exists (M14); l10n infra live (`AppLocalizations` + delegates + `MaterialApp.locale`); persisted settings stream drives locale without restart |

M18_PREREQUISITES_SATISFIED: YES

Notes for M18 Flux:
- Onboarding strings go into the SAME `app_en.arb`/`app_vi.arb`
  (extend, don't fork) — then re-run `flutter gen-l10n`.
- New onboarding widgets read `AppLocalizations.of(context)` directly;
  keep VM/flow logic context-free per A-16.
- `OnboardingRepository` impl may still be stub — check brief scope.
