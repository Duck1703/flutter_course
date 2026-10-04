## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m13/03 — "SnackBar event & test" (bài cuối M13 — chứng minh toàn kênh event bằng VM test + widget test; kèm retire các scaffold cũ).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter test test/menu_ui_events_test.dart`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. LƯU Ý QUAN TRỌNG: sau M13 ba scaffold chỉ-của-course đã RETIRE — `_soundOn`, `_playTapCount`, `_SessionTickerCard`/`menu_session_ticker.dart` (và test của chúng) đã BỊ XOÁ KHỎI menu. Đừng đánh BEHIND vì chúng vắng mặt; đánh DIVERGED nếu chúng còn sót lại. Nút 'ĐẶT LẠI HỒ SƠ' thì VẪN còn (scaffold đăng ký, chưa retire).

EXPECTED STATE SAU BÀI NÀY:
- `test/menu_view_model_test.dart` có `group('MenuViewModel events (M13)')` với 3 test (STRICT): (a) `requestGame` → `vm.events.first` hoàn thành `isA<MenuGameRequested>()`; (b) `resetProfile` → event `isA<MenuSnackBarRequested>()` + `message == 'Đã đặt lại hồ sơ.'`; (c) broadcast-no-replay: `vm.requestGame()` trước khi listen → listener mới nhận `got == 0` sau delay, rồi `== 1` sau `requestGame()` tiếp (STRICT kỹ thuật `events.first`/đếm listener; dùng addTearDown(vm.dispose)).
- `test/menu_ui_events_test.dart` tồn tại (STRICT path mới): helper `makeStore`/`scopedMenu` bọc `AppDependencyScope(profileStore: store, child: MaterialApp(home: MenuScreen()))`; 2 testWidgets — (a) `tap('BẮT ĐẦU CHƠI')` → pump + pump(400ms) → `find.text('Phòng chơi')` findsOneWidget; (b) `tester.ensureVisible(find.text('ĐẶT LẠI HỒ SƠ'))` → tap → pump + pump(300ms) → `find.text('Đã đặt lại hồ sơ.')` findsOneWidget (STRICT ensureVisible vì nút dưới fold; mọi test kết thúc `pumpWidget(const SizedBox())`).
- `_MenuScreenViewState` KHÔNG còn `_soundOn`, `_playTapCount`, `_sessionTicker`, `_toggleSound`, `_SessionTickerCard`; file `lib/data/profile/menu_session_ticker.dart` (hoặc tương đương) + test ticker đã xoá (STRICT retire — vẫn còn = DIVERGED); `_onPlayTap` gọi `requestGame()` và KHÔNG còn `_playTapCount++`.
- `_ProfileHeader`/`_MenuBody`/`_PlayButton` đã điều chỉnh theo (không còn param soundOn/tapCount/ticker — semantic).
- `flutter test` → "All tests passed!" ~52; `flutter analyze` → "No issues found!"; chạy app: ĐẶT LẠI HỒ SƠ → SnackBar 'Đã đặt lại hồ sơ.' trượt lên.

INVARIANTS NỀN:
- Event bridge (didChangeDependencies/_attachViewModel/dispose/_handleUiEvent) của bài 2; `MenuUiEvent` + broadcast controller bài 1; Provider scope M12; persistence M10; game M09 + route-result.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (sealed events, navigation controller, emitsInOrder) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m13/03
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
