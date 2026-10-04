---
title: "Bài 3 · Stream cho state: BehaviorSubject & ValueStream"
description: "Từ broadcast event (M13) sang state stream: BehaviorSubject.seeded, .value vs .stream, replay cho subscriber trễ, isClosed, close(). Ví dụ độc lập trước, repo sau."
sidebar:
  label: "Bài 3 · BehaviorSubject & ValueStream"
  order: 3
---

## Mục tiêu

- Giải thích được tại sao `StreamController.broadcast` — đúng cho
  event — **sai** cho state.
- Dùng được `BehaviorSubject.seeded`, `.value`, `ValueStream`,
  `isClosed`, `close()`.
- Phân biệt *state stream* vs *event stream* bằng một câu hỏi mỗi
  loại trả lời.

Bài này vẫn **không đổi code app** — toàn bộ ví dụ chạy trên đoạn Dart
độc lập. Impl repo ở bài 4 sẽ "gõ lại" đúng những gì bài này dạy.

## Bạn đang ở đâu

- Milestone: **M14** (bài 3/7).
- Contract đã có (bài 2) và nó hứa `ValueStream<UserProfileData>` —
  giờ là lúc hiểu kiểu đó là gì trước khi impl nó.

## `Stream` thường thiếu gì cho state?

Nhớ lại M13: `StreamController<MenuUiEvent>.broadcast()` phát **event**
— listener đến trễ bỏ lỡ event đã bắn. Đúng cho "việc vừa xảy ra".

Nhưng profile là **state**: ai hỏi "giá trị hiện tại?" lúc nào cũng
phải có câu trả lời. Một `Stream` thường chỉ *chuyển tiếp* event —
nó không giữ "hiện tại là gì". Widget mở ra sau khi profile đã load
không nhận gì tới khi có emit mới. `MenuLoadState` của M11–M13 là
miếng vá con người cho thiếu hụt đó: vì stream thường không replay,
ta tự làm trạng thái "đang tải" để lấp khoảng trống.

Mental model mới:

```
EVENT stream (broadcast)          STATE stream (BehaviorSubject)
"việc vừa xảy ra"                 "giá trị hiện tại là gì"
  add(1) ──▶ chỉ ai đang nghe       seed(0) ──▶ giá trị luôn sẵn
            nhận được 1             .value == 0 bất cứ lúc nào
  subscribe trễ: miss 1             subscribe trễ: replay 0 ngay
  add(2) ──▶ nhận 2                 add(2) ──▶ .value == 2, emit 2
```

## `BehaviorSubject` — controller biết giữ "hiện tại"

Ví dụ độc lập (không liên quan profile — đọc như scratch Dart):

```dart
import 'package:rxdart/rxdart.dart';

void main() async {
  final counter = BehaviorSubject<int>.seeded(0);   // giá trị hiện tại = 0

  print(counter.value);          // 0 — đọc ĐỒNG BỘ, không cần listen

  counter.add(1);
  print(counter.value);          // 1

  final seen = <int>[];
  counter.stream.listen(seen.add);   // subscribe TRỄ (sau hai add)
  await Future<void>.delayed(Duration.zero);
  print(seen);                   // [1] — replay giá trị MỚI NHẤT, rồi nghe tiếp

  counter.add(2);
  await Future<void>.delayed(Duration.zero);
  print(seen);                   // [1, 2]

  await counter.close();
}
```

Ba hành vi cần thuộc:

- `.seeded(v)` — subject sinh ra đã mang sẵn giá trị `v`; `.value`
  luôn hợp lệ ngay từ đầu. (Không-seeded `BehaviorSubject<int>()`
  `.value` sẽ ném khi chưa có emit — senior luôn seed.)
- **Replay latest**: subscriber mới nhận *ngay* giá trị hiện tại — đó
  là điểm broadcast không làm được.
- `.add(v)` giống controller thường — nhưng mỗi `add` đồng thời cập
  nhật `.value`.

**Android bridge:** `BehaviorSubject.seeded` ≈ `MutableStateFlow` —
giữ giá trị hiện tại, collector mới nhận ngay. **Khác quan trọng:**
Dart không tự đóng subject — không `close()` thì nó sống mãi (leak);
và `.value` chỉ có trên value-stream của rxdart, `Stream` SDK không
có. ĐỪNG đánh đồng `BehaviorSubject` = `StateFlow` — chỉ là cùng vai
trò "latest-value stream".

## `ValueStream` — mặt ĐỌC của subject

Vì sao contract (bài 2) trả `ValueStream` chứ không trả
`BehaviorSubject`? Vì subject là quyền **ghi**: ai cầm được subject đều
`add` được → ai cũng có thể bắn state giả. `ValueStream` chỉ cho đọc:

```dart
final subject = BehaviorSubject<int>.seeded(0);
ValueStream<int> readFace = subject.stream;   // .stream trả ValueStream

readFace.value;      // 0 — đọc được
readFace.listen(...);// listen được — đúng Stream
// readFace.add(5);  // KHÔNG COMPILE — ValueStream không có add
```

`ValueStream<T>` = `Stream<T>` **+** `T get value` — vừa `listen`,
vừa đọc `.value` đồng bộ. Repo trong giữ `BehaviorSubject` (ghi
được); ngoài thấy `ValueStream` (đọc được). Ranh giới đọc/ghi này là
chủ đích của senior — cùng pattern `MutableStateFlow` private +
`StateFlow` public bạn đã biết trong MVVM Android.

## `isClosed` và `close()` — lifecycle của subject

```dart
if (!subject.isClosed) {
  subject.add(v);     // add vào subject ĐÃ ĐÓNG ném StateError
}
await subject.close();
```

- `isClosed` là guard trước `add`: emit đến sau khi dispose sẽ crash
  nếu không guard — impl repo ở bài 4 dùng đúng guard này.
- `close()` trả `Future` — subject dọn event đang chờ rồi đóng. Ai
  tạo subject chịu trách nhiệm đóng nó; repo app-scoped sống cùng app
  nên `dispose()` chủ yếu phục vụ test.

## Hai loại stream trong cùng một VM

Sang bài 7 `MenuViewModel` sẽ ôm **hai** stream — đặt bảng này vào đầu
ngay từ bây giờ vì đây là chỗ nhầm nhất của cả milestone:

|  | `userProfileStream` (repo) | `events` (VM) |
| --- | --- | --- |
| Mang | **state** — "profile hiện tại là gì" | **event** — "vừa xảy ra gì" |
| Loại | `BehaviorSubject` → `ValueStream` | `StreamController.broadcast` |
| Subscriber mới | nhận ngay giá trị mới nhất | bỏ lỡ mọi event đã bắn |
| Câu hỏi | "bây giờ là gì?" | "vừa xảy ra gì?" |
| Cần `.value`? | Có — VM seed state từ nó | Không — event không có "hiện tại" |

Chọn sai loại là bug tinh vi: profile mà broadcast → màn mở sau load
thấy trống; snackbar mà subject → màn mở lại thấy snackbar cũ bay ra.

## Lỗi hay gặp

- **`subject.value` trên subject không seeded** — `StateError` khi
  chưa có emit đầu. Luôn `.seeded(...)` khi cần `.value` đáng tin.
- **Quên `close()`** — không crash, nhưng leak: subject + listener
  sống mãi. Trong app thật repo sống cùng app nên ít thấy; trong test
  thiếu close làm test treo/ô nhiễm.
- **`add` sau `close`** — `StateError`. Emit path của repo phải guard
  `isClosed` (bài 4).
- **Dùng broadcast cho state** — màn sau không thấy dữ liệu; đây
  chính là lý do `MenuLoadState` từng phải tồn tại.

## Tự làm

**Dự đoán — đừng chạy trước.** Với `s = BehaviorSubject<int>.seeded(10)`:

```dart
s.add(20);
final a = <int>[];
s.stream.listen(a.add);
s.add(30);
final b = <int>[];
s.stream.listen(b.add);   // listener thứ hai, đăng ký muộn hơn
await pumpEventQueue();   // helper flutter_test: flush mọi microtask
                          // đang chờ — chạy `dart run` thuần thì dùng
                          // Future.delayed(Duration.zero) thay thế;
                          // giải thích kỹ ở bài 4
```

1. `a` chứa gì? `b` chứa gì?
2. `s.value` là bao nhiêu lúc cuối?
3. Nếu `s` là `StreamController<int>.broadcast()`, `a` và `b` khác
   gì?

<details><summary><strong>Đáp án</strong></summary>

1. `a` = `[20, 30]` — subscribe sau `add(20)` nhưng subject replay
   latest → nhận 20 ngay, rồi 30. `b` = `[30]` — subscribe sau
   `add(30)` → replay 30.
2. `s.value == 30`.
3. Broadcast: `a` = `[30]` (miss 20), `b` = `[]` (không replay —
   `add(30)` đã qua trước khi b subscribe).

Điểm mấu chốt: **mỗi subscriber trễ của subject nhận đúng một replay
— giá trị mới nhất tại thời điểm subscribe**, không phải toàn bộ
lịch sử.
</details>

## Tự kiểm tra

1. `BehaviorSubject` khác `StreamController.broadcast` ở đâu? —
   *Subject giữ "giá trị hiện tại", replay cho subscriber mới;
   broadcast chỉ phát tới listener đang sống.*
2. Vì sao getter public là `ValueStream` chứ không `BehaviorSubject`? —
   *ValueStream chỉ cho đọc (listen + .value); lộ subject là lộ
   quyền `add` cho mọi consumer.*
3. `.value` có trên mọi `Stream` không? — *Không — chỉ value-stream
   của rxdart; Stream SDK không biết "hiện tại".*

## Ta cố ý chưa thêm

- **Operators rxdart** (`switchMap`, `debounce`, `retry`…) — roadmap
  loại khỏi M14; repo chỉ cần subject + stream.
- **PublishSubject/ReplaySubject** — không cần: state repo cần đúng
  "latest + value" mà BehaviorSubject đã cho.

## Checkpoint hoàn thành

- [ ] Nói được hai câu hỏi phân biệt state stream vs event stream.
- [ ] Dự đoán đúng kết quả replay cho subscriber trễ (bài Tự làm).
- [ ] Giải thích vì sao contract expose `ValueStream` chứ không
      `BehaviorSubject`.
- [ ] `flutter analyze` vẫn sạch (bài này không đổi code).

## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — toàn bộ ví dụ `BehaviorSubject`/`ValueStream` chạy trên Dart độc lập; impl repo mới là bài 4. Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, hỏi AI local: *"Cho `s = BehaviorSubject<int>.seeded(10); s.add(20);` rồi một listener subscribe — listener nhận gì và vì sao? Đổi sang `StreamController.broadcast` thì khác gì?"* — đối chiếu với bảng state-stream vs event-stream trong bài.

Checkpoint code sang bài sau: `pubspec.yaml` đã có `rxdart` (bài 2); `user_profile_repository.dart` vẫn chỉ là contract trần — chưa có impl, chưa ai gọi.
