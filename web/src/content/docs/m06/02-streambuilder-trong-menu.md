---
title: "Bài 2 · StreamBuilder trong menu"
description: "StreamBuilder + initialData + AsyncSnapshot, stable-stream field, và thẻ 'Thời gian phiên' tự cập nhật mà không cần setState."
sidebar:
  label: "Bài 2 · StreamBuilder"
  order: 2
---

## Mục tiêu

Đưa `menuSessionTicker()` vào menu: một `_SessionTickerCard` hiển thị
"Thời gian phiên: Ns" tự đếm mỗi giây — bằng `StreamBuilder`, không
`setState`. Học `initialData`, `snapshot.data` nullable, và quy tắc
**stable-stream** (song sinh của stable-Future ở M05).

## Bạn đang ở đâu

- Milestone: **M06 — Stream & StreamBuilder** (bài 2/3)
- App hiện tại: `menuSessionTicker()` sẵn trong `lib/data/`; menu M05 có
  FutureBuilder loading → profile.

## Vì sao việc này quan trọng ngay bây giờ

`StreamBuilder` là widget-cầu giữa stream và cây widget: nó `listen` stream
khi được gắn vào cây, gọi `builder` mỗi event, và **tự cancel** subscription
khi widget bị gỡ — đúng thứ bạn sẽ thấy khắp app senior (locale của
`MaterialApp`, onboarding gate). Nắm `StreamBuilder` là nắm được nửa câu
chuyện "UI phản ứng với dữ liệu theo thời gian" của toàn bộ course.

## Bạn đã biết gì

- `FutureBuilder` + `AsyncSnapshot` (M05 bài 2); `Stream`/`periodic`/
  `take`/`first` (bài 1); `setState` (M03).

## Mental model mới

**StreamBuilder = FutureBuilder nhưng cho chuỗi event.**

```
State field:  _sessionTicker = menuSessionTicker()   ← Stream sinh 1 lần
                     │
                     ▼ StreamBuilder subscribe khi vào cây
StreamBuilder<int>( stream: _sessionTicker,
                    initialData: 0,
                    builder: (context, snapshot) => Text('${snapshot.data}s'))
                     │
   mỗi event 1,2,3… → Flutter gọi builder() → Text rebuild → UI đổi
   widget gỡ khỏi cây → StreamBuilder tự cancel subscription
```

Khác FutureBuilder ở chỗ: `snapshot.data` **đổi sau mỗi event** — mỗi giây
builder chạy lại với số mới. Future chỉ đổi một lần (waiting→done); stream
cứ phát là builder chạy.

Và **stable-stream**: giống stable-Future — nếu tạo `menuSessionTicker()`
ngay trong `build()`, mỗi rebuild trả stream *instance khác* → `StreamBuilder`
thấy `stream` đổi → cancel cũ + subscribe mới → **bộ đếm reset liên tục**.
Field `final Stream<int> _sessionTicker` giữ một instance cho cả đời State.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `Stream<T>` field | `final Stream<int> _sessionTicker = …` | Giữ stream ổn định trong `State` |
| `snapshot.data` | `'${snapshot.data ?? 0}s'` | `int?` — event mới nhất; `??` fallback khi chưa có |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `StreamBuilder<T>` | Widget subscribe `stream:`, rebuild `builder` mỗi event; tự cancel khi gỡ cây |
| `initialData` | Giá trị "khởi đầu" cho snapshot trước event đầu — tránh hiển thị rỗng |
| `AsyncSnapshot<T>` (stream) | Giống FutureBuilder: `data` = event mới nhất, `connectionState`, `hasError`… |

## Cầu nối Android / Compose

- SIMILARITY: `StreamBuilder` ≈ `flow.collectAsState()` + UI đọc state —
  "stream chảy vào thành state UI".
- IMPORTANT DIFFERENCE: `StreamBuilder` là **widget** quản lý subscription
  trong lifecycle của chính nó — vào cây thì nghe, ra khỏi cây thì huỷ.
  Compose `collectAsState` dùng scope của composition; cơ chế khác nhau
  nhưng ý niệm "hủy theo lifecycle" giống.
- DO NOT ASSUME: mọi `Stream` đều cần `StreamBuilder` — bài 3 sẽ cho thấy
  `listen`/`cancel` tay (đúng cách VM senior làm). `StreamBuilder` chỉ là
  đường tiện cho *UI*; state không render trực tiếp thì dùng subscription.

## Trong project senior

- `flutter-accelerator-ai/lib/main.dart` — `StreamBuilder(stream:
  settingsStream, initialData: settingsStream.value, builder: …)` bọc
  `MaterialApp`: mỗi event settings → rebuild với `locale` mới — đúng cùng
  widget bạn vừa dùng, chỉ to hơn.
- `flutter-accelerator-ai/lib/widgets/onboarding/onboarding_overlay_scope.dart`
  — `StreamBuilder<bool>(stream: …, initialData: …)` lồng trong
  `FutureBuilder` — cặp Future→Stream mà course sẽ gặp lại ở M18.
- Sự khác biệt cố ý: senior truyền `initialData: stream.value` — `.value`
  là đặc quyền của `ValueStream` (rxdart); stream SDK của ta không có
  `.value` nên `initialData: 0` là giá trị seed trực tiếp. M14 sẽ gặp bản
  đầy đủ.

## Từng bước thực hiện

### Bước 1 — Field stream ổn định trong `State`

```dart
// lib/screens/menu_screen.dart — trong _MenuScreenState
  /// Stream đếm giây phiên menu — tạo MỘT LẦN như field ổn định.
  /// (Tạo stream mới mỗi lần build sẽ khiến StreamBuilder huỷ subscribe cũ
  /// và subscribe lại từ đầu — bộ đếm sẽ reset liên tục.)
  final Stream<int> _sessionTicker = menuSessionTicker();
```

- FILE: `lib/screens/menu_screen.dart`
- CHANGE: thêm `final` field (không `late` — vì gán được ngay chỗ khai báo:
  `menuSessionTicker()` là hàm top-level không cần `this`).
- WHY: một instance duy nhất cho suốt đời State → subscription ổn định.
- WHAT IS NEW: field kiểu `Stream<int>` — "một ống event" nằm trong State.

### Bước 2 — Truyền ticker xuống `_MenuBody`

```dart
// trong nhánh done của FutureBuilder
                      Expanded(
                        child: _MenuBody(
                          profile: _profile,
                          ticker: _sessionTicker,
                        ),
                      ),
```

```dart
class _MenuBody extends StatelessWidget {
  final UserProfileData profile;
  final Stream<int> ticker;

  const _MenuBody({required this.profile, required this.ticker});
```

Và thêm thẻ vào cuối `Column` của `_MenuBody`:

```dart
            _StatsRow(profile: profile),
            const SizedBox(height: MenuTokens.spacingSm),
            _SessionTickerCard(stream: ticker),
```

- `Stream<int>` cũng chỉ là một **kiểu dữ liệu** truyền như bất kỳ tham số
  nào — "data down". Card con nhận stream và tự quyết định nghe nó.

### Bước 3 — `_SessionTickerCard` với `StreamBuilder`

```dart
/// Thẻ "đồng hồ phiên" — số giây cập nhật tự động từ Stream, không cần
/// setState: StreamBuilder tự rebuild mỗi khi stream phát event.
class _SessionTickerCard extends StatelessWidget {
  final Stream<int> stream;

  const _SessionTickerCard({required this.stream});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MenuTokens.spacingMd,
        vertical: MenuTokens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: MenuTokens.cardBackground,
        borderRadius: BorderRadius.circular(MenuTokens.radiusCard),
        border: Border.all(color: MenuTokens.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_outlined,
            color: MenuTokens.accentCyan,
            size: 18,
          ),
          const SizedBox(width: MenuTokens.spacingXs),
          const Expanded(
            child: Text(
              'Thời gian phiên',
              style: TextStyle(
                color: MenuTokens.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          StreamBuilder<int>(
            stream: stream,
            initialData: 0,
            builder: (context, snapshot) {
              return Text(
                '${snapshot.data ?? 0}s',
                style: const TextStyle(
                  color: MenuTokens.accentCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

- `StreamBuilder<int>(stream: stream, initialData: 0, builder: …)` —
  `builder` chạy: lần đầu với `initialData` (`0`), rồi mỗi event 1,2,3…
- `snapshot.data` là `int?`: trước event đầu nó là `initialData` (0); giữ
  `?? 0` như phòng thủ nhỏ — đồng thời là nhắc nhở "data của snapshot
  nullable" (senior `snapshot.data ?? …` trong onboarding).
- Phạm vi rebuild **tối thiểu**: chỉ `Text` cuối Row thay mỗi giây — phần
  `const` (icon, label) không build lại. Đây là lý do StreamBuilder nên đặt
  *sâu nhất có thể* — ngược với cảm giác "bọc cả màn hình".

`flutter analyze` → sạch. `flutter run -d chrome` → sau loading, menu hiện
thẻ "Thời gian phiên 0s" → `1s, 2s, 3s…` tự tăng.

## Đọc hiểu code

```
_MenuScreenState._sessionTicker (một Stream instance duy nhất)
        │
        ▼ _SessionTickerCard vào cây (nhánh done của FutureBuilder)
StreamBuilder subscribe stream → event 1,2,3… mỗi giây
        │
        ▼ mỗi event → builder(context, snapshot) với data=event
        Text('${data ?? 0}s') rebuild → số hiển thị đổi
        │
        ▼ card bị gỡ (route đổi/ẩn) → StreamBuilder cancel subscription
           → ticker ngừng phát cho listener này
```

Không một dòng `setState` nào — event tự kéo rebuild. Đây là "UI phản ứng
với stream" đúng nghĩa.

## Chạy và quan sát

- `flutter run -d chrome` — thẻ phiên đếm `0s → 1s → 2s…`.
- Hot Reload **không** reset bộ đếm (stream + State sống xuyên rebuild —
  M03 quy tắc lifecycle); Hot Restart reset về 0s và tải lại profile.
- Thử nghiệm stable-stream (tùy chọn, học bằng cách phá): đổi
  `stream: stream` thành `stream: menuSessionTicker()` ngay trong card —
  đếm sẽ reset/nhảy khi cha rebuild (ví dụ bấm nút chơi). Đó là lý do field
  `final` tồn tại. Sửa lại sau khi thấy.

## Lỗi thường gặp

1. **Tạo stream trong `build`** — mỗi rebuild là instance mới →
   StreamBuilder huỷ/nghe lại → đếm reset. Stream là field ổn định.
2. **Đọc `snapshot.data` như non-null** — `int?`; trước event đầu nó là
   `initialData` (hoặc `null` nếu không khai). `??`/`initialData` che chỗ đó.
3. **Bọc StreamBuilder quá cao** — quanh cả `Column` sẽ rebuild cả menu mỗi
   giây; đặt nó quanh đúng `Text` cần đổi.
4. **Nghĩ StreamBuilder bắt buộc** — `listen`/`cancel` tay vẫn là cách hợp
   lệ (bài 3); StreamBuilder chỉ tiện cho *UI*.
5. **Quên stream vô hạn khi test** — `take(n)` giới hạn trước khi expect;
   `emitsInOrder` trên stream vô hạn sẽ chờ mãi.

## Kiểm tra hiểu biết

1. StreamBuilder tự làm gì khi widget gỡ khỏi cây? — Cancel subscription —
   đó là lý do nó tiện hơn `listen` tay cho UI.
2. `initialData` khác `snapshot.data` thế nào? — `initialData` là giá trị
   seed trước event đầu; `snapshot.data` là event mới nhất (hoặc
   `initialData` nếu chưa có event).
3. Vì sao `_sessionTicker` là `final` field chứ không tạo trong `build()`?
   — Instance mới mỗi build sẽ làm StreamBuilder resubscribe và bộ đếm
   reset.
4. StreamBuilder vs `setState` để đổi UI theo stream — chọn cái nào khi chỉ
   cần hiển thị event? — StreamBuilder: không cần lưu event vào State, ít
   code, tự quản lifecycle.

## Cố ý chưa làm

- `listen`/`cancel` tay + `StreamController`/`broadcast` — bài 3 (learning
  example, và trong app senior).
- Stream dẫn *profile* (live-update model từ repository) — cần repository
  `ValueStream`, M14; hôm nay stream chỉ đếm giây.
- `connectionState` chi tiết trên StreamBuilder — ta dùng `initialData` để
  tránh trạng thái trống; phân tích đầy đủ `none/waiting/active/done` khi
  cần (M14).
- `Stream`-based countdown game timer — M09 (`Timer`/`periodic` trong VM).

## Điểm kiểm tra hoàn thành

- [ ] `_sessionTicker` là `final` field của State — không tạo trong build.
- [ ] `_SessionTickerCard` dùng `StreamBuilder<int>` + `initialData: 0` +
      `snapshot.data ?? 0`.
- [ ] Thẻ đếm tự tăng mỗi giây, phần còn lại của menu không rebuild thêm.
- [ ] `flutter analyze`/`flutter test`/`flutter build web` đều xanh.
