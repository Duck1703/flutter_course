# Prerequisite Graph — M01–M16 (canonical learning dependencies)

Maps the ACTUAL course (not a generic Flutter graph). A lesson may not use a
concept before its teaching node. Maintained by Atlas at each milestone brief;
the Pedagogy Reviewer verifies edges at QA (gate G18). Status column lives in
`LEARNER_CONCEPT_REGISTRY.md`.

## Foundation chain

```
flutter tooling (M01)
Widget → Widget tree / Element tree / render tree → BuildContext (M01)
  → StatelessWidget → composition → MaterialApp/Scaffold (M01–M02)
  → layout: constraints → Row/Column/Expanded/SizedBox/Padding → ListView (M02)
  → StatefulWidget → createState → State<T> fields → setState
    → rebuild semantics → initState/dispose → mounted → state ownership
    → data-down/events-up (M03)
model-first: class/final/const/named/required → null-safety (? ! ??) →
  copyWith → ==/hashCode → enum → immutable model → JSON toMap/fromMap
  (factory ctor) (M04, M08, M10)
test: test()/expect/group (M04) → testWidgets/pumpWidget/pump/tap/finders (M08)
  → virtual time pump(Duration) (M09) → setMockInitialValues (M10)
  → pure-Dart VM test (M11) → scope-wrapped widget test (M12) → fakes (M14)
```

## Async chain

```
Future<T>≠T → async/await (suspension, single isolate) → Future.delayed →
  error completion → mounted guard → stable-Future-in-initState →
  FutureBuilder → Future<void> main() + ensureInitialized (M05)
→ Stream<T> = events over time → Stream.periodic/take/first →
  StreamSubscription/listen/cancel → StreamController → broadcast →
  StreamBuilder → stable-stream identity → dispose ownership (M06)
→ event stream: StreamController.broadcast, no replay, .first in tests (M13)
→ BehaviorSubject.seeded → .value → ValueStream → replay/current-value →
  isClosed → close/dispose (M14)
```

## Navigation chain

```
route stack → Navigator.of(context) upward lookup → MaterialPageRoute<T> →
  push → pop → route-result Future<T?> → showDialog-as-route →
  AlertDialog/barrierDismissible → popUntil (M07, M09, M10)
→ GlobalKey<NavigatorState>/nav-controller concept (M07/03 checkpoint;
  real controller M19)
(named routes: NOT in course — senior app has none)
```

## State-architecture chain

```
setState (M03) → why-it-fails (M11/01) → ChangeNotifier/notifyListeners →
  ListenableBuilder → VM ownership/dispose (M11)
→ constructor-threading problem → InheritedWidget lookup → Provider.value →
  read vs watch → ChangeNotifierProvider create:/auto-dispose →
  app vs screen scope (M12)
→ state≠event → MenuUiEvent → broadcast channel → bridge subscribe
  (didChangeDependencies + guard + cancel) → unawaited (M13)
→ storage primitive vs repository → abstract interface class → implements →
  contract-first → BehaviorSubject state stream → DI by contract →
  MultiProvider → async bootstrap → VM-on-stream (ctor .value + listen) →
  fake repos (M14)
→ sealed class (closed family) → exhaustive switch + object patterns →
  sealed UI events (MenuScreenUiEvent) → sealed dialog state
  (GameDialogState) → render-by-state (M15)
```

## Persistence/architecture chain

```
SharedPreferences plugin → getString/setString → JSON round-trip →
  ProfileStore concrete (M10) → replaced by contract+impl repos (M14)
```

## Edge rules

- A "Bạn đã biết gì" line may only cite concepts whose teaching node is
  earlier in this graph.
- Concepts listed in a lesson's "cố ý chưa làm" are NOT taught — they may not
  appear in a later lesson's prerequisite list.
- First code use of a concept must be ≥ its teaching node, or the lesson must
  carry the teaching itself (first-appearance rule).

## Known historical edge repairs (Step-13)

- `factory` ctor: code first at M10/02; teaching node now = M10/02 new
  section (was falsely claimed earlier — edge repaired).
- `pumpEventQueue`: teaching node = M14/06 (first use site owns the gloss).
- `async*`/`yield`: never taught (M06 defers; M13 claim removed). Not used
  by learner code through M14. First real teaching node will be the first
  milestone that needs it.

## M16 — persisted settings UI

`UserSettingsRepository`+`UserSettingsData` (M14) → sealed
`SettingItemData`+`SettingType`+`buildSettingItems` (M16/02; needs
D-26/D-27 from M15) → `SettingsViewModel` dialog-scoped + sealed
`SettingsUiEvent` (M16/03; needs F-18 provider-create, A-05 event
bridge, A-08 `.value` seed) → dialog UI: `Switch` controlled +
opaque row-tap + chips + account row (M16/04; needs F-13 showDialog,
F-09 gesture) → `ListWheelScrollView`+controller ownership (M16/05;
needs F-06 lifecycle) → persisted-settings feature complete.

New edges: settings-repo(M14) → M16/02 → M16/03 → M16/04 → M16/05.
Feeds M17 (`languageCode` → `MaterialApp.locale`), M21 (dialog layer
replaces `showDialog`/FR-16+FR-29), M27 (notification permission +
scheduling / FR-27).

## M17 — localization (en/vi)

`languageCode` persisted (M14/M16) → ARB resources + gen-l10n
pipeline (M17/02; D-31 mới) → `MaterialApp.locale` lái bởi
`StreamBuilder` trên `userSettingsStream` + FR-26 whitelist trong
`fromMap` (M17/03; F-25 + A-16 mới; needs A-08 `.value` seed,
F-11 StreamBuilder) → migration `AppLocalizations.of(context)` +
`localizedSettingItems` (M17/04; A-16 "UI sở hữu chữ") →
locale-switch widget test + FR-26 unit tests (M17/05; senior parity).

New edges: settings-repo(M14) + language-chips(M16) → M17/02 →
M17/03 → M17/04 → M17/05. Feeds M18 (onboarding strings theo
FR-31), M22+ (auth surface keys), M27 (notification strings hoàn
thiện khi permission/schedule đến).

## M18 — onboarding overlay (first run)

Repo flag `OnboardingRepository` (M14; consumer đầu tiên) → mental
model overlay-không-route (M18/01; F-26 mới) → sealed
`OnboardingStepState` + 16 key ARB onboarding + content data
(M18/02; needs M15 sealed, D-31 ARB) → `OnboardingViewModel`
queue-of-steps + `listEquals`/`List.unmodifiable` + stream sub +
guarded async (M18/03; D-32 + A-17 mới; needs A-08 `.value`,
A-10 stream sub, D-30 `late`) → scope FutureBuilder gate + menu
`Stack`/`Positioned.fill` + `LanguageChipRow` promote (M18/04; needs
F-11 FutureBuilder, F-18 provider-create, F-26) → widget test +
regression (M18/05; needs A-11 fake repos, F-25 l10n host).

New edges: onboarding-repo(M14) + settings-repo(M14) + l10n(M17) →
M18/02 → M18/03 → M18/04 → M18/05. Feeds M19 (game VM depth),
M21 (dialog layer cùng model overlay), M27 (permission thật
thay simulated grant / FR-27), M28 (visual parity FR-32).

## M19 — structured game architecture / GameViewModel convergence

Mental model máy trạng thái (M19/01; needs A-14 render-by-state,
D-27 sealed) → nền data: `GamePhase`×6 + `GameDialogState` sealed +
`GameSessionState` + `copyWith clear*` + question model + bank 15
câu + thang tiền + `GameResult.earnedAmount` + ARB senior keys +
xé màn cũ (M19/02; D-34 mới; needs D-31 ARB, M10 GameResult) →
presentation mapper `buildGameScreenPresentation` → `GameScreenData`
(M19/03; A-20 mới; needs M19/02 state) → `GameScreenViewModel`:
dispatch guards + `Timer.periodic` + `flowToken` + explanation flow
(M19/04; D-33 + A-18 mới; needs A-08 `.value`, M13/M15 uiEvents,
M19/03 mapper) → screen migration: `ChangeNotifierProvider` +
event bridge + `PopScope` + `AppNavigationController` +
`navigatorKey` + portrait lock (M19/05; F-27 + A-19 mới; needs
F-18 provider, F-22 GlobalKey awareness, M11 scope) → tests +
regression (M19/06; needs A-11 fakes, `fakeAsync`).

New edges: M15 sealed + M10 result + M11–M15 VM/event → M19/02 →
M19/03 → M19/04 → M19/05 → M19/06. Feeds M20 (lifelines vào cùng
state machine + `featureButtons`), M21 (dialog layer trong Stack),
M22 (VM-side save retire pop-result), M26 (DRE reducer).

## M20 — lifelines & feature buttons

Mental model lifeline-là-luat + `Set` dùng-một-lần (M20/01; D-35
mới; needs D-34 copyWith/clear*, A-18 phase guard) → nền data:
3 dialog variant + `GameAudiencePollItemData` +
`GameFeatureButtonType`/`GameFeatureButtonData` +
`audiencePercentile` + 4 field state + helper thuần + ARB
(M20/02; D-36 mới; needs D-31 ARB, M19/02 state/data, M15 sealed)
→ 50:50 + poll: mapper `featureButtons`/`visibleOptionTexts` +
VM `handleFeatureClick`/`_canUseFeature` + bar widget + ô trống
+ poll dialog (M20/03; F-28 mới; needs A-20 mapper, D-35, M20/02)
→ AI mô phỏng + walk-away: `_schedule` 700ms + dialog guard +
`ListenableBuilder` host live + `resolvedResult` (M20/04; needs
D-33 `flowToken`/timer, F-16 `ListenableBuilder`, M20/03) →
tests + regression + PRODUCE lifeline-6 (M20/05; needs A-11,
`fakeAsync`).

New edges: M19 state machine + D-35/D-36/F-28 → M20/02 →
M20/03 → M20/04 → M20/05. Feeds M21 (cùng `dialogState` nguồn —
đổi cơ chế hiển thị), M22 (`resolvedResult` → VM-side save,
`GameSaveResult`), M26 (lifeline flow → reducer), M28
(`GameFeatureButton` painter/SVG — FR-34).

## M21 — in-Stack dialog layer & back handling

Mental model "dialog = state, không phải route" + bảng parity 9
variant (M21/01; **A-21 mới**; needs F-26 overlay gating, A-14
render-by-state, M15 sealed) → layer skeleton + backdrop: 9 view
port từ `_GameDialogHost`, `ClipRect`/`BackdropFilter`/
`IgnorePointer`/opaque (M21/02; **F-30 mới**; needs M19/02
`dialogState`, F-23 opaque) → `AnimatedSwitcher` +
`ValueKey(runtimeType)` + fade/slide + `disableAnimations`
(M21/03; **D-37 + F-29 mới**; needs D-33 Duration, F-28
AnimatedOpacity) → mount layer trong `Stack` + `PopScope` +
`_handleRouteBack` + `_afterExit`; retire
`GameDialogRequested` + `_GameDialogHost`/`_GameDialogAction`/
route scaffold (M21/04; needs F-27 PopScope, A-19 nav controller,
M20/04 host để xóa) → 4 test parity + regression + PRODUCE variant
(M21/05; needs A-11 fakes).

New edges: F-26/F-27 + M19 `dialogState` + D-37/F-29/F-30 →
M21/02 → M21/03 → M21/04 → M21/05. Feeds M22 (terminal actions →
VM-side `GameSaveResult` thay `goBack(result)`), M26 (reducer
emit cùng `dialogState`), M28 (`GameDialogShell` chrome FR-32/
FR-34), M29 (menu dialog layer cùng model).

## M22 — VM-side result save & LevelConfig progression

Mental model "kết quả = ghi-DB trong VM, không phải route-pop" +
`hasSavedResult` idempotence (M22/01; **A-22 mới**; needs A-18 state
machine, A-08 ValueStream truth, D-17 unawaited) → `LevelConfig`
bảng milestone-multiplier + `while` lên cấp (M22/02; **D-38 mới**;
needs D-15 map literal, D-07 loop) → `MenuLevelProgress` derived
view-model + `_LevelCard` rewire (M22/03; **D-39 mới**; needs D-16
factory, D-38) → atomic cut: repo ctor injection +
`_emitWithSaveResult`/`_saveGameResult`/`_applyLevelProgression`
port + retire `GameResult`/`resolvedResult`/`applyGameResult`/
`expForNextLevel`/`expPercent`/`gainExp` (M22/04; needs A-22, A-07
DI, A-11 fake repo, D-34 copyWith) → regression + parity + M23
boundary (M22/05; needs A-11 fakes).

New edges: A-18 + A-08 + D-17 → M22/01 → M22/02 → M22/03 → M22/04
→ M22/05. Feeds M23 (remote reads vẫn share pattern repo-stream),
M24 (`AuthRepository` vào cùng ctor), M25 (`_syncSavedGameResult`
stub → thật), M26 (`_emitWithSaveResult` → `_withSaveResult` op
trong reducer), M28 (`MenuLevelProgress.tier`/`formatted*` lái
`LevelProgressCard`).

## M23 — Supabase bootstrap & first remote read (leaderboard)

`String.fromEnvironment`/`--dart-define` + ranh giới anon-key/RLS +
view-vs-table (M23/01; **D-40 + B-01 + B-02 mới**; needs D-01 const,
D-15 map) → `SupabaseClientService.initialize` `SupabaseClient?`
sentinel + conditional DI `client == null ? Disabled… : Supabase…`
trong `main()` + scope `Provider<LeaderboardRepository>.value`
(M23/02; **F-31 + A-23 + A-24 mới**; needs A-07 DI, F-21
MultiProvider, A-12 bootstrap) → repo deep-dive: contract
`loadLeaderboard({currentUserId})` → `LeaderboardSnapshot`, chuỗi
query `from().select().order().order().limit(10)` +
`.eq('auth_uuid',uid).maybeSingle()`, `_LeaderboardRecord` defensive
mapping, `DisabledLeaderboardRepository`, fake completers (M23/03;
**D-41 mới**; needs D-15 JSON map, A-11 fakes, B-02 view) →
`LeaderboardDialogViewModel`: 4 `LeaderboardPopup*` states,
`isRefresh` keeps-entries, `retry()`, `_requestId` stale guard,
profile-backed current entry, guest seam `→null` (M23/04; **D-42
mới**; needs D-09 async, D-24 pumpEventQueue, A-08
`userProfileStream.value`, D-26/27 sealed+switch) → dialog + menu
row: `MenuLeaderboardRequested` event → `showLeaderboardDialog` →
`MenuLeaderboardDialogScope` + `_LeaderboardDialogBridge` post-frame
load → `LeaderboardPopupBody`/`List`/`Row` +
`RefreshIndicator.adaptive` + `AlwaysScrollableScrollPhysics` + 6
key ARB (M23/05; **F-32 mới**; needs A-15 dialog-scoped VM, A-05
event bridge, F-13 showDialog, F-18 ChangeNotifierProvider, F-25
l10n, D-17 unawaited).

New edges: D-40/B-01/B-02 → M23/01 → A-23/A-24/F-31 → M23/02 →
D-41 → M23/03 → D-42 → M23/04 → F-32 → M23/05. Feeds M24
(`AuthRepository` vào ctor VM + scope dialog, `_currentLeaderboardUserId`
switch(authState), cặp `DisabledAuthRepository`/`SupabaseAuthRepository`
cùng nhánh `?:` trong main), M25 (ghi `public.users` qua cùng
`SupabaseClient`), M26 (DRE cancel thay `_requestId`), M28 (SVG
rank/avatar assets, `LeaderboardRowStyle`, `LeaderboardEntryCard`),
M29 (`MenuDialogLayer` + `MenuDialogLeaderboard` thay transport
event+showDialog).

## M24 — Authentication (identity layer)

Sealed session model + result type + contract + guest-mode
`DisabledAuthRepository` + auth≠authorization≠profile (M24/01;
**D-43 + D-44 + A-25 + B-06 mới**; needs D-26/27 sealed+switch,
A-08 BehaviorSubject, D-19 interface, B-01/02 RLS boundary) →
provider services + `AuthRepositoryImpl` trên Supabase:
`google_sign_in` v7 init-once + `authenticate`, `signInWithIdToken`
hai-chặng, `currentUser` seed + `onAuthStateChange`→Guest-on-error,
`_sessionFromUser` metadata, email `signInWithPassword`/`signUp`
confirm-email, `signOut` hai-lớp; APPENDIX Apple + sha256 nonce +
`_sessionProfileOverride`; `main()` auth ternary + scope
`+AuthRepository` (M24/02; **B-03 + B-04 + B-05 + B-07 mới**;
needs F-31 client, D-40 GOOGLE_* defines, A-24 conditional DI,
A-25 stream) → sync seam + coordinator: `ProfileSyncStateData`,
`UserProfileSyncRepository` + `UserProfileSyncRepositoryDisabled`
no-op, `MenuAuthActionCoordinator` `_signInAndSync` guard +
sign-up branch + `signOut→resetUserProfile` (FR-11), scope
`+UserProfileSyncRepository`, `main()` always-Disabled divergence
(M24/03; **A-26 mới**; needs D-43 model, D-44 result, A-25 stream,
A-11 fakes) → dialog VMs + menu auth: `MenuAuthDialogViewModel`/
`MenuSignOutDialogViewModel` + sealed `…UiEvent` (FR-12 snackbar
ownership), `_isLoading`/`_isDisposed` guards, `MenuViewModel`
+AuthRepository seed/sub/`isAuthenticated`, FR-35 leaderboard
`switch(authState)`→uid (M24/04; **reinforcement** — needs A-15
dialog-scoped VM, A-05 event bridge, D-11 broadcast, A-26
coordinator, D-27 object pattern `(:final uid)`) → UI surface:
`requestAuthAction` session routing, `MenuAuthRequested`/
`MenuSignOutRequested` events (emit site `MenuSnackBarRequested`
retire — class kept senior-true), pill
`_ProfileHeader` accent/guest-masking, `showMenuAuthDialog`/
`showMenuSignOutDialog` + scopes + bridges + `PopScope` +
`MenuLoadingOverlay`, auth dialog 2-page + senior validation +
`showApple` iOS gate, ARB +24 −`resetProfileButton`, retire
`_ResetButton`/`resetProfile()` (M24/05; needs F-13 showDialog,
F-18 provider, F-25 l10n, F-27 PopScope, A-05 events, A-15 scope).

New edges: D-43/D-44/A-25/B-06 → M24/01 → B-03/B-04/B-05(+B-07) →
M24/02 → A-26 → M24/03 → M24/04 → M24/05. Feeds M25
(`UserProfileSyncRepositoryImpl` merge+upsert `public.users` —
`main()` đổi một dòng Disabled→Impl; `syncStateStream` consumer),
M26 (DRE/`asyncOp` thay `_isLoading`+`_isDisposed` tay), M28
(`SettingsDialogShell`/`OnboardingGameButton`/`MenuDialogBackdrop`
chrome thay AlertDialog+MenuTokens; icon-asset pipeline FR-30),
M29 (`MenuDialogAuth`/`MenuDialogSignOut` state + `MenuDialogLayer`
in-Stack thay event+`showDialog` — FR-29).

## M25 — Remote Profile Sync

Boundary DTO `AppUserData` ở biên local↔remote (8 field theo cột
`public.users`; `fromMap`/`fromProfile`/`toUpsertMap`/`toProfile` +
parse phòng thủ; ba-thứ-vắng `email`/`gamesWon`/`totalEarnings`) +
schema `public.users` (11 cột, `auth_uuid` unique FK → `auth.users`,
CHECK ≥0/level 1–100, RLS own-row) + `02-verify-database.sql`
byte-identical + `user_profile_sync_schema_test` ×2 (M25/01;
**A-27 + B-08 mới**; needs D-41 map-parsing + `maybeSingle`, D-15
JSON map, D-16 factory, B-02 view-vs-table, B-01 RLS, D-38
LevelConfig range, B-06 identity↔profile) → `mergeUserProfileForSync`
pure + 5 helper: identity session-wins (fallback ba-tầng, avatar
bất-đối-xứng), leader progression `level→currentExp`-tiebreak
nguyên khối, totals `_maxInt`, `gamesWon` local-only,
`_withoutDemoProgression`/`_hasDemoProgression` `==`-match +
`user_profile_sync_merge_test` ×7 (M25/02; **A-28 mới**; needs A-27
DTO, D-05 `==`, D-34 copyWith, D-03 null-safety) →
`UserProfileSyncRepositoryImpl` cùng file Disabled:
`_isSyncing` guard (contrast `_requestId` D-42 + `_isLoading`
dialog VM) → `InProgress` → load local → fetch `maybeSingle`
`eq('auth_uuid')` → merge → save local → `upsert(onConflict:
'auth_uuid')` → `Idle`; catch → `Failed`+rethrow; `_emit`
isClosed+dedupe (M25/03; **A-29 mới**; needs A-08 BehaviorSubject/
`.value`, A-10 emit discipline, A-28 merge, D-41 `maybeSingle`,
D-09 try/finally, B-08 upsert call) → `main()` ternary lần ba
`supabaseClient == null ? Disabled : Impl(client,
userProfileRepository)` + `GameScreenViewModel` ctor `profile→
auth→sync` + `_syncSavedGameResult` thật (`loadAuthState` → `is
AuthSessionAuthenticated` → sync; guest `skipped`; catch nuốt+
`failed:`) + `game_screen.dart` create `context.read` ×2 + mọi
call-site test compile-forced + comment "LUÔN Disabled" retire
(M25/04; **A-30 mới** + A-24 reinforcement; needs A-24 conditional
DI, A-22 save boundary `hasSavedResult`, A-26 coordinator call-site,
D-43 `is`-promote, A-11 fakes `syncCallCount`/`syncError`) →
`result profile sync (M25, FR-36)` group ×3 + ba-tầng-bằng-chứng
model + `LIVE_PROFILE_SYNC: NOT_PERFORMED` honesty + FR-36 closure
(M25/05; **synthesis** — needs A-30, A-11, D-24/D-33 FakeAsync,
A-22 idempotence).

New edges: A-27/B-08 → M25/01 → A-28 → M25/02 → A-29 → M25/03 →
A-24(reinforce)/A-30 → M25/04 → M25/05. Feeds M26 (DRE/`asyncOp`
thay `unawaited`+`_isSyncing`+try/catch tay trên cùng đường
save→sync; `_syncSavedGameResult` là op mẫu), M27 (version text,
notification permission — docs FR-27/28-residual), M28 (visual
parity — không chạm sync), M29 (`MenuDialogLayer` — không chạm
sync). FR-36 **CONVERGED**: seam `UserProfileSyncRepositoryDisabled`
→ impl thật + conditional DI + result-sync branch; learner
divergence còn lại: không có `bridge/`/`part` structure (impl
inline trong game VM), `showDialog` transport (M29), không DRE
(M26).

## M26 — DRE / senior async-state architecture convergence

Đọc-hiểu giới hạn mutation-tay (M26/01; no-file lesson — needs A-18
state machine, A-22 save boundary, D-42 `_requestId` mental model
cho phần contrast) → `core/dre/dre.dart` + `dre_change_notifier.dart`
verbatim senior: 4 marker `abstract interface class` + generic
bounds `DreReducer<S,A extends DreAction,E extends DreEffect,
O extends DreAsyncOp>`, `DreResult{state,effects,asyncOp?}`,
`DreChangeNotifier` (dispatch → reduce → state-swap →
`notifyListeners` chỉ khi state đổi → broadcast `effects` →
`unawaited(executeAsyncOp(op, postReduceSnapshot))` →
`onAsyncOpError` hook → dispatch/effect đều no-op sau dispose) +
`dre_change_notifier_test` ×5 (M26/02; **D-46 mới**; needs D-26
sealed, D-02 interface, D-09 Future, D-23 addTearDown, D-17
unawaited) → `view_models/game/dre/` 5 contract files:
`GameState` (reusable immutable + `copyWith` + `clear*` + unmodifiable
collections — field set y `GameSessionState` + `flowToken` IN state),
13 `GameAction` variants, 7 `GameEffect` variants (share giữ boundary
→ M27), `GameSaveResult` async-op, contract typedefs (M26/03;
**A-32 + A-33 mới**; needs D-34 copyWith/clear*, D-32/D-35
unmodifiable, M15 sealed, D-46) → `GameReducer` + 4 `part` files
(session/answer/feature/timer flows — verbatim senior trừ share
case): mọi transition/guard/chấm điểm thuần; `_withSaveResult` trả
`GameSaveResult` op thay `unawaited` trực tiếp; `flowToken` đọc/ghi
trong state — `*Elapsed` actions mang token chụp, reducer so token
= stale-callback giảm thành no-op NGAY trong reduce
(M26/04; **A-31 + D-45 mới**, A-34 mới; needs A-18 phase machine,
D-36 comprehensions, D-42 stale-guard mental model, D-45 part+
private extension) → VM rewrite `extends DreChangeNotifier<
GameState,GameAction,GameEffect,GameAsyncOp>`: public wrappers
dispatch actions; `_handleEffect` switch biến effect-data thành
`Timer`/`Future.delayed`/`uiEvents.add` thật;
`executeAsyncOp(GameSaveResult)` → `_saveGameResult` cũ (auth+sync
giữ nguyên M25); `onAsyncOpError` → debugPrint; `dialogState`/
`screenData`/`uiEvents` đọc từ `state` — UI call-sites KHÔNG đổi
(M26/05; needs A-31, A-32, A-33, A-34, A-22/A-30 persistence body
mang nguyên) → regression suite ×3 (dispose-during-delay, stale AI,
terminal save-once) + chain 236→254 (M26/06; **synthesis** — needs
toàn bộ A-31..A-34).

New edges: D-46 → M26/02 → A-32/A-33 → M26/03 → A-31/D-45/A-34 →
M26/04 → M26/05 → M26/06. Feeds M27 (share effect → platform
`share_plus`; `package_info`; notification service seam cùng
asyncOp pattern), M28 (visual parity — không chạm DRE), M29
(`MenuDialogLayer` — menu VM chưa DRE, senior cũng thế).
`GameSessionState` retired — `GameState` sống ở
`view_models/game/dre/` đúng senior layout; `bridge/` 2 part-files
(effects + result-persistence) mới.


## M27 — Platform extras: notifications, share, package info

Platform-boundary mental model + 5 deps + manifest verbatim
(M27/01; **A-35 mới** service-contract platform boundary,
**D-47 mới** `kIsWeb` + `resolvePlatformSpecificImplementation`;
needs A-07 DI-contract M14, A-24 conditional-DI contrast M23,
D-19 interface M14, F-17/F-21 Provider M12/M14) →
`LocalNotificationService` contract+impl + `FakeLocalNotificationService`
(M27/02; **F-36 mới** FLN/`zonedSchedule`/`DateTimeComponents.time`/
timezone; needs A-35, D-47, A-11 fake counters M14) →
`SettingsNotificationCoordinator` + permission-as-state trong
settings VM + 5 fake-counter tests (M27/03; **A-36 mới**
coordinator/best-effort rollback, **A-37 mới**
permission-as-state; needs A-35, F-36, A-26 coordinator call-site
M24, A-22 persist-loop M16, D-09) → DI `main()`/app-scope
unconditional + onboarding real `requestPermission` + `v$appVersion`
(M27/04; **F-37 mới** `package_info_plus`; needs A-35, A-37, F-36,
A-24 contrast, onboarding VM M18) → share cưỡi effects-stream M26:
`GameShareRequested`→reducer→`GameShareResult`→bridge→
`GameShareResultEvent`→`SharePlus`/`sharePositionOrigin`→`Clipboard`
fallback (M27/05; **F-35 mới** share_plus/Clipboard; needs A-33
effects→bridge M26, A-31 reducer M26, D-45 part files M26, M13
events) → regression + synthesis (M27/06; needs toàn bộ
A-35..A-37/D-47/F-35..F-37).

New edges: A-35 → M27/01+02 → F-36/D-47 → A-36/A-37 → M27/03 →
A-24-contrast + F-37 → M27/04 → A-33/A-31 → F-35 → M27/05 →
M27/06. Feeds M28 (`GameDialogButton`/`shareColor` visual —
`_DialogShareButton` scaffold retire), M29 (`MenuDialogLayer`),
mọi platform feature sau (contract-boundary + permission-state
là mẫu chung).


Design tokens + assets + deps + ARB semantics keys
(M28/01; **A-38 mới** tokens single-source; needs F-10 asset,
A-07 single-source, D-31 ARB M18) → chrome chung
`QzdsGameButton`/`GlassIconButton`/`GameScreenBackground` + SvgPicture
(M28/02; **D-48 mới** if-case, **F-42 mới** flutter_svg/srcIn;
needs A-38, D-26 pattern, F-10) → countdown timer
`AnimationController`×2 + `CustomPainter` stadium + top-bar host
(M28/03; **F-38 mới** controller/vsync, **F-39 mới** painter,
**F-40 mới** didUpdateWidget; needs A-38, F-29, F-07) → money
trigger-motion + reduce-motion + ladder dialog (M28/04; **A-39
mới** trigger-as-data, F-40 reuse, F-30 reuse; needs F-38/F-39,
A-38, M19 timerProgress field) → bề mặt game + dialog subsystem
(M28/05; **F-41 mới** implicit family, **F-43 mới** semantics-nâng;
needs F-29 AnimatedSwitcher M21, F-30 dialog layer M21, A-21
in-tree dialog M21, D-37 ValueKey M21) → atomic swap `icon`→
`iconAsset` + feature-button painter + `GameScreen` thin-shell +
xoá monolith + rewrite screen tests (M28/06; needs A-38 AppAssets,
F-38/F-39 painter, F-42 svg, D-45 part test seam, M20 mapper
featureButtons, M26 DRE screen contract).

New edges: A-38 → M28/01..06 (mọi consumer); D-48/F-42 → M28/02 →
F-38/F-39/F-40 → M28/03+04 → A-39 → F-41/F-43 → M28/05 →
F-42+F-38/F-39+D-45 → M28/06. Feeds M29 (`MenuTokens`→`AppTokens`
migration, `SettingItemData.iconAsset`, onboarding visuals,
`MenuDialogLayer` — cùng token/painter/svg vocabulary).
