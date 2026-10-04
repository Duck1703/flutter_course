---
title: "Bài 5 · Dialog, menu row & RefreshIndicator"
description: "Menu leaderboard đóng: _LeaderboardEntry tappable → requestLeaderboardDialog → MenuLeaderboardRequested → bridge showLeaderboardDialog → MenuLeaderboardDialogScope (ChangeNotifierProvider + post-frame load) → LeaderboardPopupBody switch 4 state → LeaderboardList RefreshIndicator.adaptive + hàng ghim → LeaderboardRow. +6 key ARB, gen-l10n, 9 test → 184 → 193. Chạy manual: không dart-define (fallback) và có dart-define (OPTIONAL, env-dependent)."
sidebar:
 label: "Bài 5 · dialog + menu row"
 order: 5
---

## Mục tiêu

- Nối tap trên hàng menu → 
`requestLeaderboardDialog()`
 → event
 
`MenuLeaderboardRequested`
 → bridge 
`_openLeaderboard()`
 →
 
`showLeaderboardDialog`
 — đúng transport settings (→ M29).
- Dựng cụm widget: 
`MenuLeaderboardDialogScope`
 (dialog-scoped VM +
 post-frame load) → 
`MenuLeaderboardDialog`
 (chrome 
`MenuTokens`)
 → 
`LeaderboardPopupBody`
 (switch 4 state) → 
`LeaderboardList`

 (`RefreshIndicator.adaptive`
 + hàng ghim) → 
`LeaderboardRow`.
- Thêm 6 key ARB + regen l10n.
- 9 test (8 widget + 1 menu VM event) → suite **184 → 193** — đỉnh
 cuối milestone.
- Chạy app hai cách: không dart-define (fallback tĩnh) và có
 dart-define (OPTIONAL — phụ thuộc môi trường).

## Bạn đang ở đâu

- Bài 4: VM đã emit 4 state + 
`refresh`/
`retry`; 
`LeaderboardRepository`

 đã nằm trong scope từ Bài 2.
- 
`_LeaderboardEntry`
 trên menu đang là card tĩnh — chưa tap được.
- Chưa có một widget nào của dialog; 
`LeaderboardPopupBody`/
 
`LeaderboardList`/
`LeaderboardRow`
 chưa tồn tại.

## Vì sao việc này quan trọng ngay bây giờ

Đây là nơi **đóng**: hàng bảng xếp hạng trên menu — vốn chỉ
để trưng từ M02 — lần đầu thành entry thật mở dialog dữ liệu thật.
Mọi mảnh M23 đổ bộ cùng chỗ này: DI (Bài 2) cho repo, query chain
(Bài 3) cho snapshot, VM + guard (Bài 4) cho state — còn lại là
dây UI và một điểm chạm.

## Bạn đã biết gì

- Event một lần + bridge 
`switch`
 kiệt hợp (M13/M15); 
`showDialog`/
`AlertDialog`
 là route (M09);
 transport settings 
`MenuSettingsRequested → showSettingsDialog`

 (M16).
- 
`ChangeNotifierProvider`
 create/auto-dispose (M12);
 dialog-scoped VM (M16); 
`context.read`/
`watch`.
- 
`didChangeDependencies`
 + 
`addPostFrameCallback`
 + 
`mounted`
 guard; 
`unawaited`.
- 
`Semantics(button, label, excludeSemantics)`
 + 
`GestureDetector(
 HitTestBehavior.opaque)`.
- ARB + 
`flutter gen-l10n`
 + 
`AppLocalizations.of(context)`
 (M17); 
`profileLevel`
 key có sẵn.
- Widget test: 
`pumpWidget`/
`pump`/
`tap`/
`ensureVisible`
/finders; 
`localizedTestApp`
 helper.

## Mental model — "dialog = một scope sống ngắn, tự lo việc của nó"

```text
tap hàng menu
  → MenuViewModel.requestLeaderboardDialog()     (VM bắn Ý ĐỊNH)
  → event MenuLeaderboardRequested               (stream một-lần)
  → _MenuScreenViewState._openLeaderboard()
  → showLeaderboardDialog(context)
        │  đọc 2 repo từ context MENU (caller)
        ▼
  showDialog → MenuLeaderboardDialogScope
        │  ChangeNotifierProvider<LeaderboardDialogViewModel>
        │    = VM sinh cùng dialog, chết cùng dialog
        ▼
  _LeaderboardDialogBridge
        │  didChangeDependencies → attach VM
        │  _didLoadLeaderboard flag → addPostFrameCallback
        │  → loadLeaderboard() ĐÚNG MỘT LẦN sau frame đầu
        ▼
  context.watch(state) → MenuLeaderboardDialog → PopupBody switch
```

Vì sao load qua **post-frame** chứ không gọi trong 
`create:`
 hay

`build`
? Vì 
`loadLeaderboard`
 
`notifyListeners`
 ngay khi emit
Loading — notify giữa lúc framework đang build provider subtree là
lỗi ("setState during build"). 
`addPostFrameCallback`
 + cờ

`_didLoadLeaderboard`
 = "gọi đúng một lần sau frame đầu" — pattern
senior 
`_LeaderboardDialogBridge`
 giữ nguyên.

Vì sao đọc repo từ context **caller** rồi truyền vào scope? Giữ
dialog **self-contained/pumpable trong test** — pump

`MenuLeaderboardDialogScope`
 với hai fake là đủ, không cần dựng cả

`MultiProvider`
 app (giống 
`showSettingsDialog`
 M16).

## Build it step by step

**Bước 1 — ARB: +6 key.** 
`app_en.arb`/
`app_vi.arb`
 (giá trị đúng
senior):

```text
leaderboardSemanticLabel   "Leaderboard" / "Bảng xếp hạng"
leaderboardEmptyMessage    "No leaderboard data yet" / "Chưa có dữ liệu bảng xếp hạng"
leaderboardLoadErrorMessage "Unable to load leaderboard" / "Không thể tải bảng xếp hạng"
leaderboardLoadingMessage  "Loading leaderboard..." / "Đang tải bảng xếp hạng..."
retryButton                "Retry" / "Thử lại"
rankSemanticLabel          "Rank {rank}" / "Hạng {rank}"   (+ @rankSemanticLabel ICU int)
```

(`leaderboardTitle`/
`leaderboardSubtitle`
 đã có; 
`profileLevel`
 dùng
lại cho level text.) Chạy 
`flutter gen-l10n`
 — getters mới phải
xuất hiện trong 
`app_localizations.dart`
 trước khi viết widget.

**Bước 2 — 
`lib/widgets/menu/leaderboard/
menu_leaderboard_dialog_scope.dart`
** (hàm vào + scope + bridge):

```dart
Future<void> showLeaderboardDialog(BuildContext context) {
  final leaderboardRepository = context.read<LeaderboardRepository>();
  final userProfileRepository = context.read<UserProfileRepository>();
  return showDialog<void>(
    context: context,
    builder: (_) => MenuLeaderboardDialogScope(
      leaderboardRepository: leaderboardRepository,
      userProfileRepository: userProfileRepository,
    ),
  );
}

class MenuLeaderboardDialogScope extends StatelessWidget {
  // hai repo truyền vào — senior còn truyền AuthRepository (M24)
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LeaderboardDialogViewModel>(
      create: (_) => LeaderboardDialogViewModel(
        leaderboardRepository: leaderboardRepository,
        userProfileRepository: userProfileRepository,
      ),
      child: const _LeaderboardDialogBridge(),
    );
  }
}
```


`_LeaderboardDialogBridge`
 (StatefulWidget): 
`didChangeDependencies`

→ 
`_attachViewModel(context.read<LeaderboardDialogViewModel>())`;
cờ 
`_didLoadLeaderboard`
 → 
`addPostFrameCallback`
 →

`unawaited(viewModel.loadLeaderboard())`
 nếu 
`mounted`; 
`build`
 →

`context.watch`
 → 
`MenuLeaderboardDialog(state: vm.state,
onRefresh: vm.refresh, onRetry: vm.retry)`.

**Bước 3 — 
`lib/widgets/menu/leaderboard/
menu_leaderboard_dialog.dart`
** (57 dòng): 
`AlertDialog`
 key

`'leaderboard-dialog-shell'`, 
`backgroundColor: MenuTokens.
backgroundBottom`, title 
`l10n.leaderboardTitle.toUpperCase()`
 vàng
accent, 
`content: SizedBox(width: double.maxFinite, height:
_contentHeight /* 380 */)`
 chứa 
`LeaderboardPopupBody`.
Nhận 
`state`/
`onRefresh`/
`onRetry`
 — **stateless thuần**, không tự
đọc VM (bridge truyền xuống → widget test pump được chỉ bằng state).

:::note[Chrome learner, không phải senior]
Senior 
`MenuLeaderboardDialog`
 vẽ frame gradient + painter riêng và
sống trong 
`MenuDialogLayer`
 (M29). Learner dùng 
`AlertDialog`
 +

`MenuTokens`
 đúng transport settings — visual parity là M28.
:::

**Bước 4 — 
`lib/widgets/leaderboard/
leaderboard_popup_body.dart`
** (181 dòng): switch kiệt hợp —

```dart
return switch (state) {
  LeaderboardPopupSuccess(:final entries, :final currentEntry,
      :final isRefreshing) =>
    LeaderboardList(entries: entries, currentEntry: currentEntry,
        isRefreshing: isRefreshing, onRefresh: onRefresh),
  LeaderboardPopupEmpty(:final message) =>
    _LeaderboardMessage(message: _messageText(l10n, message)),
  LeaderboardPopupError(:final message) =>
    _LeaderboardErrorMessage(message: _messageText(l10n, message),
        onRetry: onRetry),
  LeaderboardPopupLoading(:final message) =>
    _LeaderboardLoadingMessage(message: _messageText(l10n, message)),
};
```


`_messageText`
 map enum 
`LeaderboardPopupMessage`
 → chuỗi l10n
(empty/loadError/loading) — **model giữ enum, widget giữ chữ**: VM
không import 
`AppLocalizations`
 (đúng phân chia "UI sở hữu chữ, VM
context-free" của). Error branch: 
`Icons.cloud_off`
 + message
+ 
`TextButton.icon`
 key 
`'leaderboard-retry-button'`
 hiển thị

`l10n.retryButton.toUpperCase()`.

**Bước 5 — 
`lib/widgets/leaderboard/leaderboard_list.dart`
** (97
dòng) — hai vùng:

```dart
Column(children: [
  Expanded(child: Stack(children: [
    _TopRowsScrollView(entries: entries, onRefresh: onRefresh),
    if (isRefreshing) const Align(alignment: Alignment.topCenter,
      child: LinearProgressIndicator(
        key: ValueKey('leaderboard-refresh-progress'),
        minHeight: 2, color: MenuTokens.accentYellow)),
  ])),
  if (currentEntry != null) ...[
    const SizedBox(height: _rowSpacing),
    LeaderboardRow(key: ValueKey('leaderboard-current-user-row'),
        entry: currentEntry),
  ],
])
```

- Top rows CUỘN trong 
`_TopRowsScrollView`
 (`SingleChildScrollView`

 key 
`'leaderboard-scrollable-top-rows'`); hàng "bạn" GHIM dưới
 đáy NGOÀI vùng cuộn (key 
`'leaderboard-current-user-row'`).
- 
`physics: onRefresh == null ? null : const
  AlwaysScrollableScrollPhysics()`
 — kéo refresh được ngay cả khi
 list ngắn không tràn.
- 
`RefreshIndicator.adaptive(onRefresh: onRefresh!, child:
  scrollView)`
 — adaptive = vẻ Material/Cupertino theo platform
 (NORMAL).

**Bước 6 — 
`lib/widgets/leaderboard/leaderboard_row.dart`
** (104
dòng): 
`Container`
 nền 
`statGreen`
 tint + viền 
`statGreen`
 khi

`entry.isCurrentUser`
 (còn lại 
`cardBackground`/
`cardBorder`);

`Semantics(label: l10n.rankSemanticLabel(
entry.rank), image: true, excludeSemantics: true)`
 bọc RIÊNG badge

`'#${entry.rank}'`
 — đặt label trên leaf để a11y đọc đúng "Hạng N"
(đặt quanh cả hàng sẽ bị Text con merge); tên + 
`l10n.profileLevel(
entry.level)`
 + 
`entry.score`.

**Bước 7 — event + VM + screen** (3 edit nhỏ):

```dart
// menu_screen_ui_event.dart — + variant (sealed → case mới là
// compile-forced ở mọi switch):
final class MenuLeaderboardRequested extends MenuScreenUiEvent {
  const MenuLeaderboardRequested();
}

// menu_view_model.dart — tên method ĐÚNG senior:
void requestLeaderboardDialog() {
  _events.add(const MenuLeaderboardRequested());
}

// menu_screen.dart — bridge + opener + hàng:
case MenuLeaderboardRequested():
  unawaited(_openLeaderboard());
// ...
Future<void> _openLeaderboard() => showLeaderboardDialog(context);
// import '../widgets/menu/leaderboard/menu_leaderboard_dialog_scope.dart';
```

Và 
`_LeaderboardEntry`
 thành tappable:

```dart
return Semantics(
  button: true, excludeSemantics: true,
  label: l10n.leaderboardSemanticLabel,
  child: GestureDetector(
    key: const ValueKey('menu-leaderboard-entry'),
    behavior: HitTestBehavior.opaque,
    onTap: () =>
        context.read<MenuViewModel>().requestLeaderboardDialog(),
    child: Container( /* card icon emoji_events + title/subtitle +
        chevron — giữ nguyên phần cũ */ ),
  ),
);
```

**Bước 8 — test.**

- 
`test/sealed_state_test.dart`
: switch kiệt hợp + 
`case
  MenuLeaderboardRequested()`
 (compile-forced — không thêm variant
 mà quên xử lý được).
- 
`test/menu_view_model_test.dart`
: +1 test — subscribe
 
`events.first`
 TRƯỚC 
`vm.requestLeaderboardDialog()`
 → 
`expect(
  await emitted, isA<MenuLeaderboardRequested>())`.
- 
`test/widgets/menu_leaderboard_dialog_test.dart`
: 8 test — 4
 nhánh state (success render tên/điểm + 
`'Hạng 125'`
 semantics +
 
`'CẤP 12'`; empty; error + retry counter; loading),
 
`RefreshIndicator`
 gọi 
`onRefresh`
 + 
`isRefreshing`
 progress,
 scope auto-load sau post-frame (`loadCallCount == 1`,
 
`lastCurrentUserId == null`), scope error→retry→
`loadCallCount 2`,
 và **tap 
`'menu-leaderboard-entry'`
 trên 
`MenuScreen`
 → dialog mở
 với dữ liệu fake repo** (đường đầy đủ qua
 
`AppDependencyScope`
 + 
`localizedTestApp`
 + 
`navigatorKey`).

## Hiểu code — ba mối nối dễ lẫn

| Cặp | Khác nhau ở |
| --- | --- |
| `onRefresh` vs `onRetry` | refresh = kéo xuống list → `vm.refresh()` → `loadLeaderboard(isRefresh: true)` — list cũ đứng yên; retry = nút THỬ LẠI ở Error → `vm.retry()` → load mới từ Loading. |
| state `Success.currentEntry` vs `entries` | `currentEntry` GHIM dưới đáy ngoài scroll; `entries` = top-10 cuộn — hàng của mình có thể trùng một hàng top (cùng data, hai chỗ hiển thị — đúng senior). |
| `MenuLeaderboardRequested` vs `MenuDialogLeaderboard` | learner: event một lần → `showDialog` (transport). Senior: `requestLeaderboardDialog()` đặt `MenuDialogLeaderboard` STATE → `MenuDialogLayer` render in-Stack (M29). Cùng tên method — body đổi ở M29. |

## Chạy và quan sát

```text
flutter gen-l10n   → regenerate getters (6 key mới)
flutter analyze    → No issues found!
flutter test       → +193: All tests passed!  (184 + 9)
flutter build web  → √ Built build\web
```

**Manual — không dart-define** (đường bắt buộc, mọi môi trường):

```text
flutter run
→ console: "[supabase] config supabase=false google=false"
→ menu → bấm hàng "Bảng xếp hạng" → dialog 'BẢNG XẾP HẠNG'
  hiện 6 hàng tĩnh + hàng "Tàu hủ đi chill" Hạng 125 tô xanh
→ kéo xuống list → spinner refresh → snapshot tĩnh trả lại
```

App chạy 
`DisabledLeaderboardRepository`
 — đúng thiết kế: thiếu
config vẫn demo được đầy đủ.

**Manual — có dart-define** — OPTIONAL, phụ thuộc môi trường:

```text
flutter run --dart-define=SUPABASE_URL=<your-project-url> \
            --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-publishable-key>
```

Giá trị lấy từ **project Supabase của chính bạn** (Dashboard →
Project Settings → API: project URL + publishable/anon key) sau khi
đã chạy 
`supabase/student-setup/01-setup-database.sql`
 trong SQL
Editor. Không bao giờ commit giá trị này.

:::caution[Đường remote chưa được verify sống]
Môi trường phát triển khóa học KHÔNG có credential —

`LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED`. Mọi PASS của M23 dựa
trên fake + impl disabled: chuỗi query là senior-verbatim và mapper
được test qua seam 
`entryFromRow`. Chạy có dart-define là checkpoint
mở rộng của riêng bạn — dữ liệu thấy được phụ thuộc project bạn tự
tạo, KHÔNG phải điều kiện qua môn.
:::

## Thử nghiệm

Trên app đang chạy (không dart-define): vào dialog, kéo refresh ba
lần liên tục thật nhanh — đoán 
`loadCallCount`
 nếu đếm được và dự
đoán hành vi (gợi ý Bài 4: mỗi 
`refresh()`
 là một request mới; repo
Disabled trả tức thì nên race khó quan sát bằng mắt — vì vậy guard
được *test* bằng Completer chứ không nhìn tay được).

## Lỗi hay gặp

1. **Gọi 
`loadLeaderboard()`
 trong 
`initState`/
`build`.** Notify
 giữa build → crash "setState during build". Post-frame callback
 + cờ 
`_didLoadLeaderboard`
 là cách senior né.
2. **
`RefreshIndicator`
 không kéo được khi list ngắn.** Quên
 
`AlwaysScrollableScrollPhysics`
 → scroll view chặn ở biên →
 indicator không bao giờ kích. (Tự làm bên dưới cho bạn tự phát
 hiện.)
3. **Đọc 
`context.read<MenuViewModel>()`
 trong 
`onTap`
 bằng context
 của dialog-builder.** Callback 
`onTap`
 chạy với context của WIDGET
 (menu row) — nơi 
`MenuViewModel`
 đang phủ; đừng truyền context
 route khác vào.
4. **
`Semantics(label)`
 đặt quanh cả hàng.** Các 
`Text`
 con merge
 nhãn vào nhau → a11y đọc sai. Senior đặt label trên leaf badge +
 
`excludeSemantics`
 — learner giữ kỹ thuật đó trên 
`#N`.
5. **Switch trên 
`LeaderboardPopupState`
 thiếu nhánh.** Sealed
 class: compiler bắt kiệt hợp — đó là lý do state là 
`sealed`,
 không phải enum + if-chain.

## Tự làm — PREDICT (kèm chứng cứ)

Trong 
`leaderboard_list.dart`, đổi 
`physics`
 của

`_TopRowsScrollView`
 về 
`null`
 trong mọi trường hợp (tức xoá

`AlwaysScrollableScrollPhysics`), giữ nguyên 
`RefreshIndicator.
adaptive`. Trên màn hình có 6 hàng (không tràn vùng cuộn):

1. Kéo xuống trên list — pull-to-refresh còn chạy không?
2. 
`flutter test test/widgets/menu_leaderboard_dialog_test.dart`

 đỏ hay xanh? Vì sao?

<details>
<summary>Đáp án</summary>

- **Hỏng kéo refresh**: 
`SingleChildScrollView`
 physics mặc định
 (clamping) không cho overscroll khi nội dung không tràn → không
 có kéo dư → 
`RefreshIndicator`
 không bao giờ kích hoạt. 6 hàng
 nhét vừa 380px nên lỗi hiện ngay trên máy chạy.
- **Test vẫn xanh**: widget test lấy 
`tester.widget<RefreshIndicator>`

 rồi gọi 
`refreshIndicator.onRefresh()`
 TRỰC TIẾP — đi qua callback,
 không qua gesture/physics. Đây là lỗi UX-thuần: observable bằng
 tay, không bắt được bằng test hiện có. Đó là lý do senior phải
 set physics một cách có chủ đích — và là bài học "test xanh ≠ UX
 đúng" cho hành vi chạm cảm.
- Revert lại 
`physics: onRefresh == null ? null :
  const AlwaysScrollableScrollPhysics()`
 sau khi quan sát.

</details>

## Kiểm tra hiểu biết

- **Hỏi:** luồng đầy đủ từ ngón tay tới 
`loadLeaderboard`
? — **Đáp:**
 tap → 
`requestLeaderboardDialog()`
 → 
`MenuLeaderboardRequested`
 →
 
`_openLeaderboard`
 → 
`showLeaderboardDialog`
 → scope tạo VM →
 post-frame → 
`loadLeaderboard()`.
- **Hỏi:** vì sao VM được tạo trong 
`ChangeNotifierProvider`
 của
 dialog thay vì 
`AppDependencyScope`
? — **Đáp:** scope = lifetime:
 VM chỉ sống khi dialog mở, Provider dispose khi dialog
 đóng — state loading/refresh của một lần mở không rò sang lần sau.
- **Hỏi:** guest thấy gì ở hàng ghim? — **Đáp:** hàng dựng từ
 profile local (`username`/
`level`/
`totalMoneyWon`
 qua
 
`userProfileStream.value`), rank 125, viền 
`statGreen`
 — test
 thấy 
`'0XFF'`
 mặc định.

## Ta cố ý chưa thêm

- 
`MenuDialogLayer`
 + 
`MenuDialogLeaderboard`
 state — **M29**;
 transport event+
`showDialog`
 giữ nguyên.
- Frame painter/SVG frame/rank-badge images/
`LeaderboardAvatar`/
 
`LeaderboardRowStyle`/
`LeaderboardEntryCard`
 tách widget của
 senior — **M28** (visual parity); hàng hiện 
`#N`
 text + 
`Icon`.
- 
`AuthRepository`
 vào scope VM dialog — **M24**.
- Level badge/rank asset theo hạng — M28 (`rankSemanticLabel`
 text
 đã senior-parity).

## Checkpoint hoàn thành

- [ ] 
`flutter gen-l10n`
 chạy xong; 6 getter mới tồn tại.
- [ ] 
`flutter analyze`
 sạch; 
`flutter test`
 **193/193**;
 
`flutter build web`
 xanh.
- [ ] Manual không dart-define: tap hàng → dialog mở, 6 hàng + hàng
 "bạn" rank 125; kéo refresh chạy; nút THỬ LẠI hiện khi repo throw
 (có thể xác nhận qua widget test error-branch).
- [ ] Đọc được chuỗi: 
`MenuLeaderboardRequested`
 →
 
`_openLeaderboard`
 → 
`showLeaderboardDialog`
 → scope → bridge →
 
`loadLeaderboard`
 → switch 4 state.
- [ ] (Tuỳ chọn) Chạy được lệnh dart-define với placeholder đúng
 format — biết giá trị thật lấy ở đâu, biết chúng không commit.

## 🤖 AI Local — Kiểm tra project sau bài này (ĐỈNH M23)

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m23/05 — "Dialog, menu row & RefreshIndicator" (đóng M23: hàng menu tappable → requestLeaderboardDialog → MenuLeaderboardRequested → showLeaderboardDialog → dialog-scoped VM + post-frame load → PopupBody switch 4 state → RefreshIndicator + hàng ghim; +6 ARB keys; +9 test → 193; manual không dart-define là đường bắt buộc).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter build web` READ-ONLY, `flutter gen-l10n` KHÔNG được chạy để "sửa" (chỉ verify getters tồn tại). Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa. KHÔNG yêu cầu chạy dart-define thật — OPTIONAL và env-dependent (`LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED`).

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Chrome dialog là `AlertDialog` + MenuTokens — frame gradient/painter/`MenuDialogLayer` là M28/M29, KHÔNG tính diverge.

EXPECTED STATE SAU BÀI NÀY (đỉnh M23):
- ARB (STRICT +6 key cả 2 file): `leaderboardSemanticLabel`, `leaderboardEmptyMessage`, `leaderboardLoadErrorMessage`, `leaderboardLoadingMessage`, `retryButton`, `rankSemanticLabel` (+metadata ICU int `{rank}`); generated `AppLocalizations` có đủ 6 getter.
- `lib/widgets/menu/leaderboard/menu_leaderboard_dialog_scope.dart` (FILE MỚI, STRICT): `Future<void> showLeaderboardDialog(BuildContext)` — đọc `LeaderboardRepository` + `UserProfileRepository` từ context CALLER (KHÔNG AuthRepository — M24) rồi `showDialog(builder: → MenuLeaderboardDialogScope(…))`; scope = `ChangeNotifierProvider<LeaderboardDialogViewModel>(create: → VM(2 repo), child: _LeaderboardDialogBridge())`; bridge StatefulWidget — `didChangeDependencies → _attachViewModel` + cờ `_didLoadLeaderboard` + `addPostFrameCallback → unawaited(loadLeaderboard())` ĐÚNG MỘT LẦN sau frame đầu (KHÔNG gọi trong create/initState/build — notify giữa build = crash) + `mounted` guard; `build → context.watch → MenuLeaderboardDialog(state: vm.state, onRefresh: vm.refresh, onRetry: vm.retry)`.
- `lib/widgets/menu/leaderboard/menu_leaderboard_dialog.dart` (FILE MỚI, STRICT): stateless nhận `state/onRefresh/onRetry` (KHÔNG tự đọc VM — bridge truyền xuống, test pump được bằng state); `AlertDialog` key `'leaderboard-dialog-shell'` + `backgroundColor: MenuTokens.backgroundBottom` + title `l10n.leaderboardTitle.toUpperCase()` vàng + `content: SizedBox(width: double.maxFinite, height: ~380)` chứa `LeaderboardPopupBody`.
- `lib/widgets/leaderboard/leaderboard_popup_body.dart` (FILE MỚI, STRICT): switch KIỆT HỢP 4 arm — `Success → LeaderboardList(entries:, currentEntry:, isRefreshing:, onRefresh:)`; `Empty → _LeaderboardMessage`; `Error → _LeaderboardErrorMessage` (`Icons.cloud_off` + `TextButton.icon` key `'leaderboard-retry-button'` hiển thị `l10n.retryButton.toUpperCase()` → `onRetry`); `Loading → _LeaderboardLoadingMessage`; `_messageText` map `LeaderboardPopupMessage` enum → l10n strings (VM context-free, widget sở hữu chữ).
- `lib/widgets/leaderboard/leaderboard_list.dart` (FILE MỚI, STRICT): `Column[ Expanded(Stack[ _TopRowsScrollView, if(isRefreshing) Align(topCenter, LinearProgressIndicator key 'leaderboard-refresh-progress' minHeight 2 accentYellow ])), if(currentEntry != null) SizedBox + LeaderboardRow key 'leaderboard-current-user-row' ]` — hàng-bạn GHIM dưới đáy NGOÀI scroll; `_TopRowsScrollView` = `SingleChildScrollView` key `'leaderboard-scrollable-top-rows'` bọc `RefreshIndicator.adaptive(onRefresh: onRefresh!, child: …)` (STRICT adaptive + physics `onRefresh == null ? null : const AlwaysScrollableScrollPhysics()` — thiếu physics = pull không kích khi list ngắn).
- `lib/widgets/leaderboard/leaderboard_row.dart` (FILE MỚI, STRICT): nền `statGreen` tint + viền `statGreen` khi `entry.isCurrentUser` (còn lại `cardBackground`/`cardBorder`); `Semantics(label: l10n.rankSemanticLabel(entry.rank), image: true, excludeSemantics: true)` bọc RIÊNG badge `'#${entry.rank}'` (label trên leaf, KHÔNG quanh cả hàng); tên + `l10n.profileLevel(entry.level)` + `entry.score` (score là String đã format — UI không format lại).
- WIRING (STRICT): `menu_screen_ui_event.dart` + `final class MenuLeaderboardRequested extends MenuScreenUiEvent`; `menu_view_model.dart` + `requestLeaderboardDialog() → _events.add(MenuLeaderboardRequested())`; `menu_screen.dart` bridge `case MenuLeaderboardRequested(): unawaited(_openLeaderboard());` + `Future<void> _openLeaderboard() => showLeaderboardDialog(context)` + import scope; `_LeaderboardEntry` tappable — `Semantics(button, label: l10n.leaderboardSemanticLabel, excludeSemantics)` + `GestureDetector(key 'menu-leaderboard-entry', behavior: HitTestBehavior.opaque, onTap: () => context.read<MenuViewModel>().requestLeaderboardDialog())` (giữ card cũ bên trong).
- TEST (STRICT → 193/193 = 184 + 9): `sealed_state_test` + arm `MenuLeaderboardRequested()`; `menu_view_model_test` +1 (subscribe `events.first` TRƯỚC khi call → `isA<MenuLeaderboardRequested>()`); `test/widgets/menu_leaderboard_dialog_test.dart` FILE MỚI ~8 test — 4 nhánh state (success render tên/điểm/'Hạng 125' semantics/'CẤP 12'; empty; error + retry counter; loading), RefreshIndicator gọi onRefresh + isRefreshing progress, scope auto-load post-frame (`loadCallCount==1`, `lastCurrentUserId==null`), scope error→retry→`loadCallCount==2`, tap `'menu-leaderboard-entry'` trên `MenuScreen` đầy đủ → dialog mở với fake repo.
- `flutter analyze` sạch; `flutter test` → **193/193**; `flutter build web` PASS. Manual không dart-define: `[supabase] config supabase=false` → tap hàng → dialog 6 hàng tĩnh + 'Tàu hủ đi chill' Hạng 125 viền xanh → kéo refresh chạy.
- KHÔNG ĐƯỢC có (chưa đến): `AuthRepository` vào scope/VM dialog (M24); `MenuDialogLayer`/`MenuDialogLeaderboard` state thay `showDialog` (M29 — transport event+showDialog là đúng ở đây); frame painter/SVG/`LeaderboardAvatar`/`LeaderboardRowStyle`/`LeaderboardEntryCard`/rank-badge images (M28); `gọi loadLeaderboard` trong `initState`/`create:`/`build` (post-frame pattern — DIVERGED); `Provider<SupabaseLeaderboardRepository>` (impl-type registration).

INVARIANTS NỀN:
- M23 Bài 1–4: `SupabaseEnvironment` + SQL + service + repo cluster + fake 3-mode + VM + `_requestId` guard + fallback profile; scope đăng ký contract; main ternary; M22 đỉnh (save trong VM — leaderboard chỉ ĐỌC, sync ghi là M25); M21 layer; M20 lifelines; M14–M18 nền.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`/`AHEAD_RISKY`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m23/05
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
