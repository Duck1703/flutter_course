---
title: "Bài 3 · Sở hữu VM & unit test"
description: "Ai tạo người đó dispose — vòng đời thủ công của VM trong State, unawaited, và test ViewModel thuần Dart với đếm notifyListeners."
sidebar:
  label: "Bài 3 · Sở hữu VM & test"
  order: 3
---

## Mục tiêu

Chốt hai thứ M11 để lại: **vòng đời thủ công** của `MenuViewModel`
(tạo trong `initState`, huỷ trong `dispose`) và **VM test thuần Dart**
— kiểm chứng state/logic/notify mà không pump một widget nào.

## Bạn đang ở đâu

- Milestone: **M11** (bài 3/3 — chốt milestone)
- App hiện tại: menu render từ `MenuViewModel` qua `ListenableBuilder`;
  `_MenuScreenState` tạo VM trong `initState` và `dispose` nó.

## Vì sao việc này quan trọng ngay bây giờ

Hai điểm dễ bị lướt qua nhưng là phần "sự thật" của milestone:

1. **VM không tự sống.** Không `viewModelScope`, không DI scope — một
   object Dart bình thường. Bạn tạo nó, bạn phải `dispose()` nó. Quên
   → listener của `ListenableBuilder` treo vào object chết (memory
   leak + notify vào hư không).
2. **VM test không cần widget.** `flutter_test` test `testWidgets` cho
   UI; VM chỉ là class Dart — `test()` thường + `addListener` đếm số
   lần notify là đủ. Đây là lần đầu course test *logic màn hình* mà
   không render.

## Bạn đã biết gì

- `initState`/`dispose` quản lý tài nguyên (M06 stream, M09 timer) —
  VM là *tài nguyên thứ ba* cùng pattern: tạo trong initState, huỷ
  trong dispose.
- `SharedPreferences.setMockInitialValues` + `ProfileStore` (M10).
- `addListener` — bạn từng nghe `Stream.listen`; `ChangeNotifier.addListener`
  là họ hàng thô hơn: callback `void Function()`, không payload.

## Mental model mới

**Ownership chain của màn menu (M11):**

```
MenuScreen (StatefulWidget)
  └─ _MenuScreenState          ← OWNER
       ├─ _viewModel            tạo initState → dispose() trong dispose
       ├─ _sessionTicker        tạo field → StreamBuilder tự huỷ sub
       ├─ _soundOn/_playTapCount ephemeral
       └─ build → ListenableBuilder nghe _viewModel
```

VM cũng *có thể* sở hữu tài nguyên (senior VM có `StreamController
_events` và tự `dispose` nó) — learner VM chưa cần nên `dispose` của
ta chỉ gọi `super.dispose()` (mặc định ChangeNotifier). Quy tắc vẫn
giống nhau: **ai giữ tài nguyên, người đó giải phóng nó**.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `addListener` | `vm.addListener(() => notifies++);` | Đăng ký callback — dùng để *đếm* notify trong test |
| `removeListener` | `vm.removeListener(listener)` | ListenableBuilder tự làm — test tay thì cân đối |
| `addTearDown` | `addTearDown(vm.dispose);` | Test hygiene: dispose VM khi test xong dù assert fail |
| test double `extends` | `class _BrokenStore extends ProfileStore` | Store là concrete → double bằng subclass ghi đè một method |

## Flutter cần dùng

Không widget mới — bài này về ownership và test.

## Android / Compose bridge

- SIMILARITY: test VM kiểu `addListener(() => n++)` ≈
  `stateFlow.test { … }`/turbine collect — cùng ý tưởng "quan sát luồng
  phát". `addTearDown(vm.dispose)` ≈ `scope.cancel()` trong test.
- IMPORTANT DIFFERENCE: Android `ViewModel` sống sót config change và
  framework tự gọi `onCleared()`; VM learner (và cả senior) chết theo
  owner của nó — `dispose` trong `State.dispose`, đích xác từng cặp.
- DO NOT ASSUME: VM đến từ DI/container. M11 tạo nó bằng `new` trong
  `initState` — thủ công, hiển nhiên, để M12 chứng minh Provider chỉ
  là *máy làm việc đó cho bạn* chứ không phải nơi VM sinh ra về ý nghĩa.

## Senior project connection

- `flutter-accelerator-ai/lib/view_models/menu/menu_screen_view_model.dart` —
  override `dispose()`: `_eventSubscription?.cancel(); _events.close();
  super.dispose();` — VM sở hữu StreamController và tự dọn trong
  dispose của nó, y hệt quy tắc "owner giải phóng".
- `flutter-accelerator-ai/lib/screens/menu_screen.dart` — senior tạo
  VM trong `ChangeNotifierProvider(create:)` — tức *provider* là owner
  và tự dispose VM khi provider unmount. Bạn sẽ thấy M12 thay đúng hai
  dòng initState/dispose bằng một provider.

## Build it step by step

### Bước 1 — Vòng đời VM trong State (đã làm ở bài 1, nhìn lại có chủ đích)

```dart
late final MenuViewModel _viewModel;

@override
void initState() {
  super.initState();
  _viewModel = MenuViewModel(store: widget.profileStore);
  unawaited(_viewModel.load());
}

@override
void dispose() {
  _viewModel.dispose();
  super.dispose();
}
```

Ba chi tiết đáng giá một lần đọc chậm:

- `late final` + `initState` — vì ctor VM cần `widget.profileStore`
  (chỉ tồn tại sau khi State gắn cây).
- `unawaited(_viewModel.load())` — kick-off async trong lifecycle sync.
- `dispose()` **trước** `super.dispose()` — dọn của mình rồi mới nhường
  cha (giống cancel timer/subscription của M06/M09).

### Bước 2 — Test VM

```dart
// test/menu_view_model_test.dart — FILE MỚI
import 'package:ai_millionaire_course/view_models/menu/menu_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
// …

Future<ProfileStore> makeStore(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  return ProfileStore(await SharedPreferences.getInstance());
}

class _BrokenStore extends ProfileStore {
  _BrokenStore(super.prefs);
  @override
  Future<UserProfileData> load() => throw StateError('broken');
}

void main() {
  group('MenuViewModel (M11)', () {
    test('load prefs trống → ready + profile mặc định, notify 1 lần',
        () async {
      final vm = MenuViewModel(store: await makeStore(const {}));
      addTearDown(vm.dispose);
      var notifies = 0;
      vm.addListener(() => notifies++);

      await vm.load();

      expect(vm.loadState, MenuLoadState.ready);
      expect(notifies, 1); // loading→loading bị _setLoadState chặn
    });

    test('applyGameResult → profile đổi, notify, persist xuống disk',
        () async {
      final store = await makeStore(const {});
      final vm = MenuViewModel(store: store);
      addTearDown(vm.dispose);
      await vm.load();
      var notifies = 0;
      vm.addListener(() => notifies++);

      await vm.applyGameResult(
        const GameResult(questionsAnswered: 4, correctAnswers: 4, won: true),
      );

      expect(vm.profile.gamesWon, 1);
      expect(notifies, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_profile'), contains('"gamesWon":1'));
    });
    // … failed path, reset, reset-noop — xem file test đầy đủ
  });
}
```

### Bước 3 — Đếm notify là assert kiến trúc

`expect(notifies, 1)` không phải đếm cho vui: nó kiểm chứng
*compare-before-notify* của `_setLoadState` — lần load đầu (loading →
loading → ready) phải báo đúng **1** lần chứ không 2. Và test
`resetProfile` trên profile mặc định expects `notifies == 0` — đó là
hợp đồng "không đổi thì không báo".

## Hiểu code

- **`_BrokenStore extends ProfileStore`** — store là class concrete,
  không interface (interface là M14), nên test double viết bằng
  `extends` + override đúng một method. Nhẹ, đủ dùng — Mockito/generator
  là đồ nặng cho một method.
- **`addTearDown(vm.dispose)`** — tương đương `unmount(tester)` của
  widget test: dọn VM kể cả khi assert giữa chừng fail, test sau không
  thừa listener rò.
- **Kỳ vọng `notifies` chính xác** — vì `_setLoadState` guard, chuỗi
  `loading → loading → ready` phát đúng 1 notify; không guard thì test
  này báo 2 và bạn phát hiện mình đang rebuild thừa.

## Chạy và quan sát

- `flutter test test/menu_view_model_test.dart` — 7 test xanh, chạy
  trong vài chục ms (không pump widget).
- `flutter analyze` + `flutter test` + `flutter build web` — toàn bộ
  suite 50 test vẫn xanh: refactor thuần.

## Lỗi hay gặp

1. **`dispose()` sau `super.dispose()`** — convention Flutter: dọn
   tài nguyên của mình *trước* rồi super. Đảo thứ tự vẫn chạy trong
   case này nhưng sai pattern.
2. **Giữ cả `FutureBuilder` và `ListenableBuilder`** — hai nguồn truth
   cho cùng một state → hành vi nửa vời. Khi state chuyển sang VM,
   FutureBuilder cũ phải đi.
3. **Test tạo VM rồi không dispose** — khác với widget test (tester tự
   thu), VM là object thường: GC thu được, nhưng listener treo ngược
   vào nó trong lúc test → `addTearDown` cho sạch.
4. **Assert `notifies == 1` mà không hiểu vì sao** — con số đó phản
   ánh *chính sách notify* của VM, không phải hằng số vũ trụ. Đổi
   `_setLoadState` bỏ guard → test này đổi — đó là điểm của nó.

## Kiểm tra hiểu biết

1. VM có tự `dispose` khi màn hình pop không? — *Không: nó là object
   Dart thường. Ai tạo người đó dispose — `State.dispose` của menu.*
2. `unawaited` và bỏ qua Future khác nhau thế nào? — *Về runtime: giống
   nhau (Future vẫn chạy). Về ý đồ: `unawaited` nói với người đọc/
   analyzer "tôi biết đây là Future và cố ý không chờ" — lint
   `unawaited_futures` và reviewer đọc được.*
3. Vì sao không đưa `_soundOn`/`_playTapCount` vào VM luôn cho gọn? —
   *Chúng là ephemeral UI của đúng một widget; vào VM thì VM bị nhiễm
   "biến hiển thị" và bạn phải notify cho mỗi toggle — setState đúng
   chỗ vẫn là công cụ tốt.*

## Tự làm

**Tự viết test — không copy.** `MenuViewModel` là `ChangeNotifier`. Viết
một test trong `test/` kiểm chứng `notifyListeners`:

1. Tạo `MenuViewModel` (nhớ ctor cần `store:` — dùng `makeStore` của
   M10), đăng ký `vm.addListener(() => calls++)` với `int calls = 0`.
2. Gọi action đổi state — ví dụ `await vm.load()` hoặc
   `vm.applyGameResult(...)` — assert `calls` tăng lên.
3. Dự đoán: nếu method đổi field nhưng **quên `notifyListeners()`**,
   `calls` là bao nhiêu? UI rebuild không? Và `resetProfile` trên
   profile mặc định notify mấy lần — vì sao?
4. Hai listener đăng ký — `calls` tăng mấy lần cho một notify?

:::note[Gợi ý]
`notifyListeners` bắn đồng bộ cho mọi listener đã `addListener`. Quên
gọi nó = field đổi nhưng không ai biết → UI đứng im.
:::

<details><summary><strong>Đáp án</strong></summary>

```dart
test('VM notifies listeners on state change', () async {
  final vm = MenuViewModel(store: await makeStore(const {}));
  addTearDown(vm.dispose);
  var calls = 0;
  vm.addListener(() => calls++);
  await vm.load();           // loading → ready: đổi state → notify
  expect(calls, greaterThan(0));
});

test('two listeners both fire on one notify', () async {
  final vm = MenuViewModel(store: await makeStore(const {}));
  addTearDown(vm.dispose);
  var a = 0, b = 0;
  vm.addListener(() => a++);
  vm.addListener(() => b++);
  await vm.load();
  expect(a, 1);   // loading→loading bị _setLoadState chặn → chỉ 1 notify
  expect(b, 1);
});
```

Quên `notifyListeners`: `calls == 0` — listener không chạy, UI không
rebuild dù field đã đổi. Đây là bug "silent state" mà bạn sẽ thấy lại
khi `BehaviorSubject` (M14) tự phát ngay khi `.add()` — không cần gọi
notify thủ công.
</details>

## Ta cố ý chưa thêm

- Provider tự dispose VM — M12.
- `MenuScreenUiEvent` stream (snackbar/navigate qua VM) — M13.
- Tách `MenuScreenView` public — widget phụ vẫn private trong file
  screen; giữ gọn cho đến khi có màn thứ hai cần dùng.

## Checkpoint hoàn thành

- [ ] `_MenuScreenState` tạo `_viewModel` trong `initState` +
  `unawaited(load())`, `dispose()` trong `dispose`.
- [ ] `test/menu_view_model_test.dart` xanh: load (trống/lưu sẵn/lỗi),
  apply (đổi + notify + persist), reset (đổi/noop).
- [ ] Trả lời được: ai sở hữu VM, ai dispose nó, và `notifyListeners`
  có diff không.
- [ ] `flutter test` toàn suite xanh.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m11/03 — "Sở hữu VM & unit test" (bài cuối M11 — vòng đời thủ công của VM + test VM thuần Dart).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter test test/menu_view_model_test.dart`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Trọng tâm: ai tạo người đó dispose (VM là object thường, không viewModelScope) + test logic VM KHÔNG pump widget.

EXPECTED STATE SAU BÀI NÀY:
- `_MenuScreenState` (STRICT): `late final MenuViewModel _viewModel` → `initState` gán `MenuViewModel(store: widget.profileStore)` + `unawaited(_viewModel.load())` → `dispose` gọi `_viewModel.dispose()` TRƯỚC `super.dispose()` (STRICT thứ tự dispose-trước-super).
- `test/menu_view_model_test.dart` tồn tại (STRICT path): ~7 `test(...)` trong `group('MenuViewModel (M11)')` — pure Dart test, KHÔNG `testWidgets`/pump (STRICT: VM test = test() thường).
- Test dùng helper `makeStore` (`SharedPreferences.setMockInitialValues` + `await SharedPreferences.getInstance()` → `ProfileStore`) — tái dùng kỹ thuật M10.
- Có test-double `class _BrokenStore extends ProfileStore { _BrokenStore(super.prefs); @override Future<UserProfileData> load() => throw StateError('broken'); }` (STRICT extends vì store là concrete — chưa có interface).
- Các ca test chứng minh: load prefs trống → `loadState == MenuLoadState.ready` + `notifies == 1` (đếm bằng `vm.addListener(() => notifies++)` — STRICT assert số notify phản ánh guard `_setLoadState`: loading→loading bị chặn); `applyGameResult` → `vm.profile.gamesWon == 1` + notify + `prefs.getString('user_profile')` chứa `'"gamesWon":1'` (STRICT persist xuống disk); failed path → `loadState == MenuLoadState.failed`; reset đổi / reset-noop `notifies == 0` (compare-before-notify).
- Mọi test tạo VM có `addTearDown(vm.dispose)` (STRICT — dọn VM dù assert fail).
- `flutter test` → "All tests passed!" ~50; `flutter analyze` → "No issues found!".

INVARIANTS NỀN:
- `MenuViewModel` + `ListenableBuilder` menu (bài 1–2); `ProfileStore` + mock-values; persistence M10; game M09 nguyên vẹn; chưa có Provider (bài tới mới thay initState/dispose bằng provider).

Mục (STRICT) phải đúng; mục khác chấm semantic (tên test/group). Code vượt checkpoint (đã có Provider/Mockito) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m11/03
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
