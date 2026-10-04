# 10 — Remediation Priority (Atlas)

**Plan only — do NOT execute.** Findings ordered P0→P3.

## P0 — none

No CRITICAL/HIGH findings. The course direction is senior-faithful.

## P1 — must fix before M14 (blocks "trusted baseline")

- **FD-01** (MEDIUM, MISLEADING_TEACHING, CONTENT_ONLY): fix
  `m03/01` senior-claim — `MenuScreen` is `StatelessWidget`; statefuls are
  `MenuScreenView` (dismiss-lock) + `_MenuScreenEventBridge`; `dialogState`
  lives in the VM. Owner: Lumen.
- **FD-04** (MEDIUM, ROADMAP + CANONICAL_CONTEXT): make model-parity
  explicit — M14/M19/M22 scope notes must name the target field set
  (`totalEarnings`, `totalQuestionCount`, drop `expForNextLevel`, senior
  defaults `'0XFF'`/zeros, defensive-parse depth, `?avatarUrl` omission) so
  the drift ends by decision, not accident. Owner: Atlas.
- **FD-12** (MEDIUM, ROADMAP): reconcile M09 roadmap scope text with shipped
  scope — annotate the M09 section (money-per-question, reveal delay,
  explanation dialog landed at M19/M20 instead) or add a dated scope note.
  Owner: Atlas.

## P2 — fix alongside M14–M16 (natural touchpoints)

- **FD-02** (MEDIUM, ROADMAP + CONTENT_AND_CODE): attach explicit
  removal/replacement milestones to the four menu scaffolds — sound toggle →
  M16 (real persisted sound switch in settings dialog), reset button → M24
  (sign-out reset), session ticker + tap counter → latest M29 parity pass
  (or earlier menu-parity step). Also covers `_LeaderboardEntry` tap wiring →
  M23. Owner: Atlas + Lumen.
- **FD-06** (MEDIUM, CONTENT_ONLY + ROADMAP): annotate `MenuLoadState` as
  expiring at M14 (stream-seeded repo makes it unnecessary) — lesson note +
  M14 brief line. Owner: Lumen/Atlas.
- **FD-05** (LOW, ROADMAP): M14 must implement `resetUserProfile()` as
  write-default (senior semantics), replacing `clear()`→remove. Owner: Flux
  (at M14 production).

## P3 — hygiene / opportunistic

- **FD-03** (LOW, LEARNER_CODE_ONLY): remove or relocate
  `demo_profile_loader.dart` (dead in lib/ since M10) — or convert its
  docstring to explicitly "kept for experimentation".
- **FD-07** (LOW, ROADMAP): assign portrait-lock to an explicit milestone
  (natural fit: M19 game screen or M29 bootstrap parity).
- **FD-09** (LOW, CONTENT_ONLY): m13/03 one-liner — senior declares
  `MenuSnackBarRequested` but emits snackbars from dialog VMs at M24.
- **FD-11** (LOW, ROADMAP): name full `GameQuizQuestionData` shape as an
  M19/M20 scope item.
- **FD-10** (INFO, CANONICAL_CONTEXT): record SENIOR_SOURCE_CONCERN — senior
  silently drops `openGame()`'s Future; learner `unawaited` is stricter.
  No change to learner; document only.

## Recommended remediation grouping (suggested batches)

- **Batch A — content precision (P1, cheap):** FD-01 lesson fix + FD-09
  one-liner + FD-06 note. Pure content edits, no code.
- **Batch B — roadmap/context precision (P1–P2):** FD-04, FD-12, FD-02,
  FD-07, FD-11 milestone-scope annotations in `MILESTONE_ROADMAP.md` +
  canonical notes. No learner code.
- **Batch C — code hygiene (P2–P3, inside next milestone):** FD-03 loader
  removal + FD-05 enforced naturally when M14 lands the repository contract.
- **Do NOT fix:** anything outside this list; no creative re-architecture.

## Handoff

Atlas final verdict in `11-final-atlas-verdict.md`. Supervisor decision on
ordering is expected in the Step-09 review.
