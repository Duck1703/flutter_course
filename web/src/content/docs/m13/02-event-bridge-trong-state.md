---
title: "Bài 2 · Event bridge trong State"
description: "StatefulWidget subscribe event stream: didChangeDependencies là chỗ đúng, guard chống re-subscribe, dispose cancel, unawaited cho Future mồ côi."
sidebar:
  label: "Bài 2 · Event bridge trong State"
  order: 2
---

## Mục tiêu

Nối hai đầu đã có: VM phát `MenuUiEvent` (bài 1) → một `State` lắng
nghe và biến event thành hành động UI. Đây là **event bridge** —
pattern trọng tâm của M13.

## Bạn đang ở đâu

- Milestone: **M13** (bài 2/3)
- `MenuViewModel.events` đã phát `MenuGameRequested`/`MenuSnackBarRequested`.
- `_MenuScreenViewState` vẫn giữ `_onPlayTap` kiểu M10 — tự push
  route. Bài này chuyển quyền điều hướng về VM.

## Vì sao việc này quan trọng ngay bây giờ

VM **không thể** tự `Navigator.push`: không có `context`. Widget
**không nên** tự quyết định điều hướng theo business intent: đó là
việc của VM. Bridge là mảnh nối hợp lệ duy nhất — widget *sở hữu*
context và lifecycle, nghe event của VM và *thực thi* hành động UI.

Nếu bỏ qua pattern này, hai lựa chọn xấu còn lại: truyền `context`
cho VM (rò rỉ lifecycle, crash khi widget chết) hoặc để widget tự
điều hướng (VM không sở hữu quyết định — test VM không thấy gì).

## Bạn đã biết gì

- `Stream.listen` trả `StreamSubscription` (M06); `context.read` tra
  Provider một lần (M12); `initState`/`dispose` (M03).
- `Navigator.push<GameResult>` + `pop(result)` (M09/M10).

## Mental model mới

```
VM (không biết context)            State (sở hữu context + lifecycle)
_events.add(intent)   ──stream──▶   _handleUiEvent(event)
                                    ├─ MenuGameRequested   → Navigator.push
                                    └─ MenuSnackBarRequested → ScaffoldMessenger
```

State làm **dịch giả**: event (ngôn ngữ VM) → side-effect (ngôn ngữ
UI). Ba khâu bắt buộc:

1. **Subscribe** — đúng chỗ: `didChangeDependencies` (provider đã
   sẵn sàng cho `context.read`; `initState` thì chưa).
2. **Guard + thay thế** — `didChangeDependencies` chạy lại mỗi khi
   dependency đổi → nếu Provider thay VM, huỷ sub cũ trước khi gắn
   sub mới; nếu VM vẫn vậy, bỏ qua.
3. **Cancel** — `dispose` huỷ subscription; listener sống sót widget
   là leak + crash sau unmount.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `StreamSubscription<T>?` | `StreamSubscription<MenuUiEvent>? _eventSubscription` | Handle của một `listen` — giữ để cancel |
| `stream.listen(fn)` | `viewModel.events.listen(_handleUiEvent)` | Subscribe; trả subscription |
| `subscription.cancel()` | trong `dispose` | Gỡ listener; an toàn gọi lại/`null` |
| `unawaited(future)` | `unawaited(_openGame())` | Đánh dấu "cố ý không await" — từ `dart:async` |
| `event is Type` | `event is MenuGameRequested` | Phân loại event (switch kiệt hợp = M15) |

## Flutter cần dùng

| API | Chỗ dùng | Vì sao |
|-----|----------|--------|
| `didChangeDependencies` | subscribe | chạy sau frame đầu + mỗi khi dep đổi; `context.read` hợp lệ ở đây |
| `dispose` | cancel | điểm chết của State — mọi handle phải giải phóng |
| `SnackBar` | widget thông báo | **Lần đầu trong course**: thanh chữ nhỏ trượt lên đáy màn, tự biến mất — chuẩn "báo một việc vừa xảy ra" |
| `ScaffoldMessenger.of(context)` | hiện SnackBar | **Lần đầu trong course**: messenger của *MaterialApp* giữ hàng SnackBar và tìm Scaffold đang hiển thị — gọi từ context bất kỳ dưới app, không cần Scaffold là cha |

## Android / Compose bridge

- SIMILARITY: bridge ≈ `LaunchedEffect(vm.events.collect { ... })` —
  collect event một-lần và làm side-effect UI.
- IMPORTANT DIFFERENCE: `LaunchedEffect` **tự huỷ** khi rời
  composition (scope theo lifecycle); `stream.listen` trả
  subscription mà **tự bạn** phải `cancel()` trong `dispose` —
  quên là leak.
- DO NOT ASSUME: re-subscribe là an toàn tự động. Compose restart
  effect gọn; Flutter gọi `didChangeDependencies` nhiều lần và không
  tự gỡ sub cũ — phải guard + cancel tay, nếu không event xử lý đúp
  (điều hướng hai lần).

## Senior project connection

- `flutter-accelerator-ai/lib/screens/menu_screen.dart` —
  `_MenuScreenEventBridgeState`: `didChangeDependencies` →
  `_attachMenuViewModel(context.read<MenuScreenViewModel>())`; hàm
  attach guard `if (_viewModel == viewModel) return;` →
  `_eventSubscription?.cancel()` → gắn sub mới; `dispose` → cancel.
  Learner dùng **đúng ba khâu** này.
- Khác biệt cấu trúc (đã ghi trong brief): senior đặt bridge là widget
  wrapper riêng `_MenuScreenEventBridge`; learner gộp vào
  `_MenuScreenViewState` vì State đó đã tồn tại — ít một lớp widget
  cho người mới, semantics y hệt.
- Senior gọi `_navigationController.openGame()`; learner chưa có
  navigation controller (D20) nên bridge `Navigator.push` trực tiếp.

## Build it step by step

### Bước 1 — subscription fields + lifecycle

Trong `_MenuScreenViewState` (`lib/screens/menu_screen.dart`), thêm
`import 'dart:async';` rồi:

```dart
/// ── M13: event bridge ────────────────────────────────────────────
/// VM bắn event một-lần (điều hướng, snackbar); State này lắng nghe
/// và biến chúng thành hành động UI — vì chỉ widget mới có context.
/// Senior: `_MenuScreenEventBridgeState` trong
/// `flutter-accelerator-ai/lib/screens/menu_screen.dart` — cùng ba
/// khâu: subscribe ở didChangeDependencies, gỡ-khi-đổi-VM, cancel ở
/// dispose.
MenuViewModel? _viewModel;
StreamSubscription<MenuUiEvent>? _eventSubscription;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Subscribe ở đây — không phải initState — vì `context.read` cần
  // InheritedWidget (Provider) đã sẵn sàng; didChangeDependencies chạy
  // sau frame build đầu và MỖI KHI dependency đổi → nếu Provider thay
  // VM, ta attach lại (và huỷ subscription cũ trong _attachViewModel).
  _attachViewModel(context.read<MenuViewModel>());
}

/// Gắn listener vào VM hiện tại — hoặc bỏ qua nếu vẫn là VM cũ.
/// Guard `==` chính là câu trả lời cho "không điều hướng hai lần":
/// didChangeDependencies có thể chạy nhiều lần mà VM không đổi.
void _attachViewModel(MenuViewModel viewModel) {
  if (_viewModel == viewModel) return;
  _eventSubscription?.cancel();
  _viewModel = viewModel;
  _eventSubscription = viewModel.events.listen(_handleUiEvent);
}

@override
void dispose() {
  _eventSubscription?.cancel();
  super.dispose();
}
```

### Bước 2 — handler biến event thành hành động

```dart
/// Biến event của VM thành hành động UI. `is`-check vì event là class
/// thường (M13); switch kiệt hợp trên sealed class là bài M15.
void _handleUiEvent(MenuUiEvent event) {
  if (event is MenuGameRequested) {
    // `unawaited`: _openGame là async (chờ kết quả game) nhưng stream
    // listener phải trả về sync — ta CỐ Ý không await. Đánh dấu bằng
    // `unawaited(...)` nói rõ "discard này là chủ đích", không phải
    // quên await — Future mồ côi âm thầm là nguồn bug khó thấy.
    unawaited(_openGame());
  } else if (event is MenuSnackBarRequested) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(event.message)));
  }
}
```

Nhánh SnackBar đáng đọc kỹ: `SnackBar` là widget "thanh báo nhỏ đáy
màn" — app chưa dùng bao giờ, đây là lần đầu. Nó không được đặt trong
cây như widget thường mà **đẩy qua `ScaffoldMessenger`** — một
InheritedWidget do `MaterialApp` cung cấp sẵn, giữ hàng chờ SnackBar
và hiển thị trên Scaffold đang mở. Vì messenger nằm *trên* mọi màn,
`ScaffoldMessenger.of(context)` gọi được từ bất kỳ đâu dưới app —
kể cả khi Scaffold của màn này là con của context gọi.

### Bước 3 — `_onPlayTap` chỉ còn báo ý định

```dart
/// Bấm chơi → KHÔNG còn tự push route: báo ý định cho VM bằng
/// `requestGame()` — event `MenuGameRequested` quay lại qua bridge
/// và `_openGame()` mới thực sự điều hướng.
void _onPlayTap() {
  context.read<MenuViewModel>().requestGame();
}

/// Push game và CHỜ kết quả (M10). `push<GameResult>` trả
/// `Future<GameResult?>` — có giá trị nếu pop kèm `pop(result)`
/// (VỀ MENU từ dialog), `null` nếu pop trần (back AppBar = bỏ cuộc).
Future<void> _openGame() async {
  final viewModel = context.read<MenuViewModel>();
  final result = await Navigator.of(context).push<GameResult>(
    MaterialPageRoute<GameResult>(
      builder: (context) => const GameScreen(),
    ),
  );
  if (!mounted || result == null) return;
  await viewModel.applyGameResult(result);
}
```

Diff rất nhỏ nhưng quyền lực đổi chủ: route push **y nguyên** từ
`_onPlayTap` cũ, chỉ dời sang `_openGame()` — người gọi nó giờ là
bridge khi event về, không phải nút bấm.

## Hiểu code

- **Vì sao `didChangeDependencies` mà không `initState`?**
  `initState` chạy *trước* khi widget tham gia cây đầy đủ — `context
  .read` cần tra InheritedWidget (Provider) nên phải chờ;
  `didChangeDependencies` chạy ngay sau frame build đầu, provider đã
  sẵn sàng, và còn chạy lại khi dependency đổi (đúng chỗ để re-attach).
- **Guard `==` làm gì?** `didChangeDependencies` có thể chạy nhiều lần
  trong đời State (locale/theme/provider đổi). Nếu VM vẫn là instance
  cũ → return, không gắn sub thứ hai. Không guard → hai listener →
  `_handleUiEvent` chạy đúp → **push hai route**.
- **Cancel trước khi thay** — khi Provider thật sự cho VM mới
  (hot-restart, scope đổi), sub cũ trỏ vào VM chết → phải huỷ trước
  khi gắn sub mới, nếu không rò rỉ cả hai.
- **`unawaited` ở đâu ra?** Stream listener là `void` — không thể
  `await`. `_openGame()` trả Future chờ cả phiên chơi; bỏ trần trông
  như "quên await". `unawaited(future)` (trong `dart:async`) là cú
  pháp nói "tôi cố ý": analyzer và người đọc đều hiểu.

## Chạy và quan sát

- `flutter analyze` + `flutter test` — xanh (bài 3 thêm test chứng
  minh).
- Chạy app: bấm BẮT ĐẦU CHƠI → màn game vẫn mở, chơi xong vẫn cập
  nhật stats — **ngoài không đổi, trong đã đổi**: quyết định điều
  hướng giờ nằm ở VM.
- Thử một lần: bỏ guard `==` trong `_attachViewModel` và ép
  `didChangeDependencies` chạy lại (đổi locale/theme) → event xử lý
  nhiều lần. Nhìn tận mắt vì sao guard tồn tại.

## Lỗi hay gặp

1. **Subscribe ở `initState`** — `context.read` throw (provider chưa
   reachable) hoặc subscribe vào VM cũ rồi không cập nhật khi đổi.
2. **Quên `dispose` cancel** — listener sống sau widget: event vẫn
   kích handler trên `context` đã unmount → crash `setState on
   unmounted`/lookup lỗi.
3. **Không guard khi re-attach** — mỗi `didChangeDependencies` thêm
   một listener → xử lý event N lần.
4. **`await` trong listener** — listener là `void Function(T)`; muốn
   gọi async thì `unawaited(...)`, không biến listener thành async
   (async-void listener trả Future vô chủ khó trace).
5. **`context.watch` trong `didChangeDependencies` để lấy VM** —
   được phép về API, nhưng không cần: bridge chỉ *nghe* events, không
   rebuild theo VM — `read` đủ và rẻ hơn.

## Kiểm tra hiểu biết

1. Vì sao bridge nằm trong `State` chứ không phải trong VM? — *Chỉ
   widget có context/lifecycle để Navigator/ScaffoldMessenger; VM
   giữ intent, widget giữ thực thi.*
2. Ba việc bắt buộc khi subscribe stream trong State? — *Subscribe ở
   `didChangeDependencies`; guard/huỷ cũ khi re-attach; `cancel()` ở
   `dispose`.*
3. `unawaited` khác "không await" thế nào? — *Cùng không chờ, nhưng
   `unawaited` là dấu chủ đích: code nói rõ Future này được bỏ — đọc
   và analyze đều không nhầm là quên.*

## Ta cố ý chưa thêm

- **Widget bridge riêng** (`_MenuScreenEventBridge` wrapper) — senior
  có; learner gộp vào `_MenuScreenViewState` vì State đó đã tồn tại.
- **Navigation controller** — `AppNavigationController.openGame()` là
  kiến trúc senior; learner `Navigator.push` trực tiếp (D20).
- **Switch kiệt hợp trên sealed events** — M15; `is`/`else if` đủ cho
  2 loại event.
- **Handler cho event chưa biết** — thêm loại event mới chỉ cần thêm
  nhánh `else if`; sealed/switch (M15) sẽ bắt buộc cover hết.

## Checkpoint hoàn thành

- [ ] `_MenuScreenViewState` có `_viewModel` + `_eventSubscription`,
  subscribe ở `didChangeDependencies` qua `_attachViewModel` có guard.
- [ ] `dispose()` cancel subscription trước `super.dispose()`.
- [ ] `_onPlayTap` gọi `requestGame()`; không `Navigator` trực tiếp;
  `_openGame()` chứa push flow cũ.
- [ ] `_handleUiEvent` dùng `is` + `unawaited(_openGame())`.
- [ ] Giải thích được: vì sao subscribe ở `didChangeDependencies`; tại
  sao guard `==` chống double-navigation.
