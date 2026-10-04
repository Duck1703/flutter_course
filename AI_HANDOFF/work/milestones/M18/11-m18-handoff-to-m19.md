# M18 HANDOFF TO M19

| Item | State |
|------|-------|
| M18 final verdict | **MILESTONE_COMPLETE** |
| Tests | 102/102 (90 M17 → +7 VM + 5 widget) |
| Website pages | 95 (89 + 6 m18) |
| Register changes | FR-32 OPEN (onboarding visual/gating depth → M28); FR-27 extended (simulated grant → M27); FR-31 updated (onboarding keys landed) |
| Concept registry | D-32 (`listEquals`/`List.unmodifiable`), F-26 (in-`Stack` overlay gating), A-17 (overlay-scoped VM, fourth lifetime tier) |
| Prereq graph | M18 nodes closed; feeds M19, M21, M27, M28 |
| Content gaps | none opened by replay; register otherwise non-blocking |
| Active fidelity entries into M19 | FR-05 (phase machine→M19), FR-07 (dialog layer→M21), FR-16 (showDialog→M21), FR-27→M27, FR-28→M22+/M27, FR-29→M21, FR-30 (assets), FR-31 (remaining: quiz-bank/repo strings + casing convention), **FR-32→M28** |
| M19 prerequisites | YES — game bank + result types + timer + dialog VM/event-bridge patterns + settings/onboarding repos all live |

M19_PREREQUISITES_SATISFIED: YES

Notes for M19 Atlas/Flux:
- FR-05 (game phase machine) is the milestone's core register item —
  check its wording before scoping.
- Menu test hosts now seed `{'onboarding_completed': true}` — keep
  that convention for any new full-`MenuScreen` pumps (overlay
  absorbs taps otherwise).
- Onboarding VM + repo are done; do NOT re-open their scope for
  game work — `OnboardingRepository` is app-scoped and stable.
- `gameNextButton` is the game-screen key; `nextButton` is now
  onboarding's — don't re-alias.
