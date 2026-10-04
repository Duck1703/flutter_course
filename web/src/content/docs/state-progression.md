---
title: Tiến trình quản lý state
description: "Một câu chuyện duy nhất: setState → ChangeNotifier → Provider → UI event → repository state stream. Mỗi bước giải quyết một vấn đề của bước trước."
sidebar:
  label: Tiến trình state
  order: 4
---

Trang này là bản đồ tổng: course không nhảy từ `setState` thẳng sang
repository stream — mỗi kỹ thuật đến vì kỹ thuật trước *thiếu* một
thứ cụ thể. Đọc lại trang này bất cứ khi nào bạn thấy "tại sao lại
phức tạp thế" — câu trả lời luôn là "vì bước trước không làm được
việc này".

```
setState (M03)        → state sống TRONG widget — nhưng chỉ widget đó
ChangeNotifier (M11)  → state tách ra object riêng — ai giữ/dispose nó?
Provider (M12)        → object đặt trong cây — nhưng UI≠state hết:
                        điều hướng/snackbar không phải "state"
UI events (M13)       → event một-lần tách khỏi state — nhưng ai giữ
                        "giá trị hiện tại" khi VM chết?
Repository stream (M14) → state sống trong repo — app-wide, replay,
                        test bằng fake — đúng kiến trúc senior.
Sealed state (M15)    → tập variant UI đóng — compiler đếm hết, thiếu
                        case = lỗi biên dịch; render = f(state).
Dialog-scoped VM (M16) → state sống TRONG provider của dialog — tầng
                        thứ ba giữa screen-scope và app-scope; persist
                        vẫn đi qua repository stream.
App-root StreamBuilder (M17) → `MaterialApp.locale` = derived state
                        từ settings stream — đổi ngôn ngữ runtime,
                        không restart.
Overlay-scoped VM (M18) → onboarding sống trong `Stack` của menu
                        — tầng thứ tư (overlay-scope); visibility là
                        state `!onboardingCompleted`, không phải route.
Session state machine (M19) → state game = một object bất biến +
                        enum phase; VM sở hữu timer/delay, UI render
                        DTO — không còn state lỏng trong widget.
```

## Từng bước — vấn đề nó giải quyết

### Bước 1 — `setState` trong `State` (M03)

| | |
|---|---|
| **Vấn đề giải quyết** | Widget immutable → cần một nơi giữ state đổi được |
| **Cơ chế** | `State<T>` giữ field; `setState` báo dirty → rebuild |
| **Ai sở hữu** | `State` object — sống cùng widget trong cây |
| **Hướng dữ liệu** | state trong `State` → render; event lên qua callback |
| **Còn thiếu** | state kẹt trong *một* widget — widget khác không chạm tới; không test được mà không pump UI |

### Bước 2 — `ChangeNotifier` + `ListenableBuilder` (M11)

| | |
|---|---|
| **Vấn đề giải quyết** | Tách state khỏi widget → `MenuViewModel` giữ state, test không cần widget |
| **Cơ chế** | `notifyListeners()` báo đổi; `ListenableBuilder` subscribe |
| **Ai sở hữu** | Người tạo VM — `_MenuScreenState` tạo rồi `dispose` nó |
| **Hướng dữ liệu** | VM → notify → UI rebuild |
| **Còn thiếu** | VM vẫn do màn hình tạo → đổi màn là mất VM; dependency phải truyền tay qua ctor |

### Bước 3 — `Provider`/`context.read`/`watch` (M12)

| | |
|---|---|
| **Vấn đề giải quyết** | Đặt dependency vào *cây* thay vì truyền ctor — widget nào cũng tra được |
| **Cơ chế** | `Provider<T>.value`/`ChangeNotifierProvider` đăng ký theo kiểu; `context.read`/`watch` tra |
| **Ai sở hữu** | `main()` → `AppDependencyScope` cho app-scoped; `ChangeNotifierProvider` tự dispose VM |
| **Hướng dữ liệu** | dependency chảy xuống cây; `watch` ngược lên subscribe |
| **Còn thiếu** | mọi thứ VM phát đều là "state" — nhưng *điều hướng*/*snackbar* không phải state mà là việc-vừa-xảy-ra |

### Bước 4 — UI event stream một-lần (M13)

| | |
|---|---|
| **Vấn đề giải quyết** | VM cần "ra lệnh" UI (điều hướng, snackbar) mà không biết context — event không phải state |
| **Cơ chế** | `StreamController<MenuUiEvent>.broadcast()` — event một lần, không replay |
| **Ai sở hữu** | VM giữ controller, `dispose` đóng nó; widget subscribe trong `didChangeDependencies` |
| **Hướng dữ liệu** | VM → `events.add` → widget bridge nghe → UI hành động |
| **Còn thiếu** | event không giữ "giá trị hiện tại"; profile vẫn load tay + `MenuLoadState` vá khoảng trống |

### Bước 5 — Repository state stream (M14)

| | |
|---|---|
| **Vấn đề giải quyết** | "Giá trị hiện tại" phải sống ở *boundary*, không trong VM — VM chết, state không mất; subscriber mới vẫn có giá trị |
| **Cơ chế** | `BehaviorSubject.seeded` trong repo → `ValueStream` expose `.value` + replay; VM ctor seed `.value` + `listen` |
| **Ai sở hữu** | `main()` tạo repo (app-scoped, sống cùng app); VM chỉ *subscribe* — không sở hữu stream |
| **Hướng dữ liệu** | writer → `repo.save*` → subject emit → `_handleUserProfile` → `notifyListeners` → UI |
| **Còn thiếu** | (đủ cho M14) — event vẫn broadcast, vẫn đúng |

### Bước 6 — Sealed state + state-driven UI (M15)

| | |
|---|---|
| **Vấn đề giải quyết** | Cờ/field rời rạc (`_endReason?`, `isLoading`…) cho phép tổ hợp vô nghĩa compiler không chặn; `is`-chain rơi nhánh âm thầm |
| **Cơ chế** | `sealed class` (tập variant đóng, cùng file) + `switch` kiệt hợp — thiếu case là *lỗi biên dịch* |
| **Ai sở hữu** | vẫn `State`/VM — thay đổi là *kiểu* của state, không phải chủ sở hữu |
| **Hướng dữ liệu** | state (sealed) → `switch(state)` → nội dung UI — render là hàm của state |
| **Còn thiếu** | dialog vẫn mở bằng `showDialog` route (in-`Stack` layer M21); phase machine chưa reducer hoá (M19) |

### Bước 7 — Dialog-scoped VM + persist loop (M16)

| | |
|---|---|
| **Vấn đề giải quyết** | Settings state ("đang mở picker", toggle tạm) không thuộc màn menu — cần tầng sống ngắn hơn screen, dài hơn một frame |
| **Cơ chế** | `ChangeNotifierProvider(create:)` đặt *trong* subtree dialog → VM sinh/chết cùng dialog; thay đổi đi qua `repo.save → BehaviorSubject → stream → VM → notifyListeners` |
| **Ai sở hữu** | ba tầng rõ rệt: repo = app-scope (sống suốt app), `MenuViewModel` = screen-scope, `SettingsViewModel` = dialog-scope |
| **Hướng dữ liệu** | `Switch.onChanged` → `vm.toggleSetting` → repo → stream → `_handleSettings` → rebuild; UI không giữ giá trị |
| **Còn thiếu** | entry dialog vẫn `showDialog` (FR-16/29 → M21) |

### Bước 8 — Locale = derived state ở app-root (M17)

| | |
|---|---|
| **Vấn đề giải quyết** | `languageCode` đã persist (M16) nhưng app chưa *phản ứng* — cần "ai đọc giá trị đó và gắn vào `MaterialApp.locale`" |
| **Cơ chế** | `StreamBuilder` quanh `MaterialApp` trên `userSettingsStream` (`initialData: .value` chống flicker) + `_selectedLocaleFor` whitelist en/vi → `Locale`; gen-l10n tạo `AppLocalizations` từ 2 file `.arb` |
| **Ai sở hữu** | chuỗi sống trong `.arb` (source of truth); locale sống trong repo stream; VM/factory **context-free** — UI đọc `l10n` rồi truyền chuỗi vào |
| **Hướng dữ liệu** | chip ngôn ngữ → `vm.setLanguage` → repo → stream → `StreamBuilder` → `MaterialApp.locale` → `AppLocalizations.of(context)` trả bản mới — đổi toàn app trong một frame |
| **Còn thiếu** | quiz-bank + repo error strings chưa l10n (FR-31, `ACTIVE_TEMPORARY`); onboarding l10n → M18 |

### Bước 9 — Overlay-scoped VM + cờ show-once (M18)

| | |
|---|---|
| **Vấn đề giải quyết** | "chỉ hiện lần đầu" không thể là route/dialog — cần một nhánh cây render khi state cho phép, và một cổng chặn render trước khi đọc xong cờ persist |
| **Cơ chế** | `Positioned.fill(child: OnboardingOverlayScope())` trong `Stack` của menu; scope = `FutureBuilder(loadOnboardingCompleted)` → `ChangeNotifierProvider` overlay-scoped; VM giữ queue `List<OnboardingStepState>` (`listEquals` + `List.unmodifiable`), tự subscribe `onboardingCompletedStream` để clear |
| **Ai sở hữu** | tầng thứ tư: app (repos) → screen (`MenuViewModel`) → dialog (`SettingsViewModel`) → overlay (`OnboardingViewModel`); cờ `onboarding_completed` sống trong repo, persist SharedPreferences |
| **Hướng dữ liệu** | `vm.nextStep`/`skipIntro` → `setOnboardingCompleted` → subject → stream → VM tự clear → `SizedBox.shrink` — ẩn là hậu quả của state, không phải `pop` |
| **Còn thiếu** | permission thật + lịch hẹn (FR-27 → M27); visual parity blur/AnimatedSwitcher/badge (FR-32 → M28) |

### Bước 10 — VM-owned session state machine + presentation mapper (M19)

| | |
|---|---|
| **Vấn đề giải quyết** | widget 600 dòng ôm 8 cụm state lỏng (phase/index/điểm/dialog/timer): tổ hợp vô nghĩa không bị ngăn, timer ràng lifetime widget, logic game không test được tách khỏi UI |
| **Cơ chế** | `GameSessionState` bất biến (`copyWith` + `clear*` flag) giữ `phase` enum 6 giá trị; `GameScreenViewModel` dispatch qua method có guard (`phase != playing → return`), sở hữu `Timer.periodic` + `Future.delayed` với `flowToken` vô hiệu callback lỗi thời; `buildGameScreenPresentation` thuần suy `GameScreenData`; event bridge → `showDialog`/`pop`; `PopScope(canPop:false)` route back theo `dialogState` |
| **Ai sở hữu** | tầng screen thứ hai theo kiểu senior: VM chứa *mọi* quyết định game; widget chỉ render DTO + forward ý định; `AppNavigationController` (navigatorKey) điều hướng không context; `main()` khóa `portraitUp` |
| **Hướng dữ liệu** | tap → `vm.submitAnswer` → `copyWith(phase: answeredPending)` → `notifyListeners` → `watch` rebuild → 1.5s `flowToken`-guarded reveal → `answeredRevealed` → 1s → `GameExplanationDialog` event → bridge `showDialog` → dismiss → `playing`/`gameOver`/`victory` |
| **Còn thiếu** | lifelines + `usedFeatureButtons`/`visibleOptionTexts` (M20); dialog trong `Stack` thay `showDialog` (M21, FR-07); VM-side save thay pop-result (M22, FR-04); DRE reducer thay method-dispatch (M26) |

### Bước 11 — Lifelines: state sở hữu "quyền dùng-một-lần" (M20)

| | |
|---|---|
| **Vấn đề giải quyết** | màn chơi thiếu 3 trợ giúp + walk-away của senior; "mỗi quyền dùng một lần" không thể là bool trên widget — phải là luật game do state sở hữu, sống cả ván qua mọi câu hỏi |
| **Cơ chế** | `usedFeatureButtons: Set<GameFeatureButtonType>` immutable trên `GameSessionState` (ghi `{...used, type}` trong `copyWith`); `handleFeatureClick` kiểm hai lớp (`button.isEnabled` → `_canUseFeature` phase+used+walkAway-amount); `visibleOptionTexts` là bản copy có thể biến đổi (50:50 ghi `''`, bank gốc nguyên); `audiencePercentiles` = `Map<text,int>` hợp sẵn với ô trống (0% miễn phí); `_GameDialogHost` đọc `dialogState` *live* qua `ListenableBuilder` để AI dialog đổi loading→result trong một route; `resolvedResult` chốt `won`/`earned` tại transition (walk-away = `victory` phase + `won:false`) |
| **Ai sở hữu** | VM sở hữu sổ đã-dùng + mutation + token/`_schedule` guard cho emit trễ; mapper suy `isEnabled`/`audiencePercentile` vào DTO; widget render `isEnabled` + forward `handleFeatureClick` — không giữ trạng thái |
| **Hướng dữ liệu** | tap nút → `handleFeatureClick` → `_canUseFeature` → `copyWith(usedFeatureButtons + type, …)` → mapper rebuild `isEnabled:false` → nút mờ; AI: emit loading → `Future.delayed(700ms)` → guard `is!` + token → emit result trên **cùng dialogState slot** → host rebuild route đang mở |
| **Còn thiếu** | visual nút = `IconData` phẳng thay painter/SVG (FR-34 → M28); dialog vẫn `showDialog` route (in-`Stack` layer M21); `resolvedResult` là interim carrier — persist qua repository ở M22; DRE reducer M26 |

### Bước 12 — In-`Stack` dialog layer + PopScope back choreography (M21)

| | |
|---|---|
| **Vấn đề giải quyết** | `showDialog` route ôm riêng cơ chế hiển thị: event `GameDialogRequested` một-lần phải "đuổi kịp" route, back hệ thống pop route-dialog thay vì hỏi máy trạng thái, transition route không biết variant |
| **Cơ chế** | `GameDialogLayer` = child cuối của `Stack` màn: `Positioned.fill` → `IgnorePointer(ignoring: Hidden)` → `AnimatedSwitcher(300ms, easeOut/InCubic, ValueKey(runtimeType))` → `_DialogBackdrop` (`ClipRect`→`BackdropFilter σ16`→`ColoredBox`→`Stack[opaque GD, SafeArea→Center→ConstrainedBox(375)]`) → 9 view callback-style; `PopScope(canPop:false, onPopInvokedWithResult)` → `_handleRouteBack` chia 3 nhánh theo `dialogState`; `_afterExit` chờ terminal animate-out rồi mới `goBack`/`playAgain`; `GameDialogRequested` + `_GameDialogHost` + `_showCurrentDialog`/`_dialogOpen` retired — `GameScreenUiEvent` chỉ còn `GameNavigateToMenuEvent` |
| **Ai sở hữu** | `dialogState` vẫn VM-owned (A-18); layer chỉ *render* state + forward callback; back-policy nằm ở bridge theo bảng: Hidden→confirm-exit, Ladder/Ended/Victory→ignore, còn lại→dismiss |
| **Hướng dữ liệu** | `copyWith(dialogState: X)` → `notifyListeners` → `watch` rebuild `GameDialogLayer(dialog: X)` → switcher swap theo `ValueKey(runtimeType)` → action nút gọi VM trực tiếp (không `pop(result)`) |
| **Còn thiếu** | `goBack(GameResult)` vẫn là transport kết quả — VM-side `GameSaveResult` + profile progression ở M22 (FR-03/FR-04); `onShare` terminal → M27 (FR-33); `GameDialogShell` chrome (gradient/sheen/`QzdsGameButton`) → M28 (FR-32/FR-34); menu `showDialog` → M29; DRE reducer → M26 |

### Bước 13 — Save kết quả trong VM + `LevelConfig` progression (M22)

| | |
|---|---|
| **Vấn đề giải quyết** | `Navigator.pop(GameResult)` để menu save là đường phụ sai ownership (result có thể mất cùng route); curve EXP learner (`correctAnswers × 50`, tăng ×1.5 mỗi cấp) sai hẳn senior; `expForNextLevel` là field lưu-thừa |
| **Cơ chế** | `_emitWithSaveResult(next, earnedAmount, isWin)` tại 4 transition kết thúc (victory/gameOver/walkAway/backToMenu): check `_state.hasSavedResult` → emit `next.copyWith(hasSavedResult: true)` + `unawaited(_saveGameResult(…))`; `_saveGameResult` load profile → `+moneyWon/+gainedExp=earnedAmount` → `_applyLevelProgression` (`while` đốt `LevelConfig.getExpRequiredForLevel`, clamp 1..100) → `+gamesJoined/+gamesWon?/+totalQuestionCount` → repo save; `_syncSavedGameResult` là stub `debugPrint` (M25) |
| **Ai sở hữu** | VM-side save boundary (A-22) — transition sở hữu persistence, cờ sống trong `GameSessionState`; `MenuLevelProgress.fromProfile` (D-39) suy `requiredExp`/`ratio`/`tier` từ profile thô — menu không còn đọc `expForNextLevel`/`expPercent`; `UserProfileData` về đúng 9 field senior |
| **Hướng dữ liệu** | transition → `_emitWithSaveResult` → save (fire-and-forget) → repo `BehaviorSubject` emit → `MenuViewModel` → `_LevelCard` rebuild với `progress.ratio`/`formatted*` — route pop chỉ là `goBack()` trần |
| **Còn thiếu** | sync thật (`_syncSavedGameResult`) → M24/M25; DRE `GameSaveResult` asyncOp thay `unawaited` call → M26; `shareResult` → M27; `LevelProgressCard` ring/glass/tier + `menuMaxLevelReached` label → M28 (max-level hiện lộ `maxExpRequirement` thô — cosmetic sót) |

### Bước 14 — Remote repository sau contract: local → remote impl (M23)

| | |
|---|---|
| **Vấn đề giải quyết** | mọi repository trước M23 đều local (SharedPreferences trên một máy); bảng xếp hạng theo bản chất là dữ liệu nhiều-người → nguồn data phải chuyển từ static/local sang remote mà UI/VM không đổi một dòng; thiếu config vẫn phải chạy được chứ không crash |
| **Cơ chế** | `SupabaseClientService.initialize` → `SupabaseClient?` sentinel; `main()` chọn impl duy nhất một chỗ `client == null ? DisabledLeaderboardRepository : SupabaseLeaderboardRepository` (A-24) sau cùng contract `LeaderboardRepository` (A-23); `LeaderboardDialogViewModel` render 4 variant `LeaderboardPopupState` sealed + `isRefreshing`; `_requestId` monotonic stale guard (D-42) chặn response cũ ghi đè |
| **Ai sở hữu** | `main()` sở hữu lựa chọn impl — app-scope, đăng ký `Provider<LeaderboardRepository>.value` theo kiểu contract; `LeaderboardDialogViewModel` (dialog-scope) sở hữu load/refresh/retry + stale guard; repo sở hữu query chain `select/order/limit/eq` + `maybeSingle` + row mapping phòng thủ |
| **Hướng dữ liệu** | menu row tap → `MenuLeaderboardRequested` → `showLeaderboardDialog` → VM `load()` → repo → Supabase view `public.leaderboard` (hoặc static khi Disabled) → `LeaderboardSnapshot` → popup states → UI; pull-to-refresh/`retry()` đi cùng đường, qua `_requestId` guard |
| **Còn thiếu** | `AuthRepository` + uid thật cho `.eq('auth_uuid',…)` → M24; ghi/sync `public.users` → M25; DRE asyncOp/cancel thay `_requestId` guard → M26; rank badge/avatar/`LeaderboardRowStyle` parity senior → M28; `MenuDialogLayer` thay `showDialog` transport → M29 |

### Bước 15 — Auth session stream: guest ↔ authenticated (M24)

| | |
|---|---|
| **Vấn đề giải quyết** | identity là *state* — "bạn là ai" đứng đó cho tới khi đổi — không phải một màn đăng nhập hay một route; trước M24 mọi người chơi đều là guest vô danh: cần "session hiện tại" ở boundary mà pill/leaderboard/sync cùng đọc, và guest phải là giá trị chính danh chứ không phải `null`/`User?` vắng mặt |
| **Cơ chế** | sealed `AuthSessionData` (`AuthSessionGuest` / `AuthSessionAuthenticated{uid,email,displayName,photoUrl}` + `isAuthenticated`) trên `authStateStream` — `BehaviorSubject` seeded đúng pattern M14 (Disabled: `AuthSessionGuest`; impl: seed `client.auth.currentUser`, `onAuthStateChange`→emit, `onError`→Guest); `AuthActionResult` value-type (private ctor `._` + redirecting `.success`/`.failure`) mang "outcome một lần của action" — tách bạch khỏi state stream; conditional DI `main()` chọn `DisabledAuthRepository`/`AuthRepositoryImpl` duy nhất một chỗ (nhánh A-24 của M23) |
| **Ai sở hữu** | `AuthRepository` sở hữu session stream + 6 method (contract); `main()` sở hữu lựa chọn impl — `DisabledAuthRepository` trả guest + `configurationError` khi thiếu dart-define, `AuthRepositoryImpl` bọc Supabase/Google v7 khi đủ config; `MenuAuthActionCoordinator` sở hữu chuỗi post-action `signIn*→loadAuthState→guard→syncUserProfile` và `signOut→resetUserProfile` một chỗ; hai dialog-scoped VM sở hữu `_isLoading` single-flight + `SnackBar`/`Dismiss` event |
| **Hướng dữ liệu** | pill tap → `requestAuthAction` route theo session (guest → `MenuAuthRequested` → auth dialog; authed → `MenuSignOutRequested` → sign-out dialog) → dialog VM gọi coordinator → repo method → `authStateStream` emit → `MenuViewModel` (seed + sub) → pill/menu re-render; sign-out success → `resetUserProfile` → profile stream về mặc định → pill về "Khách" |
| **Còn thiếu** | `UserProfileSyncRepositoryImpl` ghi/merge `public.users` + emit `ProfileSyncStateData` → M25 (Disabled no-op giữ call-site đúng); `showDialog` transport → `MenuDialogLayer` + `MenuDialogAuth`/`MenuDialogSignOut` state → M29; DRE `asyncOp`/cancel thay `_isLoading` tay → M26; verify provider sống — `LIVE_AUTH_FLOW: NOT_PERFORMED` |

### Bước 16 — Sync local ↔ remote: fetch → merge → upsert (M25)

| | |
|---|---|
| **Vấn đề giải quyết** | profile local phải đối chiếu với row `public.users` mà không mất tiến trình nào — hai nguồn sự-thật (SharedPreferences vs remote row) có thể lệch theo mọi hướng: đổi máy, cài lại, chơi offline dài; seam `UserProfileSyncRepositoryDisabled` của M24 chỉ là no-op giữ chỗ |
| **Cơ chế** | `AppUserData` boundary DTO (8 field theo cột, `fromMap`/`fromProfile`/`toUpsertMap`/`toProfile` — dịch hai namespace cột snake ↔ field domain) + `mergeUserProfileForSync` hàm thuần: leader=level/exp tiebreak nguyên khối, totals=max từng field, session identity thắng, `gamesWon` local-only, `_withoutDemoProgression` chặn tiến trình demo lên remote + `UserProfileSyncRepositoryImpl` (`_isSyncing` guard chặn re-entrancy, `maybeSingle` fetch, `upsert(onConflict:'auth_uuid')`) + conditional DI `main()` ternary lần ba |
| **Ai sở hữu** | `UserProfileSyncRepository` — `Impl` khi `supabaseClient != null`, `Disabled` no-op khi unconfigured; merge function là pure policy không sở hữu ai; `_syncSavedGameResult` trong game VM sở hữu nhánh post-save best-effort (authed→sync, guest→skip, lỗi→nuốt+log) |
| **Hướng dữ liệu** | sign-in thành công (coordinator) / save kết quả ván (game VM) → `syncUserProfile(session)` → `ProfileSyncInProgress` → load local → fetch `public.users` by `auth_uuid` (`maybeSingle`) → merge → save local TRƯỚC → upsert remote `onConflict:'auth_uuid'` → `ProfileSyncIdle`; catch → `Failed` + rethrow (caller quyết nuốt hay nổ) |
| **Còn thiếu** | DRE `asyncOp`/cancel thay `_isSyncing` + try/catch tay → M26; visual polish → M28; `MenuDialogLayer` thay `showDialog` transport → M29; verify provider/database sống — `LIVE_PROFILE_SYNC: NOT_PERFORMED` (merge/schema/call-path tests gánh verify) |

### Bước 17 — DRE: transition thành reducer thuần, side-effect thành data (M26)

| | |
|---|---|
| **Vấn đề giải quyết** | VM 733 dòng trộn bốn chủng việc — transition `copyWith`, timer/delay tay (`_schedule` + `flowToken` guard ngoài method), repo save `unawaited`, event stream; mỗi delayed callback phải tự guard bằng `_isDisposed` + token so sánh tay (và bản M19–M25 bỏ sót so-sánh token ở reveal/explanation — chỉ check phase); mọi transition trực tiếp gọi `_stopTimer`/`_emit`/`_schedule` → luồng điều khiển rải khắp VM, khó test bằng hàm thuần |
| **Cơ chế** | `DreChangeNotifier<GameState, GameAction, GameEffect, GameAsyncOp>`: `dispatch(action)` → `reducer.reduce(state, action)` trả `DreResult{state, effects, asyncOp}` → swap state → `notifyListeners()` chỉ khi instance đổi → đẩy effects vào broadcast stream → `unawaited(executeAsyncOp(op, postReduceSnapshot))`; `GameReducer` chia 4 `part` file theo flow domain (session/answer/feature/timer) với private `extension`; `flowToken` sống TRONG `GameState` — `*Elapsed` actions mang token chụp lúc schedule, reducer no-op khi `flowToken != state.flowToken` (stale = action bị loại, không phải exception); `_withSaveResult` set `hasSavedResult` + emit `GameSaveResult` op đúng một lần |
| **Ai sở hữu** | reducer = mọi transition + guard + chấm điểm (thuần, test không cần Flutter); VM = timer/future/repo/stream plumbing (`_handleEffect` bridge part file, `executeAsyncOp` switch → `_saveGameResult`); repository = persistence; UI = render `screenData`/`dialogState` + forward taps (không đổi một dòng) |
| **Hướng dữ liệu** | UI tap → `dispatch(GameAction)` → `DreResult` → state mới (notify) + effects → bridge: `GameStartTimer/Pause/Stop` → `_timer` cancel/periodic, `GameSchedule*` → `Future.delayed` → re-dispatch `*Elapsed(token)` (guard `_isDisposed`), `GameNavigateToMenu` → `_events`; asyncOp `GameSaveResult` → `_saveGameResult` → `_syncSavedGameResult` (M25 y nguyên) |
| **Còn thiếu** | share plumbing (`GameShareRequested`/`GameShareResult`/`GameShareResultEvent`/`shareResult`) → M27 (FR-33); notification/share/package_info → M27; visual polish → M28; `MenuDialogLayer` → M29 |

### Bước 18 — Platform boundary: contract → impl → plugin → OS (M27)

| | |
|---|---|
| **Vấn đề giải quyết** | Ba "lỗ hổng platform": notification toggle ghi flag nhưng không ai lên lịch; onboarding giả vờ OS luôn đồng ý (`onNotificationPermissionResult(true)` inline — FR-27); dialog kết thúc không có share (FR-33) |
| **Cơ chế** | `LocalNotificationService` contract 5 method → `LocalNotificationServiceImpl` bọc `flutter_local_notifications` + `timezone`/`flutter_timezone` (`tz.setLocalLocation`, UTC fallback); `zonedSchedule` id 1001 + `DateTimeComponents.time` + `inexactAllowWhileIdle` + `_nextDailyTime` rollover; permission qua `resolvePlatformSpecificImplementation` + `!kIsWeb` fallback; `SettingsNotificationCoordinator` = "làm-việc-OS trước, save sau, hỏng thì hoàn-tác-best-effort" (enable: schedule→save / disable: cancel→save / updateTime: conditional-reschedule); `_hasNotificationPermission` trong VM state — `effectiveNotificationEnabled` = flag AND permission |
| **Ai sở hữu** | widget = forward tap + đọc `effectiveNotificationEnabled`; VM = permission state + orchestrate qua coordinator; coordinator = chuỗi schedule/save + rollback; service contract = ranh giới duy nhất plugin được chạm; `PackageInfo.fromPlatform` qua `loadAppVersion` seam → `v$appVersion` |
| **Hướng dữ liệu** | toggle → `requestPermission` → denied: persist-off + `notificationPermissionRequired` snackbar / granted: `coordinator.enable` → `scheduleDaily` → `saveUserSettings`; share tap → `dispatch(GameShareRequested)` → reducer → `GameShareResult` effect → bridge → `GameShareResultEvent` → screen `SharePlus.instance.share(ShareParams(text, sharePositionOrigin))` → catch → `Clipboard.setData` + snackbar |
| **Còn thiếu** | `_DialogShareButton` scaffold — senior `GameDialogButton`/`shareColor` + toàn bộ visual polish → M28; `MenuDialogLayer` → M29; `REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` — fake counters + seam gánh verify, receiver manifest verbatim senior nhưng chưa device-test |

### Bước 19 — Visual parity: token một-nguồn + painter/controller sở hữu motion (M28)

| | |
|---|---|
| **Vấn đề giải quyết** | Game chạy đúng nhưng *trông* không giống senior: timer là text phẳng (field `timerProgress` đã có nhưng không ai render), money là text thường (`animationTrigger` tồn tại không consumer), lifeline = `IconData` trên nền phẳng, dialog = container `MenuTokens` tự chế; màu/khoảng-cách/cỡ chữ rải rác — không có nguồn-đúng-duy-nhất |
| **Cơ chế** | `AppTokens` (318d, `GoogleFonts` type ramp + `QzdsButtonScale` + gradients + `screenDesignWidth=375`) + `AppAssets` subset-8 const → `DesignFrame` cap-bề-rộng; `AnimationController`×2 trên timer: progress-tween (1s, `didUpdateWidget` forward-vs-snap) + critical-pulse (`repeat(reverse)`, bounds 1.0→1.08, chỉ khi `progress ≤ 0.2`); `_PillProgressPainter` vẽ stadium `Path` + gradient stroke (`extractPath`/`computeMetrics` cho dash); `GameMoneyAmountMotion` — chỉ animate khi `animationTrigger > oldTrigger` (đổi amount thường → snap), 260ms count + glitch `ShaderMask`; `GameFeatureButton` painter rotating-gradient + ripple controller + `SvgPicture.asset(iconAsset)`; `GameDialogShell` (BackdropFilter scrim + `headerSheen` + `title.toUpperCase()`) + `QzdsGameButton`/`GameDialogButton`/`GameDialogMoneyRow`; reduce-motion đúng-chỗ-senior-có (`MediaQuery.disableAnimations → Duration.zero` ở money/dialog/blink — pulse timer + sheen nút *không* honor, verbatim parity) |
| **Ai sở hữu** | `AppTokens`/`AppAssets` = nguồn duy nhất màu/cỡ/motion/asset-path (A-38); `AnimationController` sống trong `State` + `vsync` + `dispose` (widget sở hữu motion, VM không biết); painter sở hữu *vẽ* (không widget-tree); mapper vẫn sở hữu data (icon → `iconAsset` path — DTO đổi `IconData`→`String` là boundary đổi duy nhất) |
| **Hướng dữ liệu** | state→mapper→DTO (`timerProgress`/`animationTrigger`/`iconAsset` đã có từ M19–M20, M28 mới *render* chúng) → `didUpdateWidget` đọc prop-mới → controller `forward(from:0)` hoặc snap → `AnimatedBuilder`/painter rebuild — VM không đổi một dòng (visual là lớp cuối của pipeline đã đúng) |
| **Còn thiếu** | `MenuTokens` → `AppTokens` migration cho menu widgets + `SettingItemData.iconAsset`/`_SettingIconBadge` (FR-30) + `_SettingsAccountRow` chrome (FR-28-residual) + onboarding visuals `OnboardingTokens`/`BackdropFilter`-scrim/`AnimatedSwitcher`-indicator (FR-32) + `MenuDialogLayer` transport + full asset parity → **M29 final sweep**; `REAL_DEVICE_VISUAL_CHECK: NOT_PERFORMED` |

### Bước 20 — Senior alignment sweep: menu dialog layer + fidelity zero-debt (M29)

| | |
|---|---|
| **Vấn đề giải quyết** | Game đã có dialog in-`Stack` từ M21 nhưng *menu* vẫn mở dialog bằng `showDialog` route + 4 event một-lần (`MenuSettingsRequested`…) — hai cơ chế cho cùng một ý định; đồng thời còn sót mọi simplification đã-ghi-nợ: `SettingItemData.icon` (IconData), leaderboard thiếu avatar/rank assets, onboarding visual rút gọn, `MenuTokens` shim, 31 ARB value khác casing-convention senior |
| **Cơ chế** | `MenuDialogState` sealed 5-variant (`None/Leaderboard/Settings/Auth/SignOut`, `transitionKey=runtimeType`) sống trong `MenuScreenViewModel.dialogState` — dialog là *state*, không phải event; `MenuDialogLayer` trong `Stack` render scope qua `AnimatedSwitcher` `ValueKey(transitionKey)`; `MenuScreenView` `PopScope(canPop: !isVisible)` + `_dialogDismissLocked` cho sign-out loading; `menu_screen.dart` 87d giữ đúng 2-event bridge (`MenuGameRequested`/`MenuSnackBarRequested`); `requestAuthAction` = duy nhất dispatch còn lại: session quyết Auth-vs-SignOut |
| **Ai sở hữu** | VM sở hữu `dialogState` (mọi `requestXxx` chỉ set state); view sở hữu dismiss-lock + PopScope wiring; scope×4 sở hữu dialog-lifetime VM (A-15); `AppTokens` sở hữu mọi giá trị visual (`MenuTokens` đã xoá — zero reference); `AppAssets` 45 consts = mọi đường-dẫn asset |
| **Hướng dữ liệu** | tap → `viewModel.requestSettingsDialog()` → `_dialogState = MenuDialogSettings` → `notifyListeners` → `MenuDialogLayer` rebuild switch → `MenuSettingsDialogScope` mount → dialog VM `loadSettings`; back/outside-tap → `dismissCurrentDialog()` → `MenuDialogNone` → unmount; dismiss-lock chỉ chặn *dismiss*, không chặn emit |
| **Còn thiếu** | không còn simplification được ghi nợ — `lib/` ⊆ `lib/` senior (6 preview catalog cố ý không port); `REAL_DEVICE_*`/`LIVE_*` `NOT_PERFORMED` vẫn đứng (course-level documented) |

## Hai stream trong cùng một VM — cuối M14

| | `userProfileStream` | `events` |
|---|---|---|
| Mang | **state** | **event** |
| Loại | `BehaviorSubject` → `ValueStream` | `StreamController.broadcast` |
| Subscriber mới | replay giá trị mới nhất | bỏ lỡ event đã bắn |
| Trả lời | "bây giờ là gì?" | "vừa xảy ra gì?" |
| Ai subscribe | VM (ctor) | widget bridge (`didChangeDependencies`) |

## Câu hỏi tự kiểm sau khi đọc

1. Vì sao `setState` không đủ khi state cần chia giữa hai màn?
   — *State kẹt trong một `State` object; màn khác không chạm tới.*
2. `ChangeNotifier` giải quyết gì, và nó *không* giải quyết gì? —
   *Tách state khỏi widget (test được); không giải quyết ai sở
   hữu/làm sao tra — đó là Provider.*
3. Event stream của M13 khác state stream của M14 ở *thời điểm* nào?
   — *Subscriber trễ: event → miss; state → replay `.value`.*
4. Trong chuỗi này, "ai sở hữu state" di chuyển thế nào? —
   *`State` → `ChangeNotifier` → Provider tree → repository —
   mỗi bước đẩy state ra xa UI hơn một tầng.*

:::tip[Liên hệ]
Tra từng concept theo bài dạy tại [Tra cứu concept](/concepts/).
:::
