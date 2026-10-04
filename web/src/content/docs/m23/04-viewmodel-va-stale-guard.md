---
title: "Bài 4 · LeaderboardDialogViewModel — 4 state & stale guard"
description: "VM của dialog: loadLeaderboard({isRefresh}) với chuyển Loading/Success/Empty/Error, isRefreshing giữ list cũ, retry unawaited, _requestId monotonic guard 'câu trả lời cũ không được thắng', fallback hàng bạn từ profile local, guest seam _currentLeaderboardUserId→null (M24). 9 test → 175 → 184. Tự làm DEBUG: xoá _isLatestRequest."
sidebar:
 label: "Bài 4 · VM + stale guard"
 order: 4
---

## Mục tiêu

- Port `LeaderboardDialogViewModel` verbatim-minus-auth: ctor
 `(leaderboardRepository, userProfileRepository)` — chưa có
 `AuthRepository` (guest seam → M24).
- Hiểu máy trạng thái của `loadLeaderboard({isRefresh})`: Loading /
 Success(+`isRefreshing`) / Empty / Error — và `refresh()`/`retry()`
 là hai cửa vào cùng đường load.
- Hiểu `_requestId` — guard chống **stale response**: response của
 request cũ về sau phải bị bỏ, không ghi đè request mới.
- Hiểu fallback "hàng bạn" từ profile local khi remote trả `null`.
- 9 test VM → suite **175 → 184**.

## Bạn đang ở đâu

- Bài 3: repo + fake + snapshot đã hiểu; 4 `LeaderboardPopup*`
 variant nằm sẵn trong `leaderboard_entry_data.dart` từ Bài 2.
- Bài này nối chúng: VM biến `Future<LeaderboardSnapshot>` thành
 `LeaderboardPopupState` mà Bài 5 sẽ render.
- Vị trí file: `lib/view_models/leaderboard/
  leaderboard_dialog_view_model.dart` — VM sống TRONG dialog
 (dialog-scoped), scope widget tạo/dispose nó ở Bài 5.

## Vì sao việc này quan trọng ngay bây giờ

Remote không giống disk: request **mất thời gian và có thể về trễ,
về sai thứ tự, hoặc không về**. User mở dialog rồi kéo refresh
ngay — hai request bay song song; nếu response của request cũ về
SAU request mới, UI không được lật về dữ liệu cũ. Không có guard,
bảng "nhấp nháy" hiển thị dữ liệu thất lạc. `_requestId` là cách
senior chống điều đó bằng **một biến int** — không lock, không
cancel, chỉ so sánh số.

## Bạn đã biết gì

- `ChangeNotifier`/`notifyListeners` + `_isDisposed` guard (M11 —; pattern giống `MenuViewModel`).
- Sealed state + switch kiệt hợp (M15); state-driven
 UI.
- `Future`/`async`/`await` + `try/catch`; `unawaited`.
- Dialog-scoped VM — provider trong subtree dialog (M16).
- `ValueStream.value` — đọc giá trị mới nhất của stream (M14);
 `FakeUserProfileRepository`.
- Fake repo + `Completer` điều khiển thời điểm resolve (Bài 3);
 `pumpEventQueue`.

## Mental model mới — "câu trả lời cũ không được thắng" (NORMAL)

```text
_requestId = 0

load()  → id = ++_requestId  (id=1) ──await──┐
load()  → id = ++_requestId  (id=2) ──await──┤
                                             │
response của #2 về TRƯỚC: id==_requestId ✓ → ghi state (dữ liệu MỚI)
response của #1 về SAU:   id=1 ≠ _requestId=2 → RETURN, không ghi
```

Bộ đếm chỉ tăng; mỗi request "chụp" số của mình **trước** `await`.
Sau `await` — tức lúc response về — hỏi lại: "tôi còn là mới
nhất?" (`_isLatestRequest`). Không phải → kết quả đã lỗi thời → bỏ.
Đây là *monotonic generation counter* — pattern chống race kinh
điển, gọn đến mức không cần cancel request thật (network vẫn chạy
xong, chỉ kết quả bị bỏ qua).

Điểm tinh tế: check đặt **SAU await, TRƯỚC setState** — cả trong
nhánh success lẫn `catch`. Một stale *error* cũng không được phủ
state success mới.

## `loadLeaderboard` — đọc theo nhịp

```dart
Future<void> loadLeaderboard({bool isRefresh = false}) async {
  if (_isDisposed) return;

  final requestId = ++_requestId;          // ① chụp số TRƯỚC await
  final previousState = _state;

  if (isRefresh && previousState is LeaderboardPopupSuccess) {
    _setState(LeaderboardPopupSuccess(      // ② refresh: GIỮ list cũ
      entries: previousState.entries,
      currentEntry: previousState.currentEntry,
      isRefreshing: true,
    ));
  } else {
    _setState(const LeaderboardPopupLoading()); // ③ load thường → spinner
  }

  try {
    final snapshot = await _leaderboardRepository.loadLeaderboard(
      currentUserId: _currentLeaderboardUserId(),  // guest → null (M24)
    );

    if (!_isLatestRequest(requestId)) return;      // ④ stale guard

    if (snapshot.entries.isEmpty && snapshot.currentEntry == null) {
      _setState(const LeaderboardPopupEmpty());    // ⑤ rỗng thật
      return;
    }
    _setState(LeaderboardPopupSuccess(
      entries: snapshot.entries,
      currentEntry: _profileBackedCurrentLeaderboardEntry(
        snapshot.currentEntry),                    // ⑥ fallback profile
    ));
  } catch (_) {
    if (!_isLatestRequest(requestId)) return;      // ④' stale ERROR cũng bỏ
    _setState(const LeaderboardPopupError());
  }
}
```

Bốn quyết định cần thấy:

- **②** `isRefresh` + đang Success → emit Success giữ nguyên entries
 với `isRefreshing: true` — pull-to-refresh KHÔNG xoá màn hình
 xuống spinner (UX của senior: list cũ đứng yên + progress bar nhỏ).
- **④/④'** cặp guard sau mọi `await` — success lẫn error.
- **⑤** Empty chỉ khi *cả hai* rỗng: không top VÀ không hàng mình.
 (Impl Disabled không bao giờ ra Empty — luôn có 6 hàng mẫu.)
- **⑥** `currentEntry` trên state luôn đi qua
 `_profileBackedCurrentLeaderboardEntry` — remote trả hàng thì dùng
 số liệu remote, avatar ưu tiên bản profile mới hơn; remote `null`
 (guest / chưa có hạng) → dựng hàng từ `userProfileStream.value`
 với rank mượn `currentLeaderboardEntry.rank` (125).

```dart
void retry() {
  unawaited(loadLeaderboard());  // nút THỬ LẠI sync-return → fire-and-forget
}

Future<void> refresh() => loadLeaderboard(isRefresh: true);

String? _currentLeaderboardUserId() {
  return null; // guest seam — M24: switch(authState) → uid
}
```

## Guest seam — chỗ M24 sẽ nối

```dart
// SENIOR (đọc-only, KHÔNG port bây giờ):
//   final AuthRepository _authRepository;          // ctor param thứ ba
//   String? _currentLeaderboardUserId() {
//     return switch (_authRepository.authStateStream.value) {
//       AuthSessionAuthenticated(:final uid) => uid,
//       AuthSessionGuest() => null,
//     };
//   }
```

Learner chưa có `AuthRepository` → `_currentLeaderboardUserId()`
luôn `null`: repo được gọi với `currentUserId: null` → remote bỏ
qua query hàng riêng → `snapshot.currentEntry == null` →
`_currentUserLeaderboardEntry` dựng hàng từ profile local.
**Guest vẫn thấy hàng "bạn"** — đó là lý do fallback tồn tại. M24
chỉ đổi một hàm này + thêm ctor param.

## Ví dụ độc lập — guard 20 dòng

```dart
class Fetcher {
  var _requestId = 0;
  String _data = '';

  Future<String> latest() async {
    final id = ++_requestId;                       // số của TÔI
    final value = await Future.delayed(            // "network"
      const Duration(milliseconds: 10), () => 'dữ liệu #$id');
    if (id != _requestId) return _data;            // tôi đã cũ → bỏ
    return _data = value;
  }
}
// Gọi latest() hai lần liền: lời gọi 1 về sau bị bỏ — _data luôn
// mang kết quả của lời gọi 2. VM trên làm y vậy + check trong catch.
```

## Build it step by step

**Bước 1** — tạo `lib/view_models/leaderboard/
leaderboard_dialog_view_model.dart`: port nguyên file (173 dòng) —
ctor hai repo, `_state = const LeaderboardPopupLoading()`,
`_requestId`/`_isDisposed`, `loadLeaderboard`/`refresh`/`retry`,
`_currentLeaderboardUserId` (→ null, comment M24), hai hàm
profile-backed, `_formatScore`, `_isLatestRequest`, `_setState`,
`dispose` set `_isDisposed = true` trước `super.dispose()`.

**Bước 2** — `test/view_models/leaderboard/
leaderboard_dialog_view_model_test.dart`: 9 test —

| # | Test | Chứng minh |
| --- | --- | --- |
| 1 | state khởi đầu `LeaderboardPopupLoading` | ctor không auto-load |
| 2 | success → entries + currentEntry + `lastCurrentUserId == null` + `loadCallCount == 1` | guest seam |
| 3 | snapshot rỗng cả hai → `LeaderboardPopupEmpty` | nhánh ⑤ |
| 4 | repo throw → `LeaderboardPopupError(loadError)` | catch |
| 5 | `refresh()` giữ entries cũ + `isRefreshing` true→false | nhánh ② |
| 6 | **stale**: request 1 chậm về sau request 2 → state giữ 'SECOND PLAYER' | nhánh ④ |
| 7 | `retry()` → Loading rồi Success, `loadCallCount` tăng | retry path |
| 8 | remote `currentEntry` null → hàng dựng từ `FakeUserProfileRepository` (name/level/score/avatarUrl) | fallback |
| 9 | remote có `currentEntry` → số liệu remote, `avatarUrl` ưu tiên profile | nhánh ⑥ |

Test 6 là trái tim — hai `Completer` pop theo thứ tự gọi, complete
**thứ 2 trước**, assert `'SECOND PLAYER'`; complete thứ 1 sau, assert
vẫn `'SECOND PLAYER'` (không bị `'REMOTE PLAYER'` ghi đè).

## Chạy và quan sát

```text
flutter analyze → sạch
flutter test test/view_models/leaderboard/leaderboard_dialog_view_model_test.dart
  → 9/9 xanh
flutter test → +184: All tests passed!   (175 + 9)
```

## Thử nghiệm

Đoán: gọi `retry()` ngay sau khi `loadLeaderboard()` vừa bắt đầu —
repo thấy `loadCallCount` là mấy, và response của request đầu có
ghi state không?

<details>
<summary>Đáp án</summary>

`loadCallCount == 2` — `retry()` chỉ là `loadLeaderboard()` mới.
Request đầu (id=1) về sau → `!_isLatestRequest(1)` (đã là 2) →
kết quả bị bỏ. Hai request bay, chỉ một thắng — đúng guard.
</details>

## Lỗi hay gặp

1. **Tăng `_requestId` SAU await.** `++` phải chạy TRƯỚC
 `_leaderboardRepository.loadLeaderboard` — tăng sau thì request
 chậm nhất lại mang số lớn nhất, guard bảo vệ ngược.
2. **Check stale TRƯỚC await rồi bỏ check sau.** Trước await mọi id
 đều "mới nhất" — check ở đó vô nghĩa; race xảy ra *trong lúc* chờ.
3. **Quên guard trong `catch`.** Stale request mà throw → Error phủ
 lên Success của request mới hơn. Senior đặt `!_isLatestRequest`
 ở cả hai nhánh.
4. **`retry()` dùng `isRefresh: true`.** Retry từ Error mà giữ state
 sẽ không về Success (previous không phải Success) → vẫn Loading;
 nhưng về semantics nút THỬ LẠI nên là load mới sạch — senior
 gọi `loadLeaderboard()` thường.
5. **`notifyListeners` sau dispose.** Dialog đóng giữa chừng →
 response về sau → `_setState`/`_isLatestRequest` đều check
 `_isDisposed` — guard kép (mạng + vòng đời) dùng chung một cờ.

## Tự làm — DEBUG (bug có chủ đích)

Trong bản copy/sandbox, xoá **dòng guard sau await** ở nhánh success
(`leaderboard_dialog_view_model.dart` — khối `if (!_isLatestRequest(
requestId)) { return; }` ngay sau `await _leaderboardRepository.
loadLeaderboard(...)`), GIỮ nguyên guard trong `catch`.

Đoán TRƯỚC khi chạy:

1. Test nào trong 9 test đỏ?
2. State cuối hiển thị entries của request nào?

Chạy `flutter test test/view_models/leaderboard/
leaderboard_dialog_view_model_test.dart` kiểm chứng.

<details>
<summary>Đáp án</summary>

- **Chỉ một test đỏ**: `response STALE không được ghi đè kết quả
  request mới hơn`. Tám test còn lại vẫn xanh — mỗi test ấy chỉ có
 một request nên guard không bao giờ được dùng.
- Cơ chế: request 2 complete trước → ghi `'SECOND PLAYER'` ✓. Rồi
 request 1 (stale) complete → không còn check →
 `_setState(LeaderboardPopupSuccess(entries: [_remoteEntry]))` chạy
 tràn → assert cuối `expect(state.entries.single.name,
  'SECOND PLAYER')` nhận `'REMOTE PLAYER'` → FAIL.
- Guard trong `catch` giữ nguyên nên test error vẫn xanh — bug chỉ
 lộ trên đường success của response chậm. Đây là bằng chứng guard
 phải đứng ở MỌI nhánh thoát async, không phải một chỗ.
- Bài học: stale guard không bao giờ "fail sớm" — nó fail **đúng
 kịch bản nó tồn tại để chặn** (hai request chồng nhau). Đó là lý
 do test 6 dùng `Completer` để dựng race có kiểm soát.

</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao `refresh()` không nhảy về `Loading`? — **Đáp:**
 nhánh `isRefresh && previous is Success` emit Success mới giữ
 nguyên entries + `isRefreshing: true` — list đứng yên, chỉ thanh
 progress mỏng báo đang tải (Bài 5 render nó).
- **Hỏi:** guest mở bảng — hàng "bạn" đến từ đâu? — **Đáp:**
 `_currentLeaderboardUserId() → null` → remote trả
 `currentEntry: null` → `_currentUserLeaderboardEntry` dựng từ
 `userProfileStream.value` (rank mượn 125 của static
 `currentLeaderboardEntry`).
- **Hỏi:** hai chỗ `_isLatestRequest` bảo vệ khác nhau gì? —
 **Đáp:** sau `await` trong `try` chặn stale *data*; trong `catch`
 chặn stale *error* — cùng một nguyên tắc: chỉ request mới nhất
 được ghi state.

## Ta cố ý chưa thêm

- `AuthRepository` trên ctor + `switch(authState)` trả uid —
 **M24** (guest seam — khác-biệt có chủ đích).
- `DreChangeNotifier`/`asyncOp` + huỷ request thật của senior bản
 DRE — **M26**; `_requestId` đã đủ cho pull-to-refresh race.
- Taxonomy lỗi (network vs 4xx/5xx) — senior cũng chỉ `catch →
  LeaderboardPopupError`.
- UI tiêu thụ state — **Bài 5**.

## Checkpoint hoàn thành

- [ ] `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart`
 tồn tại, ctor đúng hai repo, `_currentLeaderboardUserId()` → null
 kèm comment M24.
- [ ] Giải thích được luồng: `++_requestId` → emit Loading/Success-
 refreshing → await repo → guard → Success/Empty/Error.
- [ ] `flutter test` **184/184**; test stale dùng hai `Completer`
 kiểm soát thứ tự resolve.
- [ ] (Tự làm) Xoá guard success → đúng 1 test đỏ với `'REMOTE
  PLAYER'` thay `'SECOND PLAYER'`; revert lại xanh.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m23/04 — "LeaderboardDialogViewModel — 4 state & stale guard" (VM dialog-scoped: ctor 2 repo, loadLeaderboard({isRefresh}) máy 4 state, _requestId monotonic guard stale-response cả success lẫn catch, fallback hàng-bạn từ profile local, guest seam _currentLeaderboardUserId→null; +9 test → 184; chưa có UI consumer).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. VM sống TRONG dialog (dialog-scoped — file tồn tại nhưng CHƯA có widget nào dùng; provider tạo ở BÀI 5). `AuthRepository` trên ctor là seam M24 — giờ CHỈ 2 repo + `_currentLeaderboardUserId() → null` kèm comment M24 là ĐÚNG.

EXPECTED STATE SAU BÀI NÀY:
- `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart` (FILE MỚI ~173 dòng, STRICT): `ChangeNotifier` + ctor `(leaderboardRepository, userProfileRepository)` — đúng 2 param, KHÔNG auth; `_state = const LeaderboardPopupLoading()`; `_requestId`/`_isDisposed` private; `state` getter.
- `loadLeaderboard({bool isRefresh = false})` (STRICT thứ tự): `_isDisposed → return`; `final requestId = ++_requestId` TRƯỚC await (STRICT — tăng sau await là guard ngược); `previousState = _state`; `isRefresh && previous is Success → _setState(Success(entries: previous.entries, currentEntry: previous.currentEntry, isRefreshing: true))` (GIỮ list cũ, chỉ flag); else `_setState(const LeaderboardPopupLoading())`; `try { snapshot = await repo.loadLeaderboard(currentUserId: _currentLeaderboardUserId()); if (!_isLatestRequest(requestId)) return;` (STRICT guard SAU await TRƯỚC setState) `snapshot.entries.isEmpty && snapshot.currentEntry == null → LeaderboardPopupEmpty()` else `LeaderboardPopupSuccess(entries:, currentEntry: _profileBackedCurrentLeaderboardEntry(snapshot.currentEntry))`; `catch → if (!_isLatestRequest(requestId)) return; LeaderboardPopupError()` (STRICT guard trong catch cũng có — stale error không được phủ).
- Helpers (STRICT): `retry() → unawaited(loadLeaderboard())` (load thường, KHÔNG isRefresh); `refresh() → loadLeaderboard(isRefresh: true)`; `_currentLeaderboardUserId() → null` (guest seam + comment M24 — KHÔNG switch authState); `_profileBackedCurrentLeaderboardEntry` — remote có → dùng số liệu remote, `avatarUrl` ưu tiên profile mới hơn; remote null → dựng từ `userProfileStream.value` (name/level/score/avatar) + rank mượn `currentLeaderboardEntry.rank` (125); `_formatScore` = `formatVnd(amount).replaceAll(' VNĐ','')`; `_isLatestRequest(id) => !_isDisposed && id == _requestId`; `_setState` guard `_isDisposed`; `dispose` set `_isDisposed = true` TRƯỚC `super.dispose()`.
- `test/view_models/leaderboard/leaderboard_dialog_view_model_test.dart` (FILE MỚI, STRICT 9 test): state đầu Loading (ctor không auto-load); success → entries + currentEntry + `lastCurrentUserId == null` + `loadCallCount == 1`; snapshot rỗng cả hai → Empty; repo throw → Error(loadError); `refresh()` giữ entries cũ + isRefreshing true→false; STALE — hai Completer, complete #2 trước → 'SECOND PLAYER', complete #1 sau → vẫn 'SECOND PLAYER' (không 'REMOTE PLAYER'); `retry()` → Loading→Success + loadCallCount tăng; remote currentEntry null → hàng từ FakeUserProfileRepository; remote có → số liệu remote + avatarUrl ưu tiên profile.
- `flutter analyze` sạch; `flutter test` → **184/184** (STRICT 175 + 9).
- KHÔNG ĐƯỢC có (chưa đến): `AuthRepository` ctor param + `switch(authState)` (M24 — seam cố ý); ai `context.watch<LeaderboardDialogViewModel>`/provider tạo nó (BÀI 5); `MenuLeaderboardRequested`/`requestLeaderboardDialog`/`showLeaderboardDialog`/widget leaderboard (BÀI 5); `DreChangeNotifier`/`asyncOp`/huỷ request thật (M26 — `_requestId` đã đủ); taxonomy lỗi network-vs-4xx (senior cũng chỉ `catch → Error`).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- Repo cluster Bài 2–3: contract + Snapshot + EntryData + PopupState 4 variant + hai impl + `entryFromRow` seam + `FakeLeaderboardRepository` 3-mode + scope contract-provider + main ternary; `SupabaseEnvironment` (Bài 1); M22 đỉnh (VM-save, `userProfileStream.value` — nguồn fallback); M21 layer; M20 lifelines; M14–M18 nền.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. Thiếu `_isLatestRequest` ở một nhánh = NEEDS_FIX (test stale đỏ đúng kịch bản nó chặn).

OUTPUT (đúng format; mục trống → "None"):
LESSON: m23/04
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
