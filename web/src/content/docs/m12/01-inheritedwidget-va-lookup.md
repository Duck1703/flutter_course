---
title: "Bài 1 · InheritedWidget & lookup"
description: "Vì sao truyền dependency qua constructor không scale, InheritedWidget/tree lookup ở mức mental model, và Provider<T>.value vs create."
sidebar:
  label: "Bài 1 · Tree lookup"
  order: 1
---

## Mục tiêu

Hiểu vấn đề mà Provider giải (truyền dependency tay qua constructor
không scale), nắm mental model *tree lookup* của `InheritedWidget`,
và cài `AppDependencyScope` với `Provider<ProfileStore>.value`.

## Bạn đang ở đâu

- Milestone: **M12** (bài 1/3)
- App hiện tại: `main()` tạo `ProfileStore` rồi truyền tay:
  `AIMillionaireApp(profileStore:)` → `home: MenuScreen(profileStore:)`.
  Menu tự tạo `MenuViewModel` trong `initState` và dispose nó.

## Vì sao việc này quan trọng ngay bây giờ

Hai tải trọng vừa xuất hiện sau M10/M11:

1. **Constructor threading.** `ProfileStore` đi `main → App → MenuScreen`
   qua hai lớp widget trung gian — `AIMillionaireApp` chẳng dùng store,
   nó chỉ *chuyển tiếp*. Mỗi dependency mới (settings, auth…) lại phải
   khoan thêm một đường ctor xuyên cây. Senior có **8** dependency —
   tưởng tượng 8 tham số xuyên qua mọi widget.
2. **Vòng đời VM bằng tay.** `initState` tạo + `dispose` huỷ là đúng —
   nhưng mỗi màn cần VM đều viết lại boilerplate đó, và người đọc phải
   tự kiểm "ai sở hữu cái này".

Provider giải cả hai bằng một ý tưởng duy nhất: **đặt dependency vào
widget tree; ai cần thì tra lên**.

## Bạn đã biết gì

- `BuildContext` là "vị trí của widget trong cây" (M03) — hôm nay nó
  có thêm vai trò: *con đường tra cứu*.
- `Navigator.of(context)`/`Theme.of(context)` (M07/M02) — bạn đã dùng
  tree lookup từ lâu mà không để ý: đó chính là InheritedWidget.
- `MenuViewModel` + ownership thủ công (M11) — M12 giữ nguyên VM, chỉ
  đổi *ai tạo và ai dispose*.

## Mental model mới

**Widget tree = bản đồ phạm vi.** `InheritedWidget` là widget đặc biệt:
mọi `Element` con cháu đều tra được nó qua `context`. Khi bạn viết
`Theme.of(context)` hay `Navigator.of(context)`, Flutter đi *lên* cây
từ context của bạn, tìm InheritedWidget gần nhất loại đó.

```
Provider<ProfileStore>.value(value: store)   ← đặt vào cây (AppDependencyScope)
  └─ MaterialApp
       └─ MenuScreen
            └─ ChangeNotifierProvider<MenuViewModel>
                 create: context.read<ProfileStore>()  ← tra LÊN tìm store
                 │                                    (context dưới scope)
                 └─ _MenuScreenView
                      build: context.watch<MenuViewModel>() ← tra LÊN tìm VM
```

Ba quy tắc tra cứu:

1. **Chỉ tra được THỨ NẰM TRÊN mình.** `MenuScreen` đặt provider VM —
   `MenuScreen.build` chạy *trên* provider nên không `watch` được VM
   ở đó; phải có widget con (`_MenuScreenView`) để tra. Đó là lý do
   pattern "screen bọc provider quanh view" của senior.
2. **`read` = lấy một lần; `watch` = subscribe rebuild** (bài 2).
3. **`Provider.value` ≠ `Provider(create:)`** — `.value` cho object đã
   tồn tại (không dispose); `create:` provider tự tạo *và* tự dispose.

## Ví dụ độc lập — `InheritedWidget` viết tay

Provider là `InheritedWidget` được gói sẵn. Nhìn cái trần trước — ví
dụ này **không cần package nào**, chạy thẳng trên DartPad (Flutter):

```dart
import 'package:flutter/material.dart';

void main() => runApp(const UserScope(name: 'Minh', child: App()));

/// InheritedWidget viết tay: mang dữ liệu, cho con cháu tra.
class UserScope extends InheritedWidget {
  const UserScope({super.key, required this.name, required super.child});

  final String name;

  /// Cổng tra cứu quen thuộc — giống hệt `Theme.of(context)`.
  static UserScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<UserScope>();
    assert(scope != null, 'Không có UserScope nào phía trên context');
    return scope!;
  }

  /// true → khi instance này bị thay (dữ liệu đổi), các dependent
  /// rebuild. Provider dùng chính cơ chế này cho `watch`.
  @override
  bool updateShouldNotify(UserScope old) => name != old.name;
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Greeting())),
    );
  }
}

class Greeting extends StatelessWidget {
  const Greeting({super.key});
  @override
  Widget build(BuildContext context) {
    // Tra LÊN cây: không truyền `name` qua constructor tầng nào.
    return Text('Xin chào ${UserScope.of(context).name}');
  }
}
```

Ba điều đáng nhìn chậm:

- `Greeting` không nhận `name` qua constructor — nó **tra lên cây**
  từ context của chính nó. `UserScope.of(context)` đi bộ ngược lên,
  gặp `UserScope` gần nhất.
- `dependOnInheritedWidgetOfExactType` vừa tra **vừa đăng ký**:
  `UserScope` bị thay bằng instance có `name` khác → `updateShouldNotify`
  trả `true` → `Greeting` tự rebuild. **Đó chính là `watch`** — Provider
  chỉ gói nó lại.
- Nếu `Greeting` nằm **trên** `UserScope` trong cây → `of` trả
  `null` → crash. Lookup chỉ đi lên — quy tắc 1 của bài.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `Provider<T>.value` | `Provider<ProfileStore>.value(value: store, child: …)` | Đưa object có sẵn vào cây — provider KHÔNG sở hữu/dispose nó |
| `Provider(create:)` | `Provider(create: (c) => Foo())` | Provider tạo khi cần và dispose khi rời cây |
| `context.read<T>()` | `context.read<ProfileStore>()` | Tra lên cây, lấy object — KHÔNG subscribe |
| `context.watch<T>()` | `context.watch<MenuViewModel>()` | Tra + subscribe: rebuild khi nó notify (bài 2) |
| generic `<T>` | `read<MenuViewModel>` | Kiểu đăng ký = kiểu tra — sai T là `ProviderNotFoundException` |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `package:provider/provider.dart` | `flutter pub add provider` |
| `Provider<T>.value` | Đưa object sống-ngoài-tree vào cây |
| `ChangeNotifierProvider` | Provider chuyên cho `ChangeNotifier` — tự gọi `dispose()` (bài 3) |
| `MultiProvider` | Gộp nhiều provider một chỗ — senior dùng cho 8 dep; learner chưa cần vì chỉ có 1 |

## Android / Compose bridge

- SIMILARITY: Provider ≈ `CompositionLocal` (đặt giá trị, con cháu
  đọc) + DI-lite kiểu Hilt tay (scope app ở root, scope màn ở screen
  widget). `ChangeNotifierProvider` ≈ `viewModel()` scoped to nav
  destination — VM sống trong phạm vi màn đó.
- IMPORTANT DIFFERENCE: **không có compile-time graph validation.**
  Hilt báo lỗi lúc build nếu thiếu binding; Provider ném
  `ProviderNotFoundException` lúc *runtime* khi widget tra một kiểu
  không ai cung cấp. Và lookup chỉ đi *lên* — anh em cùng cấp không
  nhìn thấy provider của nhau.
- DO NOT ASSUME: `context.read` trong `build` sẽ rebuild khi object
  đổi — không, đó là `watch`. Ngược lại `watch` trong callback =
  bug phổ biến (`read` mới là cái đúng trong event handler).

## Senior project connection

- `flutter-accelerator-ai/lib/core/app_dependency_scope.dart` —
  `MultiProvider` với 8 `Provider.value` entry; object được tạo trong
  `main()` rồi `.value` vào scope. Learner giữ *đúng shape* này với
  một dependency thật duy nhất (`ProfileStore`) — cố ý không thêm
  stub, vì scope phải phản ánh thứ app thật sự có.
- `flutter-accelerator-ai/lib/main.dart` — `runApp(AppDependencyScope(
  …, child: AIMillionaireApp()))` — y hệt `main()` của bạn sau bài 1.
- `flutter-accelerator-ai/lib/screens/menu_screen.dart` — `MenuScreen`
  là `StatelessWidget` build `MultiProvider` bọc view; learner dùng
  `ChangeNotifierProvider` trực tiếp vì chỉ có một provider con.

## Build it step by step

### Bước 1 — Thêm package

```bash
flutter pub add provider
```

### Bước 2 — `AppDependencyScope`

```dart
// lib/core/app_dependency_scope.dart — FILE MỚI
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../data/profile/profile_store.dart';

/// Scope dependency của toàn app — M12.
///
/// Rút gọn của senior AppDependencyScope (MultiProvider 8 entry):
/// learner chỉ có đúng MỘT dependency app-level — ProfileStore.
class AppDependencyScope extends StatelessWidget {
  final ProfileStore profileStore;
  final Widget child;

  const AppDependencyScope({
    super.key,
    required this.profileStore,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Provider.value cho object ĐÃ TỒN TẠI: provider không tạo và
    // không dispose nó — ownership vẫn thuộc main().
    return Provider<ProfileStore>.value(
      value: profileStore,
      child: child,
    );
  }
}
```

`.value` là điểm sống còn ở đây: `ProfileStore` được `main()` tạo và
`main()` sở hữu — nếu dùng `create:` thì provider sẽ cố dispose store
khi rời cây, cắt đứt ownership của main.

### Bước 3 — `main()` bọc scope

```dart
// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final profileStore = ProfileStore(await SharedPreferences.getInstance());
  runApp(
    AppDependencyScope(
      profileStore: profileStore,
      child: const AIMillionaireApp(),
    ),
  );
}

class AIMillionaireApp extends StatelessWidget {
  const AIMillionaireApp({super.key});
  // … home: const MenuScreen() — không còn tham số store
}
```

`AIMillionaireApp` trở lại `const` không-tham-số: đường threading
`main → App → MenuScreen` của M10 bị xoá sạch.

### Bước 4 — `MenuScreen` đọc store từ scope

Bỏ tham số `profileStore` thì `widget.profileStore` trong `initState`
không còn tồn tại — store giờ lấy *từ cây* bằng đúng `context.read`
vừa học (tra một lần, không cần subscribe):

```dart
// lib/screens/menu_screen.dart
import 'package:provider/provider.dart';   // THÊM — extension read/watch

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});           // BỎ `required this.profileStore`
  // (field `profileStore` cũng xoá)
  // …
}

class _MenuScreenState extends State<MenuScreen> {
  late final MenuViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // context.read hợp lệ trong initState: provider đã gắn phía trên,
    // tra một lần không subscribe — thay widget.profileStore của M11.
    _viewModel = MenuViewModel(store: context.read<ProfileStore>());
    unawaited(_viewModel.load());
  }
  // … ListenableBuilder + dispose giữ nguyên …
}
```

Đây là lần áp dụng đầu tiên của bảng quy tắc vừa học: initState cần
object *một lần* → `read`, không phải `watch`.

### Bước 5 — cập nhật widget test cũ

`initState` giờ gọi `context.read<ProfileStore>()` → mọi test pump
`MenuScreen` *không có scope phía trên* sẽ nổ
`ProviderNotFoundException` — đúng lỗi bạn sắp thử ở mục "Chạy và
quan sát". Ba chỗ pump còn lại từ M08–M10 (hai ở M08, một ở M09) đang
truyền tham số đã bị xoá, sửa mỗi chỗ từ:

```dart
await tester.pumpWidget(
  MaterialApp(home: MenuScreen(profileStore: profileStore)),
);
```

thành bọc scope *ngoài* `MaterialApp` — đúng thứ tự cây thật:

```dart
await tester.pumpWidget(
  AppDependencyScope(
    profileStore: profileStore,   // store test tự tạo (M10: prefs giả)
    child: const MaterialApp(home: MenuScreen()),
  ),
);
```

Đây là **test seam** của DI: test tự dựng dependency tại biên, không
mượn `main()`. Từ đây mọi test chạm `MenuScreen` đều đi qua scope —
giống hệt pattern Bước 3 ở production.

## Hiểu code

- **`Provider.value` vs `Provider(create:)`** — quyết định duy nhất:
  *ai sở hữu object?* Đã tồn tại trước tree → `.value`; sinh ra cùng
  cây → `create:`. Sai cái này = double-dispose hoặc leak.
- **Vì sao scope là một widget riêng** thay vì đặt `Provider.value`
  thẳng trong `main`? — Đặt tên cho khái niệm ("đây là điểm vào DI của
  app"), giữ `main()` chỉ lo bootstrap, và giống hình dạng file senior
  để M14+ chỉ cần thêm entry.
- **`context.read` trong `create:`** — `create` nhận context *nằm dưới
  provider mới*, và provider mới nằm *dưới* `AppDependencyScope` →
  `read<ProfileStore>` tra được lên scope. Tra ngang/xuống là không
  thể — đúng quy tắc "chỉ lên".

## Chạy và quan sát

- `flutter analyze`/`flutter test` — vẫn xanh; app hành xử y M11.
- Muốn *thấy* lookup fail: tạm bỏ `AppDependencyScope` → chạy →
  `ProviderNotFoundException` với stack chỉ đúng tên type thiếu —
  đáng thử một lần để nhớ cảm giác.

## Lỗi hay gặp

1. **`Provider(create:)` cho object main() đã tạo** — provider sẽ
   dispose store khi scope unmount → phiên sau dùng object chết.
   Đúng: `.value`.
2. **`context.read<T>()` với context *trên* provider** — đặt provider
   trong `MenuScreen.build` rồi tra ngay trong cùng build →
   `ProviderNotFoundException`. Cần widget con nằm dưới provider.
3. **Quên import `provider.dart`** — `read`/`watch` là extension trên
   `BuildContext` của package; không import thì context không có các
   method đó.
4. **`Provider<ProfileStore>` thiếu `<T>`** — generic là chìa lookup;
   bỏ `T` thì đăng ký sai kiểu.

## Kiểm tra hiểu biết

1. `Provider.value` và `Provider(create:)` khác nhau về *ownership*
   ra sao? — *`.value` chỉ đưa object có sẵn vào cây — không tạo, không
   dispose; `create:` tạo lúc cần và provider dispose khi rời cây.*
2. Vì sao `MenuScreen.build` không thể `context.watch<MenuViewModel>()`
   ngay trong cùng build đặt provider? — *Build chạy ở element của
   MenuScreen — TRÊN provider; lookup chỉ đi lên nên provider mới tạo
   chưa thấy. Phải có widget con bên dưới provider.*
3. `main()` tạo store rồi `.value` vào scope — nếu app cần store thứ
   hai (settings), cấu trúc nào đổi? — *`AppDependencyScope.build`
   chuyển sang `MultiProvider(providers: [Provider.value(…),
   Provider.value(…)])` — chính là form senior.*

## Tự làm (PREDICT)

Cây widget bên dưới có 4 lần tra `context.read<MenuViewModel>()` /
`context.watch<MenuViewModel>()` ở các vị trí khác nhau. Với mỗi lần:
**tra được hay `ProviderNotFoundException`?** (và nếu được — `read`
hay `watch` là hợp lệ?)

```
Provider<ProfileStore>.value(store)
 └─ MaterialApp
     └─ MenuScreen                       ← (A) build của MenuScreen
          └─ ChangeNotifierProvider<MenuViewModel>(create: …)
               └─ _MenuScreenView       ← (B) build của view này
                    └─ Column
                         ├─ Header      ← (C) build của Header
                         └─ Footer     ← (D) onTap callback trong Footer
```

1. `(A)` — `build` của `MenuScreen` gọi `context.watch<MenuViewModel>()`.
2. `(B)` — `build` của `_MenuScreenView` gọi `context.watch<MenuViewModel>()`.
3. `(C)` — `build` của `Header` gọi `context.watch<MenuViewModel>()`.
4. `(D)` — `onTap` của `Footer` gọi `context.watch<MenuViewModel>()`.

:::note[Gợi ý]
Hai câu hỏi theo thứ tự: (i) provider nằm **trên hay dưới** context
đang tra? (ii) lệnh gọi đang ở **trong build** hay trong **callback**?
Một câu hỏi sai ở bất kỳ cái nào cũng đủ crash.
:::

<details><summary>Đáp án</summary>

1. `(A)` — **`ProviderNotFoundException`.** Context của `MenuScreen`
   nằm *trên* `ChangeNotifierProvider` — lookup đi lên thì không thấy
   gì. Đây chính là lý do pattern "screen bọc provider quanh view":
   ai đặt provider thì không tra được nó.
2. `(B)` — **được.** Context của view ở dưới provider; `watch` trong
   build là hợp lệ → subscribe, rebuild mỗi notify. Đây là chỗ bài
   này đặt `watch`.
3. `(C)` — **được.** Header càng sâu càng thấy provider (lookup đi
   lên tìm *gần nhất* — bao nhiêu tầng ở giữa cũng không sao).
4. `(D)` — **crash.** `onTap` chạy ngoài build → `watch` không được
   phép subscribe ở đó (Provider ném lỗi ngay). Callback chỉ cần
   *gọi* VM, không cần rebuild → `context.read<MenuViewModel>()`.

Quy tắc nén: **trên mình không tra được, ngoài build không `watch`
được.** Lỗi phổ biến nhất của Provider không phải "quên provider" —
mà tra đúng kiểu ở sai context.

</details>

## Ta cố ý chưa thêm

- `MultiProvider` thật — chỉ một dependency; thêm khi có dep thứ hai
  (M14+). Senior dùng MultiProvider cho 8 entry.
- `ProxyProvider`/`context.select` — ngoài scope M12.
- Navigation controller trong scope — senior có; learner chưa cần
  (menu điều hướng trực tiếp đủ cho 2 màn).

## Checkpoint hoàn thành

- [ ] `pubspec.yaml` có `provider`; `lib/core/app_dependency_scope.dart`
  tồn tại.
- [ ] `main()` bọc `AppDependencyScope` quanh `AIMillionaireApp`;
  `MenuScreen` không còn tham số `profileStore`.
- [ ] Hiểu `.value` vs `create:` và quy tắc "lookup chỉ đi lên".
