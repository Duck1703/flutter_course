## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m29/03 — "Leaderboard pipeline: DTO có asset, mapper deterministic, snapshot có pin" (`LeaderboardEntryData` +`avatarAsset`/`avatarUrl`/`rankAsset`/`LeaderboardRowStyle`; `_LeaderboardRecord.fromMap→toEntry` — 3 mapper `_rankAsset`/`_avatarAsset`(clamp)/`_rowStyle`; `SupabaseLeaderboardRepository.loadLeaderboard` top-10 + `_loadCurrentEntry` maybeSingle pin; `DisabledLeaderboardRepository` static; seam `@visibleForTesting entryFromRow`; VM `requestId` + refresh-giữ-pin `isRefreshing` + `_profileBackedCurrentLeaderboardEntry` overlay-local; `LeaderboardAvatar` ring-rank + `Image.network` http/https-only + initial/asset fallback; `LeaderboardEntryCard` menu card; +8 → 321).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `grep`/`findstr` cho `entryFromRow`/`isRefreshing`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. "Pipeline" — cả tuyến row-DB→DTO→UI, không chỉ row visual.

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/leaderboard/leaderboard_entry_data.dart` (STRICT): `LeaderboardEntryData` 9-field `rank/name/level/score:String/avatarAsset/avatarUrl:String?/rankAsset/style/isCurrentUser` (STRICT `avatarAsset`+`avatarUrl` TÁCH — gộp = mất fallback-chain); `enum LeaderboardRowStyle {first, second, third, glass, currentUser}`; sealed `LeaderboardPopupState` 4-variant Loading/Success/Empty/Error — `LeaderboardPopupSuccess({entries = leaderboardEntries, currentEntry = currentLeaderboardEntry, isRefreshing})` default-const static-preview; static `leaderboardEntries` + `currentLeaderboardEntry` const-list (6 hàng, medal+avatar paths từ catalogue Bài 01).
- `lib/repositories/leaderboard/leaderboard_repository.dart` (STRICT verbatim + 1 seam):
  - `_LeaderboardRecord` private + `factory fromMap(Map)` parse-phòng-thủ `_intValue(v, default)`/`_stringValue` (snake_case `avatar_url`/`total_money_won`) + `toEntry({required bool isCurrentUser})` → `LeaderboardEntryData(score: _formatScore(totalMoneyWon)` int→'2.210.000' qua `UserProfileData.formatVnd` - ' VNĐ', `avatarAsset: _avatarAsset(rank)`, `rankAsset: isCurrentUser ? leaderboardRankCurrent : _rankAsset(rank)` (STRICT currentUser bypass-mapper luôn medal-current), `style: isCurrentUser ? currentUser : _rowStyle(rank)`);
  - 3 static-mapper: `_rankAsset` switch `1→leaderboardRank1, 2→Rank2, 3→Rank3, _→leaderboardRankCurrent`; `_rowStyle` `1→first, 2→second, 3→third, _→glass`; `_avatarAsset(rank)` `const assets[6]` + `(rank - 1).clamp(0, assets.length - 1).toInt()` (STRICT clamp — `%` modulo = DIVERGED rank-xa-quay-vòng);
  - `SupabaseLeaderboardRepository.loadLeaderboard({String? currentUserId})` — `.from(_leaderboardView).select(_leaderboardColumns).order('total_money_won', ascending: false).order('rank').limit(_topEntryCount)` (STRICT order-thứ-hai rank tiebreak) + `_loadCurrentEntry` `.eq('auth_uuid', id).maybeSingle()` null-safe (guest/isEmpty-guard → null) → `LeaderboardSnapshot(entries, currentEntry)`;
  - `DisabledLeaderboardRepository` trả static;
  - `@visibleForTesting static LeaderboardEntryData entryFromRow(Map row, {required bool isCurrentUser}) => _LeaderboardRecord.fromMap(row).toEntry(...)` (STRICT documented deviation — test-seam, body verbatim).
- `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart` (STRICT): `_requestId` ++ chống stale; `loadLeaderboard({isRefresh})` — isRefresh && Success → `Success(entries, currentEntry, isRefreshing: true)` (STRICT giữ-entries+pin chỉ-đổi-cờ — `Loading` variant thay-thế = nhấp-nháy DIVERGED); success → `Success(snapshot.entries, _profileBackedCurrentLeaderboardEntry(snapshot.currentEntry))`; `_profileBackedCurrentLeaderboardEntry` overlay `avatarUrl: userData.avatarUrl ?? currentEntry.avatarUrl` (local-ưu-tiên) + `avatarAsset: avatarTauHuDiChill` + `style: currentUser` + `isCurrentUser: true` (STRICT remote-rank/score + local-avatar/name).
- `lib/widgets/leaderboard/` `leaderboard_avatar.dart` — `_validAvatarUrl` `Uri.tryParse` + scheme-switch `http||https` (STRICT whitelist — `file:`/`data:`/host-rỗng → null) + `Image.network(errorBuilder → _initialAvatar)` + `_initialAvatar` `runes.first.toUpperCase` + `_fallbackAvatar` currentUser|has-url→initial else `_assetAvatar(rank)` + ring-10-màu-rank `_ringGlowColor` alpha-0x66 + `green400`/`_ringInset` current-user; `leaderboard_row.dart` medal-SVG + avatar + gradient-style + score-coin; `leaderboard_list.dart` + `leaderboard_popup_body.dart` `RefreshIndicator(vm.refresh)`.
- `lib/widgets/menu/leaderboard/` `leaderboard_entry_card.dart` (FILE MỚI menu-side — trophy-28 `srcIn` trắng + `l10n.leaderboardTitle` + `menuLeaderboardEntrySubtitle` Bài-01-key + `onTap` + Semantics) + `menu_leaderboard_dialog.dart` + `menu_leaderboard_dialog_scope.dart` (ChangeNotifierProvider(create:)-scoped-VM).
- `test/widgets/leaderboard_avatar_test.dart` 5 + `menu_leaderboard_dialog_test.dart` 11 (STRICT verbatim; net +8 retire learner-predecessors).
- `flutter analyze` sạch; `flutter test` → **321/321** (STRICT 313 + 8).
- KHÔNG ĐƯỢC có (chưa đến): `menu_screen_content`/`profile/`×5/`gradient_cta_button`/`screen_*_inset`/`LevelProgressCard`/`ProfileAvatarImage`/`StatsCard`/`EarningsCard`/`MenuProfileHeader` (BÀI 04); `MenuDialogState`/`menu_dialog_layer`/`menu_dialog_backdrop`/`menu_screen_view`/`PopScope`-dismiss/`_dialogDismissLocked` (BÀI 05 — leaderboard dialog vẫn route-`showDialog` hiện-tại); onboarding config/card/actions/indicator/scope-chain (BÀI 06); `menu_tokens.dart` xoá (BÀI 06); previews/main-verbatim (BÀI 07); `MenuLeaderboardRequested`/`MenuAuth*`/`MenuSignOut*`/`MenuSettings*` retire (BÀI 05).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- Bài 02: settings-11-file + `iconAsset` + 313; Bài 01: 45-const (leaderboard avatar/medal paths bài-03 dùng) + OnboardingTokens; M23 contract `LeaderboardRepository` + `LeaderboardDialogViewModel`-cơ-bản + `requestId`-concept + `RefreshIndicator`; M24 `_authState`/user-profile-stream (`userData.avatarUrl` source); M22 `UserProfileData.formatVnd`; `AvatarImage`-concept M27-era → `LeaderboardAvatar`/`ProfileAvatarImage` hai-ngữ-cảnh-riêng (Bài 04 avatar-guest-khác) — KHÔNG gộp generic-avatar; M26 DRE (leaderboard không-qua-DRE — VM trực tiếp, senior-đúng); `menu_screen.dart` `onLeaderboardTap → showDialog` (transport-hiện-tại — BÀI 05 in-tree).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. `_avatarAsset` modulo = DIVERGED; refresh-set-Loading = DIVERGED nhấp-nháy; `avatarUrl` không-whitelist-scheme = DIVERGED security; `_loadCurrentEntry` `.single()` thay maybeSingle = NEEDS_FIX throw-on-empty.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m29/03
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
