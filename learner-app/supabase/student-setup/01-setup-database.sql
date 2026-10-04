-- Flutter Accelerator AI - Script 01: cài đặt database.
--
-- Cách chạy:
-- 1. Mở Supabase Dashboard > SQL Editor > New query.
-- 2. Sao chép toàn bộ file này và dán vào query.
-- 3. Bấm Run một lần và chờ thông báo thành công.
--
-- Script tạo cấu trúc database và cron heartbeat. Script không sao chép user,
-- dữ liệu thật, mật khẩu, API key, secret, hoặc cấu hình đăng nhập.

begin;

-- Bật Supabase Cron; job heartbeat được tạo sau khi public.users đã sẵn sàng.
create extension if not exists pg_cron with schema pg_catalog;

grant usage on schema cron to postgres;
grant all privileges on all tables in schema cron to postgres;

create schema if not exists private;
revoke all on schema private from public;

create table if not exists public.users (
  id bigint generated always as identity primary key,
  auth_uuid uuid not null,
  name text not null,
  avatar_url text,
  level smallint not null default 1,
  current_exp bigint not null default 0,
  total_games_played bigint not null default 0,
  total_question_count bigint not null default 0,
  total_money_won bigint not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint users_auth_uuid_key unique (auth_uuid),
  constraint users_auth_uuid_fkey
    foreign key (auth_uuid)
    references auth.users (id)
    on delete cascade,
  constraint users_name_not_blank check (length(btrim(name)) > 0),
  constraint users_level_range check (level between 1 and 100),
  constraint users_current_exp_nonnegative check (current_exp >= 0),
  constraint users_total_games_played_nonnegative
    check (total_games_played >= 0),
  constraint users_total_question_count_nonnegative
    check (total_question_count >= 0),
  constraint users_total_money_won_nonnegative check (total_money_won >= 0)
);

create index if not exists users_leaderboard_sort_idx
on public.users (total_money_won desc, level desc, updated_at, id);

create or replace function private.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $function$
begin
  new.updated_at = statement_timestamp();
  return new;
end;
$function$;

revoke all on function private.set_updated_at() from public, anon, authenticated;

drop trigger if exists users_set_updated_at on public.users;

create trigger users_set_updated_at
before update on public.users
for each row
execute function private.set_updated_at();

alter table public.users enable row level security;

revoke all on table public.users from public, anon, authenticated;
revoke all on sequence public.users_id_seq from public, anon, authenticated;

-- Các GRANT này là bắt buộc cho Data API trên Supabase project mới.
grant usage on schema public to anon, authenticated;
grant select on table public.users to authenticated;
grant insert (
  auth_uuid,
  name,
  avatar_url,
  level,
  current_exp,
  total_games_played,
  total_question_count,
  total_money_won
) on table public.users to authenticated;
grant update (
  name,
  avatar_url,
  level,
  current_exp,
  total_games_played,
  total_question_count,
  total_money_won
) on table public.users to authenticated;
grant usage, select on sequence public.users_id_seq to authenticated;

drop policy if exists users_select_own on public.users;
create policy users_select_own
on public.users
for select
to authenticated
using ((select auth.uid()) = auth_uuid);

drop policy if exists users_insert_own on public.users;
create policy users_insert_own
on public.users
for insert
to authenticated
with check ((select auth.uid()) = auth_uuid);

drop policy if exists users_update_own on public.users;
create policy users_update_own
on public.users
for update
to authenticated
using ((select auth.uid()) = auth_uuid)
with check ((select auth.uid()) = auth_uuid);

-- View chạy với quyền của owner để xếp hạng toàn bộ profile trong khi bảng
-- users vẫn chỉ cho mỗi user đọc dòng của chính mình. auth_uuid của người khác
-- luôn bị che; security_barrier ngăn predicate chạy bên dưới lớp che này.
create or replace view public.leaderboard
with (security_barrier = true)
as
select
  row_number() over (
    order by
      users.total_money_won desc,
      users.level desc,
      users.updated_at,
      users.id
  ) as rank,
  case
    when users.auth_uuid = (select auth.uid()) then users.auth_uuid
    else null::uuid
  end as auth_uuid,
  users.name,
  users.avatar_url,
  users.level,
  users.total_money_won
from public.users;

revoke all on table public.leaderboard from public, anon, authenticated;
grant select on table public.leaderboard to anon, authenticated;

comment on table public.users is
  'Owner-scoped Flutter Accelerator AI account profile and progression data.';
comment on view public.leaderboard is
  'Public ranked profile display with auth UUID visible only on the caller row.';

-- Tạo heartbeat không cần URL hoặc API key cho project mới. Nếu job đã tồn tại
-- (ví dụ đang gọi REST API), giữ nguyên command và chỉ chuẩn hóa lịch/trạng thái.
select cron.schedule(
  'keep-project-active-every-8-hours',
  '0 */8 * * *',
  'select exists (select 1 from public.users);'
)
where not exists (
  select 1
  from cron.job
  where jobname = 'keep-project-active-every-8-hours'
);

select cron.alter_job(
  job_id := (
    select jobid
    from cron.job
    where jobname = 'keep-project-active-every-8-hours'
  ),
  schedule := '0 */8 * * *',
  active := true
);

notify pgrst, 'reload schema';

commit;
