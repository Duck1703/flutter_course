---
title: "Bài 2 · Immutability: copyWith, ==, hashCode"
description: "Cập nhật bất biến qua copyWith và gainExp, value equality với operator ==, hashCode bằng Object.hash, và các getter suy ra."
sidebar:
  label: "Bài 2 · copyWith & equality"
  order: 2
---

## Mục tiêu

Hoàn thiện `UserProfileData` với bộ ba cốt lõi của mọi model Dart:
**`copyWith`** (cập nhật bất biến), **`==`/`hashCode`** (so sánh theo giá
trị), cùng các **getter suy ra** (`expPercent`, `winRateDisplay`,
`totalEarningsDisplay`, `formatThousands`) và hành vi thật đầu tiên:
`gainExp`.

## Bạn đang ở đâu

- Milestone: **M04 — Model bất biến & unit test đầu tiên** (bài 2/4)
- App hiện tại: có `UserProfileData` với 8 field `final` + constructor —
  nhưng chưa "làm" được gì ngoài chứa dữ liệu.

## Vì sao việc này quan trọng ngay bây giờ

Field `final` khiến object không sửa được — tốt cho dự đoán, nhưng profile
*phải* đổi (EXP tăng, lên cấp). Câu trả lời của Dart không phải "bỏ final"
mà là **tạo object mới từ object cũ**. Đây là pattern sẽ đi theo bạn đến tận
state management (M11+) và repository (M14): mọi "state mới" đều là một
instance mới.

Và `==`: không có nó, hai `UserProfileData` cùng giá trị vẫn "khác nhau"
— bài 4 sẽ thấy vì sao điều đó phá test.

## Bạn đã biết gì

- Class, `final` field, `const` ctor + named params + defaults (bài 1).
- `String?`/`??` concept (bài 1), ternary, nội suy `${}`.

## Mental model mới

**Immutable update = object mới.** Không sửa `profile.level = 2` (compile
chặn luôn) mà viết:

```
profile (level 1) ──gainExp(300)──▶ object MỚI (level 2, exp 20)
      │                                    │
      └─ vẫn nguyên vẹn ◀── ai đang giữ ───┘
         vẫn thấy giá trị cũ
```

Ba quy tắc đi kèm:

1. **Thay biến, không sửa object:** `_profile = _profile.gainExp(10)` —
   gán field sang instance mới (bài 3 setState với nó).
2. **`==` phải so giá trị:** hai object khác chỗ ngồi trong bộ nhớ nhưng
   cùng dữ liệu phải `==` nhau — cần `operator ==` tự viết.
3. **`hashCode` đi đôi `==`:** nếu `a == b` thì `a.hashCode == b.hashCode`
   BẮT BUỘC — nếu không, `Set`/`Map`/`identical`-cache của Dart sẽ tìm sai
   chỗ và "mất" object đang có. (Quy tắc này giống hệt Kotlin `equals`/
   `hashCode` contract.)

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| Getter | `int get expPercent { … }` | Property tính-toán: gọi như field, chạy như hàm |
| Getter `=>` | `String get x => '…';` | Getter một biểu thức |
| `x ?? y` | `level ?? this.level` | "trái null → lấy phải" — lần đầu dùng thật |
| `~/` | `a ~/ b` | Chia lấy nguyên (`350 * 100 ~/ 400` = 87) — ≈ `/` của `Int` Kotlin |
| `while` | `while (exp >= cap) { … }` | Vòng lặp điều kiện — giống Kotlin |
| `var` | `var exp = currentExp + amount;` | Biến local đổi được (suy kiểu `int`) |
| `identical(a, b)` | trong `==` | So *cùng một instance* trong bộ nhớ |
| `operator ==` | `bool operator ==(Object other)` | Nạp chồng `==` — Dart gọi nó khi viết `a == b` |
| `Object.hash` | `Object.hash(a, b, …)` | Trộn nhiều field thành một hashCode |
| `static` | `static String formatThousands(int v)` | Hàm của *class*, gọi `UserProfileData.formatThousands(…)` — không cần instance |
| `StringBuffer` | `buffer.write('…')` | Ghép chuỗi hiệu quả trong vòng lặp |

## Flutter cần dùng

Không có API Flutter mới — toàn bộ bài này là **pure Dart**. Đó là điểm
quý: `lib/data/` không import `material.dart` nên file này test được bằng
`flutter test` ở tốc độ máy tính, không cần render.

## Cầu nối Android / Compose

- SIMILARITY: `copyWith` ≈ `data class`'s `copy`; `==`/`hashCode` ≈
  `equals`/`hashCode`; `StringBuffer` ≈ `StringBuilder`.
- IMPORTANT DIFFERENCE: Kotlin sinh `copy`/`equals`/`hashCode`/`toString`
  **miễn phí**; Dart bắt viết tay — và đây là *điểm mạnh cho việc học*: một
  lần viết, bạn hiểu chính xác từng dòng Kotlin giấu đi.
- DO NOT ASSUME: `copyWith(x: null)` set field về null — **không được**;
  `null` nghĩa là "giữ nguyên" (xem lỗi thường gặp số 3).

## Trong project senior

- `flutter-accelerator-ai/lib/data/profile/user_profile_data.dart` — senior
  viết tay y hệt bộ ba này: `copyWith` dùng `??`, `operator ==` so từng
  field với `identical` mở đầu, `hashCode` dùng `Object.hash(...)`, và có
  `formatVnd`/`formatThousands` static helpers. Bản học viên của bạn theo
  đúng công thức đó — chỉ ít field hơn.
- `flutter-accelerator-ai/lib/repositories/profile/user_profile_repository.dart`
  — `_emitUserProfile` so sánh `_userProfileSubject.value != userData`
  trước khi emit. **Nhờ `==` bạn viết**, repository senior biết "profile
  không đổi" và bỏ qua emit thừa — đây là lý do value equality không phải
  trang trí.

## Từng bước thực hiện

### Bước 1 — `copyWith` (cập nhật bất biến)

Trong `UserProfileData`, sau constructor:

```dart
  /// Tạo bản sao với một vài trường thay đổi — "immutable update".
  ///
  /// Tham số nullable: không truyền (`null`) nghĩa là giữ nguyên giá trị cũ.
  UserProfileData copyWith({
    String? username,
    int? level,
    int? currentExp,
    int? expForNextLevel,
    int? totalMoneyWon,
    int? gamesJoined,
    int? gamesWon,
    String? avatarUrl,
  }) {
    return UserProfileData(
      username: username ?? this.username,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      expForNextLevel: expForNextLevel ?? this.expForNextLevel,
      totalMoneyWon: totalMoneyWon ?? this.totalMoneyWon,
      gamesJoined: gamesJoined ?? this.gamesJoined,
      gamesWon: gamesWon ?? this.gamesWon,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
```

- WHAT IS NEW: toàn bộ params là **nullable** (`String?`, `int?`…). Đây là
  lúc `??` phát huy: `username ?? this.username` đọc là *"tham số truyền vào
  không phải null thì dùng nó; còn null (không truyền) thì giữ field cũ"*.
- `copyWith` không phải magic của Dart — chỉ là method thường trả `UserProfileData`
  mới. Convention tên này toàn hệ sinh thái Flutter dùng (từ `ThemeData` đến
  mọi state class của senior).
- Giới hạn đáng biết: `copyWith(avatarUrl: null)` **không xoá** được
  avatar — `null` bị hiểu là "không truyền". Senior chấp nhận hạn chế này;
  cách vượt qua (wrapper/`clearX` flags) là chủ đề nâng cao, cố ý không làm
  ở M04.

### Bước 2 — `gainExp` (hành vi thật đầu tiên)

```dart
  /// Cộng EXP và lên cấp khi tràn — trả về profile MỚI.
  ///
  /// TEMPORARY: mỗi lần lên cấp, ngưỡng EXP tăng 1.5 lần
  /// (35000 → 52500 → …). Senior dùng `LevelConfig` với hệ số milestone —
  /// curve thật là M22.
  UserProfileData gainExp(int amount) {
    var exp = currentExp + amount;
    var nextLevel = level;
    var nextCap = expForNextLevel;
    while (exp >= nextCap) {
      exp -= nextCap;
      nextLevel++;
      nextCap = (nextCap * 1.5).round();
    }
    return copyWith(
      currentExp: exp,
      level: nextLevel,
      expForNextLevel: nextCap,
    );
  }
```

- `var` = biến local **đổi được** (suy kiểu từ giá trị gán). Trong một hàm
  thuần, `var` là chuyện bình thường — "bất biến" ở đây nói về *object*,
  không cấm biến local.
- `while` chạy đến khi EXP còn lại nhỏ hơn ngưỡng. Với defaults senior
  (cap 35000) `gainExp(300)` chỉ cộng EXP chứ chưa lên cấp; để *nhìn thấy*
  lên cấp trong demo/test, truyền cap nhỏ tường minh:
  `UserProfileData(currentExp: 380, expForNextLevel: 400)` → `gainExp(300)`:
  380 + 300 = 680 → trừ 400, lên cấp 2, ngưỡng mới `(400 * 1.5).round() =
  600`, còn dư 280 EXP.
- `(nextCap * 1.5).round()` — `int * double` ra `double`, `.round()` ép về
  `int` gần nhất.
- Method **trả object mới**, không chạm `this` — đó là "immutable update"
  bằng hành vi, không chỉ khẩu hiệu.

### Bước 3 — Ba getter suy ra + `formatThousands`

```dart
  /// Phần trăm tiến trình EXP, kẹp trong 1–99 để dùng làm `flex`
  /// của `Expanded` (Expanded yêu cầu flex > 0).
  int get expPercent {
    final percent = currentExp * 100 ~/ expForNextLevel;
    if (percent < 1) return 1;
    if (percent > 99) return 99;
    return percent;
  }

  /// Tỉ lệ thắng dạng chuỗi — '—' khi chưa chơi ván nào.
  String get winRateDisplay {
    if (gamesJoined == 0) return '—';
    return '${(gamesWon * 100 / gamesJoined).round()}%';
  }

  /// Tổng tiền thưởng đã format — ví dụ '150.000 VNĐ'.
  String get totalEarningsDisplay => '${formatThousands(totalMoneyWon)} VNĐ';

  /// Nhóm chữ số theo 3, phân cách bằng dấu chấm: 1000000 → '1.000.000'.
  static String formatThousands(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i;
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    return (value < 0 ? '-' : '') + buffer.toString();
  }
```

- `expPercent` trả **1–99** chứ không 0–100: vì `Expanded(flex:)` yêu cầu
  `flex > 0`, và EXP = ngưỡng nghĩa là sắp lên cấp chứ không phải "đầy mãi".
  Đây là một *derived value* — UI không tự tính, nó hỏi model.
- `~/` là chia lấy nguyên: `350 * 100 ~/ 400` = `35000 ~/ 400` = `87`.
- `winRateDisplay` che `gamesJoined == 0` (chia-cho-0 của `int` trong Dart
  ném lỗi) bằng `'—'` — đúng chữ menu đang hiển thị.
- `formatThousands` là `static`: gọi `UserProfileData.formatThousands(…)`
  không cần profile nào. Thuật toán: duyệt từng chữ số; khi số chữ số *còn
  lại* chia 3 dư 1 (và còn > 1 số phía sau) thì chấm một dấu `.`.
- `StringBuffer` — khi ghép chuỗi trong vòng lặp, `+` nối tạo string mới mỗi
  vòng; buffer ghi vào bộ đệm rồi `toString()` một lần. (Ở 6 chữ số khác
  biệt không đáng kể — nhưng thói quen đúng từ đầu.)

### Bước 4 — `==` và `hashCode`

```dart
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserProfileData &&
            other.username == username &&
            other.level == level &&
            other.currentExp == currentExp &&
            other.expForNextLevel == expForNextLevel &&
            other.totalMoneyWon == totalMoneyWon &&
            other.gamesJoined == gamesJoined &&
            other.gamesWon == gamesWon &&
            other.avatarUrl == avatarUrl);
  }

  @override
  int get hashCode => Object.hash(
        username,
        level,
        currentExp,
        expForNextLevel,
        totalMoneyWon,
        gamesJoined,
        gamesWon,
        avatarUrl,
      );
```

Đọc kỹ từng dòng của `==`:

- `identical(this, other)` — nếu hai bên **cùng một instance** thì đúng
  ngay, khỏi so field (đường tắt hiệu năng + xử lý `a == a`).
- `other is UserProfileData` — `is` vừa kiểm kiểu vừa **smart-cast**: trong
  nhánh này `other` được xem là `UserProfileData` nên đọc `.username` được.
  So với kiểu khác (`profile == 'abc'`) → `false`, không crash.
- So từng field — `avatarUrl` so bằng `==` của `String?`: hai `null` vẫn
  "bằng nhau".
- `||` + ngoặc: đúng khi *hoặc* cùng instance *hoặc* mọi field khớp.

`hashCode`: `Object.hash(...)` trộn tất cả field thành một `int`. Bắt buộc
đi đôi `==` — hai object `==` nhau mà hashCode khác nhau sẽ phá `Set`/`Map`
(chúng dùng hashCode để *tìm* object trước, `==` để *khẳng định*).

`flutter analyze` → sạch. Model hoàn chỉnh.

## Đọc hiểu code

```dart
const a = UserProfileData();
const b = UserProfileData();
a == b            // true — cùng giá trị, và thật ra cùng một instance
identical(a, b)   // true — const canonicalization: const giống hệt nhau
                  //        được Dart tạo đúng MỘT lần

final c = a.copyWith(level: 5);
c.level        // 5
c.currentExp   // 0 — giữ nguyên vì không truyền
a.level        // 1  — a không hề đổi

a.gainExp(300).level   // 1 — cap mặc định 35000, chưa tràn
a.copyWith(expForNextLevel: 400).gainExp(500).level
// 2 — truyền cap nhỏ tường minh để thấy `while` lên cấp
```

## Chạy và quan sát

- `flutter analyze` → sạch là đủ cho bài này.
- Muốn xem nhanh: thêm tạm vào `initState` của `_MenuScreenState`:
  `debugPrint(const UserProfileData(expForNextLevel: 400)
      .gainExp(500).level.toString());` → in `2` (cap mặc định 35000 quá
  xa để demo). Xoá sau khi thử — bài 3 sẽ nối vào UI thật.

## Lỗi thường gặp

1. **`copyWith(x: null)` muốn xoá giá trị** — `null` = "không truyền",
   field giữ nguyên. Đây là hạn chế có tên của pattern; senior chấp nhận nó.
2. **Override `==` mà quên `hashCode`** — hai object "bằng nhau" nhưng `Set`
   coi là khác → hành vi kỳ lạ khó bắt. Luôn viết cả đôi.
3. **`other is UserProfileData` bỏ `identical` shortcut** — không sai, nhưng
   `identical` vừa nhanh vừa xử lý đúng self-compare; senior luôn để nó đầu.
4. **Nghĩ `var` phá immutability** — biến local trong hàm khác với field của
   object. `gainExp` đổi `var` local thoải mái, object vẫn bất biến.
5. **Quên `%`/chia-0** — `winRateDisplay` phải che `gamesJoined == 0` trước
   khi chia.

## Kiểm tra hiểu biết

1. `copyWith` khác gì việc sửa field trực tiếp? — Field `final` không sửa
   được; `copyWith` trả object mới, object cũ nguyên vẹn cho ai đang giữ.
2. `a == b` mặc định (không override) so gì? — So *identity*: hai instance
   khác nhau luôn `!=` dù cùng dữ liệu.
3. Vì sao `expPercent` kẹp 1–99 thay vì 0–100? — `Expanded` đòi `flex > 0`;
   và 100% chỉ là trạng thái quá độ ngay trước khi `gainExp` lên cấp.
4. `const UserProfileData()` gọi hai nơi tạo mấy object? — Một: các `const`
   giống hệt nhau được canonicalize thành cùng instance.

## Cố ý chưa làm

- `toString()` cho debug — thêm khi cần in profile ra log.
- `fromMap`/`toMap` — M10 với `SharedPreferences` + `dart:convert`.
- Cơ chế "set null qua copyWith" — hạn chế đã nói, cách vượt qua để sau.
- `List.unmodifiable`/deep-equality cho field collection — model M04 chưa
  có field collection nào.
- Test — bài 4 ngay sau khi model được dùng trong UI (bài 3).

## Điểm kiểm tra hoàn thành

- [ ] `copyWith` viết tay, dùng `??`, trả `UserProfileData` mới.
- [ ] `gainExp` xử lý tràn ngưỡng bằng `while` + ngưỡng mới ×1.5.
- [ ] `==` có `identical` + `is` + so từng field; `hashCode` dùng
      `Object.hash` đủ 8 field.
- [ ] Bạn giải thích được câu "thay biến, không sửa object".
