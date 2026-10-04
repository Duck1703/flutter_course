---
title: "Bài 3 · ChangeNotifierProvider & scope"
description: "MenuScreen thành entry StatelessWidget bọc ChangeNotifierProvider(create:) — VM tự tạo/tự dispose theo scope màn hình; test bọc scope."
sidebar:
  label: "Bài 3 · ChangeNotifierProvider"
  order: 3
---

## Mục tiêu

Chốt M12: `MenuScreen` trở thành "entry widget" đặt
`ChangeNotifierProvider<MenuViewModel>` — VM được tạo đúng scope màn
hình và *provider tự dispose* nó. Đối chiếu hai dòng initState/dispose
của M11 biến mất, và viết test kiểm chứng scope.

## Bạn đang ở đâu

- Milestone: **M12** (bài 3/3 — chốt milestone)
- App hiện tại: `AppDependencyScope` cung cấp `ProfileStore` (bài 1);
  `_MenuScreenView` đã `watch`/`read` VM (bài 2). Còn mảnh cuối: *ai
  tạo `MenuViewModel`?*

## Vì sao việc này quan trọng ngay bây giờ

M11 bạn tự viết: `initState` → `MenuViewModel(store: widget.profileStore)`
+ `unawaited(load())`, `dispose` → `_viewModel.dispose()`. Đúng, nhưng
là boilerplate — mỗi màn có VM đều lặp cặp đó, và quên `dispose` là
leak âm thầm. `ChangeNotifierProvider` gom ba việc vào một khai báo:

```
create: (context) => MenuViewModel(store: context.read<ProfileStore>())..load()
        │                                    │                        │
        │                                    └─ tra dep từ scope      └─ kick-off
        └─ provider tự dispose VM khi provider unmount
```

VM sống *đúng phạm vi màn hình*: provider nằm trong `MenuScreen` —
màn unmount thì VM chết; không sống qua pop về màn khác, không
singleton global. Đây chính là "VM scoped to screen" của senior.

## Bạn đã biết gì

- `Provider.value` vs `create:` (bài 1) — `ChangeNotifierProvider` là
  biến thể `create:` dành cho `ChangeNotifier`: thêm tự-`dispose`.
- `context.read`/`watch` (bài 2).
- Cascade `..` — gọi method mà expression vẫn trả object gốc.

## Mental model mới

**Hai tầng scope của app hiện tại:**

```
AppDependencyScope (app-level, sống suốt app)
  └─ Provider<ProfileStore>.value      ← store sống lâu nhất
       └─ MaterialApp
            └─ MenuScreen (entry)
                 └─ ChangeNotifierProvider<MenuViewModel>  ← screen-level:
                      create: …read<ProfileStore>()..load()    sống theo màn
                      └─ _MenuScreenView  (watch/read)
```

- Dependency *app-level* → `.value` ở scope gốc (main sở hữu).
- Dependency *screen-level* → `create:` trong provider của chính màn
  (provider sở hữu, tự dispose).

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `ChangeNotifierProvider<T>` | `ChangeNotifierProvider<MenuViewModel>(create: …, child: …)` | Tạo `T extends ChangeNotifier`, expose xuống cây, `dispose()` nó khi unmount |
| `create:` callback | `create: (context) => MenuViewModel(store: context.read<ProfileStore>())` | Context ở đây *nằm dưới* provider mới → tra được store từ scope trên |
| cascade `..load()` | `MenuViewModel(…)..load()` | Chạy method ngay khi tạo mà giữ object làm giá trị — kick-off tải |
| `Provider.of` trên Element | `viewElement.read<MenuViewModel>()` | Test: lấy Element của widget dưới provider rồi `read` |

## Flutter cần dùng

`ChangeNotifierProvider` — từ `package:provider`. Ngoài ra chỉ là
sắp xếp lại widget đã có.

## Android / Compose bridge

- SIMILARITY: `ChangeNotifierProvider(create:)` trong `MenuScreen` ≈
  `viewModel()` trong Compose destination — VM gắn vòng đời màn hình;
  Hilt-lite: scope gốc cung `ProfileStore`, scope màn tạo VM đọc nó.
- IMPORTANT DIFFERENCE: auto-dispose của provider theo *widget tree
  unmount*, không theo lifecycle runtime — route pop → provider unmount
  → `dispose()` ngay. Không có keep-alive qua config change.
- DO NOT ASSUME: provider tạo VM **eager ngay khi build** theo mặc định
  của `ChangeNotifierProvider` — `..load()` chạy tức thì, đúng ý đồ
  "màn mở là bắt đầu tải" (lazy create là opt-in của provider thường).

## Senior project connection

- `flutter-accelerator-ai/lib/screens/menu_screen.dart` — senior
  `MenuScreen extends StatelessWidget` bọc `MultiProvider` với
  `ChangeNotifierProvider<MenuScreenViewModel>(create: (context) =>
  MenuScreenViewModel(userProfileRepository:
  context.read<UserProfileRepository>(), …)..loadUserProfile())` —
  **y nguyên hình dạng** của bài này; ta chỉ bớt xuống một provider.
- `flutter-accelerator-ai/test/widget_test.dart` — test bọc app trong
  scope/provider giống `buildApp` — test M12 của learner làm hệt:
  `AppDependencyScope` bọc `MaterialApp`.

## Build it step by step

### Bước 1 — `MenuScreen` thành entry StatelessWidget

```dart
// lib/screens/menu_screen.dart — THAY toàn bộ MenuScreen cũ:
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MenuViewModel>(
      // create: context nằm DƯỚI provider mới → tra store từ scope app.
      // `..load()` kick-off tải ngay khi VM sinh ra.
      create: (context) =>
          MenuViewModel(store: context.read<ProfileStore>())..load(),
      child: const _MenuScreenView(),
    );
  }
}
```

`_MenuScreenView` là `StatefulWidget` cũ của M11 đổi tên + bỏ tham số
`profileStore` + bỏ `_viewModel`/`initState`/`dispose` — phần còn lại
giữ nguyên (đã nối `watch`/`read` ở bài 2).

### Bước 2 — `main.dart` đã bọc scope (bài 1)

`AIMillionaireApp` trở lại `const`, `home: const MenuScreen()` — không
còn threading.

### Bước 3 — Test scope

```dart
// test/menu_provider_scope_test.dart — FILE MỚI
testWidgets('scope cung cấp store → VM đọc profile đã lưu từ prefs',
    (tester) async {
  const saved = UserProfileData(username: 'Minh', gamesJoined: 7);
  SharedPreferences.setMockInitialValues(const {});
  final prefs = await SharedPreferences.getInstance();
  final store = ProfileStore(prefs);
  await store.save(saved);

  await tester.pumpWidget(AppDependencyScope(
    profileStore: store,
    child: const MaterialApp(home: MenuScreen()),
  ));
  await tester.pump();

  expect(find.text('Minh'), findsOneWidget);
  await tester.pumpWidget(const SizedBox());
});

testWidgets('ChangeNotifierProvider tự dispose VM khi rời cây',
    (tester) async {
  // … pump scopedMenu …
  final vm = tester.element(find.byType(Scaffold)).read<MenuViewModel>();
  await tester.pumpWidget(const SizedBox());
  expect(() => vm.addListener(() {}), throwsA(isA<FlutterError>()));
});
```

## Hiểu code

- **Vì sao `..load()` trong `create:` thay vì `initState`?** VM là
  data-owner, `load` là *hành vi của nó* — kích hoạt ngay tại chỗ tạo
  cho đúng senior (`..loadUserProfile()`). Cascade giữ object làm kết
  quả nên `create` vẫn trả `MenuViewModel`.
- **`context.read<ProfileStore>()` trong `create:`** — context của
  `create` nằm *dưới* `ChangeNotifierProvider` mới nhưng *trên*
  `AppDependencyScope` → tra lên thấy store. Đây là lần đầu hai tầng
  scope phối hợp: app-level `.value` + screen-level `create:`.
- **Provider tự dispose VM khi unmount** — test chứng minh bằng cách
  `addListener` trên VM đã dispose ném `FlutterError`. Nhớ rule:
  ChangeNotifier "used after dispose" là lỗi — provider của senior tự
  lo hết phần đó.

## Chạy và quan sát

- `flutter analyze` + `flutter test` — 52 test xanh gồm hai test mới.
- `flutter build web` — sạch. App hành xử y hệt M11; khác biệt hoàn
  toàn dưới nước: VM được provider sở hữu.

## Lỗi hay gặp

1. **`create:` tra sai context** — `create: (context) => … read<…>()`
   dùng context *dưới provider*; copy code sang widget *trên* provider
   sẽ `ProviderNotFoundException`.
2. **Để lại `_viewModel` field + `initState`/`dispose` cũ** — hai nguồn
   sở hữu cùng một VM: một tự dispose + một tay dispose = double-dispose.
3. **`ChangeNotifierProvider.value` cho VM mới** — `.value` không
   dispose → leak. VM tạo-trong-provider dùng `create:`.
4. **Bọc `MaterialApp` trong `ChangeNotifierProvider`** — VM của một
   màn mà sống app-level: pop màn vẫn sống → sai scope. Scope đặt ở
   *entry của màn*, không ở gốc app.

## Kiểm tra hiểu biết

1. Ai dispose `MenuViewModel` sau M12? — *`ChangeNotifierProvider` khi
   nó unmount (màn menu rời cây) — không ai phải viết `dispose` tay.*
2. `ProfileStore` được provider dispose không? — *Không: nó vào cây
   bằng `.value` — ownership thuộc `main()`; provider chỉ expose.*
3. Hai tầng scope khác nhau chỗ nào? — *App-level: dependency sống lâu
   (storage/services) đặt ở scope gốc bằng `.value`; screen-level: VM
   sống theo màn, đặt ở provider của entry màn bằng `create:`.*

## Tự làm

**Sửa đổi — không copy.** `ChangeNotifierProvider` đang cung cấp
`MenuViewModel`. Hãy tự wire một service khác:

1. Tạo `class FakeClock extends ChangeNotifier { DateTime now =
   DateTime.now(); void tick() { now = now.add(const Duration(minutes:
   1)); notifyListeners(); } }`.
2. Trong `main.dart` thêm `ChangeNotifierProvider(create: (_) =>
   FakeClock())` — app chưa có `MultiProvider`, nên hai provider phải
   **lồng nhau** (`ChangeNotifierProvider > ChangeNotifierProvider >
   child`). Đặt `FakeClock` ở tầng ngoài hay trong — khác biệt gì về
   scope/lookup? Thử và giải thích.
3. Trong `MenuScreen` đọc `context.watch<FakeClock>()` và in `now` —
   tap một nút gọi `context.read<FakeClock>().tick()` → UI có rebuild
   không? Vì sao `watch` vs `read` khác nhau ở đây?

:::note[Gợi ý]
`watch` đăng ký rebuild; `read` chỉ lấy instance — dùng `read` trong
callback (`onPressed`) vì callback không cần rebuild khi VM đổi.
:::

<details><summary><strong>Đáp án</strong></summary>

1. `FakeClock` đúng như mô tả.
2. Hai tầng đều hoạt động — `context.read`/`watch` đi lên cây nên
   thấy cả hai; khác biệt chỉ là *vị trí* (ai unmount trước → ai dispose
   trước). Provider lồng nhau hoạt động tốt, chỉ dài dòng — M14 sẽ đổi
   sang `MultiProvider` để gom một chỗ khi app có vài dependency.
3. `context.read<FakeClock>().tick()` đổi `now` + `notifyListeners`;
   widget `watch<FakeClock>` rebuild với `now` mới → hiển thị cập nhật.
   Dùng `watch` trong `build`, `read` trong `onPressed` — pattern chuẩn.
   Đây là nền để hiểu `Provider<Contract>.value` ở M14: Provider cung
   cấp *bất kỳ* kiểu nào, không chỉ `ChangeNotifier`.
</details>

## Ta cố ý chưa thêm

- `MultiProvider` — chưa đủ dependency; có dep thứ hai thì đổi sang
  (senior 8 entry).
- `ProxyProvider`, `FutureProvider`, `StreamProvider` — khi dep phụ
  thuộc dep hoặc expose stream (M14 gần với điều này).
- Navigation controller trong scope — senior có `AppNavigationController`;
  learner còn một hướng điều hướng nên chưa thêm (ghi chú trong
  DECISIONS — cố ý, không phải thiếu sót).
- `GameScreen` Provider- hoá — game vẫn `setState` cố ý; M19 refactor.

## Checkpoint hoàn thành

- [ ] `MenuScreen` là `StatelessWidget` bọc
  `ChangeNotifierProvider(create: …read<ProfileStore>()..load())`.
- [ ] `_MenuScreenView` StatefulWidget: `_soundOn`/`_playTapCount`/
  `_sessionTicker` còn lại; không còn `_viewModel`/initState/dispose.
- [ ] `main()` bọc `AppDependencyScope`; `AIMillionaireApp` const.
- [ ] Test: menu đọc profile seed sẵn qua scope; VM bị dispose khi
  màn unmount. Toàn suite xanh — **M12 gate**.
