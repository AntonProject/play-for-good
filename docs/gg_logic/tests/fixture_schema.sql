-- TEST FIXTURE ONLY, for a disposable local Postgres database.
-- Never execute on the real Supabase project.
do $$ begin
  if not exists(select 1 from pg_roles where rolname='anon') then create role anon; end if;
  if not exists(select 1 from pg_roles where rolname='authenticated') then create role authenticated; end if;
end $$;
create schema auth;
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid;
$$;
grant usage on schema auth to anon,authenticated;
grant execute on function auth.uid() to anon,authenticated;
create table public.users(
  id uuid primary key,created_at timestamp default now(),email text,
  display_name text,first_name text,surname text,photo_url text
);
create table public.games(
  id uuid primary key,created_at timestamp default now(),status text,
  creator_user_id uuid references public.users(id),game_date timestamp,
  lichtwatt double precision,title text,organization_id uuid,
  user_money double precision,team_money double precision,sieg_money double precision,
  additional_donation_money double precision,sponsor_money double precision
);
create table public.invites(
  id uuid primary key,inviter_user_id uuid references public.users(id),
  used_at timestamp,was_used boolean,lichtwatt double precision,invited_email text
);
alter table public.users enable row level security;
alter table public.games enable row level security;
alter table public.invites enable row level security;
grant select on public.users,public.games,public.invites to anon,authenticated;
create policy users_public_read on public.users for select to anon,authenticated using(true);
create policy games_public_read on public.games for select to anon,authenticated using(true);
create policy invites_owner_read on public.invites for select to authenticated
  using(inviter_user_id=(select auth.uid()));
create schema realtime;
create table realtime.test_events(
  payload jsonb,event text,topic text,is_private boolean
);
create function realtime.send(payload jsonb,event text,topic text,is_private boolean)
returns void language sql as $$
  insert into realtime.test_events values(payload,event,topic,is_private);
$$;
insert into public.users(id,display_name,email)
select ('00000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,
  'Player '||n,'private-'||n||'@example.invalid' from generate_series(1,6) n;
insert into public.games(id,creator_user_id,game_date,lichtwatt,status,user_money,sponsor_money)
values
('10000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','2025-11-20',100,'completed',10,0),
('10000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000002','2026-08-31 23:59:59.999999',80,'completed',30,1),
('10000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000003','2026-07-12',40,'completed',20,0),
('10000000-0000-0000-0000-000000000011','00000000-0000-0000-0000-000000000001','2026-09-01',10,'completed',2,0),
('10000000-0000-0000-0000-000000000012','00000000-0000-0000-0000-000000000002','2027-06-30 23:59:59.999999',20,'completed',3,0),
('10000000-0000-0000-0000-000000000013','00000000-0000-0000-0000-000000000003','2026-09-15',15,'completed',4,1),
('10000000-0000-0000-0000-000000000014','00000000-0000-0000-0000-000000000004','2026-12-20',50,'completed',7,0),
('10000000-0000-0000-0000-000000000021','00000000-0000-0000-0000-000000000001','2025-11-19 23:59:59.999999',13,'completed',1,0),
('10000000-0000-0000-0000-000000000022','00000000-0000-0000-0000-000000000004','2027-07-01',23,'completed',1,0),
('10000000-0000-0000-0000-000000000023','00000000-0000-0000-0000-000000000001',null,7,'completed',1,0),
('10000000-0000-0000-0000-000000000024','00000000-0000-0000-0000-000000000002','2026-08-31',999,'pending',1,0);
insert into public.games(id,creator_user_id,game_date,lichtwatt,status,user_money,sponsor_money)
select ('20000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,
  '00000000-0000-0000-0000-000000000004','2026-08-20',1,'completed',1,0
from generate_series(1,5) n;
insert into public.invites values
('30000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002','2026-08-31',true,30,'hidden@example.invalid'),
('30000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000001','2026-09-01',true,10,'hidden@example.invalid'),
('30000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000003',null,true,9,'hidden@example.invalid'),
('30000000-0000-0000-0000-000000000004','00000000-0000-0000-0000-000000000005','2026-08-20',true,2,'hidden@example.invalid'),
('30000000-0000-0000-0000-000000000005','00000000-0000-0000-0000-000000000002','2026-08-20',false,999,'hidden@example.invalid');
