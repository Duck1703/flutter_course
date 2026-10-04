---
title: "Bài 05 — Lớp dialog của menu: dialog là STATE, không phải event (trọng tâm)"
description: "Kiến trúc trọng tâm của milestone: `MenuDialogState` sealed 5-variant (`None/Leaderboard/Settings/Auth/SignOut`, `isVisible`, `transitionKey=>runtimeType`) → `MenuDialogLayer` (`SizedBox.expand` + `AnimatedSwitcher` fade `dialogMotionLong` + switch kiệt hợp → 4 scope keyed `ValueKey(transitionKey)`) → `MenuDialogBackdrop` (`ClipRect`+`BackdropFilter` blur + scrim + tap ngoài dismiss + `GestureDetector(onTap:(){})` nuốt tap-trong + `DesignFrame` + `foregroundOverlay` slot) → `MenuScreenView` Stack (background→column→`Positioned.fill(layer)`→`Positioned.fill(overlayScope)`) + `PopScope(canPop: !isVisible)` + `_dialogDismissLocked` (sign-out `isLoading`→`onDismissLockChanged`) → `MenuScreenViewModel.dialogState` (equality-guard `_setDialogState`) → `menu_screen.dart` 87-dòng 2-event bridge. Bốn event `*Requested` + 3 `showXxxDialog` RETIRE — zero `showDialog` trong `lib/`. +24 test: 369/369."
sidebar:
  order: 5
  label: Lớp dialog menu
---

# Bài 05 — Lớp dialog của menu: dialog là STATE, không phải event

## Mục tiêu

Đây là bài **trọng tâm** của M29 — bài duy nhất đổi *kiến trúc*
chứ không chỉ đổi pixel. Sau bài này bạn sẽ:

- Giải thích được **vì sao "đang mở dialog X" là state, không
  phải event** — và nhận diện được ranh giới: điều gì xứng là
  event một lần (navigate ra ngoài, snackbar tự tắt), điều gì
  buộc phải là state (mọi thứ tồn tại qua nhiều frame).
- Đọc trọn pipeline: `MenuDialogState` (sealed, 5 variant) →
  `MenuDialogLayer` (`AnimatedSwitcher` + `ValueKey(
  transitionKey)`) → scope (VM scoped + `MenuDialogBackdrop`)
  → `MenuScreenView` (`Stack` + `PopScope` + dismiss-lock).
- Hiểu `PopScope(canPop: !dialogState.isVisible)` — nút back
  của hệ thống *trở thành* "đóng dialog" thay vì "pop route".
- Hiểu `_dialogDismissLocked` — cơ chế "đang sign-out thì
  không cho đóng": lock sống ở view, nguồn (`isLoading`) sống
  ở dialog-VM, truyền lên qua `onDismissLockChanged`.
- Biết **4 event class + 3 `showXxxDialog` route-fn đã retire
  ở đâu** — và vì sao `grep showDialog lib/` trả trống là
  *kết quả*, không phải *mục tiêu* (mục tiêu là đúng kiến trúc;
  grep sạch chỉ chứng minh nó).

## Bạn đang ở đâu

Mọi bài trước chuẩn bị cho bài này. Vấn đề cũ — kéo dài từ
M14 — là menu **chưa bao giờ thật sự sở hữu dialog của nó**:

```text
learner (trước bài này) — mô hình ROUTE:
  MenuViewModel.events ──MenuSettingsRequested──► screen
       screen: showDialog(builder: (_) => SettingsDialog())
       → dialog là ROUTE phủ lên navigator
       → dismiss = Navigator.pop (route-level)
       → VM không biết dialog đang mở hay không!

  MenuScreenUiEvent: 6 variant — Game, SnackBar,
       + SettingsRequested/LeaderboardRequested/
         AuthRequested/SignOutRequested  (4 cái "xin mở dialog")

senior — mô hình IN-TREE (A-21):
  viewModel.dialogState: MenuDialogState  (persistent)
  view Stack: … → Positioned.fill(MenuDialogLayer)
  PopScope(canPop: !dialogState.isVisible)
  dismiss = _setDialogState(MenuDialogNone()) — state đổi,
       widget cây-render đổi theo, không route nào dính
```

 ghi ngắn gọn: *"Settings entry dispatch → `showDialog`
events"* — mô hình interim chọn event vì M14 chưa có in-tree
layer phía menu (game đã có từ M21). Bài này converge.

## Vì sao việc này quan trọng ngay bây giờ

Đây là điểm lệch kiến trúc **lớn nhất còn lại** giữa learner
và senior. Nó không phải chi tiết nhỏ: nó quyết định

- back-press hoạt động thế nào (route-pop vs state-transition),
- dialog có animate-in/out không (`AnimatedSwitcher` cần in-tree),
- sign-out-loading có chặn được dismiss không (route không có
  khái niệm "lock"),
- VM có biết dialog đang mở không (`dialogState.isVisible` —
  câu hỏi route-model không trả lời được),
- và test: `menu_dialog_layer_test` pump *state* vào layer —
  không pump route.

## Bạn đã biết gì

| Đã học | Ở đâu | Nhắc ngắn |
|---|---|---|
| In-tree dialog layer | M21 | Game đã làm chính việc này: dialog là widget trong `Stack`, render-by-state — menu chỉ *áp dụng lại pattern đã học* |
| sealed family + exhaustive switch | M15 | `GameDialogState` 9-variant → `MenuDialogState` 5-variant cùng chiều |
| UI event vs UI state | M14, M21 | Event = việc đã xảy ra một lần; state = điều đang đúng bây giờ — bài này *dùng* ranh giới đó để phán xét |
| `AnimatedSwitcher` | M26 | crossfade khi `child` đổi — keyed transition |
| `ValueKey(runtimeType)` | M21 | key theo loại: variant đổi → re-animate, cùng variant → không |
| `BackdropFilter` + scrim | M21, M29·02 | haze = blur + lớp mờ + tap ngoài dismiss |
| `PopScope` | M19 | chặn/tuỳ biến back của hệ thống |
| `showDialog`/dialog-as-route | M09 | **chính mô hình interim đang bị retire** — game đã thay nó ở M21, menu thay ở đây |
| Dialog-scoped VM | M16, M29·02 | scope = provider-subtree có VM riêng |
| Sweep | M29·01 | verbatim + grep-verify retirements |

## Mental model trọng tâm — "event hỏi 'vừa xảy ra gì', state trả lời 'đang là gì'"

Đây là chỗ cần đọc chậm. Hai kênh bên cạnh nhau trong
**cùng một VM**:

```text
┌─ MenuScreenViewModel ───────────────────────────────┐
│  MenuDialogState _dialogState    ← STATE: "đang mở   │
│    = const MenuDialogNone();        gì bây giờ"      │
│    render liên tục; notifyListeners khi ĐỔI          │
│                                                    │
│  StreamController<MenuScreenUiEvent> _events ← EVENT:│
│    "vừa xảy ra việc gì" — bắn một lần, listener     │
│    phản-ứng, không ai "render theo nó"               │
└────────────────────────────────────────────────────┘

  Câu hỏi phán-xét: điều này TỒN-TẠI hay XẢY-RA?

  "Settings dialog đang mở"          → TỒN-TẠI → state
  "Back đã được nhấn"                → XẢY-RA   → input
  "User xin đi vào game"             → XẢY-RA   → event
     (navigator đi, không ai render-lại nó)
  "Snackbar hiện rồi tự tắt"         → XẢY-RA   → event
     (hiệu-ứng-hết-mình, không phải màn-hình)
  "Sign-out đang loading"            → TỒN-TẠI → state
     (nó KHÓA dismiss — một thứ tồn-tại không
      thể là event bắn-qua)
```

:::caution[Lỗi tư duy mà 4 event `*Requested` phạm phải]
`MenuSettingsRequested` hỏi *"user vừa xin settings"* — đúng
là event. Nhưng listener của nó (`showDialog`) biến event
thành **route** — và route tự sở hữu vòng đời: VM bắn event
xong quên luôn; dialog sống ở chỗ VM không nhìn thấy. Hệ quả:
VM không trả lời được "dialog nào đang mở", back-press là
chuyện của navigator (không của VM), và mở dialog từ dialog
(account-row → auth) phải *pop route cũ rồi push route mới*
— hai thao tác route vụn thay vì một state-transition.
Đó là dấu hiệu nhận diện: **khi bạn cần hỏi "hiện tại đang
là gì" mà kênh của bạn chỉ nói được "vừa xảy ra gì" — bạn
đang dùng event cho thứ đáng là state.**
:::

Và chiều ngược lại cũng đúng: đừng nhét *mọi thứ* vào state.
`MenuGameRequested` vẫn là event vì **sau khi navigate, không
còn gì để "đang là"** — màn menu biến mất khỏi foreground.
Giữ 2-event nhỏ cũng là thắng lợi kiến trúc, không phải tiếc
nuối.

## Dart cần dùng

| Dart | Vai trò ở đây | Xem lại |
|---|---|---|
| `sealed class MenuDialogState` + 5 `final class` variant | toàn bộ không gian dialog là 5 giá trị biết trước | |
| `bool get isVisible => this is! MenuDialogNone` | predicate trên sealed — một định nghĩa cho mọi variant | |
| `Object get transitionKey => runtimeType` | key từ type — cùng variant ⇒ cùng key | / |
| `==`/`hashCode` per-variant (const `0..4`) | `_setDialogState` equality-guard chặn notify thừa | |
| `switch (state) { MenuDialogNone() => … }` | layer render kiệt hợp — variant mới = compile đòi nhánh | |
| `switch (event) { case MenuGameRequested(): … }` | event-bridge switch kiệt hợp trên 2-variant | |

## Flutter cần dùng

| Flutter | Vai trò ở đây | Xem lại |
|---|---|---|
| `AnimatedSwitcher(duration, reverseDuration, switchIn/OutCurve, transitionBuilder)` | fade giữa `SizedBox.shrink` ↔ scope | |
| `ValueKey(state.transitionKey)` trên scope | re-animate khi variant đổi | |
| `BackdropFilter` + `ClipRect` + `ColoredBox` scrim | haze che nền | |
| `GestureDetector` đôi (ngoài=`onDismiss`, trong=`onTap:(){}`) | tap ngoài đóng / tap trong nuốt | -family |
| `PopScope(canPop:, onPopInvokedWithResult:)` | back → dismiss-state thay vì pop | |
| `Positioned.fill` × 2 trong `Stack` | layer + overlay phủ cùng hình | |
| `AnnotatedRegion<SystemUiOverlayStyle>` | status-bar sáng trên nền tối | M22-era |

## Ví dụ độc lập — state-render vs event-route

```dart
/// VÍ DỤ ĐỘC LẬP — logic, không cần UI thật.
sealed class DialogState { const DialogState(); }
final class None extends DialogState { const None(); }
final class Settings extends DialogState { const Settings(); }
final class Auth extends DialogState { const Auth(); }

extension on DialogState {
  bool get isVisible => this is! None;
}

/// Render-by-state: hàm thuần của state hiện-tại.
String render(DialogState s) => switch (s) {
  None() => 'menu-trống',
  Settings() => 'menu + haze + settings-card',
  Auth() => 'menu + haze + auth-card',
};

void main() {
  var state = const None() as DialogState;
  print(render(state));           // menu-trống
  state = const Settings();       // ← "mở" = đổi state
  print(render(state));           // haze + card
  print('back? isVisible=${state.isVisible} → pop→None');
  state = const Auth();           // mở-dialog-từ-dialog = MỘT phép gán
  print(render(state));
}
```

## Android / Compose bridge

:::note[Android / Compose bridge — "dialog trong composition vs dialog route"]
- **SIMILARITY**: `MenuDialogState`→`MenuDialogLayer` giống
  Compose `var dialog by remember{mutableStateOf<Dialog?>(null)}`
  + `when(dialog){…}` — dialog là *hàm của state*, recomposition
  vẽ/xoá nó. `showDialog`-route tương đương `dialog.show(
  fragmentManager)` — vòng đời tách khỏi state.
- **IMPORTANT DIFFERENCE**: `PopScope(canPop: !isVisible)` —
  back-press đọc *state* thay vì stack: không giống
  `onBackPressed` tự quản lý; nó là *declaration* "route này
  không pop được khi dialog đang mở", callback quyết định
  state tiếp theo.
- **DO NOT ASSUME**: đừng nghĩ `AnimatedSwitcher` chỉ là trang
  trí — nó **là lý do** in-tree-layer thắng route: route khó
  crossfade giữa hai dialog; `ValueKey(transitionKey)` đổi
  variant = một phép đổi child = fade mượt.
:::

## Senior project connection

| File senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/view_models/menu/menu_dialog_state.dart` (57d) | sealed 5-variant verbatim — `isVisible`, `transitionKey => runtimeType`, hash `0..4` |
| `lib/widgets/menu/menu_dialog_layer.dart` | `AnimatedSwitcher` + switch kiệt hợp → 4 scope keyed |
| `lib/widgets/menu/menu_dialog_backdrop.dart` | haze + tap ngoài + `foregroundOverlay` slot |
| `lib/widgets/menu/menu_screen_view.dart` | Stack + `PopScope` + `_dialogDismissLocked` |
| `lib/view_models/menu/menu_screen_view_model.dart` | `dialogState` + `_setDialogState` guard + 2-event stream |
| `lib/view_models/menu/menu_screen_ui_event.dart` | **2 variant** — Game/SnackBar; 4 `*Requested` không tồn tại |
| `lib/screens/menu_screen.dart` | `_MenuScreenEventBridge` widget riêng, 87 dòng |
| `lib/widgets/menu/{auth,settings,leaderboard}/*_scope.dart` | 4 scope — `ChangeNotifierProvider(create:)` + bridge + `MenuDialogBackdrop` |
| `test/widgets/menu_dialog_layer_test.dart` (16) | state→layer: variant, key, switch, dismiss |
| `test/menu_screen_view_model_test.dart` (22) | dialogState idempotent, dismiss, event một lần |
| `test/sealed_state_test.dart` (5) | exhaustive: 2 menu-events + 5 menu-states + 9 game-states |

:::tip[Suy ra trước — đâu là state, đâu là event]
Mental model vừa phân "event hỏi vừa-xảy-ra-gì, state trả-lời
đang-là-gì" — vận dụng ngay, trước khi thấy sealed family:

1. `MenuDialogState` sẽ có bao nhiêu variant? Đếm các dialog menu
   có thể mở: Settings / Sign-out / Confirm-exit / Help… — liệt kê
   đủ, không nhìn code bên dưới.
2. Mỗi variant cần *dữ liệu đi kèm* gì? (dialog chỉ cần enum, hay
   cần payload — vd dialog lỗi cần message?)
3. Bạn dự đoán nó là `sealed class` hay `enum`? Viện dẫn một lý do
   cho phía senior.
:::
## Build it step by step — đọc pipeline từ dưới lên

### Bước 1 — `MenuDialogState`: không gian dialog là 5 giá trị

```dart
// learner-app/lib/view_models/menu/menu_dialog_state.dart (gần-trọn)
sealed class MenuDialogState {
  const MenuDialogState();
  bool get isVisible => this is! MenuDialogNone;
  Object get transitionKey => runtimeType;
}

final class MenuDialogNone extends MenuDialogState { /* ==/hash: 0 */ }
final class MenuDialogLeaderboard extends MenuDialogState { /* 1 */ }
final class MenuDialogSettings extends MenuDialogState { /* 2 */ }
final class MenuDialogAuth extends MenuDialogState { /* 3 */ }
final class MenuDialogSignOut extends MenuDialogState { /* 4 */ }
```

Ba quyết định nhỏ, ba cái lợi lớn:
- **`sealed`** → switch ở layer *bắt buộc* kiệt hợp; thêm
  variant (ví dụ `MenuDialogHelp`) = compile chỉ ngay mọi chỗ
  phải xử lý.
- **`isVisible` trên base** → mọi nơi hỏi "có dialog không" đều
  một câu trả lời — `PopScope`, backdrop, test.
- **`transitionKey => runtimeType`** → key-theo-*loại* gói sẵn
  trong state; layer khỏi `state.runtimeType` tay.

### Bước 2 — `MenuScreenViewModel`: mở dialog = gán state

```dart
// learner-app/lib/view_models/menu/menu_screen_view_model.dart (trích)
MenuDialogState _dialogState = const MenuDialogNone();
MenuDialogState get dialogState => _dialogState;

void requestLeaderboardDialog() =>
    _setDialogState(const MenuDialogLeaderboard());
void requestSettingsDialog() =>
    _setDialogState(const MenuDialogSettings());
void requestAuthAction() => _setDialogState(
  _authState is AuthSessionAuthenticated
      ? const MenuDialogSignOut()     // đã-login → hỏi sign-out
      : const MenuDialogAuth(),       // guest → mở auth
);
void requestGame() => _events.add(const MenuGameRequested());
void dismissCurrentDialog() => _setDialogState(const MenuDialogNone());

bool _setDialogState(MenuDialogState state) {
  if (_isDisposed || _dialogState == state) return false; // guard
  _dialogState = state;
  notifyListeners();
  return true;
}
```

:::note[Đọc kỹ `requestAuthAction`]
Avatar/profile-pill gọi *một* method — VM nhìn `_authState`
quyết định variant: đã login → `SignOut`, guest → `Auth`.
**Chính sách nằm trong VM**, widget không `if (isAuthenticated)`
trước khi gọi. Và `_setDialogState` trả `bool` + guard
`_dialogState == state` → `requestSettingsDialog()` gọi hai
lần chỉ notify **một** lần (test 22-case kiểm đúng điều đó:
idempotent).
:::

### Bước 3 — `MenuDialogLayer`: state → widget, keyed theo loại

```dart
// learner-app/lib/widgets/menu/menu_dialog_layer.dart (trích)
return SizedBox.expand(
  child: AnimatedSwitcher(
    duration: AppTokens.dialogMotionLong,
    reverseDuration: AppTokens.dialogMotionLong,
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.linear,
    transitionBuilder: (child, animation) =>
        FadeTransition(opacity: animation, child: child),
    child: _buildDialog(dialogState),
  ),
);

Widget _buildDialog(MenuDialogState state) => switch (state) {
  MenuDialogNone() => const SizedBox.shrink(
      key: ValueKey('menu-dialog-none')),
  MenuDialogLeaderboard() => MenuLeaderboardDialogScope(
      key: ValueKey(state.transitionKey), onDismiss: onDismiss),
  MenuDialogSettings() => MenuSettingsDialogScope(
      key: ValueKey(state.transitionKey), onDismiss: onDismiss,
      profile: profile, isAuthenticated: isAuthenticated,
      onAccountAction: onAccountAction),
  MenuDialogAuth() => MenuAuthDialogScope(
      key: ValueKey(state.transitionKey), onDismiss: onDismiss),
  MenuDialogSignOut() => MenuSignOutDialogScope(
      key: ValueKey(state.transitionKey), onDismiss: onDismiss,
      onDismissLockChanged: onDismissLockChanged ?? (_) {}),
};
```

:::tip[Key là gì để làm gì — đọc chậm]
`AnimatedSwitcher` animate khi `child` **đổi key**. Key =
`ValueKey(transitionKey)` = `ValueKey(runtimeType)`:
- `None→Settings`: key đổi → old fade-out, new fade-in.
- `Settings→Auth` (account-row → sign-in): key đổi →
  **crossfade trực tiếp giữa hai dialog** — điều route-model
  không làm được gọn.
- `Settings→Settings` (rebuild cùng variant): key giống →
  không re animate — đúng, vì đây là *cùng một dialog*.
:::

### Bước 4 — Scope + backdrop: dialog sống trong cây, VM sống trong dialog

```dart
// learner-app/lib/widgets/menu/menu_dialog_backdrop.dart (trích)
return ClipRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: AppTokens.dialogHazeBlurSigma,
      sigmaY: AppTokens.dialogHazeBlurSigma),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,                      // ← tap NGOÀI: xin đóng
      child: ColoredBox(
        color: AppTokens.dialogHazeScrim,    // ← lớp mờ trên nền
        child: Stack(fit: StackFit.expand, children: [
          SafeArea(child: Center(child: DesignFrame(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},                  // ← tap TRÊN card: nuốt
              child: child),
          ))),
          if (foregroundOverlay != null)
            Positioned.fill(child: foregroundOverlay!), // slot Bài 02
        ]),
      ),
    ),
  ),
);
```

Hai `GestureDetector` lồng nhau là toàn bộ ngữ nghĩa
"dismiss bằng tap ngoài": detector ngoài `opaque` hứng mọi tap
trong vùng mờ → gọi `onDismiss`; detector trong (quanh card)
cũng `opaque` với `onTap: () {}` — **ăn tap rồi không làm gì**
để tap trên card không lan ra ngoài. Không có "dialog.dismiss()"
— chỉ có `onDismiss` bubble về `dismissCurrentDialog()` →
state về `None` → layer render `SizedBox.shrink` → widget
unmount tự nhiên.

Mỗi scope (4 cái) làm đúng một việc: `ChangeNotifierProvider
(create: ctx.read repos)` → bridge → `MenuDialogBackdrop`
→ dialog-widget. **VM sinh và chết cùng scope**: đổi
variant → scope unmount → Provider dispose VM → subscribe
hủy — không leak, không cần `dispose` tay ở screen.

### Bước 5 — `MenuScreenView`: Stack đặt layer, `PopScope` đổi nghĩa back

```dart
// learner-app/lib/widgets/menu/menu_screen_view.dart (trích)
return PopScope(
  canPop: !viewModel.dialogState.isVisible,      // ← có dialog: cấm pop
  onPopInvokedWithResult: (didPop, _) {
    if (!didPop &&                               // pop bị chặn → back còn "nguyên"
        viewModel.dialogState.isVisible &&
        !_dialogDismissLocked) {                 // ← lock của sign-out
      viewModel.dismissCurrentDialog();          // back = state→None
    }
  },
  child: Scaffold(
    backgroundColor: Colors.transparent,
    body: Stack(children: [
      const Positioned.fill(child: GameScreenBackground()),
      Column(children: [/* topInset, header, content, CTA, bottomInset */]),
      Positioned.fill(child: MenuDialogLayer(     // ← dialog trong cùng Stack
        dialogState: viewModel.dialogState,
        onDismiss: _requestDialogDismiss,
        onDismissLockChanged: _setDialogDismissLocked,  // ← lock lên đây
        // …
      )),
      const Positioned.fill(child: OnboardingOverlayScope()), // trên cùng
    ]),
  ),
);
```

:::caution[`_dialogDismissLocked` — khoá sống ở view, lý do sống ở dialog]
`MenuSignOutDialogScope` theo dõi `vm.isLoading` và báo lên
`onDismissLockChanged(bool)`. View giữ `_dialogDismissLocked`
và chặn **hai** đường đóng: `PopScope`-dismiss (back) lẫn
`_requestDialogDismiss` (tap ngoài). Vì sao không để VM quyết?
— vì khoá là *thuộc tính hành vi của màn hình* ("màn này, khi
dialog con bận, không cho đóng"), trong-khi `isLoading` là
*state của dialog*. Hai tầng, một callback nối. Đây là câu trả
lời cho "event vs state" một lần nữa: **lock là điều đang đúng
→ đi bằng callback-state-propagation, không phải event.**
:::

Thứ tự-Stack cũng là ngữ nghĩa: background dưới cùng → column
nội dung → `MenuDialogLayer` (haze phủ *trên* nội dung) →
`OnboardingOverlayScope` **trên hết** — onboarding là overlay
của cả màn, kể cả trên dialog.

### Bước 6 — `menu_screen.dart`: 87 dòng, đúng-2-việc

```dart
// learner-app/lib/screens/menu_screen.dart (trích — toàn-bộ-bridge)
void _handleUiEvent(MenuScreenUiEvent event) {
  switch (event) {
    case MenuGameRequested():
      _navigationController.openGame();
    case MenuSnackBarRequested(:final message):
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
```

```dart
// learner-app/lib/view_models/menu/menu_screen_ui_event.dart (trọn)
sealed class MenuScreenUiEvent { const MenuScreenUiEvent(); }
final class MenuGameRequested extends MenuScreenUiEvent { … }
final class MenuSnackBarRequested extends MenuScreenUiEvent {
  final String message; const MenuSnackBarRequested(this.message); }
```

Screen chỉ còn: provide VM (`ChangeNotifierProvider(create:
…)..loadUserProfile()`), cầu nối event (subscribe trong
`didChangeDependencies`, `==`-guard, dispose-cancel — pattern
y hệt game M21), và `AnnotatedRegion` cho status-bar. **Không
một dòng biết dialog tồn tại** — đúng, vì dialog không còn là
việc của route shell.

### Bước 7 — Retirements: grep là biên bản

```text
XOÁ (zero import sau port — điều-kiện-xoá, không phải quyết-định-cảm-tính):
  MenuSettingsRequested / MenuLeaderboardRequested /
  MenuAuthRequested / MenuSignOutRequested      ← 4 event class
  showMenuSettingsDialog / showMenuLeaderboardDialog /
  showMenuAuthDialog                             ← 3 route-fn
  MenuViewModel → MenuScreenViewModel (file+class rename,
                   compile-forced — senior convention *_screen_view_model)
  lib/widgets/menu/settings_dialog.dart          ← đã xoá Bài 02

VERIFY:
  grep -rn "showDialog" lib/   → 0 call-site
     (chỉ 1 comment lịch-sử trong game_session_state_data.dart)
  grep -rn "Menu.*Requested" lib/ → chỉ còn Menu{Game,SnackBar}Requested
  grep -rn "MenuTokens" lib/   → 0 (file xoá Bài 06)
```

## Hiểu code — 7 chi tiết dễ trượt

**1. `SizedBox.expand` bọc `AnimatedSwitcher`** — layer luôn
full-khung kể cả khi `None` (shrink-child vẫn expand-khung);
haze tới từ backdrop của dialog chứ không của layer — layer
chỉ điều phối "child nào".

**2. `transitionKey` là `Object`, không `Type`** — getter trả
`Object` để `ValueKey` nhận; `runtimeType` trên sealed-base
cho *variant-type* (không phải instance-hash): `const
MenuDialogSettings()` hai lần = cùng type → cùng key →
không re animate.

**3. `onDismissLockChanged ?? (_) {}`** — layer cho phép null
callback; sign-out-scope *bắt buộc* callback → layer dùng
no-op-khi-null. Chỉ một dialog cần lock → optional ở layer,
required ở scope đó.

**4. `didPop` trong `onPopInvokedWithResult`** — callback chạy
*sau* quyết định pop: `canPop:false` → `didPop:false` → ta
dismiss-state; `canPop:true` (không dialog) → `didPop:true` →
không làm gì. Đọc sai = dismiss nhầm khi thực sự pop.

**5. `_attachViewModel` chạy ở `didChangeDependencies`, không
`initState`** — vì nó `context.read<MenuScreenViewModel>()`;
`initState` chưa an toàn đọc ancestor provider. `==`-guard
chặn re-subscribe khi dependency-re-run (Provider trả cùng-
VM → guard thoát sớm).

**6. `MenuGameRequested` vẫn event vì *đích đến nằm ngoài màn*** —
navigate sang route khác; VM menu không render game. Ngược
lại "settings đang mở" *hiển thị trong màn menu* → state.
Ranh giới không phải "mở/đóng" mà là **"render có thuộc màn
này không"**.

**7. `MenuDialogNone` vẫn là một variant có tên** — không
`null`: `null` sẽ cần `switch` `case null` + `state?.isVisible`
lỏng lẻo; variant danh nghĩa cho exhaustive + predicate sạch.

## Chạy và quan sát

```bash
cd learner-app
flutter test test/widgets/menu_dialog_layer_test.dart \
             test/menu_screen_view_model_test.dart \
             test/sealed_state_test.dart
# 16 + 22 + 5 — layer, VM, exhaustive
flutter test                          # 369/369 (+24)
grep -rn "showDialog\|MenuTokens\|MenuSettingsRequested\|\
MenuLeaderboardRequested\|MenuAuthRequested\|MenuSignOutRequested" lib/
# → chỉ comment lịch-sử game_session_state_data.dart — sạch
```

Quan sát: mở Settings → nền mờ fade in → card trượt vào; nhấn
back → card fade-out (không thoát app); mở Settings → account-
row → Sign in → settings fade-ra/auth fade vào (crossfade-1-
phép); đăng xuất đang chạy → back và tap ngoài đều im lặng
(dismiss-locked).

## Thử nghiệm

| Thử | Dự đoán | Thực tế |
|---|---|---|
| Bỏ `key: ValueKey(state.transitionKey)` khỏi scope | Settings→Auth trông sao? | `AnimatedSwitcher` thấy "cùng child type" → **không animate** — dialog biến đổi không có fade. Key = tín hiệu "đây là dialog KHÁC" |
| `canPop: true` luôn (bỏ `!isVisible`) | Back khi settings mở? | Route pop ngay — settings biến mất cùng cả màn menu → app về màn trước/thoát. Back phải *gỡ lớp trên cùng* trước |
| 4 event `*Requested` giữ + thêm `dialogState` song song | Hai kênh cùng mở dialog? | Cùng mở được hai lần / mở rồi không đóng: hai nguồn truth. Đây là lý do retire là *toàn hoặc không* — giữ song song tệ hơn một bên sai |
| `onDismissLockChanged` không gọi khi sign-out xong | Lock kẹt mãi? | Scope gọi `isLoading` mỗi `notifyListeners` — attach-seed + addListener giữ lock đồng bộ; bỏ `widget.onDismissLockChanged(_dismissLocked)` trong `_attachViewModel` = kẹt true |

## Lỗi hay gặp

| Lỗi | Vì sao | Sửa |
|---|---|---|
| Dialog không animate khi đổi variant | thiếu `ValueKey(transitionKey)` | key theo loại trên scope |
| Back thoát app khi dialog mở | `canPop` không đọc `isVisible` | `PopScope(canPop: !dialogState.isVisible)` |
| Tap trên card đóng dialog | thiếu `GestureDetector(onTap:(){})` nuốt tap | backdrop: ngoài onDismiss / trong-opaque-empty |
| Sign-out loading vẫn đóng được | `onDismissLockChanged` không nối hoặc view không dùng lock | scope→layer→view callback + `_dialogDismissLocked` |
| `notifyListeners` vẫn gọi dù state không đổi | bỏ `==`-guard trong `_setDialogState` | guard trả `false` — test kiểm đúng một notify |
| Dialog mở bằng `showDialog` vẫn còn sót | route-fn chưa xoá | port state+layer trước, `grep showDialog` verify-zero rồi xoá |

## Tự làm

**PREDICT** — Một dev port `MenuDialogLayer` nhưng quên
`ValueKey(state.transitionKey)` — chỉ truyền `key:
ValueKey('dialog')` cho mọi scope. Hành vi gì xảy ra khi
`Settings→Auth`?

:::note[Gợi ý]
`AnimatedSwitcher` quyết định animate bằng gì — type của
child hay key?
:::

<details>
<summary>Đáp án</summary>

`AnimatedSwitcher` animate khi child **đổi key** (hoặc đổi
type khi không key). Mọi scope cùng key `'dialog'` → switcher
coi là *cùng widget* → không crossfade; subtree chỉ rebuild
với type mới (settings biến thành auth đột ngột, không fade).
Key-theo-`transitionKey` là cái làm cho hai dialog khác loại
thành hai child khác nhau.

</details>

**DEBUG** — Tester báo: "mở Sign-out, bấm confirm, đang
loading vẫn bấm back được — dialog biến mất giữa chừng". Code
view đã có `_dialogDismissLocked`. Tìm mắt xích gãy.

:::note[Gợi ý]
Lock có 3 mắt xích: VM `isLoading` → scope callback → view
field → PopScope/onDismiss. Kiểm từng mắt.
:::

<details>
<summary>Đáp án</summary>

Kiểm theo chuỗi: (1) `MenuSignOutDialogViewModel.isLoading`
có set-true khi confirm không; (2) `_MenuSignOutDialogBridge`
có `addListener(_handleViewModelChanged)` → `widget
.onDismissLockChanged(vm.isLoading)` không — và có **seed**
`onDismissLockChanged(_dismissLocked)` ngay `_attachViewModel`
không (thiếu seed = lock trễ một frame); (3) view truyền
`_setDialogDismissLocked` xuống `MenuDialogLayer.onDismiss
LockChanged` *và* layer truyền tiếp `?? (_) {}` xuống scope
chưa; (4) `_requestDialogDismiss`+`onPopInvoked` đều kiểm
`!_dialogDismissLocked` chưa — một backdrop dismiss không
kiểm lock vẫn đóng được dù PopScope chặn. Một mắt gãy = lock
vô dụng.

</details>

**PRODUCE** — Senior thêm `MenuDialogHelp` (dialog hướng dẫn).
Viết 4 thay đổi tối thiểu để nó hoạt động — không cần implement
scope thật.

:::note[Gợi ý]
Đi theo compiler: variant → switch ở layer → method ở VM →
(mở bằng gì?) — và nhớ `sealed` sẽ *đòi* những chỗ đó.
:::

<details>
<summary>Đáp án</summary>

```dart
// 1) menu_dialog_state.dart — thêm variant (hash 5)
final class MenuDialogHelp extends MenuDialogState { … }

// 2) menu_dialog_layer.dart — switch đòi nhánh (compile-error
//    nếu quên — đây là điểm của sealed):
MenuDialogHelp() => MenuHelpDialogScope(
    key: ValueKey(state.transitionKey), onDismiss: onDismiss),

// 3) menu_screen_view_model.dart — method mở:
void requestHelpDialog() => _setDialogState(const MenuDialogHelp());

// 4) chỗ-gọi (help-icon) → viewModel.requestHelpDialog();
```

`PopScope`/backdrop/lock **không cần sửa** — chúng chỉ hỏi
`isVisible`, variant mới tự được cover. Đây là lý do mua sealed:
thêm dialog = thêm giá trị, không thêm đường dây.

</details>

## Kiểm tra hiểu biết

**H: Nói một câu: vì sao dialog là state?** — Vì "đang hiển thị
gì" là điều đang đúng qua nhiều frame: nó quyết render, quyết
back, quyết lock — event chỉ nói được "vừa xảy ra", không giữ
được "đang là".

**H: `MenuGameRequested` vì sao được phép ở lại là event?** —
Vì sau-khi-navigate không còn gì để render: màn menu rời
foreground, không ai hỏi "game đang được request không". Event
xứng khi kết quả là rời đi hoặc hiệu ứng hết mình (snackbar).

**H: `PopScope` khác `WillPopScope` cũ ở chỗ nào?** — `PopScope`
tách `canPop` (declaration: route có được pop không — lúc này
là-`!isVisible`) khỏi `onPopInvokedWithResult` (sự kiện sau
quyết định). Hai kênh rõ ràng thay một callback mập mờ.

**H: Dismiss-lock đi qua callback — sao không là event?** —
Lock là *điều đang đúng*: sign out đang bận. Truyền nó bằng-
`ValueChanged<bool>` (state-propagation: giá trị mới mỗi khi
đổi) chứ không bằng event ("đã lock"/"đã mở khoá" sẽ cần ghép
lại thành state — vòng vô ích).

**H: Vì sao xoá `showDialog` là *kết quả* chứ không phải mục
tiêu?** — Vì `grep showDialog` có thể sạch mà kiến trúc vẫn
sai (ví dụ custom-Navigator-push). Mục tiêu là dialog-render-
by-state; khi nó đúng, route-shim *không còn vai trò* và grep
sạch chỉ là biên bản chứng nhận.

## Ta cố ý chưa thêm

- **Không `MenuDialogHidden` variant** — senior chỉ 5-variant;
  "ẩn tạm thời" không tồn tại trong ngữ nghĩa (None đủ).
- **`MenuDialogLayer` chưa xử barrier-color khác** — haze dùng
  `dialogHazeScrim` duy nhất cho mọi dialog (verbatim).
- **Auth/sign-out *nội dung* dialog không mở ở đây** — scope
  + bridge đã nói; visual bên trong (`menu_auth_dialog_content`)
  là verbatim-file, không phải đối tượng dạy riêng.
- **Không merge `MenuScreenUiEvent` vào `MenuDialogState`** —
  hai kênh tách biệt là *điểm* của bài; merge = trộn-"đang là"
  với-"vừa xảy ra".
- **Game-side `GameDialogState` không đổi** — 9-variant-game
  đã đúng từ M21; menu *bắt chước* nó, không gộp chung (hai
  miền dialog hai-family — `sealed_state_test` kiểm cả hai).

## Checkpoint hoàn thành

- [x] `MenuDialogState` sealed 5-variant verbatim:
      `isVisible`, `transitionKey=>runtimeType`, hash `0..4`.
- [x] `MenuDialogLayer`: `AnimatedSwitcher` fade `dialogMotion
      Long` + switch kiệt hợp → 4 scope `ValueKey(transitionKey)`.
- [x] `MenuDialogBackdrop`: ClipRect+blur+scrim+tap ngoài/
      nuốt trong+`DesignFrame`+`foregroundOverlay` slot.
- [x] `MenuScreenView`: Stack background→column→`Positioned
.fill(layer)`→`Positioned.fill(overlayScope)`;
      `PopScope(canPop: !isVisible)`; `_dialogDismissLocked`
      chặn cả back lẫn tap ngoài.
- [x] `MenuScreenViewModel.dialogState` + `_setDialogState`
      equality-guard (idempotent); `MenuViewModel`→rename file
      +class compile-forced.
- [x] `menu_screen.dart` 87-dòng `_MenuScreenEventBridge`:
      đúng-2-event `MenuGameRequested`/`MenuSnackBarRequested`.
- [x] **4 event `*Requested` + 3 `showXxxDialog` RETIRE**;
      `grep showDialog lib/` → zero call-site.
- [x] `flutter analyze` clean · `flutter test` **369/369**
      (+24: layer 16 + VM 22 − retire/update learner-tests).
