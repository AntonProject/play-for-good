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
