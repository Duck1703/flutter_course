---
title: "Bài 4 · MenuViewModel nối vào stream"
description: "VM seed .value + listen trong constructor, state stream ≠ event stream, retire MenuLoadState/load()/_MenuLoading/_MenuErrorState, widget test stream propagation."
sidebar:
  label: "Bài 4 · MenuViewModel nối vào stream"
  order: 4
---

## Mục tiêu

Hoàn tất bước chuyển lớn nhất của M14: `MenuViewModel` sống trên
repository stream — và dọn đi toàn bộ vòng đời "load tay" mà M11 đã
từng cần.

## Bạn đang ở đâu

- Milestone: **M14** (bài 4/4)
- `UserProfileRepository` đã sẵn trong `AppDependencyScope`; VM vẫn
  đang ôm `ProfileStore` + `MenuLoadState` + `load()` của kỳ trước.

## Constructor mới — đúng shape senior

```dart
MenuViewModel({required UserProfileRepository userProfileRepository})
  : _userProfileRepository = userProfileRepository,
    _userData = userProfileRepository.userProfileStream.value {
  _userProfileSubscription = _userProfileRepository.userProfileStream
      .listen(_handleUserProfile);
}
```

Đọc kỹ vì cả ba điểm đều là ý đồ:

- **Tham số là CONTRACT** — `UserProfileRepository`, không phải impl.
  `create:` của provider sẽ tra `context.read<UserProfileRepository>()`.
- **`.value` trong initializer list**: `userProfileStream` là
  `ValueStream` — đọc đồng bộ được *trước cả khi ctor body chạy*. VM
  sinh ra đã có profile (tối thiểu là bản seeded).
- **`listen` trong ctor body**: subscribe ngay khi VM sinh — mọi emit
  sau này của repo chảy vào `_handleUserProfile`.

## Handler — state đến qua stream

```dart
void _handleUserProfile(UserProfileData userData) {
  if (_isDisposed) {
    return;
  }
  final shouldNotify = _userData != userData;
  _userData = userData;
  if (shouldNotify) {
    notifyListeners();
  }
}
```

- `_isDisposed` guard: một emit có thể đến *sau* khi VM dispose —
  `ChangeNotifier` đã chết không được `notifyListeners`.
- Compare-before-notify: cùng một profile thì không rebuild (senior
  `_handleUserProfile` làm đúng vậy).

Và dispose đổi theo:

```dart
@override
void dispose() {
  _isDisposed = true;
  _userProfileSubscription?.cancel();
  _events.close();
  super.dispose();
}
```

Cancel subscription *trước* khi đóng event controller — đúng thứ tự
dọn của senior.

## Writer không còn gán state tay

Đây là chỗ data flow đổi triệt để. Trước M14:

```dart
// CŨ — VM tự gán state rồi tự notify, store chỉ là nơi ghi
_profile = _profile.applyGameResult(result);
notifyListeners();
await _store.save(_profile);
```

M14:

```dart
Future<void> applyGameResult(GameResult result) async {
  await _userProfileRepository.saveUserProfile(
    _userData.applyGameResult(result),
  );
}
```

VM chỉ **save qua repo**. Repo emit → `_handleUserProfile` cập nhật
`_userData` + notify. Stream là nguồn truth duy nhất — writer nào
save cũng vậy: đúng hướng senior (ở senior, *game* VM save; learner
giữ áp kết quả ở menu tới M19/M22 — FR-04 — nhưng cơ chế stream đã
là của senior).

`resetProfile()` cũng vậy: `_userProfileRepository.resetUserProfile()`
→ stream tự cập nhật `_userData` → event `MenuSnackBarRequested` vẫn
bắn (FR-12 → M24).

`loadUserProfile()` giờ chỉ delegate:

```dart
Future<void> loadUserProfile() =>
    _userProfileRepository.loadUserProfile();
```

Vẫn gọi ở `create:` bằng `..loadUserProfile()` (tên method của senior)
— tác dụng là đọc disk → emit bản đã lưu vào stream.

## State stream ≠ event stream — phân biệt tử tế

VM bây giờ có HAI stream — đây là chỗ dễ nhầm nhất của milestone:

| | `userProfileStream` (repo) | `events` (VM) |
|---|---|---|
| Mang | **state** — "profile hiện tại là gì" | **event** — "vừa xảy ra gì" |
| Loại | `BehaviorSubject` → `ValueStream` | `StreamController.broadcast` |
| Subscriber mới | nhận ngay giá trị mới nhất (replay) | bỏ lỡ mọi event đã bắn |
| Câu hỏi trả lời | "bây giờ là gì?" | "vừa xảy ra gì?" |
| Ai subscribe | VM (ctor) | widget bridge (`didChangeDependencies`) |

Đừng học "mọi thứ đều là Stream" — đúng là cả hai cùng cơ chế, nhưng
**ngữ nghĩa khác nhau hẳn**: một cái luôn giữ hiện tại, một cái chỉ
nhớ những gì đang khi nó xảy ra. Chọn sai loại = bug tinh vi
(ví dụ profile mà broadcast → UI mở sau load thấy màn trống).

## Retire `MenuLoadState` — không còn gì để loading

Toàn bộ surface này biến mất khỏi `lib/`:

- `enum MenuLoadState { loading, ready, failed }`
- `MenuViewModel.loadState`, `_setLoadState`, method `load()`
- `_MenuLoading` (`CircularProgressIndicator` "Đang tải hồ sơ…")
- `_MenuErrorState` (icon lỗi + nút "THỬ LẠI")
- `switch (viewModel.loadState) { … }` trong build

Vì sao dám xoá? Vì senior không có surface này — repo seeded bằng
`BehaviorSubject` nên *luôn* có một giá trị profile để render;
`loadUserProfile()` chỉ nạp bản đã lưu vào stream chứ không phải điều
kiện để hiển thị. Menu của ta giờ render `userData` trực tiếp — frame
đầu thấy seed, emit sau tự cập nhật. (Đây chính là FR-08 → CONVERGED:
abstraction tạm M11 đã được thay bằng cơ chế thật của senior.)

Widget phía UI đổi tương ứng:

```dart
create: (context) => MenuViewModel(
  userProfileRepository: context.read<UserProfileRepository>(),
)..loadUserProfile(),
```

và trong build, mọi `viewModel.profile` → `viewModel.userData` (tên
getter của senior), `profile.totalEarningsDisplay` →
`profile.totalEarnings` (field đã format sẵn).

## Test chứng minh stream propagation

Hai test mới đáng đọc vì chúng chứng minh đúng điều M14 hứa:

```dart
// menu_view_model_test.dart — fake repo lái VM, không cần Flutter
await repo.saveUserProfile(const UserProfileData(username: 'An'));
await pumpEventQueue();
expect(vm.userData.username, 'An');
expect(notifies, 1);
```

```dart
// menu_provider_scope_test.dart — qua cả cây widget
await repo.saveUserProfile(const UserProfileData(username: 'Stream'));
await tester.pump();
await tester.pump();
expect(find.text('Stream'), findsOneWidget);
```

`pumpEventQueue()` / pump thứ hai là chi tiết thực tế: `subject.add`
đưa event vào queue — listener nhận ở microtask kế; test phải flush
queue trước khi assert.

## Tự kiểm tra

1. Vì sao `.value` đọc được trong initializer list? — *`ValueStream`
   của rxdart expose giá trị hiện tại đồng bộ; subject seeded nên
   giá trị tồn tại ngay khi ctor chạy.*
2. `applyGameResult` mất `notifyListeners` — ai báo UI rebuild? —
   *Repo emit → `_handleUserProfile` → notify. Stream là nguồn truth;
   writer không tự gán state.*
3. Vì sao `MenuLoadState` retire mà không "giữ lại phòng khi"? —
   *Repo seeded nên luôn có giá trị render; senior không có load
   surface — giữ nó là nuôi một abstraction không tồn tại ở đích.*
4. `events` và `userProfileStream` — listener đến trễ nhận gì? —
   *Event: không gì (đã qua). State stream: giá trị hiện tại ngay.*

## Ta cố ý chưa thêm

- **`sealed` cho event/state** — M15; `MenuUiEvent` vẫn `abstract` +
  `is`-check (FR-15).
- **Load settings/onboarding vào VM** — consumer của hai repo đó là
  M16/M18.
- **`authRepository` trong `loadUserProfile`** — senior gọi cả hai
  repo; learner chưa có auth (M24).

## Checkpoint hoàn thành

- [ ] `MenuViewModel` ctor nhận `UserProfileRepository`, seed `.value`,
      `listen` trong ctor; `dispose` có `_isDisposed` + cancel + close.
- [ ] `MenuLoadState`, `load()`, `loadState`, `_MenuLoading`,
      `_MenuErrorState` không còn trong `lib/`.
- [ ] `menu_screen.dart` render `viewModel.userData` trực tiếp —
      không switch load-state.
- [ ] `applyGameResult`/`resetProfile` chỉ gọi repo — không gán
      `_userData` tay.
- [ ] `flutter test` xanh: fake repo lái VM, repo impl persist qua
      disk, widget test thấy UI đổi khi repo emit.
