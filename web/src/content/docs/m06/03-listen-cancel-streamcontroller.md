---
title: "Bài 3 · listen, cancel & StreamController"
description: "StreamSubscription tay: listen/cancel/dispose; StreamController + broadcast() như learning example — và nhìn vào chỗ senior dùng chúng."
sidebar:
  label: "Bài 3 · Subscription & Controller"
  order: 3
---

## Mục tiêu

Hiểu subscription thật sự: `stream.listen(...)` trả `StreamSubscription`,
huỷ bằng `cancel()` — và khi nào `dispose` cần huỷ tay. Nhìn
`StreamController` + `.broadcast()` (ví dụ học tập, **không** nằm trong app
hiện tại) để sẵn sàng đọc `StreamController<…>.broadcast()` của senior.
Kết thúc M06 với bức tranh "từ Stream SDK → ValueStream của senior".

## Bạn đang ở đâu

- Milestone: **M06 — Stream & StreamBuilder** (bài 3/3)
- App hiện tại: `_SessionTickerCard` đếm giây qua `StreamBuilder` (bài 2) —
  StreamBuilder đang quản lý subscription giùm ta.

## Vì sao việc này quan trọng ngay bây giờ

`StreamBuilder` chỉ tiện khi *event đi thẳng ra UI*. Nhưng có nơi event
không render trực tiếp: một ViewModel nghe repository, một bridge chuyển
"event điều hướng" thành `Navigator.push`, một `main()` nghe settings để
đổi locale… Chỗ đó phải **`listen` tay** — và subscription phải được
**cancel** khi chủ sở hữu chết, không thì leak. Senior làm điều này khắp
nơi: `MenuScreenViewModel` giữ hai `StreamSubscription` và `cancel()` trong
`dispose()`. Bài này cho bạn đủ vốn để đọc (và sau này viết) đúng kiểu đó.

## Bạn đã biết gì

- `Stream<T>`, `Stream.periodic`, `StreamBuilder` (bài 1–2); `dispose()`
  của `State` (M03).

## Mental model mới

**listen → subscription → cancel.**

```
stream.listen((event) { … })   ─► trả về StreamSubscription<T>
                                     │
   subscription.pause()/resume()     │   (hiếm gặp)
   subscription.cancel()             │   ◄── "dừng nghe": stream ngừng
                                     │       đẩy cho listener này
   trong State: cancel() trong dispose()
```

Subscription là **một đối tượng** — giữ nó trong field để huỷ đúng lúc.
Không giữ nó = không thể cancel = listener sống sót sau khi chủ chết
(leak + crash "gọi sau dispose").

**StreamController = đầu phát tay.** `Stream.periodic` là nguồn có sẵn;
khi *bạn* là người phát (VM bắn "user tapped" ra UI), bạn cần một chỗ
"add event vào": đó là `StreamController`:

```
controller.add(1) ─► controller.stream ─► listener nhận 1
controller.close() ─► stream done
.broadcast()       ─► nhiều listener cùng nghe (thay vì chỉ một)
```

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `StreamSubscription<T>` | `final sub = s.listen((v){…})` | Handle của một lần nghe — cần để cancel |
| `subscription.cancel()` | `await sub.cancel()` | Dừng nghe; thường gọi trong `dispose()` |
| `StreamController<T>` | `StreamController<int>()` | Bộ điều khiển phát: `add`, `close`, `stream` |
| `.broadcast()` | `StreamController<X>.broadcast()` | Cho phép **nhiều** subscription cùng lúc |
| `onCancel` | trong controller | Callback khi listener cuối rời đi (khái niệm) |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `State.dispose` | Chỗ `cancel()` subscription tay — M03 đã có hook này |

## Cầu nối Android / Compose

- SIMILARITY: `listen`/`cancel` ≈ `collect` trong `lifecycleScope` —
  nhưng phải tự huỷ, không có scope tự-dọn.
- IMPORTANT DIFFERENCE: không có `viewModelScope`/`repeatOnLifecycle` —
  `dispose()` của State/VM là nơi *bạn* cancel; quên = leak.
- DO NOT ASSUME: `.broadcast()` = free — broadcast stream không đệm event
  cho listener đến-muộn (event bắn khi không ai nghe thì mất). Senior chọn
  nó cho **one-shot UI events** đúng vì vậy (xem senior evidence).

## Trong project senior — nhìn vào chỗ thật

`flutter-accelerator-ai/lib/view_models/menu/menu_screen_view_model.dart`:

```dart
final StreamController<MenuScreenUiEvent> _events;
late final StreamSubscription<UserProfileData> _userProfileSubscription;
late final StreamSubscription<AuthSessionData> _authStateSubscription;
// ctor: _events = StreamController<MenuScreenUiEvent>.broadcast()
// ctor body: _userProfileSubscription = repo.userProfileStream.listen(…)
// dispose(): _userProfileSubscription.cancel(); _authStateSubscription.cancel();
```

Đọc được: VM **subscribe tay** hai repository stream (profile + auth),
giữ subscriptions trong `late final` field, cancel trong `dispose`, và
**phát tay** UI events qua `StreamController.broadcast` — vì events là
one-shot (navigate/snackbar) và nhiều bridge có thể nghe.

`flutter-accelerator-ai/lib/main.dart`: `StreamBuilder` nghe
`userSettingsStream` (ValueStream) để đổi `MaterialApp.locale` — Stream
trong UI, y hệt thẻ ticker của bạn.

Bạn vừa có đủ vốn: `Stream`, `StreamBuilder`, `listen`, `cancel`,
`StreamController`, `broadcast` — các mảnh ghép của chính VM senior.

## Từng bước thực hiện

### Bước 1 — LEARNING EXAMPLE: `listen`/`cancel` tay

Ví dụ sau **không đi vào app** — mục đích là thấy cơ chế:

```dart
// LEARNING EXAMPLE — KHÔNG DÙNG TRONG APP HIỆN TẠI
// (App dùng StreamBuilder vì chỉ cần hiển thị; ví dụ này cho thấy
//  cách một object/VM subscribe tay.)

import 'dart:async';

Future<void> demo() async {
  final stream = menuSessionTicker();
  final subscription = stream.listen((seconds) {
    debugPrint('tick: $seconds');
  });

  await Future.delayed(const Duration(seconds: 3));
  await subscription.cancel(); // ngừng nghe — không cancel sẽ leak
}
```

- `stream.listen(fn)` trả `StreamSubscription<int>` — **giữ nó**: không
  giữ = không ai huỷ được.
- `await sub.cancel()` — trả `Future`; trong `dispose()` của `State` ta
  thường gọi `sub.cancel()` không await (dispose là sync hook).
- Khi nào cần trong app thật: M11+ khi `ChangeNotifier` VM subscribe repo
  stream — vì VM không phải widget, không có `StreamBuilder`; nó `listen`
  trong ctor và `cancel` trong `dispose` (đúng như senior trên).

### Bước 2 — LEARNING EXAMPLE: `StreamController` + `broadcast`

```dart
// Ví dụ độc lập — chạy được trong DartPad (pure Dart, không phải app):
import 'dart:async';

Future<void> main() async {
  final controller = StreamController<int>();
  final sub = controller.stream.listen((v) => print('nhận $v'));
  controller.add(1);      // listener thấy 'nhận 1'
  controller.add(2);      // 'nhận 2'
  await sub.cancel();
  await controller.close(); // controller cũng cần đóng — tài nguyên giải phóng

  // Muốn nhiều listener: StreamController<int>.broadcast() — event đi tới
  // mọi listener đang nghe (nhưng không đệm cho ai đến muộn).
}
```

- `StreamController<T>()` — mặc định **single-subscription**: `stream`
  chỉ cho một listener; listener thứ hai → `StateError`.
- `.broadcast()` — stream broadcast: nhiều listener được; nhưng event
  phát khi *không ai nghe* sẽ mất (không đệm lại). Senior chọn broadcast
  cho UI events vì đúng ngữ nghĩa one-shot.
- `controller.close()` — chủ controller cũng phải dọn.

### Bước 3 — Tại sao app M06 vẫn dùng `StreamBuilder`

Câu hỏi đúng: "vì sao không `listen` tay + `setState`?" — được, nhưng thừa:

```dart
// Cách tay (KHÔNG dùng trong app — chỉ để so sánh):
StreamSubscription<int>? _sub;
initState() { _sub = _sessionTicker.listen((v) => setState(() => _sec = v)); }
dispose()   { _sub?.cancel(); }
```

`StreamBuilder` chính là cái này *đã đóng gói*: subscribe khi vào cây,
`setState`-equivalent mỗi event, cancel khi gỡ. Chọn `StreamBuilder` khi
event thẳng ra UI; chọn `listen` tay khi cần xử lý event bằng logic
(M13/M14). Nắm cả hai = nắm được mọi nơi stream chạy tới trong senior.

`flutter analyze` → sạch (không đổi gì trong app — ví dụ chỉ để đọc).

## Đọc hiểu code

So sánh hai cách nghe cùng một stream:

```
StreamBuilder (trong _SessionTickerCard):
  subscribe khi vào cây ─► builder mỗi event ─► tự cancel khi gỡ
  dùng khi: event → hiển thị trực tiếp

listen tay (VM/State):
  _sub = stream.listen(...)  trong initState/ctor
  …xử lý event bằng logic (ví dụ dispatch, điều hướng)…
  _sub.cancel() trong dispose()
  dùng khi: event → hành động/logic, không phải render trực tiếp
```

## Chạy và quan sát

- App không đổi — bài này là kiến thức + ví dụ đọc.
- (Nếu tò mò) thử ví dụ `listen` trong `initState` + `debugPrint` tick →
  thấy console in mỗi giây; nhớ `cancel()` trong `dispose` hoặc xoá ví dụ.

## Lỗi thường gặp

1. **`listen` mà vứt `StreamSubscription`** — không cancel được → leak;
   listener có thể gọi `setState` sau dispose → crash.
2. **Quên `cancel()` trong `dispose`** — subscription sống sót, giữ State
   không được GC và event vẫn chảy vào một widget đã chết.
3. **`await cancel()` trong `dispose()`** — `dispose` là sync; gọi
   `sub.cancel()` không await (hoặc `unawaited(sub.cancel())` sau này khi
   lint yêu cầu rõ ràng).
4. **Hai listener trên single-subscription stream** — `StateError: Stream
   has already been listened to`; cần `.broadcast()` nếu thật sự nhiều
   người nghe.
5. **Nghĩ broadcast đệm event** — không: không ai nghe thì event mất;
   senior lựa nó cho one-shot UI events là vì thế.

## Kiểm tra hiểu biết

1. `stream.listen` trả về gì và dùng để làm gì? — `StreamSubscription`;
   giữ nó để `cancel()` khi chủ sở hữu huỷ.
2. Vì sao VM không dùng `StreamBuilder`? — VM không phải widget: không có
   chỗ render; nó subscribe tay để *xử lý* event.
3. Single-subscription vs broadcast khác nhau gì? — Single: một listener;
   broadcast: nhiều listener nhưng không đệm event cho người đến muộn.
4. Vì sao app M06 vẫn dùng `StreamBuilder`? — Event đi thẳng ra UI;
   `listen` tay + `setState` chỉ lặp lại đúng thứ StreamBuilder đã gói.

## Tự làm

**Dự đoán — không chạy trước.** Cho đoạn này (đọc, đừng chạy):

```dart
final c = StreamController<int>.broadcast();
c.add(1);
final s1 = c.stream.listen(print);   // s1 đăng ký SAU add(1)
c.add(2);
s1.cancel();
c.add(3);
```

1. `print` in ra số nào? `1`, `2`, hay `3`? Vì sao?
2. Nếu đổi `broadcast()` thành `StreamController<int>()` (single-
   subscription), dòng `c.stream.listen(print)` + `add(1)` ở đầu còn
   đúng không? Khác gì ở *thời điểm* event được phát?
3. Nếu quên `s1.cancel()`, điều gì tệ xảy ra trong app thật (widget
   `State` đã dispose)?

:::note[Gợi ý]
Broadcast phát event cho subscriber **tại thời điểm** event — không
replay quá khứ. Single-subscription *đệm* event chờ subscriber đầu
tiên. `cancel()` gỡ listener — không hủy controller.
:::

<details><summary><strong>Đáp án</strong></summary>

1. **In `2`**. `add(1)` phát *trước* khi s1 listen → broadcast không
   replay → s1 miss `1`. `add(3)` sau `cancel` → s1 không nhận. Chỉ `2`.
2. Single-subscription **đệm**: `add(1)` giữ trong buffer cho đến khi có
   listener đầu tiên → s1 vẫn nhận `1`. Nhưng sau `cancel` không được
   listen lại — `c.stream.listen` thứ hai sẽ throw.
3. Memory leak + crash: callback trong `State` chạy sau `dispose` → gọi
   `setState` trên State đã chết → `setState() called after dispose()`.
   Đây là lỗi bạn sẽ gặp lại ở M14 với `StreamSubscription` trong
   ViewModel.

</details>

## Cố ý chưa làm

- StreamController trong app — app M06 không cần phát-tay; M13 sẽ có UI
  events stream thật.
- `pause`/`resume`, `onListen`/`onCancel`, `Stream.fromFuture`/`async*` —
  khi nào cần, sẽ gặp đúng lúc.
- `ValueStream`/`BehaviorSubject` (rxdart) — M14; hôm nay `Stream` SDK đủ.
- `StreamTransformer` (`map`/`where`/`debounce`) — M13/M14.

## Điểm kiểm tra hoàn thành — kết M06

- [ ] App M06: profile tải async (FutureBuilder) + "Thời gian phiên" đếm
      giây (StreamBuilder) — hai cơ chế khác nhau cùng hoạt động.
- [ ] Bạn giải thích được `listen`/`cancel`/`dispose` và khi nào dùng tay
      thay `StreamBuilder`.
- [ ] Bạn đọc được `userProfileStream` / `_events.broadcast()` /
      `StreamSubscription` của senior và biết mỗi cái thuộc vai trò nào.
- [ ] `flutter test` → 15 xanh; `flutter analyze` sạch; `flutter build web`
      thành công.
- [ ] Từ đây, M07 sẽ thêm Navigator — menu bấm CHƠI sẽ thật sự sang màn
      game. Khi đó `mounted`-check của M05 càng trở nên quan trọng.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m06/03 — "listen, cancel & StreamController" (bài cuối M06 — checkpoint tích luỹ của cả band async M05–M06; bản thân bài này chỉ dạy bằng learning-example, app không đổi).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter build web`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này KHÔNG thêm code vào app (các ví dụ listen/StreamController chỉ để đọc) — nếu learner thử nghiệm ví dụ trong project thì phải đã dọn sạch. Checkpoint: hai cơ chế async của app (FutureBuilder + StreamBuilder) cùng đứng vững.

EXPECTED STATE SAU BÀI NÀY (trạng thái cuối M06):
- `lib/screens/menu_screen.dart`: `_MenuScreenState` giữ `_profile`/`_soundOn`/`_playTapCount` + `late Future<void> _profileLoadFuture` + `final Stream<int> _sessionTicker` + `_loadProfile` (await→mounted→setState) + `_retryLoadProfile` + `initState`/`dispose` đúng thứ tự super; `build` có `FutureBuilder<void>` ba nhánh bao `Column` menu với `_MenuBody(profile:, ticker:)`.
- `_SessionTickerCard` với `StreamBuilder<int>` + `initialData: 0` đếm giây; `_MenuLoading`/`_MenuErrorState` còn nguyên.
- KHÔNG có `StreamController`, `StreamSubscription`, `.listen(`, `.broadcast()` hoặc `unawaited` nào sót lại trong `lib/` (STRICT — các ví dụ của bài không thuộc app; một `debugPrint` thử nghiệm quên xoá cũng cần liệt kê).
- `lib/data/menu_session_ticker.dart` + `lib/data/profile/demo_profile_loader.dart` + `lib/data/profile/user_profile_data.dart` đầy đủ; `lib/main.dart` là `Future<void> main() async` + `ensureInitialized` + `runApp(AIMillionaireApp)`.
- `flutter analyze` → "No issues found!"; `flutter test` → ~15 xanh; `flutter build web` → thành công.

INVARIANTS NỀN (M01–M06):
- `pubspec.yaml` chỉ `flutter` dep, `name: ai_millionaire_course`; `MenuTokens`; `UserProfileData` + 10 test; khung bọc menu 375; chưa có `Navigator`/route thứ hai, chưa repository/Provider/package mới — đều bài sau, không thiếu.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (đã có navigation/controller trong app) → `AHEAD_COMPATIBLE` nếu học từ ví dụ đúng pattern, `AHEAD_RISKY` nếu phá nền bài tới; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m06/03
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
