---
title: "Bài 1 · Supabase, dart-define & bức tường bảo mật"
description: "Supabase làm gì trong app này (hosted Postgres + Data API); String.fromEnvironment + --dart-define — config là plumbing, không phải state; publishable key ≠ service-role; public.leaderboard là VIEW còn public.users nằm sau RLS. Thêm SupabaseEnvironment + 3 test → 168 → 171."
sidebar:
 label: "Bài 1 · Supabase + dart-define"
 order: 1
---

## Mục tiêu

- Giải thích được Supabase cung cấp **gì** cho app này: Postgres có
 sẵn trên cloud + Data API tự sinh (auth sẽ đến ở M24).
- Viết được `SupabaseEnvironment` đọc `String.fromEnvironment` — bốn
 key đúng senior — và nói được vì sao nó KHÔNG phải file `.env`.
- Chỉ được ranh giới bảo mật: publishable/anon key là công khai theo
 thiết kế; quyền hạn nằm ở RLS phía server, không nằm trong code
 client; `public.leaderboard` là VIEW còn `public.users` là bảng
 owner-only.
- Thêm 3 test env → suite **168 → 171**.

## Bạn đang ở đâu

- Cuối M22: `flutter test` 168/168, mọi repository đều LOCAL —
 `UserProfileRepositoryImpl`/`UserSettingsRepositoryImpl`/
 `OnboardingRepositoryImpl` đọc ghi SharedPreferences.
- Menu đã có `_LeaderboardEntry` — hàng "Bảng xếp hạng" NHÌN được
 nhưng chưa bấm được (chờ đúng milestone này).
- Chưa có `supabase_flutter`, chưa có `lib/services/`, chưa có file
 nào của leaderboard.

## Vì sao việc này quan trọng ngay bây giờ

Bảng xếp hạng theo định nghĩa là **dữ liệu của nhiều người chơi** —
không thể nằm trong SharedPreferences của một máy. Cần một backend:
nơi mọi app ghi profile vào và đọc bảng chung ra. Senior chọn
Supabase: một Postgres host sẵn, kèm **Data API tự sinh** — tức mỗi
bảng/view trong `public` tự động có REST endpoint mà SDK Dart gọi
được bằng cú pháp `from('leaderboard').select(...)`. Không cần tự
viết server.

Nhưng trước khi gọi được backend, app phải biết *backend ở đâu* —
project URL và key nào. Milestone này bắt đầu bằng câu hỏi tưởng nhỏ
đó: **đưa cấu hình vào build thế nào mà không commit bí mật lên
repo?**

## Bạn đã biết gì

- `abstract interface class` + `implements` — contract repository
 (M14); DI bằng `Provider<CONTRACT>.value` trong
 `AppDependencyScope` (M14).
- Fake repository viết tay cho test (M14).
- `const`/`static const` + `String.trim().isNotEmpty`.
- Null safety `T?`/`??`/getter `bool get`.
- `test`/`expect`/`group` (MASTERED).
- `main()` `async` + `WidgetsFlutterBinding.ensureInitialized()`
 (M05).

## Mental model mới — hai cái cùng lúc

**① "Config là plumbing, không phải state"** (concept mới M23 —
registry).

`String.fromEnvironment('KEY')` đọc một **hằng số biên dịch**: giá
trị được "đóng gói" vào binary lúc build qua `--dart-define=KEY=giá
trị`. Ba hệ quả cần thuộc:

- Nó **không phải runtime**: đổi giá trị = build lại, không có
 hot-reload nào thay được.
- Không truyền gì → chuỗi rỗng `''` (hoặc `defaultValue` nếu có) —
 KHÔNG throw, KHÔNG null. Kiểm "có cấu hình hay chưa" đơn giản là
 `trim().isNotEmpty`.
- Nó **không phải file `.env`**: không file nào trong repo chứa giá
 trị thật — tên key nằm trong code, giá trị nằm trên dòng lệnh
 build (hoặc CI secret). Đó là lý do repo sạch credentials được.

Vì config là plumbing nên *thiếu config không phải lỗi*: app nhận
ra "chưa cấu hình" → chọn impl tĩnh → chạy tiếp bình thường. Bài 2
sẽ thấy điểm rẽ đó trong `main()`.

**② "Khoá không phải bức tường — RLS mới là"** (backend awareness —
registry).

Người mới thường nghĩ "giấu key đi thì an toàn". Đúng ngược lại:

```text
code client ĐÃ ĐÓNG GÓI = công khai theo định nghĩa
    │  (ai cũng mở apk/web bundle ra đọc được)
    ▼
publishable/anon key nằm trong client → Supabase THIẾT KẾ nó là
    public key: định danh project + xin quyền "anon", không phải
    bí mật cần giấu
    ▼
bức tường thật = RLS policies + grants trên SERVER
    public.users     → owner-only (anon đọc = 0 dòng)
    public.leaderboard → VIEW ai-cũng-đọc-được, rank public fields
                     và CHE auth_uuid của người khác
```

Đối lập hoàn toàn là **service-role key**: key đó *bỏ qua* RLS — là
bí mật thật, chỉ sống trên server/dashboard, tuyệt đối không đưa
vào client. Rule ngắn: **publishable key ship cùng app; service-role
không bao giờ rời máy chủ.**

`public.leaderboard` là VIEW, không phải bảng : nó là "câu
query được đặt tên" chạy với quyền owner — đọc toàn bộ `users` để
xếp hạng, rồi chỉ lộ các cột public. Client đọc view; không ai đọc
bảng gốc trừ chủ nhân từng dòng.

## Dart mới — `String.fromEnvironment`

| Construct | Vai trò |
|---|---|
| `const String.fromEnvironment('KEY')` | hằng biên dịch: giá trị truyền qua `--dart-define=KEY=...`; thiếu → `''` |
| `defaultValue: 'x'` | tham số tuỳ chọn — thiếu key → `'x'` thay vì `''` |
| `--dart-define=KEY=value` (flutter) / `--define=KEY=value` / `-D` (dart CLI) | cách truyền lúc build/run |

Giải phẫu cú pháp:

```dart
static const _url = String.fromEnvironment('SUPABASE_URL');
//          ↑ chỉ chạy được trong const context — compiler phải tính
//            được giá trị NGAY LÚC biên dịch (đó là điểm "compile-time")
//     ↑ tên key — phải trùng CHÍNH XÁC tên truyền trên dòng lệnh
```

Vì sao `static const` ở class-level? Vì giá trị này bất biến theo
thiết kế — nó được nướng vào binary. Nếu gán `String.fromEnvironment`
vào biến non-const thì trên nhiều platform (AOT) nó trả rỗng — đúng
lý do senior giữ `const`.

`--dart-define` là tên cờ của `flutter run`/`flutter test`/
`flutter build`; Dart CLI gọi cờ tương đương là `--define`/`-D`.

## Ví dụ độc lập

15 dòng, tách khỏi app — một file `scratch.dart` tự do (DartPad
không chạy được vì cần cờ dòng lệnh; tạo file tạm rồi xoá):

```dart
// Đọc hai "environment declaration" — tên key do MÌNH đặt.
const _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
const _api = String.fromEnvironment('API_URL');

void main() {
  print('flavor=$_flavor api="${_api.isEmpty ? '<chưa cấu hình>' : _api}"');
}
```

```text
dart run scratch.dart
  → flavor=dev api="<chưa cấu hình>"
dart run --define=FLAVOR=prod --define=API_URL=https://x scratch.dart
  → flavor=prod api="https://x"
```

Nhìn kỹ: không truyền `API_URL` → `_api` là `''`, không lỗi — check
"đã cấu hình chưa" = `isEmpty`. Đó chính là pattern
`isSupabaseConfigured` sắp gặp. (Trong app Flutter, cờ đổi tên thành
`--dart-define=` — cùng cơ chế.)

## Android / Compose bridge

```text
SIMILARITY:           `--dart-define` ≈ `buildConfigField` trong
                      build.gradle — giá trị nướng vào binary lúc
                      build, đọc qua `BuildConfig.X`.
IMPORTANT DIFFERENCE: không có class sinh ra: bạn tự đọc key bằng
                      `String.fromEnvironment` tại chỗ cần — không
                      import "config" từ đâu cả.
DO NOT ASSUME:        nó KHÔNG giống SharedPreferences/Remote Config:
                      không ghi được lúc chạy, không đổi được sau
                      install. Muốn config runtime thì đây không
                      phải công cụ.
```

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/core/supabase_environment.dart` | learner port nguyên văn — cùng 4 key, cùng predicates, cùng chuỗi lỗi |
| `supabase/student-setup/01-setup-database.sql` | schema thật: `public.users` + RLS owner policies + view `security_barrier` — copy byte-identical vào learner repo (bên dưới) |
| `lib/main.dart` | `SupabaseEnvironment.fromEnvironment()` là bước bootstrap đầu tiên (Bài 2 port) |

## Đọc file SQL — chỉ điểm cần thiết

`supabase/student-setup/01-setup-database.sql` là script cài schema
(dán vào SQL Editor của Supabase Dashboard chạy một lần). Nó là
tài liệu tham khảo — đọc chọn lọc, KHÔNG học thuộc:

**Bảng `public.users` + chính sách owner** (dòng ~22–122):

```sql
alter table public.users enable row level security;
revoke all on table public.users from public, anon, authenticated;
grant select on table public.users to authenticated;

create policy users_select_own
on public.users for select to authenticated
using ((select auth.uid()) = auth_uuid);
-- (users_insert_own / users_update_own cùng pattern:
--  chỉ dòng có auth_uuid = uid của chính mình mới được qua)
```

RLS = *row level security*: Postgres tự lọc mỗi query theo policy.
`revoke all` trước rồi `grant select ... to authenticated` — mặc
định ĐÓNG, mở từng cửa. Anon (chưa đăng nhập) thì bị từ chối ngay
ở tầng quyền — không đọc được `users` tý nào; authenticated đọc
được nhưng RLS chỉ cho qua dòng có `auth_uuid = auth.uid()` của
chính mình.

**View `public.leaderboard`** (dòng ~127–149) — trái tim của bài:

```sql
create or replace view public.leaderboard
with (security_barrier = true)
as
select
  row_number() over (
    order by users.total_money_won desc,
             users.level desc, users.updated_at, users.id
  ) as rank,
  case
    when users.auth_uuid = (select auth.uid()) then users.auth_uuid
    else null::uuid
  end as auth_uuid,
  users.name, users.avatar_url, users.level, users.total_money_won
from public.users;

grant select on table public.leaderboard to anon, authenticated;
```

- `row_number() over (order by ...)` = **rank được server tính sẵn**
 — client không tự xếp hạng.
- `auth_uuid` chỉ hiện **trên dòng của chính caller** (`auth.uid()`)
 — app dùng nó để query ".eq('auth_uuid', uid)" lấy hàng "bạn";
 của người khác luôn `null`.
- `security_barrier = true` chặn predicate của caller chui xuống
 dưới lớp che — một lớp phòng thủ của Postgres.
- Grant `select` cho **cả anon** — guest cũng xem được bảng (đúng
 trải nghiệm app: chưa đăng nhập vẫn mở leaderboard được).

## Build it step by step

**Bước 1 — thêm dependency.** `pubspec.yaml`:

```yaml
  supabase_flutter: 2.14.2
```

(pin đúng version senior — `supabase_flutter: 2.14.2` y pubspec
senior; nằm sau `shared_preferences`. Chạy `flutter pub get`; kéo
theo `supabase 2.12.2` + transitive deps.)

**Bước 2 — tạo `lib/core/supabase_environment.dart`.** Port nguyên
văn senior (comment Việt giữ sẵn trong file):

```dart
class SupabaseEnvironment {
  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const _googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  final String supabaseUrl;
  final String publishableKey;
  final String googleWebClientId;
  final String googleIosClientId;

  const SupabaseEnvironment({
    required this.supabaseUrl,
    required this.publishableKey,
    required this.googleWebClientId,
    required this.googleIosClientId,
  });

  factory SupabaseEnvironment.fromEnvironment() {
    return const SupabaseEnvironment(
      supabaseUrl: _url,
      publishableKey: _publishableKey,
      googleWebClientId: _googleWebClientId,
      googleIosClientId: _googleIosClientId,
    );
  }

  bool get isSupabaseConfigured {
    return supabaseUrl.trim().isNotEmpty &&
        publishableKey.trim().isNotEmpty;
  }

  bool get isGoogleConfigured => googleWebClientId.trim().isNotEmpty;

  String? get configurationError {
    if (!isSupabaseConfigured) {
      return 'Supabase is not configured.';
    }
    if (!isGoogleConfigured) {
      return 'Google sign-in is not configured.';
    }
    return null;
  }
}
```

Bốn field, không thiếu không thừa. Cặp `GOOGLE_*` hiện chưa có
consumer — giữ nguyên để shape cấu hình khớp senior (auth = M24).

**Bước 3 — copy `supabase/student-setup/01-setup-database.sql`.**
Nguyên văn từ senior vào `supabase/student-setup/01-setup-database.sql`
(181 dòng). Nó không chứa secret — chỉ schema + policy; comment đầu
file tự nói vậy. Đây là script học viên chạy trên project RIÊNG nếu
muốn chạy remote — không bắt buộc cho checkpoint.

**Bước 4 — test `test/core/supabase_environment_test.dart`.**
`String.fromEnvironment` là compile-time nên test KHÔNG set được
dart-define — phần kiểm được là ctor + predicates (truyền giá trị
tay). Ba test:

```dart
void main() {
  SupabaseEnvironment env({
    String url = '', String key = '', String webId = '', String iosId = '',
  }) {
    return SupabaseEnvironment(
      supabaseUrl: url, publishableKey: key,
      googleWebClientId: webId, googleIosClientId: iosId,
    );
  }

  test('thiếu url/key → isSupabaseConfigured false + configurationError', () {
    expect(env().isSupabaseConfigured, isFalse);
    expect(env().configurationError, 'Supabase is not configured.');
    expect(env(url: 'https://x.supabase.co').isSupabaseConfigured, isFalse);
    expect(env(key: 'pk').isSupabaseConfigured, isFalse);
    expect(env(url: '  ', key: '  ').isSupabaseConfigured, isFalse);
  });

  test('đủ url+key → isSupabaseConfigured true', () {
    final e = env(url: 'https://x.supabase.co', key: 'pk');
    expect(e.isSupabaseConfigured, isTrue);
    expect(e.configurationError, 'Google sign-in is not configured.');
  });

  test('đủ cả bốn → configurationError null; isGoogleConfigured đúng', () {
    final full = env(url: 'https://x.supabase.co', key: 'pk',
        webId: 'web-id', iosId: 'ios-id');
    expect(full.isSupabaseConfigured, isTrue);
    expect(full.isGoogleConfigured, isTrue);
    expect(full.configurationError, isNull);
    expect(env(webId: 'web-id').isGoogleConfigured, isTrue);
    expect(env(iosId: 'ios-id').isGoogleConfigured, isFalse);
  });
}
```

(`'https://x.supabase.co'` là fixture giả — không phải project thật.)

## Hiểu code — hai chi tiết dễ trượt

- `configurationError` trả **lỗi đầu tiên theo thứ tự**: thiếu
 Supabase báo Supabase trước; đủ Supabase nhưng thiếu Google báo
 Google. Nó là chuỗi `String?` — `null` = "đủ hết", không phải
 "không có cấu hình".
- `isGoogleConfigured` chỉ check `googleWebClientId` — đúng senior
 (iOS id tham gia field nhưng predicate web là đủ cho gate).

## Chạy và quan sát

```text
flutter pub get                        → OK ("supabase_flutter 2.14.2")
flutter analyze                        → No issues found!
flutter test                           → +171: All tests passed!
flutter test test/core/supabase_environment_test.dart → 3/3 xanh
```

Đọc đúng con số: 168 (cuối M22) + 3 test env mới = **171**.

## Thử nghiệm

Đoán trước rồi viết thêm `expect` kiểm chứng trong file test:

- `env(url: 'https://x.supabase.co', key: ' ').configurationError` → ?
- `env(key: 'pk', webId: 'w').configurationError` → báo lỗi nào
 TRƯỚC: Supabase hay Google?

<details>
<summary>Đáp án</summary>

- `'Supabase is not configured.'` — key toàn khoảng trắng trim về
 `''` → `isSupabaseConfigured` false → nhánh đầu tiên.
- Vẫn `'Supabase is not configured.'` — `configurationError` check
 theo THỨ TỰ: Supabase trước, Google sau. Dù `isGoogleConfigured`
 đã true, nhánh đầu fail vẫn thắng.
</details>

## Lỗi hay gặp

1. **Nghĩ config đến từ `.env`/file JSON trong assets.** Không có
 file nào cả — `String.fromEnvironment` chỉ đọc cờ build. File
 `.env` commit vào repo là rò rỉ, và là cách *khác* (senior không
 dùng).
2. **Hardcode URL/key thật vào file Dart.** Về mặt kỹ thuật chạy
 được — về mặt quy trình là commit secret. Tên key ở trong code,
 giá trị ở trên dòng lệnh.
3. **Coi publishable key là bí mật bị lộ.** Nó ĐƯỢC THIẾT KẾ public
 (anon key) — bảo vệ dữ liệu là việc của RLS. Bí mật thật là
 service-role — thứ không bao giờ xuất hiện trong repo này.
4. **Gõ sai tên dart-define.** `SUPABASE_ULR` không báo lỗi — chỉ
 lặng lẽ `''` → `isSupabaseConfigured` false → app chạy bản
 disabled. Debug config = in `debugPrint` predicates, không phải
 in giá trị key.
5. **Gọi `String.fromEnvironment` non-const.** Trên AOT/web có thể
 trả rỗng — luôn `const` (hoặc trong const context).

## Tự làm — PREDICT

Không sửa app. Cho từng tổ hợp khởi chạy, viết ra giấy ba giá trị
`isSupabaseConfigured` / `isGoogleConfigured` / `configurationError`:

| # | dart-define truyền vào |
|---|---|
| a | *(không truyền gì)* |
| b | `--dart-define=SUPABASE_URL=<your-project-url>` (chỉ url) |
| c | `SUPABASE_URL` + `SUPABASE_PUBLISHABLE_KEY` đủ, không Google |
| d | đủ cả bốn key |

<details>
<summary>Đáp án</summary>

- a → `false` / `false` / `'Supabase is not configured.'`
- b → `false` / `false` / `'Supabase is not configured.'` (thiếu
 key vẫn thiếu — hai điều kiện AND).
- c → `true` / `false` / `'Google sign-in is not configured.'` —
 Supabase đủ → init remote được (Bài 2); Google báo thiếu nhưng
 M24 mới cần.
- d → `true` / `true` / `null`.

</details>

## Kiểm tra hiểu biết

- **Hỏi:** `String.fromEnvironment` khác đọc file `.env` ở điểm
 nào? — **Đáp:** nó là hằng biên dịch nướng vào binary qua cờ
 `--dart-define`; không file nào tồn tại trong repo, không đọc ghi
 lúc chạy.
- **Hỏi:** publishable key lộ trong client — sao dữ liệu vẫn an
 toàn? — **Đáp:** key anon chỉ "xin quyền anon"; quyền thật do RLS
 + grants phía server quyết (`public.users` owner-only, view
 `security_barrier` chỉ lộ cột public). Service-role mới là bí mật
 — và nó không nằm trong app.
- **Hỏi:** `public.leaderboard` là bảng hay view, khác nhau ra
 sao? — **Đáp:** VIEW chạy quyền owner: rank sẵn bằng `row_number()`,
 che `auth_uuid` của người khác; bảng `users` gốc không ai đọc được
 ngoài chủ dòng.

## Ta cố ý chưa thêm

- `Supabase.initialize` / `SupabaseClient` — Bài 2.
- Dùng hai key `GOOGLE_*` — **M24** (auth); giờ chỉ giữ shape.
- Chạy app với project Supabase thật — Bài 5, OPTIONAL và phụ thuộc
 môi trường (không credential nào tồn tại trong môi trường này).
- File `.env`, package `flutter_dotenv` — **không bao giờ**: senior
 không dùng, dart-define là cơ chế duy nhất của khóa.

## Checkpoint hoàn thành

- [ ] `pubspec.yaml` có `supabase_flutter: 2.14.2`, `flutter pub get`
 xanh.
- [ ] `lib/core/supabase_environment.dart` tồn tại với đúng 4
 dart-define + 2 predicates + `configurationError`.
- [ ] `supabase/student-setup/01-setup-database.sql` có trong repo
 (copy nguyên văn, không chỉnh sửa, không secret).
- [ ] `flutter analyze` sạch; `flutter test` **171/171**.
- [ ] Trả lời được: thiếu `SUPABASE_PUBLISHABLE_KEY` thì
 `isSupabaseConfigured` ra gì, và ai chịu trách nhiệm "khóa" dữ
 liệu `public.users` (RLS server-side — không phải key trong
 client).
