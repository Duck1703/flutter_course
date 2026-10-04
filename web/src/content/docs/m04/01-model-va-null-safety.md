---
title: "Bài 1 · Vì sao UI cần model & null safety"
description: "Từ giá trị rời rạc đến một object dữ liệu: class Dart, field final, named params, kiểu nullable String?, và toán tử ??."
sidebar:
  label: "Bài 1 · Model & null safety"
  order: 1
---

## Mục tiêu

Sau bài này bạn giải thích được vì sao menu nên đọc dữ liệu từ **một object
model** thay vì các literal rải rác, viết được class `UserProfileData` với
constructor `const` + named params + giá trị mặc định, và nói chính xác
`String` khác `String?` ở chỗ nào.

## Bạn đang ở đâu

- Milestone: **M04 — Model bất biến & unit test đầu tiên** (bài 1/4)
- App hiện tại: menu M03 tương tác được — nhưng `'Khách'`, `'CẤP 1'`,
  `'120 / 400 EXP'`, `'0 VNĐ'` nằm rải rác trong từng widget con.

## Vì sao việc này quan trọng ngay bây giờ

Nhìn lại `_LevelCard`, `_EarningsCard`, `_StatsRow` của M03: mỗi widget tự
hard-code con số của nó. Ba vấn đề thật:

1. **Không có "một nguồn sự thật".** Đổi EXP ở `_LevelCard` nhưng quên đổi
   chỗ khác → UI tự mâu thuẫn. Khi game thật (M08/M09) cập nhật profile,
   ta sẽ cập nhật **một object** — UI tự nhất quán.
2. **Không test được.** Một literal `'120'` trong `Text` không có hành vi
   nào để kiểm chứng; một `profile.gainExp(10)` thì có — và bài 4 sẽ test nó.
3. **Không "bám" vào app senior.** Senior có hẳn `lib/data/profile/
   user_profile_data.dart` — một model immutable. Milestone này tạo bản
   đơn giản của nó, đúng nghĩa.

## Bạn đã biết gì

- `class`, constructor + `this.field`, named params + `required` (mọi widget
  M02–M03 đều dùng).
- `final` field bất biến trong widget; `const` constructor.
- Nội suy chuỗi `'${expr}'`, ternary `?:`, `import` tương đối.

## Mental model mới

**Dữ liệu ≠ hiển thị.** Cho đến nay mỗi `Text('120 / 400 EXP')` vừa là dữ
liệu vừa là hiển thị. Từ bài này:

```
┌─────────────────────────────────────────────────┐
│  UserProfileData   ← "tờ giấy khai" dữ liệu      │
│  username, level, currentExp, …                  │
│  bất biến, không biết gì về UI                   │
└──────────────────┬──────────────────────────────┘
                   │ truyền xuống qua constructor
┌──────────────────▼──────────────────────────────┐
│  Widgets: _LevelCard, _EarningsCard, _StatsRow  │
│  chỉ ĐỌC profile.xxx để hiển thị                │
└─────────────────────────────────────────────────┘
```

Model không import Flutter, không chứa widget — thuần Dart. Đó là lý do nó
**test được mà không cần chạy app** (bài 4).

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `final T field;` | `final int level;` | Field gán một lần trong ctor, sau đó bất biến |
| Named param + default | `this.level = 1` | Tham số không bắt buộc, mặc định `1` |
| `required` | `required this.username` | Named param bắt buộc — như các widget đã viết |
| `Type?` | `final String? avatarUrl;` | Kiểu **nullable**: chứa được `String` *hoặc* `null` |
| `??` | `name ?? 'Khách'` | "Nếu vế trái là `null` lấy vế phải" — sẽ dùng trong `copyWith` (bài 2) |
| `var` | `var x = 5;` | Biến local suy kiểu (`int`), đổi được — ≈ `var` Kotlin |
| Thư mục lồng | `data/profile/` | File Dart có thể nằm sâu; import theo đường dẫn tương đối |

Về `late`: Dart còn một từ khoá `late` — "field non-nullable nhưng gán giá
trị *sau* khi khai báo". M04 chưa cần; **M05 sẽ dùng thật** khi khởi động
việc tải bất đồng bộ trong `initState`. Giờ chỉ cần nhận ra nó khi đọc code.

## Null safety — đọc chậm, đây là nền tảng

Dart phân biệt **hai loại kiểu**:

| Kiểu | Chứa được | Hậu quả |
|------|-----------|---------|
| `String` | chỉ `String` | Không bao giờ `null` — compiler bảo đảm |
| `String?` | `String` **hoặc `null`** | Compiler bắt bạn xử lý cả hai khả năng |

```dart
String a = 'Khách';     // OK
String b = null;        // LỖI COMPILE — String không nhận null
String? c = null;       // OK — ? cho phép null
String? d = 'An';       // OK — vẫn là String? chứa được String
```

`?` sau tên kiểu **không phải** "toán tử làm gì đó" — nó là *một kiểu khác*:
kiểu "có thể null". Mọi hậu quả đi từ đây:

- Gọi `d.length` khi `d` là `String?` → **lỗi compile**: compiler bắt bạn
  kiểm tra null trước (ví dụ `if (d != null)`, hoặc `d ?? 'Khách'`).
- Truyền `String?` vào chỗ cần `String` → lỗi compile tương tự.
- `x!` ("non-null assertion") **nói với compiler** "tin tôi, chỗ này không
  null" — nếu nói sai thì **crash lúc chạy**. M04 không cần `!`; nếu một
  ngày bạn thấy mình thêm `!` chỉ để hết báo đỏ — dừng lại, đó gần như chắc
  chắn là dấu hiệu thiết kế sai. (Quy tắc ngón tay cái: `!` là *lời hứa với
  compiler*, không phải câu thần chú biến null thành non-null.)

`avatarUrl` là field nullable **thật sự có nghĩa**: người chơi guest chưa có
ảnh đại diện → `null` là giá trị hợp lệ, và header sẽ hiển thị icon mặc định
cho trường hợp đó (bài 3).

## Ví dụ độc lập — `Badge` (pure Dart)

Trước khi viết model thật, cảm nhận "class + named params + default +
nullable" trong một file Dart thuần — chạy được trong DartPad (chế độ
Dart, không cần Flutter):

```dart
class Badge {
  final String title;
  final int tier;
  final String? note;

  const Badge({required this.title, this.tier = 1, this.note});
}

void main() {
  const a = Badge(title: 'Newcomer');
  const b = Badge(title: 'Veteran', tier: 5, note: 'rare');

  print(a.title);          // 'Newcomer'
  print(a.tier);           // 1 — default tự điền
  print(a.note);           // null — nullable không truyền thì null
  print(a.note ?? 'none'); // 'none' — ?? thế chỗ khi null
  print(b.note ?? 'none'); // 'rare'
}
```

Ba quy tắc thấy ngay trong output:

- `required this.title` — thiếu là lỗi compile; `this.tier = 1` — không
  truyền thì nhận default; `this.note` (kiểu `String?`) — không truyền
  thì `null`, không lỗi.
- `print` là `print` Dart thuần — model không cần Flutter để chạy.
  `UserProfileData` bạn sắp viết cũng là class thuần thế này: đó là lý
  do bài 4 test được nó mà không cần pump widget nào.

## Flutter cần dùng

Không có widget mới. Điểm duy nhất chạm Flutter: **cấu trúc thư mục**. Ta
đặt model ở `lib/data/profile/user_profile_data.dart` — đúng đường dẫn của
model cùng tên trong app senior, để khi đối chiếu senior (M14+) bạn thấy
"nhà" của nó quen thuộc.

## Cầu nối Android / Compose

- SIMILARITY: class với `val`/constructor ≈ Kotlin `data class` ở phần "bất
  biến + named params + default values".
- IMPORTANT DIFFERENCE: Kotlin `data class` **tự sinh** `copy`, `equals`,
  `hashCode`, `toString`; Dart class **không sinh gì** — bài 2 ta viết tay
  từng cái và sẽ hiểu chính xác chúng làm gì.
- DO NOT ASSUME: `String?` của Dart = `String?` của Kotlin thì *ý niệm*
  giống, nhưng cơ chế khác: Dart phân tích flow (`if (x != null)` smart-cast
  x thành non-null trong nhánh), và không có safe-call `?.` ở mọi bối cảnh
  như Kotlin? — thực ra Dart **có** `?.`, chỉ là bài này chưa cần; nó sẽ
  xuất hiện đúng lúc.

## Trong project senior

- File: `flutter-accelerator-ai/lib/data/profile/user_profile_data.dart` —
  model thật gồm `username`, `level`, `currentExp`, `totalMoneyWon`,
  `gamesJoined`, `gamesWon`, `avatarUrl` (nullable `String?`!) và vài trường
  khác. Constructor của senior cũng `const` + named params + defaults —
  bạn đang viết đúng kiến trúc đó, chỉ ít field hơn.
- Sự khác biệt cố ý: senior thêm `totalEarnings` (chuỗi hiển thị sẵn),
  `totalQuestionCount`, `fromMap`/`toMap` (để lưu JSON — **M10**), và
  `MenuLevelProgress` tính ngưỡng EXP từ bảng `LevelConfig` (M22). Bản M04
  giữ `expForNextLevel` như một field cho đơn giản — *field này không tồn
  tại trong senior model*: senior suy cap từ `LevelConfig.getExpRequiredForLevel`.
  Đây là simplification đã đăng ký; `expForNextLevel` sẽ bị xoá ở M22.
- **Defaults của learner BẰNG defaults senior** (đã chỉnh từ remediation):
  `username='0XFF'` (`UserProfileData.defaultUsername`), `currentExp=0`.
  `expForNextLevel=35000` là hardcode của `LevelConfig.
  getExpRequiredForLevel(1)` = `30000 + 1×5000` — con số senior thật,
  chỉ là ta chưa có bảng config để tính ra (M22). Không phải fixture bịa.
- `avatarUrl` nullable cũng là senior-parity: senior có field này và UI của
  họ fallback về avatar mặc định khi null — đúng hướng ta sẽ đi.

## Từng bước thực hiện

### Bước 1 — Tạo file model và khai báo field

Tạo `lib/data/profile/user_profile_data.dart` (tạo luôn hai thư mục mới
`data/profile/`):

```dart
// lib/data/profile/user_profile_data.dart
/// Hồ sơ người chơi — model bất biến đầu tiên của course (M04).
///
/// Phiên bản rút gọn của `UserProfileData` trong project senior:
/// chỉ giữ các trường màn hình menu đang hiển thị. `fromMap`/`toMap`
/// sẽ được thêm ở M10 khi có `SharedPreferences`.
class UserProfileData {
  final String username;
  final int level;
  final int currentExp;
  final int expForNextLevel;
  final int totalMoneyWon;
  final int gamesJoined;
  final int gamesWon;
  final String? avatarUrl;
}
```

- FILE: `lib/data/profile/user_profile_data.dart` (mới)
- CHANGE: khai báo 8 field — mỗi field tương ứng một thứ menu đang hiển thị.
- WHY: một chỗ duy nhất định nghĩa "profile gồm những gì".
- WHAT IS NEW: `final` trong class thường (không phải widget) —
  bất biến *dữ liệu*; `String?` — field nullable đầu tiên của course.

Chọn field thế nào? Nhìn menu M03 và liệt kê giá trị nó hiển thị: tên
(`username`), cấp (`level`), `X / Y EXP` (`currentExp`,
`expForNextLevel`), `'0 VNĐ'` (`totalMoneyWon`), ba ô stats (`gamesJoined`,
`gamesWon` — tỉ lệ thắng sẽ *suy ra*, bài 2), và `avatarUrl` cho tương lai.

### Bước 2 — Constructor `const` + named params + defaults

Thêm constructor vào trong class:

```dart
  /// Hồ sơ mặc định — ĐÚNG defaults senior (`defaultUsername='0XFF'`,
  /// counter về 0). `expForNextLevel = 35000` là hardcode của
  /// `LevelConfig.getExpRequiredForLevel(1)` = `30000 + 1×5000` —
  /// tạm thời cho tới M22 khi LevelConfig tính thật và field này bị xoá.
  const UserProfileData({
    this.username = '0XFF',
    this.level = 1,
    this.currentExp = 0,
    this.expForNextLevel = 35000,
    this.totalMoneyWon = 0,
    this.gamesJoined = 0,
    this.gamesWon = 0,
    this.avatarUrl,
  });
```

- WHAT IS NEW: `this.username = '0XFF'` — **named param có default**:
  gọi `UserProfileData()` không truyền gì → nhận hồ sơ khách — cùng
  `'0XFF'` senior dùng, không phải `'Khách'` bịa; muốn khác thì truyền
  đúng tên trường.
- `avatarUrl` không có default và không `required` — vì `String?` **mặc
  định là `null` khi không truyền**. Đây là lần đầu nullable tự phát huy
  tác dụng: "chưa có avatar" là trạng thái hợp lệ.
- `const` constructor → `const UserProfileData()` tạo được **hằng compile-
  time** — Flutter/Dart chỉ tạo đúng một instance cho các const giống hệt
  nhau (sẽ thấy hậu quả đáng ngạc nhiên ở bài 2–4).

### Bước 3 — Kiểm tra compile

```bash
flutter analyze
```

→ `No issues found!` (file mới chưa được dùng — đó là OK; analyzer không bắt
public class phải được import). App vẫn chạy y hệt M03 — ta mới chỉ *thêm*
model, chưa đổi UI. Bài 2 và 3 sẽ nối chúng.

## Đọc hiểu code

Một object model đọc được như "bản ghi":

```dart
const profile = UserProfileData();
// profile.username      → '0XFF'
// profile.level         → 1
// profile.avatarUrl     → null   (kiểu String? cho phép)

const khac = UserProfileData(username: 'Minh', level: 7);
// khac.username → 'Minh'; mọi field còn lại nhận default.
```

Không có gì "chạy" ở đây — `UserProfileData` chỉ là khuôn dữ liệu. Sức mạnh
của nó xuất hiện ở bài 2: khi mọi thứ bất biến, thay đổi trạng thái =
*tạo bản ghi mới*.

## Chạy và quan sát

- `flutter analyze` — xanh, đủ cho bước này.
- Nếu tò mò, tạo thử trong `main()`: `const p = UserProfileData();
  debugPrint(p.username);` → in `0XFF`. Nhớ xoá sau — app demo không cần.

## Lỗi thường gặp

1. **Quên `?` khi field cần null** — `final String avatarUrl;` + không
   `required` → compile error ngay: non-nullable phải được gán. Nhớ:
   muốn "có thể vắng" → `Type?`.
2. **`required` + default cùng lúc** — `required this.username = '0XFF'`
   là vô nghĩa (bắt buộc thì không cần default) — analyzer báo lỗi.
3. **Gán lại field `final`** — `profile.level = 2` → compile error.
   Muốn "level 2" → tạo object mới (bài 2: `copyWith`).
4. **`avatarUrl` không truyền** — nhận `null` tự động, đó là *đúng thiết
   kế*, không phải quên gán.

## Kiểm tra hiểu biết

1. `String` vs `String?` khác nhau gì? — `String?` chứa thêm được `null`;
   compiler bắt xử lý khả năng null trước khi dùng giá trị.
2. Vì sao `avatarUrl` không cần `required` lẫn default? — Vì nullable param
   tự mặc định `null` khi không được truyền.
3. `final` field có đổi được sau constructor không? — Không. Đó là lý do
   model gọi là bất biến; "thay đổi" = tạo object mới.
4. Model có import được `material.dart` không? — Được về mặt kỹ thuật nhưng
   **không nên**: model thuần Dart thì test pure-Dart được và không lệ thuộc
   UI. Senior giữ `lib/data/` sạch Flutter-UI cũng vì vậy.

## Tự làm (PRODUCE)

Thiết kế một model mới — `MatchTicket` — hoàn toàn trong DartPad (pure
Dart, không đụng project). Bốn field:

- `code` — mã vé, **bắt buộc** và không bao giờ null;
- `seat` — số ghế: vé đứng chưa có ghế → giá trị này **có thể vắng**;
- `price` — giá vé: vé free có `price = 0`, người mua **không bắt buộc**
  truyền;
- `eventName` — tên sự kiện, **bắt buộc**.

Trước khi viết, quyết cho từng field: `required` hay không? Kiểu `T` hay
`T?`? Có default không — và default gì? Sau đó viết class + `main()` tạo
hai instance hợp lệ (vé free đứng; vé trả phí có ghế) và in ra.

Cuối cùng, dự đoán rồi kiểm: tạo `MatchTicket(eventName: 'Final')`
thiếu `code` — compile hay chạy lỗi, lỗi gì?

:::note[Gợi ý]
Nhìn lại ba cách `Badge`/`UserProfileData` khai báo param: `required
this.x`, `this.x = default`, `this.x` (nullable → tự `null`). Mỗi field
của `MatchTicket` thuộc đúng một trong ba nhóm đó — `seat` giống
`avatarUrl` ở chỗ nào?
:::

<details><summary>Đáp án</summary>

```dart
class MatchTicket {
  final String code;      // required: không có code thì không có vé
  final String? seat;     // nullable: "chưa xếp ghế" là trạng thái hợp lệ
  final int price;        // default 0: free là trường hợp phổ biến
  final String eventName; // required

  const MatchTicket({
    required this.code,
    this.seat,
    this.price = 0,
    required this.eventName,
  });
}

void main() {
  const a = MatchTicket(code: 'F-001', eventName: 'Final');
  // a.seat == null, a.price == 0 — vé free đứng, hợp lệ
  const b = MatchTicket(
      code: 'F-002', seat: 'A12', price: 500, eventName: 'Final');
  print('${a.code}/${a.seat ?? "standing"}'); // F-001/standing
}
```

- `MatchTicket(eventName: 'Final')` thiếu `code` → **lỗi compile**
  ("required named parameter 'code' must be provided") — compiler bắt
  ngay khi gõ, không đợi chạy. Đây chính là giá trị của `required`: bắt
  buộc tại chỗ gọi, không phải kiểm tra tay.
- Quyết định thật nằm ở `seat` và `price`: `seat` là `String?` **không
  required, không default** vì "vắng" có nghĩa (giống `avatarUrl`);
  `price` là non-nullable với `= 0` vì "miễn phí" là giá trị cụ thể chứ
  không phải "chưa biết". Hai khái niệm — *có-thể-vắng* vs *có-default* —
  là sự khác biệt ngữ nghĩa thật của bài này.

</details>

## Cố ý chưa làm

- `copyWith`, `==`, `hashCode` — bài 2 (một mình đáng một bài).
- Nối model vào widget — bài 3.
- `fromMap`/`toMap` (đọc/ghi JSON) — M10, khi có `SharedPreferences`.
- `expForNextLevel` tính từ bảng cấp — senior dùng `LevelConfig`; ta giữ
  field đơn giản đến M22.
- `late`, `!`, `?.` — sẽ dùng ở M05+ khi có lý do thật.

## Điểm kiểm tra hoàn thành

- [ ] `lib/data/profile/user_profile_data.dart` tồn tại với 8 field `final`
      và constructor `const` có defaults.
- [ ] `avatarUrl` là `String?` — bạn giải thích được vì sao nó nullable.
- [ ] `flutter analyze` → `No issues found!`.
- [ ] Bạn nói được câu: "`!` là lời hứa với compiler, không phải phép biến
      null thành non-null".
