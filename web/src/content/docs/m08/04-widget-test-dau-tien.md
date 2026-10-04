---
title: "Bài 4 · Widget test đầu tiên"
description: "testWidgets/WidgetTester/pumpWidget — render GameScreen thật trong test, find.text/find.byIcon, tester.tap, tester.pump, và test điều hướng menu→game→back."
sidebar:
  label: "Bài 4 · Widget test"
  order: 4
---

## Mục tiêu

Viết và chạy widget test đầu tiên: render `GameScreen` trong môi trường
test, tap đáp án, kiểm tra UI đổi — và thêm một test điều hướng
menu → game → back.

## Bạn đang ở đâu

- Milestone: **M08** (bài 4/4 — cuối milestone)
- App hiện tại: mini-quiz chơi được hoàn chỉnh; 18 unit/bank test xanh;
  chưa có test nào *render UI*.

## Vì sao việc này quan trọng ngay bây giờ

Unit test (M04) kiểm tra *hàm Dart*. Nhưng "tap ô 'StatefulWidget' rồi
thấy icon xanh" là *hành vi widget* — không unit test nào chạm được.
Flutter trả lời bằng **widget test**: một môi trường chạy cây widget
thật (không cần emulator) với đồng hồ ảo, cho phép "nhìn" và "bấm" UI
bằng code.

## Bạn đã biết gì

- `test()`/`group`/`expect`/matcher (M04); hành vi game vừa làm (bài 2–3);
  `MaterialApp`/`Scaffold`/`Icon` (M01–M02); `Future.delayed` + `mounted`
  (M05).

## Mental model mới

**Widget test = một khung hình Flutter thu nhỏ chạy trong test.**

```
testWidgets('…', (tester) async {
  await tester.pumpWidget(MaterialApp(home: GameScreen()));
  │      └─ "khởi động app thu nhỏ": build + layout + paint một frame
  │         vào bề mặt test (không cần device)
  │
  find.text('StatefulWidget')        ← "con mắt" dò widget trong cây
  tester.tap(...)                    ← "ngón tay" chạm vào tọa độ widget
  await tester.pump()                ← "cho chạy thêm một frame" —
  │                                    setState/animation cần frame mới
  │                                    để UI cập nhật
  expect(find.text('Chính xác!'), findsOneWidget)
})
```

Khác biệt nền tảng vs unit test:

|  | Unit test (M04) | Widget test (M08) |
| --- | --- | --- |
| Đối tượng | hàm/class Dart | cây widget Flutter |
| Vào ra | trả về giá trị | find/tap/expect trên cây |
| Môi trường | Dart thuần | Flutter test engine, đồng hồ ảo |
| File | `test/foo_test.dart` | `test/widgets/…` (quy ước) |

`pumpWidget` cần `MaterialApp` bọc ngoài khi widget dùng `Scaffold`,
`Icon`, `Text` direction… — `MaterialApp` cung cấp `Theme`,
`Directionality`, `Navigator` mà các widget con cần. Thiếu → lỗi
"No Material widget found" / "No Directionality". Đây là *wrapper bắt
buộc*, không phải boilerplate mù.

## Dart/Flutter cần dùng

| API | Vai trò |
| ----- | --------- |
| `testWidgets('…', (tester) async {…})` | Định nghĩa widget test; `tester` = `WidgetTester` |
| `tester.pumpWidget(widget)` | Render widget + chạy 1 frame đầu |
| `tester.pump()` | Chạy thêm 1 frame (sau `setState`/tap/animation) |
| `tester.pump(Duration)` | Nhảy đồng hồ ảo của test (rất cần cho `Future.delayed` — chi tiết M19) |
| `find.text('…')` | Tìm widget theo text |
| `find.byIcon(Icons.x)` | Tìm `Icon` theo icon data |
| `find.byType(T)` | Tìm theo kiểu widget |
| `tester.tap(finder)` | Chạm vào widget tìm được |
| `findsOneWidget`/`findsNothing`/`findsNWidgets(n)` | Matcher số lượng |

## Ví dụ độc lập — widget test tối thiểu

Trước khi test `GameScreen`, xem toàn bộ vòng đời một widget test trên
một widget 20 dòng (trong `test/`, hoặc DartPad không hỗ trợ test — đây
là ví dụ chạy bằng `flutter test`):

```dart
// widget dưới test:
class Counter extends StatefulWidget {
  const Counter({super.key});
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('$_count'),
      GestureDetector(
        onTap: () => setState(() => _count++),
        child: const Text('tăng'),
      ),
    ]);
  }
}

// test:
testWidgets('bấm tăng thì số đổi 0 → 1', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: Counter()));
  expect(find.text('0'), findsOneWidget);   // trạng thái đầu

  await tester.tap(find.text('tăng'));      // mô phỏng chạm
  await tester.pump();                      // cho build chạy lại

  expect(find.text('1'), findsOneWidget);   // trạng thái sau
});
```

Bốn động tác là toàn bộ nghề của widget test:

- `pumpWidget` — render cây widget vào môi trường test (không phải
  `runApp` — không có device).
- `find.text('0')` + `findsOneWidget` — "phải có đúng một widget hiển
  thị '0'": assert về **những gì người dùng thấy**, không assert field.
- `tester.tap` — chạm thật vào widget tìm được, kích hoạt `onTap`.
- `tester.pump()` — cho một frame chạy: `setState` đã lên lịch rebuild,
  `pump` là frame đó. Không `pump` → UI trong test không đổi (giống
  hệt việc quên `setState` trong app!).

## Android / Compose bridge

- SIMILARITY: `tester.tap(find.text(…))` ≈ `onNodeWithText().performClick()`
  trong Compose UI test.
- IMPORTANT DIFFERENCE: widget test Flutter chạy trong *môi trường test
  của chính framework* với đồng hồ ảo — không phải instrumentation test
  trên thiết bị; nhanh hơn nhiều nhưng không cover platform thật.
- DO NOT ASSUME: `pump()` = đợi thời gian thật — nó kích *một frame*;
  `Future.delayed`/`Timer` chỉ chạy khi `pump(duration)` nhảy đồng hồ ảo.

## Senior project connection

- `flutter-accelerator-ai/test/widgets/game_answer_option_test.dart` —
  senior cũng test ô đáp án bằng widget test (tap → state đổi màu).
- `test/helpers/` của senior — file test dùng chung; course sẽ tới khi
  cần (M29 hygiene), giờ một file test đủ rõ.

## Build it step by step

### Bước 1 — File test + helper pump

```dart
// test/widgets/game_screen_test.dart — FILE MỚI
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_millionaire_course/data/game/quiz_questions.dart';
import 'package:ai_millionaire_course/screens/game_screen.dart';
import 'package:ai_millionaire_course/screens/menu_screen.dart';

void main() {
  /// Helper: pump GameScreen dưới MaterialApp — bắt buộc vì GameScreen
  /// dùng Scaffold/AppBar/Icon cần Theme + Directionality.
  Future<void> pumpGameScreen(WidgetTester tester) {
    return tester.pumpWidget(const MaterialApp(home: GameScreen()));
  }
}
```

- `Future<void>` + `async`/`await` — y hệt M05; test body là async vì
  `pump`/`tap` trả `Future`.

### Bước 2 — Test render

```dart
testWidgets('hiển thị câu hỏi đầu tiên, chỉ số câu và 4 đáp án',
    (tester) async {
  await pumpGameScreen(tester);

  expect(find.text(quizQuestions[0].question), findsOneWidget);
  expect(find.text('Câu 1/${quizQuestions.length}'), findsOneWidget);
  for (final option in quizQuestions[0].options) {
    expect(find.text(option), findsOneWidget);
  }
  expect(find.text('CHỐT ĐÁP ÁN'), findsOneWidget);
});
```

Test đọc *dữ liệu bank* thay vì chép chuỗi — đổi câu hỏi không phải sửa test.

### Bước 3 — Test chọn + chốt + tiếp (luồng hành vi)

```dart
testWidgets('tap đáp án → icon radio được chọn xuất hiện', (tester) async {
  await pumpGameScreen(tester);
  await tester.tap(find.text('StatefulWidget'));
  await tester.pump();                       // frame sau setState
  expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
});

testWidgets('chọn đúng + chốt → "Chính xác!" + icon check', (tester) async {
  await pumpGameScreen(tester);
  await tester.tap(find.text('StatefulWidget'));   // đáp án đúng câu 1
  await tester.pump();
  await tester.tap(find.text('CHỐT ĐÁP ÁN'));
  await tester.pump();
  expect(find.text('Chính xác!'), findsOneWidget);
  expect(find.byIcon(Icons.check_circle), findsOneWidget);
  expect(find.text('TIẾP'), findsOneWidget);
});

testWidgets('TIẾP → sang câu 2, reset lựa chọn', (tester) async {
  await pumpGameScreen(tester);
  await tester.tap(find.text('StatefulWidget'));
  await tester.pump();
  await tester.tap(find.text('CHỐT ĐÁP ÁN'));
  await tester.pump();
  await tester.tap(find.text('TIẾP'));
  await tester.pump();
  expect(find.text('Câu 2/${quizQuestions.length}'), findsOneWidget);
  expect(find.text(quizQuestions[1].question), findsOneWidget);
  expect(find.byIcon(Icons.radio_button_checked), findsNothing);
});
```

### Bước 4 — Test điều hướng (menu → game → back)

```dart
testWidgets('menu → game → back: route stack push/pop hoạt động',
    (tester) async {
  await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
  // MenuScreen tải profile 900ms (M05): nhảy đồng hồ ảo của test để
  // Future hoàn thành — bản xem trước của pump(Duration), đầy đủ ở M19.
  await tester.pump(const Duration(seconds: 1));

  await tester.tap(find.text('BẮT ĐẦU CHƠI'));
  await tester.pump();                                  // bắt đầu transition
  await tester.pump(const Duration(milliseconds: 400));  // transition xong
  expect(find.text('Phòng chơi'), findsOneWidget);

  await tester.tap(find.byType(BackButton));            // nút ← của AppBar
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.text('BẮT ĐẦU CHƠI'), findsOneWidget);

  // Dọn đuôi: gỡ cây widget → MenuScreen.dispose → huỷ subscription
  // ticker — không để Timer/Stream pending lúc test kết thúc.
  await tester.pumpWidget(const SizedBox());
});
```

Hai chi tiết mới dùng mà không dạy sâu:

- `pump(Duration)` — đồng hồ ảo của test nhảy thời gian; đủ để hiểu ở đây
  là "vượt qua delay 900ms" và "chạy xong transition ~300ms".
- `pumpWidget(const SizedBox())` — thay toàn bộ cây bằng widget rỗng →
  mọi State `dispose` → stream/timer dọn sạch. Test để nguyên cây có
  periodic-stream sẽ bị `flutter_test` bắt lỗi "Timer still pending".

### Bước 5 — Test integrity của bank (unit test bổ sung)

```dart
// test/quiz_questions_test.dart — FILE MỚI (unit test, không pump)
test('mọi câu đều có ít nhất 2 đáp án', () { … });
test('correctIndex luôn nằm trong phạm vi options', () { … });
test('có từ 3 đến 5 câu (đúng phạm vi mini-quiz)', () { … });
```

Bank là dữ liệu const — lỗi cấu hình (correctIndex=9) compile không báo;
unit test soi được ngay.

## Hiểu code — lifecycle của một widget test

`pumpWidget` → `GameScreen` build → `initState` chạy → frame đầu render.
`tester.tap` → đặt tap event vào tọa độ tâm widget → widget `onTap` chạy →
`setState` đánh dấu dirty → `tester.pump()` → frame mới → `find`/`expect`
nhìn cây mới. Không `pump` giữa tap và expect → test nhìn thấy *UI cũ* —
lỗi kinh điển của người mới.

## Chạy và quan sát

```bash
flutter test                        # tất cả: 15 cũ + 3 bank + 6 widget
                                    # (5 bài này + 1 bài Tự làm)
flutter test test/widgets/          # chỉ widget tests
```

- Thấy `[MenuScreen] initState — …` và `dispose` trong output test
  navigation — `debugPrint` từ M03 vẫn hoạt động trong test.
- Test thất bại điển hình: `findsNothing` cho text → kiểm tra chuỗi khớp
  *chính xác* (dấu, hoa/thường) hoặc widget chưa render (thiếu pump).

## Lỗi hay gặp

1. **Quên `pump()` sau `tap`** — expect chạy trên frame cũ → fail dù code
   đúng. Mọi thay đổi state cần một `pump`.
2. **`pumpWidget(GameScreen())` không bọc `MaterialApp`** — Scaffold/Icon
   lỗi ngay. Luôn bọc khi widget dùng Material widgets.
3. **Test để timer/stream pending** — `MenuScreen` có periodic ticker;
   kết thúc test mà không `pumpWidget(SizedBox())` sẽ báo "A Timer is
   still pending". Dọn đuôi là một phần của test có stream/timer.
4. **`pumpAndSettle` mọi nơi** — với periodic stream/timer nó không bao
   giờ "settle" (cứ có frame mới). Dùng `pump()`/`pump(duration)` chủ động
   — `pumpAndSettle` chỉ an toàn khi không có periodic còn sống.

## Kiểm tra hiểu biết

1. Vì sao `pumpWidget` cần `MaterialApp`? — *Widget con cần `Theme`,
   `Directionality`, `Navigator` — chúng sống trong `MaterialApp`.*
2. `tap` → `setState` → chưa `pump` → `find` thấy gì? — *Cây widget
   frame cũ — UI mới chỉ tồn tại sau frame kế.*
3. Test navigation pump `Duration(seconds: 1)` để làm gì? — *Nhảy đồng hồ
   ảo cho `Future.delayed(900ms)` của M05 hoàn thành, menu render xong.*

## Tự làm

**Tự viết widget test — không copy.** Viết **một** test mới trong
`test/widgets/` (file mới `menu_play_button_test.dart` hoặc thêm vào
file hiện có):

- Pump `MenuScreen` bọc `MaterialApp`, rồi `pump(const Duration(seconds:
  1))` để vượt delay profile 900ms — y hệt test navigation ở Bước 4.
- Tap nút chơi bằng `tester.tap(find.text('BẮT ĐẦU CHƠI'))` + `pump()` +
  `pump(const Duration(milliseconds: 400))` cho transition xong —
  `pumpAndSettle` không dùng được ở đây ("Lỗi hay gặp" #4).
- Assert thứ gì đó **đổi** sau tap — widget của GameScreen xuất hiện
  (`'Phòng chơi'`, `'CHỐT ĐÁP ÁN'`, câu hỏi đầu…) — rồi dọn đuôi bằng
  `pumpWidget(const SizedBox())`.
- Dự đoán: nếu `onPressed` của nút là `null`, `tester.tap` có throw
  không? `find.text` trả gì?

:::note[Gợi ý]
`tester.tap` trên widget disabled vẫn chạy nhưng `onPressed` không bắn —
assert phải kiểm *kết quả*, không chỉ "tap không crash".
:::

<details><summary><strong>Đáp án</strong></summary>

```dart
testWidgets('tap BẮT ĐẦU CHƠI mở GameScreen', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
  await tester.pump(const Duration(seconds: 1));   // vượt delay profile (M05)

  await tester.tap(find.text('BẮT ĐẦU CHƠI'));
  await tester.pump();                             // bắt đầu transition
  await tester.pump(const Duration(milliseconds: 400)); // transition xong

  expect(find.text('Phòng chơi'), findsOneWidget);   // AppBar của game
  expect(find.text('CHỐT ĐÁP ÁN'), findsOneWidget);  // GameScreen đã render

  await tester.pumpWidget(const SizedBox());        // huỷ ticker của menu
});
```

`tap` trên disabled widget: gesture vẫn dispatch nhưng callback null →
không push → `findsOneWidget` fail — đó là cách test "nút bị vô hiệu".
</details>

## Ta cố ý chưa thêm

- `tester.pump(duration)` cho Timer của game — **M09** mới có Timer; kỹ
  thuật virtual-time đầy đủ ở M19.
- Golden test (ảnh snapshot), `integration_test`, fake clock package —
  không nằm trong lộ trình widget-test cơ bản.
- Mock/fake repository — chưa có repository (M14) nên chưa cần.

## Checkpoint hoàn thành

- [ ] `test/widgets/game_screen_test.dart`: 6 test — render, select,
  correct-feedback, next-question, navigation push/pop, và test mở
  game của bài Tự làm.
- [ ] `test/quiz_questions_test.dart`: 3 test integrity bank.
- [ ] `flutter test` xanh **24/24**; `flutter analyze` sạch;
  `flutter build web` build được.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m08/04 — "Widget test đầu tiên" (bài cuối M08 — mini-quiz + widget test + bank integrity).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test` (có thể `flutter test test/widgets/` và `flutter test test/quiz_questions_test.dart` riêng). Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Trọng tâm: test ĐÚNG cơ chế (pumpWidget bọc MaterialApp, tap→pump, dọn đuôi periodic stream) và toàn bộ suite XANH.

EXPECTED STATE SAU BÀI NÀY:
- `test/widgets/game_screen_test.dart` tồn tại (STRICT path — widget test theo quy ước `test/widgets/`) với `testWidgets(...)` tests dùng helper `pumpGameScreen(tester)` trả `tester.pumpWidget(const MaterialApp(home: GameScreen()))` (STRICT bọc MaterialApp — bài giải thích vì sao bắt buộc).
- ~5–6 test kiểm chứng hành vi: render câu đầu + 'Câu 1/N' + 4 options + 'CHỐT ĐÁP ÁN'; tap 'StatefulWidget' → `find.byIcon(Icons.radio_button_checked)` findsOneWidget; chọn đúng + chốt → 'Chính xác!' + check_circle + 'TIẾP'; TIẾP → 'Câu 2/N' + reset icon; menu→game→back pump `MaterialApp(home: MenuScreen())` với `pump(const Duration(seconds: 1))` vượt delay profile (STRICT: mọi tap đều có `pump` sau; test navigation dọn đuôi bằng `pumpWidget(const SizedBox())` — STRICT vì ticker periodic của menu sẽ để "Timer still pending").
- `test/quiz_questions_test.dart` tồn tại: ~3 test integrity bank (≥2 options/câu, correctIndex trong phạm vi, số câu 3–5) — pure unit test, không pump (STRICT file).
- Nếu learner làm bài Tự làm: thêm `menu_play_button_test.dart` hoặc 1 test tương đương — chấp nhận.
- `flutter test` → "All tests passed!" ~24 (15 cũ + 3 bank + 6 widget); `flutter analyze` → "No issues found!"; `flutter build web` → thành công.
- KHÔNG có `pumpAndSettle` trong test có periodic stream sống (bài giải thích nó không bao giờ settle) — `pump()`/`pump(duration)` là đúng.

INVARIANTS NỀN:
- Mini-quiz chơi được của M08 bài 2–3; route M07; menu + async M05–M06; `UserProfileData` + 10 test model vẫn xanh.

Mục (STRICT) phải đúng; mục khác chấm semantic (tên test, tổ chức group). Code vượt checkpoint (đã có golden test/mock/fake repo) → `AHEAD_COMPATIBLE`; thiếu bắt buộc (test đỏ, thiếu file, test không dọn đuôi) → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m08/04
PROJECT_ALIGNMENT: ON_TRACK | NEEDS_FIX | DIVERGED | BLOCKED
COURSE_POSITION: ON_TRACK | BEHIND | AHEAD_COMPATIBLE | AHEAD_RISKY
READY_FOR_NEXT_LESSON: YES | YES_AFTER_FIXES | NO
VERIFICATION_PERFORMED:
WHAT_MATCHES:
GAPS:
AHEAD_OF_COURSE:
DIVERGENCES:
REQUIRED_FIXES_BEFORE_CONTINUING:
EVIDENCE: file/symbol → observation
FILES_MODIFIED_BY_REVIEW: NONE
```
