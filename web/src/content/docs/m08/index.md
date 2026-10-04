---
title: "M08 — Mini-quiz & widget test đầu tiên"
description: QuizQuestion model, ngân hàng câu hỏi const, chọn/chốt/tiếp bằng setState, enum trạng thái đáp án, và testWidgets đầu tiên.
sidebar:
  label: Tổng quan M08
  order: 0
---

## Kết quả sau milestone này

`GameScreen` biến từ layout tĩnh thành **mini-quiz chơi được**: 4 câu hỏi
về đúng các khái niệm đã học — chạm đáp án để chọn (icon radio), bấm
**CHỐT ĐÁP ÁN** để xem đúng/sai (xanh/đỏ), bấm **TIẾP** sang câu tiếp, hết
câu thì hiện màn kết quả "Đúng X/4 câu" với nút **CHƠI LẠI**.

Đồng thời đây là milestone test thứ hai: sau unit test (M04), giờ là
**widget test** — render widget thật trong môi trường test và tương tác
với nó như người dùng.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [QuizQuestion & ngân hàng câu hỏi](/m08/01-quiz-question-model/) | Model câu hỏi bất biến, `List<String> options`, `correctIndex`, bank `const` |
| 2 | [State của quiz & enum trạng thái](/m08/02-quiz-state-va-enum/) | `GameScreen` → `StatefulWidget`; `_selectedIndex` nullable; enum `_AnswerVisualState`; khoá chọn sau chốt |
| 3 | [Render danh sách & luồng tiếp](/m08/03-render-options-va-flow/) | Collection-`for` trong list literal, `String.fromCharCode`, select→submit→next, panel kết quả |
| 4 | [Widget test đầu tiên](/m08/04-widget-test-dau-tien/) | `testWidgets`, `WidgetTester`, `pumpWidget`, `MaterialApp` wrapper, `find`, `tap`, `pump`, `expect` |

## Khái niệm được giới thiệu

- **Dart:** `enum` (dùng làm trạng thái UI), collection-`for`/`...` trong
  list literal, `String.fromCharCode`, `int?` cho "chưa chọn".
- **Flutter:** `testWidgets`, `WidgetTester`, `pumpWidget`, `find.text`,
  `find.byIcon`, `tester.tap`, `tester.pump`, `findsOneWidget`/
  `findsNothing`, nút vô hiệu bằng `onTap: null` + `Opacity`.
- **Kiến trúc:** model-driven UI — UI chỉ "vẽ theo state", logic chọn
  (`_optionState`) gom một chỗ.

## Tiêu chí hoàn thành

- Quiz 4 câu chơi trọn vẹn: chọn → chốt → feedback → tiếp → kết quả.
- Đáp án đúng luôn hiện xanh sau chốt; sai thì ô sai đỏ + ô đúng xanh.
- `flutter test` xanh gồm cả `test/widgets/game_screen_test.dart`
  (6 widget test mới) và test integrity của bank.
- Vẫn chưa có Timer/dialog — đó là M09.

## Tổng kết M08 — tự kiểm tổng hợp

- **Tôi học được gì?** `testWidgets`/`WidgetTester`, `find.byType/
  byText`, `tap`+`pump`, model `QuizQuestion`/`GameResult`.
- **Tôi giải thích được gì?** Widget test không chạy device —
  `pump()` điều khiển frame tay; `findsOneWidget` assert cây render.
- **Tôi viết được gì không copy?** Một widget test tap CHƠI và assert
  route mới xuất hiện qua `NavigatorObserver` (bài Tự làm).
- **Nếu X đổi thì sao?** `onPressed: null` — `tester.tap` có throw
  không? (Không — gesture dispatch nhưng callback null; assert kết
  quả mới là chỗ bắt.)
- **Concept cần lại sau:** `WidgetTester`/`pump`/`pumpAndSettle` —
  M09 dialog, M14 stream-propagation test; `findsOneWidget` — mọi
  widget test sau.
