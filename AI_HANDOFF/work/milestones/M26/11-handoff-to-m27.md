# M26 → M27 Handoff

## Architecture after M26

`GameScreenViewModel extends DreChangeNotifier<GameState, GameAction,
GameEffect, GameAsyncOp>`: UI dispatches actions → pure `GameReducer`
→ `DreResult{state, effects, asyncOp}` → bridge parts turn
effect-data into Timer/delayed/events and `GameSaveResult` into
`_saveGameResult` (auth+sync from M25 preserved).

## For M27 specifically

- `GameShareResultRequested` action already dispatches → reducer
  emits `GameShareResultEffect` (boundary). M27 implements the
  platform side: `share_plus` service + payload construction +
  `_handleEffect` arm — do NOT re-touch the reducer.
- `package_info_plus` version text lands in settings (FR-28
  residual): `loadSettingsAppVersion` seam → `v$appVersion` row.
- Notifications (FR-27): `LocalNotificationService` +
  `SettingsNotificationCoordinator` — permission AND, schedule/
  cancel on toggle+time, `notificationPermissionRequired` event,
  onboarding real permission. Async work should follow the
  service/coordinator pattern, NOT the DRE op path (settings VM is
  not DRE in senior either).

## State

- Tests: 254/254 · analyze clean · build web PASS · site 145 pages.
- Registers synced (concept D-45/46, A-31..34; FR-04; graph; status).
- Senior: `main@c8eb860`, clean.
- POST_PASS_MUTATION_CHECK: REVERIFIED.

M27_READY: YES
