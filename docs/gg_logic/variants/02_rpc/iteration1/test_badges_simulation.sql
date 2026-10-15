-- TEST: simulated past seasons with awards for one user (profile badges check).
-- Run in the Supabase SQL editor (owner). Production data, test=false, because
-- Local Run uses the production environment.
--
-- What it changes (only these rows, nothing existing is modified):
--   gg_v2.seasons          + 2 rows: season_2023_24_test, season_2024_25_test
--                           (dates 2023-11-01..2024-09-01 and 2024-11-01..2025-09-01,
--                            before the real 2025/26 season, so no overlap)
--   gg_v2.season_closures  + 2 rows: both seasons closed (test=false)
--   gg_v2.season_results   + 2 rows for the chosen user:
--                            2024/25: MVP 1st + MAP 1st, 2023/24: MVP 2nd + MAP 3rd
-- Not touched: games, invites, users, point_awards, the real 2025/26 results.
-- Side effects while the rows exist:
--   * the user's profile (for everyone who opens it) shows these 4 badges;
--   * Good Games table medals stay on the last closed season = 2025/26 (newest);
--   * the RPC lists the two seasons in available_periods (the app's period
--     lists are fixed in FF, so they do not appear there).
-- Remove everything with the CLEANUP block at the end.

begin;

-- The user: @handle without "@". Fails unless exactly one user matches.
create temporary table _badge_user on commit drop as
  select id from public.users where display_name = 'anton';
do $$ begin
  if (select count(*) from _badge_user) <> 1 then
    raise exception 'Expected exactly one user with display_name = anton, found %',
      (select count(*) from _badge_user);
  end if;
end $$;

insert into gg_v2.seasons(season_key, label, season_year, starts_at, ends_at) values
  ('season_2023_24_test', 'Saison 2023/24 (Test)', 2024, '2023-11-01', '2024-09-01'),
  ('season_2024_25_test', 'Saison 2024/25 (Test)', 2025, '2024-11-01', '2025-09-01')
on conflict (season_key) do nothing;

insert into gg_v2.season_closures(season_key, test, finalized_at) values
  ('season_2023_24_test', false, now()),
  ('season_2024_25_test', false, now())
on conflict (season_key, test) do nothing;

insert into gg_v2.season_results(
  season_key, test, user_id, display_name, first_name, surname, photo_url,
  good_power, game_power, invite_power, games_count, good_energy,
  good_power_per_game, good_energy_per_game, sponsored_games,
  power_rank, games_rank, power_per_game_rank, energy_rank, energy_per_game_rank, sponsored_games_rank)
select r.season_key, false, u.id, p.display_name, p.first_name, p.surname, p.photo_url,
  r.good_power, r.good_power, 0, r.games_count, r.good_power,
  r.good_power / r.games_count, r.good_power / r.games_count, 0,
  r.power_rank, r.games_rank, null, null, null, null
from _badge_user u
join public.users p on p.id = u.id
cross join (values
  ('season_2024_25_test', 2500::numeric, 40::bigint, 1::bigint, 1::bigint),
  ('season_2023_24_test', 1800::numeric, 25::bigint, 2::bigint, 3::bigint)
) as r(season_key, good_power, games_count, power_rank, games_rank)
on conflict (season_key, test, user_id) do nothing;

-- Check: the awards the app will receive for this user.
select public.gg_v2_profile_stats((select id from _badge_user), 'all_time', false) -> 'awards' as awards;

commit;

-- CLEANUP (run when the check is done):
-- begin;
-- delete from gg_v2.season_results  where season_key in ('season_2023_24_test','season_2024_25_test');
-- delete from gg_v2.season_closures where season_key in ('season_2023_24_test','season_2024_25_test');
-- delete from gg_v2.seasons         where season_key in ('season_2023_24_test','season_2024_25_test');
-- commit;
