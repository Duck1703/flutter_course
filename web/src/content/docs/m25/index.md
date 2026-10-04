---
title: "M25 — Remote Profile Sync"
description: "5 bài: AppUserData DTO biên local ↔ public.users (+2 schema) → mergeUserProfileForSync thuần: leader=level/exp tiebreak, totals=max, session identity thắng, gamesWon local, demo-normalize (+7) → UserProfileSyncRepositoryImpl fetch→merge→save→upsert onConflict auth_uuid (+0) → main conditional DI + _syncSavedGameResult thật (+0) → VM-level sync tests (+3) → 236/236. converge."
sidebar:
 order: 0
 label: Tổng quan M25
---

# M25 · Remote Profile Sync

Cuối M24, mọi mảnh phía client của sign-in đã xong — nhưng

`syncUserProfile(session)`
 của coordinator rơi vào

`UserProfileSyncRepositoryDisabled`
: **no-op**. Profile chỉ sống
trong SharedPreferences; đổi máy là mất. Milestone này biến seam đó
thành đường remote thật: DTO biên 
`AppUserData`, luật merge

`mergeUserProfileForSync`, impl 
`fetch → merge → save → upsert`

lên 
`public.users`, conditional DI trong 
`main()`, và nhánh

`_syncSavedGameResult`
 thật trong game VM — đóng.

:::note[Triết lý milestone: "merge là luật, repo là máy, wire là chuyện khác"]
- 
`mergeUserProfileForSync`
 là **hàm thuần** — luật conflict
 deterministic (leader=level/exp, totals=max, session identity
 thắng) test được không cần mạng; repo impl chỉ là máy điều phối
 gọi nó đúng chỗ.
- 
`LIVE_PROFILE_SYNC: NOT_PERFORMED`
 — môi trường không credential;
 impl là senior-verbatim, hành vi khóa bằng merge/schema/call-path
 tests ở ba tầng deterministic + SQL byte-parity.
- 
`gamesWon`
 cố ý không lên remote (bảng 
`users`
 không có cột) —
 merge giữ local; 
`email`
 cũng vắng (danh tính ở 
`auth.users`).
:::

## Bản đồ bài học

| Bài | Nội dung | Checkpoint |
| ----- | ---------- | ----------- |
| [01](m25/01-app-user-data-va-schema) | `AppUserData` — DTO biên 8 field: `fromMap` / `fromProfile` / `toUpsertMap` / `toProfile` + parse phòng thủ; bảng `public.users` (11 cột, `auth_uuid` unique FK → `auth.users`, CHECK ≥0/level 1–100, RLS own-row); ba thứ remote không có (`email`, `gamesWon`, `totalEarnings`-chuỗi); `02-verify-database.sql` byte-identical | **226/226** (+2 schema) |
| [02](m25/02-merge-user-profile-for-sync) | `mergeUserProfileForSync` + 5 helper: identity session-wins (username session→remote→leader; avatar session→local→remote), progression leader level→exp-tiebreak nguyên khối, totals max từng field, `gamesWon` local-only, `_withoutDemoProgression` chặn tiến trình fake `'TÀU HỦ ĐI CHILL'` lên remote | **233/233** (+7 merge) |
| [03](m25/03-sync-repository-impl) | `UserProfileSyncRepositoryImpl` cùng file Disabled: `_isSyncing` re-entrancy (≠ `_requestId`) → `InProgress` → load local → `_fetchRemoteProfile` `maybeSingle` → merge → save local → `_upsertRemoteProfile` `upsert(onConflict:'auth_uuid')` + `[sync]` log → `Idle`; catch → `Failed` +rethrow; `_emit` dedupe/isClosed | **233/233** (+0 — impl cần SupabaseClient, coverage đến Bài 5) |
| [04](m25/04-main-di-va-game-vm) | `main()` ternary lần ba: `supabaseClient == null ? Disabled : Impl(client, userProfileRepository)`; game VM ctor `profile→auth→sync` + `_syncSavedGameResult` thật (loadAuthState→authed→sync; guest skip; lỗi nuốt+log — "save là bổn phận, sync là best-effort"); `game_screen.dart` create + mọi call-site test compile-forced; comment "LUÔN Disabled" retire | **233/233** (+0 — coverage Bài 5) |
| [05](m25/05-sync-tests-va-tong-ket) | Group `result profile sync (M25, FR-36)`: authed→ `syncCallCount==1` +uid; guest→0+save intact; `syncError` →nuốt+save `==1`; ba tầng bằng chứng deterministic vs `LIVE_PROFILE_SYNC: NOT_PERFORMED`; → khớp senior | **236/236** (+3) |

## Kết quả cuối milestone

- 
`flutter analyze`
 sạch · 
`flutter test`
 **236/236**
 (224 + 2 + 7 + 0 + 0 + 3) · 
`flutter build web`
 PASS.
- Không dart-define: 
`UserProfileSyncRepositoryDisabled`
 — app guest
 không đổi; console 
`[auth] repository=disabled`; game VM vẫn in
 
`[game] result profile sync skipped; session=guest`
 sau ván (no-op
 path vẫn an toàn).
- Có dart-define (project riêng của học viên, OPTIONAL —
 
`LIVE_PROFILE_SYNC: NOT_PERFORMED`
 trong môi trường khóa):
 
`UserProfileSyncRepositoryImpl`
 — sign-in → coordinator → fetch
 
`public.users`
 → merge → save local → upsert 
`onConflict: auth_uuid`

 (console 
`[sync] upserting public.users …`); mỗi ván xong →
 
`[game] result profile sync started/completed`.
- Khớp cuối: seam Disabled → impl thật + conditional DI +
 result-sync branch; call-site coordinator/dialog VM đã đúng từ M24
 (verified, không rewire).
- SQL: 
`01-setup-database.sql`
 (M23) re-verify byte-identical;
 
`02-verify-database.sql`
 port byte-identical mới — học viên chạy
 trên project riêng để kiểm schema/policies/trigger/view.

## Điều milestone này cố ý chưa làm

| Chưa làm | Milestone sở hữu | Vì sao |
| --- | --- | --- |
| `DreChangeNotifier` / `asyncOp` + cancel cho đường save→sync | **M26** | `try/catch` + `unawaited` + `_isSyncing` tay đủ; DRE là lớp chung sau — `_syncSavedGameResult` sẽ là op đầu tiên |
| `MenuDialogLayer` + `MenuDialogAuth` / `MenuDialogSignOut` state thay event+ `showDialog` | **M29** | transport `showDialog` giữ — cùng scaffold settings/leaderboard |
| `SettingsDialogShell` / `OnboardingGameButton` /icon-asset/ `LevelProgressCard` visual parity | **M28** | chrome hiện tại đủ cho behavior; polish gộp đợt visual (32/34) |
| Version text `v$appVersion` + notification permission/scheduling | **M27** | residual + — package_info/permission chưa vào scope M25 |
| Unit test trực tiếp cho `UserProfileSyncRepositoryImpl` | — | `SupabaseClient` concrete không fake in-process; merge/schema/call-path tests + senior-verbatim gánh verify (senior cũng không có repo-level test) |
| UI consumer `syncStateStream` (badge/spinner "đang đồng bộ") | — | senior không render; stream là observability channel — consumer thật nếu cần là việc sau |
| Retry/backoff có policy cho `ProfileSyncFailed` | — | senior không có; lần sync kế (sign-in / ván sau) là retry tự nhiên, merge idempotent |
| Verify provider/database sống | — | `LIVE_PROFILE_SYNC: NOT_PERFORMED` — không credential trong môi trường; merge+schema+call-path là đường PASS |

## Checkpoint tổng kết

- [ ] 
`flutter analyze`
 sạch; 
`flutter test`
 **236/236**;
 
`flutter build web`
 xanh.
- [ ] 
`app_user_data.dart`
 chứa 
`AppUserData`
 (8 field, 4 cửa, 3
 parser) + 
`mergeUserProfileForSync`
 + 5 helper — verbatim senior.
- [ ] 
`user_profile_sync_repository.dart`
 chứa cả
 
`UserProfileSyncRepositoryImpl`
 lẫn 
`…Disabled`
 cùng file;
 
`main.dart`
 ternary chọn theo 
`supabaseClient == null`.
- [ ] 
`_syncSavedGameResult`
 ba nhánh: authed→sync+started/completed;
 guest→
`skipped; session=guest`; lỗi→
`failed:`
 nuốt — và doc
 không còn chữ "stub M25" ở đâu cả (`app_user_data`, scope,
 coordinator, contract, state-data, VM docs).
- [ ] Test đọc đúng: 224 → +2 schema (B01) → +7 merge (B02) → +0
 impl (B03) → +0 wiring (B04) → +3 call-path (B05) = **236**.
- [ ] Nói được 
`LIVE_PROFILE_SYNC: NOT_PERFORMED`
 nghĩa là gì, và
 OPTIONAL live-run cần những gì (`01`
+
`02`
 SQL → dart-define →
 sign-in → Table Editor / 
`[sync]`
 log).

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** Boundary DTO 
`AppUserData`; merge policy ba
 lớp — session-wins identity / leader progression / max totals /
 gamesWon-local / demo-normalize; repo pipeline
 
`_isSyncing`
 → InProgress → fetch 
`maybeSingle`
 → merge → save →
 
`upsert(onConflict: 'auth_uuid')`
 → Idle, Failed+rethrow;
 
`upsert(onConflict:)`
 insert-or-update keyed unique column +
 RLS own-row; conditional DI lần ba; post-save
 best-effort sync 
`_syncSavedGameResult`.
2. **Giải thích được?** Vì sao DTO biên thay vì map thô; vì sao
 local save trước remote upsert; vì sao repo 
`rethrow`
 còn game
 VM nuốt; vì sao 
`_isSyncing`
 (chặn vào) ≠ 
`_requestId`
 (loại
 kết quả cũ); vì sao 
`gamesWon`/
`email`
 không lên 
`public.users`;
 vì sao impl không có unit test trực tiếp.
3. **Viết lại không copy?** Tự làm: DEBUG xoá
 
`_withoutDemoProgression`
 → test demo đỏ 
`expect(level,1)`
 Actual
 12 (Bài 2) + PRODUCE scratch authed→sync VM test (Bài 4) +
 PREDICT 
`fromMap`/
`toUpsertMap`
 outputs (Bài 1), emit sequence
 (Bài 3), failing-assert map (Bài 5).
4. **Nếu … thì sao?** Thiếu 
`SUPABASE_URL`
 → 
`Disabled`
 no-op, app
 không đổi; remote null → chỉ đắp session identity; profile demo
 cũ → normalize về rỗng; 
`upsert`
 fail → 
`Failed`
+rethrow
 (coordinator path) / nuốt+log (game VM); gọi sync chồng →
 
`_isSyncing`
 từ chối im lặng.
5. **Cần ở đâu sau?** M26 đưa DRE/
`asyncOp`
 vào 
`_saveGameResult`/
 
`_syncSavedGameResult`; M27 version + notification; M28 visual
 parity; M29 
`MenuDialogLayer`. Shape 
`fetch → merge → save →
   upsert`
 của M25 là mẫu cho mọi remote-write sau này.
