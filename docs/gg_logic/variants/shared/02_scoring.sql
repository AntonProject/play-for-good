-- Local preparation only. Do not execute against the live project without
-- the owner's command. This supersedes docs/gg_rpc_listener/example.sql.
begin;
create schema if not exists gg_v2;
revoke all on schema gg_v2 from public;
grant usage on schema gg_v2 to anon, authenticated;

-- Confirm timezone before live use. Existing date columns are timestamp
-- without time zone; their stored values are compared directly to boundaries.
-- timezone controls the calendar clock, not a conversion of historical rows.
create or replace function gg_v2.config() returns jsonb
language sql immutable security invoker set search_path = '' as $$
  select jsonb_build_object('timezone', 'UTC', 'tie_policy', 'sequential');
$$;

-- Dates come from the table. The basic/RPC packages seed only the two
-- specified seasons; only the admin package can plan subsequent seasons.
create or replace function gg_v2.period_info(
  p_period text,p_now timestamptz default transaction_timestamp()
) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare
  k text := lower(btrim(coalesce(p_period,'auto')));
  c timestamp := p_now at time zone (gg_v2.config()->>'timezone');
  s gg_v2.seasons%rowtype; a timestamp; b timestamp; label text;
begin
  k := case k when 'gesamt' then 'all_time' when 'all-time' then 'all_time'
    when 'saison' then 'auto' when 'saison_2025_26' then 'season_2025_26'
    when 'saison_2026_27' then 'season_2026_27' when 'letzter_monat' then 'last_month'
    when 'dieser_monat' then 'this_month' when 'monat' then 'this_month' else k end;
  if k='auto' then
    select t.season_key into k from gg_v2.seasons t where t.starts_at<=c
      order by t.starts_at desc limit 1;
    k := coalesce(k,'all_time');
  end if;
  select * into s from gg_v2.seasons t where t.season_key=k;
  if found then
    return jsonb_build_object('key',k,'label',s.label,'season_year',s.season_year,
      'period_start',s.starts_at,'period_end_exclusive',s.ends_at,
      'timezone',gg_v2.config()->>'timezone','is_completed',c>=s.ends_at);
  end if;
  case k
    when 'last_month' then b:=date_trunc('month',c); a:=b-interval '1 month'; label:='Letzten Monat';
    when 'this_month' then a:=date_trunc('month',c); b:=a+interval '1 month'; label:='Diesen Monat';
    when 'all_time' then label:='All-Time';
    else raise exception 'Unknown GG period: %',p_period using errcode='22023';
  end case;
  return jsonb_build_object('key',k,'label',label,'season_year',null,
    'period_start',a,'period_end_exclusive',b,'timezone',gg_v2.config()->>'timezone',
    'is_completed',false);
end; $$;

create or replace function gg_v2.season_periods(
  p_now timestamptz default transaction_timestamp()
) returns table(period jsonb) language sql stable security definer set search_path='' as $$
  select gg_v2.period_info(t.season_key,p_now) from gg_v2.seasons t;
$$;

create or replace function gg_v2.available_periods() returns jsonb
language sql stable security definer set search_path='' as $$
  select coalesce(jsonb_agg(p.period order by p.period->>'period_start' desc),'[]'::jsonb)
    ||jsonb_build_array(gg_v2.period_info('last_month'),gg_v2.period_info('this_month'),gg_v2.period_info('all_time'))
  from gg_v2.season_periods() p;
$$;

create or replace function gg_v2.category_key(p_category text)
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
-- Keep gg_v2 OUT of the Data API exposed schemas. No service key on client.
-- Aggregate live periods once per source. Closed seasons/awards use frozen results.
create or replace function gg_v2.score_sets(p_period text,p_test boolean default false)
returns table (
  bucket text, user_id uuid, display_name text, first_name text, surname text,
  photo_url text, good_power numeric, game_power numeric, invite_power numeric,
  games_count bigint, good_energy numeric, good_power_per_game numeric,
  good_energy_per_game numeric, sponsored_games bigint,
  power_rank bigint, games_rank bigint, power_per_game_rank bigint,
  energy_rank bigint, energy_per_game_rank bigint, sponsored_games_rank bigint
) language plpgsql stable security definer set search_path='' as $$
declare
  v_info jsonb := gg_v2.period_info(p_period);
  v_start timestamp := (v_info->>'period_start')::timestamp;
  v_end timestamp := (v_info->>'period_end_exclusive')::timestamp;
  v_shared boolean := gg_v2.config()->>'tie_policy' = 'shared';
  v_frozen boolean := exists(select 1 from gg_v2.season_closures t
    where t.season_key=v_info->>'key' and t.test=p_test and t.finalized_at is not null);
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
    from public.games g where g.status='completed' and g.test=p_test
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
    from public.invites i where i.was_used=true and i.test=p_test
  ), invite_totals as (
    select e.inviter_user_id,
      coalesce(sum(e.gp) filter(where e.selected),0) as sel_gp,sum(e.gp) as all_gp
    from invite_events e group by e.inviter_user_id
  ), bonus_totals as (
    select a.user_id,coalesce(sum(a.amount) filter(where not v_frozen
      and (v_start is null or a.awarded_at>=v_start)
      and (v_end is null or a.awarded_at<v_end)),0) as sel_gp,
      sum(a.amount) as all_gp
    from gg_v2.point_awards a where a.test=p_test group by a.user_id
  ), scores as (
    select b.bucket,u.id as user_id,u.display_name::text,u.first_name::text,u.surname::text,u.photo_url::text,
      b.gp+b.invite_gp+b.bonus_gp as good_power,b.gp as game_power,b.invite_gp as invite_power,
      b.game_count as games_count,b.energy as good_energy,
      case when b.game_count>0 then b.gp/b.game_count else 0 end as good_power_per_game,
      case when b.game_count>0 then b.energy/b.game_count else 0 end as good_energy_per_game,
      b.sponsored as sponsored_games
    from public.users u
    left join game_totals g on g.creator_user_id=u.id
    left join invite_totals i on i.inviter_user_id=u.id
    left join bonus_totals a on a.user_id=u.id
    cross join lateral (values
      ('selected',coalesce(g.sel_gp,0),coalesce(i.sel_gp,0),coalesce(a.sel_gp,0),
        coalesce(g.sel_count,0),coalesce(g.sel_energy,0),coalesce(g.sel_sponsored,0)),
      ('all_time',coalesce(g.all_gp,0),coalesce(i.all_gp,0),coalesce(a.all_gp,0),
        coalesce(g.all_count,0),coalesce(g.all_energy,0),coalesce(g.all_sponsored,0))
    ) as b(bucket,gp,invite_gp,bonus_gp,game_count,energy,sponsored)
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
    from (select * from gg_v2.season_results sr where sr.season_key=v_info->>'key' and sr.test=p_test) r
    full join public.users u on u.id=r.user_id where v_frozen
  ), frozen_awards as (
    select 'award:'||r.season_key as bucket,r.user_id,
      coalesce(u.display_name,r.display_name)::text,coalesce(u.first_name,r.first_name)::text,
      coalesce(u.surname,r.surname)::text,coalesce(u.photo_url,r.photo_url)::text,
      r.good_power,r.game_power,r.invite_power,r.games_count,r.good_energy,
      r.good_power_per_game,r.good_energy_per_game,r.sponsored_games,
      r.power_rank,r.games_rank,r.power_per_game_rank,r.energy_rank,
      r.energy_per_game_rank,r.sponsored_games_rank
    from gg_v2.season_results r join gg_v2.season_closures t using(season_key,test)
    left join public.users u on u.id=r.user_id
    where r.test=p_test and t.finalized_at is not null and (r.power_rank between 1 and 3 or r.games_rank between 1 and 3)
  )
  select * from live_ranked union all select * from frozen_selected union all select * from frozen_awards;
end;
$$;

create or replace function gg_v2.award_flags(p_awards jsonb) returns jsonb
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

create or replace function gg_v2.player_payload(
  p_score jsonb,p_category text,p_awards jsonb
) returns jsonb language sql immutable security invoker set search_path='' as $$
  select jsonb_build_object(
    'user_id',p_score->'user_id','display_name',p_score->'display_name',
    'first_name',p_score->'first_name','surname',p_score->'surname','photo_url',p_score->'photo_url',
    'good_power',p_score->'good_power','game_power',p_score->'game_power',
    'invite_power',p_score->'invite_power',
    'bonus_power',(p_score->>'good_power')::numeric-(p_score->>'game_power')::numeric-(p_score->>'invite_power')::numeric,'games_count',p_score->'games_count',
    'score',case when p_category='active' then p_score->'games_count' else p_score->'good_power' end,
    'rank',case when p_category='active' then p_score->'games_rank' else p_score->'power_rank' end,
    'awards',coalesce(p_awards,'[]'::jsonb),
    'award_flags',gg_v2.award_flags(p_awards)
  );
$$;

-- Restrict default EXECUTE grants. Helper schema is not exposed via PostgREST.
revoke all on function gg_v2.config() from public,anon,authenticated;
revoke all on function gg_v2.period_info(text,timestamptz) from public,anon,authenticated;
revoke all on function gg_v2.season_periods(timestamptz) from public,anon,authenticated;
revoke all on function gg_v2.available_periods() from public,anon,authenticated;
revoke all on function gg_v2.category_key(text) from public,anon,authenticated;
revoke all on function gg_v2.score_sets(text,boolean) from public,anon,authenticated;
revoke all on function gg_v2.award_flags(jsonb) from public,anon,authenticated;
revoke all on function gg_v2.player_payload(jsonb,text,jsonb) from public,anon,authenticated;
grant execute on function gg_v2.config(),gg_v2.period_info(text,timestamptz),
  gg_v2.season_periods(timestamptz),gg_v2.available_periods(),
  gg_v2.category_key(text),gg_v2.score_sets(text,boolean),gg_v2.award_flags(jsonb),
  gg_v2.player_payload(jsonb,text,jsonb) to anon,authenticated;
commit;
