-- LOCAL EXAMPLE ONLY. Not applied to Supabase.
-- Demonstrates profile totals/ranks + invalidation, not the complete GG spec.
-- No +100 presentation bonus. No frozen season results.
-- Monthly boundaries assume UTC. Confirm existing game_date/used_at semantics
-- and the business timezone before deploying monthly filters.
-- Equal scores receive equal ranks in this example (PostgreSQL rank()).

begin;

create schema if not exists gg_internal;
revoke all on schema gg_internal from public;
grant usage on schema gg_internal to anon, authenticated;

-- Deliberately public aggregate statistics, including guest access.
-- Private-schema definer reads invitation contributions across users because
-- invites RLS only permits the inviter to read raw invitation rows.
-- Returns statistics only: no invitation rows, emails, or other private fields.
-- Keep gg_internal out of the Data API's exposed schemas.
create or replace function gg_internal.profile_stats(
  p_user_id uuid,
  p_period text
) returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_period text := p_period;
  v_start timestamp;
  v_end timestamp;
  v_now timestamp := now() at time zone 'UTC';
  v_result jsonb;
begin
  if v_period = 'auto' then
    select season_key into v_period
    from (values
      ('season_2025_26', timestamp '2025-11-20'),
      ('season_2026_27', timestamp '2026-09-01')
    ) as seasons(season_key, starts_at)
    where starts_at <= v_now
    order by starts_at desc
    limit 1;
    v_period := coalesce(v_period, 'all_time');
  end if;

  case v_period
    when 'season_2025_26' then
      v_start := timestamp '2025-11-20';
      v_end := timestamp '2026-09-01';
    when 'season_2026_27' then
      v_start := timestamp '2026-09-01';
      v_end := timestamp '2027-07-01';
    when 'this_month' then
      v_start := date_trunc('month', v_now);
      v_end := v_start + interval '1 month';
    when 'last_month' then
      v_end := date_trunc('month', v_now);
      v_start := v_end - interval '1 month';
    when 'all_time' then
      v_start := null;
      v_end := null;
    else
      raise exception 'Unknown period: %', p_period using errcode = '22023';
  end case;

  with game_totals as (
    select creator_user_id as user_id,
      coalesce(sum(lichtwatt::numeric), 0) as game_power,
      count(*) as games_count
    from public.games
    where status = 'completed'
      and (v_start is null or game_date >= v_start)
      and (v_end is null or game_date < v_end)
    group by creator_user_id
  ), invite_totals as (
    select inviter_user_id as user_id,
      coalesce(sum(lichtwatt::numeric), 0) as invite_power
    from public.invites
    where was_used = true
      and (v_start is null or used_at >= v_start)
      and (v_end is null or used_at < v_end)
    group by inviter_user_id
  ), scores as (
    select u.id as user_id,
      coalesce(g.game_power, 0) + coalesce(i.invite_power, 0) as good_power,
      coalesce(g.games_count, 0) as games_count,
      case when coalesce(g.games_count, 0) > 0
        then g.game_power / g.games_count else 0 end as good_power_per_game
    from public.users u
    left join game_totals g on g.user_id = u.id
    left join invite_totals i on i.user_id = u.id
  ), ranked as (
    -- Rank all users BEFORE selecting the requested profile.
    select *,
      rank() over (order by good_power desc) as power_rank,
      rank() over (order by games_count desc) as games_rank,
      rank() over (order by good_power_per_game desc) as per_game_rank,
      sum(good_power) over () as total_good_power
    from scores
  )
  select jsonb_build_object(
    'user_id', user_id,
    'requested_period', p_period,
    'period', v_period,
    'total_good_power', total_good_power,
    'stats', jsonb_build_object(
      'good_power', jsonb_build_object('value', good_power, 'rank', power_rank),
      'games', jsonb_build_object('value', games_count, 'rank', games_rank),
      'good_power_per_game', jsonb_build_object(
        'value', good_power_per_game, 'rank', per_game_rank)
    )
  ) into v_result
  from ranked where user_id = p_user_id;

  return v_result;
end;
$$;

revoke all on function gg_internal.profile_stats(uuid, text)
  from public, anon, authenticated;
grant execute on function gg_internal.profile_stats(uuid, text)
  to anon, authenticated;

create or replace function public.gg_profile_stats(
  p_user_id uuid,
  p_period text default 'auto'
) returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select gg_internal.profile_stats(p_user_id, p_period);
$$;

revoke all on function public.gg_profile_stats(uuid, text)
  from public, anon, authenticated;
grant execute on function public.gg_profile_stats(uuid, text)
  to anon, authenticated;

-- Payload has no records or personal data. Broadcast is public for guests.
create or replace function gg_internal.notify_stats_changed()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_table_name = 'games' then
    if tg_op = 'INSERT' then
      if new.status is distinct from 'completed' then return new; end if;
    elsif tg_op = 'DELETE' then
      if old.status is distinct from 'completed' then return old; end if;
    else
      if new.status is distinct from 'completed'
        and old.status is distinct from 'completed' then return new; end if;
      if row(new.status, new.creator_user_id, new.game_date, new.lichtwatt)
        is not distinct from
        row(old.status, old.creator_user_id, old.game_date, old.lichtwatt)
        then return new; end if;
    end if;
  elsif tg_table_name = 'invites' then
    if tg_op = 'INSERT' then
      if new.was_used is distinct from true
        then return new; end if;
    elsif tg_op = 'DELETE' then
      if old.was_used is distinct from true
        then return old; end if;
    else
      if row(new.was_used, new.inviter_user_id, new.used_at, new.lichtwatt)
        is not distinct from
        row(old.was_used, old.inviter_user_id, old.used_at, old.lichtwatt)
        then return new; end if;
      if new.was_used is distinct from true
        and old.was_used is distinct from true
        then return new; end if;
    end if;
  end if;

  perform realtime.send(
    jsonb_build_object('changed_at', clock_timestamp()),
    'changed', 'gg:stats', false
  );
  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;

revoke all on function gg_internal.notify_stats_changed()
  from public, anon, authenticated;

create or replace trigger gg_stats_games_changed
after insert or update or delete on public.games
for each row execute function gg_internal.notify_stats_changed();

create or replace trigger gg_stats_invites_changed
after insert or update or delete on public.invites
for each row execute function gg_internal.notify_stats_changed();

-- User insertion/deletion also changes the participant set/ranks.
create or replace trigger gg_stats_users_changed
after insert or delete on public.users
for each row execute function gg_internal.notify_stats_changed();

commit;
