---
title: "Bài 1 · Stream ≠ Future"
description: "Stream<T> là chuỗi event theo thời gian, Stream.periodic, mental model subscription, và test stream với take/emitsInOrder/first."
sidebar:
  label: "Bài 1 · Stream là gì"
  order: 1
---

## Mục tiêu

Hiểu chính xác `Stream<T>` khác `Future<T>` ở đâu — **một kết quả về sau**
so với **nhiều event theo thời gian** — viết được
`Stream<int> menuSessionTicker()` bằng `Stream.periodic`, và test một
stream bằng `take` + `emitsInOrder` + `first`.

## Bạn đang ở đâu

- Milestone: **M06 — Stream & StreamBuilder** (bài 1/3)
- App hiện tại: profile tải async qua `FutureBuilder` (M05). Menu đang
  "tĩnh" sau khi tải — chưa có gì tự đổi theo thời gian.

## Vì sao việc này quan trọng ngay bây giờ

Future giải quyết "việc xong sau một lần". Nhưng app có nhiều thứ *phát
nhiều lần*: profile thay đổi mỗi khi save, settings đổi mỗi khi toggle,
timer game đếm ngược từng giây, event UI bắn ra từng lần một. Tất cả đều
là `Stream` — và mọi repository của senior đều expose `ValueStream`.
Hiểu `Stream` là chìa vào M13 (UI events), M14 (repository streams), M17
(locale switch live).

## Bạn đã biết gì

- `Future`/`async`/`await`, `FutureBuilder` + `AsyncSnapshot` (M05).
- Model + test pure Dart (M04).

## Mental model mới

Timeline — in chìm hình này:

```
Future<T>:   gọi ────────────────► hoàn thành: 1 value (hoặc 1 lỗi)
Stream<T>:   subscribe ──► event ──► event ──► event ──► … (có thể vô hạn)
             huỷ subscribe ở đâu ────────────────────────▶ done
```

- `Future<T>`: một "hộp" sẽ mở ra một lần → `T` hoặc error.
- `Stream<T>`: một **ống** — event chảy qua nhiều lần; không có "kết quả
  cuối", chỉ có *event tiếp theo* (hoặc stream đóng / bạn huỷ).

**Subscription = "ai đó đang nghe".** Stream *lười*: `Stream.periodic`
không tự phát — chỉ khi có listener (`stream.listen(...)`, hoặc một widget
như `StreamBuilder` nghe giùm) thì event mới được tạo và đẩy tới. Khi
listener huỷ (`cancel()`), stream ngừng phát cho listener đó.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
| --------- | ------- | ------- |
| `Stream<T>` | `Stream<int> s = …` | Kiểu "chuỗi event T" |
| `Stream.periodic(d, fn)` | `Stream<int>.periodic(const Duration(seconds: 1), (t) => t + 1)` | Stream phát event mỗi `d`; `fn` nhận số thứ tự tick (0,1,2…) → trả event |
| `stream.listen(fn)` | `s.listen((v) => …)` | Subscribe: `fn` được gọi mỗi event → trả `StreamSubscription` |
| `stream.take(n)` | `s.take(3)` | Stream mới chỉ phát tối đa `n` event đầu rồi đóng |
| `stream.first` | `await s.first` | `Future` hoàn thành với event đầu tiên |
| `emitsInOrder` | `expect(s.take(3), emitsInOrder([1,2,3]))` | Matcher test: stream phát đúng chuỗi theo thứ tự |

`Stream.periodic(step, computation)`: cứ mỗi `step` sau khi có người nghe,
`computation(tickCount)` được gọi với `tickCount = 0, 1, 2…` và kết quả là
event. Ta `tick + 1` để event là "giây thứ 1, 2, 3…".

## Ví dụ độc lập — stream *lười*, nhìn tận mắt

Chạy trong DartPad (pure Dart, import `dart:async`):

```dart
import 'dart:async';

void main() {
  final s = Stream<int>.periodic(
    const Duration(milliseconds: 400),
    (tick) => tick * 10,
  );

  print('A: stream vừa tạo — có gì chạy chưa?');

  s.take(4).listen((v) => print('event: $v'));

  print('B: đã listen xong — chờ event');
}
```

Output (kèm khoảng cách thời gian thật ~0.4s giữa các dòng event):

```
A: stream vừa tạo — có gì chạy chưa?
B: đã listen xong — chờ event
event: 0
event: 10
event: 20
event: 30
```

Hai quan sát đáng tiền:

- Giữa "tạo stream" và "listen" **không có event nào được phát** — in `A`
  rồi `B` liền nhau vì `listen` trả về ngay (nó đăng ký, không chờ).
  Nhịp chỉ bắt đầu *sau khi* có listener: đó là "lazy".
- `take(4)` biến stream vô hạn thành "4 event rồi đóng" — sau `30` chương
  trình im lặng, subscription kết thúc. Trong app, `StreamBuilder` đóng
  vai `listen` này cho bạn (bài 2).

## Flutter cần dùng

Chưa có widget mới trong bài này — `StreamBuilder` ở bài 2. Bài này thuần
Dart + test.

## Cầu nối Android / Compose

- SIMILARITY: `Stream<T>` ≈ `Flow<T>` — cùng ý niệm chuỗi giá trị;
  `stream.listen` ≈ `flow.collect`.
- IMPORTANT DIFFERENCE: Dart `Stream` **mặc định là single-subscription** —
  một stream chỉ cho *một* listener sống; muốn nhiều listener phải
  `asBroadcastStream()`/`StreamController.broadcast` (bài 3). Không có
  structured-concurrency scope: subscription **phải tự cancel** — không có
  `viewModelScope` huỷ giùm.
- DO NOT ASSUME: `Stream` = `Flow` cold/hot giống hệt — Dart tách rõ hai
  kiểu bằng single-subscription vs broadcast, không phải cold/hot theo
  cách Kotlin; và `Stream` không "tạm dừng" chờ collector xử lý nhanh-chậm
  như `Flow` backpressure — event được đẩy theo nhịp phát.

## Trong project senior

- `flutter-accelerator-ai/lib/repositories/profile/user_profile_repository.dart`
  — `ValueStream<UserProfileData> get userProfileStream` — repository
  expose *stream profile*: mỗi lần save, một event profile mới chảy ra.
  (Kèm `BehaviorSubject.seeded` của rxdart — M14 sẽ giải thích.)
- `flutter-accelerator-ai/lib/view_models/menu/menu_screen_view_model.dart`
  — `_events = StreamController<MenuScreenUiEvent>.broadcast()` và hai
  `StreamSubscription` được `.cancel()` trong `dispose()` — senior subscribe
  và huỷ tay. Bài 3 sẽ nhìn kỹ pattern này.
- Sự khác biệt cố ý: senior dùng `ValueStream` (rxdart — có `.value` đọc
  giá trị hiện tại); ta học `Stream` của SDK trước — `ValueStream` là
  `Stream` + quyền đọc lại giá trị mới nhất, hiểu sau khi Stream vững.

## Từng bước thực hiện

### Bước 1 — Nguồn stream

:::caution[TEACHING SCAFFOLD]
`menuSessionTicker` là **scaffold dạy học** — một stream nhân tạo để bạn
thấy Stream/StreamBuilder hoạt động trước khi có stream "thật". Senior
app không đếm giây mở menu; stream thật của menu là **repository stream**
(`userProfileStream` — BehaviorSubject của repo, M14). Ticker sẽ retire
khi đó. Giá trị của nó là *concept*, không phải feature.
:::

Tạo `lib/data/menu_session_ticker.dart`:

```dart
/// Stream đếm thời gian màn hình menu đang mở — nguồn stream đơn giản
/// phục vụ giảng dạy M06.
///
/// `Stream.periodic` phát một event mỗi [step]; computation `(tick)` đếm
/// từ 0 → ta `+ 1` để event là "giây thứ N" (1, 2, 3, …).
///
/// Stream là *lười*: không có event nào chạy cho tới khi có listener
/// subscribe — trong app, `StreamBuilder` chính là listener đó.
Stream<int> menuSessionTicker({
  Duration step = const Duration(seconds: 1),
}) {
  return Stream<int>.periodic(step, (tick) => tick + 1);
}
```

- FILE: `lib/data/menu_session_ticker.dart` (mới)
- CHANGE: hàm top-level trả `Stream<int>` — giống `loadDemoProfile` trả
  `Future<…>`, nhưng đây là chuỗi không vỏ bọc Future.
- WHY: một nguồn stream đủ nhỏ để nhìn "event theo thời gian" mà không cần
  game timer (M09 mới có countdown thật).
- WHAT IS NEW: `Stream<int>.periodic` + computation nhận số tick;
  `step` làm param — testable như `delay` ở M05.

### Bước 2 — Test stream

`test/menu_session_ticker_test.dart`:

```dart
import 'package:ai_millionaire_course/data/menu_session_ticker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('menuSessionTicker', () {
    test('phát 1, 2, 3 theo đúng thứ tự', () {
      // `take(3)` giới hạn stream còn 3 event — test kết thúc khi đủ.
      // `emitsInOrder` là matcher cho Stream: khẳng định thứ tự các event.
      expect(
        menuSessionTicker().take(3),
        emitsInOrder([1, 2, 3]),
      );
    });

    test('event đầu tiên là 1 (giây đầu tiên của phiên)', () async {
      // `.first` trả Future hoàn thành với event đầu tiên của stream.
      final first = await menuSessionTicker().first;

      expect(first, 1);
    });
  });
}
```

- `expect(stream, emitsInOrder([…]))` — `expect` nhận **Stream** làm
  actual; `emitsInOrder` chờ đủ các event theo thứ tự. Với `take(3)`, stream
  tự đóng sau event 3 → matcher kết luận đủ.
- `await stream.first` — `first` là `Future<int>`: cầu nối hai thế giới —
  stream "phát mãi" → `first` chỉ lấy event đầu như một Future.
- Test chạy *theo thời gian thật*: `take(3)` tốn ~3 giây; `flutter test`
  sẽ chờ — nhìn timestamp tăng là thấy stream đang phát từng giây. (Virtual
  time/clock trong test là kỹ thuật M19+.)

`flutter test` → `+15: All tests passed!`.

## Đọc hiểu code

```
menuSessionTicker() trả Stream (chưa có gì chạy)
        │
        ▼ ai đó nghe (listen / StreamBuilder / test matcher)
mỗi 1s: computation(0) → 1 ─► event 1
mỗi 1s: computation(1) → 2 ─► event 2
mỗi 1s: computation(2) → 3 ─► event 3   … mãi mãi
        │
        ▼ listener cancel / widget gỡ → stream ngừng phát cho listener đó
```

Chú ý: tạo stream ≠ stream chạy. `Stream.periodic` chỉ bắt đầu nhịp khi có
listener — đó là nghĩa của "lazy".

## Chạy và quan sát

- `flutter test` — thấy test ticker *mất ~3s* (thời gian thật của stream).
- `flutter analyze` → sạch. App chưa đổi — bài 2 nối ticker vào UI.

## Lỗi thường gặp

1. **Nghĩ stream tự chạy khi được tạo** — không: lazy đến khi có listener.
   Ngược lại với trực giác nếu bạn quen hot-observable.
2. **So `Future` với `Stream` như cùng một thứ** — Future = 1 kết quả;
   Stream = N event. Khi nào "xong một lần" → Future; "phát liên tục" →
   Stream.
3. **`listen` mà không giữ `StreamSubscription`** — không cancel được;
   bài 3 sẽ nói vì sao điều đó rò rỉ.
4. **`await s.first` quên stream không phát** — `.first` chờ event đầu; nếu
   stream không bao giờ phát (hoặc đã đóng) → chờ mãi/lỗi. Ticker của ta
   luôn phát nên an toàn.

## Kiểm tra hiểu biết

1. `Future<T>` vs `Stream<T>` khác nhau cốt lõi ở đâu? — Future hoàn thành
   một lần với một `T` (hoặc lỗi); Stream phát nhiều `T` theo thời gian.
2. Khi nào `Stream.periodic` bắt đầu phát? — Khi có listener subscribe
   (lazy). Không ai nghe → không có nhịp.
3. `take(3)` làm gì? — Trả stream mới phát tối đa 3 event đầu rồi đóng —
   tiện cho test.
4. `stream.first` trả gì? — `Future<T>` của event đầu tiên.

## Tự làm (PRODUCE)

Viết một hàm mới — `Stream<int> countdown(int from)` — phát `from,
from-1, …, 1` mỗi 100ms rồi đóng. Chỉ được dùng những gì bài này đã dạy
(`Stream.periodic` + computation + `take`).

Trước khi code:

1. `computation` nhận `tick` đếm từ 0 — biểu thức nào biến `0,1,2,…`
   thành `from, from-1, …`?
2. Stream `periodic` là vô hạn — đặt giới hạn `take(?)` ở đâu: trong
   hàm (stream trả về đã giới hạn) hay để người gọi tự giới hạn? **Bạn
   quyết** và bảo vệ lựa chọn đó.
3. Dự đoán output của `countdown(3)` trước khi verify.

Verify bằng DartPad: `countdown(3).listen(print)` phải in `3, 2, 1`
(hoặc test `emitsInOrder([3,2,1])` nếu bạn đưa hàm vào project).

:::note[Gợi ý]
`tick + 1` biến `0,1,2,…` thành `1,2,3,…`. Phép biến ngược —
`0,1,2,…` → `N, N-1, N-2, …` — cũng chỉ là một phép tính trên `tick`.
:::

<details><summary>Đáp án</summary>

```dart
Stream<int> countdown(int from) {
  return Stream<int>.periodic(
    const Duration(milliseconds: 100),
    (tick) => from - tick,
  ).take(from);
}
```

- `tick` chạy `0,1,2,…`; `from - tick` cho `3,2,1,0,-1,…` → phải cắt
  trước `0` → `take(from)` (3 event đầu).
- Đặt `take` **trong hàm** là lựa chọn chặt hơn: `countdown` *theo định
  nghĩa* là hữu hạn — một stream vô hạn phát số âm không còn là
  "countdown". Giới hạn thuộc về ngữ nghĩa của hàm chứ không phải của
  người gọi. (Nếu bạn để người gọi `take` và ghi rõ điều đó trong doc,
  cũng bảo vệ được — điểm là quyết định phải có lý do.)
- Khi `take(from)` đủ event, stream **đóng** — subscription kết thúc,
  periodic ngừng. Không cần huỷ tay cho stream đã đóng.

</details>

## Cố ý chưa làm

- `StreamBuilder` — bài 2.
- `StreamController`, `broadcast`, `await for`, `StreamSubscription` chi
  tiết — bài 3.
- `ValueStream`/`BehaviorSubject` (rxdart) — M14; đây là layer senior.
- Stream transformer (`map`, `where`, `debounce`…) — khi cần ở M13/M14.
- `fakeAsync`/virtual clock trong test — M19.

## Điểm kiểm tra hoàn thành

- [ ] `lib/data/menu_session_ticker.dart` trả `Stream<int>.periodic`.
- [ ] `test/menu_session_ticker_test.dart` 2 test: `emitsInOrder` + `first`.
- [ ] `flutter test` → 15 xanh (ticker test chạy theo giây thật).
- [ ] Bạn vẽ được timeline Future vs Stream không nhìn lại bài.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m06/01 — "Stream ≠ Future".

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test` (có thể giới hạn `flutter test test/menu_session_ticker_test.dart` — test này chạy ~3 giây thật, đó là bình thường). Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này thêm một stream nguồn + test — stream CHƯA nối vào UI (bài sau, không thiếu).

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/menu_session_ticker.dart` tồn tại (STRICT path) với hàm top-level `Stream<int> menuSessionTicker({Duration step = const Duration(seconds: 1)})` trả `Stream<int>.periodic(step, (tick) => tick + 1)` (STRICT: param `step` cho testability; event là tick+1 = giây 1,2,3…).
- `test/menu_session_ticker_test.dart` tồn tại với `group('menuSessionTicker', ...)` gồm ~2 test: `expect(menuSessionTicker().take(3), emitsInOrder([1, 2, 3]))` và `await menuSessionTicker().first` → `1` (STRICT hai matcher cơ chế: take+emitsInOrder và .first).
- Nếu learner đưa bài Tự làm `countdown` vào project: một hàm trả `Stream<int>.periodic(...).take(from)` có thể tồn tại — chấp nhận, miễn semantic đúng (phát from…1 rồi đóng).
- `flutter test` → "All tests passed!" khoảng +15 (10 model + 3 loader + 2 ticker); `flutter analyze` → "No issues found!".
- `lib/screens/menu_screen.dart` CHƯA có `StreamBuilder`/`_sessionTicker` — nối stream vào UI là bài 2, không chấm thiếu.

INVARIANTS NỀN:
- Tầng async M05 nguyên vẹn: `demo_profile_loader.dart`, `late Future<void> _profileLoadFuture` + `_loadProfile`/`_retryLoadProfile`, `FutureBuilder<void>` ba nhánh, `_MenuLoading`/`_MenuErrorState`; `main` là `Future<void> main() async` + `ensureInitialized`.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (đã dùng stream trong UI) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m06/01
PROJECT_ALIGNMENT: ON_TRACK | NEEDS_FIX | DIVERGED | BLOCKED
COURSE_POSITION: ON_TRACK | BEHIND | AHEAD_COMPATIBLE | AHEAD_RISKY
READY_FOR_NEXT_LESSON: YES | YES_AFTER_FIXES | NO
VERIFICATION_PERFORMED:
WHAT_MATCHES:
GAPS:
AHEAD_OF_COURSE:
DIVERGENCES:
REQUIRED_FIXES_BEFORE_CONTINUING:
EVIDENCE: file/symbol → observation
FILES_MODIFIED_BY_REVIEW: NONE
```
