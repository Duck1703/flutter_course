-- Flutter Accelerator AI - Script 02: kiểm tra database sau khi cài đặt.
--
-- Dán toàn bộ file này vào một query mới trong Supabase SQL Editor và bấm Run.
-- Kết quả hợp lệ: mọi dòng có status = PASS và overall_status = SETUP OK.
-- Script chỉ đọc metadata; không tạo, sửa, hoặc xóa dữ liệu.

with
required_columns(column_name) as (
  values
    ('id'),
    ('auth_uuid'),
    ('name'),
    ('avatar_url'),
    ('level'),
    ('current_exp'),
    ('total_games_played'),
    ('total_question_count'),
    ('total_money_won'),
    ('created_at'),
    ('updated_at')
),
checks(sort_order, check_name, passed, details) as (
  select
    1,
    'Bảng public.users tồn tại',
    to_regclass('public.users') is not null,
    coalesce(to_regclass('public.users')::text, 'Không tìm thấy')

  union all

  select
    2,
    'Bảng users có đủ 11 cột bắt buộc',
    (
      select count(*) = 11
      from required_columns
      where exists (
        select 1
        from information_schema.columns as table_columns
        where table_columns.table_schema = 'public'
          and table_columns.table_name = 'users'
          and table_columns.column_name = required_columns.column_name
      )
    ),
    'id, auth_uuid, name, avatar_url và các cột progression/timestamp'

  union all

  select
    3,
    'auth_uuid liên kết với auth.users',
    exists (
      select 1
      from pg_constraint
      where conrelid = to_regclass('public.users')
        and confrelid = to_regclass('auth.users')
        and contype = 'f'
    ),
    'Foreign key bảo đảm profile thuộc Supabase Auth user'

  union all

  select
    4,
    'auth_uuid có unique constraint',
    exists (
      select 1
      from pg_constraint
      where conrelid = to_regclass('public.users')
        and conname = 'users_auth_uuid_key'
        and contype = 'u'
    ),
    'Bắt buộc để ứng dụng upsert profile theo auth_uuid'

  union all

  select
    5,
    'Row Level Security đã bật',
    coalesce(
      (
        select relrowsecurity
        from pg_class
        where oid = to_regclass('public.users')
      ),
      false
    ),
    'public.users phải bật RLS'

  union all

  select
    6,
    'Có đủ ba owner-only policies',
    (
      select count(*) = 3
      from pg_policies
      where schemaname = 'public'
        and tablename = 'users'
        and policyname in (
          'users_select_own',
          'users_insert_own',
          'users_update_own'
        )
    ),
    'SELECT, INSERT và UPDATE chỉ dành cho profile của chính user'

  union all

  select
    7,
    'authenticated có quyền đồng bộ profile',
    coalesce(
      has_table_privilege(
        'authenticated',
        to_regclass('public.users'),
        'SELECT, INSERT, UPDATE'
      ),
      false
    ),
    'Data API cần SELECT, INSERT và UPDATE cho authenticated'

  union all

  select
    8,
    'anon không thể đọc bảng users',
    not coalesce(
      has_table_privilege('anon', to_regclass('public.users'), 'SELECT'),
      false
    ),
    'Khách chỉ được đọc leaderboard, không đọc trực tiếp profile table'

  union all

  select
    9,
    'Hàm private.set_updated_at tồn tại',
    to_regprocedure('private.set_updated_at()') is not null,
    'Trigger function nằm ngoài schema public'

  union all

  select
    10,
    'Trigger updated_at tồn tại',
    exists (
      select 1
      from pg_trigger
      where tgrelid = to_regclass('public.users')
        and tgname = 'users_set_updated_at'
        and not tgisinternal
    ),
    'updated_at tự đổi khi profile được cập nhật'

  union all

  select
    11,
    'Index leaderboard tồn tại',
    to_regclass('public.users_leaderboard_sort_idx') is not null,
    'Tối ưu sắp xếp theo tiền thưởng và level'

  union all

  select
    12,
    'View public.leaderboard tồn tại',
    exists (
      select 1
      from pg_class
      where oid = to_regclass('public.leaderboard')
        and relkind = 'v'
    ),
    coalesce(to_regclass('public.leaderboard')::text, 'Không tìm thấy')

  union all

  select
    13,
    'Leaderboard bật security barrier',
    coalesce(
      (
        select reloptions @> array['security_barrier=true']
        from pg_class
        where oid = to_regclass('public.leaderboard')
      ),
      false
    ),
    'Bảo vệ lớp che auth_uuid trong view'

  union all

  select
    14,
    'anon và authenticated đọc được leaderboard',
    coalesce(
      has_table_privilege(
        'anon',
        to_regclass('public.leaderboard'),
        'SELECT'
      ),
      false
    )
    and coalesce(
      has_table_privilege(
        'authenticated',
        to_regclass('public.leaderboard'),
        'SELECT'
      ),
      false
    ),
    'Leaderboard dùng được trước và sau khi đăng nhập'

  union all

  select
    15,
    'Supabase Cron đã được bật',
    exists (
      select 1
      from pg_extension
      where extname = 'pg_cron'
    ),
    'Extension pg_cron cung cấp scheduler cho các job định kỳ'

  union all

  select
    16,
    'Cron có catalog và API quản lý job',
    to_regclass('cron.job') is not null
    and (
      select count(distinct pg_proc.proname) = 2
      from pg_proc
      join pg_namespace
        on pg_namespace.oid = pg_proc.pronamespace
      where pg_namespace.nspname = 'cron'
        and pg_proc.proname in ('schedule', 'unschedule')
    ),
    'Dùng cron.schedule và cron.unschedule thay vì sửa cron.job trực tiếp'

  union all

  select
    17,
    'Role postgres quản lý được Cron',
    coalesce(
      has_schema_privilege(
        'postgres',
        to_regnamespace('cron'),
        'USAGE'
      ),
      false
    )
    and coalesce(
      has_table_privilege(
        'postgres',
        to_regclass('cron.job'),
        'SELECT'
      ),
      false
    ),
    'SQL Editor có quyền cấu hình và theo dõi job'

  union all

  select
    18,
    'Cron heartbeat mỗi 8 giờ đã active',
    exists (
      select 1
      from cron.job
      where jobname = 'keep-project-active-every-8-hours'
        and schedule = '0 */8 * * *'
        and active
    ),
    'Job chạy lúc 00:00, 08:00 và 16:00 UTC mỗi ngày'
)
select
  check_name,
  case when passed then 'PASS' else 'FAIL' end as status,
  details,
  case
    when bool_and(passed) over () then 'SETUP OK'
    else 'SETUP INCOMPLETE'
  end as overall_status
from checks
order by sort_order;
