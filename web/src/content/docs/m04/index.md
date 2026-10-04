---
title: "M04 — Model bất biến & unit test đầu tiên"
description: Giới thiệu class dữ liệu Dart, null safety, copyWith, ==/hashCode và bộ test pure-Dart đầu tiên của course.
sidebar:
  label: Tổng quan M04
  order: 0
---

## Kết quả sau milestone này

Màn hình menu không còn "rải" giá trị hard-code trong từng widget nữa — một
đối tượng **`UserProfileData`** duy nhất cung cấp tên, cấp độ, EXP, tiền
thưởng và thống kê cho cả màn hình. Bấm nút chơi giờ còn **cộng 10 EXP** vào
profile: thanh tiến trình nhích lên từng chút — tất cả qua cơ chế
"tạo object mới" thay vì sửa object cũ (mỗi tap +10 EXP; với mốc
35000 EXP một cấp thì "lên cấp" còn là chuyện sau — cơ chế đã sẵn sàng).

Và quan trọng không kém: `flutter test` chạy **10 test xanh** đầu tiên của
project — chúng kiểm chứng hành vi model mà không cần chạy app.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [Vì sao UI cần model + class & null safety](/m04/01-model-va-null-safety/) | `class`, `final` fields, named params, `String?`, `??`, `late` (giới thiệu) |
| 2 | [Immutability: copyWith, ==, hashCode](/m04/02-copywith-va-equality/) | Cập nhật bất biến, `copyWith`, value equality, `Object.hash`, getter |
| 3 | [Nối model vào menu](/m04/03-noi-model-vao-menu/) | Truyền object xuống widget, `gainExp` + setState, const dời chỗ |
| 4 | [Unit test đầu tiên](/m04/04-unit-test-dau-tien/) | `test/`, `group`, `test`, `expect`, Arrange–Act–Assert, `flutter test` |

## Khái niệm được giới thiệu

- **Dart:** `class` với field `final`, constructor `const` + named params +
  `required` + default values, kiểu nullable `String?`, toán tử `??`,
  `late` (khái niệm — dùng thật ở M05), `copyWith`, `operator ==`,
  `identical`, `hashCode` + `Object.hash`, getter `=>`, hàm `static`,
  `~/` chia lấy nguyên, `StringBuffer`, `while`, `var`.
- **Flutter:** không có widget mới — milestone này nằm hoàn toàn ở tầng
  dữ liệu; `Expanded(flex:)` được tái dùng với giá trị tính từ model.
- **Tooling:** `flutter_test` (trong `dev_dependencies`), `flutter test`.

## Tiêu chí hoàn thành

- Header/thẻ cấp/thẻ thưởng/stats đều đọc từ `_profile` — không còn
  hard-code `'Khách'`, `'CẤP 1'`, `'X / Y EXP'`, `'0 VNĐ'`, `'0'` trong
  widget con.
- Bấm nút chơi: đếm tăng **và** EXP tăng 10.
- `flutter test` → `All tests passed!` với ít nhất các test: mặc định,
  copyWith, equality/hashCode, gainExp, formatThousands.
- Bạn giải thích được: "immutable" **không** nghĩa là app không đổi được —
  nghĩa là ta tạo **object mới** thay vì sửa object cũ.

## Tổng kết M04 — tự kiểm tổng hợp

- **Tôi học được gì?** Model bất biến (`final` + `copyWith`), `==`/
  `hashCode`, `test()`/`expect()`/`group` đầu tiên.
- **Tôi giải thích được gì?** Vì sao `copyWith` cần `?? this.field`;
  vì sao `==` so giá trị mà không phải identity — và nó mở đường cho
  `_emitUserProfile` `value !=` ở M14.
- **Tôi viết được gì không copy?** Test cho `copyWith`/`gainExp` trên
  field khác — bao gồm viết test *để fail* (bài Tự làm).
- **Nếu X đổi thì sao?** Bỏ `??` khỏi `copyWith` → field không truyền
  thành `null` — test nào bắt được?
- **Concept cần lại sau:** `copyWith`/`==` — mọi model sau; `fromMap`/
  `toMap` — M10; test scaffold — mọi milestone.
