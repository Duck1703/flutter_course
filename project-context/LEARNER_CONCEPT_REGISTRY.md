# Learner Concept Registry (canonical)

Every meaningful Dart/Flutter/architecture concept in the course gets one row.
Purpose: prevent code appearing before theory, give every concept an owner
milestone, track reinforcement, and make "where is X taught" answerable.

Status vocabulary: PLANNED → INTRODUCED (named+used) → TAUGHT (depth per
`BEGINNER_CONTENT_STANDARD.md` level) → REINFORCED (deliberately deepened
later) → MASTERED_EXPECTATION (learner should use it unaided).

Depth: LIGHT / NORMAL / CORE_CONCEPT (levels defined in
`BEGINNER_CONTENT_STANDARD.md`).

## Dart

| ID | Concept | Depth | First taught | First code | Prereqs | Reinforced | Exercise | Status |
|----|---------|-------|--------------|-----------|---------|-----------|----------|--------|
| D-01 | `final`/`const` | CORE | M01/02 | M01 | — | M02, M04 | — | TAUGHT |
| D-02 | named params + `required` | CORE | M01/02, M02 | M01 | class | M02–M04 | — | TAUGHT |
| D-03 | null safety `T?` `!` `??` `?.` | CORE | M04/01 | M04 | types | M05, M10 | — | TAUGHT |
| D-04 | class/field/method/getter/`_` private | CORE | M02, M03/01 | M02 | — | M04, M10 | — | TAUGHT |
| D-05 | `copyWith` + `==`/`hashCode` | CORE | M04/02 | M04 | D-03/04 | M14 (emit guard relies on `==`) | — | REINFORCED |
| D-06 | enum | CORE | M08/02 | M08 | D-04 | M09, M11 | — | TAUGHT |
| D-07 | collections, spread, collection-if/for | NORMAL | M02, M08/03 | M02 | — | — | — | TAUGHT |
| D-08 | closures/`VoidCallback`/`() {}` | CORE | M03 | M03 | D-04 | M07, M11 | — | TAUGHT |
| D-09 | `Future<T>`, `async`/`await`, `Future.delayed`, `throw` | CORE | M05/01 | M05 | — | M06, M09, M10, M13 | M05 exercise | MASTERED_EXPECTATION |
| D-10 | `Stream<T>`, `listen`, `StreamSubscription` | CORE | M06/01–03 | M06 | D-09 | M13, M14 | M06 exercise | REINFORCED |
| D-11 | `StreamController` + `.broadcast` | CORE | M06/03, M13/01 | M13 | D-10 | M14 (contrast) | M13 exercise | REINFORCED |
| D-12 | `Timer.periodic` + cancel ownership | CORE | M09/01 | M09 | D-08 | — | M09 exercise | TAUGHT |
| D-13 | `is` checks / generics `<T>` | NORMAL | M08, M02/M05 | M02 | — | M13 | — | TAUGHT |
| D-14 | `switch` statement / expression | NORMAL | M09/03, M11/02 | M09 | D-06 | M15 (sealed+patterns) | — | TAUGHT |
| D-15 | `Map<String,Object?>` + `jsonEncode/Decode` | CORE | M10/02 | M10 | D-03, D-07 | M14 | — | TAUGHT |
| D-16 | **`factory` constructor** | NORMAL | **M10/02 (new §)** | M10 | D-04 | M14 (`static create()`) | — | TAUGHT |
| D-17 | `unawaited` | NORMAL | M11/01 | M11 | D-09 | M13 | — | TAUGHT |
| D-18 | cascade `..`, tear-off | LIGHT | M12/03, M11/02 | M11 | — | M14 (`..loadUserProfile`) | — | TAUGHT |
| D-19 | **`abstract interface class` + `implements`** | CORE | **M14/02 (new)** | M14 | D-04 | M16+ (every repo) | M14/02 exercise | TAUGHT |
| D-20 | `static` + async `create()` factory-method | NORMAL | M14/02 | M14 | D-09, D-16 | — | — | TAUGHT |
| D-21 | null-aware element `'k': ?v` | NORMAL | M14/04 | M14 | D-03, D-15 | — | — | TAUGHT |
| D-22 | `abstract`/`final` class modifiers | NORMAL | M13/01 | M13 | D-04 | M14, M15 | — | TAUGHT |
| D-23 | test APIs: `test/expect/group/addTearDown/throwsA` | CORE | M04/04 | M04 | — | all test lessons | M04 exercise | MASTERED_EXPECTATION |
| D-24 | `pumpEventQueue` | NORMAL | M14/04 | M14/03 (exercise, glossed) | D-10 | M14/06 | — | TAUGHT |
| D-25 | `async*`/`yield` | — | **not taught** (M06 defers) | unused | — | first consumer milestone | — | PLANNED |
| D-26 | **`sealed class` + sealed hierarchy** | CORE | **M15/02 (new)** | M15 | D-04, D-06, D-22 | M19, M21 | M15/02 exercise | TAUGHT |
| D-27 | **exhaustive `switch` expression + object pattern `Type(:final f)` + wildcard `_`** | CORE | **M15/03 (new)** | M15 | D-14, D-06, D-13 | M19, M21 | M15/03 exercise | TAUGHT |
| D-28 | `runtimeType` (awareness — senior uses as transition key) | LIGHT | M15/03 | — (senior evidence) | D-04 | M21 | — | INTRODUCED |
| D-29 | `String.padLeft` (time formatting) | LIGHT | **M16/02 (new)** | M16 | D-03 | M27 | — | TAUGHT |
| D-30 | `late`/`late final` (field gán muộn trong ctor thân) | LIGHT | **M16/03 (new)** | M16 | D-04 | M18, M27 | — | TAUGHT |
| D-31 | `.arb` resource files (`@@locale`, `"key"`, `@key` placeholder metadata, `''` escaping) | NORMAL | **M17/02 (new)** | M17 | D-15 | M18, M22+ (new keys per surface) | M17/05 Tự làm | TAUGHT |
| D-32 | `listEquals` + `List.unmodifiable` (list-state emit discipline) | NORMAL | **M18/03 (new)** | M18 | D-04, D-27 | M19+ (VM list fields) | M18/03 DEBUG | TAUGHT |
| D-33 | `Duration` + `Timer.periodic` owned by a VM (start/stop = pause/resume; `dispose` cancel; tick = copyWith emit) | CORE | **M19/04 (new)** | M19 | D-04, A-08 | M20+ (mọi timer/delay tiếp theo) | M19/04 fakeAsync tests | TAUGHT |
| D-34 | `copyWith` + `clear*` flags on immutable multi-field state (`selectedAnswer: clearSelectedAnswer ? null : …`) — nullable field ambiguity | CORE | **M19/02 (new)** | M19 | D-05 | M20, M22, M26 (GameState fields mới) | M19/02 isolated `Form` example | TAUGHT |
| D-35 | `Set<T>` field state bất biến — `{...old, x}` copy-add, `.contains`, `Set.unmodifiable`, `const {}` | CORE | **M20/01 (new)** | M20 | D-34, D-32 | M21+ (mọi used-set/gate tương tự) | M20/01 isolated `Wallet` example | TAUGHT |
| D-36 | `firstWhere` + map-comprehension `{for…k:v}` + `String.fromCharCode` + `List.generate` | NORMAL | **M20/02–03 (new)** | M20 | D-15, D-14, D-07 | M26 (reducer ports) | M20/02 helper tests | TAUGHT |
| D-37 | `ValueKey(Type)` — `ValueKey(dialog.runtimeType)` key-identity theo *variant*: variant đổi → swap animate, payload đổi cùng variant → rebuild in-place, không re-animate | CORE | **M21/03 (new)** | M21 | D-27 (type patterns), M15 sealed | M26+ (keyed transitions) | M21/03 DEBUG key-sai | TAUGHT |
| D-38 | `LevelConfig` — **config-table progression**: `static const` map milestone multipliers (`{5,10,15:1.5; 20,40,60:3; 30,50,70,80:2; 90:4; 100:5}`), `getExpRequiredForLevel` = `(baseExp + level×growthPerLevel) × multiplier(level+1)`, `while`-loop đốt ngưỡng, clamp 1..100 | NORMAL | **M22/02 (new)** | M22 | D-15, D-07 | M28 (tier visuals), M25 (sync payload) | M22/02 PREDICT thresholds | TAUGHT |
| D-39 | `MenuLevelProgress` — **derived view-model**: `fromProfile` factory suy `requiredExp`/`remainingExp`/`ratio`/`tier`/`formatted*` từ profile thô qua `LevelConfig`; field dư thừa (`expForNextLevel`) retire | NORMAL | **M22/03 (new)** | M22 | D-16, D-38 | M28 (`LevelProgressCard` ring/bar) | M22/03 RECOGNIZE tier | TAUGHT |
| D-40 | `String.fromEnvironment` / `--dart-define` — hằng biên dịch (`const` context), thiếu key → `''`/`defaultValue`; "config là plumbing, không phải state" — không `.env`, không runtime | NORMAL | **M23/01 (new)** | M23 | D-01 | M24 (auth keys), mọi remote sau | M23/01 PREDICT env combos | TAUGHT |
| D-41 | `maybeSingle()` + JSON row→typed model: Data API `from().select().order().limit().eq()`; `maybeSingle` = 0-or-1 → `null` (vs `single` throw); `_LeaderboardRecord` defensive `_intValue`/`_stringValue`/`_formatScore` | NORMAL | **M23/03 (new)** | M23 | D-15, D-03 | M25 (`_fetchRemoteProfile` cùng builder — landed; `AppUserData.fromMap` defensive parsers), M24 | M23/03 PRODUCE scripted fake | TAUGHT |
| D-42 | `_requestId` monotonic stale guard — `final id = ++_requestId` trước `await`; sau await `id != _requestId → return` (cả try lẫn catch); "câu trả lời cũ không được thắng" | NORMAL | **M23/04 (new)** | M23 | D-09, D-24 | M26 (DRE cancel), mọi refreshable load | M23/04 DEBUG xoá `_isLatestRequest` | TAUGHT |
| D-43 | sealed union áp dụng cho **identity** — `AuthSessionData` → `AuthSessionGuest`/`AuthSessionAuthenticated{uid,email,displayName,photoUrl}` + `isAuthenticated` getter; guest là variant chính danh (không `User?`); `ProfileSyncStateData` 3-variant cùng pattern | NORMAL | **M24/01 (new)** | M24 | D-26, D-27 | M24/03–05 (mọi auth consumer switch), M25 (`is AuthSessionAuthenticated` promote trong `_syncSavedGameResult` — landed) | M24/01 PREDICT env combos | TAUGHT |
| D-44 | `AuthActionResult` value-type result — private ctor `._` + **redirecting const ctor** `.success(m)/.failure(m) : this._(…)`; "outcome một lần của action" tách khỏi state stream; caller đọc `isSuccess`/`message`, không try/catch | NORMAL | **M24/01 (new)** | M24 | D-01, D-02, D-04 | M24/03–04 (coordinator + dialog VMs consume), M25 | M24/03 DEBUG guard | TAUGHT |
| D-45 | `part`/`part of` + **private `extension` across part files** — một library nhiều file chia sẻ import + private members; `extension _X on GameReducer` sống trong part-file con, chỉ thấy trong library; `part`/`part of` đã dạy ở M24 — M26 mới ở private extension (lần dùng `part` thứ hai của khoá) | NORMAL | **M26/04 (new)** | M26 | D-26 (sealed), M24 part | M28+ (mọi split-file sau), M29 | M26/04 DEBUG part-mismatch | TAUGHT |
| D-46 | `abstract interface class` + **generic bounds** — marker interface rỗng `DreAction`/`DreEffect`/`DreAsyncOp` = "nhãn vai trò" (không member); `DreReducer<S, A extends DreAction, E extends DreEffect, O extends DreAsyncOp>` ràng kiểu để `reduce` chỉ nhận đúng family | CORE | **M26/02 (new)** | M26 | D-26, D-02 | M29 (mọi DRE sau), M27/28 reinforcement | M26/02 PRODUCE tiny reducer | TAUGHT |
| D-47 | `kIsWeb` + `resolvePlatformSpecificImplementation` — `kIsWeb` là const compile-time (`foundation`): nhánh `if (kIsWeb)` bị tree-shake ở release (khác runtime `Platform.is*` không chạy được trên web); `plugin.resolvePlatformSpecificImplementation<T>()` trả impl theo-OS của federated plugin — "switch-platform theo object", trả `null` khi platform không support | NORMAL | **M27/01+02 (new)** | M27 | D-01 (const), A-07 | mọi platform API sau | M27/01 PRODUCE boundary fake | TAUGHT |

| D-48 | `if-case` destructure trong điều kiện — `if (icon case final iconData?)` extract nullable/variant field trực tiếp trong guard, tránh cast tay + `as`/temp var; cặp với switch-exhaustive (D-26): switch cho nhiều nhánh, if-case cho kiểm-tra-nhanh một shape | NORMAL | **M28/02 (new)** | M28 | D-26 (sealed/pattern), D-02 | M28+ (dual iconAsset/icon trong shell, mọi variant-extract sau) | M28/02 PREDICT icon-branch | TAUGHT |

## Flutter

| ID | Concept | Depth | First taught | First code | Prereqs | Reinforced | Exercise | Status |
|----|---------|-------|--------------|-----------|---------|-----------|----------|--------|
| F-01 | Widget / widget tree / Element tree | CORE | M01/02 | M01 | — | M02, M03 | — | MASTERED_EXPECTATION |
| F-02 | `BuildContext` (location + lookup) | CORE | M01/02 | M01 | F-01 | M07, M12 | — | REINFORCED |
| F-03 | `StatelessWidget` | CORE | M01/02, M02 | M01 | F-01 | all | — | MASTERED_EXPECTATION |
| F-04 | `StatefulWidget`/`State<T>`/`createState` | CORE | M03/01 | M03 | F-01 | M05–M13 | M03 exercise | MASTERED_EXPECTATION |
| F-05 | `setState` + rebuild semantics | CORE | M03/02 | M03 | F-04 | M08–M11 | M03 exercise | MASTERED_EXPECTATION |
| F-06 | lifecycle `initState`/`dispose`/`didChangeDependencies`/`mounted` | CORE | M03/03, M05, M13/02 | M03 | F-04 | M05, M06, M13, M14 | — | REINFORCED |
| F-07 | layout constraints + Row/Column/Expanded/scroll | CORE | M02/01 | M02 | F-01 | M02–M09 | M02 exercise | MASTERED_EXPECTATION |
| F-08 | `MaterialApp`/`Scaffold`/`AppBar`/tokens | NORMAL | M01–M02 | M01 | F-01 | — | — | TAUGHT |
| F-09 | `GestureDetector`/buttons/`onTap:null` | NORMAL | M02–M03, M08 | M02 | D-08 | — | — | TAUGHT |
| F-10 | `FutureBuilder` + stable Future | CORE | M05/02 | M05 | D-09, F-04 | retired M11 (documented) | — | TAUGHT |
| F-11 | `StreamBuilder` + `initialData` | CORE | M06/02 | M06 | D-10 | M14 contrast | — | REINFORCED |
| F-12 | Navigator stack/`push`/`pop`/`popUntil`/`MaterialPageRoute<T>`/route-result Future | CORE | M07, M09/03, M10/03 | M07 | F-02 | M09, M10, M13 | M07 exercise | MASTERED_EXPECTATION |
| F-13 | `showDialog`/`AlertDialog`/dialog-as-route | CORE | M09/03 | M09 | F-12 | M10 | — | TAUGHT |
| F-14 | widget testing `pumpWidget`/`pump`/`tap`/finders/`ensureVisible` | CORE | M08/04, M09/04, M13/03 | M08 | D-23 | M09–M14 | M08 exercise | REINFORCED |
| F-15 | `ChangeNotifier`/`notifyListeners` | CORE | M11/02 | M11 | F-05 | M12–M14 | M11 exercise | MASTERED_EXPECTATION |
| F-16 | `ListenableBuilder` | CORE | M11/02 | M11 | F-15 | — | — | TAUGHT |
| F-17 | `InheritedWidget`→`Provider`/`read`/`watch`/scope | CORE | M12 | M12 | F-02, F-15 | M13, M14 | M12 exercise | MASTERED_EXPECTATION |
| F-18 | `ChangeNotifierProvider` create/auto-dispose | CORE | M12/03 | M12 | F-17 | M14 | — | REINFORCED |
| F-19 | `SnackBar`/`ScaffoldMessenger` | NORMAL | M13/02–03 | M13 | F-02 | — | — | TAUGHT |
| F-20 | `WidgetsFlutterBinding.ensureInitialized` + async main | NORMAL | M05/03 | M05 | D-09 | M14 bootstrap | — | TAUGHT |
| F-21 | **`MultiProvider` + contract-keyed `Provider<T>.value`** | CORE | **M14/06 (new)** | M14 (named M12/03 "chưa làm") | F-17, D-19 | M16+ | M14/06 exercise | TAUGHT |
| F-22 | `GlobalKey<NavigatorState>` awareness | NORMAL | M07/03 | — | F-12 | M19 | — | INTRODUCED |
| F-23 | `Switch` controlled (`value`/`onChanged`) + `HitTestBehavior.opaque` row-tap | NORMAL | **M16/04 (new)** | M16 | F-09, A-02 | M17 (settings locale row) | M16/04-05 | TAUGHT |
| F-24 | `ListWheelScrollView.useDelegate` + `FixedExtentScrollController` (ownership) | NORMAL | **M16/05 (new)** | M16 | F-04, F-06 | M27 | M16/05 Tự làm | TAUGHT |
| F-25 | `AppLocalizations.of(context)` + `localizationsDelegates`/`supportedLocales`/`MaterialApp.locale` | CORE | **M17/02–03 (new)** | M17 | F-17, F-11 | M18+ (mọi surface mới) | M17/05 test + Tự làm | TAUGHT |
| F-26 | in-`Stack` overlay gating (`Positioned.fill` + opaque tap absorber; visibility=state, not route) | NORMAL | **M18/01+04 (new)** | M18 | F-11, A-14 | M21 (dialog layer uses same model) | M18/04 PREDICT | TAUGHT |
| F-27 | `PopScope(canPop: false, onPopInvokedWithResult:)` — chặn pop, route ý định back vào VM theo `dialogState` (thay `WillPopScope` deprecated) | NORMAL | **M19/05 (new)** | M19 | F-12, A-14 | M21 (in-Stack dialog layer) | M19/05 widget test back-routing | TAUGHT |
| F-28 | `LinearProgressIndicator(value:)` + `AnimatedOpacity` + `Semantics(button/enabled/label)` + `IconData`-as-data + `semanticLabel` on Icon | NORMAL | **M20/03 (new)** | M20 | F-25 l10n, A-20 | M28 (visual parity FR-34) | M20/03 widget tests | TAUGHT |
| F-29 | `AnimatedSwitcher(duration/reverseDuration/switchInCurve/switchOutCurve/transitionBuilder)` + `FadeTransition` + `Transform.translate(transformHitTests:false)` + `AnimatedBuilder(animation:,child:)` | CORE | **M21/03 (new)** | M21 | F-28, D-33 | M26, M28 | M21/03 layer transition tests | TAUGHT |
| F-30 | dialog-layer composition: `ClipRect`+`BackdropFilter(ImageFilter.blur)`+`ColoredBox` scrim+`GestureDetector(HitTestBehavior.opaque)`+`IgnorePointer(ignoring:)`+`MediaQuery.disableAnimations` | NORMAL | **M21/02 (new)** | M21 | F-26, F-23, F-27 | M28, M29 | M21/02 layer tests | TAUGHT |
| F-31 | `supabase_flutter`: `Supabase.initialize(url:, publishableKey:)` + `SupabaseClient` — "ổ cắm mạng" SDK; chỉ tồn tại khi configured | LIGHT | **M23/02 (new)** | M23 | D-40, F-20 | M24/M25 (mọi remote dùng chung client) | — | TAUGHT |
| F-32 | `RefreshIndicator.adaptive` + `AlwaysScrollableScrollPhysics` — pull-to-refresh trên remote list; physics cho phép overscroll khi list ngắn; `onRefresh` Future-driven | NORMAL | **M23/05 (new)** | M23 | F-07, A-15 | M28+ (mọi remote list sau) | M23/05 PREDICT physics-removal | TAUGHT |
| F-35 | `share_plus` + `Clipboard` fallback — `SharePlus.instance.share(ShareParams(text:, sharePositionOrigin:))` mở OS share sheet; iPad cần `sharePositionOrigin` (`context.findRenderObject() as RenderBox` → `box.localToGlobal(Offset.zero) & box.size` anchor rect); catch → `Clipboard.setData(ClipboardData(text:))` + snackbar = degrade gracefully khi sheet không mở được | NORMAL | **M27/05 (new)** | M27 | A-33 (share cưỡi effects stream), F-10 | mọi share sau | M27/05 PRODUCE reducer-arm test | TAUGHT |
| F-36 | `flutter_local_notifications` + `zonedSchedule` — `initialize(InitializationSettings(android:, iOS:, macOS:))` per-platform settings objects; `zonedSchedule(id, title, body, tz.TZDateTime, details, androidScheduleMode: inexactAllowWhileIdle, matchDateTimeComponents: DateTimeComponents.time)` = lặp hằng ngày vào giờ đó giờ-local; `timezone` db + `FlutterTimezone.getLocalTimezone()` → `tz.setLocalLocation` (UTC fallback); `_nextDailyTime` rollover sang ngày mai khi giờ hôm nay đã qua | NORMAL | **M27/02 (new)** | M27 | D-47, A-35 | mọi scheduled notification sau | M27/03 schedule-time assertions qua fake | TAUGHT |
| F-37 | `package_info_plus` — `PackageInfo.fromPlatform().version` đọc version từ OS bundle (không hardcode); tiêm qua seam `loadAppVersion` trong VM ctor để test đổi được (inject function thay call static) | LIGHT | **M27/04 (new)** | M27 | A-07 (seam), F-21 | — | — | TAUGHT |

| F-38 | `AnimationController` + `vsync`/`TickerProviderStateMixin` — controller = đồng-hồ-tick sống trong `State`: `forward`/`reverse`/`repeat(reverse:)` lái `Animation<double>`; `vsync: this` chống tick-ngầm khi offscreen; `SingleTickerProviderStateMixin` cho một controller / `TickerProviderStateMixin` cho nhiều; `dispose` bắt buộc | CORE | **M28/03 (new)** | M28 | F-29 (AnimatedSwitcher), D-02 | M28+ (mọi explicit animation sau) | M28/03 timer pulse test | TAUGHT |
| F-39 | `CustomPainter` + `Canvas`/`Paint`/`Path` + `shouldRepaint` — painter vẽ trực tiếp không qua widget-tree: stadium `Path`, gradient `Paint..shader`, `computeMetrics`+`extractPath` cho dash/progress-arc; `shouldRepaint(old)` quyết re-paint theo props; `CustomPaint(painter:/foregroundPainter:)` gắn vào cây | CORE | **M28/03 (new)** | M28 | F-38 (animation value), F-07 | M28/06 (feature-button painter), mọi custom-draw sau | M28/03 metric asserts | TAUGHT |
| F-40 | `didUpdateWidget` prop→controller sync — hook `State` lifecycle khi config widget đổi: quyết `forward(from:0)` (trigger tăng) hay snap giá-trị-mới; nơi trigger-based animation đọc `oldWidget` — cầu nối duy nhất giữa data-change và explicit animation | NORMAL | **M28/03+04 (new)** | M28 | F-38, A-39 | mọi controller-driven widget sau | M28/04 trigger-gate test | TAUGHT |
| F-41 | implicit-animation family — `AnimatedOpacity`/`AnimatedScale`/`AnimatedContainer`/`AnimatedDefaultTextStyle`/`TweenAnimationBuilder` + `CurvedAnimation`/`Interval` stagger: animation khai-báo theo prop-change, không controller tay; `AnimatedSwitcher` (F-29) là đại diện swap-child | NORMAL | **M28/05 (new)** | M28 | F-29, F-30 | M28+ (answers stagger, reveal blink, dialog slide) | M28/05 blink/interval asserts | TAUGHT |
| F-42 | `flutter_svg` `SvgPicture.asset` + `ColorFilter.mode(srcIn)` — SVG asset render như `Image.asset`; `colorFilter: ColorFilter.mode(color, BlendMode.srcIn)` tô một màu lên toàn-bộ-alpha → icon mono-color đổi màu theo state mà không cần nhiều file asset | NORMAL | **M28/02 (new)** | M28 | F-10 (asset), A-38 | M28+ (mọi icon asset), M29 | M28/02 glass button assert | TAUGHT |
| F-43 | semantics nâng: `liveRegion`/`value`/`onTap` + `getSemantics`/`matchesSemantics` — `Semantics` node mang thuộc-tính động + action; test đọc node trực tiếp (`tester.getSemantics(finder)`, `matchesSemantics(label:)`) thay `find.bySemanticsLabel` chỉ-tìm | LIGHT | **M28/05 (new)** | M28 | F-30 (semantics cơ bản) | a11y surface sau | — | TAUGHT |

## Architecture / patterns

| ID | Concept | Depth | First taught | First code | Prereqs | Reinforced | Exercise | Status |
|----|---------|-------|--------------|-----------|---------|-----------|----------|--------|
| A-01 | declarative UI / UI = f(state) | CORE | M01/02, M03/02 | — | F-01 | all | — | MASTERED_EXPECTATION |
| A-02 | data-down / events-up, state ownership | CORE | M03/03 | M03 | F-05 | M08, M11 | — | TAUGHT |
| A-03 | why setState doesn't scale | CORE | M11/01 | M11 | F-05 | M12–M14 | — | TAUGHT |
| A-04 | phase/state machine via enum | CORE | M08/02, M09 | M08 | D-06 | M09 | — | TAUGHT |
| A-05 | UI event vs UI state + event bridge | CORE | M13/01–02 | M13 | D-11, F-17 | M14, M15 (sealed enforces it) | M13 exercise | REINFORCED |
| A-06 | **repository boundary vs storage** | CORE | **M14/01 (new)** | M14 | D-15 | M16–M24 | M14/01 exercise | TAUGHT |
| A-07 | **dependency inversion / DI by contract** | CORE | **M14/02+06 (new)** | M14 | D-19, F-17 | M16+ | M14/06 exercise | TAUGHT |
| A-08 | **BehaviorSubject/ValueStream/replay/.value** | CORE | **M14/03 (new)** | M14/02 (contract, flagged) | D-10, D-11 | M14/04–06, M16+ | M14/03 exercise | TAUGHT |
| A-09 | state stream vs event stream | CORE | M14/03, M14/06 | M14 | A-05, A-08 | — | M14/06 exercise | TAUGHT |
| A-10 | read/write boundary (subject in, stream out) | CORE | M14/03–04 | M14 | A-08 | — | — | TAUGHT |
| A-11 | fake repository / contract-first testability | CORE | M14/05–06 | M14 | D-19, A-07 | M16+ | M14/06 exercise | TAUGHT |
| A-12 | async bootstrap ordering | NORMAL | M05/03, M14/05 | M05 | D-09 | M14 | — | TAUGHT |
| A-13 | teaching-scaffold lifecycle (introduce→mark→retire) | NORMAL | M03 badge, M06 badge, M13/03 | — | — | all scaffold intros | — | TAUGHT |
| A-14 | **state-driven UI / render-by-state (`switch` over state)** | CORE | **M15/01+05 (new)** | M15 | A-01, A-05, D-27 | M19, M21 | M15/05 exercise | TAUGHT |
| A-15 | **dialog-scoped VM — scope = lifetime (provider inside dialog subtree)** | CORE | **M16/03 (new)** | M16 | F-18, A-05, A-08 | M21 (dialog layer scope) | M16/03 isolated example + L05 checkpoint | TAUGHT |
| A-16 | **locale = derived state ở app-root (StreamBuilder → `MaterialApp.locale`) + "UI sở hữu chữ, VM context-free"** | CORE | **M17/03–04 (new)** | M17 | A-08, F-25, F-18 | M18, M22+ | M17/05 locale-switch test | TAUGHT |
| A-17 | **overlay-scoped VM — 4th lifetime tier (app→screen→dialog→overlay) + guarded async flag (`_languageSelectionInProgress`) + repo-stream self-clear** | CORE | **M18/03–04 (new)** | M18 | A-15, A-10, A-16 | M21+ | M18/03 DEBUG + L05 widget test | TAUGHT |
| A-18 | **VM-owned session state machine — enum `GamePhase` 6 giá trị + transitions có guard (`phase != playing → return`) + UI render-by-phase** | CORE | **M19/01+04 (new)** | M19 | A-14, D-27, A-05 | M20 (lifelines vào cùng machine), M26 (DRE reducer) | M19/01 OrderMachine + L04 Tự làm | TAUGHT |
| A-19 | `AppNavigationController` + `GlobalKey<NavigatorState>` — điều hướng context-free qua `navigatorKey` gắn `MaterialApp` | NORMAL | **M19/05 (new)** | M19 | F-22, F-17 | M20+ (mọi navigation sau) | M19/05 widget test menu→game | TAUGHT |
| A-20 | presentation mapper — `buildGameScreenPresentation` thuần: session state → `GameScreenData` DTO chỉ-đọc; UI không tự suy state | NORMAL | **M19/03 (new)** | M19 | A-14, D-27 | M20 (`featureButtons`, `visibleOptionTexts`), M26 | M19/03 mapper unit test | TAUGHT |
| A-21 | **in-tree dialog layer — dialog = widget trong `Stack` render theo `dialogState`, không phải route** (ownership=VM, lifetime=screen, back=state machine) | CORE | **M21/01 (new)** | M21 | F-26, A-14, A-05 | M28 (shell), M29 (menu layer), M22 (terminal actions) | M21/05 PRODUCE variant | TAUGHT |
| A-22 | **VM-side async save boundary — transition kết thúc sở hữu persistence** (`_emitWithSaveResult` guard + `hasSavedResult` idempotence trên state + `unawaited` repo write; menu đọc lại qua stream, không route-result) | CORE | **M22/01+04 (new)** | M22 | A-18, A-08, D-17 | M25 (`_syncSavedGameResult` thật — landed; `hasSavedResult` chặn sync lặp), M26 (DRE `GameSaveResult` op) | M22/04 DEBUG guard-order | TAUGHT |
| A-23 | **remote repository impl behind an existing contract** — `SupabaseLeaderboardRepository` implements `LeaderboardRepository`; UI/VM đổi nguồn (fake/disabled/remote) mà không đổi một dòng — M14 DI nâng lên remote | NORMAL | **M23/02–03 (new)** | M23 | A-06, A-07, D-19 | M24/M25 (mọi remote repo sau) | M23/03 PRODUCE fake | TAUGHT |
| A-24 | **conditional DI by configuration** — `main()` chọn impl bằng `client == null ? Disabled… : Supabase…` duy nhất một chỗ; `SupabaseClient?` null là sentinel, không class riêng | NORMAL | **M23/02 (new)** | M23 | A-07, F-21, D-40 | M24 (`DisabledAuthRepository`/`AuthRepositoryImpl` — landed), M25 (`UserProfileSyncRepositoryDisabled`/`…Impl` — landed, lần 3) | M23/02 PREDICT ternary | TAUGHT |
| A-25 | **auth session stream** — `BehaviorSubject` reuse cho identity: `authStateStream` seeded (Disabled: `AuthSessionGuest`; impl: `client.auth.currentUser`), `.value` đọc session hiện tại, listener mới được replay; "session là state, sign-in là action" — result không mang session | NORMAL | **M24/01 (new)** | M24 | A-08, A-09 | M24/04 (MenuViewModel/leaderboard sub+seed), M25 | M24/01 PREDICT | TAUGHT |
| A-26 | **action coordinator + post-action chain seam** — `MenuAuthActionCoordinator` giữ chuỗi `signIn*→loadAuthState→(guard `is! AuthSessionAuthenticated`→failure)→syncUserProfile` và `signOut→resetUserProfile` một chỗ; contract trước impl sau (`UserProfileSyncRepositoryDisabled` no-op để call-site đúng ngay — impl `public.users` M25) | NORMAL | **M24/03 (new)** | M24 | A-06, A-07, A-11 | M25 (`UserProfileSyncRepositoryImpl` thay Disabled — landed) | M24/03 DEBUG guard-removal | TAUGHT |
| A-27 | **boundary DTO / anti-corruption layer** — `AppUserData` ở biên local↔remote: `fromMap` (row→DTO, parse phòng thủ → `const UserProfileData()` default), `fromProfile{session,profile}` (`session.uid`→`authUuid`), `toUpsertMap` (key = tên cột SQL), `toProfile` (`gamesWon: 0` — remote không mang); một class `data/` dịch hai namespace (cột snake ↔ field domain), ba-thứ-vắng (`email`/`gamesWon`/`totalEarnings`-String) là thiết kế | NORMAL | **M25/01 (new)** | M25 | D-41, D-15, D-16 | mọi remote-write sau | M25/01 PREDICT fromMap/fromProfile | TAUGHT |
| A-28 | **merge / conflict-resolution policy** — `mergeUserProfileForSync` pure deterministic (không timestamp): identity session-wins (`username` session→remote→leader; `avatarUrl` session→local→remote — hai fallback khác thứ tự), progression leader `level`→`currentExp`-tiebreak NGUYÊN KHỐI (exp chỉ có nghĩa trong level), totals `_maxInt` per-field, `gamesWon` local-only, `_withoutDemoProgression` `==`-match nguyên-profile chặn tiến trình fake `'TÀU HỦ ĐI CHILL'` lên remote; idempotent | NORMAL | **M25/02 (new)** | M25 | D-05, D-34, A-27 | mọi local↔remote merge sau (M26 DRE giữ cùng luật) | M25/02 DEBUG `_withoutDemoProgression` | TAUGHT |
| A-29 | **sync pipeline orchestration + re-entrancy guard** — `UserProfileSyncRepositoryImpl`: `_isSyncing` chặn chồng TẠI CỬA (`try/finally` mở khoá — ≠ `_requestId` D-42 loại kết-quả-cũ, ≠ `_isLoading` dialog VM) → `ProfileSyncInProgress` → `loadUserProfile` → `_fetchRemoteProfile` `maybeSingle` → `mergeUserProfileForSync` → `saveUserProfile` (local TRƯỚC) → `_upsertRemoteProfile` → `Idle`; catch → `Failed` + `rethrow` (stream cho observer, exception cho caller); `_emit` `isClosed` + value-dedupe | NORMAL | **M25/03 (new)** | M25 | A-08, A-10, D-42, A-11, D-09 | M26 (DRE/`asyncOp` thay guard+try/catch tay) | M25/03 PREDICT emit-sequence | TAUGHT |
| A-30 | **post-save best-effort sync** — `_syncSavedGameResult`: sau `_saveGameResult` (A-22), `loadAuthState` → `is AuthSessionAuthenticated` (promote kiểu-hẹp) → `syncUserProfile` + started/completed; guest → `skipped; session=guest`; catch nuốt + `failed:` — repo `rethrow` (A-29) vs caller nuốt là hai tầng quyết trên cùng lỗi; "retry" = lần sync kế (merge idempotent), không backoff | NORMAL | **M25/04 (new)** | M25 | A-22, A-26, D-43 | M26 (op đầu tiên của DRE game path) | M25/04 PRODUCE scratch test | TAUGHT |
| A-31 | **project-local reducer (DRE)** — `GameReducer.reduce(state, action) → DreResult{state, effects, asyncOp}` THUẦN: mọi transition + guard + chấm điểm của game sống ở đây; reducer KHÔNG sở hữu timer/delay/IO — chỉ trả data-ý-định; "DRE" không phải framework pub, là 4 interface + `DreResult` + `DreChangeNotifier` của repo | CORE | **M26/04 (new)** | M26 | A-18, D-46, D-34 | M29 (mọi domain VM sau), reinforcement M27/28 | M26/04 reducer unit tests | TAUGHT |
| A-32 | **async-op boundary** — `DreResult.asyncOp` tối đa MỘT op mỗi reduce; `DreChangeNotifier` bắn `executeAsyncOp(op, postReduceSnapshot)` `unawaited` ngay sau reduce; lỗi op → `onAsyncOpError` overridable hook, không crash dispatch; persistence `_saveGameResult` là op đầu tiên (`GameSaveResult`) | CORE | **M26/03+05 (new)** | M26 | A-22, A-29, D-46 | M27+ (mọi op sau) | M26/05 DEBUG op-lost | TAUGHT |
| A-33 | **effects stream → bridge** — reducer trả `List<GameEffect>` (data ý định: start/pause/stop timer, schedule reveal/explanation/AI, navigate, share); VM subscribe `effects` broadcast stream, `_handleEffect` switch biến mỗi variant thành `Timer`/`Future.delayed`/event thật; reducer-testable vì effect là data không phải side-effect | CORE | **M26/03+05 (new)** | M26 | A-31, M13 events, D-46 | M27 (share effect → platform), M29 | M26/05 bridge tests | TAUGHT |
| A-34 | **`flowToken` trong state (DRE stale guard)** — token sống TRONG `GameState` (không còn field VM), tăng ở mọi transition tạo-delay; `*Elapsed` actions mang token chụp lúc lên lịch; reducer so token — callback lỗi thời = action bị giảm thành no-op ngay trong reduce, thay guard sau-`await` kiểu `_requestId` | NORMAL | **M26/05 (new)** | M26 | A-18 flowToken, D-42 | mọi delayed flow sau | M26/05 stale-token test | TAUGHT |
| A-35 | **service-contract platform boundary** — widget/VM không chạm plugin trực tiếp: chuỗi widget→VM→`abstract class Contract`→`Impl`→plugin→OS; DI `Provider<Contract>.value` + `context.read<Contract>()`; impl đổi chỗ (fake/impl khác) không sửa một call-site; khác repository boundary (A-07) ở chỗ impl bọc *plugin OS* chứ không storage/network | CORE | **M27/01+02 (new)** | M27 | A-07, D-46 (contract), A-24 | mọi platform feature sau | M27/01 PRODUCE `LoggingReminderService` decorator | TAUGHT |
| A-36 | **coordinator + best-effort rollback** — `SettingsNotificationCoordinator` tách chuỗi "việc-OS trước, persist sau" khỏi VM: `enable` schedule→save (save hỏng → `cancelDaily` rollback); `disable` cancel→save (hỏng → re-schedule giờ cũ); `updateTime` conditional-reschedule→save (hỏng → khôi phục lịch cũ); rollback cũng hỏng → nuốt lỗi rollback, GIỮ lỗi gốc (best-effort, không swallow primary) | NORMAL | **M27/03 (new)** | M27 | A-26 (coordinator call-site), A-35 | mọi chuỗi side-effect+persist sau | M27/03 DEBUG schedule/save-order swap | TAUGHT |
| A-37 | **permission-as-state** — `_hasNotificationPermission` sống TRONG VM state (nạp qua `service.hasPermission()` trong `loadSettings`, refresh mỗi mở dialog); `effectiveNotificationEnabled` = `notificationEnabled` AND `_hasNotificationPermission` — flag người-dùng chỉ "có hiệu lực" khi OS cho phép; "permission là state OS sở hữu — query/request, không assume" | NORMAL | **M27/03 (new)** | M27 | A-35, D-09 | mọi runtime-permission surface sau | M27/03 denied-path test (off+snackbar) | TAUGHT |

| A-38 | **design tokens single-source** — `AppTokens` = nguồn-đúng-duy-nhất cho màu/spacing/radius/motion/typography (`GoogleFonts.beVietnamPro` ramp, `QzdsButtonScale`, `screenDesignWidth=375`); widget không hardcode giá trị — token đổi → toàn app đổi; `AppAssets` chỉ khai const cho asset thật-ship (subset rõ ràng, không dangling ref) | CORE | **M28/01 (new)** | M28 | A-07 (single-source), F-10 | M29 (mọi surface còn lại), mọi visual sau | M28/01 PREDICT token-swap | TAUGHT |
| A-39 | **trigger-based animation as data** — `animationTrigger: int` trong DTO/mapper: widget chỉ animate khi `trigger > oldTrigger`; đổi amount không-kèm-trigger → snap thẳng; intent-to-animate là *data* đi qua mapper, không phải widget tự đoán từ diff | NORMAL | **M28/04 (new)** | M28 | A-38, F-40, D-45 | mọi "animate chỉ khi X" sau | M28/04 DEBUG trigger-same | TAUGHT |

## Backend (Supabase)

| ID | Concept | Depth | First taught | First code | Prereqs | Reinforced | Exercise | Status |
|----|---------|-------|--------------|-----------|---------|-----------|----------|--------|
| B-01 | **RLS/anon-key security boundary** — publishable/anon key là public-by-design (ship cùng client); quyền hạn = RLS policies + grants server-side; service-role ≠ client, không bao giờ vào repo/app | LIGHT (awareness) | **M23/01 (new)** | M23 | — | M24 (auth state), M25 (ghi `users` qua RLS own-row — landed) | M23/01 PREDICT combos | INTRODUCED |
| B-02 | **view-vs-table read model** — `public.leaderboard` là VIEW `security_barrier` (rank bằng `row_number()`, `auth_uuid` chỉ lộ trên hàng caller); `public.users` owner-only dưới RLS | LIGHT (awareness) | **M23/01 (new)** | M23 (`.from('leaderboard')`) | B-01 | M24 (auth_uuid → uid thật — landed FR-35), M25 (`users` ghi qua `auth_uuid` — landed FR-36) | — | INTRODUCED |
| B-03 | **`signInWithIdToken` two-leg idToken flow** — chặng 1 provider (`GoogleAuthService`→`GoogleAuthTokens{idToken,accessToken?}`; Apple→`AppleAuthTokens{idToken,rawNonce,…}`), chặng 2 `client.auth.signInWithIdToken(provider:, idToken:, accessToken:, nonce:)` đổi token lấy Supabase session; "idToken là hộ chiếu, session là visa" | NORMAL | **M24/02 (new)** | M24 | B-01, F-31 | M25 (mọi OAuth sau cùng pattern) | M24/02 PREDICT DI | TAUGHT |
| B-04 | **`google_sign_in` v7 API** — `GoogleSignIn.instance.initialize(clientId:, serverClientId:)` đúng MỘT lần (`_isInitialized` guard; `serverClientId` = Web client id Supabase verify, KHÔNG phải Android/iOS id) + `authenticate(scopeHint:)` → `account.authentication.idToken` + `authorizationForScopes ?? authorizeScopes`; `signIn()` legacy KHÔNG còn | NORMAL | **M24/02 (new)** | M24 | D-40 (GOOGLE_* defines), F-31 | — | M24/02 PREDICT | TAUGHT |
| B-05 | **`onAuthStateChange` subscription + `currentUser` seed** — subject seed từ `client.auth.currentUser` (session sót lại của SDK); `Stream<AuthState>` listener map mọi đổi-auth → session emit, `onError` → Guest; `_sessionFromUser` metadata phòng thủ (`full_name`/`name`, `avatar_url`/`picture`); `signInWithPassword`/`signUp` (confirm-email: success-không-session hợp lệ)/`signOut` | NORMAL | **M24/02 (new)** | M24 | D-10, A-08, F-31 | M25 (session-driven writes) | — | TAUGHT |
| B-06 | **auth ≠ authorization ≠ profile** — identity (uid, provider cấp) vs quyền-hạn (RLS server-side quyết, B-01) vs dữ liệu app (`UserProfileData` local / `public.users` remote); `auth_uuid` là sợi nối ba thứ | LIGHT (awareness) | **M24/01 (new)** | M24 | B-01, B-02 | M25 (ghi `public.users`), M23 callback | — | INTRODUCED |
| B-07 | **SHA-256 nonce cho OIDC token binding** (Apple, APPENDIX) — `Random.secure` 16-byte raw nonce → gửi Apple `sha256.convert(utf8.encode(rawNonce))` → trả `rawNonce` gốc cho `signInWithIdToken(nonce:)`; server hash-đối-chiếu chống replay; `_sessionProfileOverride` vá first-login `email`/`displayName` Apple chỉ trả một lần | LIGHT (awareness) | **M24/02 appendix (new)** | M24 | D-09, B-03 | — | — | INTRODUCED |
| B-08 | **`upsert(onConflict:)` write path trên `public.users`** — `from('users').upsert(toUpsertMap(), onConflict: 'auth_uuid')`: insert-khi-chưa-có / update-khi-trùng-unique-column trong một roundtrip (không select-check-existence); `auth_uuid` unique + FK→`auth.users.id`; RLS `users_select/insert/update_own` `auth.uid()=auth_uuid` chặn ghi chéo; payload 8 key = 8 cột app-sở-hữu (schema test khoá); `email`/`gamesWon` vắng có ý | NORMAL | **M25/01 (new — payload+schema)** | M25 (call M25/03) | B-01, B-02, D-41 | mọi remote-write sau | M25/01 schema test + M25/03 PREDICT | TAUGHT |

## Deferred concepts (planned, not taught — may not appear as prerequisites)

`ProxyProvider`/`select` → TBD;
`async*`/`yield` → first consumer; named routes/go_router → excluded (senior
has none); `Future.wait`, rxdart operators → per roadmap; `part`/extensions →
awareness only.

## Discipline

- Atlas records every new concept's row in the milestone brief's LEARNING
  DESIGN CHECK before Lumen writes.
- Argus may FAIL a milestone for: code before theory, a `Bạn đã biết gì`
  claim that resolves to PLANNED, or a CORE_CONCEPT row with no exercise.
