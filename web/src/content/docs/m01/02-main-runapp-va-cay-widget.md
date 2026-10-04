---
title: "Bài 2 · main(), runApp() và cây Widget đầu tiên"
description: "Entry point của app Flutter, widget tree, StatelessWidget, MaterialApp và màn hình tuỳ biến đầu tiên."
sidebar:
  label: "Bài 2 · runApp & cây Widget"
  order: 2
---

## Mục tiêu

Sau bài này bạn viết được một `main.dart` tối thiểu nhưng đầy đủ: `main()` →
`runApp()` → `MaterialApp` → `Scaffold` → widget hiển thị — và giải thích được
từng dòng làm gì.

## Bạn đang ở đâu

- Milestone: **M01** (bài 2/3)
- App hiện tại: project `learner-app` đã tạo, pubspec đã dọn, nhưng
  `lib/main.dart` vẫn là app counter của template.

## Vì sao việc này quan trọng ngay bây giờ

Template counter "chạy được" nhưng bạn không hiểu nó — `StatefulWidget`,
`_counter`, `setState` đều là khái niệm chưa dạy. Ta viết lại `main.dart` từ
con số không bằng đúng những gì đã học, để mỗi dòng đều là dòng bạn tự hiểu.

## Bạn đã biết gì

- `main()` là entry point của chương trình Dart (giống `fun main()` của Kotlin).
- Màn hình Android có vòng đời `onCreate` → `setContent { ... }`.

## Mental model mới

**UI của Flutter là một cây Widget.** Widget là *mô tả bất biến* (immutable
description) của một mảnh UI — nó giống "file cấu hình" hơn là view. Khi trạng
thái đổi, Flutter *xây lại cây widget mới* rồi so với cây cũ để cập nhật những
gì thật sự thay đổi trên màn hình.

Ba tầng cần tách biệt ngay từ đầu:

```
Cây Widget   — bạn viết: mô tả UI (immutable, được tạo lại liên tục)
Cây Element  — Flutter quản lý: "vị trí" của widget trong cây, sống lâu hơn
Cây RenderObject — Flutter quản lý: layout + vẽ thật sự
```

Ở M01 bạn chỉ cần nhớ: *bạn khai báo cây Widget; Flutter lo phần còn lại.*
Sẽ quay lại hai cây kia khi học `State` ở M03.

## Dart cần dùng

| Cú pháp | Ví dụ trong bài | Nghĩa |
|---------|-----------------|-------|
| Hàm top-level | `void main() { ... }` | Hàm không thuộc class nào; Dart cho phép (khác Java) |
| `class X extends Y` | `class AIMillionaireApp extends StatelessWidget` | Kế thừa, giống Kotlin `: StatelessWidget()` |
| Constructor + `super.key` | `const AIMillionaireApp({super.key})` | Constructor nhận **tham số đặt tên** trong `{}`; `super.key` chuyển `key` lên constructor cha |
| `const` | `const WelcomeScreen()` | Tạo object **tại compile-time**: widget hoàn toàn hằng thì Flutter tái dùng, bỏ qua khi diff cây |
| `@override` | trên `build` | Đánh dấu ghi đè — cần có, analyzer cảnh báo nếu ghi đè mà thiếu |
| `import` | `import 'package:flutter/material.dart'` | Kéo thư viện Material (widget, màu, theme) vào file |

Tham số đặt tên (named parameter) là cú pháp Dart quan trọng nhất hôm nay:
`Scaffold(backgroundColor: ..., body: ...)` — tham số nằm trong `{ }` của
khai báo, gọi bằng `tên: giá trị`, đọc được mà không cần nhớ thứ tự. Widget
Flutter dùng named parameter *ở khắp nơi*.

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `runApp(widget)` | Nhận widget gốc, inflate và gắn lên màn hình. App bắt đầu từ đây |
| `StatelessWidget` | Widget **không có state nội tại** — chỉ mô tả UI từ constructor params |
| `build(BuildContext)` | Hàm duy nhất bạn bắt buộc implement: trả về cây widget con |
| `BuildContext` | *Vị trí* của widget trong cây — handle để hỏi "cha ông" (theme, navigator…). |
| `MaterialApp` | Vỏ app: cung cấp theme, navigation, text direction… cho toàn cây con |
| `Scaffold` | Khung xương một màn hình Material: `backgroundColor`, `body`, (sau này `appBar`…) |
| `Center` | Layout widget: canh giữa `child` trong không gian cha cho phép |
| `Text` + `TextStyle` | Hiển thị chuỗi; style là object riêng (`color`, `fontSize`, `fontWeight`, `height`) |
| `Colors` / `Color(0xFF…)` | Bảng màu Material và màu ARGB tuỳ ý |

:::caution[ĐỪNG NHẦM: BuildContext ≠ Android Context]
`BuildContext context` trong `build` **không phải** Android `Context`. Nó không
phải god-object truy cập resource/service tùy ý — nó là **toạ độ của widget trong
cây**. Cú pháp `Something.of(context)` (sẽ gặp sau) đi *lên* cây từ vị trí đó.
Đừng bao giờ hình dung context như `applicationContext`.
:::

## Cầu nối Android / Compose

- SIMILARITY: `runApp(const AIMillionaireApp())` ≈ `setContent { App() }` trong
  `onCreate`; `StatelessWidget` ≈ stateless composable function;
  `MaterialApp` ≈ `MaterialTheme` + `NavHost` gộp ở gốc.
- IMPORTANT DIFFERENCE: widget **không phải hàm composable** — nó là object
  cấu hình bất biến. "Rebuild" nghĩa là tạo *object widget mới* mô tả lại UI;
  Flutter tự quyết phần nào của render tree phải cập nhật — không phải vẽ lại
  toàn bộ view hierarchy như invalidate() của View.
- DO NOT ASSUME: `MaterialApp` là bắt buộc — Flutter chạy được cả app thuần
  widget (`runApp(Text(...))`). MaterialApp là vỏ Material chúng ta *chọn*
  dùng vì app senior dùng nó.

## Trong project senior

- File: `flutter-accelerator-ai/lib/main.dart` — có `runApp(AppDependencyScope(
  child: const AIMillionaireApp()))` và `AIMillionaireApp extends
  StatelessWidget` với `build` trả về `MaterialApp(home: const MenuScreen())`.
  Cùng hình dáng — chỉ nhiều lớp hơn (async init, Provider, localization).
  M05/M12 sẽ thêm từng lớp đó.
- File: `flutter-accelerator-ai/lib/screens/menu_screen.dart` —
  `MenuScreen extends StatelessWidget` — màn hình cũng chỉ là widget.

## Từng bước thực hiện

### Bước 1 — Bộ khung tối thiểu

Thay **toàn bộ** `lib/main.dart` bằng:

```dart
// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const AIMillionaireApp());
}

class AIMillionaireApp extends StatelessWidget {
  const AIMillionaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Millionaire',
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}
```

Mỗi dòng mới:

- `import 'package:flutter/material.dart'` — thư viện widget Material của
  Flutter SDK (không phải package bên thứ ba).
- `void main()` — entry point; `void` = không trả giá trị.
- `runApp(const AIMillionaireApp())` — gắn widget gốc của bạn lên màn hình.
- `const AIMillionaireApp({super.key})` — constructor `const` nhận named param
  `key` chuyển lên cha. `key` là *định danh* của widget trong cây — lúc này chỉ
  cần biết nó tồn tại và truyền qua `super.key` là quy ước chuẩn.
- `MaterialApp(title:, debugShowCheckedModeBanner:, home:)` — vỏ app:
  `title` là tên app cho task switcher; `debugShowCheckedModeBanner: false`
  tắt banner "DEBUG"; `home:` là widget màn hình đầu tiên.
- `WelcomeScreen()` — class viết ở bước 2; tạm thời chưa có → analyzer báo đỏ,
  hoàn tất ngay dưới đây.

> Vì sao `MaterialApp` không `const` mà `WelcomeScreen()` lại `const`?
> `MaterialApp` sẽ còn nhận thêm tham số runtime ở các bài sau (theme, locale…),
> nên để non-const cho thói quen; `WelcomeScreen` là widget gốc của màn hình —
> `const` hoá nó cho phép Flutter bỏ qua cả subtree khi rebuild.

### Bước 2 — Màn hình đầu tiên

Thêm vào **cuối** `lib/main.dart`:

```dart
// lib/main.dart — thêm vào cuối file
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B1026),
      body: Center(
        child: Text('AI MILLIONAIRE'),
      ),
    );
  }
}
```

- `Scaffold` — khung màn hình: nền + `body`.
- `backgroundColor: Color(0xFF0B1026)` — màu ARGB hex (`FF` = alpha đục).
- `Center(child: Text('AI MILLIONAIRE'))` — chuỗi đầu tiên, canh giữa.
- Toàn bộ `Scaffold` là `const` — không tham số nào cần runtime, nên Flutter
  tạo nó một lần tại compile-time. (Tại sao `const` tốt: bài 3 sẽ nói khi
  bàn Hot Reload; chi tiết tối ưu ở milestone sau.)

Chạy `flutter analyze` — phải `No issues found!`.

### Bước 3 — Styling cho Text

Vẫn trong `WelcomeScreen.build`, thay `child: Text('AI MILLIONAIRE')` bằng:

```dart
// lib/main.dart — trong WelcomeScreen.build, thay phần child của Center
        child: Text(
          'AI MILLIONAIRE\nHành trình Flutter bắt đầu',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
```

- `'\n'` — xuống dòng trong chuỗi Dart, như Kotlin.
- `textAlign: TextAlign.center` — canh giữa từng dòng khi text nhiều dòng.
- `style: TextStyle(...)` — object style riêng: `color`, `fontSize` (đơn vị
  logical pixel, không cần `sp`), `fontWeight`, `height` (hệ số line-height).
- `Colors.white` — hằng màu của bảng Material (`Colors.<tên>`).

`flutter analyze` — sạch. Đây chính là code M01 đã verify.

## Đọc hiểu code

Khi `flutter run`, chuỗi sự kiện là:

```
Dart VM gọi main()
  → runApp(AIMillionaireApp)         // widget gốc được gắn vào cây
  → Flutter gọi AIMillionaireApp.build(context)
  → trả về MaterialApp
       → MaterialApp tự build phần trong của nó, gọi tiếp build() của home
       → WelcomeScreen.build(context)
       → trả về Scaffold → Center → Text
  → engine render cây kết quả lên màn hình
```

Hai lần xuất hiện `BuildContext context`: mỗi `build` nhận context *riêng* —
vị trí của chính widget đó trong cây. Ở bài này chưa dùng nó; từ M02 trở đi nó
sẽ xuất hiện khi cần hỏi theme (`Theme.of(context)`).

## Chạy và quan sát

- Chạy: `flutter run -d chrome` (hoặc `-d <device>` của bạn). Xem chi tiết
  chọn device ở bài 3.
- Kỳ vọng: màn nền navy đậm, hai dòng chữ trắng "AI MILLIONAIRE / Hành trình
  Flutter bắt đầu" canh giữa, không banner DEBUG.
- Nếu vẫn thấy app counter → đang chạy file cũ; kiểm tra bạn đã lưu
  `main.dart` mới.

## Lỗi thường gặp

1. **Quên `const` bị analyzer nhắc** — `prefer_const_constructors` gợi ý thêm
   `const` khi mọi tham số đều hằng. Thêm vào; đây là lint mặc định của
   `flutter_lints`.
2. **`build` không trả về Widget** — quên `return` hoặc return sai kiểu →
   lỗi type ngay lúc analyze.
3. **Để widget con trực tiếp trong `home`** thay vì `Scaffold` — `home` cần
   widget màn hình; Text trần sẽ hiển thị nhưng thiếu nền/material context.
4. **Nhầm `context` với Android Context** — xem khung "Đừng nhầm" ở trên.

## Kiểm tra hiểu biết

1. `runApp` nhận gì và làm gì? — Nhận widget gốc, gắn vào cây, bắt đầu render.
2. Vì sao `Scaffold` ở đây viết được `const`? — Mọi tham số là hằng
   compile-time (`Color`, `TextStyle`, `Colors.white`, literal strings).
3. Widget khác với View/Composable căn bản ở điểm nào? — Widget là cấu hình
   bất biến được tạo lại khi rebuild, không giữ state; nó không "là" pixels.
4. Micro-task: đổi `backgroundColor` thành `Color(0xFF1B1140)` rồi predict UI
   trước khi save — nền tím đậm hơn.

## Cố ý chưa làm

- Chưa có `theme`, `navigatorKey`, localization trong `MaterialApp` — senior
  cấu hình hết chỗ đó; ta thêm theo nhu cầu (theme ở M02, navigation M07,
  localization M17).
- Chưa tách `WelcomeScreen` ra file riêng — file/folder tách theo nhu cầu ở M02.
- `main()` **đồng bộ**, chưa có `WidgetsFlutterBinding.ensureInitialized()`
  hay init bất đồng bộ — senior cần vì khởi tạo Supabase/repositories; ta
  chưa có gì để khởi tạo (M05).
- Chưa có `StatefulWidget`/`setState` — M03.

## Điểm kiểm tra hoàn thành

- [ ] `main.dart` chỉ còn `AIMillionaireApp` + `WelcomeScreen` — không còn
      `MyApp`, `MyHomePage`, counter.
- [ ] App chạy và hiển thị đúng màn hình mới.
- [ ] `flutter analyze` → `No issues found!`.
