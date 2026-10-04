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
  key chứ không xoá key. Learner làm y hệt từ remediation trở đi.

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
  const UserProfileData())`). Ban đầu course dùng `clear()` (xoá key)
  như một biến thể; remediation đã chỉnh lại — "chưa từng lưu" và
  "đã reset" giờ là hai trạng thái disk khác nhau, giống senior.

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

1. `reset()` xóa profile: save một profile → `await store.reset()` →
   `await store.load()` trả `null`.
2. Corrupt: ghi thẳng `prefs.setString(key, '{bad json')` (bypass
   `save`) → `load()` không throw — trả `null` hay `PlayerProfile`?
   Đọc `fromMap`/try-catch trước, dự đoán, rồi test.
3. `SharedPreferences.setMockInitialValues({})` ở `setUp` — nếu quên,
   test nào fail?

:::note[Gợi ý]
`SharedPreferences.setMockInitialValues` tạo prefs in-memory cho test —
không cần device. `fromMap` có `try/catch` → corrupt JSON → `null` chứ
không throw.
:::

<details><summary><strong>Đáp án</strong></summary>

```dart
setUp(() => SharedPreferences.setMockInitialValues({}));

test('reset clears saved profile', () async {
  final store = ProfileStore();
  await store.save(const PlayerProfile(displayName: 'Lan'));
  await store.reset();
  expect(await store.load(), isNull);
});

test('load returns null on corrupt json', () async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('player_profile', '{bad json');
  expect(await ProfileStore().load(), isNull);
});
```

Nếu quên `setMockInitialValues`: `SharedPreferences.getInstance` trong
test không có platform channel → `MissingPluginException` hoặc prefs
rỗng nhưng persist xuyên test → test flaky.

</details>

## Ta cố ý chưa thêm

- Cập nhật profile *live khi đang chơi* — cần repository stream (M14).
- Confirm-dialog cho reset — UI dialog layer là M21; senior không có
  nút reset trên menu (reset đi qua sign-out dialog, M24) — nút này là
  scaffold đã đăng ký trong fidelity register, retire M24.
- Skeleton trạng thái "đang lưu" — đủ nhỏ để chưa cần.

## Checkpoint hoàn thành

- [ ] `main()` tạo `ProfileStore`, truyền `AIMillionaireApp` → `MenuScreen`.
- [ ] Menu load từ `profileStore.load()`; `_onPlayTap` await result,
  `applyGameResult`, `await save`.
- [ ] Nút **ĐẶT LẠI HỒ SƠ** gọi `reset()` (ghi default) + reset UI.
- [ ] Test xanh: round-trip, corrupt/missing/partial JSON, `reset`,
  và widget test "VỀ MENU → gamesJoined=1 trên disk".
- [ ] Chơi → restart app → stats còn nguyên (kiểm tay).
