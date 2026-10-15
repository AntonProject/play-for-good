begin;
create or replace function gg_v2.finalize_season(
  p_season text,p_test boolean default false,p_now timestamptz default transaction_timestamp()
) returns boolean language plpgsql volatile security definer set search_path='' as $$
declare v_info jsonb:=gg_v2.period_info(p_season,p_now); v_finalized timestamptz;
begin
  if v_info->>'season_year' is null or not (v_info->>'is_completed')::boolean then
    raise exception 'Only an ended season can be finalized' using errcode='22023';
  end if;
  -- Lock the calendar row as well: admin edits cannot race with closure.
  perform 1 from gg_v2.seasons where season_key=v_info->>'key' for update;
  -- Re-read boundaries after obtaining the lock.
  v_info:=gg_v2.period_info(p_season,p_now);
  if not (v_info->>'is_completed')::boolean then
    raise exception 'Season has not ended' using errcode='22023';
  end if;
  insert into gg_v2.season_closures(season_key,test) values(v_info->>'key',p_test)
    on conflict do nothing;
  select t.finalized_at into v_finalized from gg_v2.season_closures t
    where t.season_key=v_info->>'key' and t.test=p_test for update;
  if v_finalized is not null then return false; end if;
  insert into gg_v2.season_results(
    season_key,test,user_id,display_name,first_name,surname,photo_url,
    good_power,game_power,invite_power,games_count,good_energy,
    good_power_per_game,good_energy_per_game,sponsored_games,
    power_rank,games_rank,power_per_game_rank,energy_rank,energy_per_game_rank,sponsored_games_rank)
  select v_info->>'key',p_test,s.user_id,s.display_name,s.first_name,s.surname,s.photo_url,
    s.good_power,s.game_power,s.invite_power,s.games_count,s.good_energy,
    s.good_power_per_game,s.good_energy_per_game,s.sponsored_games,
    s.power_rank,s.games_rank,s.power_per_game_rank,s.energy_rank,s.energy_per_game_rank,s.sponsored_games_rank
  from gg_v2.score_sets(p_season,p_test) s where s.bucket='selected';
  update gg_v2.season_closures set finalized_at=transaction_timestamp()
    where season_key=v_info->>'key' and test=p_test;
  perform realtime.send(jsonb_build_object('changed_at',transaction_timestamp()),'changed','gg:v2:stats',false);
  return true;
end; $$;

-- BASIC/RPC: close only existing calendar rows. No automatic future seasons.
create or replace function gg_v2.finalize_due_seasons(
  p_now timestamptz default transaction_timestamp()
) returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare s record; e boolean; closed jsonb:='[]'::jsonb;
begin
  for s in select season_key from gg_v2.seasons
    where ends_at<=p_now at time zone 'UTC' order by starts_at
  loop
    foreach e in array array[false,true] loop
      if gg_v2.finalize_season(s.season_key,e,p_now) then
        closed:=closed||jsonb_build_array(jsonb_build_object('season',s.season_key,'test',e));
      end if;
    end loop;
  end loop;
  return jsonb_build_object('finalized',closed);
end; $$;
revoke all on function gg_v2.finalize_season(text,boolean,timestamptz),
  gg_v2.finalize_due_seasons(timestamptz) from public,anon,authenticated;
commit;
