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
