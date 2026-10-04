---
title: "Bài 3 · Lifecycle, callback & state ở đâu"
description: "initState/dispose, pattern data-down-events-up, và nguyên tắc state sống ở tổ tiên chung thấp nhất."
sidebar:
  label: "Bài 3 · Lifecycle & ownership"
  order: 3
---

## Mục tiêu

Sau bài này bạn biết `initState`/`dispose` chạy khi nào và để làm gì, giải
thích được pattern "data xuống — event lên" qua `VoidCallback`, và chọn đúng
vị trí đặt state (tổ tiên chung thấp nhất của ai đọc + ai ghi). Đây là bài
chốt M03.

## Bạn đang ở đâu

- Milestone: **M03** (bài 3/3 — cuối milestone)
- App hiện tại: menu tương tác hoàn chỉnh (bài 1–2): toggle âm thanh, đếm bấm.

## Vì sao việc này quan trọng ngay bây giờ

`setState` chạy được nhưng còn hai câu hỏi lớn: **state sống/chết khi nào**
(lifecycle) và **ai nên giữ nó** (ownership). Trả lời sai câu hai = bug mẹo
mất state sau này; trả lời đúng giờ thì M12 Provider chỉ là "đặt state cao
hơn" chứ không phải ma thuật.

## Bạn đã biết gì

- `State<T>`, `setState`, `VoidCallback`, `GestureDetector` (bài 1–2);
  hot reload giữ state / hot restart reset (M01 + quan sát bài 1 M03).

## Mental model mới

**`State` có vòng đời** — nó được tạo khi widget lần đầu xuất hiện trên cây,
và bị huỷ khi vị trí đó biến mất vĩnh viễn:

```
gắn vào cây        rebuild (0..n lần)           gỡ khỏi cây
    │                      │                         │
createState()        build() × n                  dispose()
initState()                                        │
    │                                        (dọn tài nguyên)
```

Hai mốc duy nhất ta dùng ở M03:

- `initState()` — chạy **đúng một lần** sau khi State được tạo, trước build
  đầu tiên. Chỗ khởi tạo: controller, đọc tham số ban đầu, subscribe…
- `dispose()` — chạy **đúng một lần** khi State sắp bị huỷ. Chỗ dọn dẹp:
  huỷ controller, huỷ listener — tránh leak.

Và nguyên tắc ownership: **state sống ở tổ tiên chung thấp nhất của mọi widget
đọc hoặc ghi nó.** `_soundOn` cần được `_ProfileHeader` hiển thị *và* đổi bởi
tap → nó ở `_MenuScreenState` (tổ tiên của header). Nếu đặt trong
`_IconBadge`, header-caption không đọc được.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `super.method()` | `super.initState();` | Gọi bản cha — **bắt buộc** khi override lifecycle |
| `widget.x` | `widget.tapCount` | Trong `State`, `widget` trỏ tới instance Widget hiện tại — đọc param widget (ví dụ minh hoạ bên dưới) |
| `!` trên `?` | `callback!()` | — *(chỉ nhắc, không dùng trong code)* |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `initState()` | Một lần lúc tạo State — `super.initState()` **đầu tiên** |
| `dispose()` | Một lần lúc huỷ — `super.dispose()` **cuối cùng** |
| `debugPrint` | Log lifecycle ra console DevTools/terminal |
| `GestureDetector` | Ôn lại: event đi *lên* qua callback |

## Ví dụ độc lập — `ScoreBoard` + `ScoreChip`

Trước khi bàn ownership trong menu, nhìn quy tắc "state đi xuống, sự kiện
đi lên" trong ~30 dòng trung lập — chạy được trong DartPad (chế độ
Flutter):

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      home: Scaffold(body: Center(child: ScoreBoard())),
    ));

class ScoreBoard extends StatefulWidget {
  const ScoreBoard({super.key});

  @override
  State<ScoreBoard> createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    return ScoreChip(
      score: _score,
      onTap: () => setState(() => _score++),
    );
  }
}

class ScoreChip extends StatelessWidget {
  final int score;
  final VoidCallback onTap;

  const ScoreChip({required this.score, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text('Điểm: $score'),
    );
  }
}
```

Ai sở hữu `_score`? **`_ScoreBoardState`** — vì nó là nơi duy nhất cần
*nhớ và đổi* giá trị. `ScoreChip` chỉ nhận `score` để hiển thị và nhận
`onTap` để "gọi ngược lên" — nó không biết `setState` là gì, và đó là
thiết kế tốt: widget con càng ít biết, càng tái dùng được.

Đây chính là quan hệ `_MenuScreenState` ↔ `_ProfileHeader`/`_PlayButton`
trong app của bạn — cùng quy tắc "tổ tiên chung thấp nhất".

## Cầu nối Android / Compose

- SIMILARITY: `initState` ≈ `LaunchedEffect(Unit)` (chạy một lần khi vào
  composition) hoặc `onCreate`/`init` của ViewModel ở phạm vi nhỏ; `dispose` ≈
  `DisposableEffect`'s `onDispose` / `onCleared`.
- IMPORTANT DIFFERENCE: `initState` không nhận `BuildContext` "sẵn sàng cho
  mọi việc" — context đã tồn tại nhưng một số API cần chờ (`dependOnInheritedWidget`
  bị cấm trong initState; M12 khi Provider vào sẽ gặp
  `didChangeDependencies`).
- DO NOT ASSUME: "activity destroyed → state chết" mapping 1:1 — `dispose`
  gắn với **vị trí trên cây widget**, không phải vòng đời Activity; hot
  reload *giữ* State, hot restart mới tạo lại (initState chạy lại).

## Trong project senior

- File: `flutter-accelerator-ai/lib/screens/menu_screen.dart` —
  `_MenuScreenState.initState`/`dispose` của senior quản lý controller +
  animation; ta dùng đúng hai mốc này để **log quan sát** — cùng vị trí, đơn
  giản hơn nội dung.
- File: `flutter-accelerator-ai/lib/widgets/menu/gradient_cta_button.dart` —
  `onTap` truyền từ cha xuống qua constructor: senior cũng dùng
  data-down-events-up (sau này qua ViewModel).

## Từng bước thực hiện

### Bước 1 — Thêm lifecycle log vào `_MenuScreenState`

Trong `lib/screens/menu_screen.dart`, thêm hai override vào `_MenuScreenState`
(ngay sau hai field):

```dart
// lib/screens/menu_screen.dart — trong _MenuScreenState
class _MenuScreenState extends State<MenuScreen> {
  bool _soundOn = true;
  int _playTapCount = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('[MenuScreen] initState — State được tạo');
  }

  @override
  void dispose() {
    debugPrint('[MenuScreen] dispose — State bị huỷ');
    super.dispose();
  }

  // …_toggleSound, _onPlayTap, build giữ nguyên…
}
```

- `super.initState()` gọi **đầu** — cha khởi tạo xong mới tới ta.
- `super.dispose()` gọi **cuối** — ta dọn xong mới trả cho cha huỷ. Thứ tự
  này là convention bắt buộc của Flutter (và lỗi rất khó chịu nếu quên).
- `debugPrint` — đã gặp bài 2; log sẽ in ra console/DevTools.

### Bước 2 — Quan sát lifecycle thật

`flutter run -d chrome`, mở terminal/DevTools log:

- App vừa chạy → `[MenuScreen] initState — State được tạo` in **một lần**.
- Bấm nút/badge → build chạy lại nhưng **không** có initState mới — State
  sống xuyên rebuild.
- Hot reload (`r`) → vẫn không initState — State được **giữ** qua reload
  (đếm giữ nguyên!).
- Hot restart (`R`) → `initState` in lại — `main()` chạy lại, app tạo cây
  mới → State mới → đếm về 0.
- `dispose` sẽ in khi màn này bị gỡ — hiện tại `MenuScreen` là `home` duy
  nhất nên bạn chỉ thấy nó khi app tắt/restart (và đó là **dấu hiệu** ta chưa
  có navigation — M07 sẽ cho `dispose` việc thật: chuyển màn).

### Bước 3 — Đọc lại callback dưới góc nhìn "ownership"

Không code mới — chỉ chỉ ra pattern đang có:

```
_MenuScreenState  ← state SỐNG ở đây (tổ tiên chung thấp nhất)
   │  data xuống            │  event lên
   ├─ _ProfileHeader(        │   onSoundTap() → _toggleSound()
   │    soundOn: _soundOn,   │      setState → _soundOn đổi
   │    onSoundTap: …)       │      → build() → icon/caption MỚI
   └─ _PlayButton(           │   onTap() → _onPlayTap()
        tapCount: _playTap…  │      setState → _playTapCount++
```

`_ProfileHeader`/`_PlayButton` là `StatelessWidget` và **không biết** state
là gì: chúng nhận giá trị + hàm, hiển thị giá trị, gọi hàm khi bấm. Mọi
"nhớ" tập trung một nơi — dễ debug, dễ test sau này (M04).

Trong `State`, đọc param của widget qua `widget.` — ví dụ nếu cần log param
`title` của `MenuScreen`, bạn viết `widget.title`. (App ta không dùng — chỉ
giới thiệu để bạn nhận ra khi gặp ở senior code, vd. `widget.onTap`.)

## Đọc hiểu code

`_MenuScreenState` đầy đủ (đúng file verify):

```dart
class _MenuScreenState extends State<MenuScreen> {
  bool _soundOn = true;
  int _playTapCount = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('[MenuScreen] initState — State được tạo');
  }

  @override
  void dispose() {
    debugPrint('[MenuScreen] dispose — State bị huỷ');
    super.dispose();
  }

  void _toggleSound() {
    setState(() {
      _soundOn = !_soundOn;
    });
  }

  void _onPlayTap() {
    setState(() {
      _playTapCount++;
    });
  }

  @override
  Widget build(BuildContext context) { /* cây Scaffold như M02 + params */ }
}
```

## Chạy và quan sát

- `flutter run -d chrome` + theo dõi console: initState 1 lần → bấm (không
  initState) → `r` (giữ state) → `R` (initState lại + state reset).
- Vặn nút âm lượng OS/không liên quan: không in gì — lifecycle này là của
  *widget tree*, không phải hệ thống.

## Lỗi thường gặp

1. **Quên `super.initState()`/`super.dispose()`** — State cha không khởi
   tạo/dọn đúng → lỗi tinh vi. Convention: super đầu ở init, super cuối ở
   dispose.
2. **`setState` trong `initState`** — không cần (build đầu chưa chạy, gán
   thẳng được). `setState` ở đây **không lỗi** — chỉ *thừa*: nó vẫn lên
   lịch rebuild cho một frame sẽ build từ đầu.
3. **Đặt state sai tầng** — `_soundOn` trong `_IconBadge` thì caption header
   không đọc được; nguyên tắc: tổ tiên chung thấp nhất của *reader + writer*.
4. **"Nhớ" trong biến local của `build`** — `var count = 0` trong build: mỗi
   rebuild tạo lại — không phải state, chỉ là biến tạm.
5. **Làm việc nặng trong `dispose` chậm** — dispose phải nhanh và đồng bộ.

## Kiểm tra hiểu biết

1. Khi nào `initState` chạy? — Đúng một lần sau `createState`, trước build
   đầu tiên; hot reload *không* gọi lại, hot restart *có* (State mới).
2. Thứ tự `super` đúng? — `super.initState()` đầu hàm; `super.dispose()`
   cuối hàm.
3. Vì sao `_soundOn` ở `_MenuScreenState` chứ không ở `_ProfileHeader`? —
   Vì cả caption *và* icon trong header đều đọc nó; đặt sâu hơn sẽ không với
   tới từ nơi khác. Ownership = tổ tiên chung thấp nhất.
4. "Data down, events up" nghĩa gì? — Cha truyền giá trị xuống qua params;
   con báo sự kiện lên qua callback; mutation chỉ xảy ra trong State.

## Tự làm

**Tự tạo — không copy.** Không nhìn `_ProfileHeader`, hãy tự viết một
widget `_MuteDot` riêng:

- `StatelessWidget` nhận `bool muted` + `VoidCallback onTap` qua
  constructor (`required`, `super.key`).
- Hiển thị một `Icon` — đổi icon theo `muted` (`Icons.mic` /
  `Icons.mic_off`); tap gọi `onTap`.
- Trong `_MenuScreenState`, thêm `bool _muted = false;` + hàm
  `_toggleMuted()` dùng `setState`, và đặt `_MuteDot` cạnh
  `_ProfileHeader`.
- Dự đoán trước khi chạy: nếu `_toggleMuted` đổi `_muted` **không qua**
  `setState`, UI có đổi không? Kiểm chứng bằng cách thử.

:::note[Gợi ý]
Widget cha giữ state, con nhận *giá trị* + *callback* — đúng mô hình
data-down/events-up của bài này. `Icon(muted ? Icons.mic_off : Icons.mic)`.
:::

<details><summary><strong>Đáp án</strong></summary>

```dart
class _MuteDot extends StatelessWidget {
  const _MuteDot({required this.muted, required this.onTap, super.key});
  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(muted ? Icons.mic_off : Icons.mic),
    );
  }
}
```

Trong `State`: `bool _muted = false;` +
`void _toggleMuted() => setState(() => _muted = !_muted);` rồi đặt
`_MuteDot(muted: _muted, onTap: _toggleMuted)` trong `Column`.

Nếu bỏ `setState`: field vẫn đổi (in ra sẽ thấy), nhưng `build` không
chạy lại → UI đứng im — đúng bản chất "setState = báo dirty, không phải
đổi biến".
</details>

## Cố ý chưa làm

- Phần còn lại của lifecycle (`didChangeDependencies`, `didUpdateWidget`,
  `deactivate`…) — `didChangeDependencies` gặp ở M12 khi Provider vào app;
  phần còn lại giới thiệu khi app cần.
- `mounted` + guard `setState` sau async — M05.
- Navigation → màn chơi khi bấm CHƠI — **M07**; bấm nút hôm nay chỉ đếm.
- Lưu `_soundOn` — M10; state hiện mất khi restart (chính xác là "ephemeral").
- `ChangeNotifier`/Provider/Repository — M11–M14.

## Điểm kiểm tra hoàn thành — M03

- [ ] `_MenuScreenState` có `initState`/`dispose` với `debugPrint` + đúng thứ
      tự `super`.
- [ ] Quan sát log: initState một lần; reload giữ state; restart reset state.
- [ ] Giải thích được ownership của `_soundOn`/`_playTapCount`.
- [ ] `flutter analyze` → `No issues found!`; `flutter build web` thành công.
- [ ] Bấm badge đổi icon+caption; bấm nút tăng đếm — **và bấm CHƠI không đi
      đâu**, vì navigation là M07. Biết chính xác cái gì bị trì hoãn và vì sao.

**M03 hoàn thành.** Vertical slice đầu tiên (M01–M03) của course đã xong —
xem lại [Roadmap](/roadmap/) để biết M04 sẽ mang gì (model + test đầu tiên).

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m03/03 — "Lifecycle, callback & state ở đâu" (bài cuối M03 — checkpoint tích luỹ: menu tương tác phải đứng vững trước khi học model + test).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter build web`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Checkpoint cuối M03: cần xác nhận cả ownership (state ở `_MenuScreenState`, con là Stateless nhận value+callback) lẫn lifecycle mới thêm.

EXPECTED STATE SAU BÀI NÀY (trong `lib/screens/menu_screen.dart`):
- `_MenuScreenState` có `@override void initState()` gọi `super.initState()` ĐẦU hàm + `debugPrint` log tạo State, và `@override void dispose()` gọi `super.dispose()` CUỐI hàm + `debugPrint` log huỷ (STRICT thứ tự super — convention bắt buộc).
- `_MenuScreenState` vẫn sở hữu `_soundOn`/`_playTapCount` + `_toggleSound`/`_onPlayTap` qua `setState`; `_ProfileHeader`/`_PlayButton` vẫn StatelessWidget chỉ nhận value + `VoidCallback` (STRICT ownership: mutable state KHÔNG được nằm trong widget con, không có `setState` nào trong class Stateless).
- `MenuScreen` vẫn `StatefulWidget` chỉ có `const` ctor + `createState()` — không field.
- Nếu learner làm bài Tự làm: một `_MuteDot` StatelessWidget + field `_muted` trong `_MenuScreenState` có thể tồn tại — chấp nhận, đúng cùng pattern value-down/callback-up.
- `flutter analyze` → "No issues found!"; `flutter build web` thành công; chạy app in log initState một lần.

INVARIANTS NỀN (M01–M03 trọn gói):
- `pubspec.yaml` `name: ai_millionaire_course`, chỉ `flutter` dep, `test/widget_test.dart` đã xoá; `lib/core/menu_tokens.dart`; `lib/main.dart` → `MaterialApp` + `home: const MenuScreen()`; khung bọc `Scaffold → gradient → SafeArea → Center → ConstrainedBox 375 → Column ba vùng`; chưa có `Navigator`, repository, provider hay package ngoài SDK (tất cả là bài sau, KHÔNG chấm thiếu).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (đã thêm navigation/repo/provider) → `AHEAD_RISKY`/`DIVERGED` nếu nó phá nền bài tới; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m03/03
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
