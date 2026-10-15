-- Local preparation only. Apply after 00_season_tables.sql and 01_functions.sql.
begin;
-- Owner-only operation. Cron runs this as the database owner, never the client.
-- p_now is only for an owner's rehearsal in a disposable test DB.
create or replace function gg_internal.finalize_season(
  p_season text,p_now timestamptz default transaction_timestamp()
) returns boolean language plpgsql volatile security definer set search_path='' as $$
declare
  v_info jsonb := gg_internal.period_info(p_season,p_now);
  v_key text := v_info->>'key';
  v_finalized timestamptz;
begin
  if v_info->>'season_year' is null then
    raise exception 'Only a season can be finalized' using errcode='22023';
  end if;
  if not (v_info->>'is_completed')::boolean then
    raise exception 'Season % has not ended',v_key using errcode='22023';
  end if;
  insert into gg_internal.seasons(season_key,label,season_year,starts_at,ends_at)
  values(v_key,v_info->>'label',(v_info->>'season_year')::integer,
    (v_info->>'period_start')::timestamp,(v_info->>'period_end_exclusive')::timestamp)
  on conflict(season_key) do nothing;
  -- A row lock serializes concurrent cron/manual runs. An already finalized
  -- season is a no-op; its existing results must not be overwritten.
  select t.finalized_at into v_finalized from gg_internal.seasons t
    where t.season_key=v_key for update;
  if v_finalized is not null then return false; end if;

  insert into gg_internal.season_results(
    season_key,user_id,display_name,first_name,surname,photo_url,
    good_power,game_power,invite_power,games_count,good_energy,
    good_power_per_game,good_energy_per_game,sponsored_games,
    power_rank,games_rank,power_per_game_rank,energy_rank,energy_per_game_rank,sponsored_games_rank)
  select v_key,s.user_id,s.display_name,s.first_name,s.surname,s.photo_url,
    s.good_power,s.game_power,s.invite_power,s.games_count,s.good_energy,
    s.good_power_per_game,s.good_energy_per_game,s.sponsored_games,
    s.power_rank,s.games_rank,s.power_per_game_rank,s.energy_rank,s.energy_per_game_rank,s.sponsored_games_rank
  from gg_internal.score_sets(v_key) s where s.bucket='selected';
  update gg_internal.seasons set finalized_at=transaction_timestamp() where season_key=v_key;
  perform realtime.send(jsonb_build_object('changed_at',transaction_timestamp()),'changed','gg:stats',false);
  return true;
end;
$$;

create or replace function gg_internal.finalize_due_seasons(
  p_now timestamptz default transaction_timestamp()
) returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare v_period jsonb; v_closed jsonb := '[]'::jsonb;
begin
  -- Keep the season calendar populated automatically as years advance.
  for v_period in select p.period from gg_internal.season_periods(p_now) p
    order by (p.period->>'season_year')::integer
  loop
    insert into gg_internal.seasons(season_key,label,season_year,starts_at,ends_at)
    values(v_period->>'key',v_period->>'label',(v_period->>'season_year')::integer,
      (v_period->>'period_start')::timestamp,(v_period->>'period_end_exclusive')::timestamp)
    on conflict(season_key) do nothing;
    if (v_period->>'is_completed')::boolean then
      if gg_internal.finalize_season(v_period->>'key',p_now) then
        v_closed := v_closed||jsonb_build_array(v_period->>'key');
      end if;
    end if;
  end loop;
  return jsonb_build_object('finalized_seasons',v_closed);
end;
$$;

revoke all on function gg_internal.finalize_season(text,timestamptz) from public,anon,authenticated;
revoke all on function gg_internal.finalize_due_seasons(timestamptz) from public,anon,authenticated;
commit;
-- Initial backfill of ended seasons is a separate explicit owner operation:
-- select gg_internal.finalize_due_seasons();
