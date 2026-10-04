---
title: "Bài 2 · RxDart: BehaviorSubject & ValueStream"
description: "BehaviorSubject.seeded, ValueStream, .value vs .stream, replay semantics, isClosed, dispose — vì sao repository senior chọn subject của rxdart."
sidebar:
  label: "Bài 2 · BehaviorSubject & ValueStream"
  order: 2
---

## Mục tiêu

Hiểu đúng ba khái niệm rxdart mà repository senior dùng:
`BehaviorSubject`, `ValueStream`, `.value` — và vì sao
`StreamController.broadcast` thuần Dart không đủ cho *state*.

## Bạn đang ở đâu

- Milestone: **M14** (bài 2/4)
- Contract đã viết (bài 1): `ValueStream<UserProfileData> get
  userProfileStream` — giờ là phần làm stream đó tồn tại.

## `Stream` thường thiếu gì cho state?

Nhớ lại M13: `StreamController<MenuUiEvent>.broadcast()` phát **event**
— listener đến trễ bỏ lỡ event đã bắn. Đó là đúng cho "việc vừa xảy
ra".

Nhưng profile là **state**: ai hỏi "giá trị hiện tại?" lúc nào cũng
phải có câu trả lời. `StreamController` thường không giữ "giá trị hiện
tại" — nó chỉ chuyển tiếp các event. Một widget mở ra sau khi profile
đã load sẽ không nhận gì tới khi có emit mới. `MenuLoadState` của
M11–M13 chính là miếng vá cho thiếu hụt đó: vì stream thường không
replay, ta phải tự làm trạng thái "đang tải".

## Dart mới: package `rxdart` + `BehaviorSubject`

`rxdart` là package bổ sung các *subject* và *operator* cho `Stream`
của Dart SDK — bản senior ghim `rxdart: ^0.28.0`, learner thêm y hệt
vào `pubspec.yaml` rồi `flutter pub get`.

```yaml
dependencies:
  rxdart: ^0.28.0
```

```dart
import 'package:rxdart/rxdart.dart';
```

**`BehaviorSubject`** là một StreamController đặc biệt:

```dart
final _userProfileSubject = BehaviorSubject<UserProfileData>.seeded(
  const UserProfileData(),
);
```

- `.seeded(v)`: subject sinh ra đã mang sẵn giá trị `v`.
- Nó luôn biết **giá trị hiện tại**: `_userProfileSubject.value`.
- Listener subscribe muộn **được replay ngay giá trị mới nhất** — rồi
  tiếp tục nhận các emit sau.
- `_userProfileSubject.add(v)` đẩy giá trị mới, giống controller.

> **Android bridge:** giống `MutableStateFlow` — giữ giá trị hiện tại,
> collector mới nhận ngay giá trị đó. **Khác quan trọng:** Dart không
> tự đóng subject — không `close()` thì stream sống mãi (leak); và
> `.value` chỉ tồn tại trên value-stream của rxdart, `Stream` thường
> không có. ĐỪNG đánh đồng `BehaviorSubject` = `StateFlow` — chỉ là
> cùng vai trò "latest-value stream".

## `ValueStream` — mặt ĐỌC của subject

Contract không trả `BehaviorSubject` ra ngoài (đó là quyền ghi — ai
cũng `add` được thì loạn). Nó trả `ValueStream`:

```dart
@override
ValueStream<UserProfileData> get userProfileStream =>
    _userProfileSubject.stream;
```

- `ValueStream<T>` = `Stream<T>` **+** `T get value` — vừa `listen`
  được, vừa đọc `.value` đồng bộ được.
- Repo trong giữ `BehaviorSubject` (ghi được); ngoài thấy `ValueStream`
  (đọc được). Ranh giới đọc/ghi này là có chủ đích của senior.

## Emit có guard — `isClosed` và so-sánh

```dart
UserProfileData _emitUserProfile(UserProfileData userData) {
  if (!_userProfileSubject.isClosed &&
      _userProfileSubject.value != userData) {
    _userProfileSubject.add(userData);
  }
  return userData;
}
```

Ba điểm đều quan trọng:

- `isClosed`: `add` vào subject đã `close()` ném lỗi — guard chặn
  crash khi emit đến sau dispose.
- `value != userData`: profile mới *giống hệt* hiện tại thì không
  emit — subscriber không nhận event thừa (và UI không rebuild thừa).
  Nhờ `==`/`hashCode` đầy đủ trên model (M04) nên so này là so *giá
  trị*, không phải identity.
- Hàm `return userData` dù emit hay không — `loadUserProfile()` cần
  trả profile về dù có phải emit mới không.

## Lifecycle: `dispose()` đóng subject

```dart
@override
Future<void> dispose() => _userProfileSubject.close();
```

Repo sống suốt đời app (tạo ở `main`, không ai gọi dispose trong app
thật — đúng như senior); `dispose` tồn tại cho **test** và cho chính
sách ownership rõ ràng: ai tạo subject thì có trách nhiệm đóng nó.

## Replay trong thực tế — test chứng minh

```dart
await repo.saveUserProfile(const UserProfileData(username: 'Late'));
final seen = <UserProfileData>[];
repo.userProfileStream.listen(seen.add);   // subscribe MUỘN
await pumpEventQueue();
expect(seen.single.username, 'Late');      // vẫn nhận giá trị hiện tại
```

Với `StreamController.broadcast` của M13, listener đó sẽ không nhận
gì — event "save" đã qua rồi. `BehaviorSubject` replay `value` mới
nhất ngay khi subscribe.

## Tự kiểm tra

1. `BehaviorSubject` khác `StreamController.broadcast` ở đâu? —
   *Subject giữ "giá trị hiện tại", replay cho subscriber mới;
   broadcast controller chỉ phát event tới các listener đang sống.*
2. Vì sao getter public là `ValueStream` chứ không `BehaviorSubject`? —
   *`ValueStream` chỉ cho đọc (listen + .value); trả subject ra ngoài
   là lộ quyền `add` cho mọi consumer.*
3. `.value` có trên mọi `Stream` không? — *Không — chỉ value-stream
   (rxdart). `Stream` SDK thường không biết "giá trị hiện tại".*
4. Vì sao emit guard `value != userData`? — *Chặn event thừa cho một
   "đổi" không đổi — subscriber/UI không nhận tín hiệu vô nghĩa.*

## Ta cố ý chưa thêm

- **Operators rxdart nâng cao** (`switchMap`, `Retry`, `debounce`…) —
  roadmap loại khỏi M14; repo chỉ cần subject + stream.
- **`part`/extension trên `ValueStream`** — senior dùng một ít; chỉ
  đọc để biết, không cần cho learner app giờ này.

## Checkpoint hoàn thành

- [ ] `pubspec.yaml` có `rxdart: ^0.28.0`; `flutter pub get` sạch.
- [ ] Impl chứa `BehaviorSubject<UserProfileData>.seeded(const
      UserProfileData())`; getter `userProfileStream` trả
      `_subject.stream`.
- [ ] `_emitUserProfile` có đủ hai guard `isClosed` + `value !=`.
- [ ] `dispose()` trả `Future<void>` và `close()` subject.
- [ ] Giải thích được: vì sao state cần subject replay mà event thì
      không.
