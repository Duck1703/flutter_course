---
title: "Bài 2 · setState & rebuild — cơ chế bên trong"
description: "setState làm gì và KHÔNG làm gì: đánh dấu dirty, lên lịch build, diff cây — và các lỗi kinh điển."
sidebar:
  label: "Bài 2 · setState & rebuild"
  order: 2
---

## Mục tiêu

Sau bài này bạn mô tả chính xác một lần `setState` diễn ra từng bước, sửa được
ba lỗi kinh điển (quên `setState`, gọi trong `build`, đặt logic nặng trong
callback), và hiểu vì sao "rebuild" rẻ hơn bạn tưởng.

## Bạn đang ở đâu

- Milestone: **M03** (bài 2/3)
- App hiện tại: `MenuScreen` stateful, toggle âm thanh + đếm bấm đã hoạt động
  (bài 1).

## Vì sao việc này quan trọng ngay bây giờ

`setState` trông "kỳ diệu" chỉ khi bạn chưa thấy cơ chế. Người mới hay viết
`_playTapCount++` rồi ngồi chờ UI đổi — lỗi số một. Hiểu đúng "đánh dấu dirty
→ build lại → diff" sẽ giúp bạn debug mọi vấn đề state sau này, kể cả khi
sang Provider/BLoC (chúng chỉ là `setState` có tổ chức hơn).

## Bạn đã biết gì

- `StatefulWidget`/`State`/`createState` (bài 1); `build()` trả cây widget
  mô tả UI (M01).

## Mental model mới

Câu sai phổ biến: *"setState cập nhật biến"*. Câu đúng:

```
setState(() {
  _soundOn = !_soundOn;   // ← CODE CỦA BẠN đổi biến
});                        //    setState chỉ BÁO: "State này dirty"
```

Ba việc `setState` thật sự làm:

1. **Chạy closure bạn truyền vào** (đồng bộ).
2. **Đánh dấu Element/State là "dirty"** — đặt cờ, không vẽ gì cả.
3. **Lên lịch một frame mới** — ở vsync kế tiếp, Flutter gọi `build()` của
   State dirty đó (và các con chịu ảnh hưởng), thu được **cây widget mô tả
   mới**, so sánh với cây cũ (diff theo vị trí + kiểu + key), chỉ *cập nhật
   phần thay đổi* xuống RenderObject.

Hệ quả quan trọng:

- `build()` được gọi lại **toàn bộ** cho State đó — code trong build phải
  nhanh và *pure* (không side-effect).
- Widget con `const` (như `Expanded(child: _MenuBody())`) **không** build lại
  — đã là hằng, Flutter nhận ra không đổi.
- "Rebuild" ≠ tạo lại view hierarchy — widget là *mô tả* nhẹ; RenderObject
  bên dưới chỉ cập nhật chỗ khác.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| Closure `() { … }` | `setState(() { _x++; })` | Hàm vô danh làm tham số — block chạy ngay trong `setState` |
| `debugPrint('…')` | `debugPrint('build ${_playTapCount}')` | Log an toàn trong app (tốt hơn `print` — throttle khi spam) |
| `${expr}` | `'count: ${_playTapCount + 1}'` | Nội suy biểu thức: `${…}` (khác `$name` chỉ cho biến) |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `setState(VoidCallback)` | Đánh dấu dirty + lên lịch build; closure là `VoidCallback` đã gặp ở bài 1 |
| `mounted` | `bool` trên `State`: còn gắn trên cây không — kiểm tra trước `setState` trong callback chậm (dùng sau ở M05 async) |
| DevTools "Rebuilds" / `debugPrint` | Đếm số lần build thật sự — công cụ chứng minh mental model |

## Cầu nối Android / Compose

- SIMILARITY: đổi state → framework tự recompose/redraw phần liên quan; cả hai
  đều diff thay vì vẽ lại từ đầu.
- IMPORTANT DIFFERENCE: Compose tự *theo dõi* state đọc trong composable
  (`mutableStateOf` snapshot). Flutter **không** tracking: bạn phải gọi
  `setState` thủ công để báo dirty — đổi biến thường không trigger gì.
- DO NOT ASSUME: `setState` là async hay "enqueue message". Nó chạy closure
  **đồng bộ** ngay lập tức; phần async chỉ là frame build ở vsync sau.

## Trong project senior

- File: `flutter-accelerator-ai/lib/screens/menu_screen.dart` — `_MenuScreenState`
  của senior gọi `setState` cho overlay/dialog local — cùng cơ chế, chỉ state
  phức tạp hơn (M18 sẽ tới).
- Pattern senior: state *toàn cục* (điểm, câu hỏi) **không** nằm trong
  `setState` — nằm trong ViewModel + `ChangeNotifier` (M11) + Provider (M12).
  Ghi nhớ: `setState` chỉ cho **ephemeral/local UI state** — thứ chỉ một
  widget quan tâm.

## Từng bước thực hiện (ba thí nghiệm trên code thật)

### Thí nghiệm 1 — Quên `setState`: UI "chết"

Sửa `_onPlayTap` tạm thời:

```dart
// lib/screens/menu_screen.dart — THÍ NGHIỆM, sẽ sửa lại ngay
  void _onPlayTap() {
    _playTapCount++;          // đổi biến, không báo Flutter
  }
```

Reload → bấm nút: đếm **đứng yên** dùng biến đã tăng (state vẫn đổi — chỉ là
không ai gọi `build`). Bây giờ hot reload (`r`): đếm nhảy đúng số — vì reload
buộc build lại và đọc giá trị mới.

> Đây là bằng chứng: `setState` không "cập nhật biến" — nó **báo build**.

Sửa lại:

```dart
// lib/screens/menu_screen.dart — khôi phục
  void _onPlayTap() {
    setState(() {
      _playTapCount++;
    });
  }
```

### Thí nghiệm 2 — Đếm số lần build thật

Thêm một dòng đầu `build()` của `_MenuScreenState`:

```dart
// lib/screens/menu_screen.dart — THÍ NGHIỆM đầu _MenuScreenState.build
  @override
  Widget build(BuildContext context) {
    debugPrint('[MenuScreen] build — tap=$_playTapCount, sound=$_soundOn');
    return Scaffold(
```

`debugPrint` ≈ `print` nhưng an toàn hơn khi gọi thường xuyên trong build
(throttle, không rớt log). Chạy → mỗi tap in **đúng một** dòng build; bấm
badge loa cũng in một dòng (cùng một State). Rebuild là *per-State*, không
phải cả app.

Thử di chuyển `debugPrint` sang `_MenuBody.build` — nó **không** in lại khi
bấm, vì `_MenuBody` là `const` con: Flutter thấy widget const không đổi → bỏ
qua. Đây là lý do `const` không chỉ là "style" mà là *tối ưu rebuild*.

Xoá dòng `debugPrint` khỏi `build` (hoặc giữ — bài 3 sẽ thay bằng lifecycle
log chuẩn trong file verify).

### Thí nghiệm 3 — `setState` rỗng và logic nặng

```dart
// THÍ NGHIỆM — không làm app
setState(() {});            // vẫn rebuild! closure rỗng hợp lệ

// và anti-pattern (đừng viết):
setState(() {
  heavyComputation();       // tính toán nặng trong closure → chậm frame
});
```

- `setState(() {})` hợp lệ và vẫn trigger rebuild — thêm bằng chứng closure
  chỉ là *nơi tiện* đặt mutation, không phải yêu cầu.
- Quy ước: đặt mutation *trong* `setState` để người đọc thấy rõ "state đổi
  ở đây" — đó là lý do code ta viết `_soundOn = !_soundOn;` trong callback.

Không commit thí nghiệm — giữ `_onPlayTap`/`_toggleSound` như verified.

## Đọc hiểu code

Toàn cảnh một frame (đúng với code đang chạy):

```
_bấm nút_
onTap → _onPlayTap()
  setState(() { _playTapCount++; })
    ├─ chạy closure: _playTapCount = 1
    ├─ đánh dấu _MenuScreenState dirty
    └─ đăng ký frame
_vsync sau_
_MenuScreenState.build()           ← gọi LẠI, _playTapCount=1
  └─ Column
       ├─ _ProfileHeader(soundOn: true, onSoundTap: _toggleSound)  ← widget MỚI
       ├─ const Expanded(_MenuBody())                              ← const: bỏ qua
       └─ _PlayButton(tapCount: 1, onTap: _onPlayTap)              ← widget MỚI
diff với cây cũ → chỉ Text('Số lần bấm: …') cần update RenderObject
```

## Chạy và quan sát

- Mở DevTools → tab **Widget Rebuilds** (hoặc dùng `debugPrint` thí nghiệm 2)
  — xác nhận: mỗi tap = 1 rebuild của `MenuScreen`, `_MenuBody` không rebuild.
- Bấm nhanh nhiều lần: Flutter *gộp* — nhiều `setState` trong cùng frame chỉ
  sinh **một** build (frame coalescing), không "mất" tap nào.

## Lỗi thường gặp

1. **`_x++` không `setState`** — lỗi số 1; biến đổi, UI không. Thí nghiệm 1.
2. **Gọi `setState` *trong* `build()`** — build chạy trong frame → gọi
   setState lúc đó lên lịch lại build → vòng lặp frame / exception. Mutation
   thuộc về *event handler*, không phải build.
3. **Logic nặng trong closure `setState`** — closure chạy đồng bộ trong event;
   compute trước, chỉ đặt gán cuối vào setState.
4. **`setState` khi widget đã unmount** — "setState() called after dispose()";
   bài 3 nói `dispose`/`mounted`.

## Kiểm tra hiểu biết

1. `setState(() { _x = 5; })` vs `_x = 5; setState(() {});` — khác nhau?
   — Kết quả **giống nhau** về rebuild; convention đặt mutation trong
   closure cho rõ ý đồ.
2. Vì sao `_MenuBody` không rebuild khi bấm nút? — Nó là `const` widget —
   Flutter so sánh widget mới với cũ, const-identical → skip.
3. Rebuild `MenuScreen` có tạo lại toàn bộ view tree? — Không: chỉ tạo lại
   *widget mô tả* rẻ rồi diff; RenderObject chỉ cập nhật phần đổi.
4. Predict: hai `setState` trong cùng một event handler sinh mấy build? —
   Một — Flutter gộp dirty trong frame.

## Tự làm (PREDICT)

Bốn viễn cảnh nhỏ kiểm tra cơ chế — dự đoán **từng cái trước**, rồi kiểm
chứng bằng `debugPrint` ở đầu `build` (thí nghiệm 2 đã dạy cách). Với
mỗi viễn cảnh trả lời: *`build()` có chạy lại không, và UI hiển thị
giá trị nào?*

1. `_onPlayTap` viết thành: `_playTapCount++; setState(() {});`
2. `_onPlayTap` gọi `setState(() => _playTapCount++);` **hai lần liên
   tiếp** trong một tap.
3. Đặt `setState(() {})` ngay **đầu `build()`** của `_MenuScreenState`.
4. Đổi `_soundOn = false;` trong `initState()` — **không** bọc `setState`.

Viết dự đoán xuống giấy trước; sau đó thử từng cái trên app (hoặc
DartPad với `LightSwitch` của bài 1), đối chiếu, và **khôi phục** code
về trạng thái đúng sau mỗi lần thử.

:::note[Gợi ý]
Hai điểm mấu chốt: `setState` chỉ *báo dirty* (mutation ở đâu không quan
trọng đối với việc rebuild); và `build()` lần đầu đã được framework lên
lịch sẵn khi State được tạo.
:::

<details><summary><strong>Đáp án</strong></summary>

1. **UI vẫn cập nhật đúng** — mutation đã xảy ra (biến tăng); `setState`
   rỗng vẫn báo dirty → `build` đọc giá trị mới. Chứng minh closure chỉ
   là *nơi tiện* đặt mutation: `setState` không "chứa" phần đổi biến.
2. **Một lần build, đếm +2** — hai lần báo dirty trong cùng event được
   gộp thành một frame; biến tăng 2 và UI nhảy 2.
3. **Lỗi/vòng lặp** — `setState` gọi trong `build` (trong frame) yêu cầu
   một frame mới, frame đó lại gọi `build` lại gọi `setState`… Flutter
   chặn bằng exception "setState() called during build". Mutation/marking
   thuộc *event handler*, không thuộc `build`.
4. **Không cần `setState`** — `initState` chạy trước `build` đầu tiên;
   framework đã lên lịch build đầu rồi nên giá trị `false` được đọc luôn.
   `setState` trong `initState` là *thừa* (không lỗi, nhưng vô ích — và
   trên một số đường code còn rác rối). Quy tắc: chỉ cần `setState` khi
   mutation xảy ra **sau** khi widget đã build ít nhất một lần.

Điều bài tập kiểm tra: bạn vận dụng được cơ chế "đánh dấu dirty → frame
→ build lại" vào bốn trường hợp mép — bao gồm hai trường hợp người mới
thường sai (mutation ngoài closure vẫn hiển thị; `setState` trong
`initState`/`build`).
</details>

## Cố ý chưa làm

- `mounted` + `setState` sau async — M05 (Future); giờ chưa có async.
- `ValueNotifier`/`AnimatedBuilder`, `ChangeNotifier` — M11.
- `didUpdateWidget`, `didChangeDependencies` — lifecycle nâng cao, gặp
  khi Provider/InheritedWidget vào app (M12–M13).
- Performance profiling frame — M28.

## Điểm kiểm tra hoàn thành

- [ ] Giải thích: `setState` đánh dấu dirty + lên lịch build; closure chỉ là
      chỗ đặt mutation.
- [ ] Chứng minh được bằng thí nghiệm: bỏ `setState` → UI đứng; reload →
      nhảy đúng.
- [ ] Biết `const` con được skip khi rebuild.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m03/02 — "setState & rebuild — cơ chế bên trong" (bài thí nghiệm cơ chế — không bắt buộc thay đổi code, nhưng các thí nghiệm chạy TRÊN project nên rủi ro để sót code thử).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Nhiệm vụ chính: xác nhận project vẫn ở trạng thái đúng sau các thí nghiệm "quên setState / debugPrint / setState rỗng" — không có code thí nghiệm sót lại.

EXPECTED STATE SAU BÀI NÀY (trong `lib/screens/menu_screen.dart` — bằng trạng thái cuối bài trước):
- `_MenuScreenState` vẫn có `_soundOn`, `_playTapCount`, `_toggleSound()` và `_onPlayTap()` — CẢ HAI mutation đều nằm TRONG `setState(...)` (STRICT: `_playTapCount++` và `_soundOn = !_soundOn` phải trong closure setState, không được viết trần).
- Không có `setState(...)` nào được gọi trực tiếp bên trong `build()` (STRICT — setState trong build là lỗi crash).
- `debugPrint` ở đầu `_MenuScreenState.build` được CHẤP NHẬN (bài cho phép giữ) — nhưng không được có `debugPrint` trong `build` của widget con khác sót lại từ thí nghiệm di chuyển; và không còn `setState(() {})` rỗng lạc chỗ.
- `_ProfileHeader`/`_PlayButton` vẫn StatelessWidget nhận params như cuối bài trước.
- `flutter analyze` → "No issues found!"; bấm nút/badge vẫn cập nhật UI.

INVARIANTS NỀN:
- Menu stateful hai-class (MenuScreen + _MenuScreenState), khung bọc M02, `MenuTokens`, `main.dart` còn nguyên; chưa có `Navigator`/package mới.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`/`AHEAD_RISKY`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m03/02
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
