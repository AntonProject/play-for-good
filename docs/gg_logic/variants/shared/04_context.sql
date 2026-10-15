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
