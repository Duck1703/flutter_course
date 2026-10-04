---
title: "Bài 1 · Route stack & Navigator.push"
description: "Route là gì, route stack, Navigator.of(context) tìm kiếm lên trên, MaterialPageRoute và push — nút CTA mở màn hình game."
sidebar:
  label: "Bài 1 · Route stack & push"
  order: 1
---

## Mục tiêu

Giải thích được route stack của Flutter và dùng `Navigator.of(context).push`
với `MaterialPageRoute` để mở `GameScreen` từ nút BẮT ĐẦU CHƠI.

## Bạn đang ở đâu

- Milestone: **M07 — Điều hướng: Navigator push/pop** (bài 1/3)
- App hiện tại: một màn hình duy nhất `MenuScreen` — tải profile async,
  render từ model, đồng hồ phiên bằng `StreamBuilder`, CTA bấm được nhưng
  chỉ… tăng counter và cộng EXP.

## Vì sao việc này quan trọng ngay bây giờ

M01–M06 tất cả sống trong **một** màn hình. Một app thật có nhiều màn hình —
và nút "BẮT ĐẦU CHƠI" đang nói dối: bấm vào không đi đâu cả. Trước khi xây
quiz (M08) ta cần *màn hình thứ hai* và cơ chế đi tới/lui giữa chúng. Đó là
`Navigator` — máy chồng-màn-hình có sẵn trong Flutter.

## Bạn đã biết gì

- `StatefulWidget`/`State`/`setState` (M03), `BuildContext` ở mức "vị trí
  trong cây widget" (M01–M03), `GestureDetector` + `VoidCallback` (M03),
  `MaterialApp`/`Scaffold` (M01–M02), callback đi lên / data đi xuống (M03).

## Mental model mới

**Navigator = một chồng route (route stack).** Mỗi route là "một màn hình
đang nằm trong chồng". Chỉ route trên cùng là hiển thị đầy đủ.

```
Lúc đầu:            Sau push:              Sau pop:
┌────────┐          ┌────────┐             ┌────────┐
│  Menu  │          │  Game  │ ← top       │  Menu  │
└────────┘          │  Menu  │             └────────┘
                    └────────┘
```

Ba phép toán chính:

- `push(route)` — đặt route mới **lên trên** chồng. Route cũ *không bị
  huỷ* — nó nằm yên bên dưới, giữ nguyên `State`.
- `pop()` — gỡ route trên cùng, lộ route bên dưới ra lại.
- Route mới được tạo bởi `builder` — một hàm trả về widget màn hình.

Vì sao `Navigator.of(context)`? `Navigator` là một widget ẩn *trong cây*
(`MaterialApp` tự tạo nó). `of(context)` nghĩa là: "từ vị trí `context` này,
đi **lên** cây tìm `Navigator` gần nhất". Nó không phải biến toàn cục —
nó là *truy vấn lên cây*. Cùng kiểu `X.of(context)` bạn sẽ gặp ở
`ScaffoldMessenger.of`, `Theme.of`…

## Ví dụ độc lập — hai màn hình, một stack

Trước khi push `GameScreen` thật, xem toàn bộ cơ chế trong app 45 dòng
(DartPad — chế độ Flutter):

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: HomeScreen()));

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const DetailScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue,
            child: const Text('Mở Detail',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: const Center(child: Text('Route thứ hai')),
    );
  }
}
```

Chạy và thử ba điều — mỗi cái minh chứng một câu trong mental model:

- Bấm "Mở Detail" → Detail trượt lên: đó là `push` đặt route **lên
  trên** stack.
- AppBar của Detail **tự có nút ←** — không viết dòng nào; route biết
  nó có route nằm dưới.
- Bấm ← → về Home. `DetailScreen` bị dispose, `HomeScreen` thì không —
  route dưới nằm yên (state của nó sống sót, bạn sẽ kiểm chứng điều đó
  bằng counter ở app thật).

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `MaterialPageRoute<void>` | `MaterialPageRoute<void>(builder: …)` | `Route<T>` generic: `T` là kiểu giá trị route trả về khi `pop`. Không trả gì → `void`. |
| `builder` closure | `builder: (context) => const GameScreen()` | Hàm được gọi khi route cần build UI; `context` ở đây là context *của route mới*. |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `Navigator.of(context)` | Tìm `Navigator` gần nhất phía trên `context` |
| `.push(route)` | Đẩy route lên đỉnh stack; trả `Future` (bài 3) |
| `MaterialPageRoute` | Route kiểu Material: transition trượt, back gesture, `maintainState` giữ route dưới sống |
| `AppBar` | Thanh tiêu đề; **tự hiện nút back** khi route có route bên dưới |

## Android / Compose bridge

- SIMILARITY: `push`/`pop` ≈ `navController.navigate()`/`popBackStack()`
  trong Navigation Compose — cùng ý tưởng back stack.
- IMPORTANT DIFFERENCE: Navigation Compose khai báo *route-string* rồi gọi
  `navigate("game")`; `Navigator` cổ điển của Flutter là **imperative** —
  gọi method trực tiếp với object `Route`. Senior app cũng chọn mô hình
  này (xem bài 3).
- DO NOT ASSUME: `BuildContext` giống Android `Context` (object toàn cục
  kiểu `getApplicationContext()`). `BuildContext` gắn với **vị trí** trong
  cây widget — `Navigator.of(context)` chỉ tìm được navigator nếu từ vị trí
  đó đi lên gặp nó.

## Senior project connection

- File: `flutter-accelerator-ai/lib/navigation/app_navigation_controller.dart`
  — `openGame()` push `MaterialPageRoute(builder: (_) => const GameScreen())`
  qua `navigatorKey`. App senior **không bao giờ quá hai route** (menu, game)
  — giống hệt cấu trúc ta sắp có.
- File: `flutter-accelerator-ai/lib/screens/menu_screen.dart` — nút play gọi
  `_navigationController.openGame()` qua event bridge.
- Ta học primitive `Navigator.of(context)` trước; lớp bọc
  `AppNavigationController` sẽ đến ở M19 khi cần điều hướng từ chỗ không có
  `context`.

## Build it step by step

### Bước 1 — Tạo file GameScreen tối thiểu

```dart
// lib/screens/game_screen.dart — FILE MỚI
import 'package:flutter/material.dart';

import '../core/menu_tokens.dart';

/// Màn hình chơi — M07: mới chỉ là route thứ hai được push lên menu.
/// Bố cục quiz tĩnh; logic chơi thật đến ở M08.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MenuTokens.backgroundTop,
      appBar: AppBar(
        title: const Text('Phòng chơi'),
        backgroundColor: Colors.transparent,
        foregroundColor: MenuTokens.textPrimary,
        elevation: 0,
      ),
      body: const Center(
        child: Text('GameScreen — placeholder'),
      ),
    );
  }
}
```

- `import '../core/menu_tokens.dart'` — đường dẫn tương đối đi lên một cấp
  rồi vào `core/` (cùng quy ước các file `data/`).
- `AppBar` mới: `Scaffold` tự đặt nó lên đầu màn. Khi route này nằm trên
  route khác, AppBar **tự render nút back** — không cần code gì thêm.
- `backgroundColor: Colors.transparent` + `elevation: 0` — AppBar trong suốt
  để lộ nền gradient (thêm ở bài 2).

Chạy `flutter analyze` — phải sạch (file chưa được dùng vẫn phân tích được).

### Bước 2 — Nối CTA với push

```dart
// lib/screens/menu_screen.dart — THAY đổi
// 1) thêm import cuối khối import:
import 'game_screen.dart';

// 2) trong _MenuScreenState, thay _onPlayTap:
void _onPlayTap() {
  setState(() {
    _playTapCount++;
    _profile = _profile.gainExp(10);
  });
  // M07: push GameScreen lên đỉnh stack — menu nằm yên bên dưới.
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => const GameScreen(),
    ),
  );
}
```

- `Navigator.of(context)` — `context` ở đây là context của `State`
  (`_MenuScreenState`), nằm **dưới** `MaterialApp`/`Navigator` trong cây →
  `of()` tìm thấy navigator.
- `MaterialPageRoute<void>` — route kiểu Material. `builder` nhận context
  *riêng của route mới* — đừng nhầm với context ngoài.
- `setState` trước `push` vẫn chạy bình thường: counter/EXP cập nhật, menu
  giữ state khi nằm dưới.

Chạy app: bấm BẮT ĐẦU CHƠI → `GameScreen` trượt lên; bấm `←` trên AppBar →
quay lại menu. Counter vẫn giữ số cũ — bằng chứng menu route không bị huỷ.

## Hiểu code

Khi `push` chạy:

1. `Navigator.of(context)` leo lên cây, tìm `NavigatorState` (object điều
   khiển stack) mà `MaterialApp` đã tạo.
2. `push` nhận `MaterialPageRoute` → gọi `builder` → được `GameScreen` →
   render nó như route mới nhất với transition trượt.
3. Route `MenuScreen` chuyển sang trạng thái "dưới top" — widget tree của nó
   vẫn tồn tại (`maintainState`), `_MenuScreenState` không bị `dispose`.

## Chạy và quan sát

- Chạy: `flutter run -d chrome`
- Làm: bấm **BẮT ĐẦU CHƠI** → quan sát transition; nhìn counter "Số lần
  bấm" tăng trước khi vào game; bấm `←` → menu hiện lại, counter và đồng hồ
  phiên **không reset**.
- Nếu thấy `Navigator operation requested with a context that does not
  include a Navigator` → bạn gọi `Navigator.of` với context *trên*
  `MaterialApp` (ví dụ trong `build` của `AIMillionaireApp`). Cần context
  nằm dưới Navigator.

## Lỗi hay gặp

1. **Gọi `Navigator.of(context)` ở widget trên `MaterialApp`** — không có
   Navigator phía trên → crash lúc chạy. Phải dùng context bên trong
   `MaterialApp` (ở đây là `MenuScreen`).
2. **Nhầm `builder` với truyền widget sẵn** — `builder: (context) => …`
   là hàm, không phải `child: GameScreen()`. Route tự build khi cần.
3. **Tưởng pop "đóng app"** — pop chỉ gỡ route trên cùng; ở route gốc
   (`MenuScreen`) pop không làm gì/`canPop()` trả `false`.
4. **Quên import** `game_screen.dart` — `GameScreen` không resolve.

## Kiểm tra hiểu biết

1. Sau `push`, `_MenuScreenState` có bị `dispose` không? — *Không: route
   menu nằm dưới, `maintainState` giữ cây sống — counter giữ giá trị.*
2. `Navigator.of(context)` tìm gì và theo hướng nào? — *Navigator gần
   nhất, đi **lên** cây widget.*
3. Đổi `MaterialPageRoute<void>` thành `MaterialPageRoute<int>` — app có
   vỡ không? — *Không: generic chỉ mô tả kiểu giá trị pop trả về; ta chưa
   trả gì nên `void` là đúng nhất.*

## Tự làm (PREDICT)

**Vẽ stack bằng tay trước khi chạy.** Với app đang mở MenuScreen, dự đoán
nội dung stack sau mỗi bước — viết dạng `[đáy, …, đỉnh]`:

1. App vừa mở.
2. Bấm BẮT ĐẦU CHƠI (push GameScreen).
3. Bấm ← trên AppBar của GameScreen.
4. Bấm BẮT ĐẦU CHƠI lần thứ hai.
5. **Khó hơn:** từ trong GameScreen, giả sử một nút nào đó lại gọi
   `Navigator.of(context).push(MaterialPageRoute(builder: (_) => const
   GameScreen()))` — stack lúc này? Bấm back một lần sẽ về màn nào?

Với mỗi bước, ghi thêm: `_MenuScreenState` còn sống không? State của
`GameScreen` còn sống không?

Sau đó chạy app kiểm chứng bước 1–4 (bước 5 đọc đáp án để hiểu — hoặc
tự thử bằng cách thêm tạm nút push trong GameScreen).

:::note[Gợi ý]
Stack là LIFO thuần: `push` đặt lên đỉnh bất kể route đó "cùng kiểu" hay
không; `pop` chỉ gỡ đỉnh. Hai `GameScreen` trong stack là **hai instance
route khác nhau**, không "trùng nhau" để gộp.
:::

<details><summary>Đáp án</summary>

1. `[Menu]` — MenuScreen top.
2. `[Menu, Game]` — Game top; `_MenuScreenState` **sống** (maintainState).
3. `[Menu]` — GameScreen bị **dispose**; State menu nguyên vẹn (counter
   không reset — kiểm chứng được khi chạy).
4. `[Menu, Game]` — một instance GameScreen **mới** (initState chạy lại;
   State cũ đã chết ở bước 3).
5. `[Menu, Game, Game]` — push không quan tâm "màn này đã có chưa"; hai
   entry cùng kiểu vẫn là hai route riêng. Back một lần → `Game` (route
   thứ nhất của game), **không** về Menu. Phải pop hai lần mới về Menu.

Bài học lớn: stack lưu **instance**, không lưu kiểu. "Đã ở GameScreen
rồi" không ngăn push thêm một GameScreen nữa — và State của route cũ
không bao giờ hồi sinh sau khi bị pop.

</details>

## Ta cố ý chưa thêm

- `AppNavigationController` + `GlobalKey<NavigatorState>` (senior) — M19.
- Named routes / `go_router` / deep link — senior không dùng, course không
  cần.
- Truyền tham số giữa routes — game tự chứa dữ liệu, chưa cần route args.
- Quiz thật trong `GameScreen` — **M08**.

## Checkpoint hoàn thành

- [ ] CTA push `GameScreen` lên trên menu.
- [ ] Back trên AppBar quay về menu; counter/EXP/ticker không reset.
- [ ] `flutter analyze` sạch, `flutter test` xanh (15 test).
