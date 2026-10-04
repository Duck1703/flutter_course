---
title: "Bài 2 · FutureBuilder: loading → data/error"
description: "late field + initState khởi động tải, mounted guard sau await, FutureBuilder với ConnectionState và hasError, và UI loading/lỗi/retry."
sidebar:
  label: "Bài 2 · FutureBuilder"
  order: 2
---

## Mục tiêu

Nối `loadDemoProfile()` vào `MenuScreen` bằng `FutureBuilder`: mở app hiện
"Đang tải hồ sơ…", xong thì menu hiện profile đã tải; lỗi thì hiện
`_MenuErrorState` có nút **THỬ LẠI**. Học `late` (dùng thật), `mounted`
sau `await`, và quy tắc **không tạo Future trong build()**.

## Bạn đang ở đâu

- Milestone: **M05 — Dart bất đồng bộ: Future** (bài 2/3)
- App hiện tại: `loadDemoProfile()` + `demoLoadedProfile` sẵn trong
  `lib/data/profile/`; menu M04 render từ `_profile` qua setState.

## Vì sao việc này quan trọng ngay bây giờ

Hai vấn đề cần giải cùng lúc: (a) hàm `async` trả Future phải được *khởi
động một lần* và *được chờ* — và (b) UI cần **ba trạng thái** (đang tải /
lỗi / xong). `FutureBuilder` là widget chuyên cho điều này: nó subscribe
vào Future và tự rebuild theo trạng thái của Future — bạn chỉ mô tả "trạng
thái X thì render Y".

Song song đó, profile tải xong vẫn phải là **state có thể mutate** (vì nút
chơi `gainExp` nó) — nên `FutureBuilder` ở đây lo phần *vòng đời tải*,
còn `_profile` trong `State` vẫn là nguồn sự thật hiển thị. Đây là pattern
thật, không phải giả.

## Bạn đã biết gì

- `Future`/`async`/`await`/`throw` (bài 1); `initState`/`dispose`/`setState`
  (M03); `UserProfileData` + `gainExp` (M04).

## Mental model mới

**FutureBuilder = "render theo trạng thái Future".**

```
initState:  _profileLoadFuture = _loadProfile()      ← Future sinh ra 1 lần
                 │
                 ▼ mỗi khi Future đổi trạng thái
FutureBuilder( future: _profileLoadFuture,
               builder: (context, snapshot) { … })
                 │
   snapshot.connectionState == waiting   → _MenuLoading()
   snapshot.hasError                     → _MenuErrorState(onRetry: …)
   else                                  → menu với _profile
```

`snapshot` là `AsyncSnapshot<T>` — "ảnh chụp" trạng thái hiện tại của
Future: `connectionState` (`none`/`waiting`/`done`), `data`, `error`,
`hasError`, `hasData`. Ta chỉ dùng vừa đủ ba nhánh trên.

Hai quy tắc vàng — nhớ mãi:

1. **Không tạo Future trong `build()`** — `future: loadDemoProfile()` sẽ
   *khởi động lại tác vụ mỗi lần rebuild* (và rebuild xảy ra liên tục).
   Future phải là **field ổn định** của `State`, gán một lần ở `initState`
   (và gán lại chỉ khi retry).
2. **`await` xong, check `mounted` trước `setState`** — trong lúc chờ,
   widget có thể đã bị gỡ; `setState` sau dispose là crash. `mounted` là
   property của `State` trả `true` nếu còn gắn trên cây.

## Ví dụ độc lập — `FutureBuilder` tối thiểu

Trước khi bọc menu, xem `FutureBuilder` trọn vẹn trong một app 40 dòng
(DartPad — chế độ Flutter). App này tải một "câu quote" giả:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: QuoteLoader()));

class QuoteLoader extends StatefulWidget {
  const QuoteLoader({super.key});
  @override
  State<QuoteLoader> createState() => _QuoteLoaderState();
}

class _QuoteLoaderState extends State<QuoteLoader> {
  late Future<String> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchQuote(); // Future sinh MỘT LẦN — không trong build
  }

  Future<String> _fetchQuote() async {
    await Future.delayed(const Duration(seconds: 1));
    return 'Keep it simple.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<String>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Text('Lỗi rồi!');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            return Text(snapshot.data ?? '');
          },
        ),
      ),
    );
  }
}
```

Chạy nó: spinner ~1 giây → "Keep it simple.". Ba chi tiết đáng để ý trước
khi quay lại app thật:

- `FutureBuilder<String>` mang **kiểu** — `snapshot.data` là `String?`
  (nullable!) nên cần `?? ''`; bản `FutureBuilder<void>` của menu chỉ
  đọc trạng thái vì dữ liệu đi vào `_profile` qua setState.
- `_future` là `late` field gán ở `initState` — đúng hai quy tắc vàng
  phía dưới.
- Không `setState` nào trong ví dụ: **FutureBuilder tự subscribe và tự
  rebuild** — đó là cả lý do nó tồn tại.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
| --------- | ------- | ------- |
| `late` | `late Future<void> _profileLoadFuture;` | Field non-nullable nhưng **gán sau** — hợp lệ vì initState gán trước khi build đọc; nếu đọc trước khi gán → `LateInitializationError` lúc chạy |
| `Future<void>` | kiểu của `_profileLoadFuture` | Future không mang giá trị — chỉ quan tâm *khi nào xong/lỗi* |
| `!mounted` | `if (!mounted) return;` | Kiểm State còn sống không |
| `throw` lan truyền | `_loadProfile` không `try/catch` | Lỗi loader lan ra Future → `snapshot.hasError` bắt được |

Về `late` — bài 1 đã nhắc; giờ là lúc dùng thật: `_profileLoadFuture` là
`late` vì *không thể* gán ngay chỗ khai báo (nó cần gọi `_loadProfile()`,
và việc đó thuộc `initState`). `late` hợp lệ đúng chỗ này — không phải
trò lách null-safety.

## Flutter cần dùng

| API | Vai trò |
| ----- | --------- |
| `FutureBuilder<T>` | Widget subscribe vào `future:`, rebuild theo trạng thái — "builder" nhận `(context, snapshot)` |
| `AsyncSnapshot<T>` | Trạng thái hiện tại của Future/Stream: `connectionState`, `data`, `error`, `hasError`, `hasData` |
| `ConnectionState.waiting` / `.done` | `waiting` = chưa xong; `done` = xong (kể cả lỗi — nên check `hasError` trước) |
| `CircularProgressIndicator` | Vòng quay loading của Material — widget mới, tự animate |
| `mounted` | `State` còn gắn trên cây không |

## Cầu nối Android / Compose

- SIMILARITY: `FutureBuilder` ≈ `produceState`/`collectAsState` bọc trạng
  thái async vào UI — "UI là hàm của trạng thái tải".
- IMPORTANT DIFFERENCE: `FutureBuilder` là **Widget trong cây**, không phải
  effect — nó tự subscribe/huỷ-subscribe theo lifecycle widget; bạn không
  tự viết `LaunchedEffect`/`DisposableEffect`.
- DO NOT ASSUME: `snapshot.data` non-null — nó là `T?`; với
  `FutureBuilder<void>` ta đọc `connectionState`/`hasError` chứ không đọc
  `data` (data là `void`). Khi Future mang kiểu, `data` vẫn nullable —
  senior check `snapshot.data ?? …` trong onboarding scope.

## Trong project senior

- `flutter-accelerator-ai/lib/widgets/onboarding/onboarding_overlay_scope.dart`
  — `FutureBuilder<bool>(future: _completionFuture, builder: …)`:
  `_completionFuture` là **field được lưu** (không tạo trong build),
  check `snapshot.connectionState != ConnectionState.done` → trả widget
  trống, rồi `snapshot.data ?? repository.…value` — đúng ba kỹ thuật bài
  này dạy (stable future, connectionState, `??` với data nullable).
- `flutter-accelerator-ai/lib/repositories/onboarding/onboarding_repository.dart`
  — `Future<bool> loadOnboardingCompleted()` là Future-method thật mà
  FutureBuilder trên đang chờ.
- Sự khác biệt cố ý: senior gate bằng `FutureBuilder` rồi mới tạo
  `OnboardingViewModel`; ta dùng `FutureBuilder` để render trạng thái tải
  của profile — cùng một cơ chế.

## Từng bước thực hiện

### Bước 1 — Field `late` + `initState` khởi động

```dart
// lib/screens/menu_screen.dart — trong _MenuScreenState
  bool _soundOn = true;
  int _playTapCount = 0;
  UserProfileData _profile = const UserProfileData();

  /// Future của lần tải profile — được gán MỘT LẦN trong initState (và gán
  /// lại khi retry). Không bao giờ gọi loader trực tiếp trong build().
  late Future<void> _profileLoadFuture;

  @override
  void initState() {
    super.initState();
    debugPrint('[MenuScreen] initState — State được tạo, bắt đầu tải profile');
    _profileLoadFuture = _loadProfile();
  }
```

- FILE: `lib/screens/menu_screen.dart`
- CHANGE: thêm field `late Future<void> _profileLoadFuture`; `initState`
  gán nó bằng kết quả `_loadProfile()` (hàm ở bước 2).
- WHY: Future cần sinh **một lần** khi State được tạo và được giữ ổn định —
  `initState` là chỗ chuẩn.
- WHAT IS NEW: `late` — field non-nullable nhưng chưa thể gán tại khai báo;
  `initState` gán trước khi `build` đọc → an toàn.

### Bước 2 — `_loadProfile` (await → mounted → setState) + retry

```dart
  /// Tải profile bất đồng bộ. Future trả về được giữ trong
  /// [_profileLoadFuture] để FutureBuilder render theo vòng đời của nó;
  /// dữ liệu tải xong đi vào field [_profile] vì các tương tác khác
  /// (tập luyện) còn mutate nó bằng copyWith/gainExp.
  Future<void> _loadProfile() async {
    final loaded = await loadDemoProfile();
    // Sau await, State có thể đã bị gỡ khỏi cây — mounted check trước
    // setState là bắt buộc (xem bài M05 về setState-after-dispose).
    if (!mounted) return;
    setState(() {
      _profile = loaded;
    });
  }

  /// Retry khi tải lỗi: gán lại Future cho field — FutureBuilder tự chuyển
  /// về trạng thái waiting.
  void _retryLoadProfile() {
    setState(() {
      _profileLoadFuture = _loadProfile();
    });
  }
```

Đọc kỹ:

- `_loadProfile` là `async` trả `Future<void>` — ta **không** dùng kết quả
  trả về; ta dùng *vòng đời* của Future (đang chạy / lỗi / xong) để
  FutureBuilder render.
- `await loadDemoProfile()` — chờ ~900ms; `loaded` là `UserProfileData`.
- `if (!mounted) return;` — trong lúc chờ, widget có thể đã bị huỷ
  (ví dụ M07 sau này sẽ push route khác). `setState` trên State đã gỡ =
  `setState() called after dispose()`. Check là bắt buộc.
- `setState(() => _profile = loaded)` — profile tải xong đi vào field như
  mọi state khác; `gainExp` ở nút chơi vẫn hoạt động trên profile này.
- **Không `try/catch`** ở đây: `loadDemoProfile` ném → `_loadProfile` ném
  → Future của nó hoàn thành-với-lỗi → `FutureBuilder.snapshot.hasError`.
  `catch` sẽ *nuốt* lỗi, biến Future thành "xong bình thường" — sai.
- `_retryLoadProfile` — gán `_profileLoadFuture` một Future **mới** trong
  `setState` → `FutureBuilder` thấy future đổi → quay về `waiting` → tải
  lại. Retry đúng nghĩa chỉ là "khởi động Future mới cho field".

### Bước 3 — Bọc nội dung bằng `FutureBuilder`

```dart
// lib/screens/menu_screen.dart — trong build(), thay Column
              child: FutureBuilder<void>(
                future: _profileLoadFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _MenuErrorState(onRetry: _retryLoadProfile);
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _MenuLoading();
                  }
                  return Column(
                    children: [
                      _ProfileHeader(
                        profile: _profile,
                        soundOn: _soundOn,
                        onSoundTap: _toggleSound,
                      ),
                      Expanded(child: _MenuBody(profile: _profile)),
                      _PlayButton(
                        tapCount: _playTapCount,
                        onTap: _onPlayTap,
                      ),
                    ],
                  );
                },
              ),
```

- `FutureBuilder<void>(future: …, builder: …)` — `builder` là closure
  `(BuildContext, AsyncSnapshot) → Widget`: mỗi lần Future đổi trạng thái,
  Flutter gọi lại builder.
- Thứ tự check: **`hasError` trước** (done-với-lỗi cũng là done), rồi
  `waiting`, còn lại là xong-thành-công → render menu.
- `_profile` vẫn được render trong nhánh xong — vì `_loadProfile` đã
  `setState` nó vào field; nhánh này chỉ chạy khi Future *done*, tức
  `_profile` đã chứa giá trị tải về.
- Column trước đây là `child:` trực tiếp — giờ nó là **kết quả của builder**
  ở nhánh done.

### Bước 4 — Hai widget trạng thái

```dart
/// Trạng thái đang tải profile — vòng quay + nhãn.
class _MenuLoading extends StatelessWidget {
  const _MenuLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: MenuTokens.accentCyan),
        SizedBox(height: MenuTokens.spacingMd),
        Text(
          'Đang tải hồ sơ…',
          style: TextStyle(color: MenuTokens.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

/// Trạng thái tải lỗi — icon + thông báo + nút thử lại.
class _MenuErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _MenuErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline,
          color: MenuTokens.accentYellow,
          size: 40,
        ),
        const SizedBox(height: MenuTokens.spacingSm),
        const Text(
          'Không tải được hồ sơ.',
          style: TextStyle(color: MenuTokens.textPrimary, fontSize: 15),
        ),
        const SizedBox(height: MenuTokens.spacingMd),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MenuTokens.spacingLg,
              vertical: MenuTokens.spacingSm,
            ),
            decoration: BoxDecoration(
              color: MenuTokens.cardBackground,
              borderRadius: BorderRadius.circular(MenuTokens.radiusPill),
              border: Border.all(color: MenuTokens.cardBorder),
            ),
            child: const Text(
              'THỬ LẠI',
              style: TextStyle(
                color: MenuTokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

- `CircularProgressIndicator` — widget mới: vòng quay loading tự animate,
  `color:` nhận token.
- Nút THỬ LẠI = `GestureDetector` + `Container` pill — cùng phong cách
  `_PlayButton`, chưa cần `ElevatedButton`/`FilledButton` (Material button
  sẽ đến khi có flow thật ở M07+).

`flutter analyze` → sạch. `flutter run -d chrome` → mở app thấy "Đang tải
hồ sơ…" ~900ms → menu hiện với **CẤP 3, 250/600 EXP, 150.000 VNĐ,
Đã chơi 4 / Thắng 2 / 50%**.

## Đọc hiểu code

Luồng đầy đủ:

```
main() → runApp → MenuScreen → createState → initState
   └─ _profileLoadFuture = _loadProfile()          (Future sinh 1 lần)
        └─ await loadDemoProfile() …đang chờ…
   └─ build() → FutureBuilder: connectionState=waiting → _MenuLoading()
        │
        ▼ ~900ms sau, Future.delayed xong
   _loadProfile tiếp: mounted ✓ → setState(_profile = loaded)
        └─ Future của _loadProfile hoàn thành (void)
   FutureBuilder rebuild: done → Column menu với _profile MỚI
```

Đường lỗi: `fail: true` → `throw` → Future error → `hasError` →
`_MenuErrorState`; bấm THỬ LẠI → `_retryLoadProfile` gán future mới →
`waiting` → xong.

## Chạy và quan sát

- `flutter run -d chrome` — thấy spinner ~1s rồi menu.
- Thử đường lỗi: tạm đổi `_profileLoadFuture = _loadProfile()` thành
  `loadDemoProfile(fail: true)` trong một biến thể gọi (hoặc tạm sửa
  `_loadProfile` gọi `loadDemoProfile(fail: true)`) → chạy lại → thấy
  error state; bấm THỬ LẠI → lại loading → lỗi (vì vẫn fail). Sửa về sau.
- Hot Reload giữ `_profile` đã tải; Hot Restart tải lại từ đầu (lại thấy
  loading ~1s).

## Lỗi thường gặp

1. **`future: loadDemoProfile()` trong build** — mỗi rebuild tạo Future
   mới → tải lại liên tục (loading nhấp nháy/gọi nhiều lần). Future phải
   là field ổn định.
2. **Quên `mounted` sau `await`** — app sẽ crash "setState after dispose"
   khi widget bị gỡ giữa chừng (M07 navigation là nơi dễ tái hiện).
3. **`try/catch` nuốt lỗi rồi setState xong** — `hasError` sẽ không bao giờ
   true vì catch đã "xử lý" lỗi ở tầng hàm. Sai tầng: lỗi phải lan ra
   Future để FutureBuilder thấy.
4. **Đọc `snapshot.data` như non-null** — với `FutureBuilder<T>` data là
   `T?`; ở đây ta dùng `FutureBuilder<void>` nên chỉ đọc trạng thái.
5. **Check `connectionState == done` trước `hasError`** — done-với-lỗi
   cũng tính done → sẽ render menu với `_profile` mặc định thay vì error
   state. Luôn `hasError` trước.

## Kiểm tra hiểu biết

1. `late` dùng khi nào? — Khi field non-nullable không gán được ngay chỗ
   khai báo nhưng chắc chắn gán trước khi đọc (`initState`).
2. Vì sao `_loadProfile` trả `Future<void>` chứ không `Future<UserProfileData>`?
   — Vì FutureBuilder chỉ cần *vòng đời* tải; dữ liệu đi vào `_profile`
   qua setState để các tương tác khác còn mutate được.
3. `AsyncSnapshot` chứa gì? — `connectionState`, `data`, `error`,
   `hasError`, `hasData`.
4. Retry là gì về mặt cơ chế? — Gán `_profileLoadFuture` một Future mới
   trong `setState` — FutureBuilder tự chuyển về waiting.

## Tự làm (PREDICT)

Phá luật vàng số 1 một cách có chủ đích — trong `build()`, đổi:

```dart
// từ:
future: _profileLoadFuture,
// thành:
future: _loadProfile(),   // tạo Future mới ngay trong build!
```

**Trước khi chạy**, dự đoán: app khởi động bình thường không? Sau khi
menu hiện, bấm nút PLAY (nó gọi `setState`) — điều gì xảy ra với màn
hình? Bấm thêm 3 lần nữa?

Sau đó chạy thật, quan sát, rồi sửa lại.

:::note[Gợi ý]
`_loadProfile()` trả về gì? Một Future **mới** — và Future mới nghĩa là
một lần tải mới vừa được khởi động. `setState` ở nút PLAY gọi `build()`
→ `build` tạo Future mới → …?
:::

<details><summary>Đáp án</summary>

- Khởi động vẫn có vẻ bình thường (loading → menu) — vì lần đầu chỉ có
  một Future.
- Bấm PLAY một lần: `_onPlayTap` → `setState` → `build()` chạy lại →
  `_loadProfile()` tạo **Future mới** → `FutureBuilder` thấy future đổi
  → quay về `waiting` → **toàn màn hình chớp về spinner** ~900ms rồi
  hiện lại menu.
- Mỗi lần bấm lặp lại hiện tượng: mọi `setState` (đổi âm thanh, đếm
  bấm) đều khởi động một lần tải mới — reload vô hình ở mọi tương tác,
  tồi tệ hơn nữa nếu loader gọi mạng thật.
- Đó là lý do Future phải là **field ổn định của `State`**: `initState`
  tạo một lần, chỉ gán lại khi cố ý retry. Future-in-build không "sai
  compile" — nó sai *ngữ nghĩa*: build phải thuần mô tả UI, không phải
  nơi khởi động công việc.

</details>

## Cố ý chưa làm

- `try/catch` ở `_loadProfile` — cố ý để lỗi lan ra Future; `try/catch`
  thật sự sẽ dùng khi VM tự await và tự xử lý (M11+).
- `snapshot.data`/`hasData` — `FutureBuilder<void>` không có data; sẽ gặp
  đầy đủ ở `StreamBuilder` (M06) và các builder mang dữ liệu sau này.
- Huỷ Future khi widget dispose — Dart không cancel Future; `mounted`
  check là cách "không dùng kết quả nữa". Token/staleness guard đến M19+.
- `ElevatedButton` cho retry — giữ `GestureDetector`+pill đồng nhất CTA.
- Pull-to-refresh / reload ngầm — chưa cần.

## Điểm kiểm tra hoàn thành

- [ ] `_profileLoadFuture` là `late` field, gán ở `initState` — **không**
      gọi loader trong `build()`.
- [ ] `_loadProfile` có `if (!mounted) return;` trước `setState`.
- [ ] Ba nhánh `hasError` / `waiting` / done render `_MenuErrorState` /
      `_MenuLoading` / menu.
- [ ] `flutter analyze` sạch; `flutter test` 13 xanh.
