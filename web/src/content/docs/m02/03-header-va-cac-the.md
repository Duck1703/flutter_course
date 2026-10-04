---
title: "Bài 3 · Header hồ sơ & các thẻ đầu tiên"
description: "Row, Expanded, Container + BoxDecoration, Icon, widget private có tham số — xây header và hai thẻ đầu của menu."
sidebar:
  label: "Bài 3 · Header & thẻ đầu"
  order: 3
---

## Mục tiêu

Sau bài này menu có header thật (avatar tròn + tên + icon), thẻ cấp độ với
thanh tiến trình, và thẻ tổng thưởng gradient — bạn sẽ thành thạo
`Row`/`Expanded`/`Container`/`BoxDecoration` và viết được widget private nhận
tham số.

## Bạn đang ở đâu

- Milestone: **M02** (bài 3/4)
- App hiện tại: `MenuScreen` khung ba vùng với placeholder màu
  (`_ProfileHeader`, `_MenuBody`, `_PlayButton`).

## Vì sao việc này quan trọng ngay bây giờ

Placeholder chứng minh layout chia đúng ba vùng — giờ là lúc "đổ thịt". Header
là bài tập `Row` hoàn hảo: ba phần tử ngang, phần giữa giãn hết chỗ còn lại.
Hai thẻ đầu rồi sẽ cho bạn thấy pattern `Container + BoxDecoration` lặp lại —
đó là "khối card" của cả app senior.

## Bạn đã biết gì

- Column + constraint flow (bài 1); `SafeArea`/`ConstrainedBox`/`Container` +
  `BoxDecoration` + gradient + `MenuTokens` (bài 2).
- `final` field + `required` named param đã giới thiệu bài 1 — hôm nay dùng
  thật.

## Mental model mới

**`Row`/`Column` là widget *chia trục chính*.** Trong `Row` (trục chính ngang):
các con cố định lấy chỗ của chúng trước, `Expanded` ăn **phần còn lại** — đó
là quy tắc duy nhất cần nhớ của hôm nay. `flex` trên `Expanded` chia phần còn
lại theo tỉ lệ (3:7 nghĩa là 30%/70%).

Và **widget private `_Foo` chỉ sống trong file**: khi widget chỉ phục vụ một
màn hình, giữ nó private trong cùng file — file vẫn là "một màn hình", không
ai import nhầm. App senior tách card ra file riêng vì codebase lớn; ở quy mô
hiện tại, private trong-file là đủ và sạch hơn cho bài học.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `final` field | `final IconData icon;` | Field bất biến của widget — widget không đổi sau khi tạo |
| `required this.icon` | `const _IconBadge({required this.icon})` | Named param bắt buộc; `this.icon` gán thẳng vào field |
| `bool`/`int` literal | `44`, `2` | Dart tự suy `int`/`double` (`44.0` khi cần `double`) |

## Flutter cần dùng

| API | Vai trò |
|-----|---------|
| `Row` | Xếp `children` ngang; trục chính = ngang |
| `Expanded` (trong Row) | Con chiếm **bề rộng còn lại**; `flex:` chia tỉ lệ |
| `Spacer` | Expanded rỗng — đẩy phần tử hai đầu ra xa nhau |
| `Icon` + `Icons.*` | Icon Material — `size`, `color` |
| `Padding` + `EdgeInsets` | Khoảng đệm: `all`, `symmetric(h/v)`, `fromLTRB` |
| `SizedBox` | Hộp cố định — dùng làm *khoảng cách* `width`/`height` |
| `Border.all` + `BoxShape.circle` | Viền; hình tròn cho decoration |
| `CrossAxisAlignment.start` | Canh trục chéo về đầu (Row → trên; Column → trái) |

## Cầu nối Android / Compose

- SIMILARITY: `Row`/`Expanded` ≈ `Row` + `Modifier.weight(1f)`; `Spacer` ≈
  `Spacer(Modifier.weight(1f))`; `SizedBox(width: 12)` ≈ `Spacer(Modifier.width(12.dp))`.
- IMPORTANT DIFFERENCE: `Expanded`/`Spacer` phải là **con trực tiếp** của
  Row/Column — không phải modifier gắn lên con. `BoxDecoration` ≈ phần
  `background(border = …)` + `clip` gộp lại, nhưng là *tham số của Container*,
  không phải chain.
- DO NOT ASSUME: `Icon` tự biết kích thước — nó cần `size:`; và `Padding` là
  widget chứ không phải `Modifier.padding` — bọc hay không bọc quyết định
  padding nằm đâu.

## Trong project senior

- File: `flutter-accelerator-ai/lib/widgets/menu/profile/menu_profile_header.dart`
  — `Row[ Expanded(pill[avatar+name+status]) , GlassIconButton(gear) ]`: đúng
  hình dáng header ta đang xây (senior bọc thêm `Semantics`, gradient glass,
  avatar thật — đơn giản hoá ở đây).
- File: `flutter-accelerator-ai/lib/widgets/menu/profile/level_progress_card.dart`
  — thẻ EXP của senior; ta xây bản đơn giản: nhãn + thanh hai đoạn.
- File: `flutter-accelerator-ai/lib/widgets/menu/profile/earnings_card.dart`
  — senior vẽ coin SVG + blur + gradient; ta chỉ giữ "label + số tiền trên
  nền gradient".

## Từng bước thực hiện

### Bước 1 — Widget private nhận tham số: `_IconBadge`

Trong `lib/screens/menu_screen.dart`, **thay** `_ProfileHeader` placeholder
bằng hai class sau (header + icon badge nó dùng):

```dart
// lib/screens/menu_screen.dart — thay placeholder _ProfileHeader
/// Hàng header: avatar tròn + tên người chơi + icon cài đặt.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MenuTokens.spacingMd,
        vertical: MenuTokens.spacingXs,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MenuTokens.accentYellow, width: 2),
            ),
            child: const Icon(Icons.person, color: MenuTokens.textPrimary),
          ),
          const SizedBox(width: MenuTokens.spacingSm),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Khách',
                  style: TextStyle(
                    color: MenuTokens.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tiến trình lưu trên máy',
                  style: TextStyle(
                    color: MenuTokens.accentYellow,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const _IconBadge(icon: Icons.settings),
        ],
      ),
    );
  }
}

/// Icon tròn có viền — dùng cho nút cài đặt trong header.
class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MenuTokens.spacingXs),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: MenuTokens.cardBorder),
        color: MenuTokens.cardBackground,
      ),
      child: Icon(icon, size: 20, color: MenuTokens.textPrimary),
    );
  }
}
```

Cú pháp mới cần đọc kỹ:

- `final IconData icon;` + `const _IconBadge({required this.icon})` — field
  `final` được gán qua `this.icon` ngay trong constructor; `required` bắt
  caller phải truyền. Đây là cách widget nhận "props".
- `Padding(padding: EdgeInsets.symmetric(horizontal:, vertical:))` — đệm khác
  nhau hai chiều; `Padding` là widget bọc `Row`.
- `Row[ avatarContainer , SizedBox , Expanded(nameColumn) , _IconBadge ]` —
  avatar 44 và badge cố định, `Expanded` cho cột chữ ăn phần giữa còn lại →
  badge bị đẩy sát phải.
- `shape: BoxShape.circle` trên `BoxDecoration` — hộp thành hình tròn (viền
  `Border.all` theo luôn hình tròn).
- `Column(crossAxisAlignment: start, mainAxisSize: min)` trong `Expanded` —
  hai dòng chữ bám trái; `min` để cột chỉ cao vừa chữ (đã học ở bài 1).
- `Icon(Icons.settings)` — icon Material; `Icons.<name>` là hằng `IconData`.

`flutter analyze` — sạch; reload → header thật thay placeholder.

### Bước 2 — `_MenuBody`: cột thẻ canh giữa

**Thay** `_MenuBody` placeholder bằng:

```dart
// lib/screens/menu_screen.dart — thay placeholder _MenuBody
/// Khối giữa màn hình: các thẻ thông tin xếp dọc, nằm giữa header và nút chơi.
class _MenuBody extends StatelessWidget {
  const _MenuBody();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: MenuTokens.spacingMd),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LevelCard(),
            SizedBox(height: MenuTokens.spacingSm),
            _EarningsCard(),
          ],
        ),
      ),
    );
  }
}
```

- `Center` trong vùng `Expanded` → khối thẻ **nằm giữa** khoảng trống giữa
  header và nút (giống senior centering content).
- `crossAxisAlignment: CrossAxisAlignment.stretch` — mọi card **giãn hết bề
  ngang** khung (343px = 375 − 2×16 padding). Không cần set width từng card.
- `mainAxisSize: min` — cột chỉ cao vừa các thẻ, phần thừa là của `Center`
  xung quanh — chính vì vậy `mainAxisAlignment` không cần thiết.
- Bài 4 sẽ **thêm** `_LeaderboardEntry` + `_StatsRow` vào list này — cố tình
  để list ngắn trước để mỗi bài một phần.
- `const Padding(...)` — toàn bộ con đều const được.

### Bước 3 — `_LevelCard`: nhãn + thanh tiến trình

Thêm vào cuối file:

```dart
// lib/screens/menu_screen.dart — thêm cuối file
/// Thẻ cấp độ: tên cấp, điểm EXP và thanh tiến trình.
class _LevelCard extends StatelessWidget {
  const _LevelCard();

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
          const Row(
            children: [
              Text(
                'CẤP 1',
                style: TextStyle(
                  color: MenuTokens.accentCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                '120 / 400 EXP',
                style: TextStyle(
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
                flex: 3,
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
                flex: 7,
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

- `Spacer()` — `Expanded` không child: đẩy "CẤP 1" trái và "120 / 400 EXP"
  phải trong một `Row`.
- `Expanded(flex: 3)` + `Expanded(flex: 7)` — hai đoạn thanh chia phần rộng
  còn lại (sau `SizedBox(width: 4)`) theo tỉ lệ 3:7 → **thanh tiến trình 30%**
  mà không cần đo pixel.
- `borderRadius: BorderRadius.circular(16)` / `(999)` — bo góc card / bo hẳn
  thành viên thuốc (pill).
- Vì sao *không* dùng `LinearProgressIndicator`? — Có thể, nhưng thanh hai
  `Expanded` cho thấy rõ quy tắc chia trục chính; đó là bài tập của bài này.

### Bước 4 — `_EarningsCard`: nền gradient

Thêm tiếp cuối file:

```dart
// lib/screens/menu_screen.dart — thêm cuối file
/// Thẻ tổng tiền thưởng — nổi bật nhất nhóm thẻ nhờ nền gradient.
class _EarningsCard extends StatelessWidget {
  const _EarningsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MenuTokens.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MenuTokens.radiusCard),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MenuTokens.earningsTop, MenuTokens.earningsBottom],
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TỔNG THƯỞNG',
            style: TextStyle(
              color: MenuTokens.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '0 VNĐ',
            style: TextStyle(
              color: MenuTokens.accentYellow,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```

- Cùng một pattern `Container + padding + decoration` — khác bài trước chỉ là
  `gradient:` thay `color:` (về ý đồ nên chọn **một nền**: dùng cả hai vẫn
  hợp lệ nhưng `gradient` vẽ đè `color` — chi tiết ở mục lỗi hay gặp; nếu
  cần viền hãy thêm `border:`).
- `letterSpacing` trong `TextStyle` — giãn cách chữ cho nhãn dạng "label".
- `const Column(...)` — con chữ toàn const được → `const` trọn cột.

`flutter analyze` sạch; reload → menu có header + hai thẻ (level + earnings)
giữa màn hình, nút placeholder tím dưới đáy.

## Đọc hiểu code

`Row` trong header xử lý như thế này (theo đúng constraint flow):

```
Row được cha cho "rộng 0..343"
→ các con cố định tự chọn: avatar 44, SizedBox 12, badge ~36
→ Expanded nhận phần CÒN LẠI (~251) → truyền cho Column con
→ Column con stretch? Không — Expanded trong Row chỉ ép theo
  trục NGANG; trục dọc Row để con tự chọn (cao theo chữ)
```

Và `_MenuBody`: `Center` lỏng constraint → `Column(stretch)` ép con rộng theo
bề ngang khả dụng → mỗi card tự cao, rộng 343.

## Chạy và quan sát

- Chạy: `flutter run -d chrome` → `r` sau mỗi bước.
- Kỳ vọng: header trên cùng (avatar viền vàng, "Khách", icon bánh răng trong
  vòng tròn); giữa màn hình hai thẻ stretch hết khung; đáy vẫn là dải tím
  placeholder.
- Nếu `Expanded` trong `_MenuBody` báo lỗi → kiểm tra nó nằm trong `Row`
  hay `Column` hợp lệ.

## Lỗi thường gặp

1. **Quên `Expanded` cho phần giữa Row** — `Column` hai `Text` tự ôm chữ;
   badge đứng ngay sau chữ thay vì sát phải, và text dài tràn ra ngoài.
   `Expanded`/`Flexible` là cách "xin phần còn lại" — bắt buộc khi muốn chống
   overflow.
2. **`color:` và `gradient:` cùng trong một `BoxDecoration`** — hợp lệ,
   không lỗi: `gradient` được vẽ **đè lên** `color` (color là nền bên dưới).
   Về ý đồ thiết kế nên chọn một nền; dùng cả hai chỉ hợp lý khi cố ý để
   `color` lót dưới phần trong suốt của gradient.
3. **`const` kẹt vì param runtime** — `Container(color: widget.x)` không const
   được khi `x` là field; bỏ `const` ở ngoài cùng đủ.
4. **`BorderRadius.circular` không const** — nhớ pattern: `decoration:` non-const
   nhưng phần trong có thể `const` từng mảnh.

## Kiểm tra hiểu biết

1. `Expanded` và `Spacer` khác nhau gì? — Spacer là Expanded rỗng (không con);
   Expanded nhận `child` để chiếm phần còn lại.
2. Vì sao thanh tiến trình dùng hai `Expanded(flex:)`? — flex chia phần rộng
   còn lại theo tỉ lệ: 3:7 ≈ 30%/70% mà không cần đo kích thước.
3. `crossAxisAlignment: stretch` trong `Column` làm gì? — Ép mọi con bằng bề
   ngang của Column (≈ `match_parent` ngang), không cần set width từng card.
4. Micro-task: đổi `flex` thành 5:5 — thanh tiến trình thành 50%. Predict
   trước khi reload.

## Tự làm (PRODUCE)

Thêm một thẻ mới `_StreakCard` vào `_MenuBody` — hiển thị nhãn
`'CHUỖI NGÀY'` và số `'0 ngày'`, phong cách giống `_LevelCard` (nền
`cardBackground`, bo góc `radiusCard`, viền `cardBorder`). **Không copy
y nguyên `_LevelCard`** — trước khi viết, tự quyết:

1. `_StreakCard` đứng **trước hay sau** `_EarningsCard` trong `children`?
   Chọn một thứ tự và bảo vệ nó bằng một lý do thiết kế (ví dụ: thẻ nào
   đáng đọc trước?).
2. `SizedBox(height: spacingSm)` cần thêm ở đâu — trước, sau, hay giữa
   các thẻ?
3. `crossAxisAlignment: stretch` của `Column` cha có cần đổi không để
   thẻ mới giãn hết khung như hai thẻ kia?

Viết widget (khoảng 25–30 dòng, chỉ dùng API đã xuất hiện trong bài),
thêm vào `children` của `_MenuBody`, `flutter analyze` sạch, reload và
quan sát ba thẻ.

:::note[Gợi ý]
`_LevelCard` cho bạn "khối card" hoàn chỉnh: `Container(padding:,
decoration:) > Column(min, start) > [Text nhãn, SizedBox, Text nội
dung]`. Thẻ của bạn đơn giản hơn — không cần `Row`/`Spacer`/thanh flex.
:::

<details><summary><strong>Đáp án</strong></summary>

Một cách hợp lệ (cách khác cũng chấp nhận nếu bảo vệ được):

```dart
/// Thẻ chuỗi ngày chơi liên tiếp.
class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MenuTokens.spacingMd),
      decoration: BoxDecoration(
        color: MenuTokens.cardBackground,
        borderRadius: BorderRadius.circular(MenuTokens.radiusCard),
        border: Border.all(color: MenuTokens.cardBorder),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHUỖI NGÀY',
            style: TextStyle(
              color: MenuTokens.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '0 ngày',
            style: TextStyle(
              color: MenuTokens.accentCyan,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```

Và trong `children` của `_MenuBody` (đặt sau `_EarningsCard` — thẻ "ít
quan trọng nhất" đứng cuối, giống hệ senior xếp thẻ phụ dưới thẻ chính):

```dart
_LevelCard(),
SizedBox(height: MenuTokens.spacingSm),
_EarningsCard(),
SizedBox(height: MenuTokens.spacingSm),   // khoảng mới
_StreakCard(),
```

- (1) Thứ tự là *quyết định thiết kế*: giữ thẻ nổi bật (gradient) trên,
  thẻ phụ dưới — cách khác chấp nhận nếu nêu được lý do.
- (2) `SizedBox` đi **giữa** các thẻ — nó là con của cùng `Column`, là
  "khoảng trống" chứ không phải margin của card (Flutter không có
  margin ngoài Container).
- (3) **Không cần đổi** — `stretch` ép mọi con theo bề ngang cột; thẻ
  mới tự giãn 343 như các thẻ khác.

Điều bài tập kiểm tra: bạn tái sử dụng được pattern card *với những
quyết định của riêng mình* (thứ tự, khoảng cách, màu nhấn) — đây là lần
đầu bạn sản xuất một widget UI đầy đủ không theo bản mẫu từng dòng.
</details>

## Cố ý chưa làm

- `GestureDetector`/`onTap` cho badge — M03 (bấm vào chưa làm gì là cố ý).
- `Image.asset`/avatar thật — M28 assets/SVG.
- `LinearProgressIndicator` — ta tự xếp thanh để luyện `flex`.
- Hai card còn lại (`_LeaderboardEntry`, `_StatsRow`) — bài 4.
- `ListView`/scroll — chưa có nội dung tràn; sẽ cần nếu bảng xếp hạng dài
  (M23).

## Điểm kiểm tra hoàn thành

- [ ] Header hiển thị avatar tròn, "Khách", caption vàng, badge bánh răng.
- [ ] `_LevelCard` có nhãn + EXP + thanh 30/70; `_EarningsCard` nền gradient.
- [ ] Không còn `Container` placeholder ở header/body (nút vẫn placeholder).
- [ ] `flutter analyze` → `No issues found!`.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m02/03 — "Header hồ sơ & các thẻ đầu tiên".

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Chấm hình dáng layout, không chấm đẹp/xấu pixel.

EXPECTED STATE SAU BÀI NÀY (tất cả trong `lib/screens/menu_screen.dart`):
- `_ProfileHeader` là header THẬT: `Padding` bọc `Row` gồm [container avatar tròn có viền + `Icon`, `SizedBox` ngang, `Expanded` chứa `Column` hai `Text` (tên + caption phụ, canh `start`), `_IconBadge` cuối hàng] — `Expanded` là điểm bắt buộc để badge bám phải.
- `class _IconBadge` private tồn tại với `final IconData icon` + `required this.icon` trong constructor (STRICT — đây là pattern widget-nhận-param bài kiểm tra).
- `_MenuBody` là `Padding > Center > Column(mainAxisSize: min, crossAxisAlignment: stretch)` chứa [ `_LevelCard()`, `SizedBox`, `_EarningsCard()` ] — `stretch` để các thẻ giãn hết khung.
- `_LevelCard` hiển thị nhãn cấp + số EXP + thanh tiến trình hai đoạn `Expanded(flex: 3)`/`Expanded(flex: 7)` (STRICT tỉ lệ 3:7 — đó là sản phẩm của bài; label/text cụ thể semantic).
- `_EarningsCard` là `Container` có `gradient:` trong `BoxDecoration` với nhãn + số tiền.
- `_PlayButton` VẪN là placeholder màu ở đáy — chưa đổ thịt là cố ý, không lỗi.
- Nếu learner làm bài Tự làm: một `_StreakCard` có thể nằm thêm trong `children` của `_MenuBody` — có hay không đều chấp nhận; nếu có thì nó là `Container + decoration` cùng pattern và có `SizedBox` phân cách.
- `flutter analyze` → "No issues found!".

INVARIANTS NỀN:
- Khung bọc của `MenuScreen` (gradient → SafeArea → Center → ConstrainedBox 375 → Column ba vùng) còn nguyên; `MenuTokens`/`main.dart` không đổi.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`/`AHEAD_RISKY`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m02/03
PROJECT_ALIGNMENT: ON_TRACK | NEEDS_FIX | DIVERGED | BLOCKED
COURSE_POSITION: ON_TRACK | BEHIND | AHEAD_COMPATIBLE | AHEAD_RISKY
READY_FOR_NEXT_LESSON: YES | YES_AFTER_FIXES | NO
VERIFICATION_PERFORMED:
WHAT_MATCHES:
GAPS:
AHEAD_OF_COURSE:
DIVERGENCES:
REQUIRED_FIXES_BEFORE_CONTINUING:
EVIDENCE: file/symbol → observation
FILES_MODIFIED_BY_REVIEW: NONE
```
