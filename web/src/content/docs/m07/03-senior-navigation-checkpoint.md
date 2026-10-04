---
title: "Bài 3 · Điều hướng của senior & checkpoint"
description: "Soi AppNavigationController của senior (navigatorKey + openGame/goBack), push trả về Future, và tổng kết M07."
sidebar:
  label: "Bài 3 · Senior & checkpoint"
  order: 3
---

## Mục tiêu

Nhận diện được kiến trúc điều hướng của app senior — cùng hai route, cùng
`MaterialPageRoute` — và hiểu tại sao course cố tình học primitive
`Navigator.of(context)` trước.

## Bạn đang ở đâu

- Milestone: **M07** (bài 3/3 — cuối milestone)
- App hiện tại: hai route (Menu → Game), push/pop hoạt động, `GameScreen`
  là layout quiz tĩnh chờ M08.

## Vì sao việc này quan trọng ngay bây giờ

Mỗi milestone trong course kết thúc bằng việc nhìn lại senior: bạn vừa học
xong một primitive — giờ là lúc nhận ra nó *ở đâu* trong codebase thật và
phần nào còn thiếu. Điều hướng là nơi khoảng cách learner↔senior **nhỏ
nhất** từ trước đến giờ: senior chỉ có đúng 2 route như ta.

## Bạn đã biết gì

- Route stack, `push`/`pop`, `MaterialPageRoute`, `AppBar` back (bài 1–2);
  `Future`/`Stream` (M05/M06); `BuildContext` đi lên (bài 1).

## Mental model mới

**`push` trả về một `Future<T?>`** — Future đó *hoàn thành khi route bị
pop*, và giá trị nó chứa là tham số `result` truyền vào `pop(result)`:

```dart
// Ý tưởng (course chưa dùng — chỉ để nhận diện khi đọc senior/docs):
final result = await Navigator.of(context).push<String>(
  MaterialPageRoute<String>(builder: (context) => const PickScreen()),
);
// result == gì đó mà PickScreen truyền vào pop(result)
```

App của ta không cần giá trị trả về — `MaterialPageRoute<void>` là đúng.
Nhưng biết `push → Future` giúp đọc senior và docs không bỡ ngỡ.

**`GlobalKey<NavigatorState>`** — "chìa khoá" gắn vào `Navigator` để một
object *không nằm trong cây widget* vẫn gọi được `push`/`pop` mà không cần
`BuildContext`. Senior dùng nó vì `AppNavigationController` là object
thường, không phải widget. Ta chưa cần: mọi lời gọi của ta đều có
`context` sẵn trong `State`.

## Android / Compose bridge

- SIMILARITY: `navigatorKey` ≈ giữ `NavController` ở tầng app thay vì tìm
  nó trong UI — cùng ý tưởng "điều hướng không phụ thuộc view hiện tại".
- IMPORTANT DIFFERENCE: `push` trả `Future` chứ không phải callback —
  pattern "chờ kết quả từ màn hình con" (`startActivityForResult`…) ở
  Flutter chỉ là `await push(...)`.
- DO NOT ASSUME: route result là bắt buộc — đa số route `void`; chỉ màn
  "chọn rồi trả về" mới dùng `pop(result)`.

## Senior project connection

Đọc — không copy — `lib/navigation/app_navigation_controller.dart`
(toàn file ~40 dòng):

```dart
class AppNavigationController {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> openGame() async {
    await _push<void>(
      MaterialPageRoute<void>(builder: (context) => const GameScreen()),
    );
  }

  void goBack() => _pop();
  // _navigator = navigatorKey.currentState, pop có canPop() guard…
}
```

Nhận diện ngay được:

- `MaterialPageRoute<void>` — **y hệt** dòng của ta; senior cũng không
  dùng named route, không route arguments.
- `navigatorKey` — cho phép `openGame()` gọi push mà không cần `context`
  (controller được menu event bridge gọi: `lib/screens/menu_screen.dart`
  dòng `_navigationController.openGame()`).
- `goBack` kiểm tra `navigator.canPop()` trước khi pop — an toàn hơn pop
  mù ở route gốc.

**Tại sao ta học primitive trước:** mọi abstraction điều hướng (controller,
go_router, auto_route…) cuối cùng đều gọi `Navigator.push/pop`. Hiểu
stack + `of(context)` trước thì khi gặp wrapper, bạn chỉ học "ai giữ
context dùm ta" — thay vì học hai thứ một lúc.

## Build it step by step

Không có thay đổi code — bài này là kiểm tra + đọc senior. Nếu muốn thử
`pop` thủ công, thêm tạm nút "Quay lại" vào `GameScreen` gọi
`Navigator.of(context).pop()` — rồi xoá: AppBar đã đủ.

## Hiểu code — toàn cảnh M07

```
MenuScreen (route đáy)
  └─ _onPlayTap()
        ├─ setState: counter++, profile.gainExp(10)
        └─ Navigator.of(context).push(MaterialPageRoute<void>(
               builder: (context) => const GameScreen()))
                    │
                    ▼ stack: [Menu, Game]
        AppBar.back / system back → Navigator.pop()
                    │
                    ▼ stack: [Menu]  — State menu giữ nguyên mọi field
```

## Chạy và quan sát

- `flutter analyze` → sạch; `flutter test` → 15/15; `flutter build web`
  → build được.
- Vào game, bật lại `debugPrint` của menu (`initState`/`dispose`): quay
  lại menu **không** in `initState` mới → State không bị tạo lại.

## Lỗi hay gặp

1. **Copy `navigatorKey` pattern ngay bây giờ** — không cần: khi nào phải
   điều hướng từ nơi không có `context` (ViewModel, event bridge), M19 sẽ
   đưa pattern này vào có lý do.
2. **Tưởng `push` await là chờ "màn hình load xong"** — Future hoàn thành
   khi route bị *pop*, không phải khi build xong.
3. **Pop ở route gốc** — `pop()` ở `MenuScreen` không còn gì để lộ ra;
   senior `canPop()`-guard vì lý do này.

## Kiểm tra hiểu biết

1. `AppNavigationController` của senior cần `navigatorKey` vì sao? —
   *Nó là object thường, không có `BuildContext`; key cho phép chạm
   `NavigatorState` từ ngoài cây.*
2. `MaterialPageRoute<void>` nghĩa là gì? — *Route trả về `void` — không
   có result; `push` vẫn trả `Future<void>` hoàn thành lúc pop.*
3. Hai route của app ta hiện tại là gì? — *`MenuScreen` (gốc) và
   `GameScreen` (push) — đúng cấu trúc senior.*

## Tự làm

**Sửa đổi — không copy.** Trong `GameScreen`, nút back mặc định
(`AppBar`) đã `Navigator.pop`. Hãy:

1. Thêm một nút "Về menu" riêng ở body (khác nút back trên AppBar) dùng
   `Navigator.pop(context)` — xác nhận stack vẫn pop đúng.
2. Dự đoán: nếu `GameScreen` mở từ `MenuScreen` mà bạn gọi
   `Navigator.push` thêm 1 `GameScreen` nữa rồi `pop` hai lần — màn nào
   hiển thị cuối? Vẽ stack từng bước.
3. Thử `Navigator.maybePop(context)` thay `pop` — khi nào nó "không
   pop"? (gợi ý: khi đây là root)

:::note[Gợi ý]
Stack LIFO: `pop` gỡ route trên đỉnh. `maybePop` an toàn ở root. `pop`
ở root với `false` trả về → có thể đóng app.
:::

<details><summary><strong>Đáp án</strong></summary>

1. `Navigator.pop(context)` trong body hoạt động y hệt AppBar back —
   `context` bất kỳ trong subtree route đều resolve về cùng `Navigator`.
2. Menu → push Game1 → push Game2 → pop → Game1 → pop → Menu. Hai route
   `GameScreen` là *hai entry khác nhau* trong stack — pop chỉ gỡ đỉnh.
3. `maybePop` tự check `canPop`: ở root (không có route dưới) nó không
   làm gì — an toàn hơn `pop` thô. `pop` ở root tùy platform có thể đóng
   app; `maybePop` không.

Senior dùng `pop` đơn giản; `maybePop`/`canPop` là API bạn nên biết tồn
tại nhưng chưa cần ở M07.
</details>

## Ta cố ý chưa thêm

- `GlobalKey<NavigatorState>` + `AppNavigationController` — **M19**.
- Route arguments/`pop(result)` — không cần trong app này (senior cũng
  không dùng).
- `showDialog`/route dialog — **M09** sẽ đẩy dialog lên đỉnh stack.
- Quiz thật — **M08** ngay sau đây.

## Checkpoint hoàn thành

- [ ] Giải thích được stack `[Menu] → [Menu, Game] → [Menu]` qua
  push/pop.
- [ ] Đọc `app_navigation_controller.dart` không bỡ ngỡ: nhận ra
  `MaterialPageRoute`, `push`, `canPop`, `navigatorKey`.
- [ ] `flutter analyze` sạch; `flutter test` xanh (15 test);
  `flutter build web` build được — **M07 gate PASS**.
