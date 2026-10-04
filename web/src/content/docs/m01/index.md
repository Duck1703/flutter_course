---
title: M01 — Định hướng Flutter & chạy lần đầu
description: Tạo project Flutter, hiểu giải phẫu project, chạy app đầu tiên và dùng Hot Reload.
sidebar:
  label: Tổng quan M01
  order: 0
---

## Kết quả sau milestone này

Bạn sẽ có một **project Flutter thật chạy được**: tự tạo bằng `flutter create`,
đọc hiểu được cấu trúc thư mục, thay thế màn hình mẫu bằng màn hình riêng, và
dùng Hot Reload để thấy thay đổi ngay khi đang chạy.

Trạng thái app cuối M01: một `MaterialApp` hiển thị màn hình chào mừng
"AI MILLIONAIRE" tùy biến — nền tối, chữ trắng lớn.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [Flutter, Dart và project đầu tiên](/m01/01-flutter-dart-va-project-dau-tien/) | Flutter/Dart là gì, `flutter create`, giải phẫu thư mục, `pubspec.yaml` |
| 2 | [main(), runApp() và cây Widget đầu tiên](/m01/02-main-runapp-va-cay-widget/) | Entry point, `StatelessWidget`, `build`, `BuildContext`, `MaterialApp`, `Scaffold` |
| 3 | [Chạy app, Hot Reload và tooling](/m01/03-chay-app-hot-reload-va-tooling/) | `flutter run`, hot reload vs restart, `flutter analyze` |

## Khái niệm được giới thiệu

- **Dart:** `main()`, `void`, hàm top-level, `class` + `extends`, constructor +
  `super.key`, constructor `const`, tham số đặt tên, `@override`, `import`.
- **Flutter:** `runApp`, `MaterialApp`, `Scaffold`, `StatelessWidget`,
  `build(BuildContext)`, `Text`, `TextStyle`, `Colors`, `Center`,
  Hot Reload vs Hot Restart, `flutter pub get` / `analyze` / `run`.

## Tiêu chí hoàn thành

- App chạy trên ít nhất một target (device/emulator/web) và hiển thị màn hình
  tuỳ biến — không còn chữ "Flutter Demo".
- Sửa một chuỗi và thấy nó cập nhật qua Hot Reload.
- `flutter analyze` không báo lỗi.

## Tổng kết M01 — tự kiểm tổng hợp

- **Tôi học được gì?** Ba cây widget/element/render; `runApp` chỉ gọi
  một lần; `build` được gọi lại nhiều lần.
- **Tôi giải thích được gì?** Hot Reload vs Hot Restart khác nhau ở
  *phần nào chạy lại* — và khi nào cái nào không cứu được.
- **Tôi viết được gì không copy?** Một `StatelessWidget` mới hiển thị
  text của riêng mình (bài Tự làm).
- **Nếu X đổi thì sao?** Nếu đổi code trong `main()` trước `runApp`,
  reload có đủ không? (Không — cần restart.)
- **Concept cần lại sau:** `Widget`/`StatelessWidget`/`BuildContext` —
  nền của mọi bài; `const` ctor — M03+; Hot Reload — mọi ngày dev.
