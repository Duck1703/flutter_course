# 03 — Argus Implementation QA (r1)

**Reviewer:** Argus — independent re-verification against disk + senior source
**Input:** `02-flux-code-remediation.md` + learner-app diff

## Verdict: PASS

## Independent verification log

| Claim | Re-verified on disk | Result |
|---|---|---|
| `username='0XFF'` default | `user_profile_data.dart:34` — `this.username = '0XFF'` | ✓ matches senior `defaultUsername='0XFF'` (`data/profile/user_profile_data.dart:2`) |
| `currentExp=0` | `:36` | ✓ matches senior ctor default |
| `expForNextLevel=35000` | `:37` + doc cites `LevelConfig.getExpRequiredForLevel(1)` | ✓ recomputed independently: `getExpRequiredForLevel(1)` = `(30000 + 1×5000) × getMilestoneMultiplier(2)` = `35000 × 1` (target 2 below milestone 5) — the hardcode is senior truth, not invention |
| `reset()` = write-default | `profile_store.dart:72` — `reset() => save(const UserProfileData())` | ✓ identical semantics to `resetUserProfile() => saveUserProfile(const UserProfileData())` (`user_profile_repository.dart:78`) |
| No `clear()` remains | grep `clear()` across `lib/` `test/` → 0 | ✓ |
| Scaffolds removed | grep `_soundOn\|_playTapCount\|_sessionTicker\|_SessionTickerCard` in `menu_screen.dart` → 0 | ✓ |
| Dead files deleted | `demo_profile_loader.dart`, `menu_session_ticker.dart`, both tests — absent | ✓ |
| `MenuLoadState` temp label | `menu_view_model.dart` doc — names senior stream-seeded repo + M14 retirement | ✓ |
| `resetProfile` uses `_store.reset()` | `menu_view_model.dart:110` | ✓ |
| `_ResetButton`/`_LeaderboardEntry` labelled | `menu_screen.dart` comments — reset retires M24 (sign-out), leaderboard tap activates M23 (`requestLeaderboardDialog`) | ✓ |
| No M14 leakage | no `abstract`/`interface` repo, no `rxdart`/`BehaviorSubject`/`ValueStream` imports, no sealed classes, `GameScreen` untouched | ✓ grep confirms |
| Tests updated truthfully | `user_profile_data_test` asserts senior defaults; small-cap tests pass `expForNextLevel: 400` explicitly (test fixture, not product default); store/VM reset tests assert key PERSISTS | ✓ |

## Checks for false negatives (things Flux might have missed)

- `menu_screen.dart` no longer contains `'Số lần bấm'`, `'Âm thanh'`, `'Thời gian phiên'` — verified.
- `_IconBadge` removed with its only use — no dead private widget remains — verified.
- `_MenuScreenViewState` still legitimately `StatefulWidget` (event bridge needs `didChangeDependencies`/`dispose`) — not dead statefulness.
- `test/menu_provider_scope_test.dart` still passes a seed profile `'Minh'`/`7` — unaffected by defaults change. ✓
- `main.dart` unaffected; `AppDependencyScope` unchanged. ✓

## Regression

`flutter analyze` clean · `flutter test` 52/52 · `flutter build web` PASS
(count drop 57→52 = exactly the 5 scaffold tests deleted; expected per brief).

## Blocking findings

NONE.

**STATE: IMPLEMENTATION_REMEDIATION_APPROVED — hand to Atlas/Lumen.**
