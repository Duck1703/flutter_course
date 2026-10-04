---
title: "Bài 4 · Áp kết quả & reset"
description: "applyGameResult trên model, apply-once khi route pop, persist ngay sau khi áp, nút ĐẶT LẠI HỒ SƠ, và test SharedPreferences.setMockInitialValues."
sidebar:
  label: "Bài 4 · Áp kết quả & reset"
  order: 4
---

## Mục tiêu

Nối đầy đủ vòng đời dữ liệu: menu nhận `GameResult` → áp vào profile
đúng một lần → `save()` xuống disk ngay; thêm nút **ĐẶT LẠI HỒ SƠ**
và viết test chứng minh persistence sống qua "lần mở app thứ hai".

## Bạn đang ở đâu

- Milestone: **M10** (bài 4/4 — chốt milestone)
- App hiện tại: `ProfileStore` (bài 1) + `toMap`/`fromMap` (bài 2) +
  `GameResult` đi về qua `pop(result)` (bài 3). Menu vẫn đang load
  profile demo của M05.

## Vì sao việc này quan trọng ngay bây giờ

Đây là bài "đóng mạch": ba bài trước là linh kiện, bài này lắp thành
hành vi cuối cùng — *chơi xong về menu thấy stats đổi, tắt app mở lại
vẫn còn*. Một vài quyết định nhỏ ở đây là bản chất của persistence:

- **Chính sách tiến trình nằm trên model** (`applyGameResult`), không
  rải `gamesJoined + 1` khắp UI.
- **`save` chạy *sau* `setState` và được `await`** — UI cập nhật trước,
  ghi disk nối ngay sau, không bỏ lỡ.
- **Reset = `reset()` ghi profile mặc định** — đúng semantics senior:
  `resetUserProfile()` trong `user_profile_repository.dart` là
  `saveUserProfile(const UserProfileData())`, tức GHI default đè lên
  key chứ không xoá key. Course làm y hệt từ đây trở đi.

## Bạn đã biết gì

- `setState` sau `await` + `mounted` (M05); `FutureBuilder` giữ
  `_profileLoadFuture` (M05).
- `GameResult` và `pop(result)` (bài 3); `ProfileStore` (bài 1).

## Mental model mới

**Ai áp kết quả? — model.** `UserProfileData.applyGameResult(result)`
là nơi duy nhất hiểu "thắng nghĩa là +1 won, đúng mỗi câu = +X tiền
+Y EXP". UI chỉ gọi và lưu — mai đổi luật (M22) sửa một chỗ.

```
onPlayTap():
  push<GameResult>() ──await──► result? == null → return (bỏ cuộc)
                                    │
        applyGameResult(result) ──► profile MỚI ──► setState (UI đổi)
                                    │
                                    └──► await store.save(profile MỚI)
```

Apply-once không cần cờ: Future của route chỉ hoàn thành một lần.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| method trên model | `profile.applyGameResult(result)` | Chính sách đi kèm dữ liệu — OOP đúng chỗ |
| `?.`/`is`-guarded pop | `if (!mounted \|\| result == null) return;` | `result` kiểu `GameResult?` vì pop trần cho null |
| `SharedPreferences.setMockInitialValues` | `SharedPreferences.setMockInitialValues({});` | Test: thay platform channel bằng kho in-memory |
| hằng chính sách | `moneyPerCorrectAnswer = 50000` | Con số luật chơi đặt tên — dễ đổi, dễ giải thích |

## Flutter cần dùng

Không widget mới — thêm một `GestureDetector` pill cho nút reset theo
đúng phong cách các nút hiện có.

## Android / Compose bridge

- SIMILARITY: toàn flow ≈ `viewModel.update { it.applyResult(res) }` +
  `repo.save()` trong `onActivityResult`/`navigate` callback — nhận
  kết quả màn con, đổi state, persist.
- IMPORTANT DIFFERENCE: ở đây *menu widget* giữ `_profile` bằng
  `setState` — không có tầng VM giữa. Bạn sẽ *cảm thấy* `_MenuScreenState`
  ôm cả load lẫn áp kết quả lẫn reset — đó là vật liệu tạo động lực cho
  M11 (ChangeNotifier).
- DO NOT ASSUME: `await navigator.push` xong là "an toàn tuyệt đối" —
  `mounted` vẫn phải check; State menu có thể đã dispose nếu route
  stack thay đổi bởi nhánh khác.

## Senior project connection

- `flutter-accelerator-ai/lib/view_models/game/bridge/game_screen_view_model_result_persistence.dart` —
  `_saveGameResult` làm đúng ba bước của ta (load → áp chính sách →
  `saveUserProfile`), chỉ khác: senior đọc profile hiện tại từ repo
  ngay trong VM; learner đọc từ field `_profile` đã-load của menu vì
  storage chưa có tầng giữa. Chính sách cộng trùng khớp:
  `gamesJoined + 1`, `gamesWon + (isWin ? 1 : 0)`, cộng tiền + EXP.
- Senior có thang thưởng thật nên `earnedAmount` đến từ game; learner
  dùng `moneyPerCorrectAnswer = 50.000` phẳng — ghi rõ là tạm, M20/M22
  sẽ có thang.

## Build it step by step

### Bước 1 — `applyGameResult` trên model

```dart
// lib/data/profile/user_profile_data.dart — THÊM (và import
// '../game/game_result.dart' đầu file):

/// Tiền thưởng cho MỖI câu đúng — chính sách phẳng tạm thời
/// (thang thưởng thật là M20/M22).
static const int moneyPerCorrectAnswer = 50000;

/// EXP cho MỖI câu đúng — hằng riêng vì nếu cộng nguyên số tiền
/// như senior thì với thang phẳng EXP tràn quá nhanh.
static const int expPerCorrectAnswer = 50;

/// Áp kết quả một phiên chơi — trả về profile MỚI (bất biến).
UserProfileData applyGameResult(GameResult result) {
  return copyWith(
    gamesJoined: gamesJoined + 1,
    gamesWon: gamesWon + (result.won ? 1 : 0),
    totalMoneyWon:
        totalMoneyWon + result.correctAnswers * moneyPerCorrectAnswer,
  ).gainExp(result.correctAnswers * expPerCorrectAnswer);
}
```

`copyWith(...)` trước rồi `.gainExp(...)` — mượn lại logic lên cấp đã
test ở M04 thay vì viết lại.

### Bước 2 — `MenuScreen` nhận store + đổi `_loadProfile`/`_onPlayTap`

```dart
// lib/screens/menu_screen.dart
class MenuScreen extends StatefulWidget {
  /// Store do main() tạo và truyền xuống qua constructor — M12 sẽ
  /// thay đường truyền tay này bằng Provider.
  final ProfileStore profileStore;

  const MenuScreen({super.key, required this.profileStore});
  // ...
}
```

```dart
// _MenuScreenState:
Future<void> _loadProfile() async {
  final loaded = await widget.profileStore.load();   // M10: thay loadDemoProfile()
  if (!mounted) return;
  setState(() {
    _profile = loaded;
  });
}

Future<void> _onPlayTap() async {
  setState(() {
    _playTapCount++;
  });
  final result = await Navigator.of(context).push<GameResult>(
    MaterialPageRoute<GameResult>(
      builder: (context) => const GameScreen(),
    ),
  );
  if (!mounted || result == null) return;

  final updated = _profile.applyGameResult(result);
  setState(() {
    _profile = updated;
  });
  await widget.profileStore.save(updated);
}

/// Đặt lại hồ sơ: GHI profile mặc định xuống prefs rồi đưa UI về
/// mặc định — semantics giống `resetUserProfile()` của senior.
Future<void> _resetProfile() async {
  await widget.profileStore.reset();
  if (!mounted) return;
  setState(() {
    _profile = const UserProfileData();
  });
}
```

- Bỏ import `demo_profile_loader.dart` — **và hãy xoá hẳn file
  `lib/data/profile/demo_profile_loader.dart` cùng test của nó**: app
  không còn dùng nó từ M10 (store thật đã thay). Đây là scaffold đã
  hết nhiệm vụ — đừng để dead code sống sót trong app thật.
- `gainExp(10)` mỗi lượt bấm **biến mất**: tiến trình giờ đến từ kết
  quả thật, tap-counter chỉ còn là counter hiển thị của M03.

### Bước 3 — Nút ĐẶT LẠI HỒ SƠ trong `_MenuBody`

`_MenuBody` nhận thêm `onReset` và render cuối cột (bọc Column trong
`SingleChildScrollView` để màn thấp không tràn):

```dart
// _MenuBody — cuối children, sau _SessionTickerCard:
const SizedBox(height: MenuTokens.spacingSm),
_ResetButton(onTap: onReset),
```

```dart
/// Nút reset — scaffold chỉ-của-course để thấy rõ reset-action của M10.
/// (Senior không có nút này trên menu; nó retire ở M24 khi sign-out
/// dialog gọi `resetUserProfile()` thay.)
class _ResetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ResetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MenuTokens.spacingMd,
            vertical: MenuTokens.spacingXs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MenuTokens.radiusPill),
            border: Border.all(color: MenuTokens.cardBorder),
          ),
          child: const Text(
            'ĐẶT LẠI HỒ SƠ',
            style: TextStyle(
              color: MenuTokens.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
```

### Bước 4 — `main()` truyền store

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final profileStore = ProfileStore(await SharedPreferences.getInstance());
  runApp(AIMillionaireApp(profileStore: profileStore));
}

class AIMillionaireApp extends StatelessWidget {
  final ProfileStore profileStore;
  const AIMillionaireApp({super.key, required this.profileStore});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // … theme giữ nguyên …
      home: MenuScreen(profileStore: profileStore),
    );
  }
}
```

### Bước 5 — Test persistence

```dart
// test/profile_store_test.dart — FILE MỚI
import 'package:shared_preferences/shared_preferences.dart';

Future<ProfileStore> makeStore(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  return ProfileStore(await SharedPreferences.getInstance());
}

void main() {
  test('save rồi load → round-trip giữ nguyên profile', () async {
    final store = await makeStore(const {});
    const profile = UserProfileData(totalMoneyWon: 200000, gamesJoined: 3);

    await store.save(profile);
    final reopened = await SharedPreferences.getInstance();
    expect(await ProfileStore(reopened).load(), equals(profile));
  });

  test('chuỗi JSON hỏng → load trả mặc định, không throw', () async {
    final store = await makeStore(const {'user_profile': '{không phải json'});
    expect(await store.load(), equals(const UserProfileData()));
  });
  // … vắng key, JSON không phải Map, thiếu field, clear — xem file test
}
```

Widget test "VỀ MENU → …" đã cập nhật để đọc thẳng prefs và thấy
`"gamesJoined":1` — xem `test/widgets/game_screen_test.dart`.

## Hiểu code

- **`save` đặt *sau* `setState`** — UI phản hồi trước, disk theo sau;
  ngược lại thì người chơi chờ một nhịp write trước khi thấy stats.
  Nếu `save` ném `StateError`, profile trong RAM vẫn đúng — chỉ lần mở
  sau thiếu (đủ hiếm để chấp nhận; M14 repository stream sẽ chặt hơn).
- **Sao menu áp result chứ không phải game tự lưu?** — Game không
  giữ `ProfileStore`, và không nên giữ: menu là "điểm hội tụ" profile;
  một push = một result = một lần áp, dễ kiểm chứng bằng đếm trên disk.
- **`reset()` ghi default đè key, không `remove()`** — đó là đúng
  semantics của senior (`resetUserProfile()` = `saveUserProfile(
  const UserProfileData())`). Đừng nhầm với `clear()` (xoá hẳn key) —
  ở đây "chưa từng lưu" và "đã reset" là hai trạng thái disk khác nhau,
  giống senior.

## Chạy và quan sát

- `flutter run`: mở app → hồ sơ *mặc định* (lần đầu, chưa có key).
  Chơi một ván, thua → về menu: **Đã chơi = 1**, tỉ lệ `0%`. Đóng app,
  mở lại → stats vẫn **1 / 0%** — persistence thật.
- Bấm **ĐẶT LẠI HỒ SƠ** → stats về `0 / —` ngay; mở lại app vẫn mặc
  định (key đã bị ghi đè bởi profile mặc định — đúng semantics senior).
- `flutter test` — 43 test xanh gồm round-trip, corrupt-JSON, và
  widget test kiểm chứng `"gamesJoined":1` trên disk.

## Lỗi hay gặp

1. **`await Navigator.push` mà quên `mounted`** — menu State có thể đã
   dispose (ví dụ route bị thay); `setState` sau đó ném. Guard luôn.
2. **Áp result khi `result == null`** — back AppBar trả null; nếu áp
   bừa thì bỏ cuộc cũng +1 ván. Guard `result == null` trước.
3. **`save` fire-and-forget** — bỏ `await` → trình tự "đóng app ngay
   sau khi về menu" có thể mất ghi. `await` nó.
4. **Quên cập nhật hai widget test pump `MenuScreen()`** — signature
   mới bắt `profileStore`; test cũ không compile.

## Kiểm tra hiểu biết

1. Vì sao `applyGameResult` trả `UserProfileData` mới thay vì sửa tại
   chỗ? — *Model bất biến của M04: field `final`, mọi "thay đổi" là
   object mới — ai giữ bản cũ không bị nhiễu, `==`/diff vẫn đúng.*
2. Nếu game pop hai lần (bug), result áp mấy lần? — *Không áp thêm:
   route đã pop thì Future chỉ hoàn thành một lần; pop thứ hai trên
   route đã rời stack là no-op/lỗi khác, không chạm lại `_onPlayTap`.*
3. `prefs.remove(key)` và `prefs.setString(key, '')` khác nhau chỗ nào
   cho `load()`? — *`remove` → `getString` trả null → default sạch;
   `''` → `jsonDecode` ném `FormatException` → may mắn cũng default,
   nhưng key vẫn tồn tại và mỗi lần load đều đi nhánh exception. Và
   `reset()` của ta là cách thứ ba: `setString(key, jsonEncode(defaults))`
   — ghi default đè, đúng semantics `resetUserProfile` của senior.*

## Tự làm

**Tự viết test — không copy.** `ProfileStore` đã có `load/save/reset`.
Viết **hai** test mới trong `test/` kiểm chứng `reset()` và corrupt data:

1. `reset()` ghi profile mặc định: save một profile → `await
   store.reset()` → `await store.load()` trả gì — `null`, exception,
   hay `UserProfileData` mặc định? Đọc `reset()` trong `ProfileStore`
   trước, dự đoán, rồi test.
2. Corrupt: ghi thẳng `'user_profile'` = `'[1,2,3]'` — JSON *hợp lệ*
   nhưng không phải Map (bypass `save`) → `load()` trả gì? Đọc nhánh
   `decoded is Map` và `on FormatException` trong `load()` trước, dự
   đoán, rồi test.
3. `makeStore` bọc `SharedPreferences.setMockInitialValues` — nếu bỏ
   sót lệnh đó, test nào fail và vì sao?

:::note[Gợi ý]
`makeStore` (Bước 5) đã bọc `SharedPreferences.setMockInitialValues` —
prefs in-memory cho test, không cần device. `try/on FormatException`
nằm trong `load()`, không phải `fromMap`: mọi nhánh xấu (chưa có key,
chuỗi không phải JSON, JSON không phải Map) đều trả `UserProfileData`
mặc định — `load()` **không bao giờ** trả `null`.
:::

<details><summary><strong>Đáp án</strong></summary>

```dart
test('reset ghi profile mặc định đè lên key (không xoá key)', () async {
  final store = await makeStore(const {});
  await store.save(const UserProfileData(
      username: 'Lan', totalMoneyWon: 200000, gamesJoined: 3));
  await store.reset();
  // `reset()` = `save(const UserProfileData())` — load trả mặc định.
  expect(await store.load(), equals(const UserProfileData()));
});

test('JSON hợp lệ nhưng không phải Map → load trả mặc định', () async {
  final store = await makeStore(const {'user_profile': '[1,2,3]'});
  expect(await store.load(), equals(const UserProfileData()));
});
```

Nếu `setMockInitialValues` bị bỏ sót: `SharedPreferences.getInstance`
trong test không có platform channel → `MissingPluginException` — cả
hai test đều fail ngay tại `makeStore`.

</details>

## Ta cố ý chưa thêm

- Cập nhật profile *live khi đang chơi* — cần repository stream (M14).
- Confirm-dialog cho reset — UI dialog layer là M21; senior không có
  nút reset trên menu (reset đi qua sign-out dialog, M24) — nút này là
  scaffold tạm thời của course, sẽ tháo ra ở M24.
- Skeleton trạng thái "đang lưu" — đủ nhỏ để chưa cần.

## Checkpoint hoàn thành

- [ ] `main()` tạo `ProfileStore`, truyền `AIMillionaireApp` → `MenuScreen`.
- [ ] Menu load từ `profileStore.load()`; `_onPlayTap` await result,
  `applyGameResult`, `await save`.
- [ ] Nút **ĐẶT LẠI HỒ SƠ** gọi `reset()` (ghi default) + reset UI.
- [ ] Test xanh: round-trip, corrupt/missing/partial JSON, `reset`,
  và widget test "VỀ MENU → gamesJoined=1 trên disk".
- [ ] Chơi → restart app → stats còn nguyên (kiểm tay).

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m10/04 — "Áp kết quả & reset" (bài cuối M10 — vòng đời persistence đóng mạch: chơi → result → áp profile → save → sống qua restart app).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter test test/profile_store_test.dart`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Trọng tâm: chính sách tiến trình nằm TRÊN MODEL; save await sau setState; reset ghi default (không xoá key); demo loader đã bị xoá.

EXPECTED STATE SAU BÀI NÀY:
- `UserProfileData` có `static const int moneyPerCorrectAnswer = 50000` + `static const int expPerCorrectAnswer = 50` (STRICT hai hằng chính sách phẳng) và method `UserProfileData applyGameResult(GameResult result)` trả profile MỚI qua `copyWith(gamesJoined: +1, gamesWon: +(won?1:0), totalMoneyWon: + correct*50000).gainExp(correct*50)` (STRICT: trên model, trả object mới, mượn gainExp M04); import `../game/game_result.dart` có mặt.
- `MenuScreen` có `final ProfileStore profileStore` + ctor `required this.profileStore` (STRICT truyền tay qua ctor — chưa Provider); `_loadProfile` dùng `await widget.profileStore.load()` (STRICT — `loadDemoProfile()` đã biến mất cùng file `lib/data/profile/demo_profile_loader.dart` + test của nó BỊ XOÁ; còn file demo sót = DIVERGED/dead code).
- `_onPlayTap`: `_playTapCount++` trong setState → `final result = await Navigator.of(context).push<GameResult>(MaterialPageRoute<GameResult>(builder: (context) => const GameScreen()))` → `if (!mounted || result == null) return;` → `final updated = _profile.applyGameResult(result);` → `setState` gán `_profile = updated` → `await widget.profileStore.save(updated)` (STRICT thứ tự: guard null+mounted → áp → setState → await save; `gainExp(10)` mỗi tap đã BỊ XOÁ — tiến trình giờ từ result thật).
- `_resetProfile()`: `await widget.profileStore.reset();` → `if (!mounted) return;` → `setState(_profile = const UserProfileData())` (STRICT reset=ghi default đè).
- `_MenuBody` nhận `onReset`, render `_ResetButton` cuối cột (text 'ĐẶT LẠI HỒ SƠ', pill border thứ cấp); body bọc `SingleChildScrollView` (semantic).
- `main()`: `final profileStore = ProfileStore(await SharedPreferences.getInstance()); runApp(AIMillionaireApp(profileStore: profileStore))` và `MaterialApp(home: MenuScreen(profileStore: profileStore))` (STRICT chuỗi truyền main→app→menu).
- `test/profile_store_test.dart` tồn tại với helper `makeStore` dùng `SharedPreferences.setMockInitialValues` + test round-trip save→load, corrupt-JSON→default, reset→default (STRICT mock-values technique); widget test menu/game đã cập nhật truyền `profileStore` (STRICT — signature bắt buộc giờ).
- `flutter test` → "All tests passed!" ~43; `flutter analyze` → "No issues found!"; kiểm tay: chơi 1 ván → stats đổi → kill app mở lại → stats còn.

INVARIANTS NỀN:
- `ProfileStore`/`toMap`/`fromMap`/`GameResult`/dialog-action của bài 1–3; game phase machine + timer M09; StreamBuilder ticker M06; route M07; chưa có Provider/repository interface/stream profile.

Mục (STRICT) phải đúng; mục khác chấm semantic (giá trị hằng có thể khác nếu bài cho phép — nhưng 50000/50 là số bài viết). Code vượt checkpoint (đã có Provider/repository stream) → `AHEAD_RISKY` nếu đảo cấu trúc bài tới; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m10/04
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
