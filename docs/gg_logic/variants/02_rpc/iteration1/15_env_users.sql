-- Home gauge average per environment (16.10.2026).
-- The average line divided by ALL registered users (prod and test builds
-- together); in test builds only test data is shown, so it must divide by the
-- users of that environment.
--   gg_v2.env_users_count(p_test, p_exclude)  users signed up from that build
--       (users.signup_test) or with points in that environment (completed
--       games, used invites, signup bonus), without p_exclude
--   gg_v2_rankings  new response field env_other_users_count = users of the
--       environment except the requested user (all of them for a guest);
--       every other field stays the same (legacy_bonus_users_count is kept:
--       the guest name @playerforgood_N uses it)
-- Run the WHOLE file in the Supabase SQL editor (owner); one transaction.
-- What it changes: one new read-only function, gg_v2_rankings replaced.
-- Not touched: tables, data, triggers, cron. Includes guest_places (12).
begin;
create or replace function gg_v2.env_users_count(p_test boolean,p_exclude uuid default null) returns bigint
language sql stable security definer set search_path='' as $$
  select count(*) from public.users u
  where u.id is distinct from p_exclude
    and (u.signup_test = p_test
     or exists (select 1 from public.games g where g.creator_user_id = u.id and g.status = 'completed' and g.test = p_test)
     or exists (select 1 from public.invites i where i.inviter_user_id = u.id and i.was_used and i.test = p_test)
     or exists (select 1 from gg_v2.point_awards a where a.user_id = u.id and a.test = p_test));
$$;
revoke all on function gg_v2.env_users_count(boolean,uuid) from public,anon,authenticated;
grant execute on function gg_v2.env_users_count(boolean,uuid) to anon,authenticated;

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
    'env_other_users_count',gg_v2.env_users_count(p_test,p_user_id),
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

-- Check (read-only): users per environment.
-- select gg_v2.env_users_count(false) as prod, gg_v2.env_users_count(true) as test,
--        gg_v2.registered_users_count() as all_users;
