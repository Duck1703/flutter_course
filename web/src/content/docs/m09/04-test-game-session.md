---
title: "Bài 4 · Test phiên game có Timer"
description: "Widget test cho game có Timer.periodic và dialog: pump(Duration) nhảy đồng hồ ảo, assert route stack, và một lỗi layout thật mà test bắt được."
sidebar:
  label: "Bài 4 · Test phiên game"
  order: 4
---

## Mục tiêu

Viết widget test cho trọn một phiên game: timeout tự kết thúc, dialog
kết quả, CHƠI LẠI reset, victory path, và VỀ MENU pop hai route — đồng
thời nhìn thấy widget test **bắt được một lỗi layout thật**.

## Bạn đang ở đâu

- Milestone: **M09** (bài 4/4 — cuối milestone)
- App hiện tại: ván game hoàn chỉnh (bài 1–3); file test M08 đã có 6
  test, cần thêm 4 test M09 và hai helper mới.

## Vì sao việc này quan trọng ngay bây giờ

Game có `Timer.periodic` + dialog + hai route — test phải giải quyết ba
vấn đề mới: **thời gian ảo** (không ai chờ 15 giây thật trong test),
**dọn tài nguyên** (Timer pending khiến test framework báo lỗi), và
**animation nối tiếp** (hai pop chạy lần lượt, không song song). Nếu
không học ở đây, mọi màn hình có timer/dialog sau này đều "không test
được".

## Bạn đã biết gì

- `testWidgets`, `pumpWidget`, `find`, `tap`, `pump()`, `expect`
  (M08 bài 4); `MenuScreen` loader 900ms (M05); route push/pop (M07).

## Mental model mới

**`tester.pump(Duration)` = du hành thời gian.** Test chạy trong đồng
hồ ảo (fake async): `pump(Duration(seconds: 16))` nhảy thời gian mô
phỏng 16 giây — `Timer.periodic` chạy đủ các tick trong tíc-tắc, không
chờ thật.

**Mọi thứ "có vòng đời" phải được dọn trước khi test kết thúc.** Một
`Timer` còn sống khi test xong → framework báo *"A Timer is still
pending"*. Cách dọn gọn: pump một cây rỗng → mọi `State` bị dispose →
`dispose()` tự hủy timer/subscription:

```dart
Future<void> unmount(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox());
```

`dispose` đúng (bài 1) chính là thứ cho phép test chạy sạch — test này
gián tiếp verify `dispose` viết đúng.

**pop route ≠ tức thì.** Dialog pop (~150ms) xong thì route game mới
bắt đầu reverse (~300ms) — **nối tiếp**, không song song. Assert "đã về
menu" cần pump đủ cả hai (~450ms+); pump quá ngắn sẽ thấy màn game vẫn
đang thoát → test fail dù code đúng.

## Dart/Flutter cần dùng

| API | Ví dụ | Nghĩa |
|-----|-------|-------|
| `tester.pump(Duration)` | `await tester.pump(const Duration(seconds: 16))` | Nhảy thời gian ảo → Timer tick |
| `pumpWidget(SizedBox())` | `await unmount(tester)` | Gỡ cây → dispose mọi State |
| `find.textContaining` | `find.textContaining('Đúng 4/4 câu')` | Khớp *một phần* text — cần khi text nằm trong chuỗi nhiều dòng |
| helper nội test | `answerCorrectly(tester, i)` | Hàm `Future<void>` bên trong `main()` — tái dùng chuỗi tap |

## Android / Compose bridge

- SIMILARITY: `pump(Duration)` ≈ `composeTestRule.mainClock.advanceTimeBy`
  — cùng ý tưởng fake clock cho test.
- DO NOT ASSUME: pending `Timer`/`Stream` sau test là "cảnh báo nhẹ" —
  flutter_test coi nó là lỗi. Tài nguyên không dọn = test đỏ.

## Senior project connection

- `flutter-accelerator-ai/test/widgets/` — senior cũng test dialog và
  flow bằng `testWidgets`; các test timer ở senior đi qua ViewModel
  (fake clock trong reducer). Ta test trực tiếp vì state nằm trong
  widget — khi VM xuất hiện (M11+), phần test "thuần logic" sẽ tách ra.

## Build it step by step

### Bước 1 — Helper chung mới: `unmount`

```dart
// test/widgets/game_screen_test.dart — trong main(), THÊM:
/// Gỡ cây widget để dispose mọi State — dọn timer/stream pending
/// trước khi test kết thúc (GameScreen có Timer.periodic).
Future<void> unmount(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox());
```

Và **mọi test cũ** (M08) thêm `await unmount(tester);` ở cuối — GameScreen
giờ có Timer, không dọn thì test M08 cũ cũng đỏ.

### Bước 2 — Test game over qua đáp án sai

```dart
testWidgets('chốt sai → TIẾP → dialog KẾT THÚC (game over)', (tester) async {
  await pumpGameScreen(tester);

  await tester.tap(find.text('StatelessWidget')); // đáp án sai câu 1
  await tester.pump();
  await tester.tap(find.text('CHỐT ĐÁP ÁN'));
  await tester.pump();
  // Phase revealing: ô sai đỏ + ô đúng xanh, nút đổi thành TIẾP.
  expect(find.byIcon(Icons.cancel), findsOneWidget);

  await tester.tap(find.text('TIẾP'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300)); // dialog transition

  expect(find.text('KẾT THÚC'), findsOneWidget);
  expect(find.textContaining('Đáp án chưa đúng'), findsOneWidget);
  expect(find.text('CHƠI LẠI'), findsOneWidget);
  expect(find.text('VỀ MENU'), findsOneWidget);
  await unmount(tester);
});
```

`pump(300ms)` sau khi mở dialog — dialog có entrance animation; tap nút
ngay khi chưa hiện hẳn có thể miss (hit-test đập vào barrier).

### Bước 3 — Test timeout bằng đồng hồ ảo

```dart
testWidgets('hết giờ → dialog HẾT GIỜ! (timeout game over)',
    (tester) async {
  await pumpGameScreen(tester);

  // Nhảy đồng hồ ảo 16s — vượt qua 15s/câu; Timer.periodic tick trong
  // fake-async và đến 0 → _finish(timeout) → dialog. (Kỹ thuật
  // pump(Duration) đầy đủ sẽ học ở M19.)
  await tester.pump(const Duration(seconds: 16));

  expect(find.text('HẾT GIỜ!'), findsOneWidget);
  await unmount(tester);
});
```

Không một cú tap nào — chỉ thời gian chạy. Đây là test nhỏ nhất mà mạnh
nhất: nó chứng minh `Timer` thật sự được nối vào phase machine.

### Bước 4 — Test victory qua helper `answerCorrectly`

Trước test victory, thêm **một helper nữa** vào `main()` — chuỗi "tap
đáp án đúng + CHỐT" lặp lại mọi câu nên tách ra cho gọn:

```dart
// test/widgets/game_screen_test.dart — trong main(), THÊM:
/// Tap đáp án đúng của câu `i` rồi CHỐT — đọc đáp án từ bank
/// (`correctIndex`), không hard-code text: đổi nội dung câu hỏi
/// vẫn chạy đúng.
Future<void> answerCorrectly(WidgetTester tester, int i) async {
  final q = quizQuestions[i];
  await tester.tap(find.text(q.options[q.correctIndex]));
  await tester.pump();
  await tester.tap(find.text('CHỐT ĐÁP ÁN'));
  await tester.pump();
}
```

```dart
testWidgets('trả lời đúng hết → dialog CHIẾN THẮNG!', (tester) async {
  await pumpGameScreen(tester);

  for (var i = 0; i < quizQuestions.length; i++) {
    await answerCorrectly(tester, i);
    // Câu cuối: nút là XEM KẾT QUẢ; các câu trước là TIẾP.
    final nextLabel = i == quizQuestions.length - 1 ? 'XEM KẾT QUẢ' : 'TIẾP';
    await tester.tap(find.text(nextLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  expect(find.text('CHIẾN THẮNG!'), findsOneWidget);
  // 'N/N' trần trùng với counter 'Câu N/N' phía sau dialog — khớp nguyên
  // cụm 'Đúng N/N câu' để chắc chắn đó là text kết quả của dialog.
  expect(
      find.textContaining(
          'Đúng ${quizQuestions.length}/${quizQuestions.length} câu'),
      findsOneWidget);
  await unmount(tester);
});
```

Helper `answerCorrectly` đọc đáp án đúng từ bank qua `correctIndex`
thay vì hard-code text — test chịu được đổi nội dung câu hỏi.

### Bước 5 — Test VỀ MENU pop hai route

```dart
testWidgets('VỀ MENU từ dialog → pop dialog lẫn game, về menu',
    (tester) async {
  await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
  await tester.pump(const Duration(seconds: 1)); // qua loader M05
  await tester.tap(find.text('BẮT ĐẦU CHƠI'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));

  // Sai → TIẾP → dialog → VỀ MENU.
  await tester.tap(find.text('StatelessWidget'));
  await tester.pump();
  await tester.tap(find.text('CHỐT ĐÁP ÁN'));
  await tester.pump();
  await tester.tap(find.text('TIẾP'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text('VỀ MENU'));
  await tester.pump();
  // Hai pop chạy nối tiếp: dialog tắt (~150ms) rồi route game mới bắt
  // đầu reverse (~300ms) — pump đủ dài cho cả hai animation.
  await tester.pump(const Duration(milliseconds: 800));

  // Cả hai route (dialog + game) đã pop — menu hiện lại nguyên trạng.
  expect(find.text('KẾT THÚC'), findsNothing);
  expect(find.text('Phòng chơi'), findsNothing);
  expect(find.text('BẮT ĐẦU CHƠI'), findsOneWidget);
  await unmount(tester);
});
```

### Bước 6 — Bug thật mà test này bắt được: overflow

Viết xong test victory, `flutter test` báo
`A RenderFlex overflowed by 7.0 pixels` ở `Column` của `_QuizBody`: body
M08 dùng `Spacer()` để đẩy nút xuống đáy — khi `FeedbackLine` xuất hiện
(cộng thêm ~30px), nội dung vượt viewport → nút bị đẩy ra ngoài vùng
hit-test → `tap('TIẾP')` miss → toàn chuỗi sau đó fail.

Fix đúng bản chất (không phải giảm padding cho đủ chỗ): **vùng nội dung
cuộn được, nút luôn ghim đáy**:

```dart
// _QuizBody.build — THAY Spacer():
const SizedBox(height: MenuTokens.spacingXs),
// Vùng nội dung co giãn: màn thấp thì cuộn, nút bấm luôn ghim đáy.
// (Spacer + Column không cuộn được — overflow khi nội dung cao.)
Expanded(
  child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuestionCard(text: question.question),
        const SizedBox(height: MenuTokens.spacingMd),
        for (var i = 0; i < question.options.length; i++) ...[
          _AnswerOption(
            label: String.fromCharCode(65 + i),
            text: question.options[i],
            state: _optionState(i),
            onTap: () => onSelect(i),
          ),
          const SizedBox(height: MenuTokens.spacingXs),
        ],
        if (revealed && selectedIndex != null)
          _FeedbackLine(
            isCorrect: question.isCorrect(selectedIndex!),
          ),
      ],
    ),
  ),
),
_SubmitButton(/* … */),
```

`Expanded` cho vùng cuộn chiếm mọi chỗ còn lại; `SingleChildScrollView`
bên trong hứng overflow thay vì để nó văng lỗi. Đây là pattern bạn sẽ
gặp liên tục: **header cố định — body cuộn — footer ghim**.

## Hiểu code

- `unmount` phải gọi **cuối mọi test** chạm `GameScreen`/`MenuScreen` —
  kể cả test đã pass hết assert. Test framework kiểm pending timer *sau*
  test body; dispose đúng lúc giữ test sạch.
- Test victory pump 300ms *mỗi vòng lặp* — đủ cho dialog ở vòng cuối
  hiện hẳn trước khi assert.
- Test 'Phòng chơi' `findsNothing` sau VỀ MENU là assert **route-level**:
  finder đọc AppBar của route game; còn thấy nghĩa là route còn sống.

## Chạy và quan sát

- `flutter test` — 28 test xanh (M04–M09): unit test bank + profile +
  ticker, widget test menu flow + toàn phiên game.
- Nếu một test timer báo `A Timer is still pending` — tìm chỗ quên
  `unmount` (hoặc `dispose` thiếu `cancel()`).

## Lỗi hay gặp

1. **Quên `await unmount(tester)`** — `Pending timers` fail test dù
   assert đúng hết.
2. **Tap vào dialog khi animation chưa xong** — tap miss im lặng
   (`warnIfMissed` chỉ là warning) → assert sau fail khó hiểu. Pump đủ
   transition trước khi tap.
3. **`find.text` cho chuỗi nằm trong text nhiều dòng** — `find.text`
   khớp *nguyên widget*; dùng `textContaining` và chọn cụm đủ đặc trưng
   ('Đúng 4/4 câu' chứ không '4/4' trần — trùng counter "Câu 4/4").
4. **Assert route đã pop khi reverse animation chưa hết** — hai pop
   nối tiếp cần ~450ms+; pump ngắn thấy màn cũ đang thoát.

## Kiểm tra hiểu biết

1. Vì sao test timeout chỉ `pump(16s)` mà không cần tap gì? — *Timer là
   fake-async: pump nhảy thời gian mô phỏng, tick 1s×16 chạy đủ →
   `_finish(timeout)` tự gọi.*
2. `unmount` khác gì với chỉ `dispose` thủ công? — *`pumpWidget` cây
   rỗng khiến framework *dispose đúng* mọi State — đúng quy trình
   unmount thật, gồm cả route/Navigator phía trên.*
3. `textContaining('Đúng 4/4 câu')` khớp được nếu text widget là
   `'Bạn trả lời đúng tất cả!\nĐúng 4/4 câu'`? — *Có: containing chỉ cần
   substring; ngược lại `find.text('Đúng 4/4 câu')` sẽ miss vì không
   bằng nguyên chuỗi.*

## Tự làm

**Debug — tìm bug, không copy.** Đoạn code này đã commit vào
`GameScreen` (giả tưởng — không cần gõ):

```dart
class _GameScreenState extends State<GameScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _remaining--);   // giả tưởng field _remaining tồn tại
    });
  }

  // dispose() KHÔNG hủy _timer
}
```

1. Bug là gì? Chạy `GameScreen`, pop về Menu, chờ 2 giây — console in
   lỗi gì?
2. Fix ở `dispose()` hay `initState()`? Viết 1 dòng fix.
3. Nếu `_timer.cancel()` được gọi *trước* `super.dispose()` hay sau?
   Thứ tự có quan trọng không?

:::note[Gợi ý]
`Timer.periodic` không tự dừng khi widget chết — nó không biết widget
tồn tại. Chủ sở hữu phải hủy.
:::

<details><summary><strong>Đáp án</strong></summary>

1. `setState() called after dispose()` — timer còn tick sau khi `State`
   bị dispose → gọi `setState` trên State chết.
2. Fix ở `dispose()`: `_timer?.cancel();` trước `super.dispose()`.
3. Gọi **trước** `super.dispose()` — `super.dispose()` phải là lệnh cuối
   (quy ước Dart: cleanup của mình trước, super sau). Thứ tự quan trọng:
   nếu `super.dispose` chạy trước, object đã "chết" khi cancel timer —
   dù `cancel` an toàn, convention đặt super cuối để nhất quán.

Đây là pattern "chủ sở hữu hủy resource" giống `StreamSubscription`
(M06) và `StreamSubscription` trong ViewModel (M14).
</details>

## Ta cố ý chưa thêm

- `pumpAndSettle` — hiện tại menu có `Stream.periodic` chạy vô hạn, dùng
  nó sẽ treo test; giới thiệu đúng lúc khi làm màn không có stream
  nền.
- Golden test (chụp ảnh so pixel) — công cụ riêng, milestone sau.
- Mock/bô lại Timer bằng fakeAsync — `package:fake_async` là chi tiết
  M19; `pump(Duration)` trên widget test đủ cho M09.

## Checkpoint hoàn thành

- [ ] `test/widgets/game_screen_test.dart` có đủ: first-question render,
  select/submit feedback, next-question, menu↔game route, game-over,
  restart, victory, timeout, back-to-menu.
- [ ] Mọi test đều `unmount` cuối cùng.
- [ ] `flutter test` — 28/28 xanh; `flutter analyze` sạch.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m09/04 — "Test phiên game có Timer" (bài cuối M09 — widget test cho toàn phiên game + fix overflow).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter test test/widgets/game_screen_test.dart`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Trọng tâm: thời gian ảo (`pump(Duration)`), dọn Timer pending (`unmount`), và assert route sau animation nối tiếp.

EXPECTED STATE SAU BÀI NÀY:
- `test/widgets/game_screen_test.dart` có helper `Future<void> unmount(WidgetTester tester) => tester.pumpWidget(const SizedBox());` và **MỌI test chạm GameScreen/MenuScreen kết thúc bằng `await unmount(tester)`** (STRICT — Timer pending = "A Timer is still pending").
- ~4 test M09 mới: (a) chốt sai→TIẾP→'KẾT THÚC' + 'Đáp án chưa đúng' + CHƠI LẠI + VỀ MENU (có `pump(300ms)` cho dialog transition); (b) `pump(const Duration(seconds: 16))` không tap → 'HẾT GIỜ!' (STRICT timeout qua đồng hồ ảo — chứng minh Timer thật nối phase machine); (c) victory qua helper `answerCorrectly(tester, i)` đọc `quizQuestions[i].options[q.correctIndex]` (STRICT đọc đáp án từ bank, không hard-code) + nút 'XEM KẾT QUẢ' câu cuối → 'CHIẾN THẮNG!' + `find.textContaining('Đúng N/N câu')` (STRICT textContaining — 'N/N' trần trùng counter); (d) menu→game→sai→VỀ MENU với `pump(800ms)` cho hai pop nối tiếp → 'KẾT THÚC'+'Phòng chơi' findsNothing, 'BẮT ĐẦU CHƠI' findsOneWidget (STRICT route-level assert + đủ thời gian animation).
- `_QuizBody` đã fix overflow: vùng nội dung (question card + options + feedback) bọc `Expanded(child: SingleChildScrollView(child: Column(...)))`, `_SubmitButton` ghim đáy (STRICT pattern header–scroll–footer; `Spacer` cũ đã thay).
- `flutter test` → "All tests passed!" ~28/28; `flutter analyze` → "No issues found!".
- KHÔNG có `pumpAndSettle` trong test có Timer/stream sống (không bao giờ settle); KHÔNG `find.text` cho chuỗi nằm trong text nhiều dòng (dùng textContaining).

INVARIANTS NỀN:
- Game hoàn chỉnh M09 bài 1–3 (phase machine, timer, dialog); test M08 + menu/profile/bank test vẫn xanh; chưa có golden test/fakeAsync package/mock repo.

Mục (STRICT) phải đúng; mục khác chấm semantic (tên test, số lượng chính xác). Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc (test đỏ, quên unmount, overflow còn) → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m09/04
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
