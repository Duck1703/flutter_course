---
title: "Bài 1 · Mô hình layout: constraints đi xuống, kích thước đi lên"
description: "Mental model layout của Flutter: cha truyền constraint, con chọn size, cha đặt vị trí — và Column đầu tiên."
sidebar:
  label: "Bài 1 · Mô hình constraints"
  order: 1
---

## Mục tiêu

Sau bài này bạn giải thích được câu thần chú của Flutter layout —
*"constraints go down, sizes go up, parent sets position"* — và dùng được
`Column` với `mainAxisSize`/`crossAxisAlignment` để xếp nhiều widget theo
chiều dọc.

## Bạn đang ở đâu

- Milestone: **M02 — Composition & layout tĩnh** (bài 1/4)
- App hiện tại: `WelcomeScreen` nền navy, một `Text` hai dòng ở giữa màn hình.

## Vì sao việc này quan trọng ngay bây giờ

M02 sẽ xây màn hình menu gồm ~10 widget lồng nhau. Nếu không có mental model
đúng, bạn sẽ kẹt vào "vì sao `Container` này phình ra / teo lại?" — lỗi kinh
điển của người mới. Nắm constraint model **trước** khi xếp UI thật là tiết
kiệm thời gian nhất của cả milestone.

## Bạn đã biết gì

- Compose có `Column`/`Row`/`Box` và `Modifier` (`fillMaxSize`, `weight`,
  `padding`…).
- Constraint layout Android (ConstraintLayout) cũng truyền kích thước theo
  quan hệ cha-con.

## Mental model mới

Mỗi widget được layout qua **ba bước một chiều**:

```
1. Cha truyền XUỐNG một khoảng cho phép (constraints):
     "con được rộng 0..343, cao 0..600"
2. Con CHỌN kích thước của mình trong khoảng đó và trả LÊN:
     "con rộng 343, cao 24"
3. Cha quyết VỊ TRÍ của con (con không tự chọn x,y)
```

Hệ quả cần khắc sâu:

- Widget **không tự biết vị trí** của mình trên màn hình — cha đặt.
- Widget **không thể to hơn** khoảng cha cho — muốn to hơn phải đổi cha.
- "Muốn `Text` rộng hết màn hình" không có nghĩa là set width cho `Text` —
  phải bảo *cha* của nó (Row/Column/Expanded…) cho nó constraint rộng.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `List<Widget>` literal | `children: [A(), B()]` | List literal `[]` gán kiểu `Widget` — cùng cú pháp `listOf()` |
| Tham số `required` | `const _Tile({required this.x})` | Named param bắt buộc — thiếu thì compile lỗi (dùng ở bài 3–4) |
| `final` field | `final String label;` | Field gán một lần — bắt buộc trong widget vì widget bất biến |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `Column` | Xếp `children` theo **chiều dọc**; trục chính = dọc |
| `mainAxisSize` | Column muốn cao tối đa (`max`) hay vừa con (`min`) |
| `crossAxisAlignment` | Canh con theo **trục ngang** (`start`/`center`/`stretch`…) |
| `MainAxisAlignment` | Canh con theo trục chính (dọc) — dùng khi có thừa chỗ |

## Cầu nối Android / Compose

- SIMILARITY: `Column` ≈ `Column` của Compose — xếp con dọc, có
  `mainAxis`/`crossAxis` tương đương `Arrangement`/`Alignment`.
- IMPORTANT DIFFERENCE: **không có Modifier chain**. Padding, size, màu nền
  đều là *widget bọc ngoài* (`Padding`, `SizedBox`, `Container`) hoặc tham số
  riêng của widget — thứ tự bọc quyết định kết quả, không phải thứ tự
  modifier.
- DO NOT ASSUME: widget "match_parent" mặc định. `Text` tự size theo nội dung;
  muốn nó rộng ra phải qua cha (`Expanded`, `crossAxisAlignment.stretch`),
  không có `width = match_parent`.

## Trong project senior

- File: `flutter-accelerator-ai/lib/widgets/menu/menu_screen_view.dart` —
  menu senior là `Stack` chứa `Column` với `Expanded(child: MenuScreenContent)`
  — đúng pattern "cột ba vùng: header — body nở ra — CTA" mà ta sẽ xây.
- File: `flutter-accelerator-ai/lib/widgets/menu/menu_screen_content.dart` —
  dùng `Column(mainAxisSize: min, crossAxisAlignment: stretch)` để các card
  giãn hết bề ngang khung 375px.
- File: `flutter-accelerator-ai/lib/widgets/common/design_frame.dart` —
  `ConstrainedBox(maxWidth: 375)` giới hạn bề rộng thiết kế (bài 2 dùng lại
  ý tưởng này).

## Từng bước thực hiện

### Bước 1 — Tách Text hai dòng thành hai widget

Trong `WelcomeScreen.build` (`lib/main.dart`), thay `Center(child: Text(...))`
bằng:

```dart
// lib/main.dart — WelcomeScreen.build, thay phần body
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI MILLIONAIRE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Hành trình Flutter bắt đầu',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
```

Giữ nguyên `const` trước `Scaffold` — mọi tham số trong `Column` vẫn là hằng
(`TextStyle`, `Colors.white70`, `MainAxisSize.min` đều const được), nên cả
subtree vẫn tạo tại compile-time.

- `Column(children: [...])` — `children` là `List<Widget>`: nhiều widget con
  xếp dọc theo thứ tự.
- `mainAxisSize: MainAxisSize.min` — bảo Column **chỉ cao vừa hai con** thay
  vì cao hết `Center` cho phép. Thử đổi thành `max` (mặc định) rồi reload:
  hai Text vẫn đứng giữa vì `Center` canh giữa cả cột — nhưng cột đã cao hết
  khung. Khác biệt sẽ hiện rõ ở bài 2.

Chạy `flutter analyze` → sạch; `r` hot reload → hai dòng chữ tách thành hai
widget riêng.

### Bước 2 — Cảm nhận trục chéo

Thêm vào `Column` tham số:

```dart
// lib/main.dart — trong Column vừa tạo, thêm một dòng
          crossAxisAlignment: CrossAxisAlignment.start,
```

Reload: hai Text bám về **trái** (start của trục ngang = trái với LTR). Bỏ
dòng này — mặc định `center` — quay lại như cũ. Đây chính là "cha quyết vị
trí con": Column căn cross-axis cho mọi con.

### Bước 3 — Thử trục chính

```dart
// lib/main.dart — thay mainAxisSize.min bằng:
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
```

Reload: Column cao hết `Center` và hai con dồn xuống **đáy**. Chỗ thừa trục
chính được `mainAxisAlignment` phân phối. Trả lại `mainAxisSize: min` và xoá
`mainAxisAlignment` trước khi sang bài 2 — bài 2 sẽ thay toàn bộ màn hình này.

## Đọc hiểu code

```
Center  → truyền cho Column: "rộng 0..W, cao 0..H"   (constraints down)
Column  → với mainAxisSize.min: đo từng con, cộng lại,
          trả lên Center: "tôi rộng R_con, cao H_con"  (sizes up)
Center  → đặt Column vào giữa                          (parent sets position)
```

## Chạy và quan sát

- Chạy: `flutter run -d chrome`, sửa từng tham số ở các bước trên, `r`.
- Kỳ vọng: thấy rõ Column đổi "chiều cao chiếm dụng" và hướng căn con.
- Nếu UI không đổi → kiểm tra bạn sửa đúng `build` của `WelcomeScreen` và đã
  lưu file trước khi `r`.

## Lỗi thường gặp

1. **Mong `Text` "fill màn hình"** — Text luôn ôm nội dung; muốn chiếm chỗ
   phải canh qua cha (Expanded, stretch) — bài 3 dùng liên tục.
2. **`mainAxisSize.min` + `mainAxisAlignment`** — khi cột bó sát con, không
   còn chỗ thừa để căn → tham số kia "không có tác dụng" (đúng là vậy!).
3. **Nhầm main/cross** — với Column, main = dọc, cross = ngang; với Row ngược
   lại (bài 3).

## Kiểm tra hiểu biết

1. Ba bước layout của Flutter? — constraints xuống → sizes lên → cha đặt vị trí.
2. Column có `mainAxisSize: min` khác `max` thế nào? — min: cao vừa đủ con;
   max: cao hết khoảng cha cho.
3. Muốn một widget rộng hết cha — sửa widget đó hay cha nó? — Sửa cách *cha*
   phân phối constraint (ví dụ `Expanded`, `stretch`), widget con chỉ chọn
   trong khoảng được cấp.

## Cố ý chưa làm

- `Row`, `Expanded`, `Container`, `SafeArea`, `ConstrainedBox` — bài 2/3/4.
- Overflow & scroll (`SingleChildScrollView`, `RenderFlex overflowed`) —
  khi nào xảy ra sẽ nói ở bài 4 và M18.
- `Stack`/`Positioned` — app senior dùng Stack cho nền+dialog; bản ta chưa
  cần, sẽ gặp ở M18/M21.

## Điểm kiểm tra hoàn thành

- [ ] Giải thích được "constraints go down, sizes go up, parent sets position".
- [ ] `Column` với `mainAxisSize`/`crossAxisAlignment` đổi được layout như
      dự đoán khi reload.
- [ ] `flutter analyze` → `No issues found!`.
