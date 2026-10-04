---
title: M02 — Composition & layout tĩnh
description: Mô hình constraint của Flutter và xây dựng màn hình menu tĩnh bằng widget composition.
sidebar:
  label: Tổng quan M02
  order: 0
---

## Kết quả sau milestone này

Màn hình menu **tĩnh** có cấu trúc giống app senior: nền gradient, header hồ sơ
(avatar + tên + icon), thẻ cấp độ với thanh tiến trình, thẻ tổng thưởng, hàng
bảng xếp hạng, ba ô thống kê, và nút CTA gradient "BẮT ĐẦU CHƠI" — toàn bộ là
dữ liệu cứng, chưa có hành vi.

Quan trọng hơn hình dáng: bạn **hiểu vì sao** cây widget được xếp như vậy —
constraint đi xuống, kích thước đi lên, cha đặt vị trí.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [Mô hình layout: constraints đi xuống](/m02/01-mo-hinh-constraints/) | Constraint flow, Column, trục main/cross, vì sao không có "modifier" |
| 2 | [Khung màn hình menu & MenuTokens](/m02/02-khung-man-hinh-menu/) | Tổ chức file, `static const`, `SafeArea`, `ConstrainedBox`, `Container` + `BoxDecoration` + gradient |
| 3 | [Header hồ sơ & các thẻ đầu tiên](/m02/03-header-va-cac-the/) | `Row`, `Expanded`, `Icon`, `final` field, `required`, `Spacer`, `Expanded(flex:)` |
| 4 | [Nút CTA & hoàn thiện menu tĩnh](/m02/04-nut-cta-va-hoan-thien-menu/) | Tái dùng pattern, `_StatTile` có tham số, `double.infinity`, hoàn thiện layout |

## Khái niệm được giới thiệu

- **Dart:** `List<Widget>` literal, `final` field của
  widget, tham số `required`, class private `_Foo`, constructor private
  `MenuTokens._()`, `static const`, `double.infinity`.
- **Flutter:** `Column`, `Row`, `Expanded`/`Spacer`, `SafeArea`, `Padding` +
  `EdgeInsets`, `SizedBox`, `Container` + `BoxDecoration` (`color`,
  `borderRadius`, `border`, `gradient`, `shape`), `Icon` + `Icons`,
  `ConstrainedBox`/`BoxConstraints`, `Center`.

## Tiêu chí hoàn thành

- Menu hiển thị đủ các phần, không cảnh báo overflow.
- Layout có lớp giới hạn chiều rộng kiểu "design frame" (375px).
- Bạn giải thích được tại sao `Expanded` cần thiết ở những chỗ đã dùng.

## Tổng kết M02 — tự kiểm tổng hợp

- **Tôi học được gì?** `Column`/`Row`/`Expanded`/`SizedBox`/`Padding`;
  constraint chảy xuống — size chảy lên.
- **Tôi giải thích được gì?** Vì sao `Expanded` trong `Row` chia đều;
  khi nào overflow xảy ra và cách đọc banner đỏ-vàng.
- **Tôi viết được gì không copy?** Một hàng stat-tile mới chia đều
  (bài Tự làm) — và nói được `SizedBox` vs `Padding` khác nhau ở đâu.
- **Nếu X đổi thì sao?** Thêm tile thứ 5 vào `_StatsRow` — có overflow
  không? (Không — flex chia phần còn lại.)
- **Concept cần lại sau:** `Expanded`/`Flexible` — M09 dialog, M14
  build; `BuildContext` trong `build` — M03/M11.
