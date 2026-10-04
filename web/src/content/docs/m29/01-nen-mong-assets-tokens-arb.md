---
title: "Bài 01 — Nền móng đủ: 50 asset, `AppAssets`/`OnboardingTokens` verbatim, l10n đồng bộ"
description: "Trước khi sửa bất kỳ pixel nào, sweep cuối bắt đầu bằng nền móng: ship đủ 50 file `assets/images/` của senior; `app_assets.dart` verbatim 45 const (kể cả ~10 const senior ship nhưng không reference — byte-parity); `onboarding_design_tokens.dart` verbatim (`OnboardingTokens` delegate→`AppTokens`, không redeclare literal); +11 ARB key senior, −2 dead key learner; `gen-l10n` regen. Mental model mới: quy trình đối chiếu senior — đọc → diff → port → verify. +0 test: 309/309."
sidebar:
  order: 1
  label: Nền móng assets/tokens/l10n
---

# Bài 01 — Nền móng đủ: assets, tokens, l10n đồng bộ senior

## Mục tiêu

Sau bài này bạn sẽ:

- Hiểu vì sao một "senior-alignment sweep" phải bắt đầu ở
  **nền móng** (asset, token, l10n) trước khi đụng vào bất kỳ
  widget nào — nếu nền còn thiếu, mọi file UI port sau đó sẽ
  thiếu tham chiếu và build đỏ.
- Nắm được **quy trình đối chiếu senior **: đọc file
  senior → `diff` → port verbatim (sau rename + comment VI) →
  verify bằng `analyze`/`test`/`grep` — và áp dụng nó cho cả
  asset file lẫn file Dart.
- Biết vì sao `app_assets.dart` được port **verbatim gồm cả
  ~10 const mà senior không tham chiếu**: mục tiêu không phải
  "vừa đủ dùng" mà là **byte-parity** — learner và senior nhìn
  cùng một catalogue.
- Thấy được mẫu **token-delegate**: `OnboardingTokens` chỉ định
  nghĩa giá trị thật sự riêng; giá trị nào đã có ở `AppTokens`
  thì `static const x = AppTokens.y` — một literal chỉ sống ở
 một nơi.
- Biết cộng/trừ ARB key có kỷ luật: **+11 key senior** (menu
  level + settings chrome), **−2 dead key learner**
  (`questionCounter`, `gameRoomTitle` — zero usage), regen
  `gen-l10n` để generated code đồng bộ.

## Bạn đang ở đâu

Sau M28 app đã đẹp ở phần **game** — nhưng nhìn vào nền móng
thì chưa đồng bộ:

```text
learner assets/images/          ~30 file (game-side đã đủ)
senior  assets/images/          50 file — còn thiếu avatar/,
                                 leaderboard/, icons menu,
                                 decorations phụ, launcher icon

learner lib/core/app_assets.dart  subset — chỉ const cho
                                 file game đã ship
senior  lib/core/app_assets.dart 45 const verbatim

learner lib/core/               KHÔNG có onboarding_design_tokens.dart
senior  lib/core/onboarding_design_tokens.dart  84 dòng —
                                 widget onboarding/settings vẫn
                                 literal màu mỗi nơi một kiểu

learner lib/l10n/app_*.arb      110 key — thiếu 11 key menu/settings
senior  lib/l10n/app_*.arb      119 key; learner còn 2 key chết
                                 senior không có
```

Vấn đề không chỉ là "thiếu file". Từ Bài 02 trở đi, mỗi file UI
senior port về đều **tham chiếu** `AppAssets.iconBellNotification`,
`OnboardingTokens.buttonGlow`, `l10n.menuLevelShort`... Nếu nền
móng chưa đủ, mỗi lần port bạn lại phải dừng lại vá thiếu — và
mỗi lần vá là một cơ hội trôi so với senior. Bài này vá nền
**một lần, trọn vẹn**: 50 asset đủ, `AppAssets` verbatim,
`OnboardingTokens` verbatim, ARB đồng bộ.

## Vì sao việc này quan trọng ngay bây giờ

Đây là bài duy nhất trong milestone **không thêm test**
(+0: 309→309) — và đó là đặc điểm, không phải lỗi. Nền móng
là file *được tham chiếu*: nó không có hành vi để test riêng;
hành vi của nó được test *gián tiếp* qua widget dùng nó ở các
bài sau. Nếu bài này làm đúng, các bài 02–07 port được verbatim
mà không cần một dòng vá. Nếu bài này làm ẩu — bỏ sót một
avatar PNG, thiếu một const — lỗi sẽ hiện muộn ở Bài 03–06
dưới dạng "asset not found" hoặc "getters không tồn tại", rất
khó lần ngược.

## Bạn đã biết gì

Bạn **không cần** ôn lại — nhưng bài này đứng trên vai của:

| Đã học | Ở đâu | Nhắc ngắn |
|---|---|---|
| Design tokens là nguồn sự thật duy nhất | M28·01 | `AppTokens` chứa mọi literal visual; widget không tự viết `Color(0xFF…)` |
| Teaching-scaffold lifecycle | M12 trở đi | Interim code (subset `AppAssets` "vừa đủ") có vòng đời: xuất hiện → phục vụ → retire khi full-version đến |
| ARB file = nguồn sự thật localization | M17 | Key/placeholder/metadata sống ở `app_en.arb`/`app_vi.arb`; `AppLocalizations` là *generated* — sửa ARB xong phải `flutter gen-l10n` regen, không sửa tay |
| `AppLocalizations.of(context)` | M17 | Widget đọc chữ qua accessor generated — key mới chỉ dùng được sau khi regen |
| `static const` catalogue | M01, M03 | `AppAssets` là class chỉ chứa const — path tập trung, typo = compile error thay vì runtime "asset not found" |
| dead-key hygiene | M23·07 | Key không còn ai dùng phải được xoá — nếu không ARB phình và 2 ngôn ngữ lệch nhau (grep zero-usage trước khi xoá) |

## Mental model mới — "đọc → diff → port verbatim → verify" (NORMAL)

Toàn bộ milestone này xoay quanh **một quy trình** lặp lại cho
mọi file:

```text
1. READ   mở file senior, đọc hết — không skim
2. DIFF   so với bản learner (nếu có) hoặc xác nhận "chưa có"
3. PORT   chép verbatim — chỉ đổi:
            - tên project trong import/comment (rename contract)
            - doc-comment → VI (course policy)
          KHÔNG "cải tiến" — đây không phải lúc refactor
4. VERIFY flutter analyze + flutter test + grep cho
          identifier cũ / API đã retire
```

:::note[Điểm mới so với mọi milestone trước]
Từ M12–M28, learner *xây* thứ mới: mỗi bài là "đây là vấn đề,
đây là pattern giải quyết". M29 khác: **bản thiết kế đã có sẵn**
(chính là senior). Việc của bạn không còn là quyết định "dùng
pattern gì" mà là **đối chiếu có kỷ luật** — và cái khó nhất
là cưỡng lại ý muốn "cải tiến cho hay hơn senior". Trong một
sweep, *khác so với senior* = divergence = phải documented và
converge sau; chỉ các deviation đã liệt kê (dart2js bound,
product rename, test seam, `final class` convention) được giữ.
:::

```text
DIFF có 3 kết quả:

  identical        → ghi "verified parity", không đụng
  differs          → 2 nhánh:
      learner tốt hơn?  → vẫn port senior (verbatim là mặc định);
                          nếu thật sự tin learner tốt hơn → đó là
                          DECISION, documented trong evidence,
                          không phải chỉnh lén
      learner thiếu?    → port verbatim phần thiếu
  learner-only      → 2 nhánh:
      dead code (zero usage) → xoá (REMOVED)
      chức năng senior không có → DECISION: giữ & document
                                  hoặc xoá
```

Mental model phụ của bài này: **"catalogue phải byte-parity"**.
`AppAssets` không phải kiểu "thêm const khi cần" — nó là danh
mục tài nguyên của app; senior liệt kê 45 const kể cả ~10 const
trỏ tới file senior ship nhưng không dùng (icon `cart.svg`,
`gamepad*.svg`, `trophy-detail-*.svg`... — dự phòng cho feature
tương lai). Ship nguyên catalogue có nghĩa: về sau, mọi file
senior nào dùng asset ấy đều port được ngay, không cần quay
lại vá `app_assets.dart`.

## Dart cần dùng

| Dart | Vai trò ở đây | Xem lại |
|---|---|---|
| `static const String x = '...'` | `AppAssets` catalogue — path là compile-time const | |
| `static const X = OtherClass.y` | **Const-delegate**: `OnboardingTokens.grey600 = AppTokens.qzdsBlack600` — alias không copy literal | mới tại đây |
| `static X get y => ...` | Token động (TextStyle/Gradient/Decoration) — getter vì không const được | |
| `dart format`, `dart analyze` | Verify sau port | đã dùng |

## Flutter cần dùng

| Flutter | Vai trò ở đây | Xem lại |
|---|---|---|
| `assets:` section trong `pubspec.yaml` | Khai báo theo **thư mục** — 5 dòng đã đủ cho 50 file | đã có từ M14 |
| `AssetImage`/`Image.asset`/`SvgPicture.asset` | Đọc asset qua `AppAssets.*` const | từ M28 |
| `flutter gen-l10n` | Regen `lib/l10n/*.dart` sau khi sửa ARB | |

## Ví dụ độc lập — delegate-token không copy literal

```dart
/// VÍ DỤ ĐỘC LẬP — DartPad chạy được.
/// Mô phỏng OnboardingTokens delegate→AppTokens.
class AppTokens {
  static const int black600Value = 0xFF424242; // demo: dùng int cho gọn
  static const int purple500 = 0xFF7C4DFF;
}

/// Sai: copy literal — hai nơi giữ một giá trị, đổi một quên hai.
class BadOnboardingTokens {
  static const int grey600 = 0xFF424242; // trùng AppTokens.black600Value
}

/// Đúng: alias về nguồn — đổi AppTokens là đổi khắp nơi.
class OnboardingTokens {
  static const int grey600 = AppTokens.black600Value;
  static const int blue500 = AppTokens.purple500;
}

void main() {
  print(OnboardingTokens.grey600 == AppTokens.black600Value); // true
  // identical thật sự — một nguồn:
  print(identical(OnboardingTokens.blue500, AppTokens.purple500)); // true
}
```

## Android / Compose bridge

:::note[Android / Compose bridge — "module resource parity"]
- **SIMILARITY**: `AppAssets` verbatim-45-const giống việc đồng
  bộ `res/` của hai module — bạn copy cả thư mục drawable kể cả
  file chưa ai dùng, vì resource catalogue là contract của
  module, không phải "vừa đủ dùng".
- **IMPORTANT DIFFERENCE**: `static const x = AppTokens.y` là
  **alias compile-time**, không phải value copy — trong Kotlin
  tương đương `const val GREY_600 = AppTokens.QZDS_BLACK_600`
  (delegate), KHÔNG phải `0xFF424242` gõ lại.
- **DO NOT ASSUME**: đừng cho rằng "const không ai dùng = dead
  code nên xoá". Trong resource catalogue, const-unused là
  contract — analyzer không flag, và byte-parity với senior là
  mục tiêu có chủ đích.
:::

## Senior project connection

| File senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `assets/images/**` (50 file, 5 dir) | nguồn copy — `pubspec.yaml` khai theo dir nên không cần sửa pubspec |
| `lib/core/app_assets.dart` | **verbatim** — 45 `static const`, kể cả ~10 const senior không reference |
| `lib/core/onboarding_design_tokens.dart` | **verbatim** — delegate→`AppTokens` mẫu hoàn chỉnh |
| `lib/l10n/app_en.arb`/`app_vi.arb` | nguồn +11 key; learner trừ 2 dead key |

:::tip[Suy ra trước — chạy mini "đọc→diff→port→verify" trên một file]
Quy trình ở mental model chỉ có giá trị nếu bạn *vận hành* nó — chạy
trước một vòng mini trên `app_assets.dart`, không cần mở repo senior:

1. **Đọc.** `AppAssets` hiện có 8 const. Dự đoán senior có bao
   nhiêu — và *vì sao đoán thế*? (Gợi ý: đếm asset dir đã khai báo
   trong `pubspec.yaml`, mỗi file asset cần một const).
2. **Diff.** Nếu senior có 45 const còn learner 8: nêu ra cách phân
   loại 37 const thiếu — (a) widget bạn sẽ dùng ở bài sau, (b) const
   senior ship mà *không file nào tham chiếu*. Có nên bỏ qua (b)
   không? Viện dẫn một rủi ro cụ thể của "port chọn lọc".
3. **Port.** Viết signature/const cho *một* entry bạn tự chọn — trước
   khi xem bản verbatim.
4. **Verify.** Bạn sẽ kiểm chứng parity bằng gì — đếm const, diff
   path, hay build? Nêu *một* kiểm chứng bạn sẽ chạy sau Bước 3.
:::
## Build it step by step

### Bước 1 — Diff nền móng trước khi đụng vào code

Sweep mở đầu bằng đo lường, không bằng code:

```bash
# Diff toàn bộ cây asset
diff -rq ../flutter-accelerator-ai/assets/images assets/images

# Diff catalogue const
diff ../flutter-accelerator-ai/lib/core/app_assets.dart \
     lib/core/app_assets.dart

# Đếm ARB key
grep -cE '^\s*"[^@"]+":' ../flutter-accelerator-ai/lib/l10n/app_en.arb
grep -cE '^\s*"[^@"]+":' lib/l10n/app_en.arb
```

:::tip[Quy tắc sweep: đo trước, vá sau]
Không port từ cảm giác "chắc thiếu". `diff -rq` cho kết quả
khách quan: file nào senior có learner không, file nào khác
byte. Danh sách đó là *work order* — không phải trí nhớ.
:::

### Bước 2 — Copy đủ 50 file asset (5 thư mục)

```bash
cp -r ../flutter-accelerator-ai/assets/images/* assets/images/
diff -rq ../flutter-accelerator-ai/assets/images assets/images
# → không output = byte-parity
```

`pubspec.yaml` **không đổi** — nó đã khai theo thư mục:

```yaml
# learner-app/pubspec.yaml
  assets:
    - assets/images/backgrounds/
    - assets/images/avatars/
    - assets/images/icons/
    - assets/images/decorations/
    - assets/images/leaderboard/
```

Đây là lý do senior khai `dir/` thay vì từng file: thêm asset
chỉ cần thả file vào đúng thư mục — không đụng pubspec. Năm
thư mục mới có thật sự ở batch này: `avatars/` (avatar mặc
định) và `leaderboard/` (medal SVG, score coin, 7 avatar PNG,
current-user accent) — chuẩn bị cho Bài 03.

### Bước 3 — `app_assets.dart` verbatim, cả const "không ai dùng"

```dart
// learner-app/lib/core/app_assets.dart (trích — 45 const, file verbatim)
class AppAssets {
  static const String menuBackground =
      'assets/images/backgrounds/menu-background.png';
  static const String avatar = 'assets/images/avatars/avatar.png';
  static const String iconTrophy = 'assets/images/icons/trophy.svg';
  // ... iconSpeaker/iconMusic/iconVibration/
  //     iconBellNotification/iconFilter/iconLevelRank ...
  static const String leaderboardRank1 =
      'assets/images/leaderboard/medal-gold.svg';
  static const String avatarTauHuDiChill =
      'assets/images/leaderboard/avatar-tau-hu-di-chill.png';
  // 45 const tổng cộng
}
```

:::caution[Nhìn kỹ: ~10 const senior không tham chiếu]
`iconCart`, `coinMid`, `gamepad`, `gamepadDetail`, `trophyDeco`,
`trophyDetail1/2/3`, `trophyVector`, `leaderboardCurrentAccent`
— grep toàn senior `lib/` không một chỗ dùng. Đây là asset
dự phòng senior ship sẵn. Sweep **vẫn port verbatim**: catalogue
là contract, byte-parity là mục tiêu; quyết định "dùng hay
không" là của senior, không phải của sweep. Đây là ví dụ đầu
 tiên của kỷ luật sweep: *verbatim là mặc định, mọi "tối ưu hoá" cá nhân
là divergence*.
:::

### Bước 4 — `onboarding_design_tokens.dart` verbatim

```dart
// learner-app/lib/core/onboarding_design_tokens.dart (trích)
class OnboardingTokens {
  static const double buttonHeightLarge = 48;
  static const double badgeSize = 64;
  static const double indicatorActiveWidth = 24;

  static const Color grey600 = AppTokens.qzdsBlack600;
  static const Color blue500 = AppTokens.blue500;
  static const Color blue100 = Color(0xFFAEBFFD);   // chỉ-onboarding
  static const Color purple500 = AppTokens.qzdsPurple500;
  static const Color accentGreen500 = Color(0xFF4CAF50); // step-accent

  static TextStyle get body1 => GoogleFonts.beVietnamPro(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}
```

Đọc kỹ doc-comment đầu file (verbatim senior):

> *"Values that also exist as app foundations reference
> `AppTokens` instead of redeclaring the literal; only
> genuinely onboarding-specific values are defined here."*

Đây chính là phiên bản "nhiều file token": một dự án có
thể có 2 token class, nhưng **mỗi giá trị vẫn chỉ sống ở một
nơi** — `OnboardingTokens` là *view* chuyên ngành nhìn vào
`AppTokens`, không phải nguồn thứ hai.

### Bước 5 — ARB: +11 key senior, −2 dead key, regen

```text
THÊM (senior có, learner thiếu):
  closeButton, saveButton, languageSetting,
  hourPickerSemanticLabel, minutePickerSemanticLabel,
  settingsIconSemanticLabel {label},
  menuLevelShort, menuExperienceLabel, menuExpToNextLevel {exp,level},
  menuMaxLevelReached, menuLeaderboardEntrySubtitle

XOÁ (learner-only, zero usage — dead):
  questionCounter, gameRoomTitle
```

```json
// lib/l10n/app_en.arb (trích — 2 trong 11 key mới)
  "menuExpToNextLevel": "{exp} EXP to Level {level}",
  "@menuExpToNextLevel": {
    "placeholders": { "exp": {}, "level": {} }
  },
  "settingsIconSemanticLabel": "{label} icon",
  "@settingsIconSemanticLabel": {
    "placeholders": { "label": {} }
  },
```

```bash
flutter gen-l10n   # regen lib/l10n/*.dart — KHÔNG sửa tay generated
flutter analyze    # sạch
flutter test       # 309/309 — không test mới, không test hỏng
```

:::note[Vì sao +0 test là đúng, không phải thiếu]
Nền móng là *được tham chiếu*: `AppAssets`/`OnboardingTokens`/
ARB key không có hành vi riêng để test — hành vi của chúng sẽ
được test qua widget dùng chúng ở Bài 02–06. Checkpoint 309/309
nghĩa là "thêm nền mà không phá gì đang xanh" — đúng chuẩn của
một bài chuẩn bị.
:::

## Hiểu code — 6 chi tiết dễ trượt

**1. Vì sao `pubspec` không đổi dù thêm ~20 file asset?** —
Khai báo theo `dir/` (có dấu `/` cuối) nghĩa là "bundle mọi
file trong thư mục này". Senior chọn convention này ngay từ
đầu vì biết asset sẽ lớn dần. Nếu khai từng file, mỗi asset
mới = một dòng pubspec mới = một điểm quên.

**2. `static const Color grey600 = AppTokens.qzdsBlack600` —
const alias được không?** — Được. `const` cho phép vế phải là
một const khác; `OnboardingTokens.grey600` **là** `AppTokens
.qzdsBlack600`, không phải bản copy — đổi nguồn đổi khắp alias.

**3. Vì sao `body1`/`buttonGlow` là `static get` mà không phải
`static const`?** — `GoogleFonts.beVietnamPro(...)` và
`RadialGradient(...)` không phải const-constructible (GoogleFonts
lookup runtime; `surfaceGlow` là hàm). Getter trả instance mới
mỗi lần gọi — vẫn "token" vì *cấu hình* tập trung, dù *instance*
không const.

**4. Dead key xoá khỏi ARB — có cần xoá khỏi generated?** —
Không sửa tay. `gen-l10n` viết lại toàn bộ `lib/l10n/*.dart`;
key đã xoá sẽ biến mất khỏi `AppLocalizations`. Nếu code nào
còn gọi `l10n.questionCounter` → **compile error ngay** — đây
là điểm mạnh của generated-accessor: dead key thật không thể
tồn tại lén.

**5. Hai key xoá (`questionCounter`, `gameRoomTitle`) vì sao
an toàn?** — `grep` toàn `lib/` + `test/` cho zero usage trước
khi xoá. Quy tắc: dead ≠ "tôi nghĩ không ai dùng"; dead =
"grep đếm được 0 tham chiếu".

**6. Byte-parity ≠ bit-identical mọi thứ** — asset binary là
byte-parity; file Dart là "verbatim sau rename+comment-VI";
ARB là "key-parity, value có thể khác theo ngôn ngữ". Ba mức
khác nhau, cùng một nguyên tắc: *không improve lén*.

## Chạy và quan sát

```bash
cd learner-app

# 1. Asset parity check
diff -rq ../flutter-accelerator-ai/assets/images assets/images
# → im lặng = 50/50 khớp

# 2. Catalogue parity check
diff ../flutter-accelerator-ai/lib/core/app_assets.dart lib/core/app_assets.dart
# → chỉ khác comment VI (nếu có) — const list giống hệt

# 3. ARB key parity
python -c "import json;a=json.load(open('../flutter-accelerator-ai/lib/l10n/app_en.arb'));b=json.load(open('lib/l10n/app_en.arb'));print(set(k for k in a if not k.startswith('@'))-set(k for k in b if not k.startswith('@')))"
# → senior−learner trống ngay sau Bài 1; learner−senior (3 key thừa) mới trống sau Bài 7

# 4. Gates
flutter analyze && flutter test
# → clean · 309/309
```

## Thử nghiệm

| Thử | Dự đoán | Thực tế |
|---|---|---|
| Xoá `assets/images/leaderboard/medal-gold.svg`, giữ const | App crash khi nào? | Không crash lúc build — chỉ lỗi **runtime** khi widget `Image.asset`/`SvgPicture` load path đó (Bài 03 mới dùng tới). Compile-time catalogue không kiểm tra file tồn tại — đó là giá của string-path |
| Đổi `OnboardingTokens.grey600` thành literal riêng `0xFF434343` | Ai vỡ? | Không ai vỡ compile; nhưng màu hiển thị lệch 1 step so với mọi `AppTokens.qzdsBlack600` khác — "gần giống" là divergence khó phát hiện nhất. Delegate tồn tại để ngăn đúng kiểu trôi này |
| Xoá `questionCounter` khỏi ARB nhưng **không** `gen-l10n` | Analyze báo gì? | Generated `AppLocalizations` vẫn còn getter → analyze vẫn sạch → key "ma": ARB nói đã xoá, Dart vẫn expose. Regen là bước bắt buộc của mọi chỉnh ARB |

## Lỗi hay gặp

| Lỗi | Vì sao | Sửa |
|---|---|---|
| "Unable to load asset: assets/images/…" runtime | file thiếu trong `assets/` hoặc pubspec dir không cover | `diff -rq` cây asset; kiểm path const khớp tên file (case-sensitive trên CI) |
| `The getter 'menuLevelShort' isn't defined` | ARB có key nhưng quên `gen-l10n` | `flutter gen-l10n` rồi analyze lại |
| Copy asset rồi `diff -rq` vẫn báo khác | copy qua tool nén/đổi tên (Windows xử lý unicode tên file) | copy nguyên thư mục, không qua archive; kiểm `git status` thấy file thật |
| Muốn "dọn" 10 const unused khỏi `AppAssets` | nhầm catalogue-const với dead-code | const-unused trong catalogue là contract byte-parity — giữ nguyên |

## Tự làm

**PREDICT** — Senior `app_assets.dart` có 45 const; một dev
"cleanup" xoá 10 const không ai tham chiếu rồi commit. Tuần
sau, một file senior khác port về dùng `AppAssets.trophyDeco`.
Chuyện gì xảy ra, và quy trình ngăn chuyện này bằng cách
nào?

:::note[Gợi ý]
Nghĩ theo hai lớp: (1) catalogue-as-contract vs code-as-usage;
(2) "verbatim là mặc định" nghĩa là ai quyết định const nào
được giữ — sweep hay senior?
:::

<details>
<summary>Đáp án</summary>

File port về sẽ **compile-error** (`'trophyDeco' isn't defined`)
— phải quay lại vá `app_assets.dart`, và bản vá dễ lệch với
senior (path đoán, tên const đoán). ngăn bằng nguyên tắc:
catalogue port **verbatim**, quyết định giữ/bỏ const thuộc về
senior; sweep không "tối ưu" catalogue. Xoá chỉ xảy ra khi
senior xoá — lúc đó diff tiếp theo sẽ bắt được.

</details>

**DEBUG** — Sau Bước 5, `flutter analyze` báo
`The getter 'settingsIconSemanticLabel' isn't defined for the
type 'AppLocalizations'` dù bạn đã thêm key vào cả hai ARB.
Tìm nguyên nhân.

:::note[Gợi ý]
Key ở ARB ≠ getter ở Dart. Có một bước giữa hai thứ đó.
:::

<details>
<summary>Đáp án</summary>

Quên `flutter gen-l10n`. `lib/l10n/app_localizations*.dart` là
generated từ ARB — sửa ARB không tự lan sang Dart. Regen, rồi
analyze lại sẽ sạch. (Đây cũng là vì sao quy trình luôn kết
thúc bằng `gen-l10n && analyze && test`.)

</details>

**PRODUCE** — Viết một script (bash hoặc PowerShell) in ra:
(1) số file trong `assets/images/` của learner vs senior;
(2) danh sách file senior có learner không. Chạy nó trước và
sau Bước 2.

:::note[Gợi ý]
`find assets/images -type f | sort` + `comm -23` (so sánh hai
danh sách đã sort).
:::

<details>
<summary>Đáp án</summary>

```bash
SENIOR=../flutter-accelerator-ai
find "$SENIOR/assets/images" -type f | sed "s|$SENIOR/||" | sort > /tmp/s.txt
find assets/images -type f | sort > /tmp/l.txt
echo "senior: $(wc -l < /tmp/s.txt)  learner: $(wc -l < /tmp/l.txt)"
comm -23 /tmp/s.txt /tmp/l.txt   # senior có, learner không
```

Trước Bước 2: danh sách ~20 file (avatars/, leaderboard/…).
Sau Bước 2: `comm` in trống = parity.

</details>

## Kiểm tra hiểu biết

**H: Vì sao bài này +0 test mà vẫn là checkpoint hợp lệ?** —
Vì nền móng không có hành vi riêng; hợp đồng của nó là "không
phá gì đang xanh + mọi tham chiếu cần thiết tồn tại". 309/309
sau khi thêm 50 asset + 45 const + 11 key = nền sạch.

**H: `OnboardingTokens` và `AppTokens` cùng tồn tại — hai
nguồn token?** — Không. `OnboardingTokens` *delegate* mọi giá
trị đã có sang `AppTokens` (`grey600 = AppTokens.qzdsBlack600`);
nó chỉ *định nghĩa* giá trị chỉ onboarding (`accentGreen500`,
`indicatorActiveWidth`…). Một giá trị = một nơi sống; hai class
= hai *góc nhìn* vào một nguồn.

**H: "Verbatim" trong sweep nghĩa là gì, copy nguyên xi?** —
Verbatim = nguyên bản **sau hai phép đổi được phép**: rename
project trong import/comment (`ai_millionaire_course`) và
doc-comment → VI. Mọi phép "cải tiến" khác là divergence phải
documented.

**H: Dead ARB key được nhận diện bằng cách nào trước khi xoá?** —
`grep` key đó trong toàn `lib/` + `test/`: zero usage → mới
được quyền xoá. Không xoá theo linh cảm.

## Ta cố ý chưa thêm

- **Không dùng asset mới ở bất kỳ widget nào** — catalogue và
  file chỉ *chuẩn bị*; người tiêu thụ đến ở Bài 02–06.
- **Không đóng file nào** — bài này thêm key và trừ 2 dead key;
  3 key-rename còn lại (`leaderboardSubtitle`→`menuLeaderboardEntrySubtitle`, `menuExpProgress`→`menuExpToNextLevel`,
  `notificationTimeTitle`→`notificationTimeSetting`) được xử
  cùng call-site ở Bài 03/04/07 khi widget tương ứng port.
- **Không port preview catalogs** — previews là appendix của
  Bài 07, không phải nền móng.
- **`l10n.yaml` không đổi** — `synthetic-package: false` +
  output `lib/l10n/` đã đúng từ M17.

## Checkpoint hoàn thành

- [x] `diff -rq` cây `assets/images/`: **50/50 khớp** senior.
- [x] `lib/core/app_assets.dart`: **45 const verbatim** (kể cả
      ~10 const senior ship nhưng không reference — byte-parity).
- [x] `lib/core/onboarding_design_tokens.dart`: 84-dòng
      verbatim — `OnboardingTokens` delegate→`AppTokens`.
- [x] ARB +11 key senior, −2 dead key (`questionCounter`,
      `gameRoomTitle`); `flutter gen-l10n` đã chạy.
- [x] `flutter analyze` clean · `flutter test` **309/309**
      (+0, không hỏng) · `flutter build web` PASS.
- [x] Mental model áp dụng lần đầu: đọc → diff →
      port verbatim → verify; không improve lén.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m29/01 — "Nền móng đủ: 50 asset, `AppAssets`/`OnboardingTokens` verbatim, l10n đồng bộ" (sweep mở đầu bằng nền: ship đủ ~50 file `assets/images/` senior; `app_assets.dart` verbatim 45 const — kể cả ~10 const senior ship nhưng không reference (byte-parity catalogue); `onboarding_design_tokens.dart` verbatim — delegate→AppTokens không redeclare literal; +11 ARB key senior, −2 dead key; gen-l10n regen; +0 test → 309).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter gen-l10n`, `grep`/`findstr` cho dead key. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. +0 test là ĐÚNG — nền được-tham-chiếu, hành vi test gián tiếp ở Bài 02–06.

EXPECTED STATE SAU BÀI NÀY:
- `assets/images/` — đủ ~50 file qua 5 thư mục đã khai trong pubspec: `backgrounds/`, `avatars/` (avatar.png mặc định), `icons/` (game-* từ M28 + speaker/music/vibration/bell-notification/filter/setting/gear/trophy/menu icons), `decorations/`, `leaderboard/` (medal-gold/silver/bronze SVG + score-coin + ~7 avatar PNG + current-user accent). `pubspec.yaml` `flutter.assets:` khai theo dir — KHÔNG đổi khi thêm file (dir-declaration cover). Asset binary = byte-parity với senior copy (nguyên thư mục, không qua archive/rename).
- `lib/core/app_assets.dart` (STRICT verbatim ~73 dòng): `class AppAssets` đúng **45** `static const String` — giữ 8 cũ M28 + mới: `avatar`, `iconTrophy`, `iconSpeaker`, `iconMusic`, `iconVibration`, `iconBellNotification`, `iconFilter`, `iconSetting`, `iconGear`, `leaderboardRank1/2/3`, `leaderboardRankCurrent`, `leaderboardScoreCoin`, `avatarTauHuDiChill` + ~6 leaderboard avatars + ~10 const senior-ship-không-reference (`iconCart`, `coinMid`, `gamepad`, `gamepadDetail`, `trophyDeco`, `trophyDetail1/2/3`, `trophyVector`, `leaderboardCurrentAccent`…) (STRICT: xoá const-unused "vì không ai dùng" = DIVERGED — catalogue là contract byte-parity, không phải dead-code; subset 8-const M28 còn = BEHIND).
- `lib/core/onboarding_design_tokens.dart` (FILE MỚI, STRICT verbatim ~84 dòng): `class OnboardingTokens` — chỉ-onboarding const (`buttonHeightLarge = 48`, `badgeSize = 64`, `indicatorActiveWidth = 24`, `indicatorSize = 8`, `motionLong`/`motionEmphasis`/`motionSlow`, `hazeScrim`) + **delegate→AppTokens** `static const Color grey600 = AppTokens.qzdsBlack600`/`blue500`/`purple500` (STRICT const-alias — redeclare literal `0xFF…` trùng AppTokens = DIVERGED một-giá-trị-hai-nguồn); chỉ-onboarding literal riêng (`blue100 = Color(0xFFAEBFFD)`, `accentGreen500 = Color(0xFF4CAF50)`); `static TextStyle get body1 => GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: w400, height: 1.5)` + `static … get` cho gradient/decoration runtime (getter không const được); `badgeGradient(c1, c2)` helper.
- ARB (STRICT +11/−2): THÊM `closeButton`, `saveButton`, `languageSetting`, `hourPickerSemanticLabel`, `minutePickerSemanticLabel`, `settingsIconSemanticLabel {label}`, `menuLevelShort`, `menuExperienceLabel`, `menuExpToNextLevel {exp,level}`, `menuMaxLevelReached`, `menuLeaderboardEntrySubtitle` (en có `@`-metadata placeholders, vi value verbatim); XOÁ `questionCounter`, `gameRoomTitle` (STRICT zero-usage grep-verify trước khi xoá — xoá key còn ai gọi = compile-đỏ); `lib/l10n/*.dart` REGENERATED qua `flutter gen-l10n` (STRICT không sửa tay generated — key xoá mà generated còn getter = "key ma" DIVERGED).
- `flutter analyze` sạch; `flutter test` → **309/309** (STRICT — +0: nền không hành vi riêng).
- KHÔNG ĐƯỢC có (chưa đến): `iconAsset` trên `SettingItemData` (BÀI 02 — vẫn `icon: IconData`); 11 file `widgets/menu/settings/` shell/card/section/row/account/dialog/scope/picker×3 (BÀI 02); `LeaderboardEntryData.avatarAsset`/`avatarUrl`/`rankAsset`/`style` + `_LeaderboardRecord` + `entryFromRow` + `LeaderboardAvatar`/`LeaderboardEntryCard` (BÀI 03); `menu_screen_content`/`profile/`×5/`gradient_cta_button`/`screen_*_inset` (BÀI 04); `MenuDialogState`/`menu_dialog_layer`/`menu_dialog_backdrop`/`menu_screen_view` (BÀI 05); `onboarding_header_config`/`onboarding_dialog_card`/`onboarding_step_actions`/`onboarding_step_indicator`/overlay 4-class + scope FutureBuilder→StreamBuilder chain (BÀI 06); `menu_tokens.dart` xoá (BÀI 06 — file vẫn còn); previews/`@Preview` (BÀI 07); `MenuDialog*` events retire (BÀI 05); literal `0xFF…` trùng AppTokens trong onboarding tokens (delegate-vi phạm).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- M28 đỉnh 309 (visual parity game-side hoàn chỉnh); `AppAssets` 8-const→45 (MỞ RỘNG — không viết lại sai path cũ); `menu_tokens.dart` shim còn tồn tại (BÀI 06 xoá — consumer onboarding sót); `settings_dialog.dart` monolith 461d (BÀI 02 retire); `SettingItemData.icon: IconData` (BÀI 02 swap); `menu_screen.dart` private-widgets (BÀI 04 decompose); `showDialog`/`showXxxDialog`/`MenuScreenUiEvent` 6-variant (BÀI 05 retire); `onboarding_overlay_scope.dart` chain-M18-đơn-giản (BÀI 06 khôi phục); M27 platform chain; M26 DRE.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. `AppAssets` thiếu const so với 45 hoặc xoá const-unused = DIVERGED catalogue-parity; `OnboardingTokens` redeclare literal trùng `AppTokens` = DIVERGED delegate; ARB sửa mà quên `gen-l10n` = NEEDS_FIX key-ma.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m29/01
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
