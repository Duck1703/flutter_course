# M22 → M23 HANDOFF (Atlas)

M22 is `MILESTONE_COMPLETE`. **Hard stop honored — no M23 work has
begun.** This file only records entry conditions for the next run.

## M23 entry state (what's now true)

- `GameScreenViewModel` already owns result persistence via
  `userProfileRepository` (ctor-injected). M23 remote work extends
  this same boundary — it does **not** reintroduce route results.
- `UserProfileData` = senior's exact 9-field set; `fromMap` parse is
  defensive; `_isLegacyDemoProfile` purge intact.
- `_syncSavedGameResult()` stub sits ready inside `_saveGameResult`
  — it is the M24/M25 seam (auth check + `profileSyncRepository`),
  not M23 scope.
- `LevelConfig`/`MenuLevelProgress` are the single source of level
  truth; M23 must not re-derive thresholds elsewhere.

## Remaining fidelity debt (before/at M23+)

| Debt | Owner |
|---|---|
| `_syncSavedGameResult` real impl (auth session check → Supabase sync) | M24/M25 |
| DRE reducer + `GameSaveResult` asyncOp (`_emitWithSaveResult` → `_withSaveResult` op) | M26 |
| `shareResult` + `GameShareResultEvent` on terminal dialogs | M27 (FR-33) |
| `LevelProgressCard` ring/glass/tier-gradient; `menuMaxLevelReached` + `menuExpToNextLevel` l10n labels; max-level bar cosmetic (`9e15` raw display) | M28 |
| Menu `showDialog` → `MenuDialogLayer` | M29 (FR-16 remainder, FR-29) |
| `GameDialogShell`/`QzdsGameButton` chrome, lifeline SVG painters | M28 (FR-32/FR-34) |

## Carry-over test infrastructure for M23

- `FakeUserProfileRepository` (`saveCallCount`/`value`) — reuse for
  any remote-sync fakes M23 introduces.
- `startedVm(async, N, repo:)` + `async.flushMicrotasks()` pattern —
  the canonical way to test fire-and-forget saves.
- Pre-safe-haven walk-away still saves `gamesJoined` (L05 PRODUCE
  exercise demonstrates).

## Watch-items for M23 brief

- Roadmap M23 scope = Supabase bootstrap; keep local-save path
  authoritative (offline-first per M14 decision) — remote is a
  *sync layer*, not the source of truth.
- Any M23 content teaching remote reads must not contradict the
  M22 lesson's "stream là nguồn truth" model.
