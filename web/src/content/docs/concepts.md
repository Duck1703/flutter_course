---
title: Tra cứu concept
description: "Index các concept Dart/Flutter đã dạy trong course — mỗi mục link về bài dạy đầu tiên và các bài củng cố."
sidebar:
  label: Tra cứu concept
  order: 3
---

Trang này tra ngược: gặp một khái niệm trong code mà quên nó được dạy
ở đâu → tìm ở đây → nhảy về bài dạy. Không phải từ điển — mỗi mục
chỉ ghi *ý nghĩa ngắn* + *link về nơi dạy nó*. Muốn hiểu sâu, đọc bài
đó, đừng đọc trang này.

## Nền widget

| Concept | Nghĩa một câu | Dạy ở | Củng cố ở |
|---|---|---|---|
| `Widget` / cây widget | UI = cây widget immutable, `build` vẽ lại | [M01/02](/m01/02-main-runapp-va-cay-widget/) | mọi bài |
| `BuildContext` | "địa chỉ" của widget trong cây — tra cha/lên trên | [M01/02](/m01/02-main-runapp-va-cay-widget/) | M03, M11, M12 |
| `StatelessWidget` | widget không state — chỉ render theo props | [M01/02](/m01/02-main-runapp-va-cay-widget/) | M02, M03 |
| `StatefulWidget` + `State<T>` | widget có state sống lâu hơn frame | [M03/01](/m03/01-stateless-va-stateful/) | M03–M13 |
| `setState` | báo "State này dirty" → rebuild | [M03/01](/m03/01-stateless-va-stateful/) | M03–M11 |
| `initState`/`dispose`/`didChangeDependencies` | lifecycle của `State` | [M03/03](/m03/03-lifecycle-callbacks-va-state-ownership/) | M06, M13, M14 |
| Ownership (ai sở hữu state) | field sống trong `State` — con chỉ nhận value+callback | [M03/03](/m03/03-lifecycle-callbacks-va-state-ownership/) | M06, M11 |
| `Expanded`/`Flexible` | chia phần còn lại của Row/Column theo flex | [M02](/m02/) | M09 |
| `BuildContext` trong `build` | `watch`/`read`/`of` tra lên cây | [M02](/m02/) | M12–M14 |
| `Switch` (controlled) | `value` từ data, `onChanged` báo lên — không tự giữ state | [M16/04](/m16/04-settings-dialog-ui/) | — |
| `HitTestBehavior.opaque` | bấm cả vùng "trống" của hàng | [M16/04](/m16/04-settings-dialog-ui/) | — |
| `ListWheelScrollView` + `FixedExtentScrollController` | picker cuộn snap-item; controller phải sống trong `State` | [M16/05](/m16/05-time-picker-synthesis/) | M27 |
| `MaterialApp.locale` + `localizationsDelegates` + `supportedLocales` | app chọn bản dịch theo `locale`; `AppLocalizations.of(context)` tra chuỗi — thiếu delegates là throw | [M17/02](/m17/02-arb-gen-l10n-setup/), [M17/03](/m17/03-materialapp-locale-streambuilder/) | M18+ |
| Overlay trong `Stack` (không route) | `Positioned.fill` + `HitTestBehavior.opaque` — visibility là state, không phải navigation | [M18/01](/m18/01-vi-sao-overlay-khong-phai-route/), [M18/04](/m18/04-overlay-scope-va-menu-stack/) | M21, M28 |
| `RefreshIndicator.adaptive` + `AlwaysScrollableScrollPhysics` | pull-to-refresh trên list remote — `onRefresh` nhận Future; physics cho phép overscroll kể cả khi list ngắn | [M23/05](/m23/05-dialog-va-menu-row/) | M28+ |

## Model & Dart

| Concept | Nghĩa một câu | Dạy ở | Củng cố ở |
|---|---|---|---|
| `final`/`const` field | bất biến sau construction | [M04](/m04/) | mọi model |
| `copyWith` | "đổi" immutable = tạo object mới vài field khác | [M04](/m04/) | M10, M14 |
| `==`/`hashCode` | so *giá trị* chứ không identity | [M04](/m04/) | M14 (`value !=` guard) |
| `toMap`/`fromMap` | serialize model ↔ Map cho JSON | [M10/02](/m10/02-json-tomap-frommap/) | M14 (FR-19) |
| `factory` ctor | constructor được `return` instance (có thể có sẵn / tính trước) | [M10/02](/m10/02-json-tomap-frommap/) | M14/02 (`create()`) |
| `static Future create()` | factory static cho construction async | [M14/02](/m14/02-contract-abstract-interface-implements/) | M14/04–06 |
| `abstract interface class` | class thuần chữ ký — contract | [M14/02](/m14/02-contract-abstract-interface-implements/) | M14/04–07 |
| `implements` vs `extends` | cam kết member, không thừa hưởng code | [M14/02](/m14/02-contract-abstract-interface-implements/) | mọi impl/fake M14 |
| null-aware `?value` trong map | bỏ key khi null (Dart 3.8) | [M14/05](/m14/05-hai-repo-con-lai-va-model-parity/) | `toMap` |
| `sealed class` | tập subtype đóng — chỉ khai báo được cùng file | [M15/02](/m15/02-sealed-class/) | M15/04–05 |
| `final class` | variant lá — cấm extends/implement thêm | [M15/02](/m15/02-sealed-class/) | M15/04–05 |
| `switch` expression + object pattern `(:final f)` | switch trả giá trị + bóc field ngay trong case | [M15/03](/m15/03-switch-kiet-hop-pattern/) | M15/04–05 |
| wildcard `_` pattern | "mọi thứ còn lại" — vẫn kiệt hợp | [M15/03](/m15/03-switch-kiet-hop-pattern/) | M15/05 |
| `runtimeType` | kiểu runtime của object (senior dùng làm key) | [M15/03](/m15/03-switch-kiet-hop-pattern/) | M21 |
| `enum` làm dispatch key | gắn "loại" vào data — switch biết xử lý cái gì | [M16/02](/m16/02-setting-item-data-factory/) | M16/04 |
| collection-`if` trong list | phần tử chỉ *tồn tại* khi điều kiện đúng | [M16/02](/m16/02-setting-item-data-factory/) | M16/04 |
| `String.padLeft` | format 2 chữ số (`'7'`→`'07'`) | [M16/02](/m16/02-setting-item-data-factory/) | — |
| `late`/`late final` | field gán muộn — trong thân ctor sau khi field khác sẵn | [M16/03](/m16/03-settings-view-model-dialog-scoped/) | M18 |
| file `.arb` + `@key` placeholder | resource chuỗi cho gen-l10n; `{x}` khai báo ở `@key`, `''` = escape nháy | [M17/02](/m17/02-arb-gen-l10n-setup/) | mọi surface M18+ |
| `RegExp`/`tryParse` phòng thủ | parse storage không tin được | [M10](/m10/) | M14/05 |
| `listEquals` + `List.unmodifiable` | so list theo phần tử + emit bản read-only — kỷ luật notify cho state dạng list | [M18/03](/m18/03-onboarding-view-model/) | M19 |
| `copyWith` + flag `clear*` | update immutable state nhiều field; flag tường minh phân biệt "không truyền" vs "truyền null" cho field nullable | [M19/02](/m19/02-data-game-moi-va-xe-man-cu/) | M20, M22, M26 |
| `Duration` + `Timer.periodic` trong VM | đồng hồ sống ở VM: pause = `cancel`, resume = tạo lại; `dispose` bắt buộc cancel | [M19/04](/m19/04-game-screen-view-model/) | M20+ |
| `FakeAsync`/`async.elapse` | đồng hồ ảo cho test — lái `Timer`/`Future.delayed` không chờ thật | [M19/04](/m19/04-game-screen-view-model/) | M20+ |
| `Set<T>` trên immutable state | tập "đã dùng" — ghi `{...old, x}`, bọc `Set.unmodifiable`; sổ quyền một-lần do state sở hữu | [M20/01](/m20/01-lifeline-la-luat-game/), [M20/02](/m20/02-du-lieu-va-helper-lifeline/) | M21+ |
| `firstWhere` | phần tử đầu khớp — ném `StateError` nếu không có (50:50 giữ ô sai đầu) | [M20/02](/m20/02-du-lieu-va-helper-lifeline/) | — |
| map-comprehension `{for …}` | build `Map` trong literal — `audiencePercentiles` keyed bằng text | [M20/02](/m20/02-du-lieu-va-helper-lifeline/) | M26 |
| `List.generate` + `String.fromCharCode` | list độ dài cố định + nhãn A–D từ code unit 65+i | [M20/02](/m20/02-du-lieu-va-helper-lifeline/) | — |
| `fold<int>` | gộp collection về một giá trị — test tổng % == 100 | [M20/02](/m20/02-du-lieu-va-helper-lifeline/) | — |
| Config-table progression | số game-design nằm trong `static const` map tra cứu (`LevelConfig._milestoneMultipliers`), không rải magic number; `while`-loop đốt ngưỡng từng cấp | [M22/02](/m22/02-level-config/) | M25, M28 |
| Derived view-model (`fromProfile`) | view-model suy `requiredExp`/`ratio`/`tier` từ profile thô qua `LevelConfig` — derived data để ở view, không lưu field trong model | [M22/03](/m22/03-menu-level-progress/) | M28 |
| `String.fromEnvironment` / `--dart-define` | hằng biên dịch trong `const` context — thiếu key → `''`/`defaultValue`; config là plumbing, không phải state; không `.env` | [M23/01](/m23/01-supabase-va-dart-define/) | M24, mọi remote sau |
| `sealed` union cho identity (`AuthSessionData`) | session = sealed `AuthSessionGuest`/`AuthSessionAuthenticated{uid,email,displayName,photoUrl}` + `isAuthenticated` — guest là variant chính danh, không phải `User?`/`null` | [M24/01](/m24/01-session-model/) | M24/03–05, M25+ |
| `AuthActionResult` result value-type | private ctor `._` + redirecting const ctor `.success`/`.failure` — "outcome một lần của action" tách khỏi state stream; caller đọc `isSuccess`/`message`, không try/catch | [M24/01](/m24/01-session-model/) | M24/03–04, M25 |
| `part`/`part of` + private `extension` | tách một library thành nhiều file chia sẻ import + private members; `extension _X on Class` trong part giữ method private nhưng tách theo domain — reducer 4 flow files, VM 2 bridge files | [M26/04](/m26/04-game-reducer/), [M26/05](/m26/05-vm-migration-va-bridges/) | M27+ |
| `abstract interface class` + generic bounds | marker interface rỗng `DreAction`/`DreEffect`/`DreAsyncOp` đóng vai "nhãn vai trò"; `DreReducer<S,A extends DreAction,E extends DreEffect,O extends DreAsyncOp>` kẹp kiểu tại generic — contract mở cho mọi domain, game chỉ là consumer đầu tiên | [M26/02](/m26/02-core-dre-primitives/) | M27+ |
| `if-case` trong switch-exhaustive (D-48) | pattern `if (x case Type(:field))` destructure trực tiếp trong điều kiện — tránh cast tay; dùng song song `switch` expression khi cần kiểm-tra-nhanh một variant | [M28/02](/m28/02-chrome-chung-pill-kinh-nen/) | M28+ |


## Async

| Concept | Nghĩa một câu | Dạy ở | Củng cố ở |
|---|---|---|---|
| `Future<T>` | "lời hứa có T (hoặc lỗi) về sau" | [M05/01–02](/m05/) | mọi repo M14 |
| `async`/`await` | pause *trong hàm* chờ Future | [M05/02](/m05/) | M10, M14 |
| `unawaited` | "cố ý không chờ" một Future | [M11/01](/m11/01-vi-sao-setstate-khong-scale/) | M13 event handler |
| `FutureBuilder` | widget render theo trạng thái Future | [M05](/m05/) | — |
| `WidgetsFlutterBinding.ensureInitialized` | bắt buộc trước khi `await` trong `main` | [M05/03](/m05/03-async-main/) | M14 bootstrap |
| Async-op boundary (`DreResult.asyncOp`) | tối đa MỘT op mỗi reduce; `executeAsyncOp(op, postReduceSnapshot)` chạy `unawaited`, lỗi → `onAsyncOpError` — boundary fire-and-forget, không loading/rollback framework | [M26/02](/m26/02-core-dre-primitives/), [M26/05](/m26/05-vm-migration-va-bridges/) | M27 |

## Stream

| Concept | Nghĩa một câu | Dạy ở | Củng cố ở |
|---|---|---|---|
| `Stream<T>` | nhiều event theo thời gian | [M06/01](/m06/01-stream-la-gi/) | M13, M14 |
| `StreamController` | đầu ghi của stream | [M06/03](/m06/03-listen-cancel-streamcontroller/) | M13 |
| `.broadcast` | nhiều listener, *không* replay | [M13/01](/m13/01-event-khong-phai-state/) | M14 |
| `StreamSubscription`/`cancel` | handle của listener — ai tạo ai hủy | [M06/03](/m06/03-listen-cancel-streamcontroller/) | M13, M14/07 |
| `StreamBuilder` | widget render theo stream | [M06/02](/m06/02-streambuilder-trong-menu/) | — |
| `BehaviorSubject` | controller giữ "giá trị hiện tại" + replay | [M14/03](/m14/03-stream-state-behavior-subject-value-stream/) | M14/04–07 |
| `.seeded` | subject có giá trị ngay từ đầu | [M14/03](/m14/03-stream-state-behavior-subject-value-stream/) | mọi repo |
| `ValueStream` | mặt đọc: `Stream` + `.value` | [M14/03](/m14/03-stream-state-behavior-subject-value-stream/) | mọi repo contract |
| `isClosed`/`close()` | guard emit + dọn subject | [M14/03](/m14/03-stream-state-behavior-subject-value-stream/) | M14/04 |
| `pumpEventQueue()` | flush microtask queue trong test | [M14/04](/m14/04-user-profile-repository-impl/) | M14/07 |
| `async*`/`yield` | **chưa dạy** — M06/03 chỉ liệt kê trong "cố ý chưa làm" | — | — |
| Effects stream → bridge | reducer trả `List<GameEffect>` (data ý định); broadcast `effects` stream + `_handleEffect` switch biến mỗi variant thành `Timer`/`Future.delayed`/event — intent tách khỏi execution | [M26/05](/m26/05-vm-migration-va-bridges/) | M27 |

## Kiến trúc

| Concept | Nghĩa một câu | Dạy ở | Củng cố ở |
|---|---|---|---|
| `ChangeNotifier`/`notifyListeners` | object giữ state + báo "đổi rồi" | [M11](/m11/) | M12–M14 |
| `ListenableBuilder` | widget rebuild khi Listenable notify | [M11](/m11/) | — |
| `Provider`/`Provider.value` | đặt dependency vào cây widget | [M12](/m12/) | M13, M14 |
| `context.read`/`watch` | tra (không rebuild) vs subscribe (rebuild) | [M12](/m12/) | M13, M14 |
| `MultiProvider` | shortcut gom nhiều provider lồng nhau | [M14/06](/m14/06-di-theo-contract-multiprovider-va-fake/) | — |
| DI theo contract | đăng ký `Provider<Interface>` — impl ngồi dưới | [M14/06](/m14/06-di-theo-contract-multiprovider-va-fake/) | M14/07 |
| Repository boundary | "ai đọc/ghi + ai nghe đổi" — khác storage | [M14/01](/m14/01-vi-sao-profilestore-chua-du/) | M14/04–07 |
| Event vs State stream | broadcast event ≠ seeded state | [M13/01](/m13/01-event-khong-phai-state/), [M14/03](/m14/03-stream-state-behavior-subject-value-stream/) | M14/07, [M15/04](/m15/04-seal-event-bridge/) (sealed vẫn tách hai vai trò) |
| Fake repository | `implements` contract cho test | [M14/06](/m14/06-di-theo-contract-multiprovider-va-fake/) | M14/07 |
| Sealed state family | tập đóng các variant UI — state chứ không cờ | [M15/01](/m15/01-vi-sao-state-dong/), [M15/02](/m15/02-sealed-class/) | M15/05 |
| State-driven UI | UI hỏi "đang ở variant nào" rồi render | [M15/01](/m15/01-vi-sao-state-dong/), [M15/05](/m15/05-gamedialogstate-state-driven-ui/) | M19, M21 |
| Vòng lặp persist | toggle→VM→repo.save→subject→stream→rebuild | [M16/01](/m16/01-vi-sao-settings-persist/) | M17, M18 |
| Dialog-scoped VM | `ChangeNotifierProvider` trong subtree dialog = VM chết cùng dialog | [M16/03](/m16/03-settings-view-model-dialog-scoped/) | M21 |
| Locale = derived state ở app-root | `StreamBuilder` trên settings stream lái `MaterialApp.locale` — đổi ngôn ngữ không restart | [M17/03](/m17/03-materialapp-locale-streambuilder/) | M18 |
| UI sở hữu chữ (VM context-free) | widget đọc `l10n` rồi truyền chuỗi vào VM/factory qua tham số — VM không `of(context)` | [M17/04](/m17/04-di-chuyen-chu-sang-l10n/) | — |
| Overlay-scoped VM (tầng lifetime thứ tư) | `ChangeNotifierProvider` trong subtree overlay — VM sinh/chết cùng overlay; app → screen → dialog → overlay | [M18/03](/m18/03-onboarding-view-model/), [M18/04](/m18/04-overlay-scope-va-menu-stack/) | M21, M28 |
| Máy trạng thái session (enum phase) | một `enum` phase loại trừ lẫn nhau + transition có guard trong VM — thay nắm boolean lỏng | [M19/01](/m19/01-vi-sao-widget-khong-giu-noi-game/), [M19/04](/m19/04-game-screen-view-model/) | M20, M21, M26 |
| Presentation mapper | hàm thuần state→DTO (`buildGameScreenPresentation` → `GameScreenData`); UI render, không tự suy | [M19/03](/m19/03-mapper-state-sang-screen-data/) | M20, M26 |
| `flowToken` anti-stale | token đơn điệu tăng trong state — delayed callback tự vô hiệu khi phiên đổi, thay cho việc hủy `Future` | [M19/04](/m19/04-game-screen-view-model/) | M20, M26 |
| Feature gate hai lớp | mapper suy `isEnabled` vào DTO + VM kiểm lại `_canUseFeature` theo state — belt-and-suspenders senior | [M20/01](/m20/01-lifeline-la-luat-game/), [M20/03](/m20/03-nam-muoi-nam-muoi-va-hoi-khan-gia/) | M21, M26 |
| `resolvedResult` (chốt kết quả tại transition) | phase không đủ suy `won`/`earned` — walk-away vào `victory` nhưng `won:false`; interim carrier tới VM-save M22 | [M20/04](/m20/04-hoi-ai-va-dung-cuoc-choi/) | M22 |
| Dialog một-route-hai-hình | variant mang `isLoading` + host `ListenableBuilder` đọc state live — không mở route mới giữa chừng | [M20/04](/m20/04-hoi-ai-va-dung-cuoc-choi/) | M21 |
| Dialog = state trong `Stack` (in-tree layer) | dialog không phải route — widget render theo `dialogState`; ownership=VM, lifetime=màn, test độc lập | [M21/01](/m21/01-dialog-la-state-khong-phai-route/), [M21/02](/m21/02-game-dialog-layer/) | M28, M29 |
| VM-side async save boundary | transition kết thúc sở hữu persistence: guard `hasSavedResult` trong state + `unawaited` repo write — kết quả là ghi-DB, không phải route-pop result | [M22/01](/m22/01-ket-qua-la-ghi-db/), [M22/04](/m22/04-vm-save-mot-lan/) | M25, M26 |
| Remote repository impl sau contract | `SupabaseLeaderboardRepository implements LeaderboardRepository` — đổi nguồn static/local → remote, UI/VM không đổi một dòng | [M23/02](/m23/02-init-co-dieu-kien/), [M23/03](/m23/03-leaderboard-repository/) | M24, M25 |
| Conditional DI theo config | `main()` chọn impl duy nhất một chỗ: `client == null ? Disabled… : Supabase…` — `SupabaseClient?` null làm sentinel, không class riêng | [M23/02](/m23/02-init-co-dieu-kien/) | M24 (auth cùng nhánh) |
| `_requestId` monotonic stale guard | `++_requestId` trước `await`; sau await (và trong `catch`) `id != _requestId → return` — câu trả lời cũ không được thắng | [M23/04](/m23/04-viewmodel-va-stale-guard/) | M26, mọi refreshable load |
| Auth session stream | `BehaviorSubject` reuse cho identity: `authStateStream` seeded (Disabled `AuthSessionGuest` / impl `currentUser`), `.value` đọc session hiện tại, subscriber mới được replay — "session là state, sign-in là action", result không mang session | [M24/01](/m24/01-session-model/) | M24/04, M25 |
| Action coordinator + contract-trước-impl-sau | `MenuAuthActionCoordinator` giữ chuỗi `signIn*→loadAuthState→guard→syncUserProfile` + `signOut→resetUserProfile` một chỗ; `UserProfileSyncRepositoryDisabled` no-op để call-site đúng ngay — impl `public.users` M25 | [M24/03](/m24/03-sync-seam-va-coordinator/) | M25 |
| Boundary DTO / anti-corruption layer (`AppUserData`) | một class `data/` dịch hai namespace cột snake ↔ field domain: `fromMap` (parse phòng thủ → default), `fromProfile{session,profile}`, `toUpsertMap` (key = tên cột SQL), `toProfile` (`gamesWon: 0`); `email`/`gamesWon`/`totalEarnings`-String vắng có ý | [M25/01](/m25/01-app-user-data-va-schema/) | mọi remote-write sau |
| Merge / conflict-resolution policy (`mergeUserProfileForSync`) | hàm thuần deterministic không timestamp: identity session-wins, progression leader `level`→`currentExp`-tiebreak nguyên khối, totals max từng field, `gamesWon` local-only, `_withoutDemoProgression` chặn tiến trình fake lên remote; idempotent | [M25/02](/m25/02-merge-user-profile-for-sync/) | mọi merge local↔remote sau |
| Sync pipeline + re-entrancy guard | `UserProfileSyncRepositoryImpl`: `_isSyncing` chặn chồng TẠI CỬA (`try/finally` — ≠ `_requestId` loại kết-quả-cũ) → `InProgress` → load local → fetch `maybeSingle` → merge → save local TRƯỚC → `upsert(onConflict:'auth_uuid')` → `Idle`; catch → `Failed` + `rethrow`; `_emit` dedupe/`isClosed` | [M25/03](/m25/03-sync-repository-impl/) | M26 (DRE/`asyncOp` thay guard tay) |
| Post-save best-effort sync (`_syncSavedGameResult`) | sau `_saveGameResult`: `loadAuthState` → `AuthSessionAuthenticated` → `syncUserProfile` + log started/completed; guest → skip; catch nuốt + log — repo `rethrow` vs caller nuốt là hai tầng quyết trên cùng lỗi; "retry" = lần sync kế | [M25/04](/m25/04-main-di-va-game-vm/) | M26 (op đầu tiên của DRE game path) |
| Project-local reducer (`GameReducer`) | `(state, action) → {state, effects, asyncOp}` thuần — mọi transition + guard + chấm điểm của game; test không cần Flutter; DRE là pattern project-local, không phải Redux/MVI/Elm (repo không expansion) | [M26/04](/m26/04-game-reducer/) | M27+ |
| `flowToken` trong state (stale guard DRE) | token sống TRONG `GameState`, tăng ở mọi transition tạo-delay; `*Elapsed` actions mang token chụp lúc schedule → reducer no-op khi mismatch — stale callback là action bị loại, không phải exception; khác `_requestId` (field VM) ở chỗ token đi cùng state copy | [M26/03](/m26/03-game-state-actions-effects/), [M26/04](/m26/04-game-reducer/) | M27+ |
| Service-contract platform boundary | widget/VM không chạm plugin trực tiếp — chuỗi widget→VM→contract→impl→plugin→OS; `Provider<Contract>.value` + `context.read<Contract>()`; impl đổi chỗ không sửa call-site | [M27/01](/m27/01-platform-boundary-va-dependencies/), [M27/02](/m27/02-local-notification-service/) | mọi platform feature sau |
| Coordinator + best-effort rollback | `SettingsNotificationCoordinator`: việc-OS TRƯỚC (schedule/cancel), persist SAU — save hỏng thì hoàn tác việc-OS; rollback cũng hỏng → giữ lỗi gốc, không nuốt | [M27/03](/m27/03-settings-coordinator-permission-state/) | mọi chuỗi OS+persist sau |
| Permission-as-state | `_hasNotificationPermission` là VM state được nạp qua `hasPermission()`; `effectiveNotificationEnabled` = flag AND permission — "permission là state OS sở hữu: query/request, không assume" | [M27/03](/m27/03-settings-coordinator-permission-state/) | mọi runtime-permission sau |
| Design tokens single-source (A-38) | `AppTokens` = nguồn-đúng-duy-nhất cho màu/spacing/radius/motion/typography — widget không hardcode giá trị; token đổi → toàn app đổi; `AppAssets` chỉ khai báo const cho asset thật-ship (subset rõ ràng, không dangling ref) | [M28/01](/m28/01-nen-mong-tokens-assets/) | M29 (mọi surface còn lại) |
| Trigger-based animation as data (A-39) | `animationTrigger: int` trong DTO — widget chỉ animate khi `trigger > oldTrigger`; đổi amount không-kèm-trigger → snap thẳng; intent-to-animate là *data* đi qua mapper, không phải diff-widget tự đoán | [M28/04](/m28/04-trigger-motion-so-tien-nhay/) | mọi "animate chỉ khi X" sau |

## Backend (Supabase)

| Concept | Nghĩa một câu | Dạy ở | Củng cố ở |
|---|---|---|---|
| RLS / anon-key security boundary | publishable key là public-by-design (ship cùng client); quyền hạn = RLS policies + grants phía server; service-role không bao giờ vào app | [M23/01](/m23/01-supabase-va-dart-define/) | M24, M25 |
| View-vs-table read model | `public.leaderboard` là VIEW `security_barrier` — `auth_uuid` chỉ lộ trên hàng caller; `public.users` là bảng owner-only sau RLS | [M23/01](/m23/01-supabase-va-dart-define/) | M24, M25 |
| `Supabase.initialize` + `SupabaseClient` | "ổ cắm mạng" của SDK — chỉ tồn tại khi đủ dart-define config; trả `SupabaseClient?` nullable | [M23/02](/m23/02-init-co-dieu-kien/) | M24, M25 |
| Query chain `select`/`order`/`limit`/`eq` + `maybeSingle` | Data API builder chain — rank do view tính; `maybeSingle` = 0-hoặc-1 → `null` (không throw như `single`); row JSON → typed model bằng mapping phòng thủ | [M23/03](/m23/03-leaderboard-repository/) | M24, M25 |
| `signInWithIdToken` two-leg flow | chặng 1 provider trả tokens (`GoogleAuthTokens{idToken,accessToken?}`); chặng 2 `client.auth.signInWithIdToken(provider:, idToken:, …)` đổi lấy Supabase session — "idToken là hộ chiếu, session là visa" | [M24/02](/m24/02-supabase-auth-impl/) | M25 (mọi OAuth sau) |
| `google_sign_in` v7 API | `GoogleSignIn.instance.initialize(clientId:, serverClientId:)` đúng một lần + `authenticate(scopeHint:)` → `account.authentication.idToken`; `serverClientId` = Web client id Supabase verify; legacy `signIn()` không còn | [M24/02](/m24/02-supabase-auth-impl/) | — |
| `onAuthStateChange` + `currentUser` seed | subject seed từ `client.auth.currentUser` (session sót lại của SDK); listener map mọi đổi-auth → session emit, `onError` → Guest; `signUp` confirm-email: success-không-session hợp lệ | [M24/02](/m24/02-supabase-auth-impl/) | M25 |
| auth ≠ authorization ≠ profile (awareness) | identity (uid, provider cấp) vs quyền-hạn (RLS server-side quyết) vs dữ liệu app (`UserProfileData` local / `public.users` remote); `auth_uuid` là sợi nối ba thứ | [M24/01](/m24/01-session-model/) | M25 |
| SHA-256 nonce OIDC (Apple, awareness) | `Random.secure` raw nonce → gửi Apple bản hash `sha256` → trả `rawNonce` gốc cho `signInWithIdToken(nonce:)` — server hash-đối-chiếu chống replay | [M24/02](/m24/02-supabase-auth-impl/) | — |
| `upsert(onConflict:)` write path trên `public.users` | `from('users').upsert(toUpsertMap(), onConflict: 'auth_uuid')` — insert-khi-chưa-có / update-khi-trùng-unique-column trong một roundtrip (không select-check-existence); `auth_uuid` unique + FK→`auth.users.id`; RLS own-row `auth.uid()=auth_uuid` chặn ghi chéo; payload 8 key = 8 cột app-sở-hữu | [M25/01](/m25/01-app-user-data-va-schema/) | [M25/03](/m25/03-sync-repository-impl/), mọi remote-write sau |

## Platform

| Concept | Nghĩa một câu | Dạy ở | Củng cố ở |
|---|---|---|---|
| `kIsWeb` + `resolvePlatformSpecificImplementation` | `kIsWeb` là const compile-time (tree-shake nhánh chết); `resolvePlatformSpecificImplementation<T>` lấy impl theo-OS của federated plugin — switch-platform theo object | [M27/01](/m27/01-platform-boundary-va-dependencies/), [M27/02](/m27/02-local-notification-service/) | mọi platform API sau |
| `flutter_local_notifications` + `zonedSchedule` | `zonedSchedule(id, title, body, tz.TZDateTime, details, androidScheduleMode:, matchDateTimeComponents: DateTimeComponents.time)` = lặp hằng ngày vào giờ đó theo giờ địa phương; `DateTimeComponents.time` so sánh chỉ giờ:phút | [M27/02](/m27/02-local-notification-service/) | — |
| `timezone` + `flutter_timezone` | `tz.initializeTimeZones()` nạp tz db + `FlutterTimezone.getLocalTimezone()` → `tz.setLocalLocation` (UTC fallback) — `TZDateTime` cần location local để "8h sáng" nghĩa đúng | [M27/02](/m27/02-local-notification-service/) | — |
| `share_plus` + `Clipboard` fallback | `SharePlus.instance.share(ShareParams(text:, sharePositionOrigin:))` mở sheet OS; iPad cần `sharePositionOrigin` (RenderBox→Rect anchor); catch → `Clipboard.setData` + snackbar = degrade gracefully | [M27/05](/m27/05-share-chain-dre-effect/) | — |
| `package_info_plus` | `PackageInfo.fromPlatform().version` — version/build đọc từ OS bundle; tiêm qua seam `loadAppVersion` để test đổi được | [M27/04](/m27/04-settings-wiring-version-onboarding/) | — |
| Runtime permission (Android 13+/iOS) | `POST_NOTIFICATIONS` manifest chỉ *khai báo* — permission phải xin runtime qua `requestPermission()`; denied → hành vi phải degrade (persist-off + snackbar), không crash | [M27/03](/m27/03-settings-coordinator-permission-state/), [M27/04](/m27/04-settings-wiring-version-onboarding/) | — |

## Animation & visual parity (M28)

| Concept | Nghĩa một câu | Dạy ở | Củng cố ở |
|---|---|---|---|
| `AnimationController` + `vsync`/`TickerProviderStateMixin` (F-38) | controller là đồng-hồ-tick sống trong `State`: `forward/reverse/repeat` lái `Animation<double>`; `vsync: this` chống tick-ngầm; `dispose` bắt buộc; `SingleTicker` cho một controller, `TickerProvider` cho nhiều | [M28/03](/m28/03-custompainter-animationcontroller-dong-ho/) | M28+, mọi explicit animation sau |
| `CustomPainter` + `Canvas`/`Paint`/`Path` + `shouldRepaint` (F-39) | painter vẽ trực tiếp không qua widget-tree — stadium `Path` + `extractPath`/`computeMetrics` cho dash/segment; `shouldRepaint` quyết re-paint theo props; `CustomPaint(painter:/foregroundPainter:)` bọc vào cây | [M28/03](/m28/03-custompainter-animationcontroller-dong-ho/) | M28+ (feature-button painter) |
| `didUpdateWidget` prop→controller sync (F-40) | hook `State` lifecycle khi widget config đổi — quyết `forward(from:0)` vs snap giá-trị-mới; nơi trigger-based animation đọc `oldWidget` | [M28/03](/m28/03-custompainter-animationcontroller-dong-ho/), [M28/04](/m28/04-trigger-motion-so-tien-nhay/) | — |
| Implicit-animation family (F-41) | `AnimatedOpacity`/`AnimatedScale`/`AnimatedContainer`/`AnimatedDefaultTextStyle`/`TweenAnimationBuilder`/`AnimatedSwitcher` — animation khai-báo theo prop-change, không controller tay; `CurvedAnimation`/`Interval` stagger | [M28/05](/m28/05-be-mat-game-va-lop-dialog/) | M28+ |
| `flutter_svg` `SvgPicture.asset` + `colorFilter srcIn` (F-42) | SVG asset render như Image; `ColorFilter.mode(color, BlendMode.srcIn)` tô một màu lên toàn-bộ-alpha — icon mono-color đổi màu theo state mà không cần nhiều file | [M28/02](/m28/02-chrome-chung-pill-kinh-nen/) | mọi icon asset sau |
| Semantics nâng: `liveRegion`/`value`/`onTap` + `getSemantics`/`matchesSemantics` (F-43, LIGHT) | `Semantics` node mang thuộc-tính động + action; test đọc node trực tiếp `tester.getSemantics(finder)` + `matchesSemantics(label:…)` thay `find.bySemanticsLabel` chỉ-tìm | [M28/05](/m28/05-be-mat-game-va-lop-dialog/) | — |

## Navigation & test

| Concept | Nghĩa một câu | Dạy ở | Củng cố ở |
|---|---|---|---|
| `Navigator.push`/`pop` | route stack LIFO | [M07](/m07/) | M09, M13 |
| `pop(context, result)` | route trả kết quả về caller | [M09](/m09/) | M10 |
| `test`/`expect`/`group` | unit test `flutter_test` | [M04/04](/m04/04-unit-test-dau-tien/) | mọi milestone |
| `testWidgets`/`WidgetTester`/`pump` | widget test điều khiển frame tay | [M08/04](/m08/04-widget-test-dau-tien/) | M09, M13, M14 |
| `setMockInitialValues` | prefs giả trong test | [M10](/m10/) | M14/04 |
| `NavigatorObserver` | bắt push/pop trong widget test | [M08/04](/m08/04-widget-test-dau-tien/) (Tự làm) | — |
| `ensureVisible` | cuộn element off-screen vào viewport trước khi tap | [M16/05](/m16/05-time-picker-synthesis/) | — |
| `PopScope` + `onPopInvokedWithResult` | chặn pop mặc định (`canPop: false`), route ý định back về VM — thay `WillPopScope` | [M19/05](/m19/05-man-hinh-moi-provider-bridge-popscope/) | [M21/04](/m21/04-popscope-va-back-handling/) |
| `AppNavigationController` + `GlobalKey<NavigatorState>` | điều hướng context-free: key gắn `MaterialApp.navigatorKey`, controller push/pop qua `navigatorKey.currentState` | [M19/05](/m19/05-man-hinh-moi-provider-bridge-popscope/) | M20+ |
| `find.descendant` | finder giới hạn match trong subtree — gỡ đụng text trùng giữa bar và dialog | [M20/04](/m20/04-hoi-ai-va-dung-cuoc-choi/) | — |
| `LinearProgressIndicator`/`AnimatedOpacity`/`Semantics` | progress + fade khai báo + a11y label cho nút custom | [M20/03](/m20/03-nam-muoi-nam-muoi-va-hoi-khan-gia/) | M28 |
| `AnimatedSwitcher` + `transitionBuilder` | đổi child trong cây → fade/slide giữa outgoing/incoming; reverse-duration cho exit | [M21/03](/m21/03-animated-switcher-va-keyed-transitions/) | M28 |
| `ValueKey(runtimeType)` | key-identity theo *variant*: đổi variant → swap animate; đổi payload cùng variant → rebuild in-place | [M21/03](/m21/03-animated-switcher-va-keyed-transitions/) | — |
| `BackdropFilter` + `ClipRect` + `IgnorePointer` + `HitTestBehavior.opaque` | backdrop blur trong bounds + tap-outside rule + chặn hit theo state | [M21/02](/m21/02-game-dialog-layer/) | M28 |
| `MediaQuery.disableAnimations` | a11y reduced-motion → duration `Duration.zero` (không bỏ hẳn animation code-path) | [M21/03](/m21/03-animated-switcher-va-keyed-transitions/) | M28 |

| senior-alignment pass (A-40) — đọc→diff→port→verify, giữ documented-deviation-vs-converge | quy trình đối chiếu senior có-kỷ-luật: đọc senior trước, diff từng file, port verbatim, verify bằng test — deviation phải được GHI NHẬN | [M29](/m29/) | — |
| `widget_previews` + `@Preview` (F-44) | catalog preview trong-IDE: `@Preview(name/group/size, wrapper:)` + fake-repo fixtures — kiểm-tra-visual không cần chạy app | [M29/07](/m29/07-hoi-tu-quet-cuoi/) | — |

:::tip[Dùng trang này thế nào]
Tìm concept → nhảy về "dạy ở" để đọc lại giải thích đầy đủ → xem
"củng cố ở" để biết nó sẽ quay lại đâu. Muốn thấy câu chuyện *state
management* tiến hoá qua các milestone, đọc [Tiến trình quản lý
state](/state-progression/).
:::
