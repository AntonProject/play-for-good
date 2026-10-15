-- READ-ONLY verification of Good Games v2 numbers (owner runs it in the
-- Supabase SQL editor; only SELECT, nothing is changed).
--
-- One result table, one row per check / environment / period:
--   check      what is compared
--   env        prod (test=false) / test (test=true)
--   period     all_time, auto (current season), this_month, last_month, this_week
--   checked    rows compared
--   mismatches rows that differ (expected 0, except the "legacy" rows, which
--              explain the difference to the old app)
--   detail     first differing rows / the numbers
--
-- Rules recomputed here straight from the tables (independent of gg_v2 code):
--   game power   = sum(games.lichtwatt), status 'completed', same test flag,
--                  game_date inside the period
--   invite power = sum(invites.lichtwatt), was_used, same test flag, used_at
--                  inside the period
--   bonus        = gg_v2.point_awards (guest registration +100), same test
--                  flag, awarded_at inside the period
--   Good Power   = game + invite + bonus; games = number of those games
-- Closed seasons are frozen (season_results) and are checked separately.

with envs(test, env) as (values (false, 'prod'), (true, 'test')),
periods(period) as (values ('all_time'), ('auto'), ('this_month'), ('last_month'), ('this_week')),
bounds as (
  select e.test, e.env, p.period,
         (gg_v2.period_info(p.period)->>'period_start')::timestamp as s,
         (gg_v2.period_info(p.period)->>'period_end_exclusive')::timestamp as x,
         gg_v2.period_info(p.period)->>'key' as key
  from envs e cross join periods p
),
-- independent recomputation
games_p as (
  select b.test, b.period, g.creator_user_id as user_id,
         sum(coalesce(g.lichtwatt::numeric, 0)) as gp, count(*) as n
  from bounds b join public.games g
    on g.status = 'completed' and g.test = b.test
   and (b.s is null or g.game_date >= b.s) and (b.x is null or g.game_date < b.x)
  group by 1, 2, 3
),
invites_p as (
  select b.test, b.period, i.inviter_user_id as user_id, sum(coalesce(i.lichtwatt::numeric, 0)) as ip
  from bounds b join public.invites i
    on i.was_used = true and i.test = b.test
   and (b.s is null or i.used_at >= b.s) and (b.x is null or i.used_at < b.x)
  group by 1, 2, 3
),
bonus_p as (
  select b.test, b.period, a.user_id, sum(a.amount) as bp
  from bounds b join gg_v2.point_awards a
    on a.test = b.test
   and (b.s is null or a.awarded_at >= b.s) and (b.x is null or a.awarded_at < b.x)
  group by 1, 2, 3
),
expected as (
  select b.test, b.env, b.period, u.id as user_id,
         coalesce(g.gp, 0) + coalesce(i.ip, 0) + coalesce(a.bp, 0) as good_power,
         coalesce(g.gp, 0) as game_power, coalesce(i.ip, 0) as invite_power,
         coalesce(a.bp, 0) as bonus, coalesce(g.n, 0) as games
  from bounds b cross join public.users u
  left join games_p g on g.test = b.test and g.period = b.period and g.user_id = u.id
  left join invites_p i on i.test = b.test and i.period = b.period and i.user_id = u.id
  left join bonus_p a on a.test = b.test and a.period = b.period and a.user_id = u.id
  where not exists (select 1 from gg_v2.season_closures c
                    where c.season_key = b.key and c.test = b.test and c.finalized_at is not null)
),
-- what the RPCs use
actual as (
  select b.test, b.period, s.user_id, s.good_power, s.game_power, s.invite_power, s.games_count
  from bounds b cross join lateral gg_v2.score_sets(b.period, b.test) s
  where s.bucket = 'selected'
),
diff as (
  select e.*, a.good_power as a_power, a.games_count as a_games
  from expected e left join actual a on a.test = e.test and a.period = e.period and a.user_id = e.user_id
  where a.user_id is null or a.good_power <> e.good_power or a.games_count <> e.games
     or a.game_power <> e.game_power or a.invite_power <> e.invite_power
),
check_scores as (
  select '1 scores per user = tables' as "check", e.env, e.period,
         count(*) as checked,
         (select count(*) from diff d where d.test = e.test and d.period = e.period) as mismatches,
         coalesce((select string_agg(d.user_id || ': ' || d.good_power || ' vs ' || coalesce(d.a_power::text, 'missing'), '; ')
                   from (select * from diff d where d.test = e.test and d.period = e.period limit 3) d), '') as detail
  from expected e group by e.test, e.env, e.period
),
-- RPC totals used by the Home gauge and the ranking header
rpc as (
  select b.test, b.env, b.period, public.gg_v2_rankings(b.period, 'valuable', 1, 3, null, b.test) as r
  from bounds b
  where not exists (select 1 from gg_v2.season_closures c
                    where c.season_key = b.key and c.test = b.test and c.finalized_at is not null)
),
check_totals as (
  select '2 RPC totals = tables' as "check", r.env, r.period,
         1::bigint as checked,
         (case when (r.r->>'total_good_power')::numeric = t.total and (r.r->>'max_good_power')::numeric = t.mx
               and coalesce((r.r->'top_players'->0->>'good_power')::numeric, 0) = t.mx then 0 else 1 end)::bigint as mismatches,
         'total ' || (r.r->>'total_good_power') || ' / expected ' || t.total
           || ', max ' || (r.r->>'max_good_power') || ' / expected ' || t.mx
           || ', top1 ' || coalesce(r.r->'top_players'->0->>'good_power', '-') as detail
  from rpc r
  cross join lateral (select coalesce(sum(e.good_power), 0) as total, coalesce(max(e.good_power), 0) as mx
                      from expected e where e.test = r.test and e.period = r.period) t
),
-- test data never reaches prod and back
check_isolation as (
  select '3 test/prod isolation' as "check", e.env, 'all_time' as period,
         (select count(*) from public.games g where g.status = 'completed' and g.test = e.test) as checked,
         (select count(*) from gg_v2.score_sets('all_time', e.test) s
           where s.bucket = 'selected' and s.game_power <>
             (select coalesce(sum(g.lichtwatt::numeric), 0) from public.games g
               where g.creator_user_id = s.user_id and g.status = 'completed' and g.test = e.test)) as mismatches,
         'completed games of this env: ' || (select count(*) from public.games g where g.status = 'completed' and g.test = e.test)
           || ', of the other env: ' || (select count(*) from public.games g where g.status = 'completed' and g.test <> e.test) as detail
  from envs e
),
-- frozen closed seasons: stored results vs the tables at closing time rules
check_frozen as (
  select '4 closed season results stored' as "check", case when c.test then 'test' else 'prod' end as env, c.season_key as period,
         (select count(*) from gg_v2.season_results r where r.season_key = c.season_key and r.test = c.test) as checked,
         (select count(*) from gg_v2.season_results r where r.season_key = c.season_key and r.test = c.test
           and r.good_power <> r.game_power + r.invite_power
              + coalesce((select sum(a.amount) from gg_v2.point_awards a, gg_v2.seasons s
                          where s.season_key = c.season_key and a.user_id = r.user_id and a.test = c.test
                            and a.awarded_at >= s.starts_at and a.awarded_at < s.ends_at), 0)) as mismatches,
         'finalized ' || c.finalized_at as detail
  from gg_v2.season_closures c where c.finalized_at is not null
),
-- old app (before v2), prod: games of every test flag and status filter of the
-- old query + invites + 100 for every user. Explains the difference only.
legacy as (
  select u.id as user_id,
         coalesce((select sum(g.lichtwatt::numeric) from public.games g where g.creator_user_id = u.id and g.status = 'completed'), 0)
         + coalesce((select sum(i.lichtwatt::numeric) from public.invites i where i.inviter_user_id = u.id and i.was_used = true), 0)
         + 100 as old_power
  from public.users u
),
check_legacy as (
  select '5 legacy all-time (explains the change)' as "check", 'prod' as env, 'all_time' as period,
         count(*) as checked,
         count(*) filter (where l.old_power <> e.good_power) as mismatches,
         'users: ' || count(*)
           || ', minus 100 (no retroactive bonus): ' || count(*) filter (where e.bonus = 0)
           || ', guest bonus kept: ' || count(*) filter (where e.bonus > 0)
           || ', test games/invites excluded for: '
           || count(*) filter (where l.old_power - 100 + e.bonus <> e.good_power)
           || ', sum old ' || sum(l.old_power) || ' -> new ' || sum(e.good_power) as detail
  from legacy l join expected e on e.user_id = l.user_id and e.test = false and e.period = 'all_time'
)
select * from check_scores
union all select * from check_totals
union all select * from check_isolation
union all select * from check_frozen
union all select * from check_legacy
order by 1, 2, 3;
