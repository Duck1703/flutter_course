---
title: "Bài 2 · GameScreen & pop"
description: "Dựng layout quiz tĩnh cho GameScreen (AppBar back tự động, thẻ câu hỏi, 4 ô đáp án), hiểu pop() và trạng thái sống sót dưới route."
sidebar:
  label: "Bài 2 · GameScreen & pop"
  order: 2
---

## Mục tiêu

Biến `GameScreen` từ `Text` placeholder thành bố cục quiz tĩnh (thẻ câu hỏi
+ 4 ô đáp án + nút chốt mờ), và chứng kiến bằng mắt: **route bên dưới vẫn
sống** — `pop()` trả ta về menu nguyên trạng.

## Bạn đang ở đâu

- Milestone: **M07** (bài 2/3)
- App hiện tại: push đã hoạt động, `GameScreen` đang chỉ là một `Text`.

## Vì sao việc này quan trọng ngay bây giờ

M08 sẽ bơm logic quiz vào đúng bố cục này. Dựng layout tĩnh trước giữ cho
hai thay đổi tách bạch: hôm nay chỉ có *hình dáng màn hình mới + cơ chế
quay lại*; bài sau mới là *state câu hỏi*. Đồng thời, đây là lần đầu ta
thấy `pop` và câu hỏi thú vị: "thứ gì còn sống khi một route bị che?"

## Bạn đã biết gì

- Mọi widget trong bài: `Column`/`Row`/`Expanded`/`Spacer`/`Padding`/
  `Container`/`BoxDecoration`/`BorderRadius`/`Border.all`/`LinearGradient`/
  `Opacity` (M02), `StatelessWidget` + param `required` (M02–M03),
  `SafeArea`/`ConstrainedBox` (M02), route stack + `push` (bài 1).

## Mental model mới

**`pop()` = lật route trên cùng khỏi chồng.** Không tạo gì mới — chỉ lộ
route bên dưới. Và vì `MaterialPageRoute` mặc định `maintainState: true`,
cây widget của route dưới **không bị huỷ** trong lúc bị che:

```
Menu (State còn sống: _profile, _playTapCount, _sessionTicker subscription)
   ▲
Game (route trên cùng — pop → dispose → trả về Menu y nguyên)
```

Chi tiết đáng chú ý: `_SessionTickerCard`'s `StreamBuilder` **vẫn subscribe**
khi menu nằm dưới — bộ đếm tiếp tục chạy ngầm. Đó là lý do về menu bạn thấy
số giây *nhảy tiếp*, không về 0.

`AppBar` tự render nút `←` vì nó phát hiện route hiện tại có route phía
dưới (`Navigator.canPop()` == true). Bấm `←` tương đương
`Navigator.of(context).pop()`.

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `AppBar` | Thanh trên cùng; nút back tự động khi `canPop` |
| `Opacity` | Bọc widget con, `opacity: 0.4` = 40% đậm — cách đơn giản nói "nút này chưa hoạt động" |
| `maintainState` | Thuộc tính của route (mặc định `true`) giữ cây widget route dưới sống |
| `Navigator.of(context).pop()` | Gỡ route trên cùng — AppBar tự gọi, hoặc ta gọi tay |

## Android / Compose bridge

- SIMILARITY: nút back trên `AppBar` ≈ Up button/`BackHandler` — hệ thống
  tự nối vào back stack.
- IMPORTANT DIFFERENCE: "route bên dưới giữ state" ≈ back stack của Activity
  giữ ViewModel, nhưng ở đây **cả cây widget + subscription Stream** sống
  sót — không có concept onStop/onDestroy trung gian cho route bị che.
- DO NOT ASSUME: mọi route đều giữ state — `maintainState: false` tồn tại
  (route nặng không cần giữ). Mặc định mới là `true`.

## Senior project connection

- `flutter-accelerator-ai/lib/screens/game_screen.dart` — màn hình game
  senior là `Scaffold` + `Stack` lớn với `GameScreenTopBar` (nút back riêng
  gọi `showConfirmExit` — dialog xác nhận thoát) thay vì AppBar. Ta dùng
  AppBar mặc định trước; confirm-exit của senior sẽ quay lại ở M21.
- `flutter-accelerator-ai/lib/widgets/game/questions/game_question_panel.dart`
  và `lib/widgets/game/answers/` — thẻ câu hỏi + danh sách đáp án senior.
  Layout learner của ta là bản rút gọn cùng ý tưởng.

## Build it step by step

### Bước 1 — Nền gradient + khung 375 (quen thuộc từ menu)

```dart
// lib/screens/game_screen.dart — thay body của build():
body: Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [MenuTokens.backgroundTop, MenuTokens.backgroundBottom],
    ),
  ),
  child: const SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MenuTokens.designWidth),
        child: Padding(
          padding: EdgeInsets.all(MenuTokens.spacingMd),
          child: Column(   // ← nội dung màn hình: bước 2
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [ /* … */ ],
          ),
        ),
      ),
    ),
  ),
),
```

Đây là **y hệt** khung của `MenuScreen` (M02): gradient nền → `SafeArea` →
`Center` + `ConstrainedBox` 375 → `Padding` → `Column`. Một app nên có bố
cục nền nhất quán — senior cũng làm vậy bằng `GameScreenBackground`.

### Bước 2 — Nội dung: thẻ câu hỏi + 4 đáp án + nút chốt

```dart
// lib/screens/game_screen.dart — children của Column vừa tạo:
children: [
  const _QuestionCard(
    text: 'Widget nào có state có thể thay đổi và rebuild UI?',
  ),
  const SizedBox(height: MenuTokens.spacingMd),
  const _AnswerPlaceholder(label: 'A', text: 'StatelessWidget'),
  const SizedBox(height: MenuTokens.spacingXs),
  const _AnswerPlaceholder(label: 'B', text: 'StatefulWidget'),
  const SizedBox(height: MenuTokens.spacingXs),
  const _AnswerPlaceholder(label: 'C', text: 'Scaffold'),
  const SizedBox(height: MenuTokens.spacingXs),
  const _AnswerPlaceholder(label: 'D', text: 'Container'),
  const Spacer(),
  const _ConfirmPlaceholder(),
  const SizedBox(height: MenuTokens.spacingSm),
  const Text(
    'Demo layout — quiz chơi được sẽ đến ở M08',
    textAlign: TextAlign.center,
    style: TextStyle(color: MenuTokens.textSecondary, fontSize: 12),
  ),
],
```

Ba widget private mới (xem file hoàn chỉnh bên dưới):

- `_QuestionCard` — `Container` + bo góc + `Text` căn giữa, chữ đậm.
- `_AnswerPlaceholder` — hàng `Row`: chữ cái A–D vàng + text trắng, viền
  pill. **Chưa có `onTap`** — cố ý: chọn đáp án là việc của state (M08).
- `_ConfirmPlaceholder` — nút gradient `Opacity(0.4)` = "chưa bấm được".

### Bước 3 — Kiểm tra file hoàn chỉnh

File cuối cùng (`lib/screens/game_screen.dart`, ~180 dòng): `GameScreen`
là `StatelessWidget` với `Scaffold` + `AppBar` + body gradient chứa một
`Column` trực tiếp; ba widget private `_QuestionCard`,
`_AnswerPlaceholder`, `_ConfirmPlaceholder` ở cuối file — y hệt quy ước
`_ProfileHeader`/`_MenuBody` của menu. Mở file trên máy và đối chiếu.

## Hiểu code

- `const` ở khắp `children`: toàn bộ cây tĩnh là const — Flutter tái dùng
  instance, không tạo lại mỗi rebuild (M02/M04 đã học `const`).
- `Spacer()` = `Expanded` không con — đẩy nút chốt + chú thích xuống đáy.
- Không có `Navigator.of(context).pop()` nào tự viết: nút `←` của AppBar
  là đủ — đó là "miễn phí" của route stack.

## Chạy và quan sát

- `flutter run -d chrome` → BẮT ĐẦU CHƠI → thấy layout quiz đầy đủ.
- Để ý bộ đếm phiên *trước* khi vào game, ở trong game ~10 giây, quay lại:
  số giây **tăng tiếp** chứ không về 1 — menu route sống sót toàn bộ.
- Nếu bấm các ô đáp án mà không có gì xảy ra → **đúng thiết kế**: chưa có
  `onTap`. M08 sẽ sửa.

## Lỗi hay gặp

1. **Viết `onTap` ngay bây giờ** — ô đáp án không có state nguồn để đổi
   màu; nhúng tay sớm tạo code nửa vời. M08 sẽ biến chúng thành có chọn.
2. **Tự vẽ nút back** — AppBar đã tự lo; viết tay chỉ thêm nhiễu.
3. **Tưởng `pop` tự động chạy khi widget dispose** — pop là lệnh gọi chủ
   động lên Navigator; dispose route là *hệ quả* của pop, không ngược lại.

## Kiểm tra hiểu biết

1. Vào game 20 giây rồi back — đồng hồ phiên hiển thị số nào? — *Số lớn
   hơn lúc vào: `StreamBuilder` của menu vẫn subscribe trong lúc bị che.*
2. `maintainState` mặc định trên `MaterialPageRoute` là gì? — *`true`:
   cây route dưới được giữ — đó là lý do counter/EXP không reset.*
3. Ai gọi `pop()` khi bấm `←` trên AppBar? — *Chính `AppBar`: nó render
   `BackButton` gọi `Navigator.maybePop` khi route có thể pop.*

## Ta cố ý chưa thêm

- Chọn đáp án / chấm điểm / câu tiếp theo — **M08** (cần `StatefulWidget`
  + model câu hỏi trước).
- Đếm ngược, dialog kết quả, chơi lại — **M09**.
- Dialog xác nhận thoát + `PopScope` của senior — M21.

## Checkpoint hoàn thành

- [ ] `GameScreen` render đầy đủ: AppBar "Phòng chơi", thẻ câu hỏi, 4 ô
  đáp án, nút chốt mờ, chú thích M08.
- [ ] Back trả về menu giữ nguyên counter + ticker.
- [ ] `flutter analyze` sạch; `flutter test` xanh.
