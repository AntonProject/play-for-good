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
