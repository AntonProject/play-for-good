-- Local preparation only. Do not execute against the live project without
-- the owner's command. This supersedes docs/gg_rpc_listener/example.sql.
begin;
create schema if not exists gg_internal;
revoke all on schema gg_internal from public;
grant usage on schema gg_internal to anon, authenticated;

-- Confirm timezone before live use. Existing date columns are timestamp
-- without time zone; their stored values are compared directly to boundaries.
-- timezone controls the calendar clock, not a conversion of historical rows.
create or replace function gg_internal.config() returns jsonb
language sql immutable security invoker set search_path = '' as $$
  select jsonb_build_object('timezone', 'UTC', 'tie_policy', 'sequential');
$$;

create or replace function gg_internal.period_info(
  p_period text, p_now timestamptz default transaction_timestamp()
) returns jsonb language plpgsql stable security invoker
set search_path = '' as $$
declare
  v_key text := lower(btrim(coalesce(p_period, 'auto')));
  v_timezone text := gg_internal.config()->>'timezone';
  v_clock timestamp := p_now at time zone v_timezone;
  v_start timestamp; v_end timestamp; v_label text; v_year integer;
  v_start_year integer; v_match text[];
begin
  v_key := case v_key
    when 'gesamt' then 'all_time' when 'all-time' then 'all_time'
    when 'saison' then 'auto' when 'saison_2025_26' then 'season_2025_26'
    when 'saison_2026_27' then 'season_2026_27'
    when 'letzter_monat' then 'last_month'
    when 'dieser_monat' then 'this_month' when 'monat' then 'this_month'
    else v_key end;
  if v_key = 'auto' then
    v_start_year := extract(year from v_clock)::integer
      - case when extract(month from v_clock)<9 then 1 else 0 end;
    if v_clock >= timestamp '2026-09-01' then
      v_key := 'season_'||v_start_year||'_'||to_char((v_start_year+1)%100,'FM00');
    elsif v_clock >= timestamp '2025-11-20' then v_key := 'season_2025_26';
    else v_key := 'all_time'; end if;
  end if;
  v_match := regexp_match(v_key,'^season_([0-9]{4})_([0-9]{2})$');
  if v_match is not null and v_key <> 'season_2025_26' then
    v_start_year := v_match[1]::integer;
    if v_start_year<2026 or v_start_year>9998
      or v_match[2]::integer<>(v_start_year+1)%100 then
      raise exception 'Unknown GG period: %',p_period using errcode='22023';
    end if;
    v_start := make_date(v_start_year,9,1)::timestamp;
    v_end := make_date(v_start_year+1,7,1)::timestamp;
    v_label := 'Saison '||v_start_year||'/'||v_match[2]; v_year := v_start_year+1;
    return jsonb_build_object('key',v_key,'label',v_label,'season_year',v_year,
      'period_start',v_start,'period_end_exclusive',v_end,'timezone',v_timezone,
      'is_completed',v_clock>=v_end);
  end if;
  case v_key
    when 'season_2025_26' then
      v_start := timestamp '2025-11-20'; v_end := timestamp '2026-09-01';
      v_label := 'Saison 2025/26'; v_year := 2026;
    when 'season_2026_27' then
      v_start := timestamp '2026-09-01'; v_end := timestamp '2027-07-01';
      v_label := 'Saison 2026/27'; v_year := 2027;
    when 'last_month' then
      v_end := date_trunc('month', v_clock);
      v_start := v_end - interval '1 month'; v_label := 'Letzten Monat';
    when 'this_month' then
      v_start := date_trunc('month', v_clock);
      v_end := v_start + interval '1 month'; v_label := 'Diesen Monat';
    when 'all_time' then v_label := 'All-Time';
    else raise exception 'Unknown GG period: %', p_period using errcode='22023';
  end case;
  return jsonb_build_object('key',v_key,'label',v_label,'season_year',v_year,
    'period_start',v_start,'period_end_exclusive',v_end,'timezone',v_timezone,
    'is_completed',coalesce(v_year is not null and v_clock>=v_end,false));
end;
$$;

-- One season catalogue: first season is exceptional, later seasons recur annually.
-- The future 2026/27 option remains available as specified in the original UI.
create or replace function gg_internal.season_periods(
  p_now timestamptz default transaction_timestamp()
) returns table(period jsonb) language sql stable security invoker set search_path='' as $$
  select gg_internal.period_info('season_2025_26',p_now)
  union all
  select gg_internal.period_info('season_'||y||'_'||to_char((y+1)%100,'FM00'),p_now)
  from generate_series(2026,greatest(2026,
    extract(year from p_now at time zone (gg_internal.config()->>'timezone'))::integer
    - case when extract(month from p_now at time zone (gg_internal.config()->>'timezone'))<9
      then 1 else 0 end)) y;
$$;

create or replace function gg_internal.available_periods() returns jsonb
language sql stable security invoker set search_path='' as $$
  select coalesce(jsonb_agg(p.period order by (p.period->>'season_year')::integer desc),'[]'::jsonb)
    ||jsonb_build_array(gg_internal.period_info('last_month'),
      gg_internal.period_info('this_month'),gg_internal.period_info('all_time'))
  from gg_internal.season_periods() p;
$$;

create or replace function gg_internal.category_key(p_category text)
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
-- Keep gg_internal OUT of the Data API exposed schemas. No service key on client.
-- Aggregate live periods once per source. Closed seasons/awards use frozen results.
create or replace function gg_internal.score_sets(p_period text)
returns table (
  bucket text, user_id uuid, display_name text, first_name text, surname text,
  photo_url text, good_power numeric, game_power numeric, invite_power numeric,
  games_count bigint, good_energy numeric, good_power_per_game numeric,
  good_energy_per_game numeric, sponsored_games bigint,
  power_rank bigint, games_rank bigint, power_per_game_rank bigint,
  energy_rank bigint, energy_per_game_rank bigint, sponsored_games_rank bigint
) language plpgsql stable security definer set search_path='' as $$
declare
  v_info jsonb := gg_internal.period_info(p_period);
  v_start timestamp := (v_info->>'period_start')::timestamp;
  v_end timestamp := (v_info->>'period_end_exclusive')::timestamp;
  v_shared boolean := gg_internal.config()->>'tie_policy' = 'shared';
  v_frozen boolean := exists(select 1 from gg_internal.seasons t
    where t.season_key=v_info->>'key' and t.finalized_at is not null);
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
    from public.games g where g.status='completed'
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
    from public.invites i where i.was_used=true
  ), invite_totals as (
    select e.inviter_user_id,
      coalesce(sum(e.gp) filter(where e.selected),0) as sel_gp,sum(e.gp) as all_gp
    from invite_events e group by e.inviter_user_id
  ), scores as (
    select b.bucket,u.id as user_id,u.display_name::text,u.first_name::text,u.surname::text,u.photo_url::text,
      b.gp+b.invite_gp as good_power,b.gp as game_power,b.invite_gp as invite_power,
      b.game_count as games_count,b.energy as good_energy,
      case when b.game_count>0 then b.gp/b.game_count else 0 end as good_power_per_game,
      case when b.game_count>0 then b.energy/b.game_count else 0 end as good_energy_per_game,
      b.sponsored as sponsored_games
    from public.users u
    left join game_totals g on g.creator_user_id=u.id
    left join invite_totals i on i.inviter_user_id=u.id
    cross join lateral (values
      ('selected',coalesce(g.sel_gp,0),coalesce(i.sel_gp,0),
        coalesce(g.sel_count,0),coalesce(g.sel_energy,0),coalesce(g.sel_sponsored,0)),
      ('all_time',coalesce(g.all_gp,0),coalesce(i.all_gp,0),
        coalesce(g.all_count,0),coalesce(g.all_energy,0),coalesce(g.all_sponsored,0))
    ) as b(bucket,gp,invite_gp,game_count,energy,sponsored)
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
    from (select * from gg_internal.season_results sr where sr.season_key=v_info->>'key') r
    full join public.users u on u.id=r.user_id where v_frozen
  ), frozen_awards as (
    select 'award:'||r.season_key as bucket,r.user_id,
      coalesce(u.display_name,r.display_name)::text,coalesce(u.first_name,r.first_name)::text,
      coalesce(u.surname,r.surname)::text,coalesce(u.photo_url,r.photo_url)::text,
      r.good_power,r.game_power,r.invite_power,r.games_count,r.good_energy,
      r.good_power_per_game,r.good_energy_per_game,r.sponsored_games,
      r.power_rank,r.games_rank,r.power_per_game_rank,r.energy_rank,
      r.energy_per_game_rank,r.sponsored_games_rank
    from gg_internal.season_results r join gg_internal.seasons t using(season_key)
    left join public.users u on u.id=r.user_id
    where t.finalized_at is not null and (r.power_rank between 1 and 3 or r.games_rank between 1 and 3)
  )
  select * from live_ranked union all select * from frozen_selected union all select * from frozen_awards;
end;
$$;

create or replace function gg_internal.award_flags(p_awards jsonb) returns jsonb
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

create or replace function gg_internal.player_payload(
  p_score jsonb,p_category text,p_awards jsonb
) returns jsonb language sql immutable security invoker set search_path='' as $$
  select jsonb_build_object(
    'user_id',p_score->'user_id','display_name',p_score->'display_name',
    'first_name',p_score->'first_name','surname',p_score->'surname','photo_url',p_score->'photo_url',
    'good_power',p_score->'good_power','game_power',p_score->'game_power',
    'invite_power',p_score->'invite_power','games_count',p_score->'games_count',
    'score',case when p_category='active' then p_score->'games_count' else p_score->'good_power' end,
    'rank',case when p_category='active' then p_score->'games_rank' else p_score->'power_rank' end,
    'awards',coalesce(p_awards,'[]'::jsonb),
    'award_flags',gg_internal.award_flags(p_awards)
  );
$$;

-- Public RPC #1: paged ranking, podium and the selected user's row in ONE read.
create or replace function public.gg_rankings(
  p_period text default 'auto', p_category text default 'valuable',
  p_page integer default 1, p_page_size integer default 10, p_user_id uuid default null
) returns jsonb language plpgsql stable security invoker set search_path='' as $$
declare
  v_category text := gg_internal.category_key(p_category);
  v_period jsonb := gg_internal.period_info(p_period);
  v_result jsonb;
begin
  if p_page is null or p_page<1 or p_page_size is null or p_page_size<1 or p_page_size>100 then
    raise exception 'page must be >=1; page_size must be 1..100' using errcode='22023';
  end if;
  with scores as materialized (select * from gg_internal.score_sets(p_period)),
  award_rows as (
    select s.user_id,jsonb_build_object('season',p.period->>'key',
      'season_year',(p.period->>'season_year')::integer,
      'category',r.category,'place',r.place,'badge',
      case when r.category='valuable' then
        case r.place when 1 then 'mvp_gold' when 2 then 'mvp_silver' else 'mvp_bronze' end
      else case r.place when 1 then 'active_fire' when 2 then 'map_silver' else 'map_bronze' end end) as award
    from scores s join gg_internal.season_periods() p on s.bucket='award:'||(p.period->>'key')
    cross join lateral (values ('valuable',s.power_rank),('active',s.games_rank)) r(category,place)
    where r.place between 1 and 3
  ), awards as (
    select a.user_id,jsonb_agg(a.award order by (a.award->>'season_year')::integer desc,a.award->>'category') as items
    from award_rows a group by a.user_id
  ), players as (
    select s.user_id,case when v_category='active' then s.games_count else s.good_power end as score,
      gg_internal.player_payload(to_jsonb(s),v_category,a.items) as payload
    from scores s left join awards a on a.user_id=s.user_id where s.bucket='selected'
  ), eligible as (select * from players where score>0),
  page_rows as (
    select * from eligible order by score desc,user_id
    offset ((p_page::bigint-1)*p_page_size) limit p_page_size
  ), top_rows as (select * from eligible order by score desc,user_id limit 3)
  select jsonb_build_object('requested_period',coalesce(p_period,'auto'),
    'requested_category',coalesce(p_category,'valuable'),
    'requested_user_id',p_user_id,
    'period',v_period,'available_periods',gg_internal.available_periods(),'category',v_category,
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
create or replace function public.gg_profile_stats(
  p_user_id uuid,p_period text default 'auto'
) returns jsonb language plpgsql stable security invoker set search_path='' as $$
declare v_result jsonb; v_period jsonb := gg_internal.period_info(p_period);
begin
  if p_user_id is null then raise exception 'user_id is required' using errcode='22023'; end if;
  with scores as materialized (select * from gg_internal.score_sets(p_period)),
  user_awards as (
    select jsonb_build_object('season',p.period->>'key',
      'season_year',(p.period->>'season_year')::integer,
      'category',r.category,'place',r.place,'badge',
      case when r.category='valuable' then
        case r.place when 1 then 'mvp_gold' when 2 then 'mvp_silver' else 'mvp_bronze' end
      else case r.place when 1 then 'active_fire' when 2 then 'map_silver' else 'map_bronze' end end) as award
    from scores s join gg_internal.season_periods() p on s.bucket='award:'||(p.period->>'key')
    cross join lateral (values ('valuable',s.power_rank),('active',s.games_rank)) r(category,place)
    where s.user_id=p_user_id and r.place between 1 and 3
  ), awards as (select coalesce(jsonb_agg(a.award order by (a.award->>'season_year')::integer desc,a.award->>'category'),'[]'::jsonb) as items from user_awards a)
  select jsonb_build_object('user_id',s.user_id,'requested_period',coalesce(p_period,'auto'),
    'period',v_period,'available_periods',gg_internal.available_periods(),'display_name',s.display_name,'photo_url',s.photo_url,
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
    'awards',aw.items,'award_flags',gg_internal.award_flags(aw.items)) into v_result
  from scores s join scores a on a.user_id=s.user_id and a.bucket='all_time'
  cross join awards aw where s.bucket='selected' and s.user_id=p_user_id;
  if v_result is null then raise exception 'Profile not found' using errcode='P0002'; end if;
  return v_result;
end;
$$;

-- Public RPC #3: bounded game history for Meine Games, preserving GamesRow UI.
-- Native RLS applies; games are already publicly readable in the current app.
create or replace function public.gg_games(
  p_user_id uuid,p_period text default 'auto',p_category text default 'valuable',
  p_page integer default 1,p_page_size integer default 10
) returns jsonb language plpgsql stable security invoker set search_path='' as $$
declare
  v_period jsonb := gg_internal.period_info(p_period);
  v_start timestamp := (v_period->>'period_start')::timestamp;
  v_end timestamp := (v_period->>'period_end_exclusive')::timestamp;
  v_category text := gg_internal.category_key(p_category);
  v_result jsonb;
begin
  if p_user_id is null then raise exception 'user_id is required' using errcode='22023'; end if;
  if p_page is null or p_page<1 or p_page_size is null or p_page_size<1 or p_page_size>100 then
    raise exception 'page must be >=1; page_size must be 1..100' using errcode='22023';
  end if;
  with page_rows as materialized (
    select g.* from public.games g
    where g.status='completed' and g.creator_user_id=p_user_id
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
    'period',v_period,'available_periods',gg_internal.available_periods(),'category',v_category,
    'games',coalesce((select jsonb_agg(to_jsonb(g)-'gg_position' order by g.gg_position)
      from numbered g where g.gg_position<=p_page_size),'[]'::jsonb),
    'pagination',jsonb_build_object('page',p_page,'page_size',p_page_size,
      'has_more',(select count(*) from page_rows)>p_page_size)) into v_result;
  return v_result;
end;
$$;

-- Restrict default EXECUTE grants. Helper schema is not exposed via PostgREST.
revoke all on function gg_internal.config() from public,anon,authenticated;
revoke all on function gg_internal.period_info(text,timestamptz) from public,anon,authenticated;
revoke all on function gg_internal.season_periods(timestamptz) from public,anon,authenticated;
revoke all on function gg_internal.available_periods() from public,anon,authenticated;
revoke all on function gg_internal.category_key(text) from public,anon,authenticated;
revoke all on function gg_internal.score_sets(text) from public,anon,authenticated;
revoke all on function gg_internal.award_flags(jsonb) from public,anon,authenticated;
revoke all on function gg_internal.player_payload(jsonb,text,jsonb) from public,anon,authenticated;
grant execute on function gg_internal.config(),gg_internal.period_info(text,timestamptz),
  gg_internal.season_periods(timestamptz),gg_internal.available_periods(),
  gg_internal.category_key(text),gg_internal.score_sets(text),gg_internal.award_flags(jsonb),
  gg_internal.player_payload(jsonb,text,jsonb) to anon,authenticated;
revoke all on function public.gg_rankings(text,text,integer,integer,uuid) from public,anon,authenticated;
revoke all on function public.gg_profile_stats(uuid,text) from public,anon,authenticated;
revoke all on function public.gg_games(uuid,text,text,integer,integer) from public,anon,authenticated;
grant execute on function public.gg_rankings(text,text,integer,integer,uuid),
  public.gg_profile_stats(uuid,text),public.gg_games(uuid,text,text,integer,integer)
  to anon,authenticated;
commit;
