## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m17/04 — "Dời chữ sang AppLocalizations — migration toàn bộ UI" (mechanical migration: literal → l10n.*, factory/VM nhận chuỗi qua tham số, test host có delegates + ghim Locale('vi')).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `grep` cho literal còn sót. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. RANH GIỚI: VM KHÔNG import AppLocalizations (chữ vào qua tham số); data (nativeName/username/quiz content/'Đã đặt lại hồ sơ.' trong MenuViewModel) giữ literal — KHÔNG phải sót.

EXPECTED STATE SAU BÀI NÀY:
- `settings_item_factory.dart`: `buildSettingItems` có thêm 6 named-param String với default TIẾNG ANH: `soundText='Sound'`, `musicText='Music'`, `hapticText='Haptic Feedback'`, `notificationsText='Notifications'`, `notificationTimeText='Notification Time'`, `notificationsHint='Once a day'` (STRICT default en); thân dùng các param thay literal.
- `settings_view_model.dart`: `List<SettingItemData> localizedSettingItems({required 6×String tương ứng})` forward vào `buildSettingItems(settings: _settings, effectiveNotificationEnabled: ..., <params>)` (STRICT signature 1:1 senior); VM KHÔNG import app_localizations.
- `settings_dialog.dart`: `final l10n = AppLocalizations.of(context);` + `final items = viewModel.localizedSettingItems(soundText: l10n.soundSetting, ...)` (STRICT truyền l10n qua tham số); mọi literal → `l10n.*`: 'CÀI ĐẶT'→settingsTitle, 4 section titles, 'XONG'→doneButton, 'GIỜ THÔNG BÁO'→notificationTimeTitle; `_snackBarText(AppLocalizations l10n, SettingsSnackBarMessage)` switch enum→3 key error (STRICT signature có l10n); `_SettingsAccountRow` hint → `l10n.settingsGuestSyncHint`; language chips giữ `language.nativeName` (STRICT — data, không l10n).
- `notification_time_picker_dialog.dart`: 'HUỶ'→`l10n.cancelButton`, 'XÁC NHẬN'→`l10n.confirmButton`.
- `menu_screen.dart`: `final l10n = AppLocalizations.of(context)` trong các build cần; gear semanticLabel→`l10n.settingsSemanticLabel`; 'ĐẶT LẠI HỒ SƠ'→resetProfileButton; 'BẮT ĐẦU CHƠI'→startGameButton; 'CẤP $level'→`l10n.profileLevel(profile.level)`; '$exp / $max EXP'→`l10n.menuExpProgress(currentExp, expForNextLevel)`; stats 4 label + leaderboard title/subtitle → l10n.*; `const` gỡ khỏi widget chạm l10n (STRICT — còn `const` quanh `l10n.*` là compile error).
- `game_screen.dart`: AppBar→gameRoomTitle; 'Câu i/n'→`l10n.questionCounter(i+1, n)`; '${s}s'→`l10n.secondsRemaining(s)`; 3 nút→submitAnswerButton/nextButton/seeResultButton; 2 feedback→correctFeedback/wrongFeedback; dialog end-game `_dialogTitle(AppLocalizations l10n)` + `_resultText(AppLocalizations l10n)` — cấu trúc switch sealed GIỮ NGUYÊN kể cả `GameDialogHidden() => ''` (STRICT), `l10n.correctCountBase(correct, total)` + `victoryBody/timeoutBody/wrongAnswerBody(base)`; nút 'CHƠI LẠI'/'VỀ MENU' → `AppLocalizations.of(dialogContext).playAgainButton/menuButton` (STRICT dialogContext).
- `test/helpers/localized_test_app.dart` tồn tại: `MaterialApp localizedTestApp({required Widget home, Locale locale = const Locale('vi'), Widget? child})` với `localizationsDelegates` + `supportedLocales` + `locale` (STRICT ghim vi mặc định); 4 file test dùng `localizedTestApp` thay `MaterialApp`: `menu_provider_scope_test.dart`, `menu_ui_events_test.dart`, `test/widgets/game_screen_test.dart`, `test/widgets/settings_dialog_test.dart` (STRICT).
- `MenuViewModel` vẫn chứa literal `'Đã đặt lại hồ sơ.'` (STRICT — scaffold learner, không phải key ARB).
- `flutter analyze` sạch; `flutter test` → ~87 xanh; `flutter run` → app vẫn hiển thị vi NHƯNG đổi chip sang English → toàn bộ chrome đổi en ngay.

INVARIANTS NỀN:
- StreamBuilder+locale wiring `main.dart` bài 3; ARB keys bài 2; settings dialog M16; sealed dialog-state M15; whitelist languageCode bài 3.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (onboarding/auth strings, upper() tại widget) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m17/04
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
