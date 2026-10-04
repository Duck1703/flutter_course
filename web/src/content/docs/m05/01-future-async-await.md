---
title: "Bài 1 · Future, async & await"
description: "Đồng bộ vs bất đồng bộ, Future<T> là 'việc đang chạy' chứ không phải kết quả, async/await, Future.delayed, throw — và test async đầu tiên."
sidebar:
  label: "Bài 1 · Future/async/await"
  order: 1
---

## Mục tiêu

Sau bài này bạn phân biệt chính xác **đồng bộ vs bất đồng bộ**, nói được
`Future<T>` là gì (và không phải gì), viết được `loadDemoProfile()` —
một hàm `async` trả `Future<UserProfileData>` với delay mô phỏng và đường
lỗi `throw` — và test nó bằng `await` ngay trong `test()`.

## Bạn đang ở đâu

- Milestone: **M05 — Dart bất đồng bộ: Future** (bài 1/3)
- App hiện tại: menu M04 render từ `_profile = const UserProfileData()` —
  dữ liệu "có sẵn ngay". Thực tế app phải *tải* profile (đĩa, mạng) —
  việc xong *sau*, không xong ngay.

## Vì sao việc này quan trọng ngay bây giờ

Mọi thao tác "xong sau" trong Flutter đều qua `Future`: đọc file, HTTP,
SharedPreferences, delay, lifecycle của một dialog… App senior khởi động
bằng một chuỗi `await` trong `main()` và mọi repository trả `Future`.
Không hiểu `Future` thì không đọc được một nửa code senior.

## Bạn đã biết gì

- Hàm, return type, generics (`List<T>`, `State<T>`), `async`-free code.
- `UserProfileData` model (M04); `initState`, `mounted` (M03).

## Mental model mới

**`Future<T>` không phải `T` — nó là "việc đang chạy, sẽ cho `T` (hoặc lỗi) sau".**

Timeline của một lời gọi:

```
gọi loadDemoProfile()
   │
   ▼ trả về NGAY một Future<UserProfileData>   ← "tờ nhận hàng"
   │   (code đồng bộ vẫn chạy tiếp)
   │
   │   … 900ms sau: Future "hoàn thành" ──► value = UserProfileData
   │                                     └► hoặc error
   ▼
await future  → tạm dừng HÀM tại đây, trả quyền điều khiển cho
                event loop; khi Future xong, hàm chạy tiếp với `value`
```

Ba điều cần khắc:

1. `Future` trả về **ngay** — hàm async chạy phần đồng bộ của nó rồi trả
   Future "đang chờ" về phía gọi. `T` thật chỉ có khi Future hoàn thành.
2. `await` **tạm dừng continuation của hàm async hiện tại** — nó KHÔNG
   đóng băng app. Trong lúc `await`, event loop chạy việc khác: render
   frame, xử lý tap, chạy Future khác. UI vẫn mượt.
3. Dart single-isolate: không phải "thread khác chạy hàm này" — `await` là
   *đặt phần còn lại của hàm vào hàng đợi sự kiện*, đúng một luồng chạy
   tuần tự. (Isolate/thread thật là chủ đề khác — cố ý chưa mở ở M05.)

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `Future<T>` | `Future<UserProfileData> f = …` | Kiểu "sẽ cho T sau" — generic |
| `async` | `Future<X> foo() async { … }` | Đánh dấu hàm: return type phải là `Future<…>`; cho phép `await` bên trong |
| `await expr` | `await Future.delayed(d)` | Chờ Future trong `expr` hoàn thành → lấy `T`; chỉ dùng được trong hàm `async` |
| `Future.delayed(d)` | `await Future.delayed(const Duration(milliseconds: 900));` | Future tự hoàn thành sau `d` — mô phỏng "việc mất thời gian" |
| `throw` | `throw StateError('…');` | Ném lỗi — trong hàm async thì Future hoàn thành **với error** thay vì value |
| `try/catch` | `try { await …; } catch (e) { … }` | Bắt lỗi của Future — cú pháp giống Kotlin |
| Named params + default | `loadDemoProfile({bool fail = false, …})` | Đã gặp ở widget; giờ dùng cho hàm thường |
| `Duration` | `const Duration(milliseconds: 900)` | Kiểu thời lượng của Dart (`seconds`, `minutes`…); `Duration.zero` = không chờ |
| `late` | `late Future<void> _f;` | Field non-nullable gán **sau** khai báo — dùng thật ở bài 2 |

## Ví dụ độc lập — một `Future` là gì, in ra thử

Trước khi viết loader của app, nhìn `Future` trần trong DartPad (pure
Dart):

```dart
Future<String> fetchName() async {
  await Future.delayed(const Duration(milliseconds: 300));
  return 'An';
}

void main() async {
  print('1: gọi hàm');
  final f = fetchName();     // chạy hàm: trả về NGAY một Future
  print('2: f là $f');       // f KHÔNG phải 'An'
  final name = await f;      // chờ Future hoàn thành → lấy value
  print('3: name = $name');
}
```

Output:

```
1: gọi hàm
2: f là Instance of 'Future<String>'
3: name = An
```

Dòng 2 là cả bài học: **gọi hàm async cho bạn một `Future` — không cho
bạn `String`**. `f` là "tờ nhận hàng"; `'An'` chỉ tồn tại sau khi Future
hoàn thành, và `await` là cách lấy nó ra. Cũng nhìn kỹ: `fetchName` bắt
đầu chạy *ngay* khi được gọi (dòng `await Future.delayed` của nó đã được
xếp lịch) — Dart Future là eager, không phải "chờ ai đó bắt đầu nó".

## Flutter cần dùng

Không có widget mới trong bài này — loader là pure Dart. `FutureBuilder`
và `mounted` sau `await` sang bài 2.

## Cầu nối Android / Compose

- SIMILARITY: `Future<T>` + `await` ≈ `Deferred<T>`/`suspend fun` —
  cùng ý niệm "tính toán có kết quả sau"; `await` ≈ gọi suspend function.
- IMPORTANT DIFFERENCE: Dart `Future` bắt đầu chạy **ngay khi được tạo**
  (eager), khác coroutine `async` lười-chờ-start theo builder. Không có
  `CoroutineScope`/`viewModelScope` — không có hủy-tự-động; `await` cũng
  không gắn Job cha. Việc "hủy" ở Dart là *không dùng kết quả nữa* (hoặc
  check `mounted`), không phải cancel thật.
- DO NOT ASSUME: `await` chạy trên thread khác — sai. Cùng một luồng event
  loop; phần sau `await` được xếp lịch chạy lại khi Future xong. Nặng CPU
  thật sự mới cần `Isolate` — chủ đề khác.

## Trong project senior

- `flutter-accelerator-ai/lib/main.dart` — `Future<void> main() async` với
  chuỗi `await` trước `runApp` (orientation, Supabase, `Repo.create()…`).
- `flutter-accelerator-ai/lib/repositories/profile/user_profile_repository.dart`
  — `Future<UserProfileData> loadUserProfile()` là method bạn sẽ tái hiện
  ở M14; `throw StateError('Failed to save user profile.')` trong
  `saveUserProfile` — đúng cùng idiom `throw` của bài này.
- `flutter-accelerator-ai/lib/repositories/profile/user_profile_sync_repository.dart`
  (nếu đọc): `Future<…>` + async factories `static Future<X> create()`.
- Sự khác biệt cố ý: loader của ta là *demo* — delay + trả const. Nó là
  bản mô phỏng "load thật" chứ chưa phải repository; **M10** thay bằng
  `SharedPreferences` thật và lúc đó file này được xoá hẳn (dead code
  không sống sót trong app — M14 sau đó thay store bằng repository).

## Từng bước thực hiện

### Bước 1 — Tạo file loader

Tạo `lib/data/profile/demo_profile_loader.dart`:

```dart
import 'user_profile_data.dart';

/// Hồ sơ "đã có tiến trình" mà loader demo trả về sau delay —
/// cố ý khác hồ sơ mặc định để thấy rõ menu đổi khi tải xong.
const demoLoadedProfile = UserProfileData(
  username: '0XFF',
  level: 3,
  currentExp: 250,
  expForNextLevel: 600,
  totalMoneyWon: 150000,
  gamesJoined: 4,
  gamesWon: 2,
);
```

- FILE: `lib/data/profile/demo_profile_loader.dart` (mới)
- CHANGE: một `const` top-level — biến hằng ở file-level, không thuộc class.
- WHY: profile "đã chơi rồi" khác `const UserProfileData()` mặc định — khi
  load xong, menu **đổi thấy được** (cấp 1→3, EXP, tiền, stats 4/2/50%).

### Bước 2 — Hàm `async` trả `Future`

```dart
/// Giả lập tải hồ sơ bất đồng bộ — phục vụ giảng dạy M05.
///
/// Đây là implementation *demo*, không phải kiến trúc cuối cùng:
/// M10 thay bằng đọc `SharedPreferences`, M14 thay bằng repository.
///
/// [fail] = true để mô phỏng đường lỗi (thử trong bài học/test).
/// [delay] mặc định 900ms — đủ để nhìn thấy trạng thái loading;
/// test truyền `Duration.zero` để chạy tức thì.
Future<UserProfileData> loadDemoProfile({
  bool fail = false,
  Duration delay = const Duration(milliseconds: 900),
}) async {
  await Future.delayed(delay);
  if (fail) {
    throw StateError('Không tải được hồ sơ demo.');
  }
  return demoLoadedProfile;
}
```

Đọc từng dòng mới:

- `Future<UserProfileData> loadDemoProfile(...) async` — khai báo "hàm này
  trả Future"; `async` bật quyền `await` bên trong. Nếu bỏ `async`, hàm
  phải tự `return` một Future — `async`/`await` là đường ngắn hơn.
- `await Future.delayed(delay)` — **tạm dừng hàm này** chờ delay; dòng
  dưới chạy ~900ms sau (hoặc tức thì nếu `Duration.zero`). Trong lúc chờ,
  app chạy bình thường.
- `if (fail) throw StateError('…')` — `throw` trong hàm async ⇒ Future
  hoàn thành với **error**, không phải crash tức thì. Người gọi bắt được
  bằng `try/catch` hoặc `snapshot.hasError` (bài 2).
- `return demoLoadedProfile;` — Future hoàn thành với value.
- `Duration delay` làm tham số: bài học truyền `Duration.zero` trong test
  để **không phải chờ thật** — tham số = cửa test-ability.

### Bước 3 — Test async

`test/demo_profile_loader_test.dart`:

```dart
import 'package:ai_millionaire_course/data/profile/demo_profile_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('loadDemoProfile', () {
    test('trả về hồ sơ demo có tiến trình sau delay', () async {
      final profile = await loadDemoProfile(delay: Duration.zero);

      expect(profile, demoLoadedProfile);
      expect(profile.level, 3);
      expect(profile.totalMoneyWon, 150000);
    });

    test('fail = true thì Future hoàn thành với StateError', () {
      expect(
        loadDemoProfile(fail: true, delay: Duration.zero),
        throwsStateError,
      );
    });

    test('delay được tôn trọng (Duration.zero hoàn thành ngay)', () async {
      // Test truyền delay: Duration.zero để không chờ thật — đây là lý do
      // loader nhận delay làm tham số: kiểm soát được trong test.
      final profile = await loadDemoProfile(delay: Duration.zero);

      expect(profile.gamesJoined, 4);
    });
  });
}
```

Điểm mới trong test:

- `test('…', () async { … })` — callback test cũng được `async`: `await`
  Future ngay trong test. Runner chờ Future của test hoàn thành rồi mới
  kết luận pass/fail.
- `expect(profile, demoLoadedProfile)` — `equals` gọi `==` của bạn (M04
  trả giá): hai object khác instance nhưng cùng giá trị → pass.
- `throwsStateError` — matcher "Future ném `StateError`": expect nhận một
  **Future** làm actual (không `await`!), matcher chờ nó hoàn thành-với-lỗi.
  Đây là `throwsA(isA<StateError>())` viết gọn.
- `Duration.zero` — không phải hack; nó biến "delay 900ms" thành testable.

`flutter test` → `+13: All tests passed!` (10 cũ + 3 mới).

## Đọc hiểu code

```
loadDemoProfile() được gọi
   │
   ▼ hàm chạy đồng bộ đến await đầu tiên
   │   await Future.delayed(900ms)  → hàm "dừng", trả Future về phía gọi
   │                                  app vẫn render/tap bình thường
   │   … 900ms sau: Future.delayed hoàn thành
   ▼ hàm tiếp tục: check fail → return demoLoadedProfile
   │
   ▼ Future của loadDemoProfile hoàn thành với value
```

Với `fail: true`: sau delay, `throw StateError` → Future hoàn thành-với-
lỗi thay vì value; ai `await` nó sẽ bị ném `StateError` ngay tại `await`.

## Chạy và quan sát

- `flutter analyze` → sạch (file mới chưa được dùng — OK).
- `flutter test` → 13 xanh.
- Loader **chưa nối** vào menu — bài 2 nối bằng `FutureBuilder`.

## Lỗi thường gặp

1. **Gọi hàm async mà không `await`** — `loadDemoProfile()` trả `Future`,
   không phải `UserProfileData`; gán vào `UserProfileData p` → compile
   error. Nhớ: `Future<T>` ≠ `T`.
2. **`await` ngoài hàm `async`** — compile error; `await` chỉ hợp lệ trong
   hàm/callback đánh `async`.
3. **Nghĩ `await` block UI** — nó chỉ tạm dừng *hàm*; UI vẫn render. Đây là
   cả điểm của bất đồng bộ.
4. **Quên kiểu trả về `Future`** — khai `loadDemoProfile()` trả
   `UserProfileData` mà `async` → analyzer báo; return type của hàm `async`
   luôn là `Future<…>`.
5. **`throw` đồng nghĩa crash** — trong async, `throw` = "Future hoàn
   thành-với-lỗi"; người gọi quyết định bắt hay không.

## Kiểm tra hiểu biết

1. `loadDemoProfile()` trả `UserProfileData` hay `Future`? —
   `Future<UserProfileData>` ngay lúc gọi; `UserProfileData` chỉ có sau
   `await` hoặc khi Future hoàn thành.
2. `await` có đóng băng UI không? — Không: nó tạm dừng hàm async hiện tại;
   event loop chạy việc khác (render, gesture).
3. `throw` trong hàm `async` khác `throw` trong hàm thường thế nào? — Trong
   `async`, throw hoàn thành Future với error (bắt được ở `await`/`catch`),
   không crash tức thì.
4. Vì sao `delay` làm tham số? — Test truyền `Duration.zero` để không chờ
   900ms thật; param là điểm kiểm soát từ ngoài.

## Tự làm (PREDICT)

Dự đoán thứ tự `print` của đoạn này — viết đáp án ra giấy trước, rồi
chạy DartPad kiểm chứng:

```dart
Future<void> work() async {
  print('W1');
  await Future.delayed(const Duration(milliseconds: 100));
  print('W2');
}

void main() {
  print('M1');
  work();
  print('M2');
}
```

Bốn câu hỏi:

1. `W1` in trước hay sau `M2`?
2. `W2` in trước hay sau `M2`?
3. `work()` được gọi mà không `await` — nó có chạy không, hay "chờ ai
   khởi động"?
4. Nếu `main` kết thúc khi `W2` chưa in, `W2` có còn in không?

:::note[Gợi ý]
Hỏi hai câu: (a) hàm `async` chạy đến đâu thì dừng — câu trả lời nằm ở
"chạy phần đồng bộ rồi trả Future"; (b) khi `await` tạm dừng hàm, ai
được chạy tiếp? `main` không `await` nên nó chạy hết.
:::

<details><summary>Đáp án</summary>

```
M1
W1
M2
W2
```

- `W1` in **trước** `M2`: `work()` chạy đồng bộ đến `await` đầu tiên
  (in `W1`) rồi trả Future về `main` — Future **eager**, tự chạy ngay
  khi được gọi, không cần ai `await` nó để nó bắt đầu.
- `M2` in trước `W2`: tại `await`, `work` tạm dừng và trả quyền cho
  event loop → `main` chạy tiếp (`M2`); 100ms sau Future.delayed xong,
  `W2` được xếp lịch in.
- `main` kết thúc **không** giết `W2` — Future đã được xếp lịch vẫn chạy
  (trong app Flutter thực, event loop sống đến khi app tắt).
- Nghịch lý cần khắc: "không `await`" ≠ "không chạy" — nó chỉ nghĩa
  *người gọi không chờ kết quả*. (Cách nói "cố ý không chờ" một cách sạch
  sẽ — `unawaited` — đến M11.)

</details>

## Cố ý chưa làm

- `try/catch` quanh `await` trong app — bài 2 sẽ *không* cần: `FutureBuilder`
  bắt error qua `snapshot.hasError`. `try/catch` sẽ cần khi tự await ở VM (M11+).
- `unawaited(...)` — sẽ thấy khi ta *cố ý* bỏ qua Future (M11).
- Isolate/compute — CPU-bound work, chủ đề sau.
- `Future.wait`, `Completer` — M16/M19+ khi cần song song/điều khiển.
- Repository contract — M14; loader này là *demo*.

## Điểm kiểm tra hoàn thành

- [ ] `lib/data/profile/demo_profile_loader.dart` có `loadDemoProfile` với
      `fail`/`delay` params và `demoLoadedProfile` const.
- [ ] `test/demo_profile_loader_test.dart` 3 test: success + `throwsStateError`
      + delay-kiểm-soát.
- [ ] `flutter test` → `+13: All tests passed!`.
- [ ] Bạn nói được: "`Future<T>` là việc đang chạy, không phải `T`".
