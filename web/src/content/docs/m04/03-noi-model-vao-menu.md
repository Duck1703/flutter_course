---
title: "Bài 3 · Nối model vào menu"
description: "Đưa UserProfileData vào _MenuScreenState, truyền xuống từng widget con, và cho gainExp chạy trong setState — menu render từ model."
sidebar:
  label: "Bài 3 · Model → menu"
  order: 3
---

## Mục tiêu

Xoá hết literal profile khỏi các widget con: `_ProfileHeader`,
`_LevelCard`, `_EarningsCard`, `_StatsRow` đều đọc từ một `_profile`
duy nhất trong `State`. Nút chơi giờ vừa đếm vừa **cộng 10 EXP** — thanh
tiến trình lấp đầy và người chơi lên cấp, bằng đúng cơ chế "setState sang
object mới" đã học.

## Bạn đang ở đâu

- Milestone: **M04 — Model bất biến & unit test đầu tiên** (bài 3/4)
- App hiện tại: `UserProfileData` hoàn chỉnh trong
  `lib/data/profile/` — nhưng menu vẫn đang hard-code.

## Vì sao việc này quan trọng ngay bây giờ

Đây là lần đầu "dữ liệu chảy xuống" bằng một **object có cấu trúc** thay vì
từng primitive rời rạc (`tapCount`, `soundOn` của M03 là state cục bộ nhỏ).
Khi M05 tải profile bất đồng bộ, nó chỉ cần thay `_profile` bằng object đã
tải — toàn bộ UI tự đúng vì đã "uống" từ một nguồn.

## Bạn đã biết gì

- Truyền data xuống widget con qua named params (M02–M03).
- `setState` + field trong `State` (M03); `copyWith`/`gainExp` (bài 2).
- `const` và chỗ nào mất `const` khi con nhận giá trị runtime (M03 bài 1).

## Mental model mới

**Một nguồn sự thật, nhiều hình chiếu.**

```
_MenuScreenState._profile  (một object duy nhất)
        │
        ├─► _ProfileHeader  dùng profile.username
        ├─► _LevelCard      dùng level, currentExp, expForNextLevel, expPercent
        ├─► _EarningsCard   dùng totalEarningsDisplay
        └─► _StatsRow       dùng gamesJoined, gamesWon, winRateDisplay
```

Widget con **không biết** profile đến từ đâu — chúng chỉ nhận và đọc. Khi
`_profile = _profile.gainExp(10)` trong `setState`, object mới chảy xuống
lại → mọi thẻ tự nhất quán. Đây chính là bản chất "UI = hàm của state" mà
M03 đã nói — giờ "state" là một model có nghĩa thay vì biến đếm.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| Field kiểu model | `UserProfileData _profile = const UserProfileData();` | State field kiểu riêng của ta — như `int`/`bool` đã quen |
| Tương tác setter-imm | `_profile = _profile.gainExp(10);` | Gán lại field = object mới (không sửa object) |
| `'${a.b}'` | `'CẤP ${profile.level}'` | Nội suy truy cập field trong `${}` |
| `100 - x` | `flex: 100 - profile.expPercent` | Toán học ngay trong arg — vẫn là Dart thường |

## Flutter cần dùng

Không có API mới. Một lưu ý `const`: khi con nhận `profile` runtime,
`const` tại chỗ đó mất — nhưng `const` chỉ *dời chỗ* xuống các widget vẫn
tĩnh (`SizedBox`, `_LeaderboardEntry`, `TextStyle`). Quy tắc M03 vẫn đúng:
`const` đặt ở mức cao nhất còn tĩnh được.

## Cầu nối Android / Compose

- SIMILARITY: truyền `profile` xuống các widget ≈ truyền `uiState`/`data`
  object vào các composable — một object nguồn, nhiều UI đọc.
- IMPORTANT DIFFERENCE: Compose có `data class.copy` + recomposition tự động
  khi state object đổi; Flutter cần (a) `copyWith`/method tự viết và
  (b) `setState` để báo rebuild — cả hai đã có từ M03/bài 2.
- DO NOT ASSUME: đổi field trong object cũ rồi `setState` "cũng được" —
  object của ta bất biến nên không sửa được; và kể cả khi sửa được, làm vậy
  phá luật chơi "object cũ không bao giờ đổi" mà so sánh `==` và debug dựa
  vào.

## Trong project senior

- `flutter-accelerator-ai/lib/widgets/menu/menu_screen_content.dart` + các
  card dưới `widgets/menu/profile/` — senior truyền `UserProfileData` từ
  ViewModel xuống đúng các card này (`stats_card`, `earnings_card`,
  `level_progress_card`). Ta đang bắt chước đúng hướng data-flow của họ.
- Sự khác biệt cố ý: senior lấy profile từ `UserProfileRepository` (stream,
  M14) qua ViewModel (M11) rồi `context.watch` (M12); M04 lấy từ một field
  `State` cục bộ — đủ để học "UI đọc model" mà chưa cần cả tầng kiến trúc.

## Từng bước thực hiện

### Bước 1 — Import + field `_profile` trong `State`

```dart
// lib/screens/menu_screen.dart — đầu file
import 'package:flutter/material.dart';

import '../core/menu_tokens.dart';
import '../data/profile/user_profile_data.dart';
```

```dart
class _MenuScreenState extends State<MenuScreen> {
  bool _soundOn = true;
  int _playTapCount = 0;
  UserProfileData _profile = const UserProfileData();
```

- FILE: `lib/screens/menu_screen.dart`
- CHANGE: thêm import + một field kiểu `UserProfileData`.
- WHY: `_MenuScreenState` là nơi state màn hình sống — profile là state
  màn hình.
- WHAT IS NEW: field kiểu **class của chính mình**; `const UserProfileData()`
  là giá trị khởi đầu — hồ sơ khách y hệt các con số menu đang hiển thị.

### Bước 2 — `_onPlayTap` cập nhật cả hai field

```dart
  void _onPlayTap() {
    setState(() {
      _playTapCount++;
      // Mỗi lượt bấm tạm thời tính là một "lượt luyện tập" trị giá 10 EXP —
      // chỗ này minh hoạ cập nhật bất biến; game thật sẽ thay ở M08/M09.
      _profile = _profile.gainExp(10);
    });
  }
```

- CHANGE: thêm một dòng gán — `_profile` nhận **object mới** từ `gainExp`.
- WHY: đây là lần đầu `setState` + "immutable update" gặp nhau: đổi state =
  gán field sang instance mới. Nhìn kỹ — không hề có `profile.currentExp++`
  (và cũng không thể, vì `final`).
- Hiệu ứng nhìn thấy: mỗi lần bấm, `'X / 35000 EXP'` tăng 10 — cap 35000
  là ngưỡng senior thật (`LevelConfig.getExpRequiredForLevel(1)`), nên
  lên cấp qua bấm-tay là không thực tế; demo này chứng minh cơ chế
  *cộng + gán object mới*, không phải progression nhanh. (Lên cấp thật
  đến từ `applyGameResult` ở M10 và curve LevelConfig ở M22.)

### Bước 3 — Truyền `profile` xuống header và body

```dart
              child: Column(
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
              ),
```

- `Expanded(child: _MenuBody(…))` **mất `const`** — `_MenuBody` giờ nhận
  `profile` runtime → toàn bộ `Expanded` là runtime widget.
- `_PlayButton` giữ nguyên: đếm bấm vẫn là `int` state cục bộ (không phải
  dữ liệu profile).

### Bước 4 — `_ProfileHeader` đọc `profile.username`

```dart
class _ProfileHeader extends StatelessWidget {
  final UserProfileData profile;
  final bool soundOn;
  final VoidCallback onSoundTap;

  const _ProfileHeader({
    required this.profile,
    required this.soundOn,
    required this.onSoundTap,
  });
  // …
              children: [
                Text(
                  profile.username,
                  style: const TextStyle(
                    color: MenuTokens.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
```

- `const Text('Khách', …)` cũ → `Text(profile.username, style: const …)`:
  text runtime → `const` dời xuống `TextStyle`.
- `avatarUrl` **chưa** được UI dùng: trường nullable tồn tại cho tương lai —
  khi có ảnh thật (avatar từ account, M24), header sẽ hiển thị ảnh thay icon.
  Giờ cứ `null` và hiện `Icons.person` — UI hiện tại đã xử lý đúng trường
  hợp null theo thiết kế.

### Bước 5 — `_MenuBody` chuyển tiếp profile cho ba thẻ

```dart
class _MenuBody extends StatelessWidget {
  final UserProfileData profile;

  const _MenuBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MenuTokens.spacingMd),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LevelCard(profile: profile),
            const SizedBox(height: MenuTokens.spacingSm),
            _EarningsCard(profile: profile),
            const SizedBox(height: MenuTokens.spacingSm),
            const _LeaderboardEntry(),
            const SizedBox(height: MenuTokens.spacingSm),
            _StatsRow(profile: profile),
          ],
        ),
      ),
    );
  }
}
```

- `Padding` ngoài cùng mất `const` (con nhận profile); `SizedBox` và
  `_LeaderboardEntry` vẫn `const` được — `const` tách rời từng phần, đó là
  điểm đẹp của nó.

### Bước 6 — `_LevelCard` render từ model

```dart
class _LevelCard extends StatelessWidget {
  final UserProfileData profile;

  const _LevelCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MenuTokens.spacingMd),
      decoration: BoxDecoration(
        color: MenuTokens.cardBackground,
        borderRadius: BorderRadius.circular(MenuTokens.radiusCard),
        border: Border.all(color: MenuTokens.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CẤP ${profile.level}',
                style: const TextStyle(
                  color: MenuTokens.accentCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${profile.currentExp} / ${profile.expForNextLevel} EXP',
                style: const TextStyle(
                  color: MenuTokens.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: MenuTokens.spacingXs),
          Row(
            children: [
              Expanded(
                flex: profile.expPercent,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: MenuTokens.accentCyan,
                    borderRadius: BorderRadius.circular(MenuTokens.radiusPill),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 100 - profile.expPercent,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: MenuTokens.trackBackground,
                    borderRadius: BorderRadius.circular(MenuTokens.radiusPill),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- Thanh tiến trình đổi từ `flex: 3 / flex: 7` (hard-code) sang
  `flex: profile.expPercent / 100 - profile.expPercent` — M03 viết tay 3:7
  chỉ là tỷ lệ giả; giờ `expPercent` tính ra tỷ lệ thật từ model, và **tự
  đổi** khi EXP tăng. Đây là "derived value" của bài 2 trả giá.
- `'CẤP 1'`/`'X / Y EXP'` literal biến mất hoàn toàn.

### Bước 7 — `_EarningsCard` và `_StatsRow`

```dart
class _EarningsCard extends StatelessWidget {
  final UserProfileData profile;

  const _EarningsCard({required this.profile});
  // …
      child: Column(
        // …
          Text(
            profile.totalEarningsDisplay,
            style: const TextStyle(
              color: MenuTokens.accentYellow,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
```

```dart
class _StatsRow extends StatelessWidget {
  final UserProfileData profile;

  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '${profile.gamesJoined}',
            label: 'Đã chơi',
            valueColor: MenuTokens.statGreen,
          ),
        ),
        const SizedBox(width: MenuTokens.spacingXs),
        Expanded(
          child: _StatTile(
            value: '${profile.gamesWon}',
            label: 'Thắng',
            valueColor: MenuTokens.statPurple,
          ),
        ),
        const SizedBox(width: MenuTokens.spacingXs),
        Expanded(
          child: _StatTile(
            value: profile.winRateDisplay,
            label: 'Tỉ lệ thắng',
            valueColor: MenuTokens.accentCyan,
          ),
        ),
      ],
    );
  }
}
```

- `'0 VNĐ'` → `profile.totalEarningsDisplay` (getter format `'0 VNĐ'`).
- Stats: `gamesJoined`/`gamesWon` (`int` → `'${}'` ra chuỗi) và
  `winRateDisplay` (`'—'` khi chưa chơi — đúng hình menu đang có).

`flutter analyze` → sạch. `flutter run -d chrome` → menu y hệt M03 **nhưng**
bấm nút: EXP tăng, thanh tiến lấp dần, đủ thì `CẤP 2`.

## Đọc hiểu code

Một lần bấm nút chơi:

```
Tap → onTap() = _onPlayTap()
→ setState(() { _playTapCount++; _profile = _profile.gainExp(10); })
   ├─ gainExp trả object MỚI: currentExp 0→10 (vẫn cấp 1)
   └─ setState báo State dirty → lên lịch build
→ build() chạy lại; _profile MỚI chảy xuống header/body
→ _LevelCard đọc profile.currentExp = 10 → '10 / 35000 EXP',
  expPercent vẫn kẹp dưới ở 1 → thanh gần như không đổi
```

Nhận ra: không widget nào tự cập nhật — chúng chỉ **đọc object đi qua**.
Đổi dữ liệu ở một chỗ (State), mọi thẻ nhất quán — đó là lý do chọn một
object nguồn.

## Chạy và quan sát

- `flutter run -d chrome`; bấm "BẮT ĐẦU CHƠI" vài lần: EXP 0 → 10 → 20…
  hiển thị `'X / 35000 EXP'` — cap 35000 là ngưỡng cấp-1 thật của senior
  nên *không* trông chờ lên cấp qua bấm-tay; cơ chế lên cấp được kiểm
  chứng bằng unit test (bài 4) và qua `applyGameResult` ở M10.
- Hot Reload vẫn giữ `_profile` (state sống trong `State`, quy tắc M03);
  Hot Restart reset về `const UserProfileData()`.
- Quan sát console: log `initState`/`dispose` của M03 vẫn đúng.

## Lỗi thường gặp

1. **`setState` mà gán nhầm** — `setState(() { _profile.gainExp(10); })`
   **không làm gì**: `gainExp` trả object mới, kết quả bị vứt đi, `_profile`
   giữ instance cũ → UI đứng im. Phải `_profile = _profile.gainExp(10)`.
2. **`flex: 0` trong `Expanded`** — assert `flex > 0`; đó là lý do
   `expPercent` kẹp dưới ở 1.
3. **`const` sót lại** — `_MenuBody`/`_StatsRow`/… nhận `profile` runtime
   nên `const` trước chúng là compile error; bỏ `const` đúng chỗ.
4. **Truyền profile qua `_LeaderboardEntry`** — không cần: thẻ BXH vẫn tĩnh
   đến M23. Không phải widget nào cũng phải "uống" model.
5. **Nghĩ UI phải gọi `setState` ở con** — con chỉ hiển thị; thay đổi đi lên
   qua callback (`onTap`) và State cha cập nhật — đúng "data down, events up".

## Kiểm tra hiểu biết

1. Vì sao `_profile` nằm trong `_MenuScreenState` mà không trong
   `_LevelCard`? — Vì nhiều widget (header, ba thẻ) cần cùng một nguồn;
   State của màn hình là tổ tiên chung gần nhất — "state ở chỗ thấp nhất
   nhưng đủ cao để phục vụ mọi consumer" (M03).
2. `gainExp` trả object mới — vì sao phải gán lại vào `_profile`? — Object
   cũ bất biến, không tự đổi; `setState` chỉ báo rebuild, còn dữ liệu mới
   phải được *đặt* vào field.
3. `expPercent` là field hay getter? — Getter: mỗi lần đọc tính lại từ
   `currentExp`/`expForNextLevel`; không có bản sao nào có thể lệch.
4. Vì sao `'${profile.gamesJoined}'` cần nội suy mà `value:` lại là
   `String`? — `_StatTile.value` là `String`; `gamesJoined` là `int` —
   `'$x'`/`'${x}'` ép về `String` ngay chỗ hiển thị, model vẫn giữ `int`
   cho tính toán.

## Cố ý chưa làm

- Load profile từ đâu khác — M05 sẽ thay `const UserProfileData()` bằng
  kết quả tải bất đồng bộ.
- Ảnh avatar thật — `avatarUrl` đang `null` có chủ đích; `Image`/asset đến
  khi có nguồn ảnh thật (M12+ trong giai đoạn senior-align).
- Lưu `_profile` qua restart — M10.
- Test widget — chính sách testing của course đặt widget test ở M08; bài 4
  test pure-Dart đã đủ cho M04.
- `formatVnd`/`toMap`/`fromMap` của senior — M10.

## Điểm kiểm tra hoàn thành

- [ ] Không còn literal `'Khách'`/`'CẤP 1'`/`'X / Y EXP'`/`'0 VNĐ'`/
      `'0'`/`'—'` trong các widget con — tất cả đọc từ `profile`.
- [ ] Bấm nút chơi: đếm tăng, EXP tăng 10; text `X / 35000 EXP` đổi.
- [ ] `flutter analyze` → `No issues found!`.
