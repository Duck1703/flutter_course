---
title: "Bài 2 · read vs watch"
description: "context.read lấy một lần không subscribe, context.watch subscribe + rebuild; quy tắc 'watch trong build, read trong callback' và các bug kinh điển."
sidebar:
  label: "Bài 2 · read vs watch"
  order: 2
---

## Mục tiêu

Phân biệt rành mạch `context.read<T>()` và `context.watch<T>()` —
hai API tra provider nghe giống nhau nhưng semantics hoàn toàn khác —
và áp dụng đúng chỗ trong `_MenuScreenView`.

## Bạn đang ở đâu

- Milestone: **M12** (bài 2/3)
- App hiện tại: `AppDependencyScope` đã cung cấp `ProfileStore` trong
  cây (bài 1). `MenuScreen` chưa đổi — vẫn là StatefulWidget tự tạo VM.

## Vì sao việc này quan trọng ngay bây giờ

`read`/`watch` là hai động từ của Provider — dùng sai cái nào cũng lỗi:

- `watch` trong **event callback** → subscribe từ callback, rebuild kỳ
  lạ, analyzer thậm chí cấm `watch` ngoài build cho một số tình huống.
- `read` trong **build** khi bạn cần UI theo state → UI "đứng hình"
  vì không ai subscribe — bug im lặng khó soi nhất của Provider.

Quy tắc bắt buộc nhớ:

```
build()              → watch  (đọc state + subscribe rebuild)
event handler/callback → read (lấy object, gọi method, không subscribe)
initState            → read (hoặc listen: false), KHÔNG watch
```

## Bạn đã biết gì

- `ListenableBuilder` nghe `notifyListeners` (M11) — `watch` chính là
  nó, được Provider bọc gọn: subscribe notifier + rebuild + tự hủy.
- `setState` trong callback vs rebuild trong build (M03).

## Mental model mới

```
context.watch<T>()  =  context.read<T>()  +  "đánh dấu widget này
                       cần rebuild mỗi lần T notify"
```

- `read`: tra lên cây → trả object → xong. Không đăng ký gì.
- `watch`: tra lên cây → trả object → **và** đăng ký element hiện tại
  làm dependent → mỗi notify → `build` chạy lại.

Vì `watch` tạo dependency tại build-time, nó **chỉ hợp lệ trong build**
(hoặc `didChangeDependencies` — callback chạy ngay sau mỗi lần
dependency thay đổi, cũng là chỗ watch/read hợp lệ).

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `context.watch<T>()` | `final vm = context.watch<MenuViewModel>();` đầu `build` | Subscribe + đọc — mỗi notify là một rebuild |
| `context.read<T>()` | `final vm = context.read<MenuViewModel>();` trong `_onPlayTap` | Đọc một lần, không rebuild |
| `Provider.of<T>(ctx)` | `Provider.of<MenuViewModel>(ctx)` | API gốc; `read`/`watch` là cú pháp mới khuyên dùng |
| `didChangeDependencies` | lifecycle hook | Chỗ hợp lệ khác để read/watch khi dep thay đổi |

## Flutter cần dùng

Không widget mới — extension method `read`/`watch` trên `BuildContext`
từ `package:provider`.

## Android / Compose bridge

- SIMILARITY: `watch` ≈ `collectAsState` (subscribe → recomposition);
  `read` ≈ `viewModel.` truy cập trong `onClick` — lấy instance một lần
  để gọi hàm.
- IMPORTANT DIFFERENCE: Compose *track* state-read tự động (đọc `state.value`
  ở đâu là subscribe ở đó); Provider bắt bạn *tự chọn*: `read` hay
  `watch` là quyết định tường minh — sai là sai, không compiler cứu.
- DO NOT ASSUME: `watch` trong `onTap`/`onPressed` hoạt động. Callback
  chạy ngoài build → `watch` ở đó subscribe lệch/throw. Callback cần
  VM để *gọi* chứ không cần *rebuild* → `read`.

## Senior project connection

- `flutter-accelerator-ai/lib/screens/menu_screen.dart` —
  `_MenuScreenEventBridgeState.didChangeDependencies` dùng
  `context.read<AppNavigationController>()` và
  `context.read<MenuScreenViewModel>()` (tra một lần để giữ reference);
  `build` dùng `context.watch<MenuScreenViewModel>()`. Đúng tỉ mỉ
  cặp đôi bạn đang học.
- Senior còn subscribe `viewModel.events.listen` trong bridge —
  event stream một-lần = M13, ta chưa có.

## Build it step by step

### Bước 1 — `watch` trong build của view

```dart
// lib/screens/menu_screen.dart — _MenuScreenViewState.build:
@override
Widget build(BuildContext context) {
  // watch = subscribe MenuViewModel: mỗi notifyListeners → build chạy
  // lại. Đây là ListenableBuilder của M11 được Provider bọc gọn.
  final viewModel = context.watch<MenuViewModel>();

  return Scaffold(
    // … decoration giữ nguyên …
    child: switch (viewModel.loadState) {
      MenuLoadState.loading => const _MenuLoading(),
      MenuLoadState.failed => _MenuErrorState(onRetry: viewModel.load),
      MenuLoadState.ready => Column(
          children: [
            _ProfileHeader(
              profile: viewModel.profile,
              soundOn: _soundOn,
              onSoundTap: _toggleSound,
            ),
            Expanded(
              child: _MenuBody(
                profile: viewModel.profile,
                ticker: _sessionTicker,
                onReset: viewModel.resetProfile,
              ),
            ),
            _PlayButton(tapCount: _playTapCount, onTap: _onPlayTap),
          ],
        ),
    },
  );
}
```

Không còn `ListenableBuilder`, không còn field `_viewModel` —
`watch` trả VM và lo luôn subscribe/unsubscribe.

### Bước 2 — `read` trong event handler

```dart
Future<void> _onPlayTap() async {
  setState(() {
    _playTapCount++;
  });
  // read trong callback: lấy VM một lần để gọi — handler không cần
  // rebuild theo VM nên KHÔNG watch ở đây.
  final viewModel = context.read<MenuViewModel>();
  final result = await Navigator.of(context).push<GameResult>(
    MaterialPageRoute<GameResult>(builder: (context) => const GameScreen()),
  );
  if (!mounted || result == null) return;
  await viewModel.applyGameResult(result);
}
```

Đọc VM **trước** `await` — sau `await` thì `context` vẫn dùng được nếu
`mounted`, nhưng lấy sớm giữ code tuyến tính và né tranh luận
"use_build_context_synchronously".

## Hiểu code

- **Vì sao `watch` được phép ở `build` và `didChangeDependencies`?**
  Hai chỗ đó là nơi framework *kỳ vọng* dependency được đăng ký lại —
  mỗi rebuild đăng ký lại một cách idempotent.
- **`read` trong `initState`** — an toàn: provider đã gắn vào cây, tra
  lên được; `watch` ở `initState` là illegal vì chưa có element-build
  đang chạy để đăng ký dependency (Flutter ném lỗi nếu thử).
- **Cặp `onRetry: viewModel.load`** — `viewModel` ở đây đến từ `watch`:
  getter object trong build là hợp lệ; cái được subscribe là
  *MenuViewModel*, còn `viewModel.load` chỉ là tear-off truyền xuống —
  nút THỬ LẠI không tự subscribe gì thêm.

## Chạy và quan sát

- `flutter analyze`/`flutter test` — xanh.
- Thí nghiệm đáng thử một lần: đổi `context.watch` trong build thành
  `context.read` → chạy app → đổi stats (chơi một ván) → menu **không
  cập nhật** dù state đổi — cảm nhận trực tiếp "read không subscribe".

## Lỗi hay gặp

1. **`watch` trong callback (`onTap`)** — subscribe lệch timing;
   callback là nơi của `read`.
2. **`read` trong build cho state thay đổi** — UI "đóng băng" vì không
   ai rebuild. Đây là bug #1 của Provider mới học.
3. **Tra context sai vị trí** — `context` trong `MenuScreen.build`
   (trên provider) không thấy `MenuViewModel`; phải tra từ widget con
   (`_MenuScreenView`) — kế thừa quy tắc lookup-đi-lên của bài 1.
4. **`context.watch` trong `initState`** — ném lỗi ngay: initState
   không phải build. Nhớ được `didChangeDependencies` là chỗ hợp lệ
   thứ hai nếu thật sự cần.

## Kiểm tra hiểu biết

1. `read` và `watch` đều "lấy object" — điểm khác biệt duy nhất là gì?
   — *watch **đăng ký element làm dependent**: notify → element mark
   dirty → build lại. read chỉ trả object.*
2. Vì sao `_onPlayTap` lấy VM bằng `read` thay vì `watch`? —
   *Handler là một-shot: chỉ cần gọi `applyGameResult`. Subscribe ở đây
   vô nghĩa (callback chạy xong không ai cần rebuild) và `watch` ngoài
   build là sai vị trí.*
3. `_MenuScreenViewState` cần `dispose` gì cho subscription `watch`
   không? — *Không — Provider/element tự hủy dependency khi widget
   unmount; đó là phần watch bọc sẵn thay ListenableBuilder.*

## Tự làm (RECOGNIZE + PREDICT)

**Phần 1 — chọn `read` hay `watch`** cho 5 chỗ gọi dưới đây trong
`_MenuScreenViewState`, và nêu tiêu chí quyết định:

| Chỗ gọi | Cần VM để | `read` hay `watch`? |
|---|---|---|
| 1. `build` — hiển thị `vm.profile.displayName` | vẽ text | ? |
| 2. `onPressed` nút CHƠI | `vm.requestGame()` | ? |
| 3. `didChangeDependencies` — attach event bridge | giữ reference VM | ? |
| 4. `build` — `switch (vm.loadState)` chọn widget | vẽ theo state | ? |
| 5. callback retry | `vm.load()` | ? |

**Phần 2 — dự đoán lỗi.** Một người viết `context.watch<MenuViewModel>()`
trong `onPressed` vì "watch chắc cũng lấy được VM". Chuyện gì xảy ra
khi bấm nút — và tại sao lỗi đó *đúng* chứ không phải Provider keo kiệt?

:::note[Gợi ý]
Tiêu chí một câu: chỗ này có cần **chạy lại khi VM notify** không?
Build thì gần như luôn cần (hiển thị giá trị mới); callback thì gần
như không bao giờ (nó chỉ *gọi* hành vi). Phần 2: nghĩ về lúc nào
`watch` đăng ký dependency — build-time hay run-time?
:::

<details><summary>Đáp án</summary>

| # | Chọn | Vì sao |
|---|------|--------|
| 1 | `watch` | đang hiển thị giá trị VM — notify → phải vẽ lại |
| 2 | `read` | callback chỉ gọi `requestGame()`; không cần rebuild |
| 3 | `read` | lấy instance để subscribe events — `watch` không hợp lệ/ không cần ở hook này; `read` hợp lệ trong `didChangeDependencies` |
| 4 | `watch` | switch theo `loadState` phải chạy lại mỗi notify |
| 5 | `read` | giống (2) — gọi hành vi, không subscribe |

**Phần 2:** `watch` đăng ký "element này phụ thuộc T" **tại build-time**
— nó cần element đang-build để gắn dependency. Trong `onPressed` không
có element đang build → Provider ném lỗi (không phải im lặng sai, mà
fail rõ). Nó "đúng" vì: nếu im lặng cho qua, subscribe sẽ gắn vào
context cũ/mòn — bug khó săn hơn nhiều so với một exception tại chỗ.
Đây là lựa chọn *fail-fast*: Provider hy sinh tính mềm dẻo để đổi lấy
lỗi đọc được ngay.

Quy tắc nén: **build → `watch`, callback/hook → `read`** — và `watch`
là *lệnh build-time*, không phải "cách lấy VM khác".

</details>

## Ta cố ý chưa thêm

- `context.select<T, R>(selector)` — rebuild khi chỉ một *phần* của
  object đổi; menu nhỏ nên watch nguyên VM đủ rẻ.
- `didChangeDependencies` dùng thực tế — senior dùng để attach VM trong
  event bridge; learner bridge (events) là M13.
- `Consumer<T>` widget — `context.watch` trong `build` đã gọn hơn.

## Checkpoint hoàn thành

- [ ] `build` của `_MenuScreenView` mở đầu bằng
  `context.watch<MenuViewModel>()`.
- [ ] `_onPlayTap` dùng `context.read<MenuViewModel>()`; không `watch`
  nào nằm trong callback.
- [ ] Giải thích được: điểm khác biệt duy nhất giữa read và watch;
  hai chỗ `watch` hợp lệ.
