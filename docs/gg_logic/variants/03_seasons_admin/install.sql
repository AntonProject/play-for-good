-- LOCAL PREPARATION ONLY: admin
-- SOURCE: shared/00_seasons.sql
-- Local preparation only. Execute before 01_functions.sql, on owner's command.
begin;
create schema if not exists gg_v2;
revoke all on schema gg_v2 from public;

create table if not exists gg_v2.seasons (
  season_key text primary key,
  label text not null,
  season_year integer not null,
  starts_at timestamp not null,
  ends_at timestamp not null,
  check (ends_at > starts_at)
);

-- Public profile fields only. No FK to users: account deletion must not cascade
-- into a finalized competition result. RPC can use current name/photo if available.
create table if not exists gg_v2.season_results (
  season_key text not null references gg_v2.seasons(season_key),
  test boolean not null default false,
  user_id uuid not null,
  display_name text, first_name text, surname text, photo_url text,
  good_power numeric not null, game_power numeric not null, invite_power numeric not null,
  games_count bigint not null, good_energy numeric not null,
  good_power_per_game numeric not null, good_energy_per_game numeric not null,
  sponsored_games bigint not null,
  power_rank bigint, games_rank bigint, power_per_game_rank bigint,
  energy_rank bigint, energy_per_game_rank bigint, sponsored_games_rank bigint,
  primary key(season_key,test,user_id)
);

alter table gg_v2.seasons enable row level security;
alter table gg_v2.season_results enable row level security;
revoke all on gg_v2.seasons,gg_v2.season_results from public,anon,authenticated;
create index if not exists gg_v2_season_results_power_rank
  on gg_v2.season_results(season_key,test,power_rank) where power_rank is not null;
create index if not exists gg_v2_season_results_games_rank
  on gg_v2.season_results(season_key,test,games_rank) where games_rank is not null;

create table if not exists gg_v2.season_closures (
  season_key text not null references gg_v2.seasons(season_key),
  test boolean not null, finalized_at timestamptz,
  primary key(season_key,test)
);
alter table gg_v2.season_closures enable row level security;
revoke all on gg_v2.season_closures from public,anon,authenticated;
insert into gg_v2.seasons(season_key,label,season_year,starts_at,ends_at) values
  ('season_2025_26','Saison 2025/26',2026,'2025-11-20','2026-09-01'),
  ('season_2026_27','Saison 2026/27',2027,'2026-09-01','2027-07-01')
on conflict(season_key) do nothing;
commit;

-- SOURCE: shared/01_environment_bonus.sql
-- LOCAL PACKAGE. Apply only on owner's command, after 00_seasons.sql.
begin;
alter table public.games add column if not exists test boolean not null default false;
alter table public.invites add column if not exists test boolean not null default false;
alter table public.users add column if not exists signup_test boolean not null default false;

create table if not exists gg_v2.point_awards (
  user_id uuid not null references public.users(id) on delete cascade,
  test boolean not null default false,
  reason text not null check(reason='signup_bonus'),
  amount numeric not null check(amount=100),
  awarded_at timestamp not null,
  primary key(user_id,test,reason)
);
alter table gg_v2.point_awards enable row level security;
revoke all on gg_v2.point_awards from public,anon,authenticated;

-- Uses the authenticated account, never a client-provided user/amount/date.
-- Registration date: Auth.created_at in UTC, not the deployment/backfill date.
create or replace function gg_v2.ensure_signup_bonus(p_user uuid,p_test boolean)
returns boolean language plpgsql volatile security definer set search_path='' as $$
declare d timestamp; n integer;
begin
  select a.created_at at time zone 'UTC' into d from auth.users a
  join public.users u on u.id=a.id
  where a.id=p_user and nullif(a.email,'') is not null
    and a.email_confirmed_at is not null;
  if d is null then return false; end if;
  insert into gg_v2.point_awards(user_id,test,reason,amount,awarded_at)
    values(p_user,p_test,'signup_bonus',100,d) on conflict do nothing;
  get diagnostics n=row_count;
  return n>0;
end; $$;
revoke all on function gg_v2.ensure_signup_bonus(uuid,boolean) from public,anon,authenticated;

create or replace function gg_v2.claim_signup_bonus(p_test boolean default false)
returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare u uuid:=auth.uid(); added boolean;
begin
  if u is null then raise exception 'Sign in required' using errcode='42501'; end if;
  added:=gg_v2.ensure_signup_bonus(u,p_test);
  return jsonb_build_object('created',added,'test',p_test,
    'awarded',exists(select 1 from gg_v2.point_awards a where a.user_id=u and a.test=p_test));
end; $$;
revoke all on function gg_v2.claim_signup_bonus(boolean) from public,anon,authenticated;
grant execute on function gg_v2.claim_signup_bonus(boolean) to authenticated;
create or replace function public.gg_v2_claim_signup_bonus(p_test boolean default false)
returns jsonb language sql volatile security invoker set search_path='' as $$
  select gg_v2.claim_signup_bonus(p_test);
$$;
revoke all on function public.gg_v2_claim_signup_bonus(boolean) from public,anon,authenticated;
grant execute on function public.gg_v2_claim_signup_bonus(boolean) to authenticated;

-- Old clients do not send signup_test => false => production bonus.
-- New test signup must put signup_test=true into the profile INSERT.
create or replace function gg_v2.bonus_on_profile() returns trigger
language plpgsql volatile security definer set search_path='' as $$
begin
  perform gg_v2.ensure_signup_bonus(new.id,new.signup_test);
  return new;
end; $$;
revoke all on function gg_v2.bonus_on_profile() from public,anon,authenticated;
create or replace trigger gg_v2_profile_signup_bonus after insert
  on public.users for each row execute function gg_v2.bonus_on_profile();
commit;

-- Historical backfill is EXPLICIT, before the first season finalization:
-- select gg_v2.ensure_signup_bonus(u.id,u.signup_test) from public.users u;
-- Rehearse this against the project schema; unconfirmed Auth accounts get no bonus.
-- This changes no games/invites and does not double-count in old app versions.

-- SOURCE: shared/02_scoring.sql
-- Local preparation only. Do not execute against the live project without
-- the owner's command. This supersedes docs/gg_rpc_listener/example.sql.
begin;
create schema if not exists gg_v2;
revoke all on schema gg_v2 from public;
grant usage on schema gg_v2 to anon, authenticated;

-- Confirm timezone before live use. Existing date columns are timestamp
-- without time zone; their stored values are compared directly to boundaries.
-- timezone controls the calendar clock, not a conversion of historical rows.
create or replace function gg_v2.config() returns jsonb
language sql immutable security invoker set search_path = '' as $$
  select jsonb_build_object('timezone', 'UTC', 'tie_policy', 'sequential');
$$;

-- Dates come from the table. The basic/RPC packages seed only the two
-- specified seasons; only the admin package can plan subsequent seasons.
create or replace function gg_v2.period_info(
  p_period text,p_now timestamptz default transaction_timestamp()
) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare
  k text := lower(btrim(coalesce(p_period,'auto')));
  c timestamp := p_now at time zone (gg_v2.config()->>'timezone');
  s gg_v2.seasons%rowtype; a timestamp; b timestamp; label text;
begin
  k := case k when 'gesamt' then 'all_time' when 'all-time' then 'all_time'
    when 'saison' then 'auto' when 'saison_2025_26' then 'season_2025_26'
    when 'saison_2026_27' then 'season_2026_27' when 'letzter_monat' then 'last_month'
    when 'dieser_monat' then 'this_month' when 'monat' then 'this_month' else k end;
  if k='auto' then
    select t.season_key into k from gg_v2.seasons t where t.starts_at<=c
      order by t.starts_at desc limit 1;
    k := coalesce(k,'all_time');
  end if;
  select * into s from gg_v2.seasons t where t.season_key=k;
  if found then
    return jsonb_build_object('key',k,'label',s.label,'season_year',s.season_year,
      'period_start',s.starts_at,'period_end_exclusive',s.ends_at,
      'timezone',gg_v2.config()->>'timezone','is_completed',c>=s.ends_at);
  end if;
  case k
    when 'last_month' then b:=date_trunc('month',c); a:=b-interval '1 month'; label:='Letzten Monat';
    when 'this_month' then a:=date_trunc('month',c); b:=a+interval '1 month'; label:='Diesen Monat';
    when 'all_time' then label:='All-Time';
    else raise exception 'Unknown GG period: %',p_period using errcode='22023';
  end case;
  return jsonb_build_object('key',k,'label',label,'season_year',null,
    'period_start',a,'period_end_exclusive',b,'timezone',gg_v2.config()->>'timezone',
    'is_completed',false);
end; $$;

create or replace function gg_v2.season_periods(
  p_now timestamptz default transaction_timestamp()
) returns table(period jsonb) language sql stable security definer set search_path='' as $$
  select gg_v2.period_info(t.season_key,p_now) from gg_v2.seasons t;
$$;

create or replace function gg_v2.available_periods() returns jsonb
language sql stable security definer set search_path='' as $$
  select coalesce(jsonb_agg(p.period order by p.period->>'period_start' desc),'[]'::jsonb)
    ||jsonb_build_array(gg_v2.period_info('last_month'),gg_v2.period_info('this_month'),gg_v2.period_info('all_time'))
  from gg_v2.season_periods() p;
$$;

create or replace function gg_v2.category_key(p_category text)
returns text language plpgsql immutable security invoker set search_path='' as $$
declare v_key text := lower(btrim(coalesce(p_category,'valuable')));
begin
  if v_key in ('valuable','mvp','most_valuable_player') then return 'valuable'; end if;
  if v_key in ('active','map','most_active_player') then return 'active'; end if;
  raise exception 'Unknown GG category: %',p_category using errcode='22023';
end;
$$;

-- Deliberately public aggregate data. Guest access is part of the current app.
-- The private-schema definer is required to include other users' invitation
-- earnings despite inviter-only SELECT RLS. It never returns raw invites/email.
-- Keep gg_v2 OUT of the Data API exposed schemas. No service key on client.
-- Aggregate live periods once per source. Closed seasons/awards use frozen results.
create or replace function gg_v2.score_sets(p_period text,p_test boolean default false)
returns table (
  bucket text, user_id uuid, display_name text, first_name text, surname text,
  photo_url text, good_power numeric, game_power numeric, invite_power numeric,
  games_count bigint, good_energy numeric, good_power_per_game numeric,
  good_energy_per_game numeric, sponsored_games bigint,
  power_rank bigint, games_rank bigint, power_per_game_rank bigint,
  energy_rank bigint, energy_per_game_rank bigint, sponsored_games_rank bigint
) language plpgsql stable security definer set search_path='' as $$
declare
  v_info jsonb := gg_v2.period_info(p_period);
  v_start timestamp := (v_info->>'period_start')::timestamp;
  v_end timestamp := (v_info->>'period_end_exclusive')::timestamp;
  v_shared boolean := gg_v2.config()->>'tie_policy' = 'shared';
  v_frozen boolean := exists(select 1 from gg_v2.season_closures t
    where t.season_key=v_info->>'key' and t.test=p_test and t.finalized_at is not null);
begin
  return query with game_events as (
    select g.creator_user_id,
      coalesce(g.lichtwatt::numeric,0) as gp,
      coalesce(g.user_money::numeric,0)+coalesce(g.team_money::numeric,0)
        +coalesce(g.sieg_money::numeric,0)
        +coalesce(g.additional_donation_money::numeric,0) as energy,
      coalesce(g.sponsor_money,0)>0 as sponsored,
      not v_frozen and (v_start is null or g.game_date>=v_start)
        and (v_end is null or g.game_date<v_end) as selected
    from public.games g where g.status='completed' and g.test=p_test
  ), game_totals as (
    select e.creator_user_id,
      coalesce(sum(e.gp) filter(where e.selected),0) as sel_gp,
      count(*) filter(where e.selected) as sel_count,
      coalesce(sum(e.energy) filter(where e.selected),0) as sel_energy,
      count(*) filter(where e.selected and e.sponsored) as sel_sponsored,
      sum(e.gp) as all_gp,count(*) as all_count,
      sum(e.energy) as all_energy,count(*) filter(where e.sponsored) as all_sponsored
    from game_events e group by e.creator_user_id
  ), invite_events as (
    select i.inviter_user_id,coalesce(i.lichtwatt::numeric,0) as gp,
      not v_frozen and (v_start is null or i.used_at>=v_start)
        and (v_end is null or i.used_at<v_end) as selected
    from public.invites i where i.was_used=true and i.test=p_test
  ), invite_totals as (
    select e.inviter_user_id,
      coalesce(sum(e.gp) filter(where e.selected),0) as sel_gp,sum(e.gp) as all_gp
    from invite_events e group by e.inviter_user_id
  ), bonus_totals as (
    select a.user_id,coalesce(sum(a.amount) filter(where not v_frozen
      and (v_start is null or a.awarded_at>=v_start)
      and (v_end is null or a.awarded_at<v_end)),0) as sel_gp,
      sum(a.amount) as all_gp
    from gg_v2.point_awards a where a.test=p_test group by a.user_id
  ), scores as (
    select b.bucket,u.id as user_id,u.display_name::text,u.first_name::text,u.surname::text,u.photo_url::text,
      b.gp+b.invite_gp+b.bonus_gp as good_power,b.gp as game_power,b.invite_gp as invite_power,
      b.game_count as games_count,b.energy as good_energy,
      case when b.game_count>0 then b.gp/b.game_count else 0 end as good_power_per_game,
      case when b.game_count>0 then b.energy/b.game_count else 0 end as good_energy_per_game,
      b.sponsored as sponsored_games
    from public.users u
    left join game_totals g on g.creator_user_id=u.id
    left join invite_totals i on i.inviter_user_id=u.id
    left join bonus_totals a on a.user_id=u.id
    cross join lateral (values
      ('selected',coalesce(g.sel_gp,0),coalesce(i.sel_gp,0),coalesce(a.sel_gp,0),
        coalesce(g.sel_count,0),coalesce(g.sel_energy,0),coalesce(g.sel_sponsored,0)),
      ('all_time',coalesce(g.all_gp,0),coalesce(i.all_gp,0),coalesce(a.all_gp,0),
        coalesce(g.all_count,0),coalesce(g.all_energy,0),coalesce(g.all_sponsored,0))
    ) as b(bucket,gp,invite_gp,bonus_gp,game_count,energy,sponsored)
    where b.bucket<>'selected' or not v_frozen
  ), live_ranked as (
  select s.*,
    case when s.good_power>0 then case when v_shared
      then rank() over(partition by s.bucket order by s.good_power desc)
      else row_number() over(partition by s.bucket order by s.good_power desc,s.user_id)
      end end as power_rank,
    case when s.games_count>0 then case when v_shared
      then rank() over(partition by s.bucket order by s.games_count desc)
      else row_number() over(partition by s.bucket order by s.games_count desc,s.user_id)
      end end as games_rank,
    case when s.games_count>0 then case when v_shared
      then rank() over(partition by s.bucket order by (s.games_count>0) desc,s.good_power_per_game desc)
      else row_number() over(partition by s.bucket order by (s.games_count>0) desc,s.good_power_per_game desc,s.user_id)
      end end as power_per_game_rank,
    case when s.good_energy>0 then case when v_shared
      then rank() over(partition by s.bucket order by s.good_energy desc)
      else row_number() over(partition by s.bucket order by s.good_energy desc,s.user_id)
      end end as energy_rank,
    case when s.games_count>0 then case when v_shared
      then rank() over(partition by s.bucket order by (s.games_count>0) desc,s.good_energy_per_game desc)
      else row_number() over(partition by s.bucket order by (s.games_count>0) desc,s.good_energy_per_game desc,s.user_id)
      end end as energy_per_game_rank,
    case when s.sponsored_games>0 then case when v_shared
      then rank() over(partition by s.bucket order by s.sponsored_games desc)
      else row_number() over(partition by s.bucket order by s.sponsored_games desc,s.user_id)
      end end as sponsored_games_rank
  from scores s
  ), frozen_selected as (
    select 'selected'::text as bucket,coalesce(r.user_id,u.id) as user_id,
      coalesce(u.display_name,r.display_name)::text as display_name,
      coalesce(u.first_name,r.first_name)::text as first_name,
      coalesce(u.surname,r.surname)::text as surname,
      coalesce(u.photo_url,r.photo_url)::text as photo_url,
      coalesce(r.good_power,0) as good_power,coalesce(r.game_power,0) as game_power,
      coalesce(r.invite_power,0) as invite_power,coalesce(r.games_count,0) as games_count,
      coalesce(r.good_energy,0) as good_energy,coalesce(r.good_power_per_game,0) as good_power_per_game,
      coalesce(r.good_energy_per_game,0) as good_energy_per_game,
      coalesce(r.sponsored_games,0) as sponsored_games,
      r.power_rank,r.games_rank,r.power_per_game_rank,r.energy_rank,
      r.energy_per_game_rank,r.sponsored_games_rank
    from (select * from gg_v2.season_results sr where sr.season_key=v_info->>'key' and sr.test=p_test) r
    full join public.users u on u.id=r.user_id where v_frozen
  ), frozen_awards as (
    select 'award:'||r.season_key as bucket,r.user_id,
      coalesce(u.display_name,r.display_name)::text,coalesce(u.first_name,r.first_name)::text,
      coalesce(u.surname,r.surname)::text,coalesce(u.photo_url,r.photo_url)::text,
      r.good_power,r.game_power,r.invite_power,r.games_count,r.good_energy,
      r.good_power_per_game,r.good_energy_per_game,r.sponsored_games,
      r.power_rank,r.games_rank,r.power_per_game_rank,r.energy_rank,
      r.energy_per_game_rank,r.sponsored_games_rank
    from gg_v2.season_results r join gg_v2.season_closures t using(season_key,test)
    left join public.users u on u.id=r.user_id
    where r.test=p_test and t.finalized_at is not null and (r.power_rank between 1 and 3 or r.games_rank between 1 and 3)
  )
  select * from live_ranked union all select * from frozen_selected union all select * from frozen_awards;
end;
$$;

create or replace function gg_v2.award_flags(p_awards jsonb) returns jsonb
language sql immutable security invoker set search_path='' as $$
  select jsonb_build_object(
    'mvp_gold',coalesce(p_awards,'[]'::jsonb) @> '[{"category":"valuable","place":1}]',
    'mvp_silver',coalesce(p_awards,'[]'::jsonb) @> '[{"category":"valuable","place":2}]',
    'mvp_bronze',coalesce(p_awards,'[]'::jsonb) @> '[{"category":"valuable","place":3}]',
    'active_fire',coalesce(p_awards,'[]'::jsonb) @> '[{"category":"active","place":1}]',
    'map_silver',coalesce(p_awards,'[]'::jsonb) @> '[{"category":"active","place":2}]',
    'map_bronze',coalesce(p_awards,'[]'::jsonb) @> '[{"category":"active","place":3}]'
  );
$$;

create or replace function gg_v2.player_payload(
  p_score jsonb,p_category text,p_awards jsonb
) returns jsonb language sql immutable security invoker set search_path='' as $$
  select jsonb_build_object(
    'user_id',p_score->'user_id','display_name',p_score->'display_name',
    'first_name',p_score->'first_name','surname',p_score->'surname','photo_url',p_score->'photo_url',
    'good_power',p_score->'good_power','game_power',p_score->'game_power',
    'invite_power',p_score->'invite_power',
    'bonus_power',(p_score->>'good_power')::numeric-(p_score->>'game_power')::numeric-(p_score->>'invite_power')::numeric,'games_count',p_score->'games_count',
    'score',case when p_category='active' then p_score->'games_count' else p_score->'good_power' end,
    'rank',case when p_category='active' then p_score->'games_rank' else p_score->'power_rank' end,
    'awards',coalesce(p_awards,'[]'::jsonb),
    'award_flags',gg_v2.award_flags(p_awards)
  );
$$;

-- Restrict default EXECUTE grants. Helper schema is not exposed via PostgREST.
revoke all on function gg_v2.config() from public,anon,authenticated;
revoke all on function gg_v2.period_info(text,timestamptz) from public,anon,authenticated;
revoke all on function gg_v2.season_periods(timestamptz) from public,anon,authenticated;
revoke all on function gg_v2.available_periods() from public,anon,authenticated;
revoke all on function gg_v2.category_key(text) from public,anon,authenticated;
revoke all on function gg_v2.score_sets(text,boolean) from public,anon,authenticated;
revoke all on function gg_v2.award_flags(jsonb) from public,anon,authenticated;
revoke all on function gg_v2.player_payload(jsonb,text,jsonb) from public,anon,authenticated;
grant execute on function gg_v2.config(),gg_v2.period_info(text,timestamptz),
  gg_v2.season_periods(timestamptz),gg_v2.available_periods(),
  gg_v2.category_key(text),gg_v2.score_sets(text,boolean),gg_v2.award_flags(jsonb),
  gg_v2.player_payload(jsonb,text,jsonb) to anon,authenticated;
commit;

-- SOURCE: shared/03_finalize.sql
begin;
create or replace function gg_v2.finalize_season(
  p_season text,p_test boolean default false,p_now timestamptz default transaction_timestamp()
) returns boolean language plpgsql volatile security definer set search_path='' as $$
declare v_info jsonb:=gg_v2.period_info(p_season,p_now); v_finalized timestamptz;
begin
  if v_info->>'season_year' is null or not (v_info->>'is_completed')::boolean then
    raise exception 'Only an ended season can be finalized' using errcode='22023';
  end if;
  -- Lock the calendar row as well: admin edits cannot race with closure.
  perform 1 from gg_v2.seasons where season_key=v_info->>'key' for update;
  -- Re-read boundaries after obtaining the lock.
  v_info:=gg_v2.period_info(p_season,p_now);
  if not (v_info->>'is_completed')::boolean then
    raise exception 'Season has not ended' using errcode='22023';
  end if;
  insert into gg_v2.season_closures(season_key,test) values(v_info->>'key',p_test)
    on conflict do nothing;
  select t.finalized_at into v_finalized from gg_v2.season_closures t
    where t.season_key=v_info->>'key' and t.test=p_test for update;
  if v_finalized is not null then return false; end if;
  insert into gg_v2.season_results(
    season_key,test,user_id,display_name,first_name,surname,photo_url,
    good_power,game_power,invite_power,games_count,good_energy,
    good_power_per_game,good_energy_per_game,sponsored_games,
    power_rank,games_rank,power_per_game_rank,energy_rank,energy_per_game_rank,sponsored_games_rank)
  select v_info->>'key',p_test,s.user_id,s.display_name,s.first_name,s.surname,s.photo_url,
    s.good_power,s.game_power,s.invite_power,s.games_count,s.good_energy,
    s.good_power_per_game,s.good_energy_per_game,s.sponsored_games,
    s.power_rank,s.games_rank,s.power_per_game_rank,s.energy_rank,s.energy_per_game_rank,s.sponsored_games_rank
  from gg_v2.score_sets(p_season,p_test) s where s.bucket='selected';
  update gg_v2.season_closures set finalized_at=transaction_timestamp()
    where season_key=v_info->>'key' and test=p_test;
  perform realtime.send(jsonb_build_object('changed_at',transaction_timestamp()),'changed','gg:v2:stats',false);
  return true;
end; $$;

-- BASIC/RPC: close only existing calendar rows. No automatic future seasons.
create or replace function gg_v2.finalize_due_seasons(
  p_now timestamptz default transaction_timestamp()
) returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare s record; e boolean; closed jsonb:='[]'::jsonb;
begin
  for s in select season_key from gg_v2.seasons
    where ends_at<=p_now at time zone 'UTC' order by starts_at
  loop
    foreach e in array array[false,true] loop
      if gg_v2.finalize_season(s.season_key,e,p_now) then
        closed:=closed||jsonb_build_array(jsonb_build_object('season',s.season_key,'test',e));
      end if;
    end loop;
  end loop;
  return jsonb_build_object('finalized',closed);
end; $$;
revoke all on function gg_v2.finalize_season(text,boolean,timestamptz),
  gg_v2.finalize_due_seasons(timestamptz) from public,anon,authenticated;
commit;

-- SOURCE: shared/04_context.sql
-- Basic variant: game calculations stay on the client; server supplies calendar,
-- persisted contributions and frozen results. No raw invitations or emails.
begin;
create or replace function gg_v2.context(p_period text,p_test boolean)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare p jsonb:=gg_v2.period_info(p_period); a timestamp:=(p->>'period_start')::timestamp;
  b timestamp:=(p->>'period_end_exclusive')::timestamp; result jsonb;
begin
  with contributions as (
    select i.inviter_user_id as user_id,'invite'::text as source,i.lichtwatt::numeric as amount,i.used_at as d
      from public.invites i where i.was_used and i.test=p_test
    union all
    select x.user_id,'bonus',x.amount,x.awarded_at from gg_v2.point_awards x where x.test=p_test
  ), sums as (
    select c.user_id,
      coalesce(sum(c.amount) filter(where c.source='invite'),0) as all_invite,
      coalesce(sum(c.amount) filter(where c.source='bonus'),0) as all_bonus,
      coalesce(sum(c.amount) filter(where c.source='invite' and (a is null or c.d>=a) and (b is null or c.d<b)),0) as selected_invite,
      coalesce(sum(c.amount) filter(where c.source='bonus' and (a is null or c.d>=a) and (b is null or c.d<b)),0) as selected_bonus
    from contributions c join public.users u on u.id=c.user_id group by c.user_id
  ), medals as (
    select r.user_id,jsonb_build_object('season',r.season_key,'season_year',s.season_year,
      'category',v.category,'place',v.place,'badge',case when v.category='valuable' then
        case v.place when 1 then 'mvp_gold' when 2 then 'mvp_silver' else 'mvp_bronze' end
        else case v.place when 1 then 'active_fire' when 2 then 'map_silver' else 'map_bronze' end end) as award
    from gg_v2.season_results r join gg_v2.seasons s using(season_key)
    join gg_v2.season_closures z using(season_key,test)
    cross join lateral (values('valuable',r.power_rank),('active',r.games_rank)) v(category,place)
    where r.test=p_test and z.finalized_at is not null and v.place between 1 and 3
  ), awards as (
    select m.user_id,jsonb_agg(m.award order by
      case when m.award->>'category'='valuable' then 0 else 1 end,
      (m.award->>'season_year')::integer desc,m.award->>'season',
      (m.award->>'place')::integer) as items
      from medals m group by m.user_id
  )
  select jsonb_build_object('test',p_test,'period',p,'available_periods',gg_v2.available_periods(),
    'contributions',coalesce((select jsonb_agg(to_jsonb(s)) from sums s),'[]'::jsonb),
    'awards_by_user',coalesce((select jsonb_object_agg(x.user_id,x.items) from awards x),'{}'::jsonb),
    'is_finalized',exists(select 1 from gg_v2.season_closures z where z.season_key=p->>'key' and z.test=p_test and z.finalized_at is not null),
    'frozen_players',coalesce((select jsonb_agg(to_jsonb(r)-'test'-'season_key') from gg_v2.season_results r
      where r.season_key=p->>'key' and r.test=p_test),'[]'::jsonb),
    'total_good_power_all_time',coalesce((select sum(g.lichtwatt::numeric) from public.games g join public.users u on u.id=g.creator_user_id
      where g.test=p_test and g.status='completed'),0)+coalesce((select sum(s.all_invite+s.all_bonus) from sums s),0))
    into result;
  return result;
end; $$;
revoke all on function gg_v2.context(text,boolean) from public,anon,authenticated;
grant execute on function gg_v2.context(text,boolean) to anon,authenticated;
create or replace function public.gg_v2_context(p_period text default 'auto',p_test boolean default false)
returns jsonb language sql stable security invoker set search_path='' as $$ select gg_v2.context(p_period,p_test); $$;
revoke all on function public.gg_v2_context(text,boolean) from public,anon,authenticated;
grant execute on function public.gg_v2_context(text,boolean) to anon,authenticated;
commit;

-- SOURCE: 02_rpc/10_rpc.sql
begin;
-- Public RPC #1: paged ranking, podium and the selected user's row in ONE read.
create or replace function public.gg_v2_rankings(
  p_period text default 'auto', p_category text default 'valuable',
  p_page integer default 1, p_page_size integer default 10, p_user_id uuid default null,p_test boolean default false
) returns jsonb language plpgsql stable security invoker set search_path='' as $$
declare
  v_category text := gg_v2.category_key(p_category);
  v_period jsonb := gg_v2.period_info(p_period);
  v_result jsonb;
begin
  if p_page is null or p_page<1 or p_page_size is null or p_page_size<1 or p_page_size>100 then
    raise exception 'page must be >=1; page_size must be 1..100' using errcode='22023';
  end if;
  with scores as materialized (select * from gg_v2.score_sets(p_period,p_test)),
  award_rows as (
    select s.user_id,jsonb_build_object('season',p.period->>'key',
      'season_year',(p.period->>'season_year')::integer,
      'category',r.category,'place',r.place,'badge',
      case when r.category='valuable' then
        case r.place when 1 then 'mvp_gold' when 2 then 'mvp_silver' else 'mvp_bronze' end
      else case r.place when 1 then 'active_fire' when 2 then 'map_silver' else 'map_bronze' end end) as award
    from scores s join gg_v2.season_periods() p on s.bucket='award:'||(p.period->>'key')
    cross join lateral (values ('valuable',s.power_rank),('active',s.games_rank)) r(category,place)
    where r.place between 1 and 3
      and (v_period->>'season_year' is null or p.period->>'key'=v_period->>'key')
  ), awards as (
    select a.user_id,jsonb_agg(a.award order by
      case when a.award->>'category'='valuable' then 0 else 1 end,
      (a.award->>'season_year')::integer desc,a.award->>'season',
      (a.award->>'place')::integer) as items
    from award_rows a group by a.user_id
  ), players as (
    select s.user_id,case when v_category='active' then s.games_count else s.good_power end as score,
      gg_v2.player_payload(to_jsonb(s),v_category,a.items) as payload
    from scores s left join awards a on a.user_id=s.user_id where s.bucket='selected'
  ), eligible as (select * from players where score>0),
  page_rows as (
    select * from eligible order by score desc,user_id
    offset ((p_page::bigint-1)*p_page_size) limit p_page_size
  ), top_rows as (select * from eligible order by score desc,user_id limit 3)
  select jsonb_build_object('requested_period',coalesce(p_period,'auto'),
    'requested_category',coalesce(p_category,'valuable'),
    'requested_user_id',p_user_id,
    'test',p_test,'period',v_period,'available_periods',gg_v2.available_periods(),'category',v_category,
    'total_good_power',coalesce((select sum(s.good_power) from scores s where s.bucket='selected'),0),
    'total_good_power_all_time',coalesce((select sum(s.good_power) from scores s where s.bucket='all_time'),0),
    'top_players',coalesce((select jsonb_agg(t.payload order by t.score desc,t.user_id) from top_rows t),'[]'::jsonb),
    'players',coalesce((select jsonb_agg(p.payload order by p.score desc,p.user_id) from page_rows p),'[]'::jsonb),
    'current_user',(select p.payload from players p where p.user_id=p_user_id),
    'pagination',jsonb_build_object('page',p_page,'page_size',p_page_size,
      'total_count',(select count(*) from eligible),
      'has_more',(select count(*) from eligible)>p_page::bigint*p_page_size)
  ) into v_result;
  return v_result;
end;
$$;

-- Public RPC #2: profile statistics + All-Time header + completed-season badges.
create or replace function public.gg_v2_profile_stats(
  p_user_id uuid,p_period text default 'auto',p_test boolean default false
) returns jsonb language plpgsql stable security invoker set search_path='' as $$
declare v_result jsonb; v_period jsonb := gg_v2.period_info(p_period);
begin
  if p_user_id is null then raise exception 'user_id is required' using errcode='22023'; end if;
  with scores as materialized (select * from gg_v2.score_sets(p_period,p_test)),
  user_awards as (
    select jsonb_build_object('season',p.period->>'key',
      'season_year',(p.period->>'season_year')::integer,
      'category',r.category,'place',r.place,'badge',
      case when r.category='valuable' then
        case r.place when 1 then 'mvp_gold' when 2 then 'mvp_silver' else 'mvp_bronze' end
      else case r.place when 1 then 'active_fire' when 2 then 'map_silver' else 'map_bronze' end end) as award
    from scores s join gg_v2.season_periods() p on s.bucket='award:'||(p.period->>'key')
    cross join lateral (values ('valuable',s.power_rank),('active',s.games_rank)) r(category,place)
    where s.user_id=p_user_id and r.place between 1 and 3
  ), awards as (select coalesce(jsonb_agg(a.award order by
    case when a.award->>'category'='valuable' then 0 else 1 end,
    (a.award->>'season_year')::integer desc,a.award->>'season',
    (a.award->>'place')::integer),'[]'::jsonb) as items from user_awards a)
  select jsonb_build_object('user_id',s.user_id,'requested_period',coalesce(p_period,'auto'),
    'test',p_test,'period',v_period,'available_periods',gg_v2.available_periods(),'display_name',s.display_name,'photo_url',s.photo_url,
    'total_good_power',coalesce((select sum(x.good_power) from scores x where x.bucket='selected'),0),
    'total_good_power_all_time',coalesce((select sum(x.good_power) from scores x where x.bucket='all_time'),0),
    'all_time',jsonb_build_object('good_power',a.good_power,'rank',a.power_rank,'games_count',a.games_count),
    'stats',jsonb_build_object(
      'good_power',jsonb_build_object('value',s.good_power,'rank',s.power_rank),
      'games',jsonb_build_object('value',s.games_count,'rank',s.games_rank),
      'good_power_per_game',jsonb_build_object('value',s.good_power_per_game,'rank',s.power_per_game_rank),
      'good_energy',jsonb_build_object('value',s.good_energy,'rank',s.energy_rank),
      'good_energy_per_game',jsonb_build_object('value',s.good_energy_per_game,'rank',s.energy_per_game_rank),
      'sponsored_games',jsonb_build_object('value',s.sponsored_games,'rank',s.sponsored_games_rank)),
    'awards',aw.items,'award_flags',gg_v2.award_flags(aw.items)) into v_result
  from scores s join scores a on a.user_id=s.user_id and a.bucket='all_time'
  cross join awards aw where s.bucket='selected' and s.user_id=p_user_id;
  if v_result is null then raise exception 'Profile not found' using errcode='P0002'; end if;
  return v_result;
end;
$$;

-- Public RPC #3: bounded game history for Meine Games, preserving GamesRow UI.
-- Native RLS applies; games are already publicly readable in the current app.
create or replace function public.gg_v2_games(
  p_user_id uuid,p_period text default 'auto',p_category text default 'valuable',
  p_page integer default 1,p_page_size integer default 10,p_test boolean default false
) returns jsonb language plpgsql stable security invoker set search_path='' as $$
declare
  v_period jsonb := gg_v2.period_info(p_period);
  v_start timestamp := (v_period->>'period_start')::timestamp;
  v_end timestamp := (v_period->>'period_end_exclusive')::timestamp;
  v_category text := gg_v2.category_key(p_category);
  v_result jsonb;
begin
  if p_user_id is null then raise exception 'user_id is required' using errcode='22023'; end if;
  if p_page is null or p_page<1 or p_page_size is null or p_page_size<1 or p_page_size>100 then
    raise exception 'page must be >=1; page_size must be 1..100' using errcode='22023';
  end if;
  with page_rows as materialized (
    select g.* from public.games g
    where g.status='completed' and g.test=p_test and g.creator_user_id=p_user_id
      and (v_start is null or g.game_date>=v_start)
      and (v_end is null or g.game_date<v_end)
    order by case when v_category='valuable' then coalesce(g.lichtwatt,0) end desc nulls last,
      g.game_date desc nulls last,g.id
    offset ((p_page::bigint-1)*p_page_size) limit p_page_size+1
  ), numbered as (
    select g.*,row_number() over(order by
      case when v_category='valuable' then coalesce(g.lichtwatt,0) end desc nulls last,
      g.game_date desc nulls last,g.id) as gg_position from page_rows g
  )
  select jsonb_build_object('user_id',p_user_id,'requested_period',coalesce(p_period,'auto'),
    'requested_category',coalesce(p_category,'valuable'),
    'test',p_test,'period',v_period,'available_periods',gg_v2.available_periods(),'category',v_category,
    'games',coalesce((select jsonb_agg(to_jsonb(g)-'gg_position' order by g.gg_position)
      from numbered g where g.gg_position<=p_page_size),'[]'::jsonb),
    'pagination',jsonb_build_object('page',p_page,'page_size',p_page_size,
      'has_more',(select count(*) from page_rows)>p_page_size)) into v_result;
  return v_result;
end;
$$;

revoke all on function public.gg_v2_rankings(text,text,integer,integer,uuid,boolean) from public,anon,authenticated;
revoke all on function public.gg_v2_profile_stats(uuid,text,boolean) from public,anon,authenticated;
revoke all on function public.gg_v2_games(uuid,text,text,integer,integer,boolean) from public,anon,authenticated;
grant execute on function public.gg_v2_rankings(text,text,integer,integer,uuid,boolean),
  public.gg_v2_profile_stats(uuid,text,boolean),public.gg_v2_games(uuid,text,text,integer,integer,boolean)
  to anon,authenticated;
commit;

-- SOURCE: 02_rpc/11_notifications.sql
-- Optional realtime updates for the RPC variant, transactional with the write.
begin;
create or replace function gg_v2.notify_changed() returns trigger
language plpgsql volatile security definer set search_path='' as $$
begin
  if tg_op='UPDATE' and to_jsonb(new)=to_jsonb(old) then return new; end if;
  perform realtime.send(jsonb_build_object('changed_at',clock_timestamp()),'changed','gg:v2:stats',false);
  if tg_op='DELETE' then return old; end if;
  return new;
end; $$;
revoke all on function gg_v2.notify_changed() from public,anon,authenticated;
create or replace trigger gg_v2_games_changed after insert or update or delete on public.games
  for each row execute function gg_v2.notify_changed();
create or replace trigger gg_v2_invites_changed after insert or update or delete on public.invites
  for each row execute function gg_v2.notify_changed();
create or replace trigger gg_v2_bonus_changed after insert or update or delete on gg_v2.point_awards
  for each row execute function gg_v2.notify_changed();
create or replace trigger gg_v2_users_changed after insert or update or delete on public.users
  for each row execute function gg_v2.notify_changed();
create or replace trigger gg_v2_seasons_changed after insert or update on gg_v2.seasons
  for each row execute function gg_v2.notify_changed();
commit;

-- SOURCE: 03_seasons_admin/20_admin.sql
-- LOCAL ONLY. Requires shared package and 02_rpc/10_rpc.sql.
begin;
create table if not exists gg_v2.season_admins(user_id uuid primary key);
alter table gg_v2.season_admins enable row level security;
revoke all on gg_v2.season_admins from public,anon,authenticated;
-- Owner approves admin IDs explicitly. Never trust a client-editable role/JWT metadata.
-- insert into gg_v2.season_admins(user_id) values ('ADMIN_UUID') on conflict do nothing;

create or replace function gg_v2.require_admin() returns void
language plpgsql stable security definer set search_path='' as $$
begin
  if auth.uid() is null or not exists(select 1 from gg_v2.season_admins a where a.user_id=auth.uid()) then
    raise exception 'Season admin access required' using errcode='42501';
  end if;
end; $$;
revoke all on function gg_v2.require_admin() from public,anon,authenticated;

-- Only the last begun season and its predecessor, plus the three date filters.
-- Planned future seasons appear in the admin list, not in user filters.
create or replace function gg_v2.available_periods() returns jsonb
language sql stable security definer set search_path='' as $$
  with recent as (select t.season_key,t.starts_at from gg_v2.seasons t
    where t.starts_at<=transaction_timestamp() at time zone 'UTC' order by t.starts_at desc limit 2)
  select coalesce(jsonb_agg(gg_v2.period_info(r.season_key) order by r.starts_at desc),'[]'::jsonb)
    ||jsonb_build_array(gg_v2.period_info('last_month'),gg_v2.period_info('this_month'),gg_v2.period_info('all_time'))
  from recent r;
$$;

create or replace function gg_v2.admin_api(p_operation text,p_input jsonb,p_test boolean)
returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare k text; title text; y integer; a timestamp; b timestamp; old gg_v2.seasons%rowtype;
  exists_row boolean; did_close boolean;
begin
  perform gg_v2.require_admin();
  if p_operation='list' then
    return jsonb_build_object('seasons',coalesce((select jsonb_agg(
      to_jsonb(s)||jsonb_build_object('finalized_at',z.finalized_at,'test',p_test,
        'last_day',(s.ends_at-interval '1 day')::date,
        'locked',exists(select 1 from gg_v2.season_closures c where c.season_key=s.season_key and c.finalized_at is not null))
      order by s.starts_at desc) from gg_v2.seasons s left join gg_v2.season_closures z
      on z.season_key=s.season_key and z.test=p_test),'[]'::jsonb));
  elsif p_operation='save' then
    -- Serialize all calendar edits, including distinct new seasons.
    perform pg_advisory_xact_lock(704102026);
    k:=btrim(p_input->>'season_key'); title:=btrim(p_input->>'label');
    y:=(p_input->>'season_year')::integer;
    a:=(p_input->>'starts_on')::date::timestamp;
    b:=((p_input->>'last_day')::date+1)::timestamp;
    if k is null or k !~ '^season_[a-z0-9_]{1,60}$' or title is null or length(title) not between 1 and 100
      or y is null or y not between 2025 and 9998 or a is null or b is null or b<=a then
      raise exception 'Invalid season fields' using errcode='22023';
    end if;
    select * into old from gg_v2.seasons s where s.season_key=k for update;
    exists_row:=found;
    if exists_row and exists(select 1 from gg_v2.season_closures c where c.season_key=k and c.finalized_at is not null) then
      raise exception 'Finalized season is immutable' using errcode='22023';
    end if;
    if exists(select 1 from gg_v2.seasons s where s.season_key<>k and a<s.ends_at and b>s.starts_at) then
      raise exception 'Season dates overlap' using errcode='22023';
    end if;
    insert into gg_v2.seasons(season_key,label,season_year,starts_at,ends_at)
      values(k,title,y,a,b) on conflict(season_key) do update set
        label=excluded.label,season_year=excluded.season_year,starts_at=excluded.starts_at,ends_at=excluded.ends_at;
    return jsonb_build_object('saved',k);
  elsif p_operation='preview' then
    return public.gg_v2_rankings(p_input->>'season_key','valuable',1,3,null,p_test)
      ||jsonb_build_object('map',public.gg_v2_rankings(p_input->>'season_key','active',1,3,null,p_test));
  elsif p_operation='finalize_test' then
    if not p_test then raise exception 'Manual test closure requires test=true' using errcode='42501'; end if;
    did_close:=gg_v2.finalize_season(p_input->>'season_key',true);
    return jsonb_build_object('created',did_close);
  end if;
  raise exception 'Unknown admin operation' using errcode='22023';
end; $$;
revoke all on function gg_v2.admin_api(text,jsonb,boolean) from public,anon,authenticated;
grant execute on function gg_v2.admin_api(text,jsonb,boolean) to authenticated;
create or replace function public.gg_v2_seasons_admin(
  p_operation text,p_input jsonb default '{}'::jsonb,p_test boolean default false
) returns jsonb language sql volatile security invoker set search_path='' as $$
  select gg_v2.admin_api(p_operation,p_input,p_test);
$$;
revoke all on function public.gg_v2_seasons_admin(text,jsonb,boolean) from public,anon,authenticated;
grant execute on function public.gg_v2_seasons_admin(text,jsonb,boolean) to authenticated;

create table if not exists gg_v2.calendar_settings (
  singleton boolean primary key default true check(singleton),
  auto_plan boolean not null default true
);
alter table gg_v2.calendar_settings enable row level security;
revoke all on gg_v2.calendar_settings from public,anon,authenticated;
insert into gg_v2.calendar_settings(singleton) values(true) on conflict do nothing;

-- Owner-only Cron. Annual September-June follows the earlier confirmation.
-- Set auto_plan=false if the customer has not confirmed subsequent dates.
-- Existing administrator-created next season is never overwritten.
create or replace function gg_v2.finalize_due_seasons(
  p_now timestamptz default transaction_timestamp()
) returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare s record; e boolean; k text; a timestamp; b timestamp;
  closed jsonb:='[]'::jsonb; planned jsonb:='[]'::jsonb; skipped jsonb:='[]'::jsonb;
begin
  perform pg_advisory_xact_lock(704102026);
  for s in select * from gg_v2.seasons where ends_at<=p_now at time zone 'UTC' order by starts_at loop
    foreach e in array array[false,true] loop
      if gg_v2.finalize_season(s.season_key,e,p_now) then
        closed:=closed||jsonb_build_array(jsonb_build_object('season',s.season_key,'test',e));
      end if;
    end loop;
    if (select auto_plan from gg_v2.calendar_settings where singleton) then
      a:=make_date(s.season_year,9,1)::timestamp;
      b:=make_date(s.season_year+1,7,1)::timestamp;
      k:='season_'||s.season_year||'_'||to_char((s.season_year+1)%100,'FM00');
      if exists(select 1 from gg_v2.seasons t where t.starts_at>=s.ends_at) then continue; end if;
      if a<s.ends_at or exists(select 1 from gg_v2.seasons t where a<t.ends_at and b>t.starts_at) then
        skipped:=skipped||jsonb_build_array(jsonb_build_object('season',k,'reason','Dates overlap; admin must plan next season'));
        continue;
      end if;
      insert into gg_v2.seasons(season_key,label,season_year,starts_at,ends_at)
      values(k,'Saison '||s.season_year||'/'||to_char((s.season_year+1)%100,'FM00'),s.season_year+1,a,b)
      on conflict do nothing;
      planned:=planned||jsonb_build_array(k);
    end if;
  end loop;
  return jsonb_build_object('finalized',closed,'planned',planned,'skipped',skipped);
end; $$;
revoke all on function gg_v2.finalize_due_seasons(timestamptz) from public,anon,authenticated;
commit;
