---
title: "Bài 3 · Chạy app, Hot Reload và tooling"
description: "flutter run trên device thật, Hot Reload vs Hot Restart, và thói quen analyze."
sidebar:
  label: "Bài 3 · Chạy app & Hot Reload"
  order: 3
---

## Mục tiêu

Sau bài này bạn chạy được app trên một target thật, biết khi nào dùng Hot
Reload / Hot Restart / restart hẳn, và có thói quen `flutter analyze` trước
khi chạy.

## Bạn đang ở đâu

- Milestone: **M01** (bài 3/3 — bài cuối của milestone)
- App hiện tại: `main.dart` mới với `MaterialApp` + `WelcomeScreen` hiển thị
  "AI MILLIONAIRE" nền navy.

## Vì sao việc này quan trọng ngay bây giờ

Đến đây bạn mới chỉ *viết* code — giá trị của Flutter nằm ở vòng lặp
**sửa → thấy ngay**. Nắm sai cách reload sẽ khiến bạn tưởng "code không chạy"
khi thật ra chỉ cần restart. Đây là kỹ năng dùng hàng trăm lần mỗi ngày.

## Bạn đã biết gì

- Build & deploy Android qua Gradle có ít nhất 2 tốc độ: sync/build thường vs
  Apply Changes.
- Log/bảng điều khiển là nơi nhìn lỗi runtime.

## Mental model mới

Dart biên dịch theo **hai chế độ**:

- **JIT (debug)**: code được biên dịch từng phần trong VM — nên Flutter có thể
  *bơm code mới* vào app đang chạy. Đó là Hot Reload.
- **AOT (release)**: biên dịch trước thành native — nhanh, không reload được.

Ba mức "làm mới":

| Mức | Phím trong `flutter run` | Chuyện xảy ra |
|-----|--------------------------|----------------|
| **Hot Reload** | `r` | Bơm code mới, *giữ nguyên state*, rebuild cây widget. Nhanh nhất |
| **Hot Restart** | `R` (Shift+R) | Khởi động lại Dart runtime; **mất hết state**, chạy lại `main()` |
| **Full restart** | `q` rồi `flutter run` | Build native mới — cần khi đổi platform config, pubspec assets, plugin |

## Dart cần dùng

Không có cú pháp mới — bài này thuộc về tooling.

## Flutter cần dùng

- `flutter devices` — liệt kê target đang có (emulator, điện thoại, chrome,
  edge…).
- `flutter run -d <id>` — chọn target (`chrome`, `web-server`, id emulator…).
- Trong session `run`: `r` hot reload, `R` hot restart, `q` thoát,
  `h` xem thêm phím.
- `flutter analyze` — chạy analyzer toàn project (lint + typecheck);
  `flutter pub get` sau mỗi lần sửa `pubspec.yaml`.

## Cầu nối Android / Compose

- SIMILARITY: Hot Reload ≈ Apply Code Changes + Live Edit của Compose —
  nhưng mạnh hơn: áp dụng cho **mọi thay đổi Dart**, không chỉ UI, và hoạt
  động trên thiết bị thật lẫn web.
- IMPORTANT DIFFERENCE: Apply Changes trên Android hay đứt khi đổi signature;
  Hot Reload của Flutter chịu được hầu hết thay đổi (thêm method, đổi body,
  sửa widget tree). Chỉ những thay đổi *khởi tạo* (field initializer trong
  `State`, `main()`, global) mới cần restart.
- DO NOT ASSUME: "save file = app tự reload" — trong terminal `flutter run`
  bạn phải bấm `r`; IDE (VS Code/Android Studio) mới có reload-on-save.

## Trong project senior

- File: `flutter-accelerator-ai/analysis_options.yaml` — app senior dùng cùng
  cơ chế `flutter analyze` (lint set `flutter_lints`) — công cụ bạn vừa chạy
  là đúng công cụ senior chạy.
- File: `flutter-accelerator-ai/lib/main.dart` — `main()` của senior là
  `async` vì khởi tạo nhiều thứ trước `runApp`; hậu quả: đổi init sequence ở
  đó luôn cần restart hẳn (lý do trong bài này).

## Từng bước thực hiện

### Bước 1 — Chọn target

```bash
flutter devices
```

In ra danh sách kiểu:

```
Found 3 connected devices:
  Windows (desktop) • windows • windows-x64
  Chrome (web)      • chrome  • web-javascript
  Edge (web)        • edge    • web-javascript
```

Chọn một cái có sẵn. `chrome` là lựa chọn nhanh nhất trên mọi máy; Android
emulator nếu bạn muốn thấy dạng mobile thật.

### Bước 2 — Chạy app

```bash
flutter run -d chrome
```

Lần đầu build lâu hơn (~30–60s). Khi thấy `Flutter run key commands.` và app
hiện ra — session `run` đang chờ phím lệnh.

### Bước 3 — Thí nghiệm Hot Reload

Với app **đang chạy**, sửa trong `WelcomeScreen.build`:

```dart
// lib/main.dart — WelcomeScreen.build, đổi chuỗi Text
'AI MILLIONAIRE\nBắt đầu hành trình Flutter'
```

Lưu file, quay lại terminal, bấm `r`. Màn hình cập nhật **gần như ngay** mà
không restart app.

Thử tiếp: đổi `backgroundColor` `0xFF0B1026` → `0xFF1B1140`, `r` lại — nền
đổi màu tại chỗ.

### Bước 4 — Thí nghiệm thứ cần restart

Sửa `main()` — ví dụ đổi tên widget gốc hoặc thêm lệnh mới vào `main` — rồi
bấm `r`: **không có gì đổi**, vì `main()` đã chạy xong từ lúc khởi động.
Bấm `R` (hot restart) → runtime chạy lại từ `main()`. Quy tắc nhớ:
*thay đổi trong build() → reload đủ; thay đổi khởi tạo → restart.*

### Bước 5 — Thói quen analyze

```bash
flutter analyze
```

Chạy trước mỗi lần "xong một bước". Analyzer bắt lỗi type, unused import,
thiếu `@override`… — rẻ hơn nhiều so với phát hiện lúc runtime.

## Đọc hiểu code

Khi bấm `r`, Flutter: (1) compile phần Dart đã đổi, (2) bơm vào VM đang chạy,
(3) đánh dấu cây element cần rebuild, (4) gọi lại các `build` bị ảnh hưởng.
Vì state nằm ngoài widget (sẽ học kỹ ở M03), text mới hiện ra mà app không
"về trang chủ".

## Chạy và quan sát

- Chạy: `flutter run -d chrome`, rồi lần lượt `r`, `R`, `q`.
- Kỳ vọng: `r` đổi UI tại chỗ; `R` reset về trạng thái đầu (state sẽ thấy rõ
  hơn ở M03); `q` dừng session.
- Nếu `r` không có tác dụng → bạn đang sửa phần khởi tạo (`main`, field init)
  → cần `R`.

## Lỗi thường gặp

1. **Sửa xong quên save trước khi `r`** — VM nhận code cũ trên đĩa; luôn lưu
   file trước.
2. **Bấm `r` rồi kết luận "code không chạy"** khi sửa `main()` hoặc biến
   khởi tạo — những chỗ đó chỉ chạy lại khi restart (`R` hoặc `q` + run).
3. **Đổi `pubspec.yaml` rồi `r`** — dependency/assets không hot-reload;
   `flutter pub get` rồi restart hẳn.
4. **Chạy `flutter run` không `-d`** khi có nhiều device — CLI sẽ hỏi hoặc
   chọn nhầm; ghi rõ `-d` hoặc chọn số thứ tự.

## Kiểm tra hiểu biết

1. Sửa nội dung một `Text` — cần `r` hay `R`? — `r` (đổi trong `build`).
2. Thêm field mới vào `State` với giá trị khởi tạo — reload hay restart? —
   Restart: initializer chạy lúc State tạo, reload không tạo lại nó (M03 sẽ
   thấy trực tiếp).
3. Vì sao release build không Hot Reload được? — AOT biên dịch trước thành
   native, không còn VM JIT để bơm code.
4. Micro-task: `flutter devices` và ghi lại id của target bạn sẽ dùng suốt
   khoá học.

## Tự làm

**Nhận diện + dự đoán (không cần code).** Trong `main.dart`, đổi chuỗi
`Text('…')` thành tên của bạn, **nhưng trước khi bấm gì** hãy trả lời:

1. Hot Reload có áp dụng được không? Vì sao?
2. Nếu thay đổi nằm trong `main()` trước `runApp` (ví dụ đổi tên hàm
   `main` thành `start`), Hot Reload còn áp dụng được không?
3. Với trường hợp (2), bạn phải dùng thao tác nào?

:::note[Gợi ý]
Nhớ lại điểm khác nhau then chốt: Hot Reload chỉ chạy lại `build()`,
không chạy lại `main()`.
:::

<details><summary><strong>Đáp án</strong></summary>

1. **Có** — `Text` trong `build` được rebuild; state của StatelessWidget
   không có gì để mất.
2. **Không** — `main()` không chạy lại khi reload; đổi entrypoint cần
   **Hot Restart** (chạy lại `main`, reset state) hoặc full restart.
3. Hot Restart (`flutter run` → `R`, hoặc nút restart trong IDE) là đủ;
   chỉ cần full restart khi đổi native/plugin/pubspec.

Chạy thử cả hai trường hợp để xác nhận dự đoán của bạn.
</details>

## Cố ý chưa làm

- Chưa dùng DevTools (widget inspector, performance) — sẽ giới thiệu khi có
  layout/state thật đáng soi.
- Chưa cấu hình `web/` hay signing — deploy/build release là milestone cuối
  (M29 appendix), bây giờ chỉ cần `flutter run` + `flutter build web` khi
  kiểm tra.
- Chưa có test — M04.

## Điểm kiểm tra hoàn thành

- [ ] `flutter run -d <target>` chạy được app M01.
- [ ] Sửa chuỗi `Text` → lưu → `r` → thấy đổi ngay trên app đang chạy.
- [ ] Giải thích được khi nào cần `R` thay `r` (khởi tạo/`main()`/state).
- [ ] `flutter analyze` → `No issues found!`.

**M01 hoàn thành.** Sang [M02 — Composition & layout tĩnh](/m02/).

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m01/03 — "Chạy app, Hot Reload và tooling" (bài cuối M01 — chủ yếu là thao tác chạy/thử, không bắt buộc thay đổi code).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS dưới đây; ngoài danh sách = không tính thiếu. Bài này dạy tooling — nhiệm vụ chính là xác nhận project sau các thí nghiệm Hot Reload vẫn ở trạng thái sạch của cuối M01.

EXPECTED STATE SAU BÀI NÀY:
- `lib/main.dart` vẫn chứa `main()` → `runApp(const AIMillionaireApp())`, `AIMillionaireApp` trả `MaterialApp` có `home:` là màn hình `WelcomeScreen` nền tối + `Text` canh giữa (STRICT: `runApp`/`AIMillionaireApp`/`MaterialApp`/`home` còn nguyên — chuỗi Text cụ thể có thể đã đổi qua thí nghiệm, đó là semantic, không lỗi).
- Không còn dấu vết thí nghiệm phá cấu trúc: `main()` không bị đổi tên, không còn `runApp(const Center(...))` bỏ `MaterialApp` sót lại (nếu learner thử bài tự làm mà quên khôi phục → đây là GAP cần báo).
- `flutter analyze` → "No issues found!".
- Project vẫn chỉ Flutter SDK, không package mới, không file Dart mới ngoài `lib/main.dart`.

INVARIANTS NỀN:
- `pubspec.yaml` `name: ai_millionaire_course`, chỉ dependency `flutter`; `test/widget_test.dart` đã xoá từ bài 1.

Mục (STRICT) phải đúng tên vì M02 xây tiếp lên nó; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`/`AHEAD_RISKY` tuỳ mức; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m01/03
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
