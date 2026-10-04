---
title: "Bài 3 · SnackBar event & test"
description: "MenuSnackBarRequested → ScaffoldMessenger qua bridge; VM test chứng minh event bắn; widget test chứng minh CTA điều hướng và SnackBar hiện."
sidebar:
  label: "Bài 3 · SnackBar event & test"
  order: 3
---

## Mục tiêu

Hoàn thiện vòng event thứ hai — `MenuSnackBarRequested` → SnackBar
thật hiện — và chứng minh toàn kênh bằng test: VM test kiểm event
được phát, widget test kiểm hành động UI xảy ra.

## Bạn đang ở đâu

- Milestone: **M13** (bài 3/3)
- Bài 1: VM phát event. Bài 2: bridge đã subscribe và có nhánh
  `MenuSnackBarRequested` gọi `ScaffoldMessenger`. Còn thiếu: một
  chỗ VM **thực sự** bắn snackbar, và test chứng minh cả hai đường.

## Vì sao việc này quan trọng ngay bây giờ

Kênh event mà không có test chỉ là ý đồ. Ba khẳng định cần chứng minh
của M13:

1. `requestGame()` → `MenuGameRequested` bay trên `events` (VM test).
2. `resetProfile()` → `MenuSnackBarRequested` kèm đúng message (VM
   test).
3. Tap BẮT ĐẦU CHƠI → GameScreen được push (widget test qua bridge);
   tap ĐẶT LẠI HỒ SƠ → SnackBar hiện (widget test).

Nút reset trước M13 "câm" — xoá xong không ai biết. SnackBar event
vừa là UX thật, vừa là consumer thứ hai chứng minh kênh tổng quát.

## Bạn đã biết gì

- `test()`/`testWidgets()`, `expect`, `pump`/`pumpWidget` (M04–M12).
- `SnackBar` + `ScaffoldMessenger` — **lần đầu xuất hiện trong
  course là M13**: bài 2 đã giải thích chúng (thanh báo đáy màn +
  messenger app-level giữ hàng) khi viết bridge.
- `ensureVisible` trước `tap` trên nút offscreen — gặp ngay trong
  bài này, giải thích ở chỗ dùng.

## Mental model mới

```
Widget test ≠ test riêng hai đầu:

tap BẮT ĐẦU CHƠI ─▶ _onPlayTap ─▶ requestGame()
                                     │ _events.add
                                     ▼
                              _handleUiEvent (bridge)
                                     │ unawaited(_openGame())
                                     ▼
                            Navigator.push → GameScreen
                                     │
                        test assert: 'Phòng chơi' tồn tại
```

Widget test đo **cả đường**: event đi vòng VM→bridge→UI mới xuất
hiện kết quả. Nếu `_onPlayTap` còn `Navigator.push` trực tiếp, test
vẫn xanh — nên test thứ nhất kiểm **VM emit event** (không qua UI)
để khoá đúng nguồn gốc hành vi.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `stream.first` | `final emitted = vm.events.first;` | Future hoàn thành bằng event kế tiếp — bắt event trong test |
| `isA<T>()` | `expect(event, isA<MenuGameRequested>())` | Matcher kiểu của flutter_test |
| `expect(await f, …)` | `expect(await emitted, …)` | Await Future-event rồi assert |

## Flutter cần dùng

| API | Chỗ dùng | Vì sao |
|-----|----------|--------|
| `ScaffoldMessenger.of(ctx).showSnackBar` | bridge handler | SnackBar qua messenger app-level — không cần Scaffold ancestor của widget gọi |
| `tester.ensureVisible(finder)` | trước `tap` | cuộn nút offscreen vào vùng chạm được |
| `tester.pump(dur)` | chờ animation | route push/SnackBar cần frame để render |

**Nhắc lại bẫy M06:** không `pumpAndSettle` — ticker vô hạn của menu
không bao giờ "settle"; pump tay theo đúng thời lượng animation.

## Android / Compose bridge

- SIMILARITY: `SnackBar` event ≈ `SnackbarHostState.showSnackbar`
  trong `LaunchedEffect` collect; VM test ≈ Turbine/`test { vm.events
  ... }` — await event trên flow rồi assert.
- IMPORTANT DIFFERENCE: `SharedFlow` test dùng Turbine hoặc
  `runTest`+`advanceUntilIdle`; Dart test đơn giản hơn — `stream.first`
  trả Future, `await` là bắt được event kế tiếp.
- DO NOT ASSUME: SnackBar hiện ngay khi `showSnackBar` được gọi trong
  test — nó vào qua animation; `tester.pump()` ít nhất một frame sau
  emit mới thấy widget.

## Senior project connection

- `flutter-accelerator-ai/lib/screens/menu_screen.dart` —
  `_handleUiEvent` nhánh `MenuSnackBarRequested(:final message)` →
  `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
  Text(message)))`. Learner dùng đúng dòng đó qua `is`-check.
- Senior VM test kiểm event phát (pattern `expectLater(vm.events,
  emits(...))`-style khắp dialog VMs — evidence đọc source, learner
  giữ kiểu `events.first` + await cho trực quan).
- SnackBar senior có style/duration riêng; learner dùng mặc định —
  đủ cho M13.

## Build it step by step

### Bước 1 — VM test: event được phát

Trong `test/menu_view_model_test.dart`, thêm group mới:

```dart
group('MenuViewModel events (M13)', () {
  test('requestGame → bắn MenuGameRequested lên events', () async {
    final vm = MenuViewModel(store: await makeStore(const {}));
    addTearDown(vm.dispose);

    // Broadcast stream: chỉ chờ đúng event kế tiếp — không có buffer
    // cho listener đến trễ (điểm khác BehaviorSubject sẽ học ở M14).
    final emitted = vm.events.first;
    vm.requestGame();

    expect(await emitted, isA<MenuGameRequested>());
  });

  test('resetProfile → bắn MenuSnackBarRequested kèm message', () async {
    final vm = MenuViewModel(store: await makeStore(const {}));
    addTearDown(vm.dispose);
    await vm.load();

    final emitted = vm.events.first;
    await vm.resetProfile();

    final event = await emitted;
    expect(event, isA<MenuSnackBarRequested>());
    expect(
      (event as MenuSnackBarRequested).message,
      'Đã đặt lại hồ sơ.',
    );
  });

  test('listener đến trễ KHÔNG nhận event đã bắn (broadcast)', () async {
    final vm = MenuViewModel(store: await makeStore(const {}));
    addTearDown(vm.dispose);

    vm.requestGame(); // chưa ai listen → event trôi qua, không đệm

    // Subscribe sau → chỉ nhận event TIẾP THEO, không phải cái đã
    // bắn: event là "đã xảy ra", không phải "giá trị hiện tại".
    var got = 0;
    vm.events.listen((_) => got++);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(got, 0);

    vm.requestGame();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(got, 1);
  });
});
```

`vm.events.first` là chiêu chính: nó trả `Future` hoàn thành bởi
event kế tiếp — `await` nó sau khi gọi method = bắt event đang bay.

### Bước 2 — widget test: cả đường event

File mới `test/menu_ui_events_test.dart` — hai test cho hai hành động:

```dart
/// Test widget của M13: event một-lần đi từ VM → bridge → hành động UI.
///
/// Không dùng `pumpAndSettle`: `menuSessionTicker` (M06) là Timer
/// vô hạn nên "settle" không bao giờ đến — pump thủ công theo đúng
/// thời lượng animation route (~300ms) thay thế.

testWidgets('bấm BẮT ĐẦU CHƠI → VM event → push GameScreen',
    (tester) async {
  final store = await makeStore();
  await tester.pumpWidget(await scopedMenu(store));
  await tester.pump(); // cho load() hoàn thành → ready

  await tester.tap(find.text('BẮT ĐẦU CHƠI'));
  await tester.pump(); // event → bridge → push bắt đầu
  await tester.pump(const Duration(milliseconds: 400)); // animation

  expect(find.text('Phòng chơi'), findsOneWidget);

  await tester.pumpWidget(const SizedBox()); // unmount → cancel sub
});

testWidgets('bấm ĐẶT LẠI HỒ SƠ → VM event → SnackBar hiện',
    (tester) async {
  final store = await makeStore();
  await tester.pumpWidget(await scopedMenu(store));
  await tester.pump();

  // Nút nằm dưới fold của scroll view — cuộn cho vào vùng chạm
  // được trước khi tap (tap offscreen chỉ warn, không gọi onTap).
  final resetButton = find.text('ĐẶT LẠI HỒ SƠ');
  await tester.ensureVisible(resetButton);
  await tester.pump();
  await tester.tap(resetButton);
  await tester.pump(); // clear() + event → bridge → SnackBar
  await tester.pump(const Duration(milliseconds: 300));

  expect(find.text('Đã đặt lại hồ sơ.'), findsOneWidget);

  await tester.pumpWidget(const SizedBox());
});
```

`scopedMenu`/`makeStore` giống `menu_provider_scope_test.dart` (M12):
bọc `AppDependencyScope` + `MaterialApp` — test cây giống app thật.

## Hiểu code

- **Vì sao widget test cần `ensureVisible`?** `tap` chỉ tác động lên
  widget *hit-test được*; nút reset nằm dưới fold của scroll view →
  tap trần chỉ "warn" và im lặng bỏ qua — test fail kiểu khó đoán.
  `ensureVisible` cuộn nó vào viewport trước.
- **`stream.first` vs `listen`** — `first` tự subscribe một lần rồi
  huỷ: gọn cho "chờ đúng một event"; `listen` cần quản subscription
  (như bridge làm).
- **Test thứ ba chứng minh semantics broadcast** — không chỉ "có
  event" mà "không có replay": khác biệt then chốt với state-holder
  sẽ học ở M14.
- **Double-subscribe guard được bảo hiểm gián tiếp:** nếu re-subscribe
  tạo hai listener, `_openGame` chạy hai lần → push hai route → test
  CTA sẽ thấy chồng màn (và cấu trúc `==` guard ở `_attachViewModel`
  ngăn điều đó tận gốc).

## Chạy và quan sát

```text
$ flutter test    → 57/57 (52 cũ + 5 mới của M13)
$ flutter analyze → No issues found!
```

Chạy app thật: bấm ĐẶT LẠI HỒ SƠ → SnackBar "Đã đặt lại hồ sơ." trượt
lên; bấm BẮT ĐẦU CHƠI → màn game mở. Hai hành động đều xuất phát từ
event của VM, không còn từ widget trực tiếp.

## Lỗi hay gặp

1. **`tester.tap` nút offscreen** — cảnh báo hit-test và không gọi
   `onTap`; luôn `ensureVisible` trước.
2. **`pumpAndSettle` với ticker vô hạn** — test treo; pump tay.
3. **Assert SnackBar quá sớm** — `showSnackBar` xong cần ít nhất một
   `pump` để widget vào cây.
4. **`expect` event bằng `listen` thay vì `first`** — quên cancel
   subscription → test leak; `first` tự dọn.
5. **Test qua UI mà không test VM** — widget test xanh vẫn có thể che
   việc widget tự điều hướng; VM test khoá nguồn gốc ở `requestGame`.

## Kiểm tra hiểu biết

1. `vm.events.first` làm gì trong test? — *Subscribe một lần, trả
   Future hoàn thành bởi event kế tiếp — bắt event không cần quản
   subscription.*
2. Vì sao widget test CTA→GameScreen một mình chưa đủ chứng minh
   "điều hướng qua event"? — *Nếu `_onPlayTap` vẫn push trực tiếp
   test vẫn xanh; cần VM test `requestGame → event` để khoá đường
   đi qua kênh event.*
3. Test broadcast-no-replay chứng minh gì? — *Listener gắn sau khi
   event bắn nhận 0 event cũ — event là "đã xảy ra", không phải
   giá trị đọc lại được; đây là khác biệt cốt lõi event≠state.*

## Ta cố ý chưa thêm

- **`emitsInOrder`/`emits` matchers nhiều-event** — `events.first` đủ
  cho M13; stream-matcher phức tạp khi cần.
- **Test navigation trở về** (`pop` + `applyGameResult` qua bridge) —
  flow M10 vẫn nguyên; phủ thêm không đổi gì M13.
- **Event replay/buffered event** — chính semantics broadcast đã bỏ
  nó; cần buffer là vùng `rxdart` của M14.
- **Widget test đếm push hai lần** — guard `==` đảm bảo ở code; test
  cấu trúc này dễ flaky hơn là giá trị mang lại ở M13.

## Checkpoint hoàn thành

- [ ] `test/menu_view_model_test.dart` có group `MenuViewModel events
  (M13)` với 3 test: emit game-requested, emit snackbar kèm message,
  no-replay broadcast.
- [ ] `test/menu_ui_events_test.dart` có 2 widget test: CTA→GameScreen,
  reset→SnackBar; cả hai dùng `ensureVisible`/pump tay đúng.
- [ ] `flutter test` xanh 57/57.
- [ ] Giải thích được: `first` vs `listen` trong test; vì sao cần cả
  VM test lẫn widget test.
