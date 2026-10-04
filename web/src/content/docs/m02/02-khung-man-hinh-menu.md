---
title: "Bài 2 · Khung màn hình menu & MenuTokens"
description: "Tổ chức file (screens/, core/), hằng số thiết kế MenuTokens, SafeArea, ConstrainedBox design frame và nền gradient."
sidebar:
  label: "Bài 2 · Khung menu & tokens"
  order: 2
---

## Mục tiêu

Sau bài này app có file `lib/screens/menu_screen.dart` chứa `MenuScreen` với
khung xương đúng chuẩn — nền gradient, `SafeArea`, khung giới hạn 375px,
`Column` ba vùng (header / body / nút) — cùng file `lib/core/menu_tokens.dart`
gom hằng số thiết kế. Ba vùng còn là placeholder có màu, sẽ "đổ thịt" ở bài 3–4.

## Bạn đang ở đâu

- Milestone: **M02** (bài 2/4)
- App hiện tại: `WelcomeScreen` với `Column` hai dòng chữ (bài 1 M02).

## Vì sao việc này quan trọng ngay bây giờ

Màn hình chào mừng chỉ có một Text — không chỗ để mọc ra menu. Trước khi xếp
từng card, ta dựng **khung xương**: đúng thư mục, đúng lớp nền, đúng giới hạn
chiều rộng, đúng ba vùng — giống hệt cách app senior chia `MenuScreenView`.
Dựng khung trước giúp mỗi card sau này chỉ là "thay một placeholder".

## Bạn đã biết gì

- `StatelessWidget`, `build(BuildContext)`, `Scaffold`, `Center`, `Text`,
  `const`, named params (M01).
- Constraint flow + `Column`/`mainAxisSize`/`crossAxisAlignment` (bài 1).

## Mental model mới

**Widget composition = bọc hộp trong hộp.** Mỗi widget chỉ làm một việc
(màu nền, padding, giới hạn rộng, xếp dọc…) — UI phức tạp là *nhiều lớp bọc
đơn giản*, không phải một widget "biết làm nhiều". Nhìn một `Container` có
`padding` + `decoration` + `child` cũng chính là ba lớp: chỉnh size/box-model,
vẽ nền, chứa con.

Và **"file đúng chỗ" là một phần của kiến trúc**: `lib/screens/` chứa widget
của cả màn hình; `lib/core/` chứa thứ dùng chung như hằng số thiết kế —
cùng quy ước với app senior.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `static const` | `static const double spacingMd = 16;` | Hằng số thuộc *class*, không cần instance |
| Constructor private | `MenuTokens._()` | `._()` = named constructor private — class chỉ là "namespace" chứa hằng, không ai `MenuTokens()` được |
| Class private | `class _ProfileHeader` | Tên bắt đầu `_` = private **theo thư viện (file)** — file khác không import được |
| `required this.x` | `const _IconBadge({required this.icon})` | Named param bắt buộc (dùng ở bài 3) |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `SafeArea` | Chừa vùng hệ thống (status bar, notch, gesture bar) — con không bị đè |
| `Container` | Hộp đa năng: `padding`, `color`/`decoration`, `width`/`height`, `child` |
| `BoxDecoration` | "Áo" của Container: `color`, `borderRadius`, `border`, `gradient`, `shape` |
| `LinearGradient` | Gradient tuyến tính — `colors`, `begin`/`end` theo `Alignment` |
| `ConstrainedBox` + `BoxConstraints` | Ép thêm constraint lên con — ở đây `maxWidth: 375` (design frame) |
| `Expanded` | Trong `Column`/`Row`: cho con chiếm **phần còn lại** của trục chính |
| `MediaQuery`/`paddingOf` | *(nhắc tới)* — đọc thông tin thiết bị như inset; `SafeArea` đã wrap nó |

:::caution[ĐỪNG NHẦM]
`ConstrainedBox` **không** phải widget `const` được (constructor có `assert` —
khác đa số widget cơ bản). Đó là lý do `const` trong skeleton chỉ đặt ở
`BoxConstraints` và `Column`, không bao trọn `SafeArea`.
:::

## Cầu nối Android / Compose

- SIMILARITY: `SafeArea` ≈ `Modifier.systemBarsPadding()`/`WindowInsets`;
  `ConstrainedBox(maxWidth)` ≈ `Modifier.widthIn(max = 375.dp)`; lớp `tokens`
  ≈ `Dimens.kt`/`Color.kt` trong design system Android.
- IMPORTANT DIFFERENCE: "giới hạn khung" là **widget bọc** ngoài nội dung,
  không phải modifier gắn lên nội dung — thứ tự bọc quyết định constraint.
- DO NOT ASSUME: `EdgeInsets`/`SizedBox` là "margin" — Flutter không có margin
  ngoài Container; cách nhau bằng `SizedBox`/`Padding` widget.

## Trong project senior

- File: `flutter-accelerator-ai/lib/widgets/common/design_frame.dart` —
  `Center > ConstrainedBox(maxWidth: AppTokens.screenDesignWidth)` — ta đang
  tái tạo đúng ý tưởng này (375px).
- File: `flutter-accelerator-ai/lib/core/app_design_tokens.dart` —
  `AppTokens` với `static const` spacing/color/motion — `MenuTokens` là bản
  rút gọn của nó (senior còn text style, duration, gradient dùng chung).
- File: `flutter-accelerator-ai/lib/widgets/menu/menu_screen_view.dart` —
  `Column` [topInset → `DesignFrame(header)` → `Expanded(content)` →
  `DesignFrame(cta)` → bottomInset] trong `Stack`: ta giữ cùng cấu trúc ba
  vùng, bỏ `Stack` vì chưa có overlay/dialog.
- File: `flutter-accelerator-ai/lib/widgets/menu/screen_top_inset.dart` —
  senior tự đọc `MediaQuery.paddingOf(context).top`; ta dùng `SafeArea` —
  đơn giản hơn và đủ dùng ở mức này.

## Từng bước thực hiện

### Bước 1 — File hằng số thiết kế

Tạo **`lib/core/menu_tokens.dart`** (thư mục `core/` tồn tại vì đây là chỗ
"thứ dùng chung" — quy ước từ project senior):

```dart
// lib/core/menu_tokens.dart — tạo mới
import 'package:flutter/material.dart';

/// Hằng số thiết kế của màn hình menu.
class MenuTokens {
  MenuTokens._();

  static const double designWidth = 375;
  static const double spacingXs = 8;
  static const double spacingSm = 12;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double radiusCard = 16;
  static const double radiusPill = 999;

  static const Color backgroundTop = Color(0xFF0B1026);
  static const Color backgroundBottom = Color(0xFF1B1140);
  static const Color cardBackground = Color(0x14FFFFFF);
  static const Color cardBorder = Color(0x24FFFFFF);
  static const Color trackBackground = Color(0x33FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color accentCyan = Color(0xFF00E0FF);
  static const Color accentYellow = Color(0xFFFFD54F);
  static const Color statGreen = Color(0xFF89E87F);
  static const Color statPurple = Color(0xFFAA9BFF);
  static const Color buttonTop = Color(0xFF745CFF);
  static const Color buttonBottom = Color(0xFF5137E5);
  static const Color earningsTop = Color(0xFF0036F9);
  static const Color earningsBottom = Color(0xFF00104B);
}
```

- `MenuTokens._()` — named constructor private: với chỉ `static` member, cấm
  ai `new MenuTokens()`; class đóng vai "namespace".
- `Color(0xAARRGGBB)` — alpha nằm ở byte đầu (`0x14` ≈ 8% trắng — màu card mờ
  của senior).
- Giá trị số bắt chước *tinh thần* palette senior (`AppTokens.qzdsPurple700`,
  `mint500`…) — ta đặt tên theo vai trò, không sao chép toàn bộ.

### Bước 2 — Khung `MenuScreen` với ba vùng placeholder

Tạo **`lib/screens/menu_screen.dart`** (`screens/` = widget chiếm cả màn
hình; khi app có nhiều màn, mỗi màn một file):

```dart
// lib/screens/menu_screen.dart — tạo mới
import 'package:flutter/material.dart';

import '../core/menu_tokens.dart';

/// Màn hình menu chính — bản tĩnh của milestone M02.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MenuTokens.backgroundTop,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [MenuTokens.backgroundTop, MenuTokens.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: MenuTokens.designWidth,
              ),
              child: const Column(
                children: [
                  _ProfileHeader(),
                  Expanded(child: _MenuBody()),
                  _PlayButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

Và **ba widget placeholder** ở cuối cùng file — chỉ là hộp có màu để "thấy"
vùng (sẽ thay thật ở bài 3–4):

```dart
// lib/screens/menu_screen.dart — tiếp cuối file (placeholder)
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(height: 60, color: MenuTokens.cardBackground);
  }
}

class _MenuBody extends StatelessWidget {
  const _MenuBody();

  @override
  Widget build(BuildContext context) {
    return Container(color: MenuTokens.cardBorder);
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(height: 68, color: MenuTokens.buttonBottom);
  }
}
```

Điểm mới của bước này:

- `body: Container(decoration: BoxDecoration(gradient: LinearGradient(...)))`
  — `Container` không có `width`/`height`/`child`-bound size thì ôm theo con;
  ở đây nó là `body` nên nhận full màn hình và **vẽ gradient phủ kín** cả vùng
  dưới status bar (SafeArea nằm *trong* nó).
- `SafeArea` — chừa notch/status bar/navigation bar cho phần content.
- `Center > ConstrainedBox(maxWidth: 375)` — "design frame": trên điện thoại
  < 375px thì full width; trên tablet/web rộng hơn thì nội dung bó còn 375 và
  nằm giữa — đúng cách senior giữ layout ổn định.
- `Column` [ `_ProfileHeader()` · `Expanded(child: _MenuBody())` ·
  `_PlayButton()` ] — ba vùng: header cố định, body **chiếm phần còn lại**
  nhờ `Expanded`, nút cố định dưới đáy. Đây là công dụng đầu tiên của
  `Expanded`: chia sẻ trục chính.
- `const Column` — ba widget con đều `const` được; lưu ý `SafeArea`/
  `ConstrainedBox` không nằm trong `const` vì `ConstrainedBox` không phải
  const-constructible.

### Bước 3 — Trỏ `home` sang `MenuScreen` + thêm theme

Trong `lib/main.dart`: **thay** `home` và thêm `theme`; **xoá** toàn bộ class
`WelcomeScreen` (đã hoàn thành nhiệm vụ demo):

```dart
// lib/main.dart — toàn bộ file sau khi sửa
import 'package:flutter/material.dart';

import 'screens/menu_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5137E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}
```

- `import 'screens/menu_screen.dart'` — import tương đối trong cùng package
  (cách `lib/` → `screens/`).
- `theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor:…,
  brightness: Brightness.dark), useMaterial3: true)` — theme tối Material 3
  với màu hạt giống tím của senior; `home: const MenuScreen()`.
- `import 'package:flutter/material.dart'` giữ nguyên trên đầu.

`flutter analyze` → `No issues found!`. `flutter run` → ba vùng màu: header
mờ trên cùng, body mờ giữa, dải tím dưới đáy — khung menu đã đứng.

## Đọc hiểu code

Thứ tự bọc và vì sao (constraint flow đúng bài 1):

```
Scaffold(body:)                → cho body toàn màn hình
Container(decoration: gradient)→ phủ nền, truyền constraint nguyên vẹn xuống
SafeArea                       → *siết* constraint: trừ vùng notch/NavBar
Center                         → lỏng constraint (0..max), sẽ canh giữa con
ConstrainedBox(maxWidth: 375)  → siết maxWidth=375 — "khung thiết kế"
Column                         → full size khung; chia trục dọc:
   _ProfileHeader()            → con chọn cao (60 placeholder)
   Expanded(_MenuBody())       → H còn lại sau 2 vùng kia
   _PlayButton()               → con chọn cao (68 placeholder)
```

## Chạy và quan sát

- Chạy: `flutter run -d chrome` (hoặc emulator).
- Kỳ vọng: nền gradient navy→tím; ba vùng placeholder tách rệt; trên cửa sổ
  rộng (web) khung nội dung dừng ở 375 và canh giữa — resize cửa sổ để thấy.
- Nếu `Expanded` lỗi "RenderFlex" → kiểm tra nó nằm **trực tiếp** trong
  `Column`/`Row`, không được bọc widget khác.

## Lỗi thường gặp

1. **`const` trước `ConstrainedBox`** — compile error: constructor có assert,
   không const được. Đặt `const` vào `BoxConstraints`/`Column` thay vì bọc cả
   `ConstrainedBox`/`SafeArea`.
2. **`Expanded` không trong Flex** — `Expanded` chỉ hợp lệ khi cha trực tiếp
   là `Column`/`Row`/`Flex`; bọc trong `Container`/`Padding` sẽ lỗi runtime.
3. **Quên `flutter pub get` sau khi đổi pubspec ở M01** — analyzer nhìn dep
   cũ. (Ở bài này không đổi pubspec, chỉ nhắc thói quen.)
4. **Import sai đường** — file trong `lib/screens/` dùng `../core/…`, không
   phải `core/…` (relative) hay `package:` (cùng package vẫn dùng được
   `package:ai_millionaire_course/…` — senior dùng kiểu relative cho file
   trong lib).

## Kiểm tra hiểu biết

1. Vì sao `Expanded` bọc `_MenuBody`? — Để body chiếm **toàn bộ chiều cao còn
   lại** giữa header và nút; nếu bỏ, Column chỉ cao vừa con và vùng thừa để
   trống cuối màn hình (thử xoá `Expanded` — body teo theo placeholder).
2. `SafeArea` nằm *trong* hay *ngoài* `Container` gradient? Tại sao? — Trong:
   gradient muốn phủ cả vùng sau status bar; chỉ *nội dung* cần né.
3. `MenuTokens._()` làm gì? — Constructor private, biến class thành namespace
   thuần cho `static const`.
4. Micro-task: đổi `designWidth` thành 480 rồi reload trên web — khung nội
   dung rộng tới 480.

## Cố ý chưa làm

- `Stack`/`Positioned` — senior xếp nền + content + dialog/onboarding bằng
  Stack; ta chưa có overlay nên chưa cần (M18/M21 sẽ quay lại).
- `AppBar` — senior tự xây header; ta cũng tự xây (bài 3) thay vì AppBar.
- Text style dùng chung trong tokens (`AppTokens.body5`…) — M28.
- Asset/ảnh (`Image.asset`, `flutter_svg`) — menu ta chưa cần ảnh; senior
  dùng SVG — M28.
- `MediaQuery` thủ công — `SafeArea` đã bao.

## Điểm kiểm tra hoàn thành

- [ ] `lib/core/menu_tokens.dart` tồn tại với `MenuTokens` private ctor.
- [ ] `lib/screens/menu_screen.dart` có khung 3 vùng; `main.dart` trỏ
      `home: const MenuScreen()` và `WelcomeScreen` đã xoá.
- [ ] `flutter analyze` sạch; app hiển thị 3 vùng màu đúng vị trí.
