---
title: "Bài 2 · mergeUserProfileForSync — luật merge local ↔ remote"
description: "Merge thuần (pure): progression theo leader = level cao hơn thắng, bằng level → currentExp quyết; tổng tích luỹ = max từng field; session identity thắng username/avatar; gamesWon giữ local; profile demo legacy bị normalize về rỗng trước khi đẩy lên remote. +7 test → 226 → 233."
sidebar:
 label: "Bài 2 · merge semantics"
 order: 2
---

## Mục tiêu

- Thêm `mergeUserProfileForSync` (top-level, pure) + năm helper
 private vào `app_user_data.dart` — hàm quyết định **kết quả cuối
 cùng** của một lần sync: gì giữ từ local, gì lấy từ remote, gì lấy
 từ session.
- Nêu được ba lớp luật khác chủng loại: **identity** (session thắng —
 Google/Apple mới nhất), **progression** (leader = level→exp tiebreak, thắng nguyên khối), **totals** (max từng field — độc lập nhau).
- Giải thích được hai quyết định "kỳ" của senior: `gamesWon` luôn lấy
 local (remote không có cột), và profile demo legacy
 (`'TÀU HỦ ĐI CHILL'`, lv12, 1M) bị normalize về rỗng trước merge —
 tiến trình fake không được phép đẩy lên remote.
- +7 test (`user_profile_sync_merge_test.dart`) → suite **226 → 233**.

## Bạn đang ở đâu

- Cuối Bài 1: `AppUserData` đứng ở biên với đủ 4 cửa dịch;
 `toUpsertMap` khớp cột `public.users` qua test. Suite **226/226**.
- Còn thiếu: *luật* kết hợp hai profile. Repo impl (Bài 3) sẽ fetch
 row remote → gọi hàm merge này → lưu kết quả local → upsert lại
 remote. Merge là đoạn "não" của pipeline — và là phần duy nhất có
 thể unit-test thuần không cần mạng.
- `UserProfileData.copyWith` đã sẵn — merge được viết
 hoàn toàn bằng `copyWith` trên bản leader.

## Vì sao việc này quan trọng ngay bây giờ

Sync gặp xung đột là chuyện thường: chơi offline cả tuần trên điện
thoại (local giàu), đăng nhập lại trên máy tính (remote có bản cũ)
— ai thắng? Nếu trả lời bằng "cái mới hơn thắng" thì cần timestamp
đáng tin (không có — `updated_at` chỉ server biết và có thể bị một
upsert vô nghĩa ghi đè). Senior chọn cách khác: **luật merge tường
minh, deterministic, không cần đồng hồ** — mỗi nhóm field một rule
riêng, và mọi rule test được bằng hàm thuần. Đây là kiến thức không
chỉ dùng cho Supabase: bất cứ đâu có hai bản dữ liệu gặp nhau
(local↔remote, offline-first, multi-device) đều cần một
"merge policy" kiểu này.

## Bạn đã biết gì

- `AppUserData` + `toProfile()`/`fromProfile()` (Bài 1);
 `UserProfileData` đầy đủ field + `copyWith` + `==`.
- `AuthSessionAuthenticated{displayName, photoUrl}` nullable
 (M24); `?.`/`??`/`is`.
- Top-level function + private top-level helper `_name`;
 ternary `?:` (Dart cơ bản).
- `LevelConfig` level 1–100 — level/exp là progression cặp
 đôi, không tách rời được.

## Mental model mới — "ba lớp luật, ba chủng loại" (NORMAL)

```text
identity   → session THẮNG:   username = session.displayName
                              ?? remote.name ?? leader.username
                              avatarUrl = session.photoUrl
                              ?? local.avatarUrl ?? remote.avatarUrl
progression→ LEADER thắng nguyên khối:
             level khác nhau → bên level cao hơn giữ level+exp
             level bằng nhau → bên currentExp cao hơn hơn giữ
             (không trộn level của A với exp của B)
totals     → MAX từng field:  totalMoneyWon / totalQuestionCount /
                              gamesJoined  — độc lập, không "leader"
gamesWon   → LUÔN local (remote không có cột)
```

Vì sao progression "thắng nguyên khối" còn totals thì max từng field?
Vì `level` và `currentExp` **ràng nhau**: exp chỉ có nghĩa trong level
đang đứng (exp 250 của level 1 ≠ exp 250 của level 9). Trộn level của
bên này với exp của bên kia là ra cặp vô nghĩa → phải chọn một bên
("leader"). Còn `totalMoneyWon`/`totalQuestionCount`/`gamesJoined` là
các tổng tích luỹ độc lập — cái nào lớn hơn thì lớn hơn thật, max là
câu trả lời an toàn.

Và vì sao session thắng identity? Vì session vừa được provider cấp —
nó là *hiện tại*. Local username có thể do user tự gõ, remote name có
thể từ máy cũ; `displayName` Google vừa verify mới là "tên thật" mới
nhất. Chuỗi fallback ba tầng: session → remote → leader (leader thường
là local, nhưng cũng có thể là remote khi remote level cao hơn).

Còn `_withoutDemoProgression`: app bản cũ từng seed profile demo
(`'TÀU HỦ ĐI CHILL'`, lv12, 20 trận, 1M VNĐ). Nếu một thiết bị cũ còn
profile đó và user đăng nhập → **không normalize thì tiến trình fake
được merge và upsert lên `public.users` như dữ liệu thật.** Senior
xử bằng `==` so khớp nguyên profile: khớp đúng bộ demo → reset về
rỗng trước khi so sánh; lệch một field cũng coi là profile thật.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
| --- | --- |
| top-level `UserProfileData mergeUserProfileForSync({required …})` | hàm thuần trên import — không class vì không giữ state |
| `levelLeader.copyWith(…)` | kết quả = bản leader vá lại từng nhóm field |
| `_nonEmpty(session.displayName)` | `String?` → `String?` chỉ giữ nếu không rỗng — chuỗi fallback `??` |
| `left.currentExp >= right.currentExp` | tiebreak tại bằng → left (remote) thắng hoà |
| `profile == const UserProfileData(…)` | so khớp nguyên object nhận diện demo |

Chi tiết nhỏ đáng học: `>=` (không phải `>`) trong tiebreak — khi
level *và* exp đều bằng nhau, **remote thắng hoà** (remote là arg
`left`). Cùng tính "thiên remote khi hoà" đó xuất hiện ở
`_maxInt(left >= right)` — nhất quán: nghiêng về phía server khi
không phân được.

## Ví dụ độc lập

Hai mươi dòng — merge policy thu nhỏ, DartPad chạy được:

```dart
class P {
  final int level, exp, coins;
  const P(this.level, this.exp, this.coins);
  P copy({int? level, int? exp, int? coins}) =>
      P(level ?? this.level, exp ?? this.exp, coins ?? this.coins);
}

P leader(P a, P b) =>
    a.level != b.level ? (a.level > b.level ? a : b)
                       : (a.exp >= b.exp ? a : b);
int mx(int a, int b) => a >= b ? a : b;

P merge(P remote, P local) {
  final lead = leader(remote, local);
  return lead.copy(coins: mx(remote.coins, local.coins));
}

void main() {
  final local = const P(11, 200, 50000);  // level cao, tiền ít
  final remote = const P(9, 120, 30000);  // level thấp, tiền nhiều… không
  final m = merge(remote, local);
  print('lv${m.level} exp${m.exp} coins${m.coins}'); // lv11 exp200 coins50000
}
```

Đổi `local` thành `P(4, 50, 8000)` và `remote` `P(9, 120, 30000)` →
`lv9 exp120 coins30000`: leader remote giữ level+exp, coins vẫn max
(remote lại trùng max luôn trong ca này — thử `remote.coins = 500`
để thấy `coins500` ≠ coins local 8000 → max vẫn là local!). Đây chính
xác là hai rule tách nhau của `mergeUserProfileForSync`.

## Android / Compose bridge

**SIMILARITY — `merge()` trong repo offline-first.** Pattern
"fetch remote → reconcile → persist → push" giống hệt WorkManager/
sync-adapter cũ: bạn viết một hàm reconcile thuần, unit-test nó,
rồi worker chỉ còn plumbing. Rule "field group → winner" tương đương
conflict-resolution strategy (last-write-wins / field-max).

**IMPORTANT DIFFERENCE — không timestamp/LWW.** Android sync hay dựa
`updatedAt` ai mới hơn thắng; ở đây không có client-clock tin được —
senior chọn semantic merge (leader theo *level*, không theo *giờ).
Kết quả: merge idempotent — chạy hai lần cùng input ra cùng output.

**DO NOT ASSUME — merge không cộng dồn.** `gamesJoined` không phải
`local + remote` (hai máy đếm cùng trận sẽ double-count); nó là
`max`. Nếu tư duy "cộng dồn cho công bằng" sẽ inflate mọi tổng sau
mỗi lần sync.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
| --- | --- |
| `lib/data/profile/app_user_data.dart` (`mergeUserProfileForSync` + `_higherLevelProgressionProfile`/`_maxInt`/`_nonEmpty`/`_withoutDemoProgression`/`_hasDemoProgression` + demo constant) | learner port verbatim — cùng file `app_user_data.dart`, cùng luật và thứ tự fallback |
| `test/user_profile_sync_merge_test.dart` | 7 test learner port verbatim (chỉ đổi package import) — leader/max/session-identity/zero-starter/demo-normalize |

## Build it step by step

**Bước 1 — append vào `lib/data/profile/app_user_data.dart`** (sau
class `AppUserData` — verbatim senior; file giờ đủ hai phần: DTO +
merge):

```dart
/// Merge local ↔ remote khi sync — port nguyên văn senior.
UserProfileData mergeUserProfileForSync({
  required AuthSessionAuthenticated session,
  required UserProfileData localProfile,
  required AppUserData? remoteProfile,
}) {
  final sessionName = _nonEmpty(session.displayName);
  final sessionPhoto = _nonEmpty(session.photoUrl);
  final normalizedLocalProfile = _withoutDemoProgression(localProfile);

  if (remoteProfile == null) {
    return normalizedLocalProfile.copyWith(
      username: sessionName ?? normalizedLocalProfile.username,
      avatarUrl: sessionPhoto ?? normalizedLocalProfile.avatarUrl,
    );
  }

  final remoteAsProfile = remoteProfile.toProfile();
  final levelLeader = _higherLevelProgressionProfile(
    remoteAsProfile,
    normalizedLocalProfile,
  );
  final totalMoneyWon = _maxInt(
    remoteAsProfile.totalMoneyWon,
    normalizedLocalProfile.totalMoneyWon,
  );

  return levelLeader.copyWith(
    username:
        sessionName ??
        _nonEmpty(remoteProfile.displayName) ??
        levelLeader.username,
    avatarUrl:
        sessionPhoto ??
        normalizedLocalProfile.avatarUrl ??
        remoteProfile.avatarUrl,
    totalEarnings: UserProfileData.formatVnd(totalMoneyWon),
    totalMoneyWon: totalMoneyWon,
    totalQuestionCount: _maxInt(
      remoteAsProfile.totalQuestionCount,
      normalizedLocalProfile.totalQuestionCount,
    ),
    gamesJoined: _maxInt(
      remoteProfile.totalGamesPlayed,
      normalizedLocalProfile.gamesJoined,
    ),
    gamesWon: normalizedLocalProfile.gamesWon,
  );
}

UserProfileData _higherLevelProgressionProfile(
  UserProfileData left,
  UserProfileData right,
) {
  if (left.level != right.level) {
    return left.level > right.level ? left : right;
  }
  return left.currentExp >= right.currentExp ? left : right;
}

int _maxInt(int left, int right) => left >= right ? left : right;

String? _nonEmpty(String? value) {
  if (value != null && value.trim().isNotEmpty) return value;
  return null;
}

UserProfileData _withoutDemoProgression(UserProfileData profile) {
  if (!_hasDemoProgression(profile)) return profile;
  return profile.copyWith(
    username: UserProfileData.defaultUsername,
    level: UserProfileData.defaultLevel,
    currentExp: 0,
    totalQuestionCount: 0,
    totalEarnings: UserProfileData.formatVnd(0),
    totalMoneyWon: 0,
    gamesJoined: 0,
    gamesWon: 0,
  );
}

bool _hasDemoProgression(UserProfileData profile) {
  return profile ==
      const UserProfileData(
        username: 'TÀU HỦ ĐI CHILL',
        level: 12,
        totalEarnings: '1.000.000 VNĐ',
        totalMoneyWon: 1000000,
        gamesJoined: 20,
        gamesWon: 12,
      );
}
```

Đọc nhịp: (1) trích `sessionName`/`sessionPhoto` non-empty; (2)
normalize demo ở *local* trước mọi so sánh; (3) `remoteProfile == null`
→ nhánh early: chỉ đắp danh tính session lên local; (4) có remote →
`toProfile()` dịch về domain, chọn leader, vá từng nhóm.

**Bước 2 — `test/user_profile_sync_merge_test.dart`** (file mới — 7
test senior verbatim; trích hai case trục):

```dart
test('merge uses remote progression when remote money is greater', () {
  const localProfile = UserProfileData(
    username: 'LOCAL PLAYER', avatarUrl: 'local.png',
    level: 4, currentExp: 50,
    gamesJoined: 8, gamesWon: 5,
    totalQuestionCount: 8, totalMoneyWon: 8000,
  );
  const remoteProfile = AppUserData(
    authUuid: 'user-1', displayName: 'REMOTE PLAYER',
    level: 9, currentExp: 120,
    totalGamesPlayed: 30, totalQuestionCount: 30,
    totalMoneyWon: 30000,
  );

  final merged = mergeUserProfileForSync(
    session: const AuthSessionAuthenticated(uid: 'user-1'),
    localProfile: localProfile,
    remoteProfile: remoteProfile,
  );

  expect(merged.username, 'REMOTE PLAYER');   // remote name (session im)
  expect(merged.avatarUrl, 'local.png');      // local avatar sống sót
  expect(merged.level, 9);                    // leader = remote
  expect(merged.currentExp, 120);
  expect(merged.totalQuestionCount, 30);      // max
  expect(merged.totalMoneyWon, 30000);        // max
  expect(merged.totalEarnings, '30.000 VNĐ'); // format lại từ số
  expect(merged.gamesJoined, 30);             // max
  expect(merged.gamesWon, 5);                 // LOCAL — remote không có
});
```

Bảy case đủ phủ: local-wins / remote-wins / tie-exp / session-identity
override / remote-null zero-starter / remote-null demo-normalize.

## Hiểu code — ba chi tiết dễ trượt

1. **Username fallback ba tầng, KHÔNG phải "leader thắng".** Ngay cả
 khi *local là leader*, `username` vẫn ưu tiên `remote.displayName`
 khi session không cung cấp — test 'merge keeps local progression
 when local money is greater' assert `username == 'REMOTE PLAYER'` dù
 level/exp/totals đều local. Danh tính và progression là hai chủ
 đề khác nhau.
2. **`avatarUrl` fallback không đối xứng:** `sessionPhoto ??
   localAvatar ?? remote.avatarUrl` — local đứng trước remote
 (avatar user tự chọn local được giữ; remote chỉ là dự phòng cuối).
 So với `username` (remote trước leader): hai chuỗi fallback khác
 thứ tự là cố ý.
3. **Demo-detect bằng `==` nguyên object.** User chơi thật mà tình cờ
 trùng *một* field với bộ demo (ví dụ cùng level 12) thì
 `_hasDemoProgression` = false → giữ nguyên. Chỉ khớp đúng bộ sáu
 field mới bị normalize — cực kỳ hẹp, cố ý để không xoá nhầm
 profile thật.

## Chạy và quan sát

```text
flutter analyze → No issues found!
flutter test test/user_profile_sync_merge_test.dart → 7/7 xanh
flutter test    → +233: All tests passed!   (226 + 7)
```

`mergeUserProfileForSync` vẫn chưa có caller trong `lib/` — repo impl
Bài 3 sẽ gọi nó. Đó là thứ tự cố ý: *luật* được test kỹ trước khi
có *máy chạy luật*.

## Thử nghiệm

Đoán trước, rồi kiểm bằng một `test` scratch hoặc đọc lại case 4
trong file merge test: `local(level 1, exp 250)` vs
`remote(level 1, exp 0)`, session chỉ có `uid` — `merged.currentExp`?
`merged.username`?

<details>
<summary>Đáp án</summary>

`currentExp` = **250** — level hoà → tiebreak exp, local (250 > 0)
là leader. `username` = **'REMOTE PLAYER'** — session không có
`displayName` → rơi vào `_nonEmpty(remoteProfile.displayName)`;
leader-username chỉ là tầng cuối. Đây là bẫy "local thắng progression
nhưng remote vẫn thắng tên" của Hiểu code #1.
</details>

## Lỗi hay gặp

1. **Gộp leader và totals thành một rule.** "Bên thắng lấy hết" sai:
 totals max từng field — test 'remote money greater' chứng minh
 `gamesWon` và từng total được vá riêng trên bản leader.
2. **Trộn level của A với exp của B** (`level: max, exp: max`) —
 tạo cặp progression không tồn tại; leader phải nguyên khối.
3. **Cho `gamesWon` vào max** — `_maxInt(remote(0), local(5))` vẫn
 ra 5 trùng kết quả… nhưng remote luôn 0 nên viết `gamesWon:
   normalizedLocalProfile.gamesWon` là nói đúng ý đồ (và an toàn
 nếu sau này remote thêm cột).
4. **Dùng `>` thay `>=` ở tiebreak** — đổi kết quả khi hoà tuyệt đối;
 senior chọn remote thắng hoà nhất quán với `_maxInt`.
5. **So sánh bằng `toUpsertMap()` thay vì `toProfile()`** — merge
 làm việc trên domain; DTO chỉ là hình chiếu.

## Tự làm — DEBUG (bắt buộc, ca trồng bug thật)

**Setup** — không cần file mới: bug trồng thẳng vào
`lib/data/profile/app_user_data.dart`, test bắt là shipped test.

**Trồng bug**: trong `mergeUserProfileForSync`, đổi

```dart
final normalizedLocalProfile = _withoutDemoProgression(localProfile);
```

thành

```dart
final normalizedLocalProfile = localProfile;
```

**PREDICT trước khi chạy** `flutter test
test/user_profile_sync_merge_test.dart`: mấy test đỏ? Test nào?
Assert nào fail đầu tiên, Expected/Actual là gì? Username trong test
đó có đỏ không?

<details>
<summary>Đáp án + giải thích (đã verify bằng cách chạy thật)</summary>

Đúng **1 test đỏ**: `'merge normalizes legacy demo progression
before first remote upsert'` — fail tại
`expect(merged.level, 1)` với `Expected: <1>, Actual: <12>`.

Bẫy "test đỏ một nửa": assert *trước đó*
`expect(merged.username, 'SESSION PLAYER')` **vẫn xanh** — session
`displayName` thắng danh tính kể cả khi demo không bị normalize,
nên nhìn lướt tưởng chừng merge vẫn đúng. Chỉ khi đọc tiếp mới thấy
level 12 / `totalMoneyWon` 1000000 / `gamesWon` 12 của profile demo
sót lại — chúng sẽ được `saveUserProfile` + upsert lên
`public.users` như tiến trình thật ở Bài 3.

Root cause: `_withoutDemoProgression` là *điều kiện tiên quyết* của
mọi so sánh — local chưa normalize đi vào leader-selection lẫn
max-totals. Khôi phục dòng gốc, chạy lại → 7/7 xanh.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao progression chọn "leader nguyên khối" còn totals
 lại max từng field? — **Đáp:** `level`+`currentExp` ràng nhau
 (exp chỉ có nghĩa trong level đang đứng) → trộn hai bên tạo cặp
 vô nghĩa; các tổng tích luỹ độc lập → max per-field an toàn.
- **Hỏi:** session thắng username/avatar vì lý do gì? — **Đáp:**
 `displayName`/`photoUrl` vừa được provider cấp trong phiên hiện
 tại — là nguồn danh tính mới nhất; remote name có thể cũ, local
 username có thể tự gõ.
- **Hỏi:** `_hasDemoProgression` nhận diện demo bằng cách nào, và
 vì sao cách đó an toàn? — **Đáp:** `==` nguyên `UserProfileData`
 với đúng 6 field bộ demo; lệch một field → profile thật, giữ
 nguyên — không bao giờ xoá nhầm dữ liệu thật.

## Ta cố ý chưa thêm

- Ai gọi `mergeUserProfileForSync`: `UserProfileSyncRepositoryImpl`
 — **Bài 3**.
- Conflict-resolution nâng hơn (per-field timestamp, three-way
 merge với base) — senior không có; luật deterministic này là đủ.
- Merge `UserSettingsData`/leaderboard — sync chỉ phủ profile.
- Đọc/ghi `public.users` thật — **Bài 3–4**; live run OPTIONAL
 (`LIVE_PROFILE_SYNC: NOT_PERFORMED`).

## Checkpoint hoàn thành

- [ ] `app_user_data.dart` có `mergeUserProfileForSync` + 5 helper
 private, đúng luật: identity session-wins, progression leader,
 totals max, `gamesWon` local, demo normalize trước merge.
- [ ] `test/user_profile_sync_merge_test.dart` 7 test xanh.
- [ ] `flutter analyze` sạch; `flutter test` **233/233**.
- [ ] Giải thích được: vì sao `username` có thể là `'REMOTE PLAYER'`
 khi local vẫn là progression-leader, và điều gì xảy ra nếu bỏ
 `_withoutDemoProgression` (test nào đỏ, ở assert nào).
