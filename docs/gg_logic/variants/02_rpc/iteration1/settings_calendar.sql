-- PRIVATE rollout settings. Client roles cannot change these switches.
create table if not exists gg_v2.rollout (
  singleton boolean primary key default true check(singleton),
  signup_bonus_migrated boolean not null default false,
  finalization_enabled boolean not null default false,
  auto_plan_enabled boolean not null default true,
  season_months integer not null default 10 check(season_months between 1 and 24)
);
insert into gg_v2.rollout(singleton) values(true) on conflict do nothing;
alter table gg_v2.rollout enable row level security;
revoke all on gg_v2.rollout from public,anon,authenticated;
create or replace function gg_v2.config() returns jsonb
language sql stable security definer set search_path='' as $$
  select jsonb_build_object('timezone','UTC','tie_policy','sequential') ||
    (to_jsonb(r)-'singleton') from gg_v2.rollout r where singleton;
$$;
create or replace function gg_v2.registered_users_count() returns bigint
language sql stable security definer set search_path='' as $$
  select count(*) from public.users;
$$;
create or replace function gg_v2.is_finalized(p_season text,p_test boolean) returns boolean
language sql stable security definer set search_path='' as $$
  select exists(select 1 from gg_v2.season_closures c where c.season_key=p_season
    and c.test=p_test and c.finalized_at is not null);
$$;
revoke all on function gg_v2.registered_users_count(),gg_v2.is_finalized(text,boolean) from public,anon,authenticated;
grant execute on function gg_v2.registered_users_count(),gg_v2.is_finalized(text,boolean) to anon,authenticated;

-- New rule (13 Oct): next day, ten calendar months. Original TZ seeds stay intact.
create or replace function gg_v2.plan_due_seasons(
  p_now timestamptz default transaction_timestamp()
) returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare
  latest gg_v2.seasons%rowtype; a timestamp; b timestamp; k text; title text;
  created jsonb:='[]'::jsonb; start_year integer; end_year integer;
begin
  if not (gg_v2.config()->>'auto_plan_enabled')::boolean then return created; end if;
  perform pg_advisory_xact_lock(74740261013);
  loop
    select * into latest from gg_v2.seasons order by ends_at desc,starts_at desc limit 1;
    if not found or latest.ends_at > p_now at time zone (gg_v2.config()->>'timezone') then exit; end if;
    a:=latest.ends_at;
    b:=a+make_interval(months=>(gg_v2.config()->>'season_months')::integer);
    k:='season_'||to_char(a,'YYYY_MM_DD');
    start_year:=extract(year from a)::integer;
    end_year:=extract(year from b-interval '1 day')::integer;
    title:='Saison '||start_year||case when end_year<>start_year then '/'||right(end_year::text,2) else '' end;
    insert into gg_v2.seasons(season_key,label,season_year,starts_at,ends_at)
      values(k,title,end_year,a,b);
    created:=created||jsonb_build_array(k);
  end loop;
  return created;
end; $$;

create or replace function gg_v2.finalize_due_seasons(
  p_now timestamptz default transaction_timestamp()
) returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare s record; e boolean; planned jsonb; closed jsonb:='[]'::jsonb;
begin
  planned:=gg_v2.plan_due_seasons(p_now);
  if (gg_v2.config()->>'finalization_enabled')::boolean then
    for s in select season_key from gg_v2.seasons
      where ends_at<=p_now at time zone (gg_v2.config()->>'timezone') order by starts_at
    loop
      foreach e in array array[false,true] loop
        if gg_v2.finalize_season(s.season_key,e,p_now) then
          closed:=closed||jsonb_build_array(jsonb_build_object('season',s.season_key,'test',e));
        end if;
      end loop;
    end loop;
  end if;
  return jsonb_build_object('planned',planned,'finalized',closed,
    'finalization_enabled',(gg_v2.config()->>'finalization_enabled')::boolean);
end; $$;
revoke all on function gg_v2.plan_due_seasons(timestamptz),gg_v2.finalize_due_seasons(timestamptz) from public,anon,authenticated;

-- Seasons from the TZ are seeds; later dates are forecasts and may be edited in
-- the Table Editor. Periods never overlap. Editing a finalized season requires
-- gg_v2.refinalize_season afterwards. Name avoids the gg_v2_% business prefix.
create or replace function gg_v2.check_season_overlap() returns trigger
language plpgsql set search_path='' as $$
begin
  if exists(select 1 from gg_v2.seasons s where s.season_key<>new.season_key
      and s.starts_at<new.ends_at and new.starts_at<s.ends_at) then
    raise exception 'Season % overlaps another season',new.season_key using errcode='23P01';
  end if;
  return new;
end; $$;
revoke all on function gg_v2.check_season_overlap() from public,anon,authenticated;
drop trigger if exists seasons_no_overlap on gg_v2.seasons;
create trigger seasons_no_overlap before insert or update on gg_v2.seasons
  for each row execute function gg_v2.check_season_overlap();

-- Template for a new season: first and LAST day, both inclusive.
--   select gg_v2.add_season('2027-09-01','2028-06-30');
-- Key/label follow the auto-planner: season_2027_09_01, 'Saison 2027/28'.
create or replace function gg_v2.add_season(
  p_starts_on date,p_last_day date,p_label text default null,p_key text default null
) returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare
  y1 integer:=extract(year from p_starts_on)::integer;
  y2 integer:=extract(year from p_last_day)::integer;
  k text:=coalesce(nullif(p_key,''),'season_'||to_char(p_starts_on,'YYYY_MM_DD'));
  t text:=coalesce(nullif(p_label,''),'Saison '||y1||case when y2<>y1 then '/'||right(y2::text,2) else '' end);
begin
  if p_starts_on is null or p_last_day is null or p_last_day<p_starts_on then
    raise exception 'Last day must not be before the first day' using errcode='22023';
  end if;
  insert into gg_v2.seasons(season_key,label,season_year,starts_at,ends_at)
    values(k,t,y2,p_starts_on::timestamp,(p_last_day+1)::timestamp);
  return jsonb_build_object('season_key',k,'label',t,'season_year',y2,
    'first_day',p_starts_on,'last_day',p_last_day);
end; $$;
revoke all on function gg_v2.add_season(date,date,text,text) from public,anon,authenticated;

-- Owner-only recompute of a closed season: after +100 migration, a date change
-- or a check run. Fails as a whole if the season cannot be finalized again.
create or replace function gg_v2.refinalize_season(
  p_season text,p_test boolean default false,p_now timestamptz default transaction_timestamp()
) returns boolean language plpgsql volatile security definer set search_path='' as $$
declare k text:=gg_v2.period_info(p_season,p_now)->>'key';
begin
  perform 1 from gg_v2.seasons where season_key=k for update;
  delete from gg_v2.season_results where season_key=k and test=p_test;
  delete from gg_v2.season_closures where season_key=k and test=p_test;
  return gg_v2.finalize_season(k,p_test,p_now);
end; $$;
revoke all on function gg_v2.refinalize_season(text,boolean,timestamptz) from public,anon,authenticated;

-- Ranking rows show medals of the LAST closed season, whatever the filter
-- (owner, 14 Oct). Profile keeps all seasons. Null until a season is closed.
create or replace function gg_v2.last_finalized_season(p_test boolean) returns text
language sql stable security definer set search_path='' as $$
  select c.season_key from gg_v2.season_closures c join gg_v2.seasons s using(season_key)
  where c.test=p_test and c.finalized_at is not null order by s.starts_at desc limit 1;
$$;
revoke all on function gg_v2.last_finalized_season(boolean) from public,anon,authenticated;
grant execute on function gg_v2.last_finalized_season(boolean) to anon,authenticated;
