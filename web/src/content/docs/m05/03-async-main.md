---
title: "Bài 3 · async main() & bootstrap"
description: "Future<void> main() async, WidgetsFlutterBinding.ensureInitialized — vì sao senior await trước runApp và khi nào ta cần."
sidebar:
  label: "Bài 3 · async main()"
  order: 3
---

## Mục tiêu

Chuyển `main()` thành `Future<void> main() async` +
`WidgetsFlutterBinding.ensureInitialized()`, hiểu chính xác vì sao hai
thứ này tồn tại (và vì sao *hôm nay* chúng gần như "chưa làm gì"), nhận ra
đúng cấu trúc bootstrap mà senior dùng — để khi M10 cần `await` đọc
`SharedPreferences` trước `runApp`, chỗ đó đã sẵn sàng.

## Bạn đang ở đâu

- Milestone: **M05 — Dart bất đồng bộ: Future** (bài 3/3)
- App hiện tại: profile tải bất đồng bộ qua `FutureBuilder` trong
  `MenuScreen` (bài 2). `main()` vẫn còn đồng bộ từ M01.

## Vì sao việc này quan trọng ngay bây giờ

`main()` của senior có dạng `Future<void> main() async` với một chuỗi
`await` dài trước `runApp`. Đó là nơi "app quyết định cấu hình trước khi
dựng UI": khoá dọc màn hình, đọc dart-define, khởi tạo Supabase, tạo
repository từ `SharedPreferences`, load settings để biết ngôn ngữ…

Ta chưa có những await đó — nhưng sớm có (M10 prefs, M16 settings). Bài
này dựng **khung** đúng và — quan trọng hơn — giải thích *khi nào* mỗi
thứ là bắt buộc, để bạn không học thuộc một "incantation" không hiểu.

## Bạn đã biết gì

- `void main()` + `runApp` từ M01; `Future`/`async`/`await` (bài 1–2).

## Mental model mới

**Binding trước runApp.** Flutter engine và framework nói với nhau qua một
"binding" — lớp keo nối Dart với engine (rendering, platform channels,
scheduler). `runApp` tự khởi tạo binding nếu cần, nhưng **bất kỳ call nào
chạm binding TRƯỚC `runApp`** (ví dụ `await` platform call,
`SystemChrome.setPreferredOrientations`, đọc SharedPreferences) đòi binding
đã tồn tại → phải gọi `WidgetsFlutterBinding.ensureInitialized()` trước.

```
void main() {                              sync: chạy thẳng runApp
  runApp(app);                             → binding tự tạo bên trong runApp
}

Future<void> main() async {                async: có await trước runApp
  WidgetsFlutterBinding.ensureInitialized();→ BẮT BUỘC: binding phải có
  await SystemChrome…;                        trước các await/plugin call
  await repo.create();                     → await thật của senior
  runApp(app);
}
```

`main` được `async`: Dart cho phép `main` trả `Future` — runtime sẽ chờ
nó hoàn thành trước khi coi chương trình "chạy xong phần khởi động".
`Future<void>` = "không trả giá trị, chỉ là việc khởi động async".

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `Future<void> main() async` | signature mới | `main` là hàm async — được chứa `await` |
| `WidgetsFlutterBinding.ensureInitialized()` | gọi đồng bộ | Khởi tạo binding sớm — bắt buộc nếu có await/plugin call trước `runApp` |

`ensureInitialized()` bản thân nó **đồng bộ** — không `await`, không
Future. Nó chỉ "đánh thức" binding. Một lần duy nhất đủ; gọi thừa không
hại (idempotent).

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `WidgetsFlutterBinding` | Lớp keo giữa framework và engine; `ensureInitialized()` tạo nó sớm |
| `runApp` | Gắn widget gốc — như M01, vẫn vậy |

## Cầu nối Android / Compose

- SIMILARITY: ≈ "setup trong `Application.onCreate`/`Activity.onCreate`
  trước `setContent`" — phần khởi tạo trước khi UI có mặt.
- IMPORTANT DIFFERENCE: không có `Application` subclass — `main()` chính
  là chỗ đó; và ensureInitialized **không** giống `super.onCreate` — nó là
  yêu cầu kỹ thuật khi code pre-UI cần framework binding.
- DO NOT ASSUME: "async main chậm hơn/vào thread khác" — `main` async vẫn
  trên cùng isolate; nó chỉ cho phép `await`. Và `runApp` không tự đợi
  await trong main — main await *trước khi* gọi runApp.

## Trong project senior

- `flutter-accelerator-ai/lib/main.dart` — đọc file này sẽ thấy:
  `WidgetsFlutterBinding.ensureInitialized()` đứng **đầu**, sau đó
  `await SystemChrome.setPreferredOrientations([portraitUp])`,
  `SupabaseEnvironment.fromEnvironment()`, `await
  SupabaseClientService.initialize()`, `await
  UserProfileRepositoryImpl.create()` + hai repo khác, `await
  loadUserSettings()` — rồi mới `runApp`. Đó là lý do `ensureInitialized`
  phải trước tiên: mọi `await` kia chạm binding/plugin.
- Sự khác biệt cố ý: ta chưa await gì trong `main` — vậy `main` async +
  ensureInitialized hôm nay chỉ là **shape**; nó trở nên load-bearing ở
  M10 (`await SharedPreferences.getInstance()` trước runApp). Đây là lý do
  bài này giải thích *khi nào* nó bắt buộc thay vì "cứ thêm vào".

## Từng bước thực hiện

### Bước 1 — `main()` thành async

```dart
// lib/main.dart
/// Bootstrap của app — M05: chuyển thành `async` và ensureInitialized.
///
/// `WidgetsFlutterBinding.ensureInitialized()` bắt buộc khi có bất kỳ
/// `await`/platform call nào trước `runApp`. Hôm nay chưa có await nào ở
/// đây, nhưng khung này là đúng shape của senior: M10 (đọc prefs) và M16+
/// sẽ cắm các `await` vào chính chỗ này mà không phải đổi `main()`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AIMillionaireApp());
}
```

- FILE: `lib/main.dart`
- CHANGE: `void main()` → `Future<void> main() async`; thêm
  `WidgetsFlutterBinding.ensureInitialized()` trước `runApp`.
- WHY: ký shape của bootstrap senior; khi có await thật (M10+), hai thứ
  này là điều kiện tiên quyết — và đọc code senior bạn sẽ nhận ra ngay.
- WHAT IS NEW: `async` trên `main`; `ensureInitialized` — ý nghĩa đã nói
  ở mental model.

### Bước 2 — Kiểm tra

```bash
flutter analyze
flutter test
flutter build web
```

App chạy y hệt — `ensureInitialized` đồng bộ, không đổi gì quan sát được.
Điều thay đổi là *khả năng*: `main()` giờ có thể chứa `await` mà không
cần sửa lại cấu trúc.

## Đọc hiểu code

`main` giờ là điểm khởi đầu async:

```
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();  // binding có sẵn
  // (M10 sẽ thêm: final prefs = await SharedPreferences.getInstance();)
  runApp(const AIMillionaireApp());           // chỉ dựng UI khi xong setup
}
```

Với `MenuScreen` chạy `initState` → `_loadProfile()` — hai loại "async"
khác nhau: **bootstrap-async trong `main`** (một lần, trước UI) vs
**runtime-async trong State** (sau khi UI đã có, FutureBuilder render
trạng thái). Phân biệt hai loại này là nửa việc hiểu `main` của senior.

## Chạy và quan sát

- `flutter run -d chrome` — mọi thứ y hệt bài 2 (loading → menu). Đó là
  *đúng*: bootstrap shape không đổi gì hôm nay.
- `flutter test` → 13 xanh; `flutter build web` → build thành công.

## Lỗi thường gặp

1. **`await` trước `runApp` mà quên `ensureInitialized`** — lỗi binding
   chưa sẵn sàng khi call plugin/platform; khi có await trước runApp,
   ensureInitialized là dòng đầu tiên.
2. **`await` trong `void main()`** — compile error: `void main` không
   async → không `await` được. Đó là lý do signature phải đổi.
3. **Thêm boilerplate không lý do** — nếu `main` thuần `runApp`, `async`/
   `ensureInitialized` thừa; ta thêm vì đây là *điểm neo* cho M10+ — bài
   này nói rõ điều đó thay vì bắt học thuộc.
4. **Nhầm ensureInitialized = async** — nó đồng bộ; đừng `await` nó
   (cũng không hại nếu lỡ `await` — nó trả `void`, không phải Future).

## Kiểm tra hiểu biết

1. Khi nào `ensureInitialized` bắt buộc? — Khi có bất kỳ await/platform/
   plugin call nào trước `runApp`.
2. `Future<void> main() async` khác `void main()` ở đâu? — Cho phép
   `await`; runtime chờ nó xong trong giai đoạn khởi động.
3. Vì sao senior `ensureInitialized` đứng đầu `main`? — Vì các `await`
   ngay sau (orientation, Supabase, repos, settings) đều chạm binding.
4. Ta có await gì trong `main` hôm nay không? — Chưa; đây là shape cho
   M10+ khi bootstrap-async thật sự có việc.

## Tự làm

**Tự viết — không copy.** Viết một `Future<int>` function `Future<int>
loadCoinBonus()` giả lập: sau 200ms trả `50`. Sau đó:

1. Trong `main()` (trước `runApp`) `await` nó và `print` kết quả.
2. Dự đoán thứ tự print: nếu bạn viết `print('A'); final x = await
   loadCoinBonus(); print('B:$x'); print('C');` — C in trước hay sau B?
   Chạy để kiểm chứng.
3. Đổi `await` thành `.then(print)` — hành vi khác gì? `main` còn
   "async" không?

:::note[Gợi ý]
`await` dừng **chỉ trong hàm async** chờ Future; sau `await` code chạy
lại theo thứ tự. `.then` đăng ký callback — `main` tiếp tục ngay.
:::

<details><summary><strong>Đáp án</strong></summary>

```dart
Future<int> loadCoinBonus() async {
  await Future<void>.delayed(const Duration(milliseconds: 200));
  return 50;
}
```

1. `A` → `B:50` → `C`: `await` chờ xong mới chạy tiếp dòng sau.
2. `.then(print)`: `C` in **trước** `B` vì then là callback không chặn —
   `main` xong ngay, `50` in sau 200ms. `main` không còn "async" nếu bỏ
   `await` — và `main` xong không đồng nghĩa app thoát (event loop vẫn
   chạy timer của Future.delayed).

Đây là hai bản chất khác nhau của "chờ": `await` = pause trong hàm,
`then` = đăng ký callback không pause.
</details>

## Cố ý chưa làm

- `await` thật trong `main` (đọc prefs, init repo) — M10.
- `SystemChrome.setPreferredOrientations` — senior khoá dọc; ta chưa khoá
  (đã nói ở M01; thêm khi cần).
- `SupabaseEnvironment`/`Supabase.initialize` — M23+.
- `AppDependencyScope`/Provider — M12.
- `StreamBuilder` quanh `MaterialApp` (senior dùng cho locale) — M17 khi
  l10n + settings stream tồn tại.

## Điểm kiểm tra hoàn thành

- [ ] `main()` là `Future<void> main() async` với
      `WidgetsFlutterBinding.ensureInitialized()` trước `runApp`.
- [ ] Bạn giải thích được *khi nào* ensureInitialized bắt buộc — và rằng
      hôm nay nó là shape chuẩn bị, không phải magic bắt buộc.
- [ ] `flutter analyze`/`flutter test`/`flutter build web` đều xanh.
- [ ] M05 kết thúc: menu có loading → data/error, main async, loader demo
      được test — sẵn sàng cho Stream (M06).
