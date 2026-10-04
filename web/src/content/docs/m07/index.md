---
title: "M07 — Điều hướng: Navigator push/pop"
description: Route stack, Navigator.of(context), MaterialPageRoute, push/pop — nút BẮT ĐẦU CHƠI mở màn hình game thật.
sidebar:
  label: Tổng quan M07
  order: 0
---

## Kết quả sau milestone này

Nút **BẮT ĐẦU CHƠI** cuối cùng làm đúng tên của nó: đẩy một `GameScreen`
lên trên menu. `GameScreen` M07 là bố cục quiz *tĩnh* (thẻ câu hỏi + 4 ô
trả lời + nút chốt bị vô hiệu) — bấm nút back trên AppBar quay về menu, và
trạng thái menu (EXP, counter, đồng hồ phiên) vẫn còn nguyên vì route menu
nằm yên *dưới* route game.

Đây là milestone "app thật" đầu tiên: từ một màn hình → hai màn hình.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [Route stack & Navigator.push](/m07/01-route-stack-va-push/) | Route là gì, stack mental model, `Navigator.of(context)`, `MaterialPageRoute`, `push` |
| 2 | [GameScreen & pop](/m07/02-game-screen-va-pop/) | Build màn hình game placeholder, `AppBar` back tự động, `pop`, cái gì còn sống dưới route mới |
| 3 | [Điều hướng của senior & checkpoint](/m07/03-senior-navigation-checkpoint/) | `AppNavigationController`, `navigatorKey`, tại sao học primitive trước |

## Khái niệm được giới thiệu

- **Flutter:** `Navigator`, `Navigator.of(context)`, `Navigator.push`,
  `Navigator.pop`, `Route<T>`, `MaterialPageRoute`, route `builder`,
  `AppBar` với nút back tự động, `maintainState` (khái niệm).
- **Dart:** `Route<T>` generic ở mức nhận biết; `push` trả về `Future`
  (nhận biết, chưa dùng).
- **Nhận biết nhưng chưa dùng:** `GlobalKey<NavigatorState>` — sẽ quay lại
  ở M19 cùng `AppNavigationController`.

## Tiêu chí hoàn thành

- Bấm BẮT ĐẦU CHƠI → `GameScreen` hiện lên trên menu.
- Bấm back (AppBar hoặc nút back hệ thống) → quay về menu đúng trạng thái
  cũ: counter giữ giá trị, đồng hồ phiên không reset về 0.
- Giải thích được `push` không phá route cũ — menu vẫn nằm trong stack.
- `flutter analyze` sạch; `flutter test` vẫn xanh (15 test);
  `flutter build web` build được.

## Tổng kết M07 — tự kiểm tổng hợp

- **Tôi học được gì?** `Navigator.push`/`pop`, route stack LIFO,
  `MaterialPageRoute`, `maybePop`/`canPop` (bài Tự làm).
- **Tôi giải thích được gì?** Vì sao menu giữ state khi pop về (route
  cũ không bị phá — chỉ bị che); vì sao senior dùng push/pop tường
  minh chứ không named routes.
- **Tôi viết được gì không copy?** Vẽ stack qua từng push/pop và dự
  đoán màn cuối; nút pop thứ hai trong body.
- **Nếu X đổi thì sao?** Push hai `GameScreen` liên tiếp — pop hai
  lần về đâu? (Menu — hai route là hai entry khác nhau trong stack.)
- **Concept cần lại sau:** `Navigator` — dialog M09 (`pop` với kết
  quả), navigation controller D20/M19+.
