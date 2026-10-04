---
title: "Bài 3 · LeaderboardRepository — query chain & row mapping"
description: "Mổ xẻ cụm đã port ở Bài 2: contract loadLeaderboard({currentUserId}) → LeaderboardSnapshot; chuỗi query senior from('leaderboard').select(...).order(total_money_won desc).order(rank).limit(10) +.eq('auth_uuid', uid).maybeSingle; _LeaderboardRecord map JSON→entry phòng thủ; entryFromRow seam; DisabledLeaderboardRepository; FakeLeaderboardRepository + 4 test → 171 → 175."
sidebar:
 label: "Bài 3 · repository + query"
 order: 3
---

## Mục tiêu

- Đọc trơn chuỗi query Supabase: `from('leaderboard')` →
 `select(cột)` → `order(...) × 2` → `limit(10)` và query hàng riêng
 `.eq('auth_uuid', uid).maybeSingle()`.
- Hiểu `maybeSingle()` — "0 hoặc 1 dòng" trả `null` thay vì throw.
- Giải thích mapping `Map<String,dynamic>` → `_LeaderboardRecord` →
 `LeaderboardEntryData` (parse phòng thủ + format điểm bỏ ' VNĐ').
- Viết `FakeLeaderboardRepository` scriptable + 4 test repo → suite
 **171 → 175**.

## Bạn đang ở đâu

- Bài 2: bốn file leaderboard đã vào `lib/` verbatim; scope đã đăng
 ký contract; `main()` đã chọn impl theo cấu hình.
- Bài này KHÔNG thêm production file — nó mổ xẻ thứ đã port và khoá
 lại bằng test.

## Vì sao việc này quan trọng ngay bây giờ

`SupabaseLeaderboardRepository` là **đường remote đầu tiên** của
toàn khóa: trước giờ mọi repo đọc SharedPreferences cục bộ. Chuỗi
query của nó là API của Data API Supabase — thứ sẽ tái xuất ở M24
(auth) và M25 (sync). Hiểu đúng một chuỗi ở đây = hiểu pattern của
mọi query sau.

## Bạn đã biết gì

- Contract + snapshot + hai impl (Bài 2); `import`/
 `export` file hợp nhất.
- `Map<String,dynamic>` + parse phòng thủ kiểu `fromMap` (M10 —; `UserProfileData.fromMap` cùng họ).
- `String.trim()`, `??`, `_intValue`-style fallback.
- `UserProfileData.formatVnd` (M14 — format '510.000 VNĐ').
- `abstract interface class` + `implements`; fake repo
 handwritten.
- VIEW-vs-table + `auth_uuid` che trên view (Bài 1).

## Mental model — "snapshot là ảnh chụp, không phải kênh trực tiếp"

`loadLeaderboard()` trả `Future<LeaderboardSnapshot>` — một lần
đọc, một kết quả:

```text
repo.loadLeaderboard(currentUserId: uid)
   │  (một HTTP request qua Data API — client không thấy)
   ▼
LeaderboardSnapshot {
  entries:      top-10 đã sort SẴN trên server (rank từ view),
  currentEntry: hàng của mình — null nếu uid null hoặc chưa có trên bảng
}
   │
   ▼
VM quyết định render — repo KHÔNG stream, KHÔNG tự cập nhật.
```

Khác `userProfileStream` (BehaviorSubject, M14): leaderboard không
có stream — muốn dữ liệu mới, phải gọi `loadLeaderboard` lại. Đó
chính là cơ sở cho `refresh()` ở Bài 4.

## Dart/Backend mới — query builder + `maybeSingle` 

| Construct | Vai trò |
|---|---|
| `.from('leaderboard')` | chọn VIEW `public.leaderboard` — Bài 1 |
| `.select('rank,name,avatar_url,level,total_money_won')` | chỉ lấy các cột liệt kê — không `select *` |
| `.order('total_money_won', ascending: false)` | sort giảm dần theo tiền thắng |
| `.order('rank')` | sort phụ theo rank (tie-break của senior) |
| `.limit(10)` | top 10 — `_topEntryCount` |
| `.eq('auth_uuid', uid)` | `WHERE auth_uuid = uid` — lọc đúng hàng mình |
| `.maybeSingle()` | **0 hoặc 1 dòng** → `Map?`: không có → `null` (không throw); `single()` thì throw khi ≠1 |
| `Map<String,dynamic>` row | JSON row thô → map sang model typed |

`select/order/limit/eq` là Data API tự sinh từ schema — vì
`public.leaderboard` là view nên *đọc* như đọc bảng thường; điểm
khác duy nhất là `auth_uuid` đã bị che trừ hàng của mình (Bài 1).

## Đọc kỹ impl — `leaderboard_repository.dart`

**Hằng số + hai query** (đúng senior):

```dart
const _leaderboardView = 'leaderboard';
const _leaderboardColumns = 'rank,name,avatar_url,level,total_money_won';
const _topEntryCount = 10;

// Query 1 — top rows:
final rows = await _client
    .from(_leaderboardView)
    .select(_leaderboardColumns)
    .order('total_money_won', ascending: false)
    .order('rank')
    .limit(_topEntryCount);
final records = rows.map(_LeaderboardRecord.fromMap).toList();
final topEntries = records
    .map((record) => record.toEntry(isCurrentUser: false))
    .toList();

// Query 2 — hàng của chính mình (trong _loadCurrentEntry):
if (currentUserId == null || currentUserId.isEmpty) {
  return null; // guest → không có "hàng riêng" để query
}
final row = await _client
    .from(_leaderboardView)
    .select(_leaderboardColumns)
    .eq('auth_uuid', currentUserId)
    .maybeSingle();
```

Ba chi tiết dễ trượt:

1. **Hai `.order` liên tiếp** = `ORDER BY total_money_won DESC, rank`
 — order thứ hai là tie-breaker, không ghi đè order thứ nhất.
2. `.eq('auth_uuid', uid)` hoạt động nhờ thiết kế view ở Bài 1:
 `auth_uuid` chỉ non-null trên hàng của chính caller → query lọc
 này trả đúng một hàng của mình, hoặc không hàng nào.
3. `maybeSingle()` trả `null` khi 0 dòng — người chơi đã đăng nhập
 nhưng chưa có trên bảng là *trường hợp hợp lệ*, không phải lỗi.
 `single()` sẽ throw và biến "chưa có hạng" thành crash — đó là
 lý do senior chọn `maybeSingle`.

**Mapper phòng thủ** — `_LeaderboardRecord`:

```dart
factory _LeaderboardRecord.fromMap(Map<String, dynamic> map) {
  return _LeaderboardRecord(
    rank: _intValue(map['rank'], 0),
    name: _stringValue(map['name']) ?? 'Player',
    avatarUrl: _stringValue(map['avatar_url']),
    level: _intValue(map['level'], 1),
    totalMoneyWon: _intValue(map['total_money_won'], 0),
  );
}

LeaderboardEntryData toEntry({required bool isCurrentUser}) {
  return LeaderboardEntryData(
    rank: rank, name: name, level: level,
    score: _formatScore(totalMoneyWon),
    avatarUrl: avatarUrl,
    isCurrentUser: isCurrentUser,
  );
}

// score '510.000 VNĐ' → '510.000' — senior bỏ hậu tố cho gọn hàng:
static String _formatScore(int amount) {
  return UserProfileData.formatVnd(amount).replaceAll(' VNĐ', '');
}
```

- `_intValue(v, fb)`: `int` → giữ; `num` khác (vd `1500000.0`) →
 `toInt()`; còn lại → fallback. `_stringValue(v)`: `String`
 non-blank → trim; còn lại → `null` (→ `?? 'Player'`/`?? null`).
 Server trả kiểu lệch cũng không crash — đúng tinh thần
 `UserProfileData.fromMap` của M14.
- `score` trên entry là **String đã format** — UI chỉ in ra, không
 tự format lại.

**Seam test** — vì không dựng được `SupabaseClient` trong test:

```dart
@visibleForTesting
static LeaderboardEntryData entryFromRow(
  Map<String, dynamic> row, {required bool isCurrentUser}) {
  return _LeaderboardRecord.fromMap(row).toEntry(
    isCurrentUser: isCurrentUser,
  );
}
```

`@visibleForTesting` báo "API này tồn tại cho test" — unit test gọi
thẳng với `Map` giả JSON, không cần mạng. Đây là cách course giữ
mapper được test trong khi đường remote vẫn
`NOT_PERFORMED` về live.

**Impl tĩnh** — `DisabledLeaderboardRepository`:

```dart
@override
Future<LeaderboardSnapshot> loadLeaderboard({String? currentUserId}) async {
  return const LeaderboardSnapshot(
    entries: leaderboardEntries,
    currentEntry: currentLeaderboardEntry,
  );
}
```

Bỏ qua `currentUserId` hoàn toàn — impl tĩnh không query hàng
riêng: 6 hàng mẫu + hàng "bạn" rank 125 `Tàu hủ đi chill` (tên/điểm
giữ đúng bảng showcase của senior).

## `LeaderboardPopupState` — từ điển 4 state của dialog

Cùng file `leaderboard_entry_data.dart` còn chứa **sealed class
`LeaderboardPopupState`** với đúng 4 variant senior — "từ điển kết
quả" mà VM (Bài 4) emit và UI (Bài 5) switch lên:

| Variant | Mang | Nghĩa |
|---|---|---|
| `LeaderboardPopupSuccess` | `entries` + `currentEntry?` + `isRefreshing` | có dữ liệu; `isRefreshing` = đang pull lại, giữ list cũ |
| `LeaderboardPopupEmpty` | `message` (`LeaderboardPopupMessage.empty`) | snapshot rỗng cả hai phía |
| `LeaderboardPopupError` | `message` (`loadError`) | repo throw — render nút THỬ LẠI |
| `LeaderboardPopupLoading` | `message` (`loading`) | request đang bay |

`sealed` nghĩa là tập đóng: mọi `switch` trên nó được
compiler bắt kiệt hợp — thêm variant thứ năm mà quên render là lỗi
biên dịch, không phải bug ngầm. `LeaderboardPopupMessage`
là enum nhãn — **model giữ enum, widget giữ chữ**: VM không biết
chuỗi l10n; Bài 5 `_messageText` map enum → `l10n.*`.

## `FakeLeaderboardRepository` — fake scriptable (nâng cấp)

`test/helpers/fake_leaderboard_repository.dart` (verbatim senior):

```dart
class FakeLeaderboardRepository implements LeaderboardRepository {
  final LeaderboardSnapshot? snapshot;
  final Object? error;
  final List<Completer<LeaderboardSnapshot>> completers;
  String? lastCurrentUserId;
  var loadCallCount = 0;

  @override
  Future<LeaderboardSnapshot> loadLeaderboard({String? currentUserId}) async {
    loadCallCount++;
    lastCurrentUserId = currentUserId;
    final error = this.error;
    if (error != null) {
      throw error; // nhánh error — lái LeaderboardPopupError
    }
    if (completers.isNotEmpty) {
      return completers.removeAt(0).future; // test tự quyết KHI NÀO về
    }
    return snapshot ?? const LeaderboardSnapshot(entries: []);
  }
}
```

Ba chế độ scriptable hơn fake M14:

- `snapshot`: trả ngay — lái nhánh success/empty.
- `error`: throw — lái nhánh `LeaderboardPopupError`.
- `completers`: pop một `Completer` mỗi call — **test giữ chìa
 khoá**: quyết định response "về" lúc nào, ở đâu — chính cái này
 dựng được test stale-response ở Bài 4 (request 1 chậm hơn
 request 2).

`loadCallCount`/`lastCurrentUserId` ghi tương tác để assert "VM gọi
repo đúng tham số" — không mock framework, đúng convention repo.

## Build it step by step — fake + test file

**Bước 1** — tạo `test/helpers/fake_leaderboard_repository.dart`
(code trên, đầy đủ ctor `FakeLeaderboardRepository({this.snapshot,
this.error, List<Completer<…>>? completers}) : completers =
completers ?? [];`).

**Bước 2** — `test/repositories/leaderboard_repository_test.dart`,
4 test:

```dart
group('DisabledLeaderboardRepository', () {
  test('trả đúng static data (entries + currentEntry)', () async {
    const repo = DisabledLeaderboardRepository();
    final snapshot = await repo.loadLeaderboard();
    expect(snapshot.entries, leaderboardEntries);
    expect(snapshot.currentEntry, currentLeaderboardEntry);
    expect(snapshot.entries, hasLength(6));
    expect(snapshot.currentEntry?.isCurrentUser, isTrue);
    expect(snapshot.currentEntry?.rank, 125);
  });

  test('bỏ qua currentUserId — impl static không query hàng riêng', () async {
    const repo = DisabledLeaderboardRepository();
    final snapshot = await repo.loadLeaderboard(currentUserId: 'uid-1');
    expect(snapshot.currentEntry, currentLeaderboardEntry);
  });
});

group('SupabaseLeaderboardRepository.entryFromRow (mapper seam)', () {
  test('row đầy đủ → entry đúng field, score bỏ hậu tố VNĐ', () {
    final entry = SupabaseLeaderboardRepository.entryFromRow(
      const {
        'rank': 3, 'name': '  Trợ lí đậu bắp ',
        'avatar_url': 'https://example.com/a.png',
        'level': 9, 'total_money_won': 510000,
      },
      isCurrentUser: false,
    );
    expect(entry.rank, 3);
    expect(entry.name, 'Trợ lí đậu bắp'); // trim
    expect(entry.level, 9);
    expect(entry.score, '510.000');
    expect(entry.avatarUrl, 'https://example.com/a.png');
    expect(entry.isCurrentUser, isFalse);
  });

  test('row thiếu/sai kiểu → fallback phòng thủ của senior', () {
    final entry = SupabaseLeaderboardRepository.entryFromRow(
      const {
        'rank': 'abc',           // sai kiểu → 0
        'name': '   ',           // blank → 'Player'
        'avatar_url': 42,        // sai kiểu → null
        'total_money_won': 1500000.0, // num → int
      },
      isCurrentUser: true,
    );
    expect(entry.rank, 0);
    expect(entry.name, 'Player');
    expect(entry.level, 1);      // thiếu → mặc định
    expect(entry.score, '1.500.000');
    expect(entry.avatarUrl, isNull);
    expect(entry.isCurrentUser, isTrue);
  });
});
```

## Chạy và quan sát

```text
flutter analyze                                       → sạch
flutter test test/repositories/leaderboard_repository_test.dart
  → 4/4 xanh
flutter test → +175: All tests passed!   (171 + 4)
```

## Thử nghiệm

Đoán không chạy: gọi `entryFromRow` với
`{'rank': 1, 'name': 'A', 'level': 2, 'total_money_won': -500}` —
`entry.score` ra gì? (gợi ý: `formatThousands` đếm *ký tự* của
chuỗi `'-500'` — dấu trừ cũng là một ký tự.)

<details>
<summary>Đáp án</summary>

`entry.score == '-.500'` — `formatThousands` nhóm theo 3 ký tự
kể cả dấu `-` (chuỗi `'-500'` dài 4 → chèn `.` sau ký tự đầu), rồi
`formatVnd` thêm `' VNĐ'` và mapper cắt hậu tố. Kết quả xấu nhưng
*thành thật*: mapper chỉ chuyển kiểu, không validate miền giá trị.
Validate business (`>= 0`) nằm ở SQL (`users_total_money_won_
nonnegative check`) — bảng phòng thủ ở hai lớp khác nhau; số âm
thực tế không bao giờ qua được INSERT.
</details>

## Lỗi hay gặp

1. **`.single()` thay `.maybeSingle()` cho hàng của mình.** Người
 chưa có trên bảng → throw PostgrestException thay vì `null` —
 biến trường hợp hợp lệ thành error branch.
2. **Tự sort lại `entries` trong Dart.** Rank + thứ tự đã được
 server tính (`row_number()` + `ORDER BY`); sort lại client-side
 phá tie-break và làm việc thừa.
3. **Quên `isCurrentUser` khi map hàng riêng.** Hàng top đều
 `isCurrentUser: false`; hàng riêng phải truyền `true` — quên thì
 hàng "bạn" không được tô accent (Bài 5 thấy trên UI).
4. **`select *`-tư tưởng.** `.select()` liệt kê đúng 5 cột — view
 đã thiết kế cột public; lôi thêm cột là lôi dữ liệu không cần
 (và `auth_uuid` bản thân đã được che cho mục đích riêng).
5. **Format điểm ở UI.** `entry.score` là String đã format trong
 mapper; format lại ở widget là nhân đôi trách nhiệm và lệch
 senior.

## Tự làm — PRODUCE

Viết `ScriptedLeaderboardRepository` — một fake *mới* (trong
`test/helpers/` hoặc file test riêng, tự quyết; KHÔNG sửa
production): `implements LeaderboardRepository`, ctor nhận
`List<LeaderboardSnapshot> queue`, mỗi `loadLeaderboard` POP snapshot
đầu queue và trả nó; queue hết → trả `LeaderboardSnapshot(entries: [])`.
Ghi `loadCallCount`. Sau đó viết một test nhỏ dùng nó: queue hai
snapshot khác nhau → gọi `loadLeaderboard()` hai lần → assert lần 1
ra entries của snapshot A, lần 2 ra entries của snapshot B,
`loadCallCount == 2`.

:::note[Gợi ý]
Pattern giống `completers.removeAt(0)` của
`FakeLeaderboardRepository` — chỉ khác lưu `LeaderboardSnapshot`
thay vì `Completer`.
:::

<details>
<summary>Đáp án</summary>

```dart
class ScriptedLeaderboardRepository implements LeaderboardRepository {
  final List<LeaderboardSnapshot> queue;
  var loadCallCount = 0;

  ScriptedLeaderboardRepository(this.queue);

  @override
  Future<LeaderboardSnapshot> loadLeaderboard({String? currentUserId}) async {
    loadCallCount++;
    if (queue.isEmpty) return const LeaderboardSnapshot(entries: []);
    return queue.removeAt(0);
  }
}

test('queue hai snapshot → trả đúng thứ tự gọi', () async {
  const a = LeaderboardSnapshot(entries: [
    LeaderboardEntryData(rank: 1, name: 'A', level: 1, score: '1'),
  ]);
  const b = LeaderboardSnapshot(entries: [
    LeaderboardEntryData(rank: 2, name: 'B', level: 2, score: '2'),
  ]);
  final repo = ScriptedLeaderboardRepository([a, b]);

  expect((await repo.loadLeaderboard()).entries.single.name, 'A');
  expect((await repo.loadLeaderboard()).entries.single.name, 'B');
  expect(repo.loadCallCount, 2);
});
```

</details>

## Kiểm tra hiểu biết

- **Hỏi:** `maybeSingle()` khác `single()` ở điểm nào và vì sao
 senior chọn nó? — **Đáp:** `maybeSingle` trả `null` khi 0 dòng;
 `single` throw. "Đã đăng nhập nhưng chưa có hạng" là hợp lệ →
 null, không phải lỗi.
- **Hỏi:** `auth_uuid` trên view khác gì `auth_uuid` trên bảng
 `users`? — **Đáp:** view chỉ lộ `auth_uuid` trên hàng của chính
 caller (case … `else null`); bảng giữ đầy đủ nhưng chỉ owner đọc
 được nhờ RLS.
- **Hỏi:** vì sao test mapper không dựng `SupabaseClient`? — **Đáp:**
 nó cần `Supabase.initialize` (mạng/config thật) — không có trong
 test; seam `entryFromRow` cho phép test map thuần trên `Map` giả.

## Ta cố ý chưa thêm

- Ai gọi `loadLeaderboard` và chuyển snapshot thành UI — **Bài 4**
 (VM) + **Bài 5** (dialog).
- `currentUserId` thật từ auth — **M24** (giờ VM luôn truyền null —
 guest seam).
- GHI vào `public.users` (insert/update/upsert/sync) — **M25**.
- Realtime subscription tự cập nhật bảng — ngoài scope (senior
 không dùng; pull-to-refresh là cơ chế).

## Checkpoint hoàn thành

- [ ] Đọc trơn không nhìn code: `from('leaderboard')` → `select(5
  cột)` → `order total_money_won desc` → `order rank` → `limit 10`;
 hàng riêng `eq('auth_uuid', uid).maybeSingle()`.
- [ ] `test/helpers/fake_leaderboard_repository.dart` + test file
 tồn tại; `flutter test` **175/175**.
- [ ] Giải thích được vì sao `entries` không cần sort lại phía
 Dart (rank từ `row_number()` + ORDER BY trên server).
