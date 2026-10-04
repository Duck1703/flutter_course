---
title: "Bài 2 · JSON & parse phòng thủ"
description: "dart:convert jsonEncode/jsonDecode, Map<String, Object?>, toMap một chiều và fromMap phòng thủ với is int/is String + FormatException."
sidebar:
  label: "Bài 2 · JSON & fromMap"
  order: 2
---

## Mục tiêu

Cho `UserProfileData` biết tự biến thành JSON và trở lại — với quy
tắc bất biến của course: **dữ liệu từ disk không bao giờ được tin**,
mọi field parse phòng thủ, hỏng thì về mặc định.

## Bạn đang ở đâu

- Milestone: **M10** (bài 2/4)
- App hiện tại: `ProfileStore` (bài 1) gọi `profile.toMap()` và
  `UserProfileData.fromMap(map)` — hai hàm chưa tồn tại.

## Vì sao việc này quan trọng ngay bây giờ

`SharedPreferences` chỉ lưu được String/int/bool… — không lưu được
object Dart. Muốn persist `UserProfileData` ta phải đi qua một dạng
trung gian: **Map → chuỗi JSON**. Đây là pattern serialization tay
đầu tiên của course; senior dùng đúng pattern này (chưa dùng codegen
`json_serializable` — đó là lựa chọn của project senior, ta theo).

Chiều "đọc về" là nơi mọi bug persistence trú ngụ: file do version cũ
ghi, field đổi kiểu sau update, tester chỉnh tay… `fromMap` phòng thủ
biến "crash khi mở app" thành "hồ sơ về mặc định".

## Bạn đã biết gì

- `Map` literal `{}`, `Map<K,V>` (M04), `String?`/null safety (M04).
- `is` type-check (M08 trong `_optionState` style guards),
  `try`/`on`/`catch` (M05).
- `factory` constructor — **lần đầu trong course**, dạy ngay dưới trước
  khi dùng trong `fromMap`.

## Mental model mới

```
UserProfileData ──toMap()──► Map<String, Object?> ──jsonEncode──► "{"level":3,...}"
                                                                   │  (ghi prefs)
UserProfileData ◄─fromMap()── Map<String, Object?> ◄─jsonDecode── "{"level":3,...}"
                                                                   │  (đọc prefs)
```

- `toMap` **dễ**: bạn kiểm soát model — chỉ cần liệt kê key → field.
- `fromMap` **khó**: map đến từ `jsonDecode` là `Map<dynamic, dynamic>`
  với value `Object?` bất định — compile không bảo vệ gì. Guard từng
  field: `is int`/`is String` rồi mới `as`/dùng; không qua guard thì
  `fallback` về default.
- `jsonDecode` trả `dynamic`: chuỗi `'123'` decode thành `int 123`,
  `'[1,2]'` thành `List` — chỉ có `is Map` mới đi tiếp được.

## Ví dụ độc lập — vòng đời JSON trong DartPad

`dart:convert` là pure Dart — chạy thử toàn bộ vòng serialize/deserialize
trước khi đụng model thật:

```dart
import 'dart:convert';

void main() {
  const player = {'name': 'An', 'score': 120, 'vip': false};

  final encoded = jsonEncode(player);
  print(encoded);            // {"name":"An","score":120,"vip":false}
  print(encoded.runtimeType); // String — đây là thứ ghi vào prefs

  final decoded = jsonDecode(encoded);
  print(decoded.runtimeType); // _Map<String, dynamic> / Map<dynamic, dynamic>
  print(decoded['score']);   // 120
  print(decoded['score'].runtimeType); // int — kiểu JSON bảo toàn được

  // Bẫy 1: value là dynamic — ép sai kiểu ném lỗi LÚC CHẠY:
  // decoded['name'] as int; // → TypeError
  print(decoded['name'] is int); // false — guard trước khi dùng

  // Bẫy 2: chuỗi không phải JSON:
  // jsonDecode('not json'); // → FormatException
}
```

Ba quan sát là nửa bài này:

- `jsonEncode` nhận Map/List/num/String/bool/null — **không** nhận
  `UserProfileData`: đó là lý do `toMap()` tồn tại (model → kiểu JSON
  hiểu được).
- `jsonDecode` trả `dynamic`: kiểu của từng value chỉ biết lúc chạy →
  `is int` guard trong `fromMap` không phải sếu, nó là phòng thủ bắt
  buộc khi dữ liệu đến từ ngoài (file, mạng, phiên bản app cũ).
- `FormatException` là lỗi riêng cho chuỗi JSON hỏng — `on FormatException`
  bắt đúng nó mà không nuốt lỗi khác.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `jsonEncode` | `jsonEncode(profile.toMap())` | `dart:convert`; Map/List/num/String/bool/null → chuỗi JSON |
| `jsonDecode` | `jsonDecode(encoded)` | Chuỗi → `dynamic` (Map/List/num/String/bool/null); ném `FormatException` khi hỏng |
| `Map<String, Object?>` | `Map<String, Object?>.from(decoded)` | Ép Map dynamic về key-String — chữ ký chuẩn của fromMap |
| `is int` guard | `value is int ? value : fallback` | Kiểm kiểu runtime — khác `as` (ném khi sai), `is` trả bool |
| `on FormatException` | `try { jsonDecode(s) } on FormatException {}` | Bắt đúng một loại lỗi — JSON hỏng |
| `const defaults = UserProfileData()` | `const defaults = UserProfileData();` | Tận dụng ctor const làm "nguồn default" duy nhất |

## Dart mới: `factory` constructor

Bài này có một từ khoá Dart **chưa từng xuất hiện** trong course — `factory`.
Đọc kỹ trước khi gõ code, vì nó khác constructor bạn đã viết từ M02–M09.

Constructor thường (generative) mà ta đã dùng:

```dart
class Point {
  Point(this.x, this.y);
  final int x;
  final int y;
}
```

Nó **luôn tạo một instance mới** và body nó (nếu có) chỉ chạy *sau khi* field
đã gán — không có chỗ để "tính rồi mới quyết định giá trị field", và không
thể `return` một object đã có sẵn.

`factory` là constructor **trả về** một instance thay vì tự build:

```dart
class Point {
  Point._(this.x, this.y);
  final int x;
  final int y;

  /// Factory: được chạy logic trước, rồi `return` instance bất kỳ —
  /// ở đây là instance dựng tay từ ctor private `._`.
  factory Point.fromList(List<int> xy) {
    if (xy.length != 2) return Point._(0, 0);   // fallback — ctor thường không làm được
    return Point._(xy[0], xy[1]);
  }
}
```

Đọc kỹ:

- `factory Point.fromList(...)` — khai báo một *named constructor* trả
  `Point`; body là hàm thường, **phải `return` một `Point`**.
- Bên trong được tính toán, guard, throw — khác ctor thường chỉ có
  initializer list `: field = value`.
- Factory có thể trả **instance đã có sẵn** (cache/singleton) — ctor thường
  không bao giờ làm được. Đây là nguồn sức mạnh của `factory`.
- `Point._(this.x, this.y)` — ctor **private** (`_` M03): chỉ trong file
  này gọi được — factory trở thành cổng duy nhất vào.
- **Khi nào KHÔNG nên dùng:** khi chỉ cần gán field thẳng — ctor thường
  (hoặc named ctor `Point.zero()`) rõ ràng hơn; `factory` làm người đọc
  phải đoán "có cache/logic gì không?" — chỉ dùng khi cần quyền `return`
  hoặc logic trước construction.

Với Kotlin dev: `factory` ≈ companion `fun fromList(...): Point` — hàm tạo
trả instance. **Khác quan trọng:** ở Dart nó vẫn là *constructor* theo cú
pháp gọi `Point.fromList(map)` — caller không phân biệt được nó là factory
hay ctor thường. Senior dùng `factory …fromMap` đúng pattern này.

## Flutter cần dùng

Không có widget mới — bài này thuần `dart:convert` + model.

## Android / Compose bridge

- SIMILARITY: giống hệt `JSONObject`/`Gson` thủ công: `toMap` ≈
  `toJson`, `fromMap` ≈ `fromJson`, guard `is int` ≈ `optInt` trả
  default. Kotlin/Compose dev quen Moshi/Retrofit sẽ nhận ra — đây là
  bản "không codegen".
- IMPORTANT DIFFERENCE: Dart không có `optInt` sẵn — `map['level']`
  trả `Object?` và **cast sai (`as int` trên `'ba'`) sẽ ném**. Phải tự
  viết `_intValue(value, fallback)` — senior cũng tự viết helper y hệt.
- DO NOT ASSUME: JSON giữ kiểu như bạn ghi. `jsonDecode('1.5')` cho
  `double`, `jsonDecode` của map luôn là `Map<dynamic, dynamic>` —
  kiểu an toàn chỉ đến từ guard của bạn.

## Senior project connection

- `flutter-accelerator-ai/lib/data/profile/user_profile_data.dart` —
  `toMap`/`fromMap` với helper `_intValue(map['x'], fallback)` và
  `defaults` — code learner dưới đây là cùng một hình dạng, gọn hơn
  vì bỏ các field senior-only (`totalEarnings` chuỗi, legacy-demo
  reset, `totalQuestionCount`).
- `flutter-accelerator-ai/lib/repositories/settings/user_settings_repository.dart` —
  cùng pattern `getString → jsonDecode → is Map → fromMap` cho một
  model khác: xác nhận đây là convention của project, không phải
  one-off.

## Build it step by step

### Bước 1 — `toMap` trên model

```dart
// lib/data/profile/user_profile_data.dart — trong class, THÊM:
/// Serialize profile thành `Map` — bước giữa trước khi `jsonEncode`.
///
/// `jsonEncode` chỉ hiểu `Map<String, Object?>` với value thuộc
/// String/num/bool/null/List/Map — mọi trường của ta đều thuộc nhóm
/// đó nên `toMap` chỉ là "liệt kê key → field".
Map<String, Object?> toMap() {
  return <String, Object?>{
    'username': username,
    'level': level,
    'currentExp': currentExp,
    'expForNextLevel': expForNextLevel,
    'totalMoneyWon': totalMoneyWon,
    'gamesJoined': gamesJoined,
    'gamesWon': gamesWon,
    'avatarUrl': avatarUrl,
  };
}
```

- `avatarUrl` là `String?` — `null` encode thành JSON `null`, hợp lệ.
- Tên key snake-case đơn từ, khớp tên field — convention senior giữ
  nguyên tên field làm key, đỡ map mental.

### Bước 2 — `fromMap` phòng thủ + helper

```dart
// cùng file, THÊM:
/// Deserialize từ `Map` — parse PHÒNG THỦ: storage có thể chứa
/// dữ liệu cũ, thiếu trường, hoặc sai kiểu. Field nào không tin được
/// thì rơi về giá trị mặc định — profile hỏng vẫn cho app chạy.
factory UserProfileData.fromMap(Map<String, Object?> map) {
  const defaults = UserProfileData();
  return UserProfileData(
    username: _stringValue(map['username'], defaults.username),
    level: _intValue(map['level'], defaults.level),
    currentExp: _intValue(map['currentExp'], defaults.currentExp),
    expForNextLevel:
        _intValue(map['expForNextLevel'], defaults.expForNextLevel),
    totalMoneyWon: _intValue(map['totalMoneyWon'], defaults.totalMoneyWon),
    gamesJoined: _intValue(map['gamesJoined'], defaults.gamesJoined),
    gamesWon: _intValue(map['gamesWon'], defaults.gamesWon),
    // Field nullable: chỉ nhận khi đúng String — còn lại về null.
    avatarUrl: map['avatarUrl'] is String ? map['avatarUrl'] as String : null,
  );
}

/// Đọc `int` phòng thủ: `is int` bảo đảm đúng kiểu (jsonDecode ném
/// số thực `double` nếu file chứa `1.5` — ta bỏ qua thay vì ép sai).
static int _intValue(Object? value, int fallback) =>
    value is int ? value : fallback;

/// Đọc `String` phòng thủ — cùng ý tưởng [_intValue].
static String _stringValue(Object? value, String fallback) =>
    value is String ? value : fallback;
```

- `const defaults = UserProfileData()` — một object const làm nguồn
  fallback; nếu mai đổi default ở ctor, `fromMap` tự theo.
- `_intValue` private-static: đúng phạm vi "helper của class".

### Bước 3 — Nối vào `ProfileStore` (đã có sẵn từ bài 1)

`profile_store.dart` bài 1 đã viết sẵn `jsonEncode(profile.toMap())`
và `UserProfileData.fromMap(...)` — giờ biên dịch được.
`Map<String, Object?>.from(decoded)` ở đó làm việc "kiểm kiểu lười":
nếu một key không phải String nó ném — nhưng JSON object decode luôn
cho key String nên đây chỉ là ép cho đúng chữ ký.

## Hiểu code

- **`fromMap` là `factory` chứ không phải constructor thường?** Factory
  cho phép tính toán/validate trước khi gọi ctor thật (`const defaults`,
  guard từng field). Constructor thường phải "gọi `: this(...)` ngay" —
  không có chỗ cho logic parse.
- **Vì sao fallback của `avatarUrl` là `null` chứ không `defaults.avatarUrl`?**
  Giống nhau (defaults là null) — viết `null` tường minh để nhấn "field
  nullable → vắng là bình thường, không phải lỗi".
- **`is int` loại `double` — đúng ý đồ.** `{"level": 2.5}` decode ra
  `2.5` (double) — `2.5 is int` = false → về default. Nếu dùng
  `as int` thì crash; dùng `(value as num).toInt()` thì *chấp nhận*
  2.5 → 2 — ta chọn từ chối như senior.

## Chạy và quan sát

- `flutter analyze` — sạch; `flutter test` — nhóm test mới xanh:
  round-trip, thiếu field, sai kiểu, double-bị-loại.
- App chưa thấy khác gì vì `ProfileStore` chưa nối vào menu — bài 4.

## Lỗi hay gặp

1. **`jsonDecode` bỏ trong `try` vô tận (`catch (e)`)** — nuốt luôn
   lỗi logic. `on FormatException` chỉ bắt đúng lỗi JSON; lỗi khác vẫn
   nổ để debug được.
2. **`Map<String, Object?>.from(decoded)` viết thành cast
   `decoded as Map<String, Object?>`** — cast ném khi `decoded` là
   `_Map<dynamic, dynamic>`? Không — thực ra cast được vì
   `Map<dynamic,dynamic>` thoả `Map<String,Object?>`… *chỉ khi* mọi
   key thật sự là String; với JSON decode luôn đúng, nhưng `.from`
   an toàn và rõ ý đồ hơn (copy + kiểm). Đừng cast khi có thể `.from`.
3. **`fromMap` tin `map['level']` là int vì "mình tự ghi mà"** — phiên
   bản app cũ/tester có thể ghi khác; storage không có compiler gác cổng.
4. **Quên import `dart:convert`** — `jsonEncode`/`jsonDecode` sống ở
   `dart:convert`, không phải core.

## Kiểm tra hiểu biết

1. `is int` vs `as int` khác nhau thế nào khi value là `'ba'`? —
   *`is` trả `false` (cho nhánh fallback); `as` ném `TypeError` ngay.*
2. Vì sao `toMap` không cần guard còn `fromMap` cần? — *`toMap` đọc
   field đã được compiler kiểm kiểu; `fromMap` đọc `Object?` từ runtime
   — nơi không có kiểm soát compile-time.*
3. Field mới `totalSessions` được thêm vào model sau này, app cũ đã
   ghi JSON không có key đó — `fromMap` xử lý sao? — *`map['totalSessions']`
   trả null → `is int` false → fallback default. Đây chính là lý do
   parse phòng thủ = forward-compatible.*

## Tự làm (DEBUG)

Storage trả về dữ liệu hỏng (phiên bản app cũ ghi sai, hoặc user sửa
file). Dự đoán kết quả của `fromMap` — **không crash** là yêu cầu, nhưng
field nào rơi về default?

**Phần 1.** Map này đi qua các guard `is int`/`is String` → fallback:

```dart
{
  'username': 42,          // int thay vì String!
  'level': '3',            // String thay vì int!
  'currentExp': 250.0,     // double thay vì int
  'avatarUrl': null,       // null — field này có sao không?
  'gamesJoined': 4,        // đúng kiểu
}
```

Với từng key: dự đoán field của `UserProfileData` nhận giá trị map hay
default. Đặc biệt: `avatarUrl` — `null` có bị guard từ chối không?

**Phần 2.** Ba chuỗi đi vào `jsonDecode` — dự đoán mỗi cái ra gì và
`fromMap` có được gọi không:

```dart
jsonDecode('123');     // ?
jsonDecode('');        // ?
jsonDecode('{}');      // ?
```

:::note[Gợi ý]
`is` kiểm kiểu **chặt**: `'3' is int` → false (String ≠ int), `250.0 is
int` → false (double ≠ int — Dart phân biệt!). `jsonDecode` trả
`dynamic`: số JSON trần decode thành `int`, không phải Map. `avatarUrl`
là `String?` — guard của nó phải *cho phép* null.
:::

<details><summary>Đáp án</summary>

**Phần 1** — từng field:

- `username: 42` → `is String` **fail** → fallback `'0XFF'` (default).
- `level: '3'` → `is int` **fail** → `1` — chuỗi số không được "ngầm
  ép" (Dart không JS-coerce).
- `currentExp: 250.0` → `is int` **fail** → `0` — `250.0` là `double`;
  JSON `250.0` decode thành double. (Đây là bẫy thật khi migrate.)
- `avatarUrl: null` → **hợp lệ** — guard cho field nullable phải là
  `value is String ? value : null` (hoặc tương đương cho-phép-null);
  `null` là giá trị đúng của `String?`, không phải dữ liệu hỏng.
- `gamesJoined: 4` → `4`.

Kết quả: một profile "còn sống" với gamesJoined giữ được, phần còn lại
về default — đúng triết lý defensive parsing: hỏng một field ≠ mất
toàn bộ profile.

**Phần 2:**

- `'123'` → decode thành `int 123` — không phải Map → check `is Map`
  fail → dùng defaults (fromMap không được gọi).
- `''` → **`FormatException`** — chuỗi rỗng không phải JSON →
  `on FormatException` → defaults.
- `'{}'` → `Map` rỗng → fromMap chạy, mọi field vắng → toàn defaults.

Ba trường hợp tổng hợp đúng ba tuyến phòng thủ: sai kiểu-value → guard
field; không-phải-Map → guard `is Map`; không-phải-JSON →
`on FormatException`.

</details>

## Ta cố ý chưa thêm

- `json_serializable`/codegen — senior không dùng; M10 dạy pattern tay
  để bạn nắm bản chất trước.
- `int.tryParse` đọc số-hoá-thành-chuỗi — senior cần nó cho field
  `totalEarnings` dạng chuỗi (`_moneyFromDisplay`); model learner lưu
  thuần int nên chưa cần.
- Schema version/migration — M16+ mới có đủ key để cần lo.

## Checkpoint hoàn thành

- [ ] `UserProfileData` có `toMap` + `fromMap` + `_intValue`/`_stringValue`.
- [ ] `ProfileStore` biên dịch được (không còn lỗi `toMap`/`fromMap`).
- [ ] Test: `fromMap(toMap(p)) == p`; map rỗng → default; `level: 'ba'`
  → level 1; `level: 2.5` → level 1.
