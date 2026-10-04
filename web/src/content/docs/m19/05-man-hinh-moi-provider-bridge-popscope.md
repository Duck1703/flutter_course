---
title: "Bài 5 · Màn hình mới: provider + event bridge + PopScope"
description: "GameScreen stateless tạo ChangeNotifierProvider, _GameScreenEventBridge subscribe uiEvents → showDialog/pop, PopScope canPop:false route back vào VM, AppNavigationController + GlobalKey<NavigatorState>, khóa dọc portrait. +widget test → 126/126."
sidebar:
  label: "Bài 5 · migration màn"
  order: 5
---

## Mục tiêu

- Dựng lại `game_screen.dart` theo shape senior: stateless
  `GameScreen` chỉ tạo scope VM; `_GameScreenEventBridge` là
  `StatefulWidget` duy nhất — sở hữu stream-subscription + dialog.
- Nối ba thứ: `context.watch` → rebuild UI từ `screenData`;
  `uiEvents.listen` → hành động một-lần (dialog/pop); `PopScope` →
  back hệ thống về VM.
- Đưa `AppNavigationController` + `GlobalKey<NavigatorState>` vào
  `MaterialApp` + DI scope; khóa dọc app trong `main()`.

## Bạn đang ở đâu

- Bài 4: VM đầy đủ nhưng `game_screen.dart` vẫn stub.
- Cuối bài này: `flutter test` = **126/126** (+10 widget test);
  game chơi được thật từ menu.

## Vì sao việc này quan trọng ngay bây giờ

Đây là bài trả lời câu hỏi "statemachine+VM rồi, còn widget làm
gì?". Câu trả lời của senior: widget chỉ làm **ba** việc — render
`screenData`, forward ý định vào method VM, biên dịch event một-lần
thành side-effect (`showDialog`, `pop`). Không field game nào được
phép còn lại trong `State`.

## Bạn đã biết gì

- `ChangeNotifierProvider(create:)` / `.value` / `context.read`/
  `context.watch` (M11–M12).
- `StreamSubscription` + cancel trong `dispose` (M13/M15 menu event
  bridge).
- `PopScope`/`onPopInvokedWithResult` — **concept mới** (thay
  `WillPopScope` deprecated).
- `Navigator.push/pop` cơ bản; `GlobalKey` đã gặp (form).

## Dựng từng phần

### Bước 1 — `GameScreen`: stateless, chỉ tạo scope

```dart
class GameScreen extends StatelessWidget {
  /// VM tiêm sẵn — chỉ test dùng (bank mini). null = tự tạo.
  final GameScreenViewModel? viewModel;
  const GameScreen({super.key, this.viewModel});

  @override
  Widget build(BuildContext context) {
    final injected = viewModel;
    return injected != null
        ? ChangeNotifierProvider<GameScreenViewModel>.value(
            value: injected,
            child: const _GameScreenEventBridge(),
          )
        : ChangeNotifierProvider<GameScreenViewModel>(
            create: (context) => GameScreenViewModel()..startNewGame(),
            child: const _GameScreenEventBridge(),
          );
  }
}
```

Hai nhánh provider: `.value` khi test tiêm VM sẵn (test giữ
ownership — provider **không** dispose object do `.value` đưa vào);
còn lại `create:` tự tạo + provider tự dispose khi route pop. Đây
là "screen-scoped VM" — khác `MenuViewModel` (M11) sống lâu hơn:
VM game chết cùng route.

`..startNewGame()` trong `create` là đúng senior shape — và an toàn:
`create` chỉ chạy *lazy* khi ai đó `read` VM lần đầu (ở
`didChangeDependencies` của bridge), lúc đó **chưa có listener nào**
đăng ký (`watch` chỉ subscribe trong `build` sau đó) →
`notifyListeners` không đánh ai dirty. Cái cần defer là *mutation
sau khi đã có listener* — ví dụ VM tiêm sẵn từ test — xử ở bước 2.

### Bước 2 — `_GameScreenEventBridge`: `StatefulWidget` duy nhất

(`game_screen.dart` giờ cần `import 'dart:async'` cho
`StreamSubscription`/`unawaited`; `WidgetsBinding` đã có qua
`material.dart`.)

```dart
class _GameScreenEventBridgeState extends State<_GameScreenEventBridge> {
  AppNavigationController? _navigationController;
  GameScreenViewModel? _viewModel;
  StreamSubscription<GameScreenUiEvent>? _uiEventSubscription;

  /// Chặn mở dialog chồng: mỗi GameDialogRequested chỉ mở MỘT
  /// showDialog đang chờ.
  var _dialogOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigationController = context.read<AppNavigationController>();
    _attachViewModel(context.read<GameScreenViewModel>());
  }

  void _attachViewModel(GameScreenViewModel viewModel) {
    if (_viewModel == viewModel) return;
    _uiEventSubscription?.cancel();
    _viewModel = viewModel;
    _uiEventSubscription = viewModel.uiEvents.listen(_handleUiEvent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _viewModel != viewModel) return;
      // VM tiêm sẵn (test) chưa start → mở intro ladder tại đây;
      // VM do `create` tạo đã `..startNewGame()` ngay khi read.
      if (viewModel.state.phase == GamePhase.notStarted &&
          viewModel.dialogState is GameDialogHidden) {
        viewModel.startNewGame();
      } else if (viewModel.dialogState is! GameDialogHidden) {
        // Event bắn trước khi subscribe (broadcast không buffer) —
        // dialog-state đã mở sẵn thì vẫn hiện dialog.
        unawaited(_showCurrentDialog());
      }
    });
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    super.dispose();
  }
}
```

Ba kỹ thuật lifecycle đáng học:

- **`context.read` trong `didChangeDependencies`** — không được
  `read` trong `build` khi chỉ cần giữ reference (subscription);
  `didChangeDependencies` là điểm đúng để bắt provider lần đầu.
- **Post-frame cho mutation/event**: `notifyListeners` hoặc
  `showDialog` gọi giữa `didChangeDependencies`/mount sẽ đánh
  provider element dirty giữa build → assert `!_dirty` — mọi việc
  đụng VM/dialog ở đây đều đi qua `addPostFrameCallback`.
- **Dialog-state là nguồn thật, event chỉ là tín hiệu**: broadcast
  *không buffer* — `GameDialogRequested` bắn trước khi subscribe sẽ
  mất. Bridge kiểm `dialogState` sau frame đầu: mở sẵn rồi thì
  `_showCurrentDialog()` trực tiếp, chưa thì `startNewGame()`
  (trường hợp VM tiêm của test — VM từ `create` đã tự start).
- **`_attachViewModel` idempotent** — guard `==` vì
  `didChangeDependencies` có thể chạy lại (locale đổi, dependency
  đổi); re-attach chỉ khi VM *thật sự* khác.

### Bước 3 — `PopScope`: back hệ thống → VM quyết định

```dart
  void _handleRouteBack() {
    final viewModel = _viewModel;
    if (viewModel == null) return;
    final dialog = viewModel.dialogState;
    if (dialog is GameDialogHidden) {
      viewModel.showConfirmExit();       // không dialog → hỏi thoát
      return;
    }
    // Intro ladder & dialog kết thúc: back BỊ BỎ QUA — bắt buộc nút.
    if (dialog is GameMoneyLadderDialog ||
        dialog is GameEndedDialog ||
        dialog is GameVictoryDialog) {
      return;
    }
    viewModel.dismissDialog();           // ConfirmExit/Explanation → đóng
  }
```

Và trong `build`:

```dart
return PopScope(
  canPop: false, // back không bao giờ pop route trực tiếp
  onPopInvokedWithResult: (didPop, result) {
    if (!didPop) _handleRouteBack();
  },
  child: Scaffold(...),
);
```

`PopScope` thay `WillPopScope` deprecated: `canPop: false`
chặn pop mặc định; `onPopInvokedWithResult` chạy *sau* quyết định
pop — `didPop == false` nghĩa là pop bị chặn và đây là lúc route
"ý định back" vào VM. Ý nghĩa nút back giờ là **hàm của
`dialogState`** — không còn "pop trần mất kết quả" của màn cũ.

:::note[showDialog vẫn là route — edge case đã xử lý]
Một dialog `showDialog` nằm *trên* `PopScope` trong stack route —
back hệ thống pop dialog trực tiếp, `PopScope` không thấy. Vì vậy
`_showCurrentDialog` (bước 4) phải xử lý `action == null` (back
đã pop dialog): terminal/ladder → **mở lại** dialog (senior bỏ qua
back — state vẫn giữ variant); confirm-exit/giải thích →
`dismissDialog`. Bỏ nhánh `action == null` là defect thật — đừng
bỏ nó.
:::

### Bước 4 — Event bridge: event một-lần → `showDialog`/`pop`

```dart
  void _handleUiEvent(GameScreenUiEvent event) {
    if (!mounted) return;
    switch (event) {
      case GameNavigateToMenuEvent():
        // Pop route game KÈM GameResult — transport M10 (→M22).
        _navigationController?.goBack(_viewModel?.buildGameResult());
      case GameDialogRequested():
        // Luôn post-frame: event đầu đến ngay trong
        // didChangeDependencies — push route giữa build = crash.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_showCurrentDialog());
        });
    }
  }

  Future<void> _showCurrentDialog() async {
    if (_dialogOpen) return;
    final viewModel = _viewModel;
    if (viewModel == null) return;
    final dialog = viewModel.dialogState;
    if (dialog is GameDialogHidden) return;

    _dialogOpen = true;
    final action = await showDialog<_GameDialogAction>(
      context: context,
      barrierDismissible: false, // dialog game bắt buộc chọn nút
      builder: (ctx) => _GameDialogHost(dialog: dialog, l10n: AppLocalizations.of(ctx)),
    );
    _dialogOpen = false;
    if (!mounted || _viewModel == null) return;

    if (action == null) {
      // Back pop route dialog TRỰC TIẾP — routing lại theo variant.
      if (dialog is GameMoneyLadderDialog ||
          dialog is GameEndedDialog ||
          dialog is GameVictoryDialog) {
        unawaited(_showCurrentDialog()); // mở lại — senior bỏ qua back
        return;
      }
      viewModel.dismissDialog();
      return;
    }
    switch (action) {
      case _GameDialogAction.dismiss:    viewModel.dismissDialog();
      case _GameDialogAction.backToMenu: viewModel.backToMenu();
      case _GameDialogAction.playAgain:  viewModel.playAgain();
    }
  }
```

Đây là **scaffold có chủ đích** (sẽ đến M21): `dialogState` là
nguồn thật cho *nội dung + nghĩa*, còn *cơ chế* `showDialog` sẽ bị
`GameDialogLayer` trong `Stack` thay ở M21. Chú ý pattern
`Navigator.pop(action)` → `switch` action → method VM: dialog
widget *không* gọi VM trực tiếp, nó trả enum — bridge biên dịch.
Điều này giữ dialog widget thuần (test render không cần VM).

`_GameDialogHost` (cuối file) là `AlertDialog` switch kiệt hợp trên
`dialog` — mỗi variant đổ title/màu/content/actions: ladder render
`items` (dải tiền đảo, level hiện tại cyan, safe-haven vàng),
explanation render `question/correctAnswer/explanation`, terminal
render `earnedAmount` + nút PLAY AGAIN/MENU.

### Bước 5 — `AppNavigationController` + `navigatorKey` + khóa dọc

`lib/navigation/app_navigation_controller.dart` — điều hướng không
cần `context`:

```dart
class AppNavigationController {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<GameResult?> openGame() {
    return _push<GameResult>(
      MaterialPageRoute<GameResult>(builder: (_) => const GameScreen()),
    );
  }

  void goBack<T extends Object?>([T? result]) {
    final navigator = _navigator;
    if (navigator.canPop()) navigator.pop(result);
  }

  NavigatorState get _navigator {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      throw StateError('navigatorKey is not attached to a Navigator.');
    }
    return nav;
  }
}
```

`GlobalKey<NavigatorState>` là "tay cầm" vào `NavigatorState` của
`MaterialApp` — controller push/pop mà không cần widget context.
Hai điểm khác senior có chủ đích: `openGame` trả `Future<GameResult?>`
và `goBack` nhận result — learner còn transport pop-result (M10)
cho tới M22; senior `openGame` trả `Future<void>` (không kết quả)
vì VM tự lưu profile.

`main.dart` gắn key + scope + khóa dọc:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Khóa dọc — game chỉ thiết kế cho portrait (y senior).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // ... repos ...
  final navigationController = AppNavigationController();
  runApp(AppDependencyScope(
    /* ... */ navigationController: navigationController,
    child: const AIMillionaireApp(),
  ));
}
```

```dart
MaterialApp(
  navigatorKey: context.read<AppNavigationController>().navigatorKey,
  // ...
)
```

Và `AppDependencyScope` nhận field `navigationController` bắt buộc
— test scope nào dựng app (menu tests) phải truyền nó.

`menu_screen.dart` thay `Navigator.push(MaterialPageRoute(...))`
bằng `await navigationController.openGame()` — `await` giữ nguyên:
route game pop kèm `GameResult`, menu `applyGameResult` như cũ.

### Bước 6 — Widget test màn mới

`test/widgets/game_screen_test.dart` — 10 test, tiêm VM mini qua
`GameScreen(viewModel: vm)`. Harness bắt buộc gồm hai lớp (thiếu
lớp nào cũng `ProviderNotFoundException`/navigator chết):

```dart
await tester.pumpWidget(
  Provider<AppNavigationController>.value(
    value: nav, // controller giữ navigatorKey riêng của test
    child: localizedTestApp(
      navigatorKey: nav.navigatorKey, // gắn key vào MaterialApp
      home: GameScreen(viewModel: vm),
    ),
  ),
);
```

Bridge `context.read<AppNavigationController>()` trong
`didChangeDependencies` → phải có provider; `goBack` đi qua
`navigatorKey` → key phải gắn vào `MaterialApp` thật. Coverage:

- intro ladder mở khi vào; đóng → câu hỏi + timer đếm;
- tap đáp án → pending → reveal xanh/đỏ → dialog giải thích → câu kế;
- back hệ thống: intro ladder & dialog kết thúc **bị bỏ qua**
  (vẫn mở), không-dialog → confirm-exit, confirm-exit → đóng;
- ✕ → confirm-exit → THOÁT → về menu + `GameResult` áp profile;
- victory → dialog chúc mừng; gameOver → dialog kết thúc.

## Android / Compose bridge

- **SIMILARITY:** `BackHandler { viewModel.onBack() }` của Compose
  ↔ `PopScope canPop:false` + `_handleRouteBack`; `LaunchedEffect`
  collect event ↔ `uiEvents.listen`.
- **IMPORTANT DIFFERENCE:** `navigatorKey` pattern giống
  `NavController` singleton; khác là Flutter key phải gắn tay vào
  `MaterialApp.navigatorKey` — quên gắn = `StateError` khi push.
- **DO NOT ASSUME:** `PopScope` không chặn dialog pop — dialog là
  route khác; back ưu tiên route trên cùng (dialog), không phải
  page (edge case đã xử trong bridge).

## Senior project connection

- `lib/screens/game_screen.dart` (senior) — `GameScreen` stateless
  + `_GameScreenEventBridge` + `_GameDialogLayer` trong `Stack`;
  learner giữ `showDialog` scaffold → M21.
- `lib/navigation/app_navigation_controller.dart` (senior) — port
  trừ chữ ký `openGame`/`goBack` (result transport → M22).
- `lib/main.dart` (senior) — `SystemChrome.setPreferredOrientations
  ([DeviceOrientation.portraitUp])` verbatim.

## Chạy và quan sát

```bash
flutter analyze  # sạch
flutter test     # 126/126
flutter run      # hoặc build web — chơi thật: intro → 15 câu → thắng/thua
```

Quan sát: tap tiền giữa ván → timer *đứng* (pause); đóng dialog →
đếm tiếp. Back hệ thống ở màn game → confirm-exit, không pop trần.

## Tự làm — ai sở hữu gì trên màn mới

Trả lời từng câu **bằng chữ** trước khi mở đáp án — đây là phần kiến
trúc của màn, không phải cú pháp:

1. `_GameScreenEventBridge` là `StatefulWidget` riêng chỉ để giữ một
   `StreamSubscription`. Vì sao **không** `listen` ngay trong
   `GameScreen` (stateless) hoặc trong VM — hậu quả của từng cách?
2. `PopScope(canPop: false, …)` nghĩa là **VM quyết** chứ không phải
   hệ thống. Trace: user bấm back khi dialog kết quả đang mở → gọi
   gì trên VM → VM emit state nào → widget nào nhìn thấy gì?
3. `GameScreen` (stateless, chỉ tạo `ChangeNotifierProvider`) —
   nếu bạn đặt provider này lên `main()` tầng app thay vào, hai hậu
   quả gì? (gợi: VM sống qua mọi ván? `dispose` khi nào?)
4. `AppNavigationController` + `navigatorKey` được tạo ở tầng nào —
   và vì sao `MaterialApp` phải nằm *dưới* nó?

<details><summary>Đáp án</summary>

1. `listen` cần `dispose`/`cancel` → cần `State`. `GameScreen`
   stateless không có lifecycle để huỷ → subscription rò. Trong VM:
   VM là nguồn *phát* event — tự listen event của chính mình vòng
   quanh là sai ranh giới (VM không biết `BuildContext`/Navigator
   để `showDialog`/`pop`). Bridge = vị trí duy nhất có cả lifecycle
   lẫn context.
2. System back → `onPopInvokedWithResult` (canPop đã chặn pop) →
   `_handleRouteBack()` trong bridge *đọc* `viewModel.dialogState`:
   đang có dialog → gọi `viewModel.dismissDialog()` (VM emit state
   đóng dialog, UI đổi theo); chưa có dialog → gọi
   `viewModel.showConfirmExit()` — *quyết định "back làm gì" nằm ở
   VM qua các method của nó, widget chỉ đọc state và route*. Route
   không bao giờ pop trừ khi VM cho phép.
3. VM sống suốt app → timer/flowToken/subscriptions của ván trước
   dính sang ván sau; `dispose` không bao giờ được gọi khi thoát màn
   → đồng hồ cũ vẫn tick. Phạm vi màn là đúng: VM sinh/chết cùng
   `GameScreen`.
4. Tầng app (trong `AppDependencyScope`), trên `MaterialApp` —
   `navigatorKey` phải được gán vào `MaterialApp` nên controller
   phải tồn tại *trước* và *ngoài* nó; dialog route cũng cần thấy
   controller → phải trên Navigator.

</details>

## Kiểm tra hiểu biết

1. `create: … ..startNewGame()` gọi `notifyListeners` ngay khi VM
   được tạo — vì sao không crash `!_dirty`?
   → `create` lazy: chạy khi bridge `read` trong
   `didChangeDependencies`, lúc đó chưa có listener nào (`watch`
   subscribe sau trong `build`) — notify vào hư không. Cái phải
   defer post-frame là mutation *sau khi đã có listener* (VM tiêm,
   dialog events).
2. `canPop: false` + `onPopInvokedWithResult` — `didPop` là gì?
   → `true` nếu route đã pop; `false` = pop bị chặn, đây là lúc
   route ý định back vào VM.
3. Vì sao `_GameDialogHost` trả `enum _GameDialogAction` thay vì
   gọi `viewModel.dismissDialog()` trực tiếp?
   → Dialog widget thuần — không cần biết VM; bridge biên dịch
   action → method, dialog test render được độc lập.
4. Hai nơi `navigationController` xuất hiện trong app?
   → `AppDependencyScope` (DI) + `MaterialApp.navigatorKey` (gắn key).

## Sai lầm thường gặp

- **`context.read` trong `build`** cho subscription — phải ở
  `didChangeDependencies`; `watch` mới thuộc `build`.
- **Quên cancel `_uiEventSubscription`** trong `dispose` → leak.
- **`showDialog` không post-frame** — event đầu đến giữa
  `didChangeDependencies`, push route lúc đó crash.
- **Quên `action == null` branch** — back pop dialog trực tiếp,
  bỏ nhánh này = terminal dialog bị thoát chui (bug đã từng gặp khi port).

## Ta cố ý chưa thêm

- `GameDialogLayer` trong `Stack` + dismiss animation — M21.
- Thanh `featureButtons` (50:50/poll/AI) — M20.
- `GameShareResultEvent` + SharePlus — đến M27.
- `openGame` trả `Future<void>` (không result payload) + VM-side
  save — M22.

## Checkpoint hoàn thành

- [ ] `game_screen.dart` = stateless shell + `_GameScreenEventBridge`
  + `_GameDialogHost`; không field game trong `State` ngoài
  `_viewModel`/subscription/`_navigationController`/`_dialogOpen`.
- [ ] `AppNavigationController` trong DI scope + `navigatorKey` gắn
  `MaterialApp`; menu mở game qua `openGame()`.
- [ ] `main.dart` khóa `portraitUp`.
- [ ] `flutter analyze` sạch, `flutter test` = **126/126**.
