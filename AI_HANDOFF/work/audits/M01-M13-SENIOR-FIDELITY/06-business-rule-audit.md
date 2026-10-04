# 06 — Business Rule Audit (Atlas + Flux)

Every rule introduced by course code, classified:
`SENIOR-DERIVED` · `TEACHING-ONLY TEMPORARY` · `INVENTED/UNJUSTIFIED`.

| # | Rule (learner) | Senior truth | Classification | Note |
|---|---|---|---|---|
| BR-01 | Default profile: `username='Khách'`, level 1, `currentExp=120`, `expForNextLevel=400`, zeros elsewhere | `username='0XFF'`, level 1, `currentExp=0`, `totalEarnings='0 VNĐ'` (stored), `totalQuestionCount=0`, zeros | **INVENTED** (fixture values) | labelled "hồ sơ khách y hệt các con số menu" — honest as fixture, but the fixture IS the persisted default → fresh installs show fake 120 EXP. Senior shows real zeros. FD-04 |
| BR-02 | `gainExp`: cap growth ×1.5/level, stored `expForNextLevel` | `LevelConfig`: `baseExp 30000 + level×5000`, milestone multipliers (5,10,15:1.5; 20:3; 30:2; 40,60:3; 50,70,80:2; 90:4; 100:5); cap derived, max level 100 | TEACHING-ONLY TEMPORARY | labelled + M22. Curve shape differs (×1.5 constant vs stepped multipliers) — no max level in learner |
| BR-03 | `applyGameResult`: money = `correctAnswers × 50000`; EXP = `correctAnswers × 50`; +1 joined; +won won | `_saveGameResult`: `earnedAmount` from 15-level money ladder; **EXP = earnedAmount**; joined+1; won+isWin; `totalQuestionCount += questionCount`; `totalEarnings` = formatVnd | TEACHING-ONLY TEMPORARY | labelled verbatim in code + m10/04 (flat ladder → M20/M22). Note: learner EXP basis is *count×50*, senior's is *money* — different rule, explicitly disclosed |
| BR-04 | `GameResult{questionsAnswered, correctAnswers, won}` via `pop(result)` → menu VM applies + saves | no route result; game VM saves directly to `UserProfileRepository`; menu observes `userProfileStream` | TEACHING-ONLY TEMPORARY | explicitly declared in lesson + file doc; converges M19 (nav controller) + M22 (VM-side save + stream propagation) |
| BR-05 | Countdown 15s/question | `timePerQuestion = 30s` | TEACHING-ONLY TEMPORARY | labelled in code + lesson + D18 + impl notes; M19 |
| BR-06 | `GamePhase{answering,revealing,finished}` | `GamePhase{notStarted,playing,answeredPending,answeredRevealed,gameOver,victory}` | TEACHING-ONLY TEMPORARY | labelled; converges M15 (sealed) + M19 (full machine) |
| BR-07 | `GameEndReason{wrongAnswer,timeout,victory}` → single `AlertDialog` with 3 titles | no such enum; sealed `GameDialogState` → 8 dialog variants incl. `GameEndedDialog(earnedAmount)`, `GameVictoryDialog(earnedAmount, affirmationMessage)` | TEACHING-ONLY TEMPORARY | labelled; M15 sealed + M21 layer. **Nuance:** senior dialog shows *earned money*; learner shows "Đúng X/Y câu" — covered by M19 ladder |
| BR-08 | Victory = last question correct; wrong/timeout = game over | same rule | SENIOR-DERIVED | identical semantics |
| BR-09 | `questionsAnswered` excludes the in-flight question on timeout | senior `questionCount` passed to save = questions processed | SENIOR-DERIVED (approximation) | learner's "answered" ≈ senior's count; edge semantics unverified in detail → acceptable at this stage |
| BR-10 | `ProfileStore` key `'user_profile'`, `jsonEncode(toMap())`, `StateError` on failed save | identical key/format/throw (verified lines 22-71) | SENIOR-DERIVED | exact match |
| BR-11 | `clear()` = `prefs.remove('user_profile')` | `resetUserProfile()` = `saveUserProfile(const UserProfileData())` — writes default, key persists | TEACHING-ONLY TEMPORARY | same observable result (defaults next load), different storage semantics; converge M14 — FD-05 LOW |
| BR-12 | `toMap` writes `'avatarUrl': null` explicitly | `toMap` uses `'avatarUrl': ?avatarUrl` — key omitted when null | TEACHING-ONLY TEMPORARY | forward/backward compatible either way; cosmetic schema diff — FD-04 LOW part |
| BR-13 | Defensive `fromMap`: `is int`/`is String` only | senior adds `>= 0` for ints, nonempty-trim for strings, `_moneyFromDisplay` recovery, `_isLegacyDemoProfile` purge | TEACHING-ONLY TEMPORARY | pattern identical, depth reduced; converge M14 — FD-04 |
| BR-14 | `winRateDisplay` = `'—'` when 0 games else `won*100/joined %` | `formatWinRate(data)` same concept in `stats_card.dart` | SENIOR-DERIVED | matches |
| BR-15 | `formatThousands` dot-grouping | identical algorithm | SENIOR-DERIVED | exact match |
| BR-16 | `expPercent` = `currentExp*100~/expForNextLevel` clamped 1–99 | `MenuLevelProgress.fromProfile` → `LevelConfig.getExpRequiredForLevel`; ring + tier semantics | TEACHING-ONLY TEMPORARY | converges M22 |
| BR-17 | Menu shows sound toggle, tap counter, session ticker, reset button | senior menu shows: profile header (account+settings taps), level card, earnings, leaderboard entry (tappable→dialog), stats, CTA — **none of the four** | TEACHING-ONLY TEMPORARY (labelled) | removal not explicitly scheduled → FD-02 MEDIUM |
| BR-18 | `MenuLoadState{loading,ready,failed}` + retry UI | senior menu has **no load state** — repo is `BehaviorSubject.seeded`, `loadUserProfile()` is a silent kick | TEACHING-ONLY TEMPORARY | teaches FutureBuilder-replacement concept; converges M14 — FD-06 MEDIUM |
| BR-19 | `resetProfile()` emits `MenuSnackBarRequested('Đã đặt lại hồ sơ.')` | senior `MenuScreenViewModel` never emits `MenuSnackBarRequested` (type exists; unused at menu level — dialog VMs emit own snackbar types) | TEACHING-ONLY TEMPORARY | coherent scaffolding; lesson omits the senior emit-site nuance → FD-09 LOW |
| BR-20 | `requestGame()` → `MenuGameRequested` → bridge → `unawaited(_openGame())` → `push<GameResult>` | `requestGame()` → `MenuGameRequested` → `_navigationController.openGame()` (bare Future, no `unawaited`) | SENIOR-DERIVED mechanism; transport differs | nav controller → M19; `unawaited` is *stricter* than senior → FD-10 INFO |
| BR-21 | `_attachViewModel` `==` guard, cancel-old, dispose-cancel | identical in `_MenuScreenEventBridgeState._attachMenuViewModel` | SENIOR-DERIVED | line-for-line parity |
| BR-22 | `changeOrientation` — none | `SystemChrome.setPreferredOrientations([portraitUp])` | MISSING_SENIOR_BEHAVIOR | roadmap acknowledges "wired later" but no owner → FD-07 LOW |
| BR-23 | Leaderboard row static (not tappable) | `LeaderboardEntryCard(onTap → requestLeaderboardDialog)` | TEACHING-ONLY TEMPORARY | senior dialog arrives M23; tap wiring implied by M23 scope |
| BR-24 | Quiz questions = 4 const review questions | `gameSampleQuestions` bank w/ difficulty/explanation/category/language | TEACHING-ONLY TEMPORARY | labelled; full shape implicit M19/M20 → FD-11 |
| BR-25 | No money display during game | senior shows ladder amount + countdown ring | TEACHING-ONLY TEMPORARY | in M09 roadmap scope but unshipped — recorded in impl notes → FD-12 |

**Unclassified rules: NONE.** Every learner-side business rule traced.

Summary: SENIOR-DERIVED 8 (BR-08,09,10,14,15,20-mech,21 + 25-not-a-rule…
count: 08,10,14,15,21 = 5 exact + BR-09/BR-20 partial) ·
TEACHING-ONLY TEMPORARY 17 · INVENTED 1 (BR-01 fixture defaults — labelled
as fixture but surviving as persisted product behavior → MEDIUM via FD-04).
