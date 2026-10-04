## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m06/03 — "listen, cancel & StreamController" (bài cuối M06 — checkpoint tích luỹ của cả band async M05–M06; bản thân bài này chỉ dạy bằng learning-example, app không đổi).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter build web`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này KHÔNG thêm code vào app (các ví dụ listen/StreamController chỉ để đọc) — nếu learner thử nghiệm ví dụ trong project thì phải đã dọn sạch. Checkpoint: hai cơ chế async của app (FutureBuilder + StreamBuilder) cùng đứng vững.

EXPECTED STATE SAU BÀI NÀY (trạng thái cuối M06):
- `lib/screens/menu_screen.dart`: `_MenuScreenState` giữ `_profile`/`_soundOn`/`_playTapCount` + `late Future<void> _profileLoadFuture` + `final Stream<int> _sessionTicker` + `_loadProfile` (await→mounted→setState) + `_retryLoadProfile` + `initState`/`dispose` đúng thứ tự super; `build` có `FutureBuilder<void>` ba nhánh bao `Column` menu với `_MenuBody(profile:, ticker:)`.
- `_SessionTickerCard` với `StreamBuilder<int>` + `initialData: 0` đếm giây; `_MenuLoading`/`_MenuErrorState` còn nguyên.
- KHÔNG có `StreamController`, `StreamSubscription`, `.listen(`, `.broadcast()` hoặc `unawaited` nào sót lại trong `lib/` (STRICT — các ví dụ của bài không thuộc app; một `debugPrint` thử nghiệm quên xoá cũng cần liệt kê).
- `lib/data/menu_session_ticker.dart` + `lib/data/profile/demo_profile_loader.dart` + `lib/data/profile/user_profile_data.dart` đầy đủ; `lib/main.dart` là `Future<void> main() async` + `ensureInitialized` + `runApp(AIMillionaireApp)`.
- `flutter analyze` → "No issues found!"; `flutter test` → ~15 xanh; `flutter build web` → thành công.

INVARIANTS NỀN (M01–M06):
- `pubspec.yaml` chỉ `flutter` dep, `name: ai_millionaire_course`; `MenuTokens`; `UserProfileData` + 10 test; khung bọc menu 375; chưa có `Navigator`/route thứ hai, chưa repository/Provider/package mới — đều bài sau, không thiếu.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (đã có navigation/controller trong app) → `AHEAD_COMPATIBLE` nếu học từ ví dụ đúng pattern, `AHEAD_RISKY` nếu phá nền bài tới; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m06/03
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
