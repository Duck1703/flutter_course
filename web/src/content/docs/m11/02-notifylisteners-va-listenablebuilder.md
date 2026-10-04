---
title: "Bài 2 · notifyListeners & ListenableBuilder"
description: "ListenableBuilder thay FutureBuilder, switch expression trên MenuLoadState, và vì sao notifyListeners không tự diff."
sidebar:
  label: "Bài 2 · ListenableBuilder"
  order: 2
---

## Mục tiêu

Nối `MenuViewModel` vào UI: thay `FutureBuilder` bằng
`ListenableBuilder`, render theo `MenuLoadState`, và hiểu đúng
`notifyListeners` — nó báo vô điều kiện, diff là việc của bạn.

## Bạn đang ở đâu

- Milestone: **M11** (bài 2/3)
- App hiện tại: `MenuViewModel` đã tồn tại và được `_MenuScreenState`
  tạo/dispose (bài 1), nhưng UI vẫn đang dùng `FutureBuilder` đọc
  `_profileLoadFuture` — hai thế giới chưa nối.

## Vì sao việc này quan trọng ngay bây giờ

`FutureBuilder` rất đúng ở M05 — khi state duy nhất là "Future này xong
chưa". Nhưng nó mô hình hoá sai vấn đề bây giờ: profile sau khi load
còn *tiếp tục đổi* (áp kết quả, reset) — một Future thì chỉ hoàn thành
một lần. Ta cần một **nguồn thay đổi liên tục**: `ChangeNotifier`.

`ListenableBuilder` là cầu nối nguyên thuỷ: cho nó một `Listenable`,
nó subscribe, rebuild `builder` mỗi lần `notifyListeners` chạy, và tự
hủy subscribe khi widget unmount. Không package ngoài — framework cung
cấp sẵn (đến Flutter 3.10+).

## Bạn đã biết gì

- `FutureBuilder`/`StreamBuilder` (M05/M06) — `ListenableBuilder` là
  anh em thứ ba của "builder-nghe-nguồn-ngoài": Future (một lần),
  Stream (nhiều event), Listenable (nhiều lần báo "đổi").
- `switch` statement trên enum (M09) — hôm nay gặp `switch` *expression*.
- Callback tear-off `onRetry: _viewModel.load` — method reference.

## Mental model mới

```
        ┌─────────────── MenuViewModel ───────────────┐
        │ load()/applyGameResult()/resetProfile()      │
        │        │                                    │
        │        ▼ state đổi                          │
        │   notifyListeners() ─────┐                  │
        └──────────────────────────┼──────────────────┘
                                   ▼
              ListenableBuilder(listenable: _viewModel)
                                   │
                                   ▼ builder chạy lại
              switch (vm.loadState) { loading → spinner
                                      failed  → error+retry
                                      ready   → Column profile… }
```

So với FutureBuilder: *không* cần giữ `Future` field, *không* cần
snapshot — builder đọc thẳng `_viewModel.profile`/`.loadState`, và mọi
thay đổi sau load (áp result, reset) đều tự rebuild.

**`switch` expression** — Dart 3: `return switch (x) { a => w1, b => w2 };`
Exhaustive trên enum, trả giá trị — gọn hơn `if/else` cho "chọn widget
theo state".

## Ví dụ độc lập — `ChangeNotifier` + `ListenableBuilder` trần

Toàn bộ cơ chế trong ~55 dòng (DartPad — chế độ Flutter). Chú ý: ví dụ
này **không phải** `MenuViewModel` — nó chỉ chứng minh contract:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: CounterScreen()));

/// Model nhỏ tự quản state — object thường + cơ chế listener.
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count; // getter public — ngoài đọc, không ghi

  void increment() {
    _count++;
    notifyListeners(); // "ding" — báo có đổi, KHÔNG mang giá trị
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});
  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  final Counter _counter = Counter(); // ai tạo — người đó dispose

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListenableBuilder(
              listenable: _counter,
              builder: (context, _) =>
                  Text('${_counter.count}',
                      style: const TextStyle(fontSize: 40)),
            ),
            GestureDetector(
              onTap: _counter.increment,
              child: const Text('bấm để tăng'),
            ),
          ],
        ),
      ),
    );
  }
}
```

Chạy: mỗi lần bấm, số tăng — và **không có `setState` nào trong
`State`**. Ba điều đây là toàn bộ bài:

- `_count++` đổi field; `notifyListeners()` chỉ phát tín hiệu —
  `ListenableBuilder` nghe tín hiệu rồi **tự đọc lại** `_counter.count`.
- `Counter` không biết widget nào đang nghe — decoupling đúng nghĩa:
  thêm một `ListenableBuilder` thứ hai vào đâu đó, nó cũng cập nhật.
- `_counter.dispose()` ở `dispose` — notifier là tài nguyên có owner.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `ListenableBuilder` | `ListenableBuilder(listenable: _viewModel, builder: …)` | Subscribe `_viewModel`, rebuild builder mỗi notify |
| `listenable:` | `listenable: _viewModel` | Bất kỳ `Listenable` nào — `ChangeNotifier` là một |
| switch expression | `switch (s) { MenuLoadState.loading => … }` | Trả *giá trị*, exhaustive-check trên enum |
| tear-off method | `onRetry: _viewModel.load` | `Future<void> Function()` gán được cho `VoidCallback` — Dart coi return value bị bỏ qua |

## Flutter cần dùng

`ListenableBuilder` — hiện diện trong `package:flutter/widgets.dart`
(re-export qua material). Không cần package ngoài.

## Android / Compose bridge

- SIMILARITY: `ListenableBuilder` + `ChangeNotifier` ≈
  `collectAsStateWithLifecycle` + `StateFlow`: subscribe → mỗi phát là
  một recomposition của vùng bọc.
- IMPORTANT DIFFERENCE: `StateFlow` *mang giá trị* (`state.value`),
  `ChangeNotifier` *không mang gì* — chỉ "ding"; giá trị nằm ở getter,
  ai nghe thì tự đọc. Và recomposition-scoped: `ListenableBuilder`
  rebuild **toàn bộ builder** — không có granular tracking kiểu
  Compose state-read.
- DO NOT ASSUME: notify chỉ khi giá trị khác. `notifyListeners` báo
  thẳng — `ListenableBuilder` rebuild dù getter trả giá trị hệt nhau;
  nếu cần tránh rebuild thừa thì phải guard *trước khi* notify (đó là
  `_setLoadState` và `==` trong `resetProfile` ở bài 1).

## Senior project connection

- Senior không gọi `ListenableBuilder` trực tiếp — họ đi thẳng qua
  Provider (`context.watch<MenuScreenViewModel>()` trong
  `screens/menu_screen.dart`). Cơ chế dưới Provider vẫn chính là
  "listen ChangeNotifier → markNeedsBuild" — bài này cho bạn thấy
  nguyên thuỷ *trước* khi Provider bọc nó ở M12.
- `notifyListeners` không-diff: senior chứng minh bằng convention
  `_handleUserProfile`: `final shouldNotify = _userData != userData;`
  rồi mới notify — đúng cái bạn vừa viết trong `_setLoadState`.

## Build it step by step

### Bước 1 — Thay FutureBuilder bằng ListenableBuilder

```dart
// lib/screens/menu_screen.dart — trong build(), THAY FutureBuilder:
child: ListenableBuilder(
  listenable: _viewModel,
  builder: (context, child) {
    return switch (_viewModel.loadState) {
      MenuLoadState.loading => const _MenuLoading(),
      MenuLoadState.failed =>
        _MenuErrorState(onRetry: _viewModel.load),
      MenuLoadState.ready => Column(
          children: [
            _ProfileHeader(
              profile: _viewModel.profile,
              soundOn: _soundOn,
              onSoundTap: _toggleSound,
            ),
            Expanded(
              child: _MenuBody(
                profile: _viewModel.profile,
                ticker: _sessionTicker,
                onReset: _viewModel.resetProfile,
              ),
            ),
            _PlayButton(
              tapCount: _playTapCount,
              onTap: _onPlayTap,
            ),
          ],
        ),
    };
  },
),
```

- `builder` chạy lại mỗi `notifyListeners` — đọc `_viewModel.loadState`
  *tại đó*; không cache snapshot.
- `onRetry: _viewModel.load` — tear-off: retry gọi lại đúng hàm load
  của VM, không tạo Future mới trong State nữa.
- `_MenuBody(onReset: _viewModel.resetProfile)` — nút reset giờ gọi
  thẳng VM.

### Bước 2 — Dọn State

Trong `_MenuScreenState` xoá: `_profile`, `_profileLoadFuture`,
`_loadProfile`, `_retryLoadProfile`, `_resetProfile`. `_onPlayTap` đã
ủy quyền ở bài 1. Còn lại: `_soundOn`, `_playTapCount`,
`_sessionTicker`, `_viewModel`, `_toggleSound`, `_onPlayTap`, `build`.

Đọc lại file — nó ngắn và rõ hơn hẳn: mỗi thứ ở đúng một chủ sở hữu.

## Hiểu code

- **ListenableBuilder bọc ở đâu?** Ở *ngoài cùng* phần thay đổi —
  toàn bộ body menu. Rebuild cả cột mỗi notify nghe có vẻ "to", nhưng
  rebuild là rẻ (đều là widget config bất biến) — senior cũng watch
  toàn màn. Tối ưu rebuild-con-select là M12+ (`context.select`) và
  hoàn toàn optional.
- **`switch` expression trả Widget** — mỗi nhánh `=>` là một biểu thức
  widget; exhaustive nên không cần `default`. Thiếu một `MenuLoadState`
  trong tương lai = analyzer báo ngay — đúng chất lượng enum M08/M09.
- **`onRetry: _viewModel.load`** — gán method `Future<void> Function()`
  cho `void Function()`: Dart cho phép (kiểu trả bị bỏ qua). Lợi ích:
  không cần wrapper `() { _viewModel.load(); }` — nhưng nhớ là
  *không* `await` được trong chỗ gọi.

## Chạy và quan sát

- `flutter analyze` sạch; `flutter test` — toàn bộ 50 test vẫn xanh:
  refactor thật nghĩa là *test cũ không đổi mà vẫn qua*.
- `flutter run`: app y hệt M10 — spinner → menu → chơi → stats đổi →
  persist. Khác biệt nằm dưới nước: profile đổi giờ đi qua
  `notifyListeners`, không `setState`.
- Thử trong debug console: đặt breakpoint trong `builder` — mỗi
  `notifyListeners` là một lần builder chạy.

## Lỗi hay gặp

1. **`ListenableBuilder` bọc sai vùng** — đặt nó chỉ quanh một Text
   nhỏ thì phần còn lại của cây đọc `_viewModel.profile` *không*
   rebuild. Quy tắc: bọc quanh vùng *đọc state của notifier*.
2. **Tạo `MenuViewModel` trong `build`** — mỗi rebuild một VM mới,
   mất state + rò listener. VM phải là `late final` trong `initState`
   (bài 1) — giống hệt bài học "không tạo Stream trong build" của M06.
3. **Gọi `notifyListeners()` trong getter/build** — notify trong lúc
   rebuild đang chạy → lỗi "setState during build". Notify chỉ từ
   method hành vi (load/apply/reset) hoặc callback sự kiện.

## Kiểm tra hiểu biết

1. `FutureBuilder` và `ListenableBuilder` khác nhau căn bản ở đâu? —
   *Future hoàn thành một lần và mang snapshot; Listenable báo nhiều
   lần và không mang gì — builder tự đọc getter. Profile đổi nhiều lần
   sau load nên Listenable là mô hình đúng.*
2. Tại sao `builder` đọc `_viewModel.profile` trực tiếp thay vì nhận
   profile qua `child`/snapshot? — *ListenableBuilder không truyền dữ
   liệu — nó chỉ là tín hiệu "đổi". Nguồn sự thật là getter của VM.*
3. Nếu `applyGameResult` quên `notifyListeners` thì sao? — *Disk vẫn
   ghi đúng, `_profile` đổi đúng, nhưng ListenableBuilder không được
   báo → UI menu giữ stats cũ tới rebuild kế. Đúng kiểu bug "dữ liệu
   đúng mà màn hình sai".*

## Tự làm (PREDICT)

Ba thí nghiệm nhỏ trong `MenuViewModel` — dự đoán từng cái trước, rồi
thử và sửa lại:

1. **Bỏ `notifyListeners()`** ra khỏi một method đổi state (ví dụ
   `resetProfile` — giữ đổi field nhưng bỏ dòng notify). Bấm nút kích
   hoạt nó: `_profile` có đổi không (check bằng `debugPrint`)? UI có
   đổi không?
2. **Gọi `notifyListeners()` mà không đổi gì** — thêm tạm một nút gọi
   `notifyListeners()` trần. `ListenableBuilder` có rebuild không?
   (Thêm `debugPrint` trong `builder` để thấy.)
3. `notifyListeners()` được gọi **hai lần liên tiếp** trong một method —
   `builder` chạy mấy lần? Dự đoán rồi đếm bằng print.

:::note[Gợi ý]
`notifyListeners` không mang giá trị — nó là *tín hiệu*. Hỏi ngược:
nếu nó là StateFlow thì (1) và (2) sẽ khác gì? Đó chính là chỗ
analogy Kotlin gãy.
:::

<details><summary>Đáp án</summary>

1. `_profile` **đổi thật** (print chứng minh) nhưng **UI đứng yên** —
   không ai được báo để đọc lại getter. Giống hệt bẫy `setState` của
   M03 nhưng ở tầng VM: mutation ≠ notification, ở mọi tầng.
2. `builder` **chạy lại** — `notifyListeners` báo vô điều kiện, kể cả
   khi "không đổi gì". Đây là lý do senior guard `!=` trước khi notify:
   *tín hiệu* không tự diff; muốn báo-khi-đổi-thật phải so sánh tay.
3. `builder` chạy **hai lần** (hoặc coalesce tuỳ framework — nhưng
   nguyên tắc: mỗi notify là một tín hiệu riêng, không "gộp thông minh"
   theo giá trị). Một quy tắc sạch: một method nên notify **một lần**,
   ở cuối, sau khi mọi field đã ở trạng thái nhất quán — để listener
   không bao giờ đọc được "state nửa chừng".

Điểm cốt lõi: `ChangeNotifier` + `ListenableBuilder` là contract
*ding-then-read*. Khác `StateFlow` (mang giá trị, tự diff theo
`==`), khác `Stream` (event theo thời gian, có subscription) — ba cơ
chế, ba mental model riêng.

</details>

## Ta cố ý chưa thêm

- `AnimatedBuilder` — cùng widget, tên cũ; `ListenableBuilder` là alias
  hiện đại rõ nghĩa hơn, course chọn tên mới.
- `context.watch`/`Provider` — M12.
- Tách nhỏ vùng rebuild (mỗi thẻ một builder / `context.select`) —
  tối ưu không cần ở quy mô này; đo trước khi tối ưu.

## Checkpoint hoàn thành

- [ ] `build` dùng `ListenableBuilder(listenable: _viewModel, …)` và
  switch expression trên `MenuLoadState`.
- [ ] Không còn `FutureBuilder`/`_profileLoadFuture`/`snapshot` ở menu.
- [ ] `_MenuErrorState` nhận `onRetry: _viewModel.load`; `_MenuBody`
  nhận `onReset: _viewModel.resetProfile`.
- [ ] `flutter analyze` + `flutter test` xanh — refactor không đổi
  hành vi.
