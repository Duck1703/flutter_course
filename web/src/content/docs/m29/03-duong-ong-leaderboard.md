---
title: "Bài 03 — Leaderboard pipeline: DTO có asset, mapper deterministic, snapshot có pin"
description: "Converge residual leaderboard: `LeaderboardEntryData` +`avatarAsset`/`avatarUrl`/`rankAsset`/`LeaderboardRowStyle{first,second,third,glass,currentUser}`; `_LeaderboardRecord.fromMap→toEntry` — `_rankAsset`/`_avatarAsset`/`_rowStyle` mapper deterministic từ rank; `SupabaseLeaderboardRepository.loadLeaderboard` top-10 + `_loadCurrentEntry` (`maybeSingle`); `DisabledLeaderboardRepository` trả static entries; seam `@visibleForTesting entryFromRow`. `LeaderboardDialogViewModel`: `requestId` chống stale, refresh giữ entries (isRefreshing flag), `_profileBackedCurrentLeaderboardEntry` overlay profile local. `LeaderboardAvatar`: ring màu theo rank + glow + `Image.network` chỉ http/https + initial-fallback. `LeaderboardEntryCard` trophy+subtitle (menu card). +8 test: 321/321."
sidebar:
  order: 3
  label: Đường ống leaderboard
---

# Bài 03 — Leaderboard pipeline: DTO có asset, mapper có quy tắc

## Mục tiêu

Sau bài này bạn sẽ:

- Hiểu pipeline đầy đủ của một màn hình **remote-data**: Supabase
  row → private `_LeaderboardRecord` (parse phòng thủ) →
  `LeaderboardEntryData` (presentation DTO) → `LeaderboardRow`
  (vẽ theo `rankAsset`/`style`).
- Biết vì sao DTO mang **cả `avatarAsset` lẫn `avatarUrl`**
  nullable — asset là fallback deterministic từ rank, URL là
  ảnh thật khi có; UI quyết định ưu tiên nào, không phải repo.
- Nắm được 3 mapper **deterministic** trong repo:
  `_rankAsset(rank)` (medal SVG), `_rowStyle(rank)` (gradient
  theo hạng), `_avatarAsset(rank)` (clamp vào 6 avatar) —
  cùng input luôn cùng output, không random.
- Hiểu **pinned current-user entry**: hạng của bạn (ví dụ 125)
  không nằm trong top-10 nhưng vẫn hiển thị ghim dưới — qua
  hai query (`top-10` + `eq(auth_uuid).maybeSingle()`) hợp
  thành `LeaderboardSnapshot`.
- Ôn lại và thấy lại ở chỗ mới: `_requestId` chống stale async
, sealed `LeaderboardPopupState` 4-variant,
 `@visibleForTesting` seam (mẫu).

## Bạn đang ở đâu

Sau Bài 02 settings đã senior-grade. Leaderboard còn ở "thời
tạm":

```text
learner (trước bài này):
  LeaderboardEntryData: rank/name/level/score + isCurrentUser
       — KHÔNG có avatarAsset/avatarUrl/rankAsset/style
  LeaderboardRow: text rank + text tên — phẳng, không medal,
       không ring avatar, không gradient theo hạng
  static entries: thiếu asset path → UI tự bịa màu
  menu card: không có LeaderboardEntryCard (trophy + subtitle)

senior:
  DTO đầy đủ 5 field mới; repo map record→entry qua 3 mapper;
  VM giữ entry-pin qua refresh; row vẽ medal+avatar+gradient;
  avatar ưu-tiên URL http/https → initial → asset
```

Phần residual ghi gọn: "leaderboard entry card + row asset
pipeline". "Pipeline" là từ khoá — không phải vá row, mà là
xây lại **toàn tuyến** dữ liệu từ-DB-đến pixel.

## Vì sao việc này quan trọng ngay bây giờ

Leaderboard là màn **đầu tiên** trong course kết hợp đủ ba
thứ: remote data thật (Supabase view `leaderboard`), profile
local (username/level/avatarUrl của bạn), và static fallback
(disabled repo → dev/preview không cần DB). Cách nó ghép ba
nguồn — repo cho remote, VM overlay profile lên pinned entry,
const list cho offline — là mẫu sẽ tái dùng ở mọi remote-screen
sau này. Và đây là bài kiểm tra khắt khe nhất: repo file
là verbatim gần như tuyệt đối, chỉ thêm đúng **một seam**
`entryFromRow` được documented.

## Bạn đã biết gì

| Đã học | Ở đâu | Nhắc ngắn |
|---|---|---|
| Remote repository sau contract | M23 | `LeaderboardRepository` là interface; `Supabase…` và `Disabled…` là 2 impl DI chọn |
| Conditional DI | M23 | `main()` chọn impl theo cấu hình; test/preview dùng Disabled/Fake |
| sealed state family | M15 | `LeaderboardPopupState` 4-variant: Loading/Success/Empty/Error — switch kiệt hợp |
| `_requestId` chống stale | M23 | Response trễ không được ghi đè state của request mới hơn |
| Dialog-scoped VM | M16, M29·02 | `LeaderboardDialogViewModel` tạo trong scope, chết cùng dialog |
| Injected-function seam | M27 | `@visibleForTesting static entryFromRow` — cùng mẫu seam-documented của `loadAppVersion`: bóc logic ra test, body verbatim |
| `RefreshIndicator` | M23 | Pull-to-refresh gọi `vm.refresh()` |
| Presentation mapper | M19 | DTO ≠ DB row — `_formatScore`/`_rankAsset` là tầng trình bày ở repo |

## Mental model củng cố — "DTO là hợp đồng giữa data và pixel"

```text
DB row (snake_case, nullable, kiểu lỏng)
   │  _LeaderboardRecord.fromMap   ← parse phòng-thủ (D-41)
   ▼
_LeaderboardRecord (typed, đã-clean)
   │  .toEntry() — 3 mapper deterministic
   ▼
LeaderboardEntryData (rank, name, score:String-đã-format,
   avatarAsset + avatarUrl? + rankAsset + style + isCurrentUser)
   │
   ▼
LeaderboardRow — không biết DB tồn tại: chỉ đọc field DTO
```

Điểm cốt lõi: **row widget không hỏi "rank mấy thì vẽ gì"** —
nó đọc `entry.rankAsset`/`entry.style` đã quyết định sẵn. Mọi
quy tắc "rank 1 thì vàng" sống ở *một* chỗ (repo mapper); UI
là nơi thi hành, không phải nơi suy luận. Ngày senior đổi bảng
màu rank 4, bạn diff một hàm `_rowStyle` — không lùng 40 chỗ
render.

## Dart cần dùng

| Dart | Vai trò ở đây | Xem lại |
|---|---|---|
| `switch (rank) { 1 => …, _ => … }` | mapper deterministic — expression, exhaustive trên int bằng `_` | |
| `LeaderboardRowStyle` enum | style là *giá trị của enum*, không literal | |
| `(rank - 1).clamp(0, len - 1).toInt()` | index an toàn vào list avatar | mới tại đây |
| `value is int / is num → toInt()` | parse phòng thủ JSON loose-typed | |
| `String? → Uri.tryParse → scheme check` | validate `avatarUrl` trước `Image.network` | |
| `maybeSingle()` | query "0 hoặc 1 hàng" — không throw khi rỗng | |
| `@visibleForTesting static` | seam bóc private mapper ra test | |

## Flutter cần dùng

| Flutter | Vai trò ở đây | Xem lại |
|---|---|---|
| `Image.network(url, errorBuilder:)` | avatar remote — fallback initial khi lỗi | mới tại đây |
| `Image.asset(entry.avatarAsset)` | avatar fallback deterministic | catalogue Bài 01 |
| `Border.all` + `BoxShadow` ring | ring màu + glow theo rank | -family |
| `SvgPicture.asset(entry.rankAsset)` + `Semantics` | medal SVG + `rankSemanticLabel` | / |
| `RefreshIndicator` | `vm.refresh()` — isRefreshing giữ entries | |

## Ví dụ độc lập — deterministic mapper

```dart
/// VÍ DỤ ĐỘC LẬP — DartPad chạy được.
const medals = ['gold.svg', 'silver.svg', 'bronze.svg'];
const avatars = ['a1.png', 'a2.png', 'a3.png', 'a4.png', 'a5.png', 'a6.png'];

String rankAsset(int rank) => switch (rank) {
  1 => medals[0],
  2 => medals[1],
  3 => medals[2],
  _ => 'normal.svg',
};

String avatarAsset(int rank) {
  final i = (rank - 1).clamp(0, avatars.length - 1);
  return avatars[i];
}

void main() {
  for (final r in [1, 3, 7, 125]) {
    print('rank $r → ${rankAsset(r)} / ${avatarAsset(r)}');
  }
  // rank 125 → normal.svg / a6.png (clamp vào phần tử cuối)
}
```

## Android / Compose bridge

:::note[Android / Compose bridge — "DTO tại tầng repo"]
- **SIMILARITY**: `record.toEntry()` tương đương
  `ResponseDto.toUiModel()` trong data-layer — mapping là
  *trách nhiệm của repo*, ViewModel nhận đồ đã bày.
- **IMPORTANT DIFFERENCE**: `isCurrentUser` là tham số của
  `toEntry`, không phải field DB — cùng một row render khác
  (style `currentUser`, medal `RankCurrent`) tuỳ ngữ cảnh.
  Row của bạn trong top-10 và row pin của bạn dùng cùng DTO,
  khác *flag*.
- **DO NOT ASSUME**: đừng cho rằng `avatarUrl` nullable nghĩa
  là "luôn hiển thị asset". Ưu tiên senior: URL hợp lệ →
  `Image.network`; URL xấu/lỗi → initial letter; chỉ entry
  không-URL và không phải current user mới `_assetAvatar`.
:::

## Senior project connection

| File senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/data/leaderboard/leaderboard_entry_data.dart` | DTO 9-field + `LeaderboardRowStyle` enum + sealed `LeaderboardPopupState` + static entries |
| `lib/repositories/leaderboard/leaderboard_repository.dart` | `_LeaderboardRecord` + 3 mapper + 2 impl + seam `entryFromRow` (seam là learner-doc, body verbatim) |
| `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart` | `requestId`, refresh giữ pin, `_profileBackedCurrentLeaderboardEntry` |
| `lib/widgets/leaderboard/{leaderboard_avatar,leaderboard_row,leaderboard_list,leaderboard_popup_body}.dart` | vẽ medal+avatar+gradient+score-coin |
| `lib/widgets/menu/leaderboard/leaderboard_entry_card.dart` | menu card 44px trophy + `menuLeaderboardEntrySubtitle` (key mới Bài 01) |
| `lib/widgets/menu/leaderboard/{menu_leaderboard_dialog,menu_leaderboard_dialog_scope}.dart` | dialog + scope |
| `test/widgets/{leaderboard_avatar_test(5),menu_leaderboard_dialog_test(11)}` | test port; net +8 sau retire learner-predecessors |

## Build it step by step

### Bước 1 — DTO mang đủ thứ UI cần

```dart
// learner-app/lib/data/leaderboard/leaderboard_entry_data.dart (trích)
class LeaderboardEntryData {
  final int rank;
  final String name;
  final int level;
  final String score;
  final String avatarAsset;      // fallback deterministic theo rank
  final String? avatarUrl;       // ảnh thật từ DB — có thể null
  final String rankAsset;        // medal SVG path
  final LeaderboardRowStyle style;
  final bool isCurrentUser;
}

enum LeaderboardRowStyle { first, second, third, glass, currentUser }
```

:::note[Hai trường avatar — tại sao không gộp?]
`avatarUrl` là *dữ kiện remote* (có/không, hợp lệ/không — do
network quyết); `avatarAsset` là *dự phòng deterministic* (luôn
có, do rank quyết). Gộp một field sẽ xoá khả năng "thử URL,
rớt về asset" — chính logic của `_AvatarImage`. Giữ tách =
giữ được chuỗi fallback.
:::

### Bước 2 — Parse phòng thủ → DTO qua mapper

```dart
// learner-app/lib/repositories/leaderboard/leaderboard_repository.dart (trích)
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
    rank: rank,
    name: name,
    level: level,
    score: _formatScore(totalMoneyWon),          // int → '2.210.000'
    avatarAsset: _avatarAsset(rank),             // rank → avatar fallback
    avatarUrl: avatarUrl,
    rankAsset: isCurrentUser
        ? AppAssets.leaderboardRankCurrent       // bạn: luôn medal-current
        : _rankAsset(rank),
    style: isCurrentUser ? LeaderboardRowStyle.currentUser
                         : _rowStyle(rank),
    isCurrentUser: isCurrentUser,
  );
}
```

```dart
// ba mapper — deterministic, một nơi duy nhất
static String _rankAsset(int rank) => switch (rank) {
  1 => AppAssets.leaderboardRank1, 2 => AppAssets.leaderboardRank2,
  3 => AppAssets.leaderboardRank3, /* 4,5,6 … */ _ => AppAssets.leaderboardRankCurrent,
};

static LeaderboardRowStyle _rowStyle(int rank) => switch (rank) {
  1 => LeaderboardRowStyle.first, 2 => LeaderboardRowStyle.second,
  3 => LeaderboardRowStyle.third, _ => LeaderboardRowStyle.glass,
};

static String _avatarAsset(int rank) {
  const assets = [AppAssets.avatarMitUotChayTask /* …6 cái… */];
  final index = (rank - 1).clamp(0, assets.length - 1).toInt();
  return assets[index];
}
```

:::tip[Clamp, không modulo]
`_avatarAsset` dùng `clamp` chứ không `%` — rank 125 lấy avatar
cuối, không quay vòng về avatar 1. Quyết định visual nhỏ này
là của senior: hạng xa vẫn có avatar "phù hợp tính cách" nhất
định chứ không ngẫu nhiên.
:::

### Bước 3 — Hai query → một snapshot có pin

```dart
// learner-app/lib/repositories/leaderboard/leaderboard_repository.dart (trích)
Future<LeaderboardSnapshot> loadLeaderboard({String? currentUserId}) async {
  final rows = await _client
      .from(_leaderboardView)
      .select(_leaderboardColumns)
      .order('total_money_won', ascending: false)
      .order('rank')
      .limit(_topEntryCount);                    // top-10
  final topEntries = rows
      .map(_LeaderboardRecord.fromMap)
      .map((r) => r.toEntry(isCurrentUser: false))
      .toList();
  final currentEntry = await _loadCurrentEntry(currentUserId);
  return LeaderboardSnapshot(entries: topEntries, currentEntry: currentEntry);
}

// _loadCurrentEntry: .eq('auth_uuid', id).maybeSingle()
// → row của bạn dù KHÔNG trong top-10; null → guest/no-row
```

`maybeSingle()` là chi tiết quan trọng : "0 hoặc 1 hàng"
— guest (uid null) hoặc user chưa có row đều trả `null` thay
vì throw. VM nhận `null` → tự build entry-pin từ profile local.

### Bước 4 — VM: requestId, refresh giữ pin, overlay profile

```dart
// learner-app/lib/view_models/leaderboard/leaderboard_dialog_view_model.dart (trích)
Future<void> loadLeaderboard({bool isRefresh = false}) async {
  final requestId = ++_requestId;
  final previousState = _state;
  if (isRefresh && previousState is LeaderboardPopupSuccess) {
    _setState(LeaderboardPopupSuccess(
      entries: previousState.entries,            // giữ list cũ…
      currentEntry: previousState.currentEntry,  // …và giữ pin
      isRefreshing: true,                        // chỉ đổi cờ
    ));
  } else {
    _setState(const LeaderboardPopupLoading());
  }
  // …await repo…
  _setState(LeaderboardPopupSuccess(
    entries: snapshot.entries,
    currentEntry: _profileBackedCurrentLeaderboardEntry(snapshot.currentEntry),
  ));
}
```

```dart
// _profileBackedCurrentLeaderboardEntry (trích):
return LeaderboardEntryData(
  rank: currentEntry.rank,          // rank từ DB — giữ
  name: currentEntry.name,
  avatarAsset: AppAssets.avatarTauHuDiChill,
  avatarUrl: userData.avatarUrl ?? currentEntry.avatarUrl, // local ưu-tiên
  style: LeaderboardRowStyle.currentUser,
  isCurrentUser: true,
);
```

Vì sao overlay? — DB của bạn có thể cũ vài giây (username mới
đổi chưa sync). VM ghép *rank/score remote* với *avatarUrl/
username local* → pin luôn phản ánh "bạn" nhất có thể. Ngược
lại `avatarAsset`/`rankAsset`/`style` luôn cố định cho
currentUser — không phụ thuộc DB.

### Bước 5 — Avatar: chuỗi fallback 3 tầng

```dart
// learner-app/lib/widgets/leaderboard/leaderboard_avatar.dart (trích)
final avatarUrl = _validAvatarUrl(entry.avatarUrl);
if (avatarUrl == null) return _fallbackAvatar();
return Image.network(avatarUrl, fit: BoxFit.cover,
    errorBuilder: (_, _, _) => _initialAvatar());

String? _validAvatarUrl(String? value) {
  if (value == null) return null;
  final uri = Uri.tryParse(value.trim());
  if (uri == null || uri.host.isEmpty) return null;
  return switch (uri.scheme) {
    'http' || 'https' => uri.toString(),
    _ => null,                       // file://, data:, … đều bị chặn
  };
}
```

```text
avatarUrl hợp-lệ ──network OK──► Image.network
        │                └──error──► _initialAvatar (chữ cái đầu)
        ▼ null/xấu
_fallbackAvatar: currentUser hoặc có-url ─► _initialAvatar
                 còn lại                  ─► _assetAvatar (rank-avatar)
```

:::caution[Vì sao chặn non-http scheme?]
`Uri.tryParse` nhận cả `file:///etc/passwd` hay `data:` URI.
`Image.network` không hiểu `file:` — và cho phép scheme tùy ý
là lỗ hổng (asset-path traversal). Whitelist `http||https` là
phòng thủ đầu vào ngay ở lớp widget — senior không tin
dữ liệu DB.
:::

### Bước 6 — Seam cho test (deviation được document)

```dart
// learner-app/lib/repositories/leaderboard/leaderboard_repository.dart (trích)
/// Learner test seam (không có trong senior): bóc mapper
/// `_LeaderboardRecord.fromMap → toEntry` để test phòng-thủ-parse
/// không cần SupabaseClient.
@visibleForTesting
static LeaderboardEntryData entryFromRow(
  Map<String, dynamic> row, {
  required bool isCurrentUser,
}) => _LeaderboardRecord.fromMap(row).toEntry(isCurrentUser: isCurrentUser);
```

Đây là ví dụ mẫu của "documented deviation" trong sweep: senior
không có seam này, nhưng thêm nó cho phép test
`_intValue`/`_stringValue`/mapper mà không mock Supabase.
Logic bên trong vẫn verbatim — chỉ cửa vào là mới. Register
ghi rõ `TEST_SEAM` thay vì `CONVERGED`-mập mờ.

## Hiểu code — 6 chi tiết dễ trượt

**1. `_formatScore` trừ chữ ' VNĐ'** — `UserProfileData
.formatVnd(2210000)` → `'2.210.000 VNĐ'`; leaderboard chỉ muốn
số → `replaceAll(' VNĐ','')`. Format tiền vẫn một nguồn
(UserProfileData), leaderboard chỉ cắt hậu tố.

**2. `order('total_money_won').order('rank')`** — sắp cạnh
tiền trước, rank-sau: hai người cùng tiền thì rank (server-side)
phân định. Bỏ order thứ hai = thứ tự không xác định cho điểm
hòa.

**3. `LeaderboardPopupSuccess` có default-const** —
`entries = leaderboardEntries, currentEntry = currentLeaderboardEntry`
— `const LeaderboardPopupSuccess()` *là* offline-preview hợp lệ;
`DisabledLeaderboardRepository` trả đúng static đó. Dev-mode
và preview không cần DB.

**4. `isRefreshing` là flag trong Success, không phải variant** —
refresh *trong khi thành công* khác *đang tải lần đầu*: variant
riêng sẽ mất entries→nhấp nháy; flag giữ list + hiện indicator.

**5. Ring-current-user khác ring-rank** — `_isCurrentUserEntry`
cho `green400` + `_ringInset` bỏ gap (ring sát mép); còn rank
1–10 mỗi hạng một màu + màu glow riêng (`_ringGlowColor` — bảng
10 màu @alpha-0x66). Hai lookup-table riêng cho viền và quầng.

**6. `_initial` dùng `runes.first`** — không `value[0]`: rune
lấy đúng code-point đầu (an toàn với emoji/dấu), `toUpperCase`
chuẩn hoá hiển thị.

## Chạy và quan sát

```bash
cd learner-app
flutter test test/widgets/leaderboard_avatar_test.dart \
             test/widgets/menu_leaderboard_dialog_test.dart
# 5 + 11 case
flutter test                      # 321/321 (+8)
grep -rn "entryFromRow" lib/ test/   # seam chỉ test dùng
```

Quan sát trong app (disabled-repo): mở leaderboard → 6 hàng
static với medal vàng/bạc/đồng, avatar PNG theo rank, row pin
xanh lá ở dưới. Pull-to-refresh: list **không biến mất**, chỉ
indicator chạy — đó là `isRefreshing` đang giữ pin+entries.

## Thử nghiệm

| Thử | Dự đoán | Thực tế |
|---|---|---|
| Sửa `_avatarAsset` dùng `% assets.length` | Rank 125 nhận avatar nào? | `125 % 6 = 5` → avatar thứ 5 thay vì cuối — khác biệt nhỏ nhưng **sai**: hạng xa quay vòng, người rank 7 và rank 13 trùng avatar. Clamp giữ "xa nhất" |
| Repo trả `avatarUrl: 'javascript:alert(1)'` | UI hiện gì? | `_validAvatarUrl` chặn scheme → null → fallback — whitelist cứu cả payload lạ lẫn DB-bẩn |
| Bỏ `isRefreshing` mà set `LeaderboardPopupLoading` khi refresh | Nhìn thấy gì? | Toàn list biến thành spinner rồi quay lại — nhấp nháy. Flag-in-variant giữ UX "đang làm mới chứ không mất dữ liệu" |
| `currentUserId` rỗng chuỗi `''` | `_loadCurrentEntry` làm gì? | `isEmpty` check → null sớm, không query `.eq('auth_uuid','')` vô nghĩa — guard cả hai dạng "không có user" |

## Lỗi hay gặp

| Lỗi | Vì sao | Sửa |
|---|---|---|
| Medal đồng hạt cho mọi hạng | `_rankAsset` bị gỡ switch chỉ trả `RankCurrent` | khôi phục switch; nhớ `isCurrentUser` bypass mapper (luôn RankCurrent) |
| Refresh xong list chớp rỗng | refresh không truyền `isRefresh:true` → Loading variant | `refresh() => loadLeaderboard(isRefresh: true)` |
| Avatar mạng không hiện dù URL đúng | URL khoảng trắng/host rỗng → `_validAvatarUrl` null | đây là đúng hành vi; sửa data ở DB, không nới validator |
| Test muốn gọi `_LeaderboardRecord` trực tiếp | class private | dùng seam `SupabaseLeaderboardRepository.entryFromRow` |
| Pin current-user biến mất sau refresh | quên `currentEntry` trong Success copy | success-refresh giữ cả `entries` lẫn `currentEntry` |

## Tự làm

**PREDICT** — Người dùng đổi avatar ở profile rồi mở
leaderboard **ngay lập tức**, DB chưa kịp sync. Avatar nào
hiển thị ở hàng pin — và cơ chế nào quyết định?

:::note[Gợi ý]
Nhìn `_profileBackedCurrentLeaderboardEntry`: `avatarUrl`
lấy từ đâu trước?
:::

<details>
<summary>Đáp án</summary>

Avatar **local** (mới đổi) hiển thị — `userData.avatarUrl ??
currentEntry.avatarUrl` ưu tiên stream profile local trên giá
trị DB. Đây là lý do overlay tồn tại: pinned entry = "bạn" và
app tin bản local về *chính bạn* hơn bản remote có thể trễ.
Rank/score vẫn lấy remote (local không biết xếp hạng).

</details>

**DEBUG** — QA báo: "user guest mở leaderboard — hàng pin biến
mất hoàn toàn, nhưng senior vẫn hiện pin 'Tàu hủ đi chill'".
Repo trả `currentEntry: null` đúng chuẩn. Bug ở đâu?

:::note[Gợi ý]
Null từ repo không có nghĩa "không pin". Xem VM làm gì khi
`snapshot.currentEntry == null` nhưng `entries` không rỗng.
:::

<details>
<summary>Đáp án</summary>

Bug trong `_profileBackedCurrentLeaderboardEntry` (hoặc phiên
bản learner cũ trả `null` thẳng). Senior: `currentEntry == null
→ _currentUserLeaderboardEntry()` — build pin từ profile local
(username/level/avatarUrl của chính user + asset/rankAsset/
style cố định). Guest vẫn có pin "bạn" — chỉ khi *cả entries
và currentEntry* đều trống VM mới vào `PopupEmpty`.

</details>

**PRODUCE** — Thêm variant giả `LeaderboardPopupRateLimited`
vào sealed family (không cần repo thật). Liệt kê compile-error
nào bùng lên — đó là danh sách chỗ phải xử lý.

:::note[Gợi ý]
Tìm mọi `switch` trên `LeaderboardPopupState` — sealed cho
compiler biết "chưa đủ nhánh".
:::

<details>
<summary>Đáp án</summary>

```dart
final class LeaderboardPopupRateLimited extends LeaderboardPopupState {
  const LeaderboardPopupRateLimited();
}
```

Mọi switch-expression kiệt hợp trên `LeaderboardPopupState`
(`leaderboard_popup_body.dart` — nơi render state→widget) báo
"missing case". Đây chính là lý do sống của sealed family:
thêm variant = compiler tự liệt kê danh sách việc; một `if/
else` lỏng sẽ âm thầm render nhầm.

</details>

## Kiểm tra hiểu biết

**H: Vì sao mapper (`_rankAsset`/`_rowStyle`/`_avatarAsset`)
nằm ở repo chứ không ở widget?** — Vì nó là *trình bày của
dữ liệu*, không phải *vẽ*: cùng một entry có thể render bởi
nhiều widget (row, entry-card, preview) — quy tắc một chỗ.
Widget đọc `entry.rankAsset`, không suy luận lại.

**H: `isCurrentUser` là param `toEntry` — sao không lưu vào
`_LeaderboardRecord`?** — Record là *hình chiếu của row*;
"đây là tôi" là *ngữ cảnh request* (`currentUserId`), không
phải cột DB. Giữ record thuần row cho phép cùng một row render
hai vai (trong top-10 vs hàng pin).

**H: Sealed `LeaderboardPopupState` và enum `LeaderboardPopup
Message` khác nhau thế nào?** — State là *màn hình đang ở đâu*
(4 variant); Message là *lý do của variant rỗng/lỗi* (payload
enum). Success mang data; Empty/Error/Loading mang message —
phân tầng "trạng thái" vs "chi tiết trạng thái".

**H: Seam `entryFromRow` có phải divergence không?** — Có, và
được *documented đúng* trong register (`TEST_SEAM`): nó bóc
private-mapper ra test không đổi logic; senior không cần vì
senior test qua mock client. cho phép deviation kiểu này
— miễn là ghi rõ, không improve lén.

## Ta cố ý chưa thêm

- **Không port phần popup/list "nâng cao" hơn senior** —
  `leaderboard_list.dart`/`leaderboard_popup_body.dart` chỉ
  theo senior (RefreshIndicator + state-switch); không thêm
  skeleton-shimmer hay infinite-scroll senior không có.
- **Không live-test Supabase** — `LIVE_SUPABASE_CONNECTIVITY:
  NOT_PERFORMED` vẫn đứng; coverage là fake-repo + widget test.
- **Không xử lý rank > 10 khác senior** — `_rankAsset` đã
  ` _ → RankCurrent` cho mọi hạng xa; đó là verbatim.
- **`LeaderboardEntryCard` (menu-side) để ở đây nhưng
  consumption ở Bài 04** — card trophy+subtitle xuất hiện trên
  menu khi `MenuScreenContent` port; file tới cùng pipeline
  cho gọn.

## Checkpoint hoàn thành

- [x] `LeaderboardEntryData`: +`avatarAsset`/`avatarUrl`/
      `rankAsset`/`LeaderboardRowStyle`; static entries mang
      asset-path.
- [x] Repo: `_LeaderboardRecord.fromMap` phòng thủ + `toEntry`
      3-mapper deterministic; top-10 + `maybeSingle` pin;
      `DisabledLeaderboardRepository` trả static.
- [x] VM: `requestId` chống stale; refresh `isRefreshing` giữ
      pin; `_profileBackedCurrentLeaderboardEntry` overlay
      profile local.
- [x] `LeaderboardAvatar`: ring+glow theo rank; `Image.network`
      chỉ http/https; fallback initial→asset đúng thứ tự.
- [x] Seam `@visibleForTesting entryFromRow` — deviation
      documented, body verbatim.
- [x] `flutter analyze` clean · `flutter test` **321/321**
      (+8: avatar 5 + dialog 11 − retire learner-predecessor).
