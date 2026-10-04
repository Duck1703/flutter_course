---
title: "Bài 1 · Flutter, Dart và project đầu tiên"
description: "Flutter và Dart là gì, tạo project bằng flutter create, và đọc hiểu cấu trúc thư mục."
sidebar:
  label: "Bài 1 · Flutter & project đầu tiên"
  order: 1
---

## Mục tiêu

Sau bài này bạn tạo được một project Flutter mới, hiểu từng thư mục quan trọng
trong đó, và biết thư mục nào có thể bỏ qua trong giai đoạn đầu.

## Bạn đang ở đâu

- Milestone: **M01 — Định hướng Flutter & chạy lần đầu** (bài 1/3)
- App hiện tại: **chưa có gì** — chúng ta bắt đầu từ một thư mục trống.

## Vì sao việc này quan trọng ngay bây giờ

Mọi thứ trong khoá học đều xây trên project này. Nếu tạo project mà không hiểu
cấu trúc của nó, bạn sẽ sợ `android/`, `ios/`, `pubspec.yaml` và đống file
generated — và nỗi sợ đó sẽ theo bạn suốt 29 milestone. Bài này dẹp nỗi sợ đó
trước khi viết dòng code đầu tiên.

## Bạn đã biết gì

Từ kinh nghiệm Android của bạn:

- Một project cần file mô tả dependencies và build config
  (`build.gradle.kts`, `settings.gradle.kts`).
- Mã nguồn nằm trong một module riêng, còn platform shell (Gradle wrapper,
  manifest) nằm ở chỗ khác.
- IDE/tooling cần bước "sync" để kéo dependencies về.

## Mental model mới

**Flutter là một bộ UI toolkit tự vẽ tất cả.** Không giống React Native cầu
nối sang view native, Flutter mang theo engine render riêng (Skia/Impeller)
và tự vẽ từng pixel. Code bạn viết bằng **Dart** — một ngôn ngữ biên dịch
JIT trong lúc develop (nên có Hot Reload) và AOT khi release (nên nhanh).

Một project Flutter = **code Dart trong `lib/`** + **các "vỏ" platform**
(`android/`, `ios/`, `web/`). Vỏ Android *thật sự là một project Gradle*
như bạn đã quen — Flutter nhét engine vào trong đó.

## Dart cần dùng

Chưa có — bài này chỉ tạo và dọn project. Dòng Dart đầu tiên xuất hiện ở bài 2.

## Flutter cần dùng

Các lệnh CLI — đây là "tooling" của Flutter, tương đương `./gradlew` + Android
Studio actions gộp lại:

| Lệnh | Việc |
| ------ | ------ |
| `flutter doctor` | Kiểm tra môi trường: toolchain nào sẵn sàng, thiếu gì |
| `flutter create` | Sinh project mới từ template |
| `flutter pub get` | Tải dependencies theo `pubspec.yaml` (≈ Gradle sync) |
| `flutter analyze` | Chạy static analyzer (lint + typecheck) |
| `flutter run` | Build + cài + chạy trên một target |

## Cầu nối Android / Compose

- SIMILARITY: `flutter create` ≈ "New Project" wizard của Android Studio;
  `pubspec.yaml` ≈ `build.gradle.kts` + `version/catalog` + phần `application`.
- IMPORTANT DIFFERENCE: thư mục `android/` trong project Flutter **là** một
  project Gradle thật, nhưng bạn hiếm khi cần vào — code của bạn sống ở `lib/`,
  viết bằng Dart, không phải Kotlin.
- DO NOT ASSUME: `pubspec.yaml` chỉ là danh sách dependency — nó còn khai báo
  assets, fonts, và metadata app (sẽ dùng ở các milestone sau).

## Trong project senior

- File: `flutter-accelerator-ai/pubspec.yaml` — `name: ai_millionaire`,
  `environment.sdk`, danh sách dependency (provider, rxdart,
  shared_preferences, supabase_flutter…), section `flutter:` khai báo assets.
- File: `flutter-accelerator-ai/.metadata` — Flutter ghi lại kênh/phiên bản đã
  tạo project.
- Thư mục `flutter-accelerator-ai/{android,ios,web}` — ba vỏ platform cùng tồn
  tại trong repo senior; app của chúng ta nhắm đúng bộ ba này.

## Từng bước thực hiện

### Bước 1 — Kiểm tra môi trường

```bash
flutter --version
flutter doctor
```

`flutter --version` phải in ra kênh stable và phiên bản Dart đi kèm.
`flutter doctor` liệt kê toolchain: Android SDK, Chrome (cho web), connected
devices. Mục nào có `[X]` chỉ cần xử lý nếu bạn định build cho target đó —
ví dụ thiếu Visual Studio chỉ ảnh hưởng build Windows.

### Bước 2 — Tạo project

Đứng ở thư mục workspace và chạy:

```bash
flutter create --project-name ai_millionaire_course --platforms android,ios,web learner-app
```

- `learner-app` — **thư mục output** được tạo.
- `--project-name ai_millionaire_course` — tên package Dart (snake_case, chữ
  thường). Khác với tên thư mục, tên này xuất hiện trong `pubspec.yaml` và
  trong các `import 'package:ai_millionaire_course/...'` sau này.
- `--platforms android,ios,web` — chỉ sinh ba vỏ platform cần thiết (đúng bộ
  ba của app senior; bỏ qua windows/macos/linux vì chưa có toolchain).

### Bước 3 — Đọc giải phẫu project vừa tạo

```
learner-app/
  pubspec.yaml        ← metadata + dependencies (≈ build.gradle.kts)
  pubspec.lock        ← phiên bản đã resolve — app thì commit file này
  analysis_options.yaml ← cấu hình lint (mặc định bật flutter_lints)
  lib/
    main.dart         ← entry point — toàn bộ code của bạn sẽ sống trong lib/
  test/
    widget_test.dart  ← test mẫu của template (sẽ xoá ở bước 4)
  android/            ← project Gradle thật (vỏ Android)
  ios/                ← project Xcode (vỏ iOS)
  web/                ← index.html + manifest (vỏ web)
```

**Có thể bỏ qua lúc này:** `build/` (output), `.dart_tool/` (cache của pub),
phần sâu trong `android/app/src/main` — chúng ta sẽ quay lại đúng lúc cần.

### Bước 4 — Dọn template

Template sinh sẵn một app "counter demo" với rất nhiều comment dạy bằng tiếng
Anh. Ta sẽ thay `main.dart` ở bài 2. Còn hai thứ dọn ngay:

1. Trong `pubspec.yaml`, **xoá** dependency `cupertino_icons` (bộ icon iOS
   mà app ta không dùng — giữ pubspec sạch ngay từ đầu):

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
   # (không còn cupertino_icons)
   ```

   và đổi `description` thành mô tả thật, ví dụ
   `"Learner app for the AI Millionaire Flutter course (M01–M03 state)."`.

2. **Xoá** `test/widget_test.dart` — file test mẫu trỏ vào app counter đã
   bị xoá. Khoá học bắt đầu dạy testing ở M04; lúc đó bạn sẽ tự viết file
   test đầu tiên.

3. Sau khi sửa pubspec, chạy lại:

   ```bash
   flutter pub get
   flutter analyze
   ```

   `pub get` resolve lại dependency (cupertino_icons biến mất khỏi lock file);
   `analyze` phải in `No issues found!`.

## Đọc hiểu code

Chưa có code mới — chỉ có project mới. Điều đáng nhớ: **`pubspec.yaml` là bản
kê khai duy nhất** của app Flutter: tên package, version, dependencies,
assets, fonts. Mỗi lần sửa nó, chạy `flutter pub get` — giống hệt thói quen
"đổi gradle rồi sync".

## Chạy và quan sát

- Chạy: `flutter analyze` trong `learner-app/`.
- Kỳ vọng: `No issues found!` — project còn nguyên template nhưng hợp lệ.
- Nếu thấy lỗi về `widget_test.dart` → bạn chưa xoá file test mẫu ở bước 4.

## Lỗi thường gặp

1. **Đặt tên project sai quy ước** — `flutter create` từ chối tên có chữ hoa
   hoặc gạch ngang; Dart package name phải là `snake_case`.
2. **Sửa `pubspec.yaml` mà quên `flutter pub get`** — analyzer vẫn thấy
   dependency cũ; luôn `pub get` sau khi đổi pubspec.
3. **Hoảng vì số lượng file generated** — `android/` và `ios/` là vỏ platform;
   bạn không phải hiểu chúng để học Flutter. Tập trung vào `lib/`.

## Kiểm tra hiểu biết

1. File nào đóng vai trò "khai báo dependency + metadata" của project Flutter?
   — `pubspec.yaml`.
2. `flutter doctor` báo `[X] Visual Studio` — app của bạn còn chạy được trên
   Android/web không? — Có; chỉ build Windows mới cần Visual Studio.
3. Vì sao xoá `test/widget_test.dart` thay vì sửa nó? — Nó test app counter
   của template đã bị xoá; lesson test đầu tiên thuộc M04, khi đó ta tự viết.

## Tự làm (PREDICT)

Bài này kiểm tra bạn nắm được *quy tắc đặt tên package* chứ không chỉ nhớ
một ví dụ. Tạo một thư mục probe trống (ví dụ `probe/`) và dự đoán **trước
khi chạy** `flutter create` chấp nhận hay từ chối từng `--project-name`:

| Tên thử | Dự đoán của bạn (accept/reject) | Vì sao (theo quy tắc nào) |
| --------- | ---------------------------------- | --------------------------- |
| `AIMillionaire` |  |  |
| `ai-millionaire` |  |  |
| `ai_millionaire` |  |  |
| `2cool` |  |  |

Sau đó trong `probe/` chạy thử từng cái, ví dụ
`flutter create --project-name ai_millionaire try1`, và đối chiếu thông
báo thực tế với dự đoán. **Dọn sạch thư mục `probe/` khi xong** — nó
không phải một phần của `learner-app`.

:::note[Gợi ý]
Quy tắc package Dart có ba phần: ký tự cho phép, chữ hoa/thường, và ký
tự đầu tiên.
:::

<details><summary><strong>Đáp án</strong></summary>

- `AIMillionaire` → **reject** — tên package Dart phải chữ thường.
- `ai-millionaire` → **reject** — dấu gạch ngang không hợp lệ; dùng
  gạch dưới (`snake_case`), đúng như `ai_millionaire_course` của ta.
- `ai_millionaire` → **accept**.
- `2cool` → **reject** — tên phải bắt đầu bằng chữ cái; chữ số chỉ được
  phép sau ký tự đầu.

Điều bài tập kiểm tra: bạn *áp dụng* được quy tắc `snake_case` vào bốn
trường hợp khác nhau — kể cả hai trường hợp lẻ (gạch ngang vs gạch dưới,
chữ số ở đầu) — chứ không chỉ lặp lại một tên đã cho.
</details>

## Cố ý chưa làm

- Chưa viết Dart nào — `main.dart` vẫn là template (bài 2 thay thế).
- Chưa thêm bất kỳ package bên thứ ba nào — suốt M01–M03 chỉ dùng Flutter SDK.
- Chưa đụng vào `android/`/`ios/` internals — khóa màn hình dọc, label app
  v.v. sẽ đến khi cần (một phần ở milestone căn chỉnh senior).

## Điểm kiểm tra hoàn thành

- [ ] `flutter --version` in ra kênh stable.
- [ ] `flutter create` tạo được `learner-app` với 3 platform android/ios/web.
- [ ] `cupertino_icons` đã rời `pubspec.yaml`, `widget_test.dart` đã xoá.
- [ ] `flutter pub get` + `flutter analyze` → `No issues found!`.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m01/01 — "Flutter, Dart và project đầu tiên".

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, chạy formatter, `flutter pub get` hoặc thay đổi dependency/lockfile, viết patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi bài học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml` (app được tạo bằng `flutter create`). Nếu thấy nhiều project Flutter mà không rõ đâu là của tôi → `BLOCKED_PROJECT_ROOT`, đừng đoán.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; thứ ngoài danh sách — kể cả thứ "tốt/chuẩn" — KHÔNG tính là thiếu. Project học theo từng bài, đừng chấm theo app hoàn chỉnh.

EXPECTED STATE SAU BÀI NÀY:
- `pubspec.yaml` có `name: ai_millionaire_course` (STRICT — import sau này dựa vào) và `dependencies:` chỉ có `flutter: sdk: flutter`; `cupertino_icons` đã bị xoá.
- `description:` trong pubspec đã đổi thành mô tả thật (nội dung tự do, semantic).
- `test/widget_test.dart` đã bị xoá — app counter của template không còn test đi kèm.
- `lib/main.dart` VẪN LÀ app counter của template — bài này cố ý chưa viết Dart, đây không phải lỗi.
- Tồn tại ba vỏ platform `android/`, `ios/`, `web/`; không cần windows/macos/linux.
- `flutter analyze` → "No issues found!".

INVARIANTS NỀN:
- (bài đầu tiên — chưa có invariant)

Mục (STRICT) phải đúng tên/hình dáng vì bài sau dùng lại; mục khác chấm semantic — cách viết tương đương được chấp nhận. Code đi trước checkpoint → `AHEAD_COMPATIBLE` nếu không cản bước sau (ví dụ đã tự đổi main.dart thay vì giữ template); `AHEAD_RISKY`/`DIVERGED` nếu nó phá nền bài tới. Thiếu phần bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m01/01
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
