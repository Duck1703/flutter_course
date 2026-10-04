---
title: "Bài 4 · Unit test đầu tiên"
description: "test/, group/test/expect, Arrange–Act–Assert và flutter test — kiểm chứng UserProfileData mà không cần chạy app."
sidebar:
  label: "Bài 4 · Unit test đầu tiên"
  order: 4
---

## Mục tiêu

Viết file test đầu tiên của course: `test/user_profile_data_test.dart`
kiểm chứng 10 hành vi của `UserProfileData` — constructor mặc định,
`copyWith`, `==`/`hashCode`, `gainExp` lên cấp, `expPercent` kẹp dải,
`winRateDisplay`, `formatThousands`. `flutter test` → `All tests passed!`.

## Bạn đang ở đâu

- Milestone: **M04 — Model bất biến & unit test đầu tiên** (bài 4/4)
- App hiện tại: menu M04 render hoàn toàn từ `UserProfileData`; bấm nút
  cộng EXP/lên cấp.

## Vì sao việc này quan trọng ngay bây giờ

Cho đến giờ "đúng" nghĩa là *mắt nhìn thấy đúng trên màn hình*. Model vừa
viết có logic thật (`gainExp` lên cấp, format hàng nghìn, chia tỉ lệ) —
những thứ *không nhìn được hết bằng mắt một lần* (ai bấm 28 lần để thấy
lên cấp? ai kiểm `1.000.000` format đúng?). Test biến hành vi thành
**khẳng định tự động**: viết một lần, chạy mãi, và mỗi lần refactor sau này
(M10 `fromMap`, M14 repository) có ngay mạng an toàn.

## Bạn đã biết gì

- Model `UserProfileData` đầy đủ (bài 1–2); cú pháp Dart cơ bản.
- `pubspec.yaml` có `dev_dependencies` với `flutter_test` (đã nhìn ở M01).

## Mental model mới

**Test = hàm chạy assertion.** Một test không có gì ma thuật:

```
test('gainExp lên cấp', () {
  // ARRANGE — chuẩn bị dữ liệu
  const profile = UserProfileData();
  // ACT — chạy hành vi
  final next = profile.gainExp(300);
  // ASSERT — khẳng định kết quả
  expect(next.level, 2);
});
```

- `flutter test` quét `test/**_test.dart`, chạy `main()` của từng file,
  đếm `expect` qua/trượt.
- Model **pure Dart** (không import Flutter UI) → test pure Dart: không
  render, không màn hình ảo — chỉ tính và so. Đây là lý do `lib/data/`
  tách khỏi `lib/screens/` ngay từ đầu.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `import 'package:…'` | `package:ai_millionaire_course/data/profile/user_profile_data.dart` | Import theo **tên package** (thay vì tương đối) — test nằm ngoài `lib/` nên đi qua tên package tự khai trong `pubspec` |
| `test(name, fn)` | `test('mô tả', () { … });` | Khai báo một case |
| `group(name, fn)` | `group('UserProfileData', () { … });` | Gom các test cùng chủ đề, prefix tên khi in kết quả |
| `expect(actual, matcher)` | `expect(p.level, 1)` | Khẳng định: matcher `1` nghĩa là `equals(1)` |
| `equals`, `isTrue`, `isNull` | `expect(x, isNull)` | Matcher có sẵn của `flutter_test` |
| `identical(a, b)` | trong test | Kiểm cùng-instance — đã gặp trong `==` |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `flutter_test` | Package test của SDK (trong `dev_dependencies` — chỉ khi dev, không ship vào app). Re-export `package:test_api` + matchers |
| `flutter test` | Lệnh chạy toàn bộ `test/` |

## Cầu nối Android / Compose

- SIMILARITY: `test`/`expect` ≈ JUnit `@Test` + `assertEquals`; `group` ≈
  `@Nested`/`describe`; AAA = đúng Given/When/Then bạn đã quen.
- IMPORTANT DIFFERENCE: Dart test là **hàm đăng ký trong `main()`**, không
  phải annotation — file test tự `import 'package:flutter_test/flutter_test.dart'`
  và tự khai `main()`; runner chỉ cần chạy `main` của file.
- DO NOT ASSUME: `flutter test` chạy trên máy như unit test JVM —
  đúng với test pure Dart này, nhưng `testWidgets` (M08+) chạy trong môi
  trường Flutter giả lập với `WidgetTester` — khác Espresso/Compose Test.

## Trong project senior

- `flutter-accelerator-ai/test/` — ~45 file test, toàn `flutter_test`, fakes
  viết tay trong `test/helpers/` (không mockito/build_runner). Course đi
  đúng hướng đó: test đầu tiên là pure model, fakes đến M14.
- `user_profile_repository_test`/`user_settings_repository_test` của senior
  dùng `SharedPreferences.setMockInitialValues` — M10 ta sẽ viết kiểu đó.

## Từng bước thực hiện

### Bước 1 — Tạo file test

Tạo `test/user_profile_data_test.dart`:

```dart
// test/user_profile_data_test.dart
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfileData', () {
    test('constructor mặc định khớp defaults của senior', () {
      const profile = UserProfileData();

      // Senior `UserProfileData`: defaultUsername '0XFF', mọi counter = 0.
      // `expForNextLevel = 35000` = LevelConfig.getExpRequiredForLevel(1)
      // — hardcode tạm (fidelity register), M22 tính thật và xoá field.
      expect(profile.username, '0XFF');
      expect(profile.level, 1);
      expect(profile.currentExp, 0);
      expect(profile.expForNextLevel, 35000);
      expect(profile.totalMoneyWon, 0);
      expect(profile.gamesJoined, 0);
      expect(profile.gamesWon, 0);
      expect(profile.avatarUrl, isNull);
    });
  });
}
```

- FILE: `test/user_profile_data_test.dart` (mới) — tên phải khớp
  `*_test.dart` để `flutter test` nhận.
- Import đầu: `package:ai_millionaire_course/…` — đường dẫn package từ
  `pubspec.name` + đường dẫn dưới `lib/`; file test nằm ngoài `lib/` nên
  đây là cách chuẩn.
- `group` bọc các test cùng chủ đề — output in `UserProfileData <tên test>`.

### Bước 2 — Test `copyWith` và `==`/`hashCode`

```dart
    test('copyWith thay đúng trường được chọn, giữ nguyên phần còn lại', () {
      const profile = UserProfileData();
      final updated = profile.copyWith(username: 'Minh', level: 5);

      expect(updated.username, 'Minh');
      expect(updated.level, 5);
      expect(updated.currentExp, profile.currentExp);
      expect(updated.gamesWon, profile.gamesWon);
    });

    test('hai profile cùng giá trị thì bằng nhau và có cùng hashCode', () {
      const a = UserProfileData();
      const b = UserProfileData();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a == b, isTrue);
      expect(identical(a, b), isTrue); // const giống nhau được canonicalize
    });

    test('copyWith tạo object mới, không sửa object cũ', () {
      const profile = UserProfileData();
      final updated = profile.copyWith(level: 2);

      expect(identical(profile, updated), isFalse);
      expect(profile.level, 1); // object cũ không đổi
    });
```

- `expect(a, equals(b))` — matcher `equals` gọi `a == b`: test này *phụ
  thuộc* `operator ==` bạn viết ở bài 2. Thiếu `==` → `a != b` dù cùng
  giá trị → test đỏ.
- `identical(a, b)` ở đây trả `true` nhờ **const canonicalization**: hai
  `const UserProfileData()` giống hệt nhau thành đúng một instance — quan
  sát thú vị của `const`.
- Test thứ ba khóa hợp đồng bất biến: `copyWith` không đụng object cũ.

### Bước 3 — Test `gainExp`, `expPercent`, `winRateDisplay`

```dart
    test('gainExp lên cấp và giữ phần EXP dư', () {
      // Truyền cap nhỏ tường minh — default senior 35000 quá xa để
      // demo lên cấp trong một lần cộng.
      const profile = UserProfileData(
        currentExp: 380,
        expForNextLevel: 400,
      );
      final next = profile.gainExp(300); // 380 + 300 = 680 → tràn ngưỡng 400

      expect(next.level, 2);
      expect(next.currentExp, 280);
      expect(next.expForNextLevel, 600); // ngưỡng mới = 400 * 1.5
    });

    test('gainExp dưới ngưỡng chỉ cộng EXP, không đổi level', () {
      const profile = UserProfileData();
      final next = profile.gainExp(10); // 0 + 10 = 10 < 35000

      expect(next.level, 1);
      expect(next.currentExp, 10);
      expect(next.expForNextLevel, 35000);
    });

    test('expPercent quy tiến trình về 1–99', () {
      expect(const UserProfileData().expPercent, 1); // 0/35000 → kẹp dưới
      expect(
        const UserProfileData(currentExp: 350, expForNextLevel: 400)
            .expPercent,
        87, // 350/400 = 87%
      );
      expect(
        const UserProfileData(currentExp: 400, expForNextLevel: 400)
            .expPercent,
        99, // kẹp trên: 100% chỉ tồn tại một lát trước khi lên cấp
      );
    });

    test('winRateDisplay trả — khi chưa chơi, phần trăm khi đã chơi', () {
      expect(const UserProfileData().winRateDisplay, '—');
      expect(
        const UserProfileData(gamesJoined: 4, gamesWon: 2).winRateDisplay,
        '50%',
      );
    });
```

### Bước 4 — Test format helper

```dart
    test('formatThousands nhóm chữ số bằng dấu chấm', () {
      expect(UserProfileData.formatThousands(0), '0');
      expect(UserProfileData.formatThousands(999), '999');
      expect(UserProfileData.formatThousands(150000), '150.000');
      expect(UserProfileData.formatThousands(1000000), '1.000.000');
    });

    test('totalEarningsDisplay ghép format với đơn vị VNĐ', () {
      expect(const UserProfileData().totalEarningsDisplay, '0 VNĐ');
      expect(
        const UserProfileData(totalMoneyWon: 150000).totalEarningsDisplay,
        '150.000 VNĐ',
      );
    });
```

### Bước 5 — Chạy test

```bash
flutter test
```

Kết quả mong đợi:

```
00:00 +10: All tests passed!
```

`+10` = 10 test xanh. Một test đỏ sẽ in `Expected:`/`Actual:` — đọc diff
để biết assertion nào trượt.

## Đọc hiểu code

File test không có gì ngoài `main` → `group` → `test` → `expect`:

```
flutter test
└─ tìm test/user_profile_data_test.dart
   └─ main() chạy → đăng ký group + 10 test
      └─ mỗi test(): chạy callback, expect() so actual vs matcher
         → pass: +1 | fail: in diff Expected/Actual
```

Test không gọi `runApp`, không `MaterialApp` — model là pure Dart nên đây
là unit test đúng nghĩa, chạy trong vài mili-giây.

## Chạy và quan sát

- `flutter test` — đếm `+10: All tests passed!`.
- Thử phá một assert: sửa `expect(next.level, 2)` thành `3` → chạy lại,
  đọc `Expected: <3>` / `Actual: <2>` — đây là format bạn sẽ đọc khi test
  đỏ thật. Sửa lại sau khi thử.
- `flutter analyze` vẫn sạch — test cũng được analyzer kiểm.

## Lỗi thường gặp

1. **Đặt file sai tên** — `flutter test` chỉ nhận `test/**/*_test.dart`;
   `user_profile_test.dart` được nhận, `user_profile_tests.dart` không.
2. **Import tương đối `../lib/…`** — test ngoài `lib/` nên dùng
   `package:<name>/…`; import tương đối lộn ra `lib/` là sai convention.
3. **Test quá rộng** — một `test` assert 20 thứ sẽ khó đọc khi đỏ; tách
   nhỏ theo hành vi như file mẫu.
4. **Nghĩ test phải chạy app** — model pure Dart không cần render; giữ test
   ở tầng Dart tới khi nào cần tương tác UI (M08, `testWidgets`).

## Kiểm tra hiểu biết

1. `expect(a, equals(b))` kiểm gì ở `a`/`b`? — `a == b` qua `operator ==`
   bạn viết; và mặc định `equals` cũng chính là so sánh `==`.
2. Vì sao `identical(a, b)` của hai `const UserProfileData()` là `true`?
   — Vì Dart canonicalize các `const` giống hệt nhau thành một instance.
3. `group` làm gì? — Gom test + prefix tên trong output; tổ chức, không
   thay đổi ngữ nghĩa test.
4. AAA là gì? — Arrange (dựng dữ liệu) / Act (chạy hành vi) / Assert
   (`expect`) — khung đọc test theo ba đoạn.

## Tự làm

**Tự viết test — không copy.** Viết **một** test mới vào
`test/models/app_models_test.dart` (tự viết, không chép 3 test đã có):

- `copyWith` trên `PlayerProfile` (hoặc field bạn chọn) giữ nguyên các
  field không truyền — khác gì `expect` của test bài này?
- Một test cho `UserStats`: `gamesPlayed + 1` qua `copyWith` không làm
  đổi `bestScore`.
- Dự đoán: nếu `copyWith` bị bug quên `?? this.field` (trả `null` khi
  param null), test nào sẽ fail? Viết test đó và xem nó fail đỏ (đừng
  sửa model — xóa test sau khi xác nhận).

:::note[Gợi ý]
`copyWith` chỉ đổi field được truyền; `??` giữ `this.field` khi param là
null — test phải assert cả hai phía: field đổi *và* field giữ nguyên.
:::

<details><summary><strong>Đáp án</strong></summary>

```dart
test('copyWith only changes provided fields', () {
  const p = PlayerProfile(displayName: 'Lan', totalCoins: 100);
  final p2 = p.copyWith(displayName: 'Minh');
  expect(p2.displayName, 'Minh');
  expect(p2.totalCoins, 100);          // giữ nguyên
});

test('copyWith increments gamesPlayed, keeps bestScore', () {
  const s = UserStats(gamesPlayed: 3, bestScore: 9000);
  final s2 = s.copyWith(gamesPlayed: 4);
  expect(s2.gamesPlayed, 4);
  expect(s2.bestScore, 9000);
});
```

Nếu `copyWith` bỏ `??`: `p.copyWith()` không đổi gì nhưng trả `null` cho
field không truyền → test fail. Đó là regression bạn vừa tự tạo và tự
bắt được — kỹ năng "viết test để fail trước" là core của TDD.
</details>

## Cố ý chưa làm

- `testWidgets`/`WidgetTester` — M08 khi có UI tương tác đáng test.
- `setUp`/`tearDown`, `test`-level config — chưa cần.
- Matcher nâng cao (`throwsA`, `closeTo`, `emitsInOrder`) — `throwsA` sẽ
  xuất hiện ở M05 khi test đường lỗi của loader; `emits*` ở M06 (Stream).
- Fake/mock — M10/M14 (senior cũng viết tay fakes, không dùng mockito).

## Điểm kiểm tra hoàn thành

- [ ] `test/user_profile_data_test.dart` có `group('UserProfileData')` và
      10 `test`.
- [ ] `flutter test` → `All tests passed!`.
- [ ] Bạn đọc được một test đỏ qua `Expected:`/`Actual:`.
- [ ] Bạn giải thích được vì sao model pure Dart test được mà không cần UI.
