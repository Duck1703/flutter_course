---
title: "M23 — Supabase bootstrap & Leaderboard"
description: "5 bài: Supabase + dart-define + bức tường RLS → init có điều kiện + DI theo config → LeaderboardRepository (query chain + maybeSingle + row mapping) → LeaderboardDialogViewModel (4 state + stale guard + guest seam) → dialog + menu row tap (FR-14) + RefreshIndicator + manual run."
sidebar:
  order: 0
  label: Tổng quan M23
---

# M23 · Supabase bootstrap & Leaderboard

Đến M23, mọi repository của learner đều LOCAL — SharedPreferences
trên một máy. Bảng xếp hạng thì ngược lại theo bản chất: dữ liệu
của nhiều người chơi, cần một backend. Milestone này cắm **đường
remote đầu tiên** của khóa — và đồng thời đóng FR-14: hàng "Bảng
xếp hạng" trên menu trở thành entry thật, mở dialog với dữ liệu
repository thật (tĩnh khi chưa cấu hình, remote khi có).

:::note[FR-14 đóng ở đây — và một seam mới mở ra]
- `_LeaderboardEntry` tĩnh → tappable → event → `showDialog` →
  dialog-scoped VM → `LeaderboardRepository` data.
- **Guest seam (→ M24):** `LeaderboardDialogViewModel` chưa nhận
  `AuthRepository`; `_currentLeaderboardUserId()` luôn `null` —
  hàng "bạn" dựng từ profile local.
- Transport vẫn là `showDialog` (FR-29 — `MenuDialogLayer` ở M29).
:::

## Bản đồ bài học

| Bài | Nội dung | Checkpoint |
|-----|----------|-----------|
| [01](/m23/01-supabase-va-dart-define/) | Supabase làm gì trong app này; `String.fromEnvironment` + `--dart-define` (D-40, config=plumbing); publishable key ≠ service-role; view `security_barrier` vs bảng owner-only (B-01/B-02) | **171/171** (+3 env test) |
| [02](/m23/02-init-co-dieu-kien/) | `SupabaseClientService.initialize` → `SupabaseClient?` sentinel; `client == null ? Disabled… : Supabase…` trong `main()` (A-24); scope nhận `LeaderboardRepository`; "contract không biết dữ liệu sống ở đâu" (A-23) | **171/171** |
| [03](/m23/03-leaderboard-repository/) | `loadLeaderboard({currentUserId})` → `LeaderboardSnapshot`; chuỗi query `from().select().order().order().limit(10)` + `.eq('auth_uuid',uid).maybeSingle()` (D-41); `_LeaderboardRecord` mapping phòng thủ; `DisabledLeaderboardRepository`; fake scriptable | **175/175** (+4 repo test) |
| [04](/m23/04-viewmodel-va-stale-guard/) | `LeaderboardDialogViewModel`: 4 state, `isRefreshing`, `retry()`, `_requestId` stale guard (D-42 — "câu trả lời cũ không được thắng"), fallback hàng-bạn từ profile, guest seam → M24 | **184/184** (+9 VM test) |
| [05](/m23/05-dialog-va-menu-row/) | menu row tap → `MenuLeaderboardRequested` → `showLeaderboardDialog` → scope + post-frame load → `LeaderboardPopupBody`/`List`/`Row` + `RefreshIndicator.adaptive` (F-32); +6 key ARB; manual run không/có dart-define | **193/193** (+9) + build web |

## Kết quả cuối milestone

- `flutter analyze` sạch · `flutter test` **193/193** (168 + 3 + 4
  + 9 + 9) · `flutter build web` PASS.
- Không dart-define: app chạy `DisabledLeaderboardRepository` — hàng
  menu mở dialog 6 hàng tĩnh + hàng "bạn" rank 125; pull-to-refresh
  chạy được; error branch có THỬ LẠI.
- Có dart-define (project của chính học viên, OPTIONAL —
  `LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED` trong môi trường khóa):
  `SupabaseLeaderboardRepository` đọc view `public.leaderboard` —
  cùng contract, UI không đổi một dòng.
- `supabase/student-setup/01-setup-database.sql` có trong repo —
  schema byte-identical senior, grant `anon`/`authenticated` chỉ
  trên view, không secret.

## Điều milestone này cố ý chưa làm

| Chưa làm | Milestone sở hữu | Vì sao |
|---|---|---|
| `AuthRepository` + `switch(authState)` trả uid thật | **M24** | guest seam có chủ đích — ctor VM thiếu auth repo; `_currentLeaderboardUserId() → null` |
| Ghi/sync `public.users` (insert/update/upsert) | **M25** | M23 chỉ ĐỌC — `settingsGuestSyncHint` vẫn là hint |
| `DreChangeNotifier`/`asyncOp` + cancel thật | **M26** | `_requestId` monotonic guard đủ cho pull-race |
| SVG rank badge/avatar asset/frame painter/`LeaderboardRowStyle`, `LeaderboardEntryCard` tách-file | **M28** | pipeline asset chưa có; `#N` text + MenuTokens chrome |
| `MenuDialogLayer` + `MenuDialogLeaderboard` state | **M29** | FR-29: transport `showDialog` giữ — cùng scaffold settings |
| Realtime subscription | — | senior cũng không dùng cho bảng này; refresh() là cơ chế |
| Verify remote sống | — | `LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED` — không credential trong môi trường; deterministic fakes là đường PASS |

## Checkpoint tổng kết

- [ ] `flutter analyze` sạch; `flutter test` **193/193**;
  `flutter build web` xanh.
- [ ] Grep `lib/` không có `.env`, không credential, không
  `ServiceRole`/service-role usage; chỉ 4 dart-define NAME +
  placeholder `<your-…>` trong docs/comments.
- [ ] Tap "Bảng xếp hạng" → dialog `BẢNG XẾP HẠNG` mở qua đúng
  transport event → `showDialog`; 4 nhánh state render đúng chuỗi
  l10n tiếng Việt.
- [ ] Repo scope đăng ký `Provider<LeaderboardRepository>.value` —
  kiểu contract, impl do `main()` chọn theo `client == null`.
- [ ] Test đọc đúng: 168 → +3 env (B01) → +4 repo (B03) → +9 VM
  (B04) → +8 dialog + 1 menu VM (B05) = 193.

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** `String.fromEnvironment`/`--dart-define` (D-40);
   conditional init + DI theo config (A-24); remote impl sau
   contract (A-23); query chain + `maybeSingle` + row mapping
   phòng thủ (D-41); `_requestId` stale guard (D-42);
   `RefreshIndicator.adaptive` (F-32); ranh giới anon-vs-service-role
   + view-vs-table (B-01/B-02).
2. **Giải thích được?** Vì sao thiếu config → `null` → impl tĩnh
   chứ không crash; vì sao key trong client không phải bức tường
   (RLS mới là); vì sao hàng "bạn" của guest vẫn hiện dù
   `currentUserId` null; vì sao guard đặt sau `await` và trong cả
   `catch`; vì sao rank không sort lại phía Dart.
3. **Viết lại không copy?** Tự làm: PRODUCE scripted-queue fake
   (Bài 3) + DEBUG xoá `_isLatestRequest` → test stale đỏ (Bài 4)
   + PREDICT env combos / DI ternary / RefreshIndicator physics.
4. **Nếu … thì sao?** Thiếu `SUPABASE_PUBLISHABLE_KEY` →
   `isSupabaseConfigured` false → Disabled impl; xoá guard success
   → response chậm ghi đè → stale test đỏ `'REMOTE PLAYER'`; repo
   trả rỗng cả hai → `LeaderboardPopupEmpty`; xoá
   `AlwaysScrollableScrollPhysics` → pull-to-refresh chết trên list
   ngắn (test vẫn xanh — lỗi UX-thuần).
5. **Cần ở đâu sau?** M24 inject `AuthRepository` → uid thật →
   query `.eq('auth_uuid',…)` có nghĩa; M25 dùng cùng `SupabaseClient`
   để GHI `public.users`; M28 thay `#N`/`Icon` bằng asset senior;
   M29 đổi `requestLeaderboardDialog()` sang `MenuDialogLeaderboard`
   state; mọi remote sau đều đi qua `SupabaseClientService` đã
   bootstrap ở đây.
