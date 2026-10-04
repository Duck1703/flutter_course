# 01 — Remediation Brief (Atlas)

Step-09 findings, owned and dispositioned. Remediation executes ONLY these
items — nothing opportunistic, no M14 leakage.

## Senior source anchors (verified during audit, re-verified this pass)

| Fact | Senior evidence |
|---|---|
| Default profile | `lib/data/profile/user_profile_data.dart` — `defaultUsername='0XFF'`, level 1, `currentExp=0`, `totalEarnings='0 VNĐ'`, `totalQuestionCount=0`, money/games 0 |
| Level cap | `lib/data/game/level_config.dart` — `baseExp=30000 + level×5000`; level 1 → **35000** (multiplier ×1 below milestone 5) |
| Reset semantics | `lib/repositories/profile/user_profile_repository.dart:78` — `resetUserProfile() => saveUserProfile(const UserProfileData())` (write-default, NOT key removal); called from `menu_auth_action_coordinator.dart:116` (sign-out flow) |
| Menu shape | `lib/screens/menu_screen.dart` — `MenuScreen` is `StatelessWidget`; `MenuScreenView` stateful for `_dialogDismissLocked`; `_MenuScreenEventBridge` owns event subscription; `dialogState` lives in `MenuScreenViewModel` |
| Leaderboard | `menu_screen_view_model.dart:90` `requestLeaderboardDialog()` → `MenuDialogLeaderboard`; row widget `widgets/menu/leaderboard/leaderboard_entry_card.dart` is tappable (`onTap`) |
| Snackbar events | `MenuSnackBarRequested` declared in `menu_screen_ui_event.dart`, but senior emits snackbars from **dialog VMs** (`MenuAuthDialogSnackBarRequested`, `MenuSignOutDialogSnackBarRequested`), not the menu VM reset path |
| Portrait lock | `lib/main.dart` — `SystemChrome.setPreferredOrientations` at bootstrap |
| `unawaited` | senior drops `openGame()` Future silently (`menu_screen.dart:70`); learner's `unawaited` is stricter — SENIOR_SOURCE_CONCERN (FD-10), document only |

## Finding dispositions

| Finding | Sev | Disposition | Owner | Target |
|---|---|---|---|---|
| FD-01 m03/01 false senior claim | MED | RESOLVED_CONTENT — rewrite claim: `MenuScreen` Stateless, `MenuScreenView`+`_MenuScreenEventBridge` stateful, `dialogState` in VM; keep learner form honest | Lumen | `web/src/content/docs/m03/01-*.md` |
| FD-02 4 course-only menu scaffolds | MED | RESOLVED_CODE_AND_CONTENT — remove sound toggle, tap counter, session ticker NOW (teaching purpose complete, not needed for M14); keep reset button as registered scaffold (aligned semantics); leaderboard stays placeholder, tap activates M23 | Flux + Lumen + Atlas roadmap | `menu_screen.dart`, m03/m06 lessons, roadmap |
| FD-03 dead `demo_profile_loader` | LOW | RESOLVED_CODE_AND_CONTENT — delete file + test; m10/01 must explicitly instruct its retirement | Flux + Lumen | `learner-app`, `m10/01` |
| FD-04 profile model parity | MED | RESOLVED_CODE_AND_CONTENT + roadmap — defaults become senior truth NOW (`'0XFF'`/zeros; `expForNextLevel` = 35000, hardcode of `LevelConfig.getExpRequiredForLevel(1)`, labelled); missing fields (`totalEarnings`, `totalQuestionCount`, parse depth, `?avatarUrl` omission) owned by M14; `expForNextLevel` retires M22 | Flux + Lumen + Atlas | `user_profile_data.dart`, m04/01, roadmap |
| FD-05 reset semantics | LOW | RESOLVED_CODE — `ProfileStore.clear()` → `reset()` writing `save(const UserProfileData())` (senior write-default semantics NOW); VM keeps `resetProfile()` + snackbar event | Flux | `profile_store.dart`, `menu_view_model.dart` |
| FD-06 `MenuLoadState` framing | MED | RESOLVED_CONTENT + roadmap — comment + lesson note mark it temporary; M14 roadmap line says stream-seeded repository retires it | Lumen + Atlas | `menu_view_model.dart`, m11, roadmap M14 |
| FD-07 portrait lock unowned | LOW | RESOLVED_ROADMAP — assign M19 (milestone already rewires `main.dart`/`MaterialApp` for `AppNavigationController`; orientation is bootstrap wiring with game-screen motivation) | Atlas | `MILESTONE_ROADMAP.md` |
| FD-09 snackbar emit-site nuance | LOW | RESOLVED_CONTENT — m13/03 one-liner: event type is senior-derived; learner emit site is teaching choice; senior emits snackbars from dialog VMs at M24 | Lumen | `m13/03` |
| FD-10 `unawaited` stricter than senior | INFO | RESOLVED_CANONICAL_CONTEXT — record SENIOR_SOURCE_CONCERN in register; no code change | Atlas | `SENIOR_FIDELITY_REGISTER.md` |
| FD-11 `GameQuizQuestionData` parity unowned | LOW | RESOLVED_ROADMAP — M19 owns full shape (`id`, `category`, `language`, `difficulty`, `correctOption`, `explanation`) since M19 lands `GameScreenData`/mapper + explanation flow | Atlas | `MILESTONE_ROADMAP.md` |
| FD-12 M09 roadmap scope drift | MED | RESOLVED_ROADMAP — dated annotation on M09: what shipped vs deferred, each deferred item's owner (money ladder→M19, reveal timing→M19, explanation dialog→M19, guaranteed amount→M20) | Atlas | `MILESTONE_ROADMAP.md` |
| BR-01 invented defaults | — | folded into FD-04 — defaults now senior truth | Flux | `user_profile_data.dart` |

## Scaffold disposition detail (FD-02)

| Element | Introduced | Verdict | Removal milestone |
|---|---|---|---|
| Sound toggle `_soundOn`/`_toggleSound` | M03 setState demo | **REMOVE NOW** — purpose complete; senior has no menu sound toggle (real one is settings-dialog switch → M16) | removed this pass |
| Tap counter `_playTapCount` | M03 setState demo | **REMOVE NOW** — course-only, no senior counterpart | removed this pass |
| Session ticker card | M06 StreamBuilder demo | **REMOVE NOW** — `menu_session_ticker.dart` + test deleted; menu gets real streams at M14 | removed this pass |
| Reset button "ĐẶT LẠI HỒ SƠ" | M10 | **KEEP, registered** — semantics aligned to senior (write-default); placement is course-only vehicle that also feeds M13's snackbar-event demo; retires M24 when senior sign-out dialog owns reset | M24 |
| `_LeaderboardEntry` non-tappable | M02 | **KEEP, registered** — senior row IS tappable (`requestLeaderboardDialog`); tap activates at M23 with dialog layer + leaderboard data | M23 |

## Register / governance work (Atlas, after remediation lands)

- `project-context/SENIOR_FIDELITY_REGISTER.md` — every surviving
  simplification: current form, senior form, converges-at, senior evidence.
- `QUALITY-GATES.md` — new **G16 — Senior Fidelity & Convergence**; Argus may
  FAIL a milestone on unregistered deviation.
- `templates/milestone-brief-template.md` — mandatory **SENIOR FIDELITY CHECK**
  section (senior target, current difference, register entries opened/closed,
  forbidden alternatives).
- `CURRENT_STATE.md` / `CONTENT_STATUS.md` / `DECISIONS.md` — reflect
  remediation; record durable decision for the register + gate.

## Done criteria for this task

- All findings dispositioned; no `UNVERIFIED`.
- `flutter analyze` clean; `flutter test` green (count may drop — scaffold
  tests removed); `flutter build web` + `npm run build` green.
- `SENIOR_FIDELITY_REGISTER.md` complete; every ACTIVE_TEMPORARY row has an
  exact `Converges at` milestone.
- Argus re-audit verdict: `STRICT_FIDELITY_PASS`.
