---
title: "M12 — Provider & dependency scope"
description: Provider package, context.read/watch, AppDependencyScope bọc MaterialApp, ChangeNotifierProvider sở hữu MenuViewModel, và bỏ constructor threading.
sidebar:
  label: Tổng quan M12
  order: 0
---

## Kết quả sau milestone này

Dependency đi **qua widget tree**, không qua constructor:

- `main()` vẫn tạo `ProfileStore` — nhưng giờ đặt nó vào
  **`AppDependencyScope`** (một widget bọc `MaterialApp`) thay vì
  truyền tay `AIMillionaireApp → MenuScreen`.
- `MenuScreen` trở thành `StatelessWidget` đặt
  **`ChangeNotifierProvider<MenuViewModel>`**: VM được tạo trong
  `create:` và **tự dispose** khi provider rời cây — hai dòng
  `initState`/`dispose` thủ công của M11 biến mất.
- View bên dưới dùng `context.read` (trong callback) và
  `context.watch` (trong build) thay cho `ListenableBuilder` + field
  `_viewModel`.

Hành vi app vẫn y hệt M10/M11 — đây là milestone *lấy dependency* chứ
không phải feature.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [InheritedWidget & lookup](/m12/01-inheritedwidget-va-lookup/) | Vì sao truyền tay không scale; tree lookup; `Provider<T>`/`.value` vs `create:` |
| 2 | [read vs watch](/m12/02-read-vs-watch/) | Hai cách lấy dependency; watch trong build, read trong callback; lỗi kinh điển |
| 3 | [ChangeNotifierProvider & scope](/m12/03-changenotifierprovider-va-scope/) | `create:` + auto-dispose, scope VM vào màn hình, test bọc scope |

## Khái niệm được giới thiệu

- **Dart:** generic `Provider<T>`, `context.read<T>()`/`watch<T>()`,
  `create:` callback signature.
- **Flutter:** package `provider`, `Provider.value` (object đã tồn
  tại), `ChangeNotifierProvider` (tự dispose ChangeNotifier),
  `MultiProvider` (liệt kê nhiều provider — senior dùng; ta chưa cần),
  `didChangeDependencies` như chỗ an toàn để tra provider.
- **Kiến trúc:** `AppDependencyScope` = DI-lite — một chỗ đặt
  dependency app-level; scope-per-screen cho VM.

## Tiêu chí hoàn thành

- `pubspec.yaml` có `provider`; `lib/core/app_dependency_scope.dart`
  tồn tại và bọc app trong `main()`.
- `MenuScreen` = StatelessWidget + `ChangeNotifierProvider(create:)`;
  không còn `MenuScreen(profileStore:)` hay `_viewModel` field.
- `context.read` trong `_onPlayTap`, `context.watch` trong build —
  giải thích được khác biệt.
- `flutter test` xanh gồm test scope cung cấp store + provider tự
  dispose VM; không còn constructor threading nào cho dependency.
- Vẫn chưa có: `MultiProvider` thật (chỉ có một dep), `ProxyProvider`,
  `context.select`, navigation controller — đó là khi app cần thêm
  dep thật (M13+).

## Tổng kết M12 — tự kiểm tổng hợp

- **Tôi học được gì?** `Provider.value` vs `create:`,
  `context.read`/`watch`, `ChangeNotifierProvider` tự dispose,
  `AppDependencyScope` là service-locator qua widget tree.
- **Tôi giải thích được gì?** Provider tra theo *kiểu đăng ký* —
  `read<A>` không thấy `Provider<B>` dù B subtype A (nền cho DI theo
  contract M14); `watch` trong build, `read` trong callback.
- **Tôi viết được gì không copy?** Wire một `FakeClock` qua hai
  provider lồng nhau và dùng `read`/`watch` đúng chỗ (bài Tự làm).
- **Nếu X đổi thì sao?** Ba Provider lồng nhau vs một `MultiProvider`
  — semantics khác không? (Không — MultiProvider chỉ gom list.)
- **Concept cần lại sau:** `context.read<T>()` — M13 bridge, M14 DI;
  `Provider.value` ownership — repo app-scoped M14; kiểu-đăng-ký →
  `Provider<Contract>` M14.
