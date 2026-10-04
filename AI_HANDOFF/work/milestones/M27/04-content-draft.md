# M27 — CONTENT DRAFT MANIFEST (Lumen)

## Intake gate

`IMPLEMENTATION_APPROVED` confirmed — `01-brief.md` +
`02-implementation-evidence.md` + `03-implementation-qa.md` on disk
(Argus PASS after remediation: manifest `RECEIVE_BOOT_COMPLETED` +
`POST_NOTIFICATIONS` added by Flux). Learner app verified on disk:
`flutter analyze` clean, `flutter test` **259/259** (254 + 5),
`flutter build web` PASS. Senior unchanged (`main@c8eb860`,
read-only). **`REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED`**
inherited — plugin↔OS paths (prompt thật, notification bắn thật,
share sheet thật, iPad anchor) carry fake-counters verification
weight per brief; stated honestly in lessons L01/L02/L04/L05/L06
+ index (never claimed performed).

`Future.wait` is listed as deferred-not-taught in the concept
registry, but senior `loadSettings` uses it verbatim — taught as
formalization of already-seen `await`-parallelism (D-09), declared
deviation below.

## Lessons authored (6 + index) — `AI_HANDOFF/work/milestones/M27/lessons/`

| File | Concepts (brief registry) | Exercise |
|---|---|---|
| `index.md` | milestone map + deferred table + synthesis 5-câu + FR-27/28-residual/FR-33 closure | — |
| `01-platform-boundary-va-dependencies.md` | **A-35** service-contract platform boundary — widget→VM→contract→impl→plugin→OS, `lib/services/` sở hữu plugin import duy nhất (architecture, CORE); **D-47** phần một — `kIsWeb` hằng biên dịch vs `Platform.is*` runtime/`dart:io`-trên-web-lỗi (NORMAL); manifest `uses-permission`×2 + receiver×2 verbatim (LIGHT) | Tự làm **PRODUCE** `LoggingReminderService` decorator + counters; Thử nghiệm PREDICT xoá POST_NOTIFICATIONS (suite xanh / device đỏ) |
| `02-local-notification-service.md` | **F-36** `flutter_local_notifications` — `zonedSchedule` + `DateTimeComponents.time` + `inexactAllowWhileIdle` + id 1001 + channel + payload (NORMAL); **D-47** phần hai — `resolvePlatformSpecificImplementation<T>()` null-gate + `!kIsWeb` fallback value (NORMAL); **A-35** reinforcement — `FakeLocalNotificationService` counters/`throwOn*` | Tự làm **PREDICT** `_nextDailyTime` 3-case incl. equality-rolls-tomorrow; Thử nghiệm PREDICT bỏ `cancelDaily` (vẫn 1 notification — defensive-cancel ý đồ) |
| `03-settings-coordinator-permission-state.md` | **A-36** coordinator + best-effort rollback — schedule-trước-save-sau, `_saveSettingsWithRollback` giữ lỗi gốc, `_restoreSchedule` (architecture, CORE); **A-37** permission-as-state — `_hasNotificationPermission` OS-owned, `effectiveNotificationEnabled` = flag AND permission, `Future.wait`×3 (architecture, CORE) | Tự làm **DEBUG** (verified reasoning): đảo thứ tự schedule/save trong `enable` → test `'schedule lỗi → settings vẫn off + snackbar updateFailed'` ĐỎ at `expect(repo.value.notificationEnabled, isFalse)` Actual `true`; Thử nghiệm PREDICT quên `loadSettings` trước toggle (false-confidence path) |
| `04-settings-wiring-version-onboarding.md` | **F-37** `package_info_plus` — `PackageInfo.fromPlatform().version` + `Future<String> Function()` seam `() async => '9.9.9'` (NORMAL); A-24 contrast — unconditional `LocalNotificationServiceImpl()` vs conditional Supabase DI (reinforcement); onboarding `requestPermission` thật + `FlutterError.reportError` (FR-27) | Tự làm **PREDICT** `loadAppVersion` throw → `loadSettings` atomicity (cả ba gán hay không gán); Thử nghiệm PREDICT conditional-DI cho notification (cần Disabled-impl mới — không có config để điều kiện hoá) |
| `05-share-chain-dre-effect.md` | **F-35** `share_plus` + `Clipboard` fallback — `SharePlus.instance.share(ShareParams)`, `RenderBox`/`localToGlobal`/`&`-Rect `sharePositionOrigin`, catch→clipboard+snackbar (NORMAL); A-31/A-33 reuse — share cưỡi reducer + effects-stream, KHÔNG concept mới; `_DialogShareButton` TEACHING SCAFFOLD (caution box — `GameDialogButton`/`shareColor` → M28) | Tự làm **PRODUCE** reducer test scratch cho `GameShareRequested` (state same-instance + `GameShareResult` effect) — suite shipped không có test này; Thử nghiệm PREDICT đổi effects→`copyWith` (state-không-đổi mental model) |
| `06-regression-va-tong-ket.md` | synthesis — boundary→coordinator→permission→effect→platform trên một sơ đồ; fake counters = deterministic OS substitute; FR convergence table; NOT_PERFORMED honesty; M28/M29 deferred | Tự làm **PREDICT** chuỗi share-fail (Clipboard fallback + `!mounted` + tầng-hai-throw → unhandled async); Thử nghiệm trace denied-path đầy đủ |

## Concept → brief registry entry mapping

| Brief entry (corrected M27 allocation) | Lesson | Registry row used in lessons |
|---|---|---|
| service-contract platform boundary | L01 (+reinforced L02) | **A-35** (new, CORE) |
| coordinator + best-effort rollback | L03 | **A-36** (new, CORE) |
| permission-as-state / AND-gate | L03 | **A-37** (new, CORE) |
| `kIsWeb` + `resolvePlatformSpecificImplementation` | L01 (kIsWeb) → L02 (resolve + `!kIsWeb`) | **D-47** (new, NORMAL) |
| `share_plus` + `Clipboard` fallback | L05 | **F-35** (new, NORMAL) |
| `flutter_local_notifications` + `zonedSchedule`/`DateTimeComponents.time` | L02 | **F-36** (new, NORMAL) |
| `package_info_plus` | L04 | **F-37** (new, NORMAL) |

**F-33/F-34 NOT used** — đã thuộc M26 (effects-stream + async-op);
M26 concepts cited as A-31 (reducer) / A-33 (effects-stream→
bridge) where reused — share rides the effects path; no new
effects-stream concept claimed in L05.

Reinforcement rows cited (no new rows): A-24 (conditional-DI
contrast L04), A-31/A-33 (DRE reducer + effects reuse L05), A-11 (fake
counters), A-16 (l10n ở layer không VM), A-05/A-15/A-22 (VM event
+ stream-truth + dialog-scoped), F-17/F-21 (`context.read` +
`Provider.value`), D-19 (`abstract interface class`), D-03 (`??`
fallbacks), D-18 (tear-off `rollback: …cancelDaily`), D-09
(`Future`/`await`; `Future.wait` lần-đầu — see deviations),
D-26/D-27 (`sealed`/`final class` + exhaustive `switch`),
D-45 (`part of` extension — bridge arm), A-16/F-25 (l10n ở
layer — share text), D-31 (ARB placeholders), D-30 (`late
final` coordinator), A-21 (in-tree dialog layer host of share
button), A-14 (render-by-state `timePickerVisible`).

Mental models placed: "UI không chạm plugin trực tiếp" (contract→
impl→plugin→OS) → L01; "một file = một bộ phiên dịch platform"
(thời gian/permission/null-platform) → L02; "permission là state
OS sở hữu" (AND-gate) + "coordinator orchestrate, rollback
best-effort giữ lỗi gốc" → L03; "hai kiểu DI: conditional theo
config vs unconditional theo tự-an-toàn" → L04; "share sheet là
effect, không phải state" → L05; "test ở đúng tầng — fake gánh
ý định, device gánh OS" → L06.

Isolated examples: `ReminderService` contract + `FakeReminder`
counters → L01; `nextDailyTime` `DateTime`-port rollover → L02;
`runWithRollback` giữ lỗi gốc → L03; `VersionHolder` seam
`Function()` → L04; `Offset & Size` → `Rect` → L05; `CountingOs`
→ L06.

## Depth assignments

- Guided/new: **A-35, A-36, A-37** CORE; **D-47, F-35, F-36, F-37**
  NORMAL.
- LIGHT/awareness: manifest `uses-permission`/receivers (copy
  verbatim + vai trò, không deep-dive boot-reschedule);
  `payload: 'daily_quiz'` (data đi kèm, senior không có handler).
- ≤3 new concepts per lesson (excluding LIGHT/awareness/
  reinforcement): L01=2 (A-35+D-47-part), L02=2 (F-36+D-47-part),
  L03=2 (A-36+A-37), L04=1 (F-37), L05=1 (F-35), L06=0.

## Registry / graph notes (for post-authoring step)

- `LEARNER_CONCEPT_REGISTRY.md` (not authored here — content
  authoring scope chỉ gồm M27 files): rows needed → **A-35/A-36/
  A-37** (Architecture), **D-47** (Dart), **F-35/F-36/F-37**
  (Flutter/Framework). Reinforcement touches: A-24, A-31/A-33,
  A-11, A-16, F-17/F-21, D-19, D-09, D-03, D-18, D-30, D-45.
- `PREREQUISITE_GRAPH.md`: M27 section to append (A-35+D-47 →
  L01→L02; A-36+A-37 → L03; F-37 → L04; F-35 (+A-31/A-33 reuse) → L05;
  synthesis → L06; feeds M28 visuals + M29 dialog transport).
- `SENIOR_FIDELITY_REGISTER.md`: **FR-27 → CONVERGED**, **FR-28
  (version) → CONVERGED** (account-row visual stays M28), **FR-33
  → CONVERGED** at M27.
- Registry/graph edits are outside this handoff's write scope —
  listed here for the update step (same convention as prior
  milestones).

## Incremental implementation (step sizes)

| Lesson | Steps | Justification |
|---|---|---|
| L01 | 3 (pubspec+deps, manifest 2+2, verify) | deps+manifest only — chưa file Dart nào dùng; 254/254 giữ |
| L02 | 3 (service file ~178d, fake ~54d, verify) | service verbatim một file duy nhất — không cắt nhỏ được vì contract+impl cùng file senior; fake là test-infra |
| L03 | 7 (coordinator file, enum, VM 5-edit, scope+dialog+ARB, tests, 2 test-host fixes, verify) | VM ctor `required` compile-forces scope/test updates cùng bài — không thể tách thành hai bài mà giữ compile green |
| L04 | 6 (main, scope DI, version row, onboarding, test hosts ×5, verify) | đóng ProviderNotFound gap L03 mở — sequential-required |
| L05 | 10 (ARB, action/effect/event ×3 file, reducer arm, bridge arm, VM wrapper, views+scaffold, layer, screen, test-host fix, verify) | mỗi mắt chain một file — verbatim, không intermediate-state nào cần label |
| L06 | 4 (analyze, test, build web, self-check) | regression-only — không code mới |

Largest single paste: `local_notification_service.dart` (~178
dòng verbatim) — senior file, declared; chia nhỏ trong bài thành
contract/init/permission/schedule+helper bốn khối giải thích.

## Code-explanation coverage

- Mọi construct mới trong mọi block đều có dòng giải thích hoặc
  bảng Dart/Flutter cần dùng: `resolvePlatformSpecificImplementation
  <T>()`, `tz.*` pair-import, `zonedSchedule` named-params,
  `inexactAllowWhileIdle`, `DateTimeComponents.time`, `payload`,
  `!kIsWeb` fallback-value, `Future.wait`+`as`-unwrap, tear-off
  `rollback: notificationService.cancelDaily`, `PackageInfo.
  fromPlatform()`, `FlutterError.reportError`, `unawaited`,
  `context.findRenderObject() as RenderBox?`, `localToGlobal(
  Offset.zero) & box.size`, `ShareParams`, `Clipboard.setData`,
  `Future<void>`-handler-assign-void.
- ARB placeholder metadata `{amount}`/`{message}` shown verbatim
  (en+vi); `label.toUpperCase()` explained as senior parity.

## Android bridges

| Lesson | Bridge | False-equivalence check |
|---|---|---|
| L01 | manifest `uses-permission`/`receiver` | 3-line ✓ — POST_NOTIFICATIONS là runtime-permission ≠ install-time; `kIsWeb` ≠ `Platform.isWeb` + web impl federated (không MissingPluginException) |
| L02 | `NotificationDetails` ≈ `NotificationChannel`/builder | 3-line ✓ — `inexactAllowWhileIdle` ≠ `setExact…`; `zonedSchedule`+`DateTimeComponents.time` ≠ one-shot `AlarmManager` |
| L03 | coordinator ≈ transaction script quanh prefs+WorkManager | 3-line ✓ — rollback best-effort ≠ DB atomicity; permission không persist được (≈ `checkSelfPermission` per-resume) |
| L04 | `PackageInfo.version` ≈ `versionName` | 3-line ✓ — runtime-permission chỉ prompt giới hạn lần; service lazy-init ≠ `main()`-init |
| L05 | `SharePlus` ≈ `ACTION_SEND`+chooser | 3-line ✓ — `sharePositionOrigin` là iPad-popover (Android ignore); share-throw → clipboard fallback cố ý |
| L06 | notification path ≈ `WorkManager`/`AlarmManager`+wrapper | 3-line ✓ — fake counters ≠ Robolectric; suite xanh ≠ device thật |

## Senior evidence references

| Lesson | Citation | Evidence class |
|---|---|---|
| L01 | `pubspec.yaml` 5 pins · `android/app/src/main/AndroidManifest.xml` (`RECEIVE_BOOT_COMPLETED`, `POST_NOTIFICATIONS`, `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver` + 4 intent-filter actions) | DIRECT_EVIDENCE (verbatim port) |
| L02 | `lib/services/local_notification_service.dart` (contract 5-method, `_dailyNotificationId 1001`, `_channelId`, `initialize`+`_isInitialized`, `_setLocalTimeZone` UTC fallback, `hasPermission`/`requestPermission` resolve-chain + `!kIsWeb`, `scheduleDaily`/`cancelDaily`, `_nextDailyTime`) · `test/helpers/fake_local_notification_service.dart` | DIRECT_EVIDENCE (verbatim) |
| L03 | `lib/view_models/settings/settings_notification_coordinator.dart` (verbatim 82d) · `settings_view_model.dart` (`notificationService`, `_loadAppVersion`, `_notificationCoordinator`, `_hasNotificationPermission`, `effectiveNotificationEnabled`, `loadSettings` wait×3, `_toggleNotifications`, `onNotificationTimeSelected`) · `settings_ui_event.dart` enum · `test/settings_view_model_test.dart` 12-test | DIRECT_EVIDENCE (verbatim) |
| L04 | `lib/main.dart` (`LocalNotificationServiceImpl()` unconditional + comment) · `core/app_dependency_scope.dart` (`Provider<LocalNotificationService>.value`) · `settings_app_version_loader.dart` (verbatim 6d) · `settings_dialog.dart` `v$appVersion` row · `onboarding_overlay_scope.dart` `_requestNotificationPermission` | DIRECT_EVIDENCE (verbatim) |
| L05 | `game_dre_action.dart` `GameShareRequested` · `game_dre_effect.dart` `GameShareResult` · `game_reducer.dart` arm · `game_screen_view_model_effects.dart` arm · `game_session_state_data.dart` `GameShareResultEvent` · `game_screen_view_model.dart` `shareResult` · `game_dialog_layer.dart` `onShareResult`+l10n · `game_dialog_views.dart` `_DialogShareButton`+`shareAction` · `game_screen.dart` share arm | DIRECT_EVIDENCE (verbatim; `_DialogShareButton` declared-scaffold) |
| L06 | all above (synthesis) | DIRECT_EVIDENCE |

## Exercises & checks

| Lesson | Type | Task | Verifiability |
|---|---|---|---|
| L01 | PRODUCE + PREDICT | `LoggingReminderService` decorator (callCount=2, scheduleCount=1); manifest-removal consequence | DartPad-runnable (solution in `<details>`); manifest outcome reasoned (không test được trong suite — declared) |
| L02 | PREDICT ×2 | `_nextDailyTime` 3-case incl. equality; `cancelDaily`-removal (vẫn 1 notif — defensive ý đồ) | DartPad-runnable vs shipped `_nextDailyTime` verbatim; id-1001 upsert semantics documented |
| L03 | **DEBUG** + PREDICT | đảo schedule/save trong `enable` → test nào đỏ + invariant hỏng; quên `loadSettings` → counters đúng-nhầm-đường | **verified reasoning against shipped suite**: `'schedule lỗi → settings vẫn off + snackbar updateFailed'` expect `isFalse` nhận `true` (save-on trước schedule-fail); false-confidence path giải thích bằng `_hasNotificationPermission=false` initial |
| L04 | PREDICT ×2 | `loadAppVersion` throw → atomicity `Future.wait` (không gán nửa-vở) + `v…` row gate; conditional-DI hypothetical (cần Disabled-impl) | vs shipped `loadSettings` code; vs shipped ARB/row gate |
| L05 | **PRODUCE** + PREDICT | reducer test scratch `GameShareRequested` (state `same(initialState)` + `GameShareResult` effect); effects→copyWith mental-model | runnable vs shipped `GameReducer.reduce` — suite intentionally lacks this test (declared) |
| L06 | PREDICT + trace | share-fail chain incl. tầng-hai clipboard-throw → unhandled async; denied-path full trace | vs shipped `_handleUiEvent`/`_toggleNotifications` verbatim |

Spread: PRODUCE ×2 (L01, L05), DEBUG ×1 (L03 — verified against
shipped suite semantics), PREDICT/trace ×5. Requirement ≥1
PRODUCE-or-DEBUG satisfied (both present).

## Common mistakes covered

- L01: manifest≠permission-granted; `dart:io`-on-web; receiver
  package-name verbatim; permission-thu-hồi-mọi-lúc.
- L02: quên `tz.initializeTimeZones`; tưởng `zonedSchedule`
  one-shot; `DateTime` trần cho `scheduledDate`; `requestPermission`
  ≠ prompt mọi platform; sửa constants.
- L03: persist permission; quên `rethrow` lỗi gốc; `updateTime`
  schedule khi flag-off; quên AND permission; `enable` trước khi
  biết permission.
- L04: `initialize()` trong `main()`; quên test hosts (compile-
  forced — tính năng); trộn hai call-site request; hardcode
  version; tưởng `reportError` crash.
- L05: `Share.share(text)` API cũ; build chuỗi trong VM;
  `sharePositionOrigin` từ dialog; quên `!mounted` re-guard; bỏ
  catch.
- L06: milestone-level recap (persist-permission, save-first,
  widget-import-plugin, dialog-anchor, assume-tested).

## Intentionally delayed concepts

| Deferred | Owner |
|---|---|
| `GameDialogButton`/`shareColor` gradient + toàn bộ visual parity (`SettingsDialogShell`, `OnboardingGameButton`, `MenuDialogBackdrop`, icon assets, `LevelProgressCard`, account-row auth visual) | **M28** (FR-28-visual/FR-30/FR-32/FR-34) |
| `MenuDialogLayer` + `MenuDialogSettings`/`Auth`/`SignOut` state transport | **M29** (FR-29) |
| Notification tap-handler (payload `'daily_quiz'` deep-link) | — senior không có |
| Exact alarms / nhiều channel / custom actions / foreground presentation | — roadmap loại trừ |
| Re-schedule sau reboot tự viết | — plugin receiver cover |
| iOS `hasPermission` check; denied-guidance UI ("mở Settings máy") | — senior không wire |
| Share ảnh/file (`ShareFiles`), share analytics | — senior không |
| `TestDefaultBinaryMessenger`-style plugin-level tests | — fake counters carry (senior cũng không test plugin thật) |

## Completion criteria

Per-lesson binary checkpoints (all in each file's `Checkpoint
hoàn thành`):

- L01: 5 pins + 2 uses-permission + 2 receiver; analyze clean;
  **254/254**.
- L02: service + fake verbatim constants/behavior; analyze clean;
  **254/254**.
- L03: coordinator + VM + scope-param + enum/ARB + 2 test-host
  fixes; **259/259** (+5); compile sạch với
  `ProviderNotFound`-runtime-gap declared.
- L04: main unconditional + `Provider<…>.value`; `v…` row;
  onboarding real-request; 5 test-host updates; **259/259**;
  `build web` xanh.
- L05: chain sáu mắt + scaffold caution + 4 ARB key + 1 test-host
  fix; **259/259**;
  `build web` xanh.
- L06: analyze clean + **259/259** + `build web` PASS + synthesis
  trả lời đủ 5 câu.

Milestone-level: analyze clean; 259/259 (254+0+0+5+0+0+0);
`flutter build web` PASS; FR-27/FR-28-version/FR-33 CONVERGED;
`REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` stated verbatim in
index + L04 + L06.

## Checkpoint arithmetic (honest, from M26 final 254)

| Lesson end | Count | Delta | Test files touched |
|---|---|---|---|
| L01 | **254** | +0 | none (deps+manifest only) |
| L02 | **254** | +0 | `test/helpers/fake_local_notification_service.dart` created (infra — chưa import) |
| L03 | **259** | +5 | `test/settings_view_model_test.dart`: 7→12 — new `loadSettings nạp defaults + appVersion qua seam`, `quyền bị từ chối→off+snackbar`, `tắt→cancel+persist-off`, `schedule lỗi→off+updateFailed`, `schedule lỗi khi đổi giờ→giữ giờ cũ`; expanded `bật notifications`(+request/schedule counters), `onNotificationTimeSelected`(+reschedule asserts); `loadFailed` pre-existed M16; compile-forced host fixes: `widgets/settings_dialog_test.dart` (+`notificationService:` ctor arg + `Provider<…>.value` cho `showSettingsDialog` test), `localization_switch_test.dart` (+ctor arg) |
| L04 | **259** | +0 | host updates only: 4 `AppDependencyScope` hosts (`menu_provider_scope_test.dart`, `menu_screen_ui_events_test.dart`, `widgets/game_screen_test.dart`, `widgets/menu_leaderboard_dialog_test.dart`) +`notificationService:` fake; `widgets/onboarding_overlay_test.dart` +`Provider<LocalNotificationService>.value` |
| L05 | **259** | +0 | `widgets/game_dialog_layer_test.dart` (+`onShareResult: (_) {}` — compile-forced call-site fix; share chain: reducer-arm assertable nhưng suite không thêm test mới — Tự làm PRODUCE bù) |
| L06 | **259** | +0 | none |

Cross-checked vs impl ledger: 254 + 0 + 0 + 5 + 0 + 0 + 0 = **259**
✓ matches `02-implementation-evidence.md` (`259/259`) +
`03-implementation-qa.md` PASS + `00-status.md` post-impl line.

## Per-lesson checkpoint commands (all credential-free)

- L01: `flutter pub get`, `flutter analyze`, `flutter test` (254)
- L02: `flutter analyze`, `flutter test` (254)
- L03: `flutter analyze`, `flutter test
  test/settings_view_model_test.dart` (12), `flutter test` (259)
- L04: `flutter analyze`, `flutter test` (259), `flutter build web`
- L05: `flutter analyze`, `flutter test` (259); optional scratch
  `flutter test test/m27_share_reducer_exercise_test.dart` then
  delete (keeps 259 senior-parity count honest)
- L06: `flutter analyze`, `flutter test` (259), `flutter build web`

## Remote-runtime honesty (hard requirement)

Every lesson states mandatory path = fake counters + seam;
**`REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED`** appears verbatim in
index (lesson-map row + deferred table), L02 (Chạy-và-quan-sát),
L04 (Chạy-và-quan-sát), L05 (Chạy-và-quan-sát), L06 (verification
table + checklist). No test invokes a real
OS notification or share sheet — declared in L02/L05/L06. On-web
behavior described honestly: `hasPermission`→`true` (no Android
impl to check), `requestPermission`→`false` (`!kIsWeb` fallback —
onboarding path), `zonedSchedule`→`UnsupportedError`→caught→
snackbar; `share`→throw→clipboard. `_DialogShareButton` labelled
`:::caution[TEACHING SCAFFOLD]` at introduction in L05; visual
parity owned by M28.

## Declared deviations from template

- Template-V2 spine kept on all six lessons + index (Mục tiêu →
  Checkpoint hoàn thành); index follows M26 overview shape
  (Triết-lý note, lesson map, deferred table, 5-question
  synthesis).
- `settings_app_version_loader.dart` lands **L03** not L04
  (VM imports it for the `_loadAppVersion` default — file must
  exist at L03 compile time); F-37 *explanation* + `v…` row stay
  L04. Declared in both lessons.
- L03 ends in a **compilable-but-runtime-gap** state (declared
  `:::caution`): `showSettingsDialog` `context.read<Local
  NotificationService>` lacks the provider until L04 registers
  `Provider<LocalNotificationService>.value` — suite stays green
  (host fixes ở Bước 6 giữ suite xanh); L04 opens by closing it.
  Sequential-execution preserved; the gap is the DI-missing
  teaching beat.
- `Future.wait` taught inside L03 `loadSettings` as D-09
  formalization — registry lists it deferred, but senior uses it
  verbatim; taught as "đã gặp, giờ formalize" rather than new
  concept row (no new ID claimed).
- Share carries **no new effects-stream concept** — A-31/A-33
  reuse only (reducer + effects→bridge; `asyncOp` A-32 /
  `flowToken` A-34 not on the share path); F-33/F-34 remain
  M26-owned (corrected allocation per brief).
- Onboarding VM `onNotificationPermissionResult` pre-exists M18 —
  L04 changes only the *scope call-site* (simulated→real), not
  the VM.
- `_DialogShareButton` is a declared learner scaffold (senior
  `GameDialogButton` is M28) — the only non-verbatim new widget;
  flagged `:::caution[TEACHING SCAFFOLD]`.
- L05 has +0 tests by design (plugin path not unit-testable;
  reducer-arm covered via PRODUCE exercise) — same honest-
  coverage convention as M25 L03.

## Verification before handoff

- Every quoted symbol verified against learner disk via grep/sed
  (stale-read issue worked around — verified by shell reads):
  `local_notification_service.dart` full file (178d),
  `settings_notification_coordinator.dart` (82d),
  `settings_view_model.dart` (ctor/`loadSettings`/`_toggle
  Notifications`/`effectiveNotificationEnabled`/`onNotification
  TimeSelected`), `settings_ui_event.dart` enum,
  `settings_app_version_loader.dart` (6d), `settings_dialog.dart`
  (`context.read` l34, scope field l53, `v…` row l241–253,
  snackbar arm l146–147), `app_dependency_scope.dart` (field l56,
  ctor l74, provider l93), `main.dart` (l90–104),
  `onboarding_overlay_scope.dart` (l91–119), `game_dre_action.dart`
  `GameShareRequested` (l70–77), `game_dre_effect.dart`
  `GameShareResult` (l41–47), `game_reducer.dart` arm (l54–58),
  `game_screen_view_model_effects.dart` arm (l21–23),
  `game_session_state_data.dart` `GameShareResultEvent` (l203–209),
  `game_screen_view_model.dart` `shareResult` (l131–135),
  `game_dialog_layer.dart` (`onShareResult` l32/l41, l10n l55–58,
  Ended l165–170, Victory l175–180), `game_dialog_views.dart`
  (`shareAction` l27–37/l64–69, Ended `#325DFA` l529–532, Victory
  `statGreen` l589–592, `_DialogShareButton` l703–725),
  `game_screen.dart` (`_handleUiEvent`→`Future<void>` l139,
  share arm l143–168, `onShareResult` wiring l301).
- ARB keys verified on disk: `shareResultButton`, `shareResult
  Message`+`@`placeholders, `shareVictoryResultMessage`+`@`,
  `resultCopiedSnackBar` (en l139–144, vi l132–135);
  `settingsNotificationPermissionRequiredMessage` (en l145, vi
  l136).
- Test file verified: `settings_view_model_test.dart` 12 tests —
  `createViewModel` seam + `notificationSwitch` helper + five
  M27-new/expanded (l89–237) quoted verbatim.
- Web-safety chain verified from pub cache
  (`flutter_local_notifications_web-1.0.0`): web impl exists —
  `initialize()` returns `false` on unsupported browsers (no
  throw), `zonedSchedule` throws `UnsupportedError`, resolves
  return null → `!kIsWeb` → `false`. L01 wording corrected
  accordingly (`kIsWeb` là *giá trị* fallback, không phải dead-
  code guard trong file này).
- Suite arithmetic re-derived: 254 + 5 = 259 ✓; test-listing
  count 12 = 7 baseline + 5 net (names enumerated in L03 step 5).
- No `dart test`/`dart analyze` anywhere — all `flutter`.
- **Code snapshot alignment:** mọi block trong bài khớp disk tại
  post-implementation state (verbatim senior ports); intermediate
  labelled states: (1) L03 `SettingsDialogScope.notificationService`
  compile-ok nhưng `showSettingsDialog` `context.read` runtime-gap
  tới L04 (declared `:::caution` box); (2) `settings_app_version_
  loader.dart` land ở L03 nhưng row UI `v…` land ở L04 (declared
  trong "Ta cố ý chưa thêm" của L03); (3) `_DialogShareButton` là
  declared scaffold (senior `GameDialogButton` → M28).
- Allowed write scope respected: only `M27/04-content-draft.md`
  + `M27/lessons/*`; `web/` and `learner-app/` untouched.
