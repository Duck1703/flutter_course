# 04 — Lumen Content Remediation

> Role: Lumen (lesson/content/canonical wording corrections)
> Scope: M01–M13 lessons only; every substantive change cites a Step-09
> finding ID. No style rewrites. Historical milestone descriptions kept
> truthful (lessons describe what the learner built THEN; the current-tip
> corrections carry the "it has since been removed/changed" notes).

## Changes by finding

### FD-01 — false senior state-ownership claim (M03/01)

`web/src/content/docs/m03/01-stateless-va-stateful.md`
- Corrected: senior `MenuScreen` is a **StatelessWidget** provider entry
  point; `MenuScreenView` is the stateful view (local bridge/dismiss
  concerns); `_MenuScreenEventBridge` is event-subscription
  infrastructure; **dialog state belongs to `MenuScreenViewModel`**.
- Learner-vs-senior distinction made explicit (LEARNER M03 FORM vs
  SENIOR TARGET FORM); no history rewritten.

### FD-02 — course-only menu scaffolds

`web/src/content/docs/m13/` lessons (the current tip):
- m13/03: stale `menuSessionTicker` comment and `clear()` comment
  removed from snippets; test count corrected to 52; scaffold-retirement
  note added instructing the learner that the sound toggle / tap counter
  / session ticker are removed at this point and why (their teaching
  purposes — setState, GestureDetector callbacks, StreamBuilder — are
  already absorbed; senior replacements land M14/M16).
- Earlier-milestone lessons (m07–m12) that *historically* describe
  building those scaffolds were left as accurate history — the removal
  instruction lives at the current tip (M13), per "no hidden deletion".

### FD-03 — dead demo loader

`web/src/content/docs/m05/01-future-async-await.md`
- Demo-profile values in snippets updated to match the corrected model.
- Explicit note added: `demo_profile_loader.dart` is a teaching-only
  loader, retired/deleted at M10 — learner is told this up front.

`web/src/content/docs/m10/04-*` (menu reset + result flow lesson)
- Added explicit instruction that the M05 demo loader is deleted at this
  milestone (`ProfileStore` supersedes it) — no hidden disappearance.

### FD-04 / BR-01 — invented defaults presented as product defaults

`web/src/content/docs/m04/01-model-va-null-safety.md`
- Senior field set documented: `totalEarnings`, `totalQuestionCount`
  present; `LevelConfig`-derived EXP cap (level-1 = 35000).
- Learner `expForNextLevel` explicitly labelled **temporary** (retires
  M22); defaults now stated as `'0XFF'`/zeros = senior truth; defensive
  parsing + `?avatarUrl` omission recorded as convergence items.

`web/src/content/docs/m04/03-noi-model-vao-menu.md`
- `120 / 400` examples replaced; level-up demo reframed around explicit
  test values / temporary cap — no longer implies tap-to-level-up is
  product behavior; learner scaffold vs senior progression separated.

`web/src/content/docs/m04/04-unit-test-dau-tien.md`
- Test snippets + expectations updated to senior-faithful defaults,
  explicit `expForNextLevel`, new fields, `gainExp` explicit-cap test.

`web/src/content/docs/m04/index.md`
- Completion criteria de-hardcoded; senior-default alignment stated.

### FD-05 — reset semantics

`web/src/content/docs/m10/01-sharedpreferences-va-profile-store.md`
- API wording `load/save/clear` → `load/save/reset`; code example shows
  `reset()` writing the default profile (not deleting the key);
  `loadDemoProfile()` wording corrected.

`web/src/content/docs/m10/04-*`
- Reset section teaches `reset()` = write-default, matching senior
  `resetUserProfile()` semantics; the menu *button* is labelled a
  teaching placement (senior exposes reset via sign-out dialog — M24).

### FD-06 — MenuLoadState as senior architecture implication

`web/src/content/docs/m11/01-vi-sao-setstate-khong-scale.md`
- Explicit note: `MenuLoadState` is a **temporary pre-repository**
  abstraction; senior seeds state from repository streams (no load-state
  surface); enum + `_MenuLoading`/`_MenuErrorState` retire at M14.

### FD-09 — snackbar emit-site nuance (M13/03)

- Lesson now states: the `MenuSnackBarRequested` event *type/pattern* is
  senior-derived, but the learner's reset emission is a teaching use of
  the mechanism — senior's menu VM declares event types while the actual
  snackbar emit sites live in the dialog VMs
  (`MenuAuthDialogSnackBarRequested`, `MenuSignOutDialogSnackBarRequested`).
  Learner emit site converges at M24.

### FD-07 / FD-11 / FD-12 — canonical/roadmap wording

Handled in the Atlas roadmap pass (same remediation run):
- M09 as-shipped annotation (FD-12);
- M19 owns `GameQuizQuestionData` shape (FD-11) + portrait lock (FD-07);
- convergence bullets added to M14/M16/M22/M23/M24/M29.

## Lesson files changed

- `web/src/content/docs/m03/01-stateless-va-stateful.md` (FD-01)
- `web/src/content/docs/m04/01-model-va-null-safety.md` (FD-04/BR-01)
- `web/src/content/docs/m04/03-noi-model-vao-menu.md` (FD-04/BR-01)
- `web/src/content/docs/m04/04-unit-test-dau-tien.md` (FD-04/BR-01)
- `web/src/content/docs/m04/index.md` (FD-04)
- `web/src/content/docs/m05/01-future-async-await.md` (FD-03, FD-04)
- `web/src/content/docs/m10/01-sharedpreferences-va-profile-store.md` (FD-03, FD-05)
- `web/src/content/docs/m10/04-*` (FD-03, FD-05)
- `web/src/content/docs/m11/01-vi-sao-setstate-khong-scale.md` (FD-06)
- `web/src/content/docs/m13/01-*.md`, `m13/02-*.md`, `m13/03-*.md` (FD-02, FD-05, FD-09)

## Out of scope (deliberately not edited)

- M07–M12 historical descriptions of scaffold construction — accurate
  for their milestone; retirement note lives at M13 tip.
- No new lessons, no M14 pages, no restructuring (Forge boundary).
