# 09 — Independent Argus Review

**Role:** Argus — independent audit QA.
**Method note (D21):** single-executor runtime; independence is simulated via
fresh re-reads of real source against each finding — every claim below was
re-verified on disk, not trusted from upstream artifacts.

## Re-verification pass (fresh disk reads)

| Finding | Verification performed | Result |
|---|---|---|
| FD-01 (m03/01 false senior claim) | Re-read `lib/screens/menu_screen.dart:13` → `class MenuScreen extends StatelessWidget`; `menu_screen_view.dart:14` → `MenuScreenView extends StatefulWidget` (only `_dialogDismissLocked`); re-read lesson text L91–95 — claim says senior `MenuScreen` "cũng là StatefulWidget với `_MenuScreenState`" | **CONFIRMED — MEDIUM, MISLEADING_TEACHING** |
| FD-02 (4 surviving menu scaffolds, no removal milestone) | Re-grepped roadmap M14–M29 for ticker/tap-counter/sound-toggle/reset-removal — only "reset" appears at M24 as *sign-out* reset, not menu-button removal; `_LeaderboardEntry` re-verified non-tappable (plain `Container`, no GestureDetector) | **CONFIRMED — MEDIUM, roadmap gap** |
| FD-03 (dead `demo_profile_loader` in lib/) | `grep -rn loadDemoProfile learner-app/lib` → only self-references; test file is sole consumer | **CONFIRMED — LOW** |
| FD-04 (model parity) | Re-read senior `user_profile_data.dart` — `totalEarnings` String + `totalQuestionCount` + `'0XFF'`/0 defaults + `_isLegacyDemoProfile` + `_moneyFromDisplay` + `>=0`/nonempty guards + `?avatarUrl` omission all present; learner lacks all | **CONFIRMED — MEDIUM** |
| FD-05 (`clear()` vs write-default) | senior `resetUserProfile()` → `saveUserProfile(const UserProfileData())` (line 78); learner `_prefs.remove(_profileKey)` | **CONFIRMED — LOW** |
| FD-06 (`MenuLoadState` invented surface) | senior `MenuScreenViewModel` re-read — no load-state; `userProfileStream.value` seeds data instantly; `loadUserProfile()` is a repo kick | **CONFIRMED — MEDIUM** |
| FD-07 (portrait lock) | senior `main.dart:24` `SystemChrome.setPreferredOrientations([portraitUp])`; learner `main.dart` has none; roadmap M01 note "all wired later" exists but no owner milestone | **CONFIRMED — LOW (roadmap gap)** |
| FD-09 (snackbar emit site) | `grep MenuSnackBarRequested lib/` → declaration + handler case only; **zero emission sites** in senior; dialog VMs emit `MenuAuthDialogSnackBarRequested`/`MenuSignOutDialogSnackBarRequested` instead | **CONFIRMED — LOW** |
| FD-10 (`unawaited` vs senior bare call) | senior `menu_screen.dart:70` `_navigationController.openGame()` — bare call, Future dropped silently | **CONFIRMED — INFO** (learner stricter; record as SENIOR_SOURCE_CONCERN note) |
| FD-11 (question model shape) | senior `game_quiz_question_data.dart` — `correctOption:String` + 6 extra fields; learner `correctIndex:int`; no milestone explicitly lists model expansion | **CONFIRMED — LOW** |
| FD-12 (M09 scope drift) | roadmap M09 text lists "money amount per question", reveal delay (`Future.delayed` concept), explanation dialog; learner has none; `M07_M09_IMPLEMENTATION_NOTES.md` "Intentional simplifications" records the cut + D18 records 15s timer | **CONFIRMED — MEDIUM** (roadmap text unamended) |

## False-positive challenges (checked, rejected)

| Candidate | Verdict |
|---|---|
| "`_playTapCount`+`gainExp(10)` on CTA = invented game progression" | REJECTED as invented-product-behavior: it was labelled temp in m04/03 and **no longer exists** — `_onPlayTap` now only counts taps + `requestGame()` |
| "`popUntil` in M09 changed navigation semantics permanently" | REJECTED: replaced by `pop(result)` at M10; both were labelled scaffolds |
| "learner menu missing leaderboard/settings/auth = missing senior features" | REJECTED: all explicitly deferred to M16/M23/M24/M29 with named milestones |
| "15s timer is unlabelled" | REJECTED: labelled in code comment + lesson m09/01 verbatim + D18 |
| "`MenuUiEvent` not sealed = architecture divergence" | REJECTED: explicitly deferred to M15 with doc label |
| "M13 Step-08 PASS implies fidelity" | checked independently — PASS confirmed M13's own scope; this audit adds FD-09/FD-02 nuances Step-08 QA didn't need to weigh |

## False-negative sweep (searched for findings upstream missed)

- Rechecked `menu_screen.dart` learner vs senior dialog/menu layer: no
  missed finding — dialog absence is mapped (M29); `PopScope` absence mapped
  (M18/M21/M29 notes).
- Rechecked `pubspec.yaml`: learner deps = provider + shared_preferences —
  consistent with roadmap staging (rxdart M14, etc.). Not a finding.
- Rechecked tests for fidelity problems: widget tests honestly exercise real
  flows (event→push, event→SnackBar verified via `ensureVisible`). None.
- Rechecked `game_screen.dart` back behavior: free back-pop vs senior
  `PopScope(canPop:false)` — covered by M19/M21 mapping; not separately filed.
- Rechecked `_MenuErrorState` reachability: `load()` catch is nearly
  unreachable (store swallows FormatException) — minor dead-path, folds into
  FD-06 note; not separate.

## Audit-process integrity

- Write scope respected: only `AI_HANDOFF/work/audits/**` written; zero
  writes under `learner-app/**`, `web/**`, senior repo.
- All findings carry file-level evidence; no vague findings.
- No finding silently reclassified; no history overwritten.

## Argus verdict

**PASS** — the audit artifacts (00–08) are evidence-backed, findings are
real, classifications are honest, and the audit itself did not touch
course/learner/web/senior content. Caveat: role independence is simulated
(D21) — all verification above was fresh disk inspection.

Signed: Argus.
