---
title: "Bài 1 · AppUserData — DTO biên local ↔ public.users"
description: "AppUserData: 8 field theo đúng cột public.users; fromMap/fromProfile/toUpsertMap/toProfile + parse phòng thủ; bảng users (11 cột, auth_uuid unique FK → auth.users, CHECK ≥ 0, RLS own-row); tên cột ≠ tên field; gamesWon không có cột → local-only. +2 test → 224 → 226."
sidebar:
 label: "Bài 1 · AppUserData + schema"
 order: 1
---

## Mục tiêu

- Giải thích được vai trò của **DTO biên** (boundary DTO): 
`UserProfileData`

 là domain model local (SharedPreferences), row 
`public.users`
 là shape
 remote — 
`AppUserData`
 là lớp dịch duy nhất giữa hai thế giới.
- Tạo 
`AppUserData`
 đúng 8 field theo cột remote
 (`authUuid`, 
`displayName`, 
`avatarUrl`, 
`level`, 
`currentExp`,
 
`totalGamesPlayed`, 
`totalQuestionCount`, 
`totalMoneyWon`) + bốn cửa
 chuyển đổi: 
`fromMap`
 (row → DTO), 
`fromProfile`
 (session + profile →
 DTO), 
`toUpsertMap`
 (DTO → payload ghi), 
`toProfile`
 (DTO → domain).
- Đọc được schema 
`public.users`
 trong 
`01-setup-database.sql`
: 11 cột,
 
`auth_uuid`
 unique + FK tới 
`auth.users.id`, CHECK 
`≥ 0`
/level 1–100/
 name không rỗng, RLS ba policy own-row — và biết 
`02-verify-database.sql`

 là script kiểm tra schema đó.
- Chỉ được ba thứ remote **không** lưu: 
`email`
 (danh tính ở 
`auth.users`),
 
`gamesWon`
 (không có cột → local-only), 
`totalEarnings`
 chuỗi đã format
 (remote giữ số nguyên 
`total_money_won`, format lại khi đọc về).
- +2 test (`user_profile_sync_schema_test.dart`) → suite **224 → 226**.

## Bạn đang ở đâu

- Cuối M24: 
`flutter test`
 **224/224**. Identity layer đã xong — sealed
 
`AuthSessionData`, 
`AuthRepositoryImpl`, coordinator gọi
 
`syncUserProfile(session)`
 sau sign-in thành công… nhưng lời gọi đó
 rơi vào 
`UserProfileSyncRepositoryDisabled`
 — **no-op**.
- 
`ProfileSyncStateData`
 (Idle/InProgress/Failed) + contract
 
`UserProfileSyncRepository`
 + 
`FakeUserProfileSyncRepository`
 đã tồn
 tại từ M24 — seam chờ impl.
- Bảng 
`public.users`
 + policies + view 
`public.leaderboard`
 đã có
 trong 
`supabase/student-setup/01-setup-database.sql`
 từ M23
 (byte-identical senior) — nhưng app chưa từng đọc/ghi nó. Đây là
 bảng M25 ghi vào.
- 
`UserProfileData`
 đã đủ field merge cần: 
`username`, 
`level`,
 
`currentExp`, 
`totalQuestionCount`, 
`totalMoneyWon`, 
`gamesJoined`,
 
`gamesWon`, 
`avatarUrl`, 
`totalEarnings`, 
`copyWith`, 
`formatVnd`

 (M14/M22).

## Vì sao việc này quan trọng ngay bây giờ

Sync không bắt đầu bằng 
`.upsert(`
 — nó bắt đầu bằng câu hỏi *"row
trông như thế nào trong code?"*. Nếu repo merge trực tiếp trên

`Map<String, dynamic>`
 thô từ Supabase, mọi luật merge phải tự parse,
tự đối chiếu tên cột 
`snake_case`
 với field 
`camelCase`, và một lỗi
chính tả trong key là bug lặng đến khi có người nhìn vào database.
Senior giải bằng một DTO biên: **
`AppUserData`
 biết đúng shape của
bảng 
`users`, 
`UserProfileData`
 không biết gì về remote cả.** Upsert
payload do 
`toUpsertMap`
 sinh — sai key là fail ngay ở test schema,
không phải ở production.

## Bạn đã biết gì

- 
`Map<String, dynamic>`
 row → typed model + parse phòng thủ
 
`_intValue`
/
`_stringValue`
 (M23 — 
`_LeaderboardRecord`);
 
`maybeSingle`
 = 0-or-1 → 
`null`.
- 
`UserProfileData`
 + 
`copyWith`
 + 
`==`
 (M14); 
`formatVnd`

 format 
`'30.000 VNĐ'`
 (M14); 
`LevelConfig`
 level 1–100 (M22).
- 
`AuthSessionAuthenticated{uid,email,displayName,photoUrl}`
 —
 
`uid`
 là sợi nối identity↔profile (M24).
- RLS own-row 
`(select auth.uid()) = auth_uuid`; publishable key
 public-by-design, quyền do server quyết (M23).
- 
`factory`
 ctor + named params + 
`T?`
/
`??`.

## Mental model mới — ba cái cùng lúc

**① "DTO biên: hai thế giới, một lớp dịch"** (NORMAL).

```text
UserProfileData (domain, local)          public.users row (remote, SQL)
  username            ←── name            name text not null
  gamesJoined         ←── total_games_played  bigint
  totalMoneyWon       ←── total_money_won     bigint CHECK ≥ 0
  totalEarnings       (chuỗi format — sinh lại từ totalMoneyWon)
  gamesWon            (KHÔNG có cột — local-only)
                      id/created_at/updated_at (server tự lo)
  —                   auth_uuid           uuid FK → auth.users.id
```


`AppUserData`
 đứng giữa: một chiều 
`fromProfile`
/
`toUpsertMap`
 đi lên,
một chiều 
`fromMap`
/
`toProfile`
 đi xuống. Đổi tên cột ở SQL → chỉ file
này đổi; đổi field domain → cũng chỉ file này đổi. Đó là anti-corruption
layer tí hon — và là lý do merge ở Bài 2 làm việc trên typed data thay
vì JSON thô.

**② "Schema là contract thật — payload phải khớp cột"** (NORMAL).


`toUpsertMap`
 không "tiện gì ghi đó": 8 key của nó là đúng 8 cột app
sở hữu trong 
`public.users`. Constraint phía server kể lại cùng luật
mà parser phía client phòng thủ: 
`name`
 CHECK không rỗng ↔

`_stringValue`
 rỗng → fallback; mọi 
`total_*`
 CHECK 
`≥ 0`
 ↔ 
`_intValue`

âm → fallback; 
`level`
 CHECK 1–100 ↔ 
`LevelConfig.min/maxLevel`.
Hai phía cùng một spec — đó là dấu hiệu schema được thiết kế cho app
này, không phải bảng generic.

**③ "Ba thứ remote CỐ Ý không có"** (callback — awareness).

- 
`email`
: danh tính sống ở 
`auth.users`
 do Supabase Auth quản —
 
`public.users`
 chỉ giữ 
`auth_uuid`
 trỏ về. Duplicate email xuống
 profile-table vừa thừa vừa rủi ro lộ PII qua view.
- 
`gamesWon`
: cột không tồn tại — 
`toProfile()`
 trả 
`gamesWon: 0`
 và
 merge (Bài 2) lấy lại giá trị **local**; nó không bao giờ đi lên
 remote trong payload upsert.
- 
`totalEarnings`
 (String 
`'30.000 VNĐ'`): đó là chuỗi hiển thị —
 remote giữ số nguyên 
`total_money_won`; đọc về format lại qua
 
`UserProfileData.formatVnd`.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| 
`factory X.fromMap(Map<String, dynamic> m)`
 | row JSON → DTO — / áp dụng |
| 
`factory X.fromProfile({required session, required profile})`
 | domain + session → DTO — named factory đọc hai nguồn |
| 
`Map<String, Object?> toUpsertMap()`
 | DTO → payload 
`upsert`
 — key = tên cột |
| 
`static T _xValue(Object? v, T fallback)`
 | parse phòng thủ — reuse |
| 
`const UserProfileData()`
 làm 
`defaults`
 | fallback = default domain, không magic number |
| 
`map['snake_key']`
 ↔ field camelCase | dịch thủ công, không codegen — giữ verbatim senior |

Không construct Dart mới ở đây — mới ở **pattern**: một class chỉ để
dịch biên, nằm trong 
`data/`
 chứ không trong 
`repositories/`, vì nó
thuộc về shape dữ liệu chứ không thuộc hành vi repo.

## Ví dụ độc lập

Hai mươi dòng — một "DTO biên" mini, DartPad chạy được:

```dart
class LocalWallet {
  final String ownerName;
  final int coins;
  const LocalWallet({this.ownerName = 'guest', this.coins = 0});
}

class WalletRow {
  // "bảng remote": cột owner_name + coin_count — KHÔNG có gì khác
  final String ownerName;
  final int coinCount;
  const WalletRow({required this.ownerName, required this.coinCount});

  factory WalletRow.fromMap(Map<String, dynamic> m) => WalletRow(
        ownerName: m['owner_name'] is String &&
                (m['owner_name'] as String).trim().isNotEmpty
            ? m['owner_name']
            : 'guest',
        coinCount: m['coin_count'] is int && (m['coin_count'] as int) >= 0
            ? m['coin_count']
            : 0,
      );

  Map<String, Object?> toUpsertMap() =>
      {'owner_name': ownerName, 'coin_count': coinCount};
}

void main() {
  final up = const WalletRow(ownerName: 'A', coinCount: 5).toUpsertMap();
  final down = WalletRow.fromMap({'owner_name': '', 'coin_count': -7});
  print('$up → ${down.ownerName}/${down.coinCount}');
  // → {owner_name: A, coin_count: 5} → guest/0   (xấu → default)
}
```

Map trực tiếp: 
`WalletRow`
 ↔ 
`AppUserData`, 
`LocalWallet`
 ↔

`UserProfileData`, 
`owner_name`
 ↔ 
`name`, 
`coin_count`
 ↔

`total_money_won`. Điểm giống nhau: key của 
`toUpsertMap`
 là *tên cột
SQL*, còn field là *tên domain* — hai namespace khác nhau, DTO là
người phiên dịch duy nhất.

## Android / Compose bridge

**SIMILARITY — 
`@Entity`
 + 
`TypeConverter`
 ≈ DTO + mapper.** Trong
Room/Retrofit bạn đã quen 
`data class UserEntity`
 với field khác tên
domain model + hàm 
`toDomain()`
/
`toEntity()`. 
`AppUserData`
 là đúng
cái đó: 
`toProfile()`
 ≈ 
`toDomain()`, 
`fromProfile`
 ≈ 
`toEntity()`,

`toUpsertMap()`
 ≈ serialize body cho 
`@PUT`.

**IMPORTANT DIFFERENCE — không 
`@SerializedName`, không codegen.**
Moshi/kotlinx.serialization map 
`snake_case↔camelCase`
 tự động; ở đây
ánh xạ viết tay trong 
`fromMap`
/
`toUpsertMap`
 — dễ đọc, dễ review,
và sai thì test schema (Bước 3) bắt ngay. Đừng tìm annotation — không
có.

**DO NOT ASSUME — remote row ≠ domain model.** Quen "server trả
entity = model" sẽ gặp ngay hai bẫy: 
`gamesWon`
 có ở domain nhưng
vắng ở remote (đừng upsert nó), 
`totalEarnings`
 là chuỗi format chỉ
tồn tại phía domain (đừng cố ghi 
`'30.000 VNĐ'`
 vào cột bigint).

## Senior project connection

| Senior @ 
`main@c8eb860`
 | Dùng để chứng minh |
|---|---|
| 
`lib/data/profile/app_user_data.dart`
 | learner port verbatim — cùng 8 field, 4 ctor/method, 3 parser phòng thủ (file senior còn chứa 
`mergeUserProfileForSync`
 + helpers — Bài 2) |
| 
`supabase/student-setup/01-setup-database.sql`
 | bảng 
`public.users`
 + unique 
`auth_uuid`
 + FK + CHECKs + RLS own-row — learner byte-identical từ M23 |
| 
`supabase/student-setup/02-verify-database.sql`
 | script verify 11 cột + policies + trigger + view — learner port byte-identical (file mới M25) |

## Build it step by step

**Bước 1 — 
`lib/data/profile/app_user_data.dart`
** (file mới — version
Bài 1 chứa 
`AppUserData`
 + 3 parser; 
`mergeUserProfileForSync`
 +
helpers của nó vào ở Bài 2):

```dart
import '../auth/auth_session_data.dart';
import 'user_profile_data.dart';

class AppUserData {
  final String authUuid;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final int currentExp;
  final int totalGamesPlayed;
  final int totalQuestionCount;
  final int totalMoneyWon;

  const AppUserData({
    required this.authUuid,
    required this.displayName,
    this.avatarUrl,
    required this.level,
    required this.currentExp,
    required this.totalGamesPlayed,
    required this.totalQuestionCount,
    required this.totalMoneyWon,
  });

  factory AppUserData.fromMap(Map<String, dynamic> map) {
    const defaults = UserProfileData();
    return AppUserData(
      authUuid: _stringValue(map['auth_uuid'], ''),
      displayName: _stringValue(map['name'], defaults.username),
      avatarUrl: _nullableStringValue(map['avatar_url']),
      level: _intValue(map['level'], defaults.level),
      currentExp: _intValue(map['current_exp'], defaults.currentExp),
      totalGamesPlayed: _intValue(
        map['total_games_played'], defaults.gamesJoined),
      totalQuestionCount: _intValue(
        map['total_question_count'], defaults.totalQuestionCount),
      totalMoneyWon: _intValue(
        map['total_money_won'], defaults.totalMoneyWon),
    );
  }

  factory AppUserData.fromProfile({
    required AuthSessionAuthenticated session,
    required UserProfileData profile,
  }) {
    return AppUserData(
      authUuid: session.uid,
      displayName: profile.username,
      avatarUrl: profile.avatarUrl,
      level: profile.level,
      currentExp: profile.currentExp,
      totalGamesPlayed: profile.gamesJoined,
      totalQuestionCount: profile.totalQuestionCount,
      totalMoneyWon: profile.totalMoneyWon,
    );
  }

  Map<String, Object?> toUpsertMap() => {
        'auth_uuid': authUuid,
        'name': displayName,
        'avatar_url': avatarUrl,
        'level': level,
        'current_exp': currentExp,
        'total_games_played': totalGamesPlayed,
        'total_question_count': totalQuestionCount,
        'total_money_won': totalMoneyWon,
      };

  UserProfileData toProfile() {
    return UserProfileData(
      username: displayName,
      level: level,
      totalEarnings: UserProfileData.formatVnd(totalMoneyWon),
      currentExp: currentExp,
      totalQuestionCount: totalQuestionCount,
      totalMoneyWon: totalMoneyWon,
      gamesJoined: totalGamesPlayed,
      gamesWon: 0, // remote không mang gamesWon — merge lấy lại local
      avatarUrl: avatarUrl,
    );
  }

  static String _stringValue(Object? value, String fallback) {
    if (value is String && value.trim().isNotEmpty) return value;
    return fallback;
  }

  static String? _nullableStringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  static int _intValue(Object? value, int fallback) {
    if (value is int && value >= 0) return value;
    return fallback;
  }
}
```

Đọc bốn cửa: 
`fromMap`
 dùng 
`const UserProfileData()`
 làm nguồn
fallback (giá trị xấu/thiếu → default domain, không throw — đúng
kỷ luật); 
`fromProfile`
 lấy 
`session.uid`
 làm 
`authUuid`

sợi nối; 
`toUpsertMap`
 trả đúng 8 key = 8 cột; 
`toProfile`

reconstruct domain và **cố ý 
`gamesWon: 0`
** vì remote không mang
field đó.

**Bước 2 — 
`supabase/student-setup/02-verify-database.sql`
** (file
mới, port byte-identical senior — *không* sửa). Script chỉ đọc kiểm
tra sau khi chạy 
`01`
: bảng tồn tại, đủ 11 cột bắt buộc
(`id`, 
`auth_uuid`, 
`name`, 
`avatar_url`, 
`level`, 
`current_exp`,

`total_games_played`, 
`total_question_count`, 
`total_money_won`,

`created_at`, 
`updated_at`), constraints + trigger

`users_set_updated_at`
 + ba policy own-row + view 
`leaderboard`.
Đây là bằng chứng schema cho học viên chạy trên project Supabase
riêng — trong môi trường khóa không chạy được (xem caution dưới).

**Bước 3 — 
`test/user_profile_sync_schema_test.dart`
** (file mới —
2 test khóa payload ↔ cột và đọc row):

```dart
import 'package:ai_millionaire_course/data/profile/app_user_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upsert payload includes profile identity and progression fields',
      () {
    const appUser = AppUserData(
      authUuid: 'user-1',
      displayName: 'PLAYER',
      avatarUrl: 'https://example.com/avatar.png',
      level: 20,
      currentExp: 300,
      totalGamesPlayed: 7,
      totalQuestionCount: 40,
      totalMoneyWon: 50000,
    );

    expect(appUser.toUpsertMap(), {
      'auth_uuid': 'user-1',
      'name': 'PLAYER',
      'avatar_url': 'https://example.com/avatar.png',
      'level': 20,
      'current_exp': 300,
      'total_games_played': 7,
      'total_question_count': 40,
      'total_money_won': 50000,
    });
  });

  test('remote profile reads users row fields without email', () {
    final appUser = AppUserData.fromMap({
      'auth_uuid': 'user-1',
      'name': 'PLAYER',
      'avatar_url': 'https://example.com/avatar.png',
      'level': 20,
      'current_exp': 300,
      'total_games_played': 7,
      'total_question_count': 40,
      'total_money_won': 50000,
    });

    expect(appUser.displayName, 'PLAYER');
    expect(appUser.avatarUrl, 'https://example.com/avatar.png');
    expect(appUser.totalGamesPlayed, 7);
  });
}
```

Test đầu so *toàn map*: thêm/bớt/đổi tên một key là đỏ — payload khớp
cột là contract bị khóa. Test hai khóa điều senior gọi "without
email": row không có 
`email`
 và 
`AppUserData`
 không hỏi đến — danh
tính đã ở 
`auth.users`.

## Hiểu code — ba chi tiết dễ trượt

1. **
`fromProfile`
 đọc 
`profile.username`
 → 
`displayName`
 → cột
 
`name`.** Ba tên cho một khái niệm: domain gọi 
`username`, DTO gọi
 
`displayName`
 (thân thiện với session 
`displayName`), SQL gọi
 
`name`. Lần dịch nào cũng tường minh — không có ánh xạ ngầm.
2. **
`toProfile`
 trả 
`gamesWon: 0`
 là cố ý, không phải sót.** Row
 remote không biết 
`gamesWon`; Bài 2 merge lấy lại từ local —
 
`gamesWon: normalizedLocalProfile.gamesWon`. Nếu "fix" bằng cách
 giữ giá trị remote… remote không có gì để giữ.
3. **
`_intValue`
 từ chối cả số âm.** CHECK 
`≥ 0`
 phía server và guard
 
`value >= 0`
 phía client là cùng luật hai đầu — row bẩn (âm) rơi
 về default thay vì kéo theo một 
`totalMoneyWon < 0`
 vào merge.

## Chạy và quan sát

```text
flutter analyze → No issues found!
flutter test test/user_profile_sync_schema_test.dart → 2/2 xanh
flutter test    → +226: All tests passed!   (224 + 2)
```

Đọc số: 224 (cuối M24) + 2 schema = **226**. 
`AppUserData`
 chưa có
ai gọi trong 
`lib/`
 — người dùng đầu tiên là repo impl ở Bài 3;

`mergeUserProfileForSync`
 vào Bài 2 cùng file này.

:::caution[LIVE_PROFILE_SYNC: NOT_PERFORMED]
Môi trường khóa không có credential Supabase — không chạy được

`02-verify-database.sql`
 trên database thật và không ghi được row
thật. Bài này chứng minh shape bằng: schema test khóa key-payload,
file SQL byte-identical senior (diff 
`-q`
 sạch), và 
`fromMap`
/
`toProfile`

unit-level. Đường live (chạy 
`01`
+
`02`
 trong SQL Editor của project
riêng, xem 
`public.users`
 sau sign-in) là OPTIONAL — nói rõ ở Bài 5.
:::

## Thử nghiệm

Đoán trước rồi viết 
`expect`
 kiểm chứng:

`AppUserData.fromMap({'auth_uuid': 'u1', 'name': '   ', 'level': -3,
'total_money_won': 'abc'})`
 → 
`displayName`
? 
`level`
? 
`totalMoneyWon`
?

`avatarUrl`
?

<details>
<summary>Đáp án</summary>


`displayName`
 = 
`'0XFF'`
 (name rỗng sau trim → 
`defaults.username`),

`level`
 = 
`1`
 (âm → 
`defaults.level`), 
`totalMoneyWon`
 = 
`0`

(`'abc'`
 không phải 
`int`
 → default), 
`avatarUrl`
 = 
`null`
 (key vắng
→ 
`_nullableStringValue(null)`
 → null). Không throw — đó là điểm của
parse phòng thủ.
</details>

## Lỗi hay gặp

1. **Coi 
`name`
/
`displayName`
/
`username`
 khác nhau là bug.** Đó là
 thiết kế: cột SQL 
`name`, DTO 
`displayName`, domain 
`username`
 —
 DTO dịch tường minh mỗi chiều.
2. **Thêm 
`email`
 vào 
`toUpsertMap`.** Bảng 
`users`
 không có cột
 
`email`
 — upsert sẽ lỗi server-side; email sống ở 
`auth.users`.
 Test schema cũng đỏ vì map thừa key.
3. **Mong 
`gamesWon`
 lên remote.** Không có cột; 
`toProfile`
 trả 0,
 merge lấy lại local. Đừng "bổ sung" key vào payload.
4. **Bỏ parse phòng thủ** (`map['level'] as int`): JSON có thể trả
 kiểu khác; crash ở boundary thay vì về default.
5. **Sửa key 
`toUpsertMap`
 "cho nhất quán camelCase".** Key PHẢI là
 tên cột 
`snake_case`
 — đổi là ghi sai cột, test đỏ ngay.
6. **Đặt file vào 
`repositories/`.** Nó là data shape, không phải
 hành vi repo — senior để trong 
`data/profile/`; learner giữ y.

## Tự làm — PREDICT

Không chạy test. Với từng input, viết ra giấy kết quả

`AppUserData.fromProfile(session: s, profile: p).toUpsertMap()`
:

| # | 
`session`
 | 
`profile`
 |
|---|---|---|
| a | 
`AuthSessionAuthenticated(uid: 'u9')`
 | 
`UserProfileData()`
 (mặc định) |
| b | 
`AuthSessionAuthenticated(uid: 'u7', displayName: 'G')`
 | 
`UserProfileData(username: 'LAN', level: 3, gamesJoined: 2, gamesWon: 1, totalMoneyWon: 9000)`
 |
| c | như b | 
`UserProfileData(avatarUrl: 'a.png', username: ' ')`
 |

Cụ thể cần ghi: giá trị của 
`'auth_uuid'`, 
`'name'`, 
`'avatar_url'`,
và 
`gamesWon`
 có xuất hiện trong map không?

<details>
<summary>Đáp án</summary>

- a → 
`'auth_uuid':'u9'`, 
`'name':'0XFF'`, 
`'avatar_url':null`,
 các tổng 
`0`, 
`level:1`. 
`gamesWon`
 **không** có trong map (và
 không có trong 
`AppUserData`).
- b → 
`'auth_uuid':'u7'`, 
`'name':'LAN'`
 — displayName của DTO lấy
 từ *profile*, không phải 
`session.displayName`
 ('G' chỉ đi vào
 merge ở Bài 2). 
`'avatar_url':null`, 
`total_games_played:2`,
 
`total_money_won:9000`.
- c → 
`'name':' '`
 nguyên văn — 
`fromProfile`
 KHÔNG normalize
 (không qua 
`_stringValue`); sanitize xảy ra ở 
`fromMap`
 phía đọc
 và ở merge phía ghi. Đây là bẫy "hàm đối xứng không đối xứng":
 
`fromProfile`
 tin input typed, 
`fromMap`
 phòng thủ input JSON thô.

</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao 
`AppUserData`
 tồn tại thay vì repo làm việc trực
 tiếp trên 
`Map<String, dynamic>`
? — **Đáp:** map thô trộn hai
 namespace (cột SQL vs field domain) và không kiểm được bằng type;
 DTO là lớp dịch duy nhất — đổi schema chỉ đổi một file, merge
 làm việc trên typed data.
- **Hỏi:** 
`toProfile`
 trả 
`gamesWon: 0`
 — mất dữ liệu không? —
 **Đáp:** không; remote không lưu 
`gamesWon`, giá trị thật nằm ở
 local và merge (Bài 2) lấy lại 
`normalizedLocalProfile.gamesWon`.
- **Hỏi:** 
`auth_uuid`
 khác 
`id`
 thế nào, và FK trỏ đâu? — **Đáp:**
 
`id`
 là khóa chính tự tăng của bảng; 
`auth_uuid`
 là unique + FK
 tới 
`auth.users.id`
 — sợi nối identity↔profile; upsert conflict
 trên 
`auth_uuid`
 (Bài 3).

## Ta cố ý chưa thêm

- 
`mergeUserProfileForSync`
 + 
`_higherLevelProgressionProfile`
/
 
`_maxInt`
/
`_nonEmpty`
/
`_withoutDemoProgression`
/
`_hasDemoProgression`

 — **Bài 2**, cùng file 
`app_user_data.dart`.
- 
`UserProfileSyncRepositoryImpl`
 — fetch/upsert thật — **Bài 3**.
- 
`main()`
 conditional DI + game VM 
`_syncSavedGameResult`
 — **Bài 4**.
- Consumer 
`syncStateStream`
 (badge/snackbar "đang đồng bộ") — senior
 không render nó; state tồn tại cho observability.
- Chạy 
`02-verify-database.sql`
 trên Supabase thật — OPTIONAL theo
 project riêng của học viên (`LIVE_PROFILE_SYNC: NOT_PERFORMED`).

## Checkpoint hoàn thành

- [ ] 
`lib/data/profile/app_user_data.dart`
 tồn tại với 
`AppUserData`

 8 field + 
`fromMap`
/
`fromProfile`
/
`toUpsertMap`
/
`toProfile`
 +
 3 parser phòng thủ (merge chưa có — Bài 2).
- [ ] 
`supabase/student-setup/02-verify-database.sql`
 tồn tại,
 nội dung nguyên văn senior (không chỉnh sửa).
- [ ] 
`test/user_profile_sync_schema_test.dart`
 2 test xanh —
 map 
`toUpsertMap`
 khớp đúng 8 key/cột.
- [ ] 
`flutter analyze`
 sạch; 
`flutter test`
 **226/226**.
- [ ] Giải thích được: vì sao 
`email`
 và 
`gamesWon`
 không nằm trong
 payload upsert, và fallback của 
`fromMap`
 lấy từ đâu.
