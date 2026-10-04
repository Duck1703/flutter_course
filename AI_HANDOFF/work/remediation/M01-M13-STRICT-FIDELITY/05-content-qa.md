# 05 — Argus Content Remediation QA

> Role: Argus — independent review of Lumen's content changes.
> Method: fresh re-reads of edited lessons + grep sweeps for stale
> claims. Role independence is simulated (single-executor runtime) via
> stage boundary + on-disk evidence — per D21.

## Verdict: PASS

## Verification per finding site

### FD-01 — `m03/01-stateless-va-stateful.md` ✅

Verified on disk (lines 96–110): senior `MenuScreen` now correctly
described as **StatelessWidget** provider entry; `_MenuScreenEventBridge`
as event-subscription infra; `MenuScreenView` as the stateful view;
dialog state in `MenuScreenViewModel`. LEARNER M03 FORM vs SENIOR TARGET
FORM explicitly distinguished. Senior evidence re-verified:
`lib/screens/menu_screen.dart` — `class MenuScreen extends StatelessWidget`,
`MenuScreenView extends StatefulWidget`, bridge is a widget subscribing
to `vm.events`; `dialogState` lives in `menu_screen_view_model.dart`.
No history rewritten — lesson still shows learner building a
StatefulWidget at M03 (which is what happened).

### FD-02 — scaffold retirement ✅

`m13/03` lines 296–306: explicit "Scaffold đã retire" section naming all
three removed scaffolds + convergence owners (sound → M16 persisted
switch; ticker → M14 repository streams; counter → none in senior) and
reset button kept-but-registered (retires M24). Earlier-milestone
lessons (m03/m05/m06/m11/m12) still describe building the scaffolds —
verified accurate history, no hidden deletion: removal instruction
lives at the current tip (M13/03).

### FD-03 — demo loader ✅

`m05/01` teaches the loader as teaching-only with explicit retirement
note; `m10/04` lines 182–185 instruct deleting the file + its test;
learner source has no `demo_profile_loader.dart` (verified absent on
disk). Historical lessons keep describing the M05-era build — correct.

### FD-04 / BR-01 — defaults ✅

`m04/01`: senior defaults stated (`'0XFF'`, zeros, 35000 cap as
`LevelConfig.getExpRequiredForLevel(1)` hardcode); `expForNextLevel`
labelled temporary → M22; senior extra fields + `MenuLevelProgress`
named with M14/M22 ownership. `m04/04` test snippets match the corrected
model + tests on disk (verified against `test/user_profile_data_test.dart`
— explicit `expForNextLevel: 400` for the level-up scenario).
`m04/03` rewires `'X / 35000 EXP'` and reframes the level-up demo
honestly (explicit small cap). Argus caught-and-fixed residuals in this
review: `m04/01` still showed `// → 'Khách'` output claims (lines 238,
254, 261) and `m04/02` still taught the `gainExp` worked example with
the old 400 cap (`gainExp(300).level // 2`, `c.currentExp // 120`, two
`120*100~/400` arithmetic examples, debugPrint printing `2`) — all
corrected in-place during QA (joint Lumen re-pass) so snippets match the
real file (`(35000 → 52500 → …)` doc comment; explicit-cap examples).

### FD-05 — reset semantics ✅

`m10/01`: API = `load/save/reset`, example writes default profile.
`m10/04` lines 171–179: `_resetProfile` calls `store.reset()` +
`setState(const UserProfileData())`; prose says semantics match senior
`resetUserProfile()`; the only `clear(` left on disk is the historical
contrast sentence at line 304 ("Ban đầu course dùng `clear()`…") —
accurate history, not present-tense instruction.

### FD-06 — MenuLoadState ✅

`m11/01`: temporary pre-repository note present (enum + `_MenuLoading`/
`_MenuErrorState` retire at M14 when stream-seeded repos land). Code
comment in `menu_view_model.dart` matches.

### FD-09 — snackbar emit-site nuance ✅

`m13/03` lines 106–114: explicitly states `MenuSnackBarRequested` type +
channel mechanism are senior-derived, but senior does NOT emit it from
`resetProfile` in the menu VM — real emit sites are the dialog VMs
(`MenuAuthDialogSnackBarRequested`, `MenuSignOutDialogSnackBarRequested`);
learner emit site labelled a teaching choice converging at M24. Verified
against senior: `menu_screen_view_model.dart` declares the event type
via `menu_screen_ui_event.dart`; snackbar events emit from
`menu_auth_dialog_view_model.dart` / `menu_sign_out_dialog_view_model.dart`.

### No-lesson-claims-scaffold-as-senior ✅

Grep sweeps: no present-tense claim that sound toggle / tap counter /
ticker / demo loader exist in senior; no lesson claims `MenuLoadState`
is senior architecture; no `57/57` stale count (m13/03 now says 52/52
with an explanatory note — verified real count on disk).

### Senior-parity phrase audit ✅

All `giống senior`/`y hệt senior`/`senior cũng` claims (21 hits) spot-
verified: each is either modest-and-true (const constructor, hand-written
`==`, `formatThousands` helper, sealed-phase modeling) or explicitly
frames the difference (m10/03 correctly states senior does NOT use
route-results — game VM persists via repository).

## Issues found & fixed during QA

| # | Site | Problem | Fix |
|---|------|---------|-----|
| QA-C1 | `m04/01` L238,254,261 | output comments still printed `'Khách'` | → `'0XFF'` |
| QA-C2 | `m04/02` L156 | gainExp doc `(400→600→900)` ≠ real comment | → `(35000→52500→…)` + TEMPORARY note |
| QA-C3 | `m04/02` L177 | worked example implied 400-cap default | → explicit `expForNextLevel: 400` scenario |
| QA-C4 | `m04/02` L69,221 | stale `120*100~/400` arithmetic | → `350*100~/400=87` |
| QA-C5 | `m04/02` L289,292 | `c.currentExp//120`, `gainExp(300).level//2` wrong under new defaults | → `// 0`; `// 1` + explicit-cap demo |
| QA-C6 | `m04/02` L299 | debugPrint claims output `2` | → explicit-cap call printing `2` |

## Not changed (verified accurate history)

- m02/m03 `'Khách'`/literal menus — M02/M03-era learner code really had
  those literals.
- m05/m06 loader+ticker lessons — creation history, retirement noted.
- m11/m12 ephemeral-state references (`_soundOn`, `_playTapCount`,
  `_sessionTicker`) — accurate for M11/M12-era code; removed at M13 tip.
- m07 `pop(result)` claim — at M07 true; M10 adds the flow later.

## Verdict

**PASS** — all Step-09 content findings corrected; no misleading
present-tense claims remain; learner-vs-senior distinctions explicit;
snippets match on-disk learner code.
