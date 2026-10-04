---
title: "Bài 4 · Nút CTA & hoàn thiện menu tĩnh"
description: "Hàng mở leaderboard, ba ô thống kê với Expanded, nút BẮT ĐẦU CHƠI gradient — hoàn tất M02 và review toàn file."
sidebar:
  label: "Bài 4 · CTA & hoàn thiện"
  order: 4
---

## Mục tiêu

Hoàn thiện menu tĩnh M02: hàng "Bảng xếp hạng", hàng ba ô thống kê chia đều
bằng `Expanded`, và nút "BẮT ĐẦU CHƠI" gradient ở đáy. Sau bài này bạn đọc
trơn toàn bộ `menu_screen.dart` và biết chính xác chỗ nào sẽ "động" ở M03.

## Bạn đang ở đâu

- Milestone: **M02** (bài 4/4 — cuối milestone)
- App hiện tại: header + `_LevelCard` + `_EarningsCard` thật; `_MenuBody` còn
  hai chỗ trống; `_PlayButton` vẫn là placeholder.

## Vì sao việc này quan trọng ngay bây giờ

Đây là bài đóng khung M02: thêm hai pattern cuối ("entry card" một hàng, "row
chia đều") rồi nhìn *tổng thể* một màn hình composition. Xong bài này, code
M03 chỉ khác M02 ở đúng một điểm: state. Bạn đã có đủ "đất tĩnh".

## Bạn đã biết gì

- Mọi API của bài 1–3: Column/Row/Expanded/Spacer, Container+BoxDecoration,
  `required`/`final` params, tokens, SafeArea/design frame.

## Mental model mới

Ý duy nhất hôm nay: **UI lặp cấu trúc → một widget nhận tham số.** Ba ô
Đã chơi / Thắng / Tỉ lệ thắng cùng hình dáng khác dữ liệu → viết một
`_StatTile` nhận `value`/`label`/`valueColor`, bọc ba lần trong `Expanded`.
Viết widget tái dùng là tư duy composition, không phải copy-paste.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| Nhiều `required` param | `{required this.value, required this.label, required this.valueColor}` | Named params bắt buộc, phân tách `,` |
| `Color` field | `final Color valueColor;` | Field kiểu `Color` nhận từ caller |
| `double.infinity` | `width: double.infinity` | "Hằng số vô cực" — xin hết bề rộng cha cho phép |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `Expanded` ×3 trong Row | Ba ô `flex` bằng nhau → bề rộng đều |
| `Icons.emoji_events`, `Icons.chevron_right`, `Icons.play_arrow` | Icon cúp / mở trang / chơi |
| `textAlign: TextAlign.center` | Canh giữa chữ trong `Text` |

## Cầu nối Android / Compose

- SIMILARITY: `_StatTile(value, label, valueColor)` ≈ `@Composable fun
  StatTile(...)` nhận tham số; `width: double.infinity` ≈
  `Modifier.fillMaxWidth()`.
- IMPORTANT DIFFERENCE: "fill width" là thuộc tính `width` của `Container`
  (con xin hết constraint), không phải modifier — và nó chỉ có tác dụng khi
  cha thật sự cho constraint rộng hữu hạn.
- DO NOT ASSUME: số liệu trong menu là dữ liệu thật — senior truyền từ game
  state; ta đặt literal vì state/game chưa tồn tại (local state M03 chỉ cho
  phép *state UI*, dữ liệu thật đến M08+).

## Trong project senior

- File: `flutter-accelerator-ai/lib/widgets/menu/leaderboard/leaderboard_entry_card.dart`
  — card "mở bảng xếp hạng" của senior: `Row` [icon/ảnh · title+subtitle ·
  chevron] — ta giữ đúng cấu trúc một-hàng-mở-ra (senior thêm ripple,
  gradient theo rank, ảnh thật).
- File: `flutter-accelerator-ai/lib/widgets/menu/profile/stats_card.dart` —
  các ô stat của senior lấy số liệu từ state; ta hardcode `'0'`/`'—'` vì
  chưa có dữ liệu — cố ý, sẽ quay lại khi có game state.
- File: `flutter-accelerator-ai/lib/widgets/menu/gradient_cta_button.dart` —
  nút senior là `GestureDetector` + gradient pill; ở M02 ta **chỉ dựng hình**
  — `GestureDetector` đến ở M03.

## Từng bước thực hiện

### Bước 1 — Thêm hai widget con vào `_MenuBody`

Mở rộng `children` của `Column` trong `_MenuBody` (giữ nguyên phần đã có):

```dart
// lib/screens/menu_screen.dart — children của _MenuBody sau khi thêm
          children: [
            _LevelCard(),
            SizedBox(height: MenuTokens.spacingSm),
            _EarningsCard(),
            SizedBox(height: MenuTokens.spacingSm),
            _LeaderboardEntry(),
            SizedBox(height: MenuTokens.spacingSm),
            _StatsRow(),
          ],
```

### Bước 2 — `_LeaderboardEntry`: entry card một hàng

```dart
// lib/screens/menu_screen.dart — thêm cuối file
/// Hàng mở bảng xếp hạng.
class _LeaderboardEntry extends StatelessWidget {
  const _LeaderboardEntry();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MenuTokens.spacingMd),
      decoration: BoxDecoration(
        color: MenuTokens.cardBackground,
        borderRadius: BorderRadius.circular(MenuTokens.radiusCard),
        border: Border.all(color: MenuTokens.cardBorder),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.emoji_events,
            size: 28,
            color: MenuTokens.accentYellow,
          ),
          SizedBox(width: MenuTokens.spacingSm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bảng xếp hạng',
                  style: TextStyle(
                    color: MenuTokens.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Top 10 người chơi',
                  style: TextStyle(
                    color: MenuTokens.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: MenuTokens.textSecondary),
        ],
      ),
    );
  }
}
```

- Pattern quen thuộc lần thứ ba: `Container(padding+decoration)` → `Row` →
  `Expanded` đẩy `chevron` sát phải.
- Toàn bộ `Row` là `const` — mọi con đều hằng (icon, text, `Expanded` với
  `Column` const). Đây là mức `const` sâu nhất có thể.

### Bước 3 — `_StatsRow` + `_StatTile`: ba ô bằng nhau

```dart
// lib/screens/menu_screen.dart — thêm cuối file
/// Ba ô thống kê nhỏ: đã chơi, thắng, tỉ lệ thắng.
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '0',
            label: 'Đã chơi',
            valueColor: MenuTokens.statGreen,
          ),
        ),
        SizedBox(width: MenuTokens.spacingXs),
        Expanded(
          child: _StatTile(
            value: '0',
            label: 'Thắng',
            valueColor: MenuTokens.statPurple,
          ),
        ),
        SizedBox(width: MenuTokens.spacingXs),
        Expanded(
          child: _StatTile(
            value: '—',
            label: 'Tỉ lệ thắng',
            valueColor: MenuTokens.accentCyan,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _StatTile({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MenuTokens.spacingSm),
      decoration: BoxDecoration(
        color: MenuTokens.cardBackground,
        borderRadius: BorderRadius.circular(MenuTokens.radiusCard),
        border: Border.all(color: MenuTokens.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: MenuTokens.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
```

- Ba `Expanded` không `flex` → mặc định `flex: 1` → **chia đều** phần rộng
  còn lại sau hai `SizedBox(width: 8)`: mỗi ô đúng 1/3 hàng.
- `_StatTile` nhận ba `required` param — một widget, dùng ba lần.
- `TextStyle(color: valueColor)` — `valueColor` là *field* (runtime), nên
  `TextStyle` đó không `const` được; `SizedBox`/`Text(label)` vẫn `const`.

### Bước 4 — `_PlayButton`: nút gradient thật (chưa bắt tap)

**Thay** `_PlayButton` placeholder:

```dart
// lib/screens/menu_screen.dart — thay placeholder _PlayButton
/// Nút hành động chính — M02 mới chỉ là hình; M03 sẽ thêm tương tác.
class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MenuTokens.spacingMd),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(MenuTokens.radiusPill),
              gradient: const LinearGradient(
                colors: [MenuTokens.buttonTop, MenuTokens.buttonBottom],
              ),
            ),
            child: const Text(
              'BẮT ĐẦU CHƠI',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MenuTokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: MenuTokens.spacingXs),
          const Text(
            '15 câu hỏi — Giải thưởng tới 150.000.000 VNĐ',
            style: TextStyle(
              color: MenuTokens.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
```

- `width: double.infinity` — Container xin **hết bề rộng cha** (343px sau
  padding) → nút dài hết khung, `textAlign: center` đặt chữ giữa nút.
- `LinearGradient(colors: [buttonTop, buttonBottom])` không `begin`/`end` —
  mặc định đổ từ trái sang phải; đủ đẹp cho pill.
- `Column` bọc pill + caption — nút và dòng chú thích dưới nó đi cùng nhau;
  caption sẽ bị **thay** bằng bộ đếm động ở M03.
- Vẫn **không** `GestureDetector` — cố ý để M03 có thứ để dạy.

## Đọc hiểu code

Toàn bộ `menu_screen.dart` cuối M02 (đúng cấu trúc với file `learner-app`):

```
MenuScreen (StatelessWidget)
└─ Scaffold(bg: backgroundTop)
   └─ Container(decoration: gradient Top→Bottom)
      └─ SafeArea
         └─ Center
            └─ ConstrainedBox(maxWidth: 375)
               └─ Column
                  ├─ _ProfileHeader          — avatar | Khách | badge ⚙
                  ├─ Expanded(_MenuBody)     — Padding > Center > Column(stretch)
                  │     ├─ _LevelCard        — CẤP 1 · EXP · thanh flex 3:7
                  │     ├─ _EarningsCard     — TỔNG THƯỞNG · 0 VNĐ trên gradient
                  │     ├─ _LeaderboardEntry — 🏆 | Bảng xếp hạng | ›
                  │     └─ _StatsRow         — 3 × Expanded(_StatTile)
                  └─ _PlayButton             — pill gradient + caption
```

Widget public duy nhất là `MenuScreen` — mọi phần con private trong file.
Khi codebase lớn, senior tách từng card ra `lib/widgets/menu/…`; ở quy mô
một màn hình, giữ private vừa đủ vừa dễ đọc.

## Chạy và quan sát

- `flutter run -d chrome` → menu hoàn chỉnh: header trên, 4 vùng thẻ giữa,
  nút gradient đáy. Resize cửa sổ web — khung bó còn 375 khi rộng.
- `flutter build web` — biên dịch production; `flutter analyze` — sạch.
- Bấm icon cài đặt / nút chơi: **không có gì xảy ra** — đúng kỳ vọng M02.
  Chính "không có gì xảy ra" là lý do M03 tồn tại.

## Lỗi thường gặp

1. **Quên `Expanded` quanh `_StatTile`** — ba ô ôm nội dung, không bằng nhau,
   để trống phải hàng.
2. **`flex` trên `SizedBox`** — `SizedBox` không nhận flex; flex chỉ thuộc
   `Expanded`/`Flexible`, và chúng là *anh em* trong `children`, không lồng.
3. **`double.infinity` trong hướng vô hạn** — `width: double.infinity` an
   toàn trong `Column`; nhưng `height: double.infinity` trong `Column` con
   (trục dọc vô hạn) sẽ crash — infinity chỉ dùng theo hướng cha đã giới hạn.

## Kiểm tra hiểu biết

1. Ba ô stat bằng nhau nhờ gì? — Ba `Expanded` cùng `flex:1` chia đều phần
   rộng còn lại của Row.
2. `_StatTile` là StatelessWidget hay StatefulWidget? — Stateless: chỉ hiển
   thị `value`/`label`/`valueColor` truyền vào, không tự đổi.
3. `width: double.infinity` khác `Expanded` thế nào? — `Expanded` xin *phần
   còn lại* trong Row/Column; `double.infinity` xin *hết* constraint cha —
   hai cơ chế khác nhau cho kết quả tương tự trong trường hợp này.
4. Predict: đổi `_StatsRow` thành `Column` ra sao? — `Expanded` vẫn hợp lệ
   trong Column → ba ô xếp **dọc**, mỗi ô cao 1/3 phần còn lại.

## Tự làm

**Sửa đổi — không copy.** Trong `_StatsRow` đang có 3 `_StatTile` (ván
chơi / thắng / …). **Không nhìn lại code bài 3**, hãy:

1. Thêm một `_StatTile` thứ tư (ví dụ "Chuỗi ngày · 5") sao cho 4 ô chia
   đều hàng — và giải thích vì sao `Expanded` đảm bảo điều đó.
2. Tăng khoảng cách giữa các ô lên gấp đôi. Bạn sửa ở đâu: padding của
   từng tile, hay `SizedBox` giữa chúng? Thử cả hai và nói khác biệt
   (constraint nào bị ảnh hưởng).

:::note[Gợi ý]
`Expanded` chia *phần còn lại* theo flex — 4 Expanded flex bằng nhau vẫn
đều nhau. `SizedBox(width:)` ăn vào tổng trước khi Expanded chia.
:::

<details><summary><strong>Đáp án</strong></summary>

1. Thêm `_StatTile(...)` thứ tư bọc trong `Expanded` như 3 ô kia — 4
   `Expanded` cùng flex=1 nên mỗi ô nhận `(width − gaps)/4`.
2. Cả hai đều "chạy", nhưng khác nhau: `SizedBox` giữa các tile chiếm
   không gian *trước* khi Expanded chia phần còn lại (tile hẹp đi);
   padding bên trong tile làm *nội dung* hẹp chứ không đổi bề ngang ô.
   Nếu overflow → bạn đã thấy constraint bị chặn ở đâu.

</details>

## Cố ý chưa làm

- Bắt tap → **M03** (`GestureDetector` + `setState`).
- Số liệu thật từ game state — M08+.
- `ListView` leaderboard dài — M23.
- Overlay/dialog trong `Stack` — M18, M21.

## Điểm kiểm tra hoàn thành — M02

- [ ] `menu_screen.dart` đủ class: `MenuScreen` + `_ProfileHeader`,
      `_IconBadge`, `_MenuBody`, `_LevelCard`, `_EarningsCard`,
      `_LeaderboardEntry`, `_StatsRow`, `_StatTile`, `_PlayButton`.
- [ ] `flutter analyze` → `No issues found!`; `flutter build web` thành công.
- [ ] UI có header + 4 thẻ + CTA gradient; khung bó 375 khi rộng.
- [ ] Giải thích được: `Expanded` ở `_MenuBody`, `stretch` ở body `Column`,
      `flex` trong thanh EXP, `flex:1` trong stats row.
- [ ] Bấm chưa làm gì — và bạn biết [M03](/m03/) sẽ sửa đúng điều đó.
