---
title: "Bài 1 · Event ≠ state"
description: "Vì sao điều hướng/SnackBar không thể là state; event classes đơn giản và StreamController.broadcast trên MenuViewModel."
sidebar:
  label: "Bài 1 · Event ≠ state"
  order: 1
---

## Mục tiêu

Hiểu sự khác biệt căn bản giữa **state** (giá trị đúng cho tới khi đổi)
và **event** (việc vừa xảy ra đúng một lần), và dựng nửa đầu của kênh
event trên `MenuViewModel`: event classes + broadcast controller.

## Bạn đang ở đâu

- Milestone: **M13** (bài 1/3)
- App hiện tại (cuối M12): `MenuViewModel` giữ `loadState`/`profile`,
  Provider scope đã sẵn sàng. `_onPlayTap` trong `_MenuScreenViewState`
  đang tự `Navigator.push` rồi `applyGameResult` — widget quyết định
  hết, VM chỉ giữ dữ liệu.

## Vì sao việc này quan trọng ngay bây giờ

Có những việc "xảy ra một lần rồi thôi": mở màn khác, hiện SnackBar,
đóng dialog. Nhét chúng vào `ChangeNotifier` state gặp hai lỗi kinh
điển:

1. **Trigger lặp lại**: nếu `shouldNavigate` là một bool trong state,
   rebuild sau đó (xoay màn, dependency đổi) đọc lại `true` → điều
   hướng **hai lần**. State không biết "đã xử lý chưa".
2. **State bẩn**: VM bắt đầu mang `showSnackBar`, `navigateTo`… —
   trường tồn tại chỉ để được reset ngay, không ai biết giá trị
   "đúng" của chúng là gì.

Nguyên tắc: **state mô tả màn hình đang như thế nào; event mô tả việc
vừa xảy ra.** Điều hướng và SnackBar là event.

## Bạn đã biết gì

- `Stream`, `StreamBuilder`, `listen`/`cancel`, `StreamController` (M06) —
  (`async*`/`yield` M06 liệt kê trong "cố ý chưa làm" — chưa cần ở đây);
  event channel là
  một stream, chỉ khác nguồn phát và cách subscribe.
- `ChangeNotifier` + `notifyListeners` (M11), `context.read`/`watch`
  (M12) — kênh state đã có; giờ thêm kênh event song song.

## Mental model mới

```
STATE (ChangeNotifier)          EVENT (StreamController)
"profile là X"                  "vừa bấm CHƠI"
đọc lại bao nhiêu lần cũng đúng   nhận đúng một lần, rồi qua
rebuild để HIỂN THỊ              lắng nghe để HÀNH ĐỘNG
```

Một stream `broadcast` phù hợp với event vì nó không giữ lại event
cho người đến trễ: bấm CHƠI khi chưa ai nghe thì event trôi qua —
đúng bản chất "sự kiện", khác với state "ai đến sau cũng đọc được
giá trị hiện tại".

## Ví dụ độc lập — broadcast stream không replay

Bản chất "event = nhận một lần rồi qua" nhìn rõ nhất trong Dart thuần
(DartPad — chỉ cần `dart:async`, không Flutter):

```dart
import 'dart:async';

void main() async {
  final events = StreamController<String>.broadcast();

  // Listener A đến TRƯỚC khi có event.
  events.stream.listen((e) => print('A nhận: $e'));

  events.add('vừa bấm CHƠI'); // A đang nghe → nhận được

  // Listener B đến SAU event — broadcast không replay.
  events.stream.listen((e) => print('B nhận: $e'));

  events.add('vừa bấm THOÁT'); // cả A và B nhận

  await Future<void>.delayed(Duration.zero);
  await events.close();
}
```

Output:

```text
A nhận: vừa bấm CHƠI
A nhận: vừa bấm THOÁT
B nhận: vừa bấm THOÁT
```

B **không bao giờ thấy** `'vừa bấm CHƠI'` — đó là lựa chọn cố ý của
event: đến trễ thì event đã qua, không được xem lại. Nếu đây là
*state* (ví dụ "profile hiện tại"), hành vi đó là bug; với *event*,
nó là đúng bản chất. Một kênh phát, nhiều listener, mỗi event đi qua
đúng một lần cho ai đang nghe — VM của bạn expose `events` chính là
cái stream này.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
| --------- | ------- | ------- |
| `abstract class` | `abstract class MenuUiEvent` | Class cha không tạo instance — chỉ để các event `extends` |
| `final class` | `final class MenuGameRequested extends MenuUiEvent` | Class không cho extend/implement nữa — event "đóng kín" |
| `StreamController<T>.broadcast()` | `_events = StreamController<MenuUiEvent>.broadcast()` | Controller nhiều-listener, không replay |
| `_controller.add(e)` | `_events.add(const MenuGameRequested())` | Bắn một event vào kênh |
| `_controller.close()` | trong `dispose()` | Đóng kênh khi VM chết |
| `Stream<T> get events` | `=> _events.stream` | Expose stream đọc-only; che controller |

`abstract` vs `sealed`: `abstract` chỉ chặn tạo instance. `sealed` còn
cho compiler kiểm tra switch `is` đã cover hết con chưa — mạnh hơn
nhưng là bài **M15**, M13 dùng `abstract` + `is` cho đơn giản.

## Flutter cần dùng

Chưa có — bài này chỉ chạm ViewModel (Dart thuần). Phần "bắt" event
bằng widget là bài 2.

## Android / Compose bridge

- SIMILARITY: `StreamController.broadcast` ≈ `SharedFlow`/`Channel`
  của ViewModel dùng cho one-shot effect (navigation, toast) —
  cùng bài toán "không phải state".
- IMPORTANT DIFFERENCE: `SharedFlow` có `replay`/`buffer` tuỳ chọn;
  `StreamController.broadcast` mặc định **không buffer** — listener
  đến trễ mất luôn event. Đây là lựa chọn cố ý, không phải thiếu sót.
- DO NOT ASSUME: event listener của Compose (`LaunchedEffect` +
  `collect`) *tự* huỷ theo composition — Flutter không tự huỷ; phần
  huỷ tay là bài 2.

## Senior project connection

- `flutter-accelerator-ai/lib/view_models/menu/menu_screen_ui_event.dart` —
  `sealed class MenuScreenUiEvent` với `MenuGameRequested` và
  `MenuSnackBarRequested(message)`. **Cùng tên, cùng shape** với file
  ta sắp viết; chỉ khác senior dùng `sealed` (M15 mới học).
- `flutter-accelerator-ai/lib/view_models/menu/menu_screen_view_model.dart` —
  field `_events` khởi tạo `StreamController<MenuScreenUiEvent>
  .broadcast()`, getter `events`, `requestGame()` chứa
  `_events.add(const MenuGameRequested())`, `dispose()` gọi
  `_events.close()`. Learner copy đúng pattern này.
- Đây là **evidence đọc source**, không phải code để dán — đọc để
  thấy pattern, viết lại theo trình độ M13.

## Build it step by step

### Bước 1 — file event mới

Tạo `lib/view_models/menu/menu_ui_event.dart`:

```dart
/// Sự kiện một-lần của màn menu — M13.
///
/// Khác với *state* (`loadState`, `profile`): state "đúng cho tới khi đổi",
/// còn event là "việc vừa xảy ra" — điều hướng sang game, hiện SnackBar.
/// Listener nhận event đúng một lần; không ai "đọc lại" một event cũ.
///
/// `abstract class` (không `sealed`): M13 chỉ cần phân biệt kiểu bằng
/// `is`; sealed + switch kiệt hợp là bài M15.
/// Senior: `lib/view_models/menu/menu_screen_ui_event.dart` — cùng shape
/// (`MenuGameRequested`, `MenuSnackBarRequested(message)`) nhưng sealed.
abstract class MenuUiEvent {
  const MenuUiEvent();
}

/// VM xin mở màn chơi. Widget bridge nghe event này → Navigator.push.
/// Không mang dữ liệu — ý định thuần tuý.
final class MenuGameRequested extends MenuUiEvent {
  const MenuGameRequested();
}

/// VM xin hiện một SnackBar. Mang [message] vì chữ hiển thị do VM
/// quyết (VM biết vì sao nó báo) — widget chỉ render, không soạn chữ.
final class MenuSnackBarRequested extends MenuUiEvent {
  const MenuSnackBarRequested(this.message);

  /// Nội dung SnackBar.
  final String message;
}
```

Mỗi event là một class: rõ tên, rõ payload. Không enum, không chuỗi
ma thuật — vì event có thể mang dữ liệu (như `message`) và M15 sẽ
seal chúng để được switch kiệt hợp.

### Bước 2 — controller trên ViewModel

Trong `lib/view_models/menu/menu_view_model.dart`:

```dart
import 'dart:async';   // StreamController, StreamSubscription
// ...
import 'menu_ui_event.dart';

class MenuViewModel extends ChangeNotifier {
  // ...

  /// Kênh event một-lần — M13. `broadcast` vì UI có thể subscribe khi VM
  /// đã sống sẵn: broadcast stream không buffer cho listener đến trễ
  /// (event bắn trước khi có listener thì mất — đúng bản chất "sự kiện",
  /// không phải state), và cho phép nhiều listener về lâu dài.
  final StreamController<MenuUiEvent> _events =
      StreamController<MenuUiEvent>.broadcast();

  /// Stream event public — UI subscribe qua đây. VM chỉ "add", UI chỉ
  /// "listen": kênh một chiều, không ai ghi ngược vào VM.
  Stream<MenuUiEvent> get events => _events.stream;

  /// Ý định "người chơi bấm BẮT ĐẦU CHƠI". VM không Navigator —
  /// điều hướng cần context, thuộc widget. VM chỉ bắn event; bridge
  /// trong `_MenuScreenView` nghe và đẩy route.
  void requestGame() {
    _events.add(const MenuGameRequested());
  }

  Future<void> resetProfile() async {
    await _store.reset(); // ghi profile mặc định đè lên key
    const defaults = UserProfileData();
    if (_profile != defaults) {
      _profile = defaults;
      notifyListeners();
    }
    // M13: báo thành công bằng event — VM quyết CHUYỆN GÌ xảy ra,
    // widget quyết HIỂN THỊ thế nào.
    _events.add(const MenuSnackBarRequested('Đã đặt lại hồ sơ.'));
  }

  @override
  void dispose() {
    _events.close();   // đóng kênh trước khi VM chết
    super.dispose();
  }
}
```

Chỉ ba thứ mới trên VM: controller, getter, và `add()` ở hai chỗ có
ý định một-lần. `notifyListeners()` vẫn giữ nguyên vai trò state —
hai kênh chạy song song, không trộn.

## Hiểu code

- **Vì sao `broadcast`?** Stream thường (`StreamController()` mặc
  định) chỉ cho **một** listener nguyên đời. Màn menu có thể gắn/tách
  listener nhiều lần (re-subscribe khi dependency đổi — bài 2) → cần
  loại cho nhiều listener lần lượt. `broadcast` cũng là lựa chọn của
  senior cho cùng lý do.
- **Vì sao getter `events` thay vì public field?** `Stream` chỉ có
  `listen` — ai cầm `controller` mới `add` được. Che controller =
  kênh một chiều: VM phát, UI nghe, không ai bắn ngược vào VM.
- **`requestGame()` là sync** — `add()` vào broadcast chỉ xếp event
  vào hàng đợi, không chờ ai xử lý. VM xong việc ngay.
- **`_events.close()` ở `dispose()`** — ChangeNotifierProvider tự gọi
  `dispose` khi VM rời cây (M12), nên controller được đóng đúng chỗ
  mà không cần widget nhớ.

## Chạy và quan sát

Chưa thấy gì trên UI — chưa có ai `listen`. Kiểm chứng nhanh bằng
Dart pad/test:

```dart
// test thủ trong file test bất kỳ:
final vm = MenuViewModel(store: store);
final seen = <MenuUiEvent>[];
vm.events.listen(seen.add);
vm.requestGame();
await Future.delayed(Duration.zero);
expect(seen.single, isA<MenuGameRequested>());
```

(Test thật của bài 3 làm đúng việc này — đây chỉ là preview để thấy
kênh chạy.)

## Lỗi hay gặp

1. **`StreamController()` mặc định (single-subscription)** — subscribe
   lần hai ném `StateError: Stream has already been listened to`.
   Event channel cho UI phải là `broadcast`.
2. **Quên `close()`** — controller rò rỉ tài nguyên; thói quen: mở
   ở field → đóng ở `dispose`.
3. **`await` trong `requestGame()`** — không cần; `add()` là lệnh
   xếp hàng sync. Biến intent-thành-event phải rẻ và tức thì.
4. **Event làm state** — đừng lưu `lastEvent` rồi cho UI đọc: đó là
   đưa event về state, đúng cái ta đang bỏ.

## Kiểm tra hiểu biết

1. Vì sao `showSnackBar: true` trong state là anti-pattern? — *Rebuild
   sau đó đọc lại `true` → hiện lại SnackBar; state không có khái
   niệm "đã xử lý". Event chỉ đến đúng một lần.*
2. Broadcast vs single-subscription khác nhau thế nào? — *Broadcast
   cho nhiều listener lần lượt và không replay cho người đến trễ;
   single-subscription chỉ một listener duy nhất và buffer chờ nó.*
3. Vì sao `events` là getter trả `Stream` chứ không public
   `StreamController`? — *Che quyền `add`: chỉ VM phát event; UI chỉ
   nghe — kênh một chiều.*

## Tự làm (RECOGNIZE)

Menu sắp có 6 "thứ thay đổi" sau. Phân loại từng cái: **state**
(ChangeNotifier — rebuild để hiển thị) hay **event** (stream — nghe
để hành động một lần)? Với mỗi cái, trả lời thêm: *nếu listener đến
trễ, có được xem/nhận lại không — và có nên không?*

| # | Thứ thay đổi | State hay event? |
| --- | --- | --- |
| 1 | "Đang tải profile" | ? |
| 2 | "Vừa bấm nút CHƠI" | ? |
| 3 | Tên hiển thị của user | ? |
| 4 | "Vừa lưu profile thành công" (hiện snackbar) | ? |
| 5 | Số ván đã chơi trong session | ? |
| 6 | "Vừa xin điều hướng về menu" | ? |

:::note[Gợi ý]
Câu hỏi phân ranh giới: nếu widget **rebuild lại từ đầu** sau khi
"thứ đó" đã xảy ra — nó có cần *hiển thị/nhận lại* giá trị đó không?
Cần → state. Chỉ cần *hành động đúng lúc nó xảy ra* → event.
:::

<details><summary>Đáp án</summary>

| # | Chọn | Vì sao |
| --- | ------ | -------- |
| 1 | **state** | UI phải vẽ đúng trạng thái mọi lúc; đến trễ vẫn phải thấy "đang load" |
| 2 | **event** | hành động một lần (điều hướng); ai đến trễ không "được bấm lại" — mà không nên |
| 3 | **state** | giá trị hiện tại; mọi widget đọc lại được bất cứ lúc nào |
| 4 | **event** | snackbar hiện đúng một lần rồi tự biến mất; nếu rebuild lại mà hiện lại snackbar là bug kinh điển |
| 5 | **state** | số đếm hiện tại; rebuild phải vẽ đúng nó — mất giá trị khi đến trễ là không chấp nhận được |
| 6 | **event** | intent một lần — giống `MenuGameRequested`/`MenuBackRequested` |

Cái bẫy thường gặp là **#4**: nhiều người đưa "đã lưu" vào state để
"an toàn" — rồi snackbar hiện lại sau mỗi rebuild/config-change cho
đến khi ai đó nhớ reset cờ. Event kênh giải quyết đúng bản chất:
*việc vừa xảy ra* ≠ *giá trị hiện tại*. Giữ hai kênh song song —
state trong `ChangeNotifier`, event trong broadcast stream — là toàn
bộ kiến trúc M11–M13.

</details>

## Ta cố ý chưa thêm

- **`sealed class` event + switch kiệt hợp** — M15; giờ `abstract` +
  `is` đủ dùng và dễ hiểu hơn.
- **Event từ `GameScreen` ViewModel** — `GameScreen` chưa có VM (D20);
  event "quay lại menu" là M19.
- **Error events cho `load()` thất bại** — error state hiện là
  `MenuLoadState.failed` (đúng là state — màn hình *đang* lỗi), chưa
  cần event.
- **`rxdart`/`BehaviorSubject`** — M14.

## Checkpoint hoàn thành

- [ ] `menu_ui_event.dart` tồn tại với đúng 3 class.
- [ ] `MenuViewModel.events` trả broadcast stream; `requestGame()` +
  `resetProfile()` gọi `_events.add(...)`.
- [ ] `dispose()` đóng `_events` trước `super.dispose()`.
- [ ] Giải thích được: vì sao event không phải state; vì sao
  broadcast.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m13/01 — "Event ≠ state" (kênh event trên MenuViewModel: event classes + broadcast controller).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. LƯU Ý: chưa có ai `listen` kênh event ở bài này (bridge là bài sau) — app không đổi hành vi; `events` chưa dùng là đúng.

EXPECTED STATE SAU BÀI NÀY:
- `lib/view_models/menu/menu_ui_event.dart` tồn tại (STRICT path): `abstract class MenuUiEvent { const MenuUiEvent(); }` + `final class MenuGameRequested extends MenuUiEvent` + `final class MenuSnackBarRequested extends MenuUiEvent { const MenuSnackBarRequested(this.message); final String message; }` (STRICT đúng 3 class: abstract cha + 2 final con; KHÔNG `sealed` — bài dùng abstract cố ý).
- `MenuViewModel` có thêm `import 'dart:async';` + `import 'menu_ui_event.dart';` và `final StreamController<MenuUiEvent> _events = StreamController<MenuUiEvent>.broadcast();` (STRICT broadcast — single-subscription default = bug); `Stream<MenuUiEvent> get events => _events.stream;` (STRICT getter trả Stream, che quyền add).
- `void requestGame() { _events.add(const MenuGameRequested()); }` — sync, không await (STRICT).
- `resetProfile()` giờ có `_events.add(const MenuSnackBarRequested('Đã đặt lại hồ sơ.'));` ở cuối (STRICT: phát event báo thành công — message đúng).
- `@override void dispose()` trên VM gọi `_events.close();` trước `super.dispose()` (STRICT owner-close; provider M12 tự gọi dispose).
- `notifyListeners()`/load/applyGameResult nguyên vẹn — hai kênh state/event song song, không trộn (STRICT: KHÔNG có `lastEvent`/event-làm-state).
- `flutter analyze` → "No issues found!" (hoặc chỉ warning `unused` cho `events`/`requestGame` — chấp nhận, bài 2 nối).
- KHÔNG có `rxdart`/`BehaviorSubject` (chưa tới lúc — có = AHEAD).

INVARIANTS NỀN:
- `MenuViewModel` (MenuLoadState, profile, _setLoadState, applyGameResult, resetProfile) M11–M12 nguyên vẹn; `ChangeNotifierProvider` + `AppDependencyScope` M12; persistence M10; game M09; route M07.

Mục (STRICT) phải đúng; mục khác chấm semantic (comment/doc). Code vượt checkpoint (đã có bridge/sealed event/rxdart) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m13/01
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
