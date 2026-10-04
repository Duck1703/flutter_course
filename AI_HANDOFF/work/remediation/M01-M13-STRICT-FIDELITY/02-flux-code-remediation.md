# 02 — Flux Code Remediation Evidence

**Role:** Flux (learner-code corrections only, every edit tied to a finding ID)
**Date:** post-Step-09 remediation pass

## Changes made

### FD-04 + BR-01 — senior defaults in `UserProfileData`

`learner-app/lib/data/profile/user_profile_data.dart`
- `username`: `'Khách'` → `'0XFF'` (= `UserProfileData.defaultUsername`,
  senior `lib/data/profile/user_profile_data.dart:2`)
- `currentExp`: `120` → `0` (senior ctor default)
- `expForNextLevel`: `400` → `35000` — NOT invented: equals
  `LevelConfig.getExpRequiredForLevel(1)` = `30000 + 1×5000`, multiplier ×1
  (senior `lib/data/game/level_config.dart:2-3,25-29`). Field stays as a
  registered TEMPORARY scaffold; M22 replaces it with `LevelConfig`
  derivation and drops the field.
- Class doc + `gainExp` doc updated: registered simplification, M14 adds
  `totalEarnings`/`totalQuestionCount`, M22 drops `expForNextLevel`.

### FD-05 — reset semantics aligned to senior

`learner-app/lib/data/profile/profile_store.dart`
- `clear()` (prefs key removal) → `reset()` = `save(const UserProfileData())`.
  Matches `UserProfileRepositoryImpl.resetUserProfile() =>
  saveUserProfile(const UserProfileData())`
  (`lib/repositories/profile/user_profile_repository.dart:78`).

`learner-app/lib/view_models/menu/menu_view_model.dart`
- `resetProfile()` now calls `_store.reset()`; comment documents senior
  call site (`menu_auth_action_coordinator.dart:116` — sign-out flow) and
  that the menu button retires at M24.

### FD-06 — `MenuLoadState` marked temporary

- `MenuLoadState` doc now states senior menu has no load state
  (stream-seeded `BehaviorSubject` repository) and the enum retires at M14.

### FD-02 — course-only scaffolds removed

`learner-app/lib/screens/menu_screen.dart`
- Removed `_soundOn`/`_toggleSound`/`_ProfileHeader.soundOn,onSoundTap`/
  `_IconBadge` (now-unused) — senior sound control lives in the settings
  dialog (M16).
- Removed `_playTapCount`/`_PlayButton.tapCount`/"Số lần bấm" text —
  no senior counterpart.
- Removed `_sessionTicker`/`_SessionTickerCard`/`ticker` param —
  menu's real streams arrive at M14.
- `_ResetButton` kept as registered scaffold (semantics now senior-aligned);
  comment says placement is course-only and retires M24.
- `_LeaderboardEntry` kept non-tappable; comment names senior
  `LeaderboardEntryCard.onTap → requestLeaderboardDialog()` and activation
  milestone M23.

### FD-03 — dead teaching scaffold deleted

- `lib/data/profile/demo_profile_loader.dart` — deleted (dead since M10).
- `lib/data/menu_session_ticker.dart` — deleted (ticker card removed).
- `test/demo_profile_loader_test.dart`, `test/menu_session_ticker_test.dart`
  — deleted (tests of removed scaffolds).

### Test updates (consequence of above, no behavior invented)

- `test/user_profile_data_test.dart`: default assertions now senior truth
  (`'0XFF'`/0/35000); `gainExp`/`expPercent` tests pass explicit
  `expForNextLevel: 400` where a small cap is needed for level-up demos.
- `test/profile_store_test.dart`: `clear()` test → `reset()` test asserting
  key PERSISTS with default contents (senior write-default).
- `test/menu_view_model_test.dart`: reset test now asserts disk holds
  default JSON (not `isNull`); title renamed `ghi` not `xoá`.
- `test/menu_ui_events_test.dart`: stale `pumpAndSettle`-warning comment
  rewritten (ticker gone); `clear()` → `reset()` comment.

## Not done (per boundaries)

- No repository interface, no rxdart/BehaviorSubject, no sealed classes,
  no GameViewModel, no M14+ scope.
- `MenuLoadState`/`load()`/`_MenuLoading`/`_MenuErrorState` kept — they are
  registered TEMPORARY architecture with M14 convergence, not deleted early.
- `gainExp` ×1.5 curve, flat `moneyPerCorrectAnswer=50000`,
  `expPerCorrectAnswer=50`, `GamePhase` tri-state, 15s timer, `pop(result)`
  — all remain as previously registered simplifications with roadmap owners.

## Verification

| Check | Result |
|---|---|
| `flutter analyze` | No issues found |
| `flutter test` | 52/52 PASS (57 − 5 scaffold tests removed) |
| `flutter build web` | PASS |

## Residual risk

- `test/menu_ui_events_test.dart` reset test still taps "ĐẶT LẠI HỒ SƠ"
  (kept scaffold) — will need updating at M24 when button retires; the
  register tracks this.
