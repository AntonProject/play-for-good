-- READ-ONLY: everything about the users who signed up TODAY (UTC day of the
-- Auth registration), one table (owner, Supabase SQL editor). Nothing is changed.
-- Another day: change the date in the first line of the query
-- (e.g. current_date - 1 for yesterday and today).
--
-- Columns: nick | section | item | value | ok
--   ok = 'OK' / 'CHECK' where there is a rule to compare, empty otherwise.
-- Rules:
--   bonus   guest signup: users.guest_signup_bonus = 100 and ONE point_awards
--           row (signup_bonus, 100) in the env of users.signup_test;
--           normal signup: 0 and no row
--   posts   every completed game has a post; post.test = game.test
--   totals  per env (prod/test): Good Power from the tables (completed games +
--           used invites + bonus) = gg_v2_profile_stats, All-Time and current
--           season; the place is shown as is

with since(d) as (values (current_date)),
me as (
  select u.* from public.users u
  join auth.users a on a.id = u.id
  cross join since
  where (a.created_at at time zone 'utc')::date >= since.d
),
envs(test, env) as (values (false, 'prod'), (true, 'test')),
season as (
  select (gg_v2.period_info('auto')->>'period_start')::timestamp as s,
         (gg_v2.period_info('auto')->>'period_end_exclusive')::timestamp as x,
         gg_v2.period_info('auto')->>'label' as label
),
migrated as (select coalesce((gg_v2.config()->>'signup_bonus_migrated')::boolean, false) as on_),
rows as (
  -- user
  select coalesce(me.display_name, me.id::text) as nick, 1 as o, 'user' as section, 'id' as item, me.id::text as value, '' as ok from me
  union all select coalesce(me.display_name, me.id::text), 2, 'user', 'display_name / first_name', coalesce(me.display_name, '-') || ' / ' || coalesce(me.first_name, '-'), '' from me
  union all select coalesce(me.display_name, me.id::text), 3, 'user', 'auth created / email confirmed',
    coalesce((select a.created_at::text from auth.users a where a.id = me.id), 'no auth row') || ' / ' ||
    coalesce((select a.email_confirmed_at::text from auth.users a where a.id = me.id), 'not confirmed'),
    case when exists (select 1 from auth.users a where a.id = me.id) then 'OK' else 'CHECK' end from me
  union all select coalesce(me.display_name, me.id::text), 4, 'user', 'signup_test (env of the signup)',
    coalesce((to_jsonb(me)->>'signup_test'), '-'), '' from me
  -- bonus
  union all select coalesce(me.display_name, me.id::text), 10, 'bonus', 'users.guest_signup_bonus', coalesce(to_jsonb(me)->>'guest_signup_bonus', '-'), '' from me
  union all select coalesce(me.display_name, me.id::text), 11, 'bonus', 'point_awards',
    coalesce((select string_agg(a.reason || ' ' || a.amount || ' ' || case when a.test then 'test' else 'prod' end || ' at ' || a.awarded_at, '; ')
              from gg_v2.point_awards a where a.user_id = me.id), 'none'),
    case
      when coalesce((to_jsonb(me)->>'guest_signup_bonus')::int, 0) = 100
       and (select count(*) from gg_v2.point_awards a where a.user_id = me.id) = 1
       and exists (select 1 from gg_v2.point_awards a where a.user_id = me.id and a.amount = 100
                   and a.test = coalesce((to_jsonb(me)->>'signup_test')::boolean, false)) then 'OK (guest signup)'
      when coalesce((to_jsonb(me)->>'guest_signup_bonus')::int, 0) = 0
       and not exists (select 1 from gg_v2.point_awards a where a.user_id = me.id) then 'OK (normal signup)'
      else 'CHECK' end
  from me
  union all select coalesce(me.display_name, me.id::text), 12, 'bonus', 'bonus counted in Good Power (rollout)', (select on_::text from migrated), '' from me
  -- games
  union all select coalesce(me.display_name, me.id::text), 20, 'games', g.status || ' ' || case when g.test then 'test' else 'prod' end || ' ' || coalesce(g.game_date::text, '-'),
    coalesce(g.lichtwatt::text, '0') || ' LW, ' || coalesce(to_jsonb(g)->>'org_display_name', g.organization_id::text, '-')
      || ', posts: ' || (select count(*) from public.posts p where p.game_id = g.id)
      || coalesce(' (post test ' || (select string_agg(coalesce(to_jsonb(p)->>'test', 'no column'), ',') from public.posts p where p.game_id = g.id) || ')', ''),
    case when g.status <> 'completed' then ''
         when not exists (select 1 from public.posts p where p.game_id = g.id) then 'CHECK no post'
         when exists (select 1 from public.posts p where p.game_id = g.id
                      and coalesce(to_jsonb(p)->>'test', 'false') <> g.test::text) then 'CHECK post env'
         else 'OK' end
  from me join public.games g on g.creator_user_id = me.id
  -- invites I sent
  union all select coalesce(me.display_name, me.id::text), 30, 'invites sent', case when i.was_used then 'used' else 'open' end || ' ' || case when i.test then 'test' else 'prod' end
      || ' ' || coalesce(i.used_at::text, '-'),
    coalesce(i.lichtwatt::text, '0') || ' LW' || coalesce(', registered: ' || (select u.display_name from public.users u where u.id = (to_jsonb(i)->>'registered_user_id')::uuid), ''),
    ''
  from me join public.invites i on i.inviter_user_id = me.id
  -- the invite that brought me
  union all select coalesce(me.display_name, me.id::text), 31, 'invite received', 'from ' || coalesce((select u.display_name from public.users u where u.id = i.inviter_user_id), i.inviter_user_id::text),
    case when i.was_used then 'used' else 'open' end || ' ' || case when i.test then 'test' else 'prod' end || ', ' || coalesce(i.lichtwatt::text, '0') || ' LW to the inviter', ''
  from me join public.invites i on (to_jsonb(i)->>'registered_user_id') = me.id::text
  -- totals per env: tables vs RPC
  union all
  select coalesce(me.display_name, me.id::text), 40 + case when e.test then 1 else 0 end, 'totals ' || e.env,
    'All-Time: tables ' || t.at_power || ' / RPC ' || coalesce(st.r->'all_time'->>'good_power', '-')
      || ', place #' || coalesce(st.r->'all_time'->>'rank', '-'),
    'games ' || t.at_games || ', invites ' || t.at_invites || ', bonus ' || t.at_bonus,
    case when (st.r->'all_time'->>'good_power')::numeric = t.at_power then 'OK' else 'CHECK' end
  from me cross join envs e
  cross join lateral (
    select
      coalesce((select sum(g.lichtwatt::numeric) from public.games g where g.creator_user_id = me.id and g.status = 'completed' and g.test = e.test), 0) as at_games,
      coalesce((select sum(i.lichtwatt::numeric) from public.invites i where i.inviter_user_id = me.id and i.was_used and i.test = e.test), 0) as at_invites,
      case when (select on_ from migrated) then coalesce((select sum(a.amount) from gg_v2.point_awards a where a.user_id = me.id and a.test = e.test), 0) else 0 end as at_bonus
  ) t0
  cross join lateral (select t0.*, t0.at_games + t0.at_invites + t0.at_bonus as at_power) t
  cross join lateral (select public.gg_v2_profile_stats(me.id, 'all_time', e.test) as r) st
  union all
  select coalesce(me.display_name, me.id::text), 42 + case when e.test then 1 else 0 end, 'totals ' || e.env,
    (select label from season) || ': tables ' || t.power || ' / RPC ' || coalesce(st.r->'stats'->'good_power'->>'value', '-')
      || ', place #' || coalesce(st.r->'stats'->'good_power'->>'rank', '-'),
    'games ' || t.games_n || ' (' || coalesce(st.r->'stats'->'games'->>'value', '-') || ' in RPC)',
    case when (st.r->'stats'->'good_power'->>'value')::numeric = t.power
          and (st.r->'stats'->'games'->>'value')::numeric = t.games_n then 'OK' else 'CHECK' end
  from me cross join envs e cross join season
  cross join lateral (
    select
      coalesce((select sum(g.lichtwatt::numeric) from public.games g where g.creator_user_id = me.id and g.status = 'completed' and g.test = e.test
                and g.game_date >= season.s and g.game_date < season.x), 0)
      + coalesce((select sum(i.lichtwatt::numeric) from public.invites i where i.inviter_user_id = me.id and i.was_used and i.test = e.test
                and i.used_at >= season.s and i.used_at < season.x), 0)
      + case when (select on_ from migrated) then coalesce((select sum(a.amount) from gg_v2.point_awards a where a.user_id = me.id and a.test = e.test
                and a.awarded_at >= season.s and a.awarded_at < season.x), 0) else 0 end as power,
      (select count(*) from public.games g where g.creator_user_id = me.id and g.status = 'completed' and g.test = e.test
                and g.game_date >= season.s and g.game_date < season.x) as games_n
  ) t
  cross join lateral (select public.gg_v2_profile_stats(me.id, 'auto', e.test) as r) st
)
select nick, section, item, value, ok from (
  select nick, o, section, item, value, ok from rows
  union all
  select '-', 0, 'user', 'no users signed up since', (select d::text from since), 'CHECK' where not exists (select 1 from me)
) r
order by nick, o, item;
