---
title: "Bài 1 · StatelessWidget vs StatefulWidget"
description: "Widget bất biến vs đối tượng State sống lâu — createState, field trong State, và chuyển MenuScreen sang StatefulWidget."
sidebar:
  label: "Bài 1 · Stateless vs Stateful"
  order: 1
---

## Mục tiêu

Sau bài này bạn giải thích được vì sao `StatefulWidget` cần **hai class**
(Widget + State), `createState()` làm gì, và chuyển `MenuScreen` sang
`StatefulWidget` với hai state field `_soundOn`/`_playTapCount` — màn hình
bắt đầu **phản ứng** khi bấm.

## Bạn đang ở đâu

- Milestone: **M03 — Interactivity với StatefulWidget & setState** (bài 1/3)
- App hiện tại: menu tĩnh hoàn chỉnh của M02 — bấm icon/nút không có gì xảy ra.

## Vì sao việc này quan trọng ngay bây giờ

Mọi widget ta viết đến giờ là `StatelessWidget`: `build()` nhận context, trả
cây — xong. Nhưng menu cần *nhớ*: âm thanh đang bật hay tắt? Nút được bấm bao
nhiêu lần? Những thứ "nhớ" này không sống được trong `StatelessWidget` —
bạn sẽ thấy chính xác vì sao ở bước 1.

## Bạn đã biết gì

- `StatelessWidget`, `build(BuildContext)`, widget bất biến (`final` field,
  `const` ctor) từ M01–M02.
- Composition: widget nhận tham số qua constructor (bài 3 M02).

## Mental model mới

Đây là **mental model quan trọng nhất của M03** — đọc chậm:

```
┌────────────────────────────────────────────────────────────┐
│  Widget (StatelessWidget / StatefulWidget)                 │
│  ─ BẤT BIẾN: chỉ có final field, tạo xong không sửa được   │
│  ─ RẺ & TẠM THỜI: bị huỷ/tạo lại mỗi lần rebuild           │
│  ─ Giống "bản mô tả" (description), không giữ trạng thái   │
├────────────────────────────────────────────────────────────┤
│  State<T> (chỉ StatefulWidget mới có)                      │
│  ─ SỐNG LÂU: một instance gắn với vị trí trên cây          │
│  ─ MUTABLE: field thay đổi được — đây là chỗ "nhớ"         │
│  ─ Giống "trạng thái sống" phía sau bản mô tả              │
└────────────────────────────────────────────────────────────┘
```

Khi bạn gọi `setState`, Flutter **không** huỷ State — nó tạo *widget mới*
thay widget cũ (widget vẫn bất biến!), rồi gọi `state.build()` lần nữa.
`State` sống xuyên qua các lần rebuild — đó là nơi duy nhất an toàn để giữ
dữ liệu thay đổi được trong widget tree.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `State<MenuScreen>` | `State<MenuScreen> createState()` | Generic: `State<T>` là "trạng thái của widget kiểu T" |
| `!` phủ định | `_soundOn = !_soundOn;` | Toán tử NOT trên `bool` — như Kotlin |
| `++` | `_playTapCount++;` | Tăng 1 — như Kotlin/Java |
| `$x` nội suy | `'Số lần bấm: $tapCount'` | `$tên` chèn giá trị vào string — ≈ `"$name"` Kotlin |
| `cond ? a : b` | `soundOn ? Icons.volume_up : Icons.volume_off` | Ternary — như Kotlin `if … else` expression |
| Hàm private | `void _toggleSound()` | `_` = private theo file/library |
| `VoidCallback` | `final VoidCallback onTap;` | Type có sẵn = `void Function()` — "hàm không tham số không trả về" |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `StatefulWidget` | Widget bất biến *có* State đi kèm |
| `createState()` | Factory: widget tạo đối tượng State của mình — Flutter gọi khi gắn widget vào cây |
| `State<T>` | Lớp giữ state sống lâu; chứa `build()` và các field mutable |
| `setState(fn)` | Báo Flutter "State này cần build lại" (chi tiết bài 2) |
| `GestureDetector` | Widget bắt gesture — `onTap:` nhận `VoidCallback` |
| `widget.field` | Trong `State`, `widget` trỏ về instance Widget hiện tại — đọc param của widget (bài 3 dùng) |

## Ví dụ độc lập — `LightSwitch`

Trước khi chuyển `MenuScreen`, nhìn toàn bộ cặp Widget+State trong ~25
dòng — không cần app Millionaire. Chạy được trong DartPad (chế độ
Flutter):

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      home: Scaffold(body: Center(child: LightSwitch())),
    ));

class LightSwitch extends StatefulWidget {
  const LightSwitch({super.key});

  @override
  State<LightSwitch> createState() => _LightSwitchState();
}

class _LightSwitchState extends State<LightSwitch> {
  bool _on = false; // ← chỗ duy nhất "nhớ" — nằm trong State, không trong widget

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _on = !_on),
      child: Icon(
        _on ? Icons.lightbulb : Icons.lightbulb_outline,
        size: 64,
        color: _on ? Colors.amber : Colors.grey,
      ),
    );
  }
}
```

Đọc theo mental model vừa học:

- `LightSwitch` **không có field nào** — widget vẫn bất biến trọn vẹn.
- `_on` sống trong `_LightSwitchState` — mutable, sống xuyên rebuild.
- Tap → `setState` báo dirty → frame sau `build()` đọc `_on` mới → icon
  và màu đổi. UI = hàm của state, đúng `UI = f(state)`.

Đây chính là hình dáng `_MenuScreenState` sắp viết — chỉ khác tên field
và widget hiển thị.

## Cầu nối Android / Compose

- SIMILARITY: field trong `State` + `setState` ≈ `remember { mutableStateOf() }`
  + Compose recomposition: đổi state → UI tự vẽ lại.
- IMPORTANT DIFFERENCE: `StatefulWidget` *bản thân vẫn bất biến* — khác hẳn
  View Android (mutable). Trạng thái sống trong class `State` **riêng**, giống
  `rememberSaveable` holder chứ không phải "widget giữ biến".
- DO NOT ASSUME: `setState` làm việc giống Compose snapshot — `setState`
  là **opt-in thủ công**: đổi biến mà không gọi `setState` → UI *không* cập
  nhật (bài 2 sẽ làm thí nghiệm đúng chỗ này).

## Trong project senior

Đọc kỹ `flutter-accelerator-ai/lib/screens/menu_screen.dart` — cấu trúc
menu senior khác với bản M03 của ta theo một cách có chủ đích:

- `MenuScreen` của senior là **StatelessWidget** — không phải
  `StatefulWidget`. Nó chỉ là "entry widget" đặt provider cho màn hình.
- Phần stateful của senior chia thành hai vai trò nhỏ, rõ ràng:
  `_MenuScreenEventBridge` (chỉ subscribe/unsubscribe event stream của
  ViewModel — bạn sẽ gặp pattern này ở M13) và `MenuScreenView` (stateful
  chỉ để giữ `_dialogDismissLocked` — một cờ ephemeral ngăn dialog đóng
  hai lần).
- **Dialog state của senior KHÔNG nằm trong `State`** — nó nằm trong
  `MenuScreenViewModel` (`dialogState`), tức state "to" sống ở VM, widget
  chỉ giữ state UI nhất thời. Đây chính là quy tắc ownership bài này đang
  dạy — senior áp dụng nó triệt để hơn cả những gì M03 cần.

Vậy picture đúng là: LEARNER M03 FORM = một `StatefulWidget` giữ mọi
state local (`setState`); SENIOR TARGET FORM = `StatelessWidget` entry +
`MenuScreenViewModel` giữ state màn hình + hai stateful widget nhỏ chỉ giữ
bridge/dismiss-lock. Ta đi đúng hướng đó — qua Provider ở M12 và event
bridge ở M13 — chỉ đơn giản hơn ở giai đoạn này.

- File khác: `flutter-accelerator-ai/lib/widgets/menu/gradient_cta_button.dart`
  — nút senior bọc `GestureDetector(onTap:…)` quanh `Container` gradient —
  đúng pattern `_PlayButton` của ta sẽ có.
- Sự khác biệt cố ý: senior dùng Provider/ViewModel cho state thật (M12+);
  M03 chỉ dùng `setState` **local** — đơn giản hoá có chủ đích, không phải
  thiếu sót.

## Từng bước thực hiện

### Bước 1 — Vì sao StatelessWidget không được

Giả sử thử thêm vào `_ProfileHeader` (M02) một biến đếm và đổi icon khi bấm —
bạn sẽ kẹt ngay:

- `StatelessWidget` yêu cầu mọi field `final` (analyzer lint
  `must_be_immutable`) → **không khai báo `bool _soundOn` mutable được**.
- Không có chỗ nào "sống lâu" để giữ giá trị qua rebuild.

→ Cần widget **có** State riêng: `StatefulWidget`.

:::caution[TEACHING SCAFFOLD]
Hai state field `_soundOn` / `_playTapCount` bạn sắp tạo là **scaffold
dạy học** — tồn tại để cho `setState` có thứ gì đó để đổi. Senior app
không có toggle âm thanh trần trên menu cũng không đếm số lần bấm CHƠI:
âm thanh là switch trong settings dialog (M16, repo-backed), nút CHƠI
mở game ngay. Chúng sẽ **retire ở M13** khi event bridge + repo stream
thay thế (senior dùng cơ chế đó thật). Học cú pháp,
đừng học nó như feature của sản phẩm.
:::

### Bước 2 — Chuyển `MenuScreen` thành `StatefulWidget`

Trong `lib/screens/menu_screen.dart`, đổi comment + thay toàn bộ class
`MenuScreen` bằng **hai** class:

```dart
// lib/screens/menu_screen.dart — thay class MenuScreen
/// Màn hình menu chính — bản tương tác của milestone M03.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _soundOn = true;
  int _playTapCount = 0;

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
  Widget build(BuildContext context) {
    // …body giữ nguyên như M02, chỉ đổi 3 dòng trong Column (bước 3)…
  }
}
```

Cú pháp mới, đọc kỹ:

- `class MenuScreen extends StatefulWidget` — widget vẫn **bất biến**:
  chỉ có `const` ctor + `createState()`, không có field nào.
- `State<MenuScreen> createState() => _MenuScreenState();` — Flutter gọi hàm
  này **một lần** khi widget được gắn vào cây; nó trả về đối tượng State
  sẽ sống cùng vị trí đó.
- `class _MenuScreenState extends State<MenuScreen>` — private (`_`), generic
  `State<MenuScreen>` ràng buộc state này với `MenuScreen`.
- `_soundOn` / `_playTapCount` — **field mutable** nằm trong `State` (được
  phép! `State` không đòi bất biến). Private vì chỉ State dùng.
- `setState(() { … })` — callback chứa *phần đổi biến*; `setState` báo Flutter
  đánh dấu State "dirty" → lên lịch `build()` lại. Bài 2 mổ xẻ cơ chế.
- `build()` giờ nằm trong **`State`**, không còn trong Widget — vì UI phụ
  thuộc field của State.

### Bước 3 — Truyền state xuống con trong `Column`

Trong `build()` của `_MenuScreenState`, sửa `Column` — bỏ `const` (con giờ
nhận tham số runtime) và truyền state + callback:

```dart
// lib/screens/menu_screen.dart — trong _MenuScreenState.build
              child: Column(
                children: [
                  _ProfileHeader(
                    soundOn: _soundOn,
                    onSoundTap: _toggleSound,
                  ),
                  const Expanded(child: _MenuBody()),
                  _PlayButton(
                    tapCount: _playTapCount,
                    onTap: _onPlayTap,
                  ),
                ],
              ),
```

- `_soundOn` / `_toggleSound` — field và method *của State* được truyền xuống
  dưới dạng named params. Pattern: **state đi xuống, sự kiện đi lên**
  (con gọi `onSoundTap()` → code trong State chạy).
- `const Expanded(child: _MenuBody())` — `_MenuBody` vẫn toàn const được →
  `const` dời xuống `Expanded`. Đây là lý do `const` giờ nằm "sâu" hơn.

### Bước 4 — `_ProfileHeader` nhận state và callback

Thay toàn bộ `_ProfileHeader` (M02) bằng:

```dart
// lib/screens/menu_screen.dart — thay _ProfileHeader
/// Hàng header: avatar tròn + tên người chơi + nút bật/tắt âm thanh.
class _ProfileHeader extends StatelessWidget {
  final bool soundOn;
  final VoidCallback onSoundTap;

  const _ProfileHeader({required this.soundOn, required this.onSoundTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MenuTokens.spacingMd,
        vertical: MenuTokens.spacingXs,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MenuTokens.accentYellow, width: 2),
            ),
            child: const Icon(Icons.person, color: MenuTokens.textPrimary),
          ),
          const SizedBox(width: MenuTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Khách',
                  style: TextStyle(
                    color: MenuTokens.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  soundOn ? 'Âm thanh: bật' : 'Âm thanh: tắt',
                  style: const TextStyle(
                    color: MenuTokens.accentYellow,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSoundTap,
            child: _IconBadge(
              icon: soundOn ? Icons.volume_up : Icons.volume_off,
            ),
          ),
        ],
      ),
    );
  }
}
```

Điểm mới:

- `final VoidCallback onSoundTap` — widget **nhận một hàm** như nhận dữ liệu;
  `VoidCallback` = `void Function()`. Header không biết toggle làm gì — nó chỉ
  "bấm thì gọi".
- `GestureDetector(onTap: onSoundTap, child: …)` — widget bọc bắt tap;
  `onTap:` là named param kiểu `VoidCallback?` — truyền thẳng field của mình.
- `soundOn ? Icons.volume_up : Icons.volume_off` — **ternary** chọn icon;
  caption `Text(soundOn ? 'Âm thanh: bật' : 'Âm thanh: tắt')` — UI *suy ra*
  từ giá trị state. Khi `soundOn` đổi + rebuild → icon/caption tự đổi.
- `Expanded` mất `const` — con `Column` giờ có `Text` phụ thuộc `soundOn`
  (runtime) → không const được nữa.
- `_ProfileHeader` **vẫn là StatelessWidget** — nó không giữ state; state sống
  ở `_MenuScreenState`, chỉ *trôi qua* đây. Đây là quyết định "state ở đâu"
  (bài 3 bàn kỹ).

### Bước 5 — `_PlayButton` nhận tap count + callback

Thay `_PlayButton` (M02) bằng:

```dart
// lib/screens/menu_screen.dart — thay _PlayButton
/// Nút hành động chính — M03: bấm được, đếm số lần bấm.
class _PlayButton extends StatelessWidget {
  final int tapCount;
  final VoidCallback onTap;

  const _PlayButton({required this.tapCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MenuTokens.spacingMd),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MenuTokens.radiusPill),
                gradient: const LinearGradient(
                  colors: [MenuTokens.buttonTop, MenuTokens.buttonBottom],
                ),
              ),
              child: const Text(
                'BẮT ĐẦU CHƠI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MenuTokens.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: MenuTokens.spacingXs),
          Text(
            'Số lần bấm: $tapCount',
            style: const TextStyle(
              color: MenuTokens.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
```

- `GestureDetector(onTap: onTap)` bọc **cả pill** — vùng bấm = vùng nút.
- `'Số lần bấm: $tapCount'` — **string interpolation**: `$tapCount` chèn giá
  trị biến vào chuỗi (giống `"$count"` Kotlin). Vì `tapCount` runtime → `Text`
  này không `const` (nhưng `TextStyle` vẫn const được — để ý cách `const`
  tách rời).
- Caption cũ `'15 câu hỏi — …'` bị thay bằng bộ đếm — cố ý cho bạn *thấy*
  state thay đổi trên UI.

`flutter analyze` → sạch. `flutter run` → **bấm badge loa**: icon đổi
volume_up ↔ volume_off, caption đổi "Âm thanh: bật/tắt"; **bấm nút**: "Số lần
bấm: N" tăng mỗi lần. Menu sống rồi.

## Đọc hiểu code

Dòng chảy một lần bấm nút chơi:

```
Tap lên GestureDetector(child: pill)
→ onTap() = _onPlayTap() trong _MenuScreenState chạy
→ setState(() => _playTapCount++)
   ├─ code trong () đổi field: _playTapCount = 1
   └─ setState đánh dấu State dirty → Flutter lên lịch build
→ Frame sau: _MenuScreenState.build() chạy lại với giá trị MỚI
→ _PlayButton được tạo lại với tapCount: 1
→ Text('Số lần bấm: 1') hiển thị
```

Nhận ra `MenuScreen` widget **vẫn** bất biến — cái được tạo lại là widget
mô tả UI; cái **giữ** `_playTapCount` là `State` sống lâu.

## Chạy và quan sát

- `flutter run -d chrome`; bấm nút vài lần, bấm badge loa.
- Thử **Hot Reload** (`r`) sau khi sửa text: số đếm **không reset** — State
  sống xuyên reload. Thử **Hot Restart** (`R`): đếm về 0 — app chạy lại từ
  `main()`. (Đây là khác biệt đã học ở M01 giờ có nghĩa thực tế.)
- Mở DevTools/terminal xem log — bài 3 sẽ thêm `debugPrint` lifecycle.

## Lỗi thường gặp

1. **Đổi biến mà quên `setState`** — `_playTapCount++` ngoài setState: biến
   đổi nhưng UI không cập nhật. `setState` là phần **báo cho Flutter**, không
   phải phần đổi biến (bài 2 mổ xẻ).
2. **Đặt field mutable trong Widget** — `must_be_immutable`: widget phải
   `final`-only; mutable đặt trong `State`.
3. **`setState` sau khi widget gỡ khỏi cây** — lỗi "called after dispose()";
   mốc `dispose` ở bài 3.
4. **Nghĩ rebuild = tạo lại toàn bộ UI nặng nề** — Flutter chỉ *tạo lại widget
   mô tả* (rẻ) rồi diff; phần `const` như `_MenuBody` không build lại.

## Kiểm tra hiểu biết

1. `StatefulWidget` vs `State` — ai bất biến, ai sống lâu? — Widget bất biến
   và tạo/huỷ rẻ; `State` mutable và sống xuyên rebuild.
2. Vì sao `build()` nằm trong `State` khi dùng StatefulWidget? — Vì UI phụ
   thuộc field của State; mỗi lần state đổi → `state.build()` chạy lại.
3. `VoidCallback` là gì? — Type alias có sẵn cho `void Function()` — hàm
   không tham số, không trả về; dùng cho `onTap`/`onPressed`.
4. Predict: đặt `_playTapCount` trong `MenuScreen` (widget) sẽ ra sao? —
   Compile error: widget bất biến, không cho field mutable.

## Tự làm (MODIFY)

Sản phẩm muốn caption dưới nút hiển thị `'Lần bấm cuối: chẵn'` hoặc
`'lẻ'` thay vì số đếm. **Trước khi sửa code**, tự quyết hai câu:

1. Bạn cần **field state mới** (ví dụ `_lastWasEven`) hay suy ra từ state
   đang có? Chọn một hướng và nêu lý do.
2. Nếu suy ra: chỗ nào tính — trong `setState`, trong `build`, hay trong
   `_onPlayTap`? Vì sao chỗ đó là chỗ đúng?

Sau đó sửa `Text('Số lần bấm: $tapCount')` trong `_PlayButton` thành dạng
chẵn/lẻ, `flutter analyze` sạch, reload và bấm vài lần để kiểm chứng.

:::note[Gợi ý]
Nguyên tắc: *không lưu thứ gì suy ra được từ state đã lưu* — nó sẽ lệch
nguồn sự thật. `_playTapCount % 2 == 0` là đủ dữ kiện.
:::

<details><summary><strong>Đáp án</strong></summary>

1. **Suy ra — không thêm field.** `_lastWasEven` sẽ là nguồn sự thật thứ
   hai cho cùng một sự thật (`_playTapCount` đã chứa thông tin chẵn/lẻ);
   lúc nào cũng có nguy cơ quên cập nhật đồng bộ. State nên lưu *dữ kiện
   gốc*, UI tính phần suy diễn.
2. Tính **trong `build`** — vì (a) nó chỉ ảnh hưởng hiển thị, (b) `build`
   luôn chạy lại khi `_playTapCount` đổi nên giá trị suy ra không bao giờ
   cũ. Đặt trong `setState`/`_onPlayTap` nghĩa là tính một lần lúc event —
   dư thừa, và lại là lưu thứ suy ra được.

Một cách sửa:

```dart
// _PlayButton.build — thay Text caption
Text(
  tapCount % 2 == 0 ? 'Lần bấm cuối: chẵn' : 'Lần bấm cuối: lẻ',
  style: const TextStyle(
    color: MenuTokens.textSecondary,
    fontSize: 13,
  ),
),
```

(`%` = toán tử chia lấy dư như Kotlin; ternary `cond ? a : b` đã gặp ở
bài này — suy diễn xảy ra ngay trong `build`, không field mới.) Bấm
1,3,5… lần → "lẻ"; 0,2,4… → "chẵn".

Điều bài tập kiểm tra: **state nguồn vs state suy diễn** — quyết định
thiết kế thật của mọi hệ state management sau này (VM derive cũng theo
quy tắc này).
</details>

## Cố ý chưa làm

- `initState`/`dispose` — bài 3 thêm ngay (đã có trong file verify).
- Điều hướng (`Navigator`) khi bấm CHƠI — M07; nút hôm nay chỉ đếm.
- Lưu `_soundOn` xuống disk — M10 (`SharedPreferences`).
- `ChangeNotifier`/Provider chia sẻ state giữa nhiều màn — M11/M12.
- `InkWell`/ripple — `GestureDetector` tối giản; hiệu ứng chạm để sau.
- `ValueKey`, `GlobalKey`, form — milestone sau khi cần.

## Điểm kiểm tra hoàn thành

- [ ] `MenuScreen` là `StatefulWidget` + `_MenuScreenState` với
      `_soundOn`/`_playTapCount`.
- [ ] Bấm badge → icon + caption đổi; bấm nút → đếm tăng.
- [ ] `flutter analyze` → `No issues found!`.
