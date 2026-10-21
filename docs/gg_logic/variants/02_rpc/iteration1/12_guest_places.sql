-- Rankings RPC + guest_places (16.10.2026): places for the guest profile Stats.
-- A guest has the demo 100 points and nothing else, so:
--   good_power            place of 100 in the period (= guest_rank)
--   games, good_power_per_game, good_energy, good_energy_per_game, sponsored_games
--                         last place = players with a value > 0, plus 1
--   all_time_good_power   place of 100 in All-Time (profile header), same call
-- Same rule as the zero rows of gg_v2_profile_stats for registered users.
-- Run the WHOLE file in the Supabase SQL editor (owner); one transaction.
--
-- What it changes:
--   public.gg_v2_rankings  replaced (read-only function); the response gets the
--                          new field guest_places, all old fields stay the same
-- Not touched: tables, data, grants (create or replace keeps them), triggers, cron.
-- Text = the LAST gg_v2_rankings definition in 01_install.sql (built by build.py).
begin;
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
      'season_year',(p.period->>'season_year')::integer,'season_label',p.period->>'label','period_start',p.period->>'period_start',
      'category',r.category,'place',r.place,'badge',
      case when r.category='valuable' then
        case r.place when 1 then 'mvp_gold' when 2 then 'mvp_silver' else 'mvp_bronze' end
      else case r.place when 1 then 'active_fire' when 2 then 'map_silver' else 'map_bronze' end end) as award
    from scores s join gg_v2.season_periods() p on s.bucket='award:'||(p.period->>'key')
    cross join lateral (values ('valuable',s.power_rank),('active',s.games_rank)) r(category,place)
    where r.place between 1 and 3
      and p.period->>'key'=gg_v2.last_finalized_season(p_test)
  ), awards as (
    select a.user_id,jsonb_agg(a.award order by
      case when a.award->>'category'='valuable' then 0 else 1 end,
      a.award->>'period_start' desc,a.award->>'season',
      (a.award->>'place')::integer) as items
    from award_rows a group by a.user_id
  ), players as (
    select s.user_id,case v_category when 'active' then s.games_count when 'generous' then s.good_energy when 'social' then s.sponsored_games else s.good_power end as score,
      case v_category when 'active' then s.games_rank when 'generous' then s.energy_rank when 'social' then s.sponsored_games_rank else s.power_rank end as place,
      gg_v2.player_payload(to_jsonb(s),v_category,a.items) as payload
    from scores s left join awards a on a.user_id=s.user_id where s.bucket='selected'
  ), eligible as (select * from players where score>0),
  page_rows as (
    select * from eligible order by place,user_id
    offset ((p_page::bigint-1)*p_page_size) limit p_page_size
  ), top_rows as (select * from eligible order by place,user_id limit 3)
  select jsonb_build_object('requested_period',coalesce(p_period,'auto'),
    'requested_category',coalesce(p_category,'valuable'),
    'requested_user_id',p_user_id,
    'awards_season',gg_v2.last_finalized_season(p_test),
    'signup_bonus_migrated',(gg_v2.config()->>'signup_bonus_migrated')::boolean,
    'legacy_bonus_users_count',gg_v2.registered_users_count(),
    'layout_mode',case when v_period->>'season_year' is not null and (v_period->>'is_completed')::boolean then 'final' else 'current' end,
    'results_finalized',gg_v2.is_finalized(v_period->>'key',p_test),
    'test',p_test,'period',v_period,'available_periods',gg_v2.available_periods(),'category',v_category,
    'total_good_power',coalesce((select sum(s.good_power) from scores s where s.bucket='selected'),0),
    'max_good_power',coalesce((select max(s.good_power) from scores s where s.bucket='selected'),0),
    'total_good_power_all_time',coalesce((select sum(s.good_power) from scores s where s.bucket='all_time'),0),
    'guest_rank',(select count(*)+1 from scores s where s.bucket='selected' and s.good_power>100),
    'guest_places',jsonb_build_object(
      'good_power',(select count(*)+1 from scores s where s.bucket='selected' and s.good_power>100),
      'games',(select count(*)+1 from scores s where s.bucket='selected' and s.games_count>0),
      'good_power_per_game',(select count(*)+1 from scores s where s.bucket='selected' and s.games_count>0),
      'good_energy',(select count(*)+1 from scores s where s.bucket='selected' and s.good_energy>0),
      'good_energy_per_game',(select count(*)+1 from scores s where s.bucket='selected' and s.games_count>0),
      'sponsored_games',(select count(*)+1 from scores s where s.bucket='selected' and s.sponsored_games>0),
      'all_time_good_power',(select count(*)+1 from scores s where s.bucket='all_time' and s.good_power>100)),
    'top_players',coalesce((select jsonb_agg(t.payload order by t.place,t.user_id) from top_rows t),'[]'::jsonb),
    'players',coalesce((select jsonb_agg(p.payload order by p.place,p.user_id) from page_rows p),'[]'::jsonb),
    'current_user',(select p.payload from players p where p.user_id=p_user_id),
    'pagination',jsonb_build_object('page',p_page,'page_size',p_page_size,
      'total_count',(select count(*) from eligible),
      'has_more',(select count(*) from eligible)>p_page::bigint*p_page_size)
  ) into v_result;
  return v_result;
end;
$$;

notify pgrst, 'reload schema';
commit;

-- Check (read-only): guest places of the current season, prod.
-- select public.gg_v2_rankings('auto','valuable',1,1,null,false)->'guest_places';
