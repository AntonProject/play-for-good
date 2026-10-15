-- Recompute the prod results of season_2025_26 without the retroactive +100
-- (owner decision 15.10.2026; see 10_check_season_2025_26.sql).
-- The season was closed on 13.10.2026 while the 53 retroactive bonus rows were
-- still counted; they were removed by 07_cleanup.sql, the frozen results kept
-- them (42 users +100). Expected change: MVP 2 timoor, MVP 3 jcd33 (were
-- swapped); MAP places unchanged.
-- Run the WHOLE file in the Supabase SQL editor (owner); one transaction.
--
-- What it changes:
--   gg_v2.season_results  prod rows of season_2025_26 deleted and written again
--                         from the current games / invites / point_awards
--   gg_v2.season_closures prod row of season_2025_26 written again (new finalized_at)
-- Not touched: test results (closed without the bonus), other seasons, users,
-- games, invites. Medals of 2025/26 shown in the app follow the new results.

begin;
select gg_v2.refinalize_season('season_2025_26', false) as refinalized;
commit;

-- Check 1: no bonus left inside the results (expected one row: 0 | 61).
-- Check 2 (separately): top places now.
select good_power - game_power - invite_power as bonus_in_results, count(*) as users
from gg_v2.season_results
where season_key = 'season_2025_26' and test = false
group by 1 order by 1;

-- select coalesce(display_name, first_name) as name, good_power, power_rank, games_count, games_rank
-- from gg_v2.season_results
-- where season_key = 'season_2025_26' and test = false and (power_rank <= 3 or games_rank <= 3)
-- order by power_rank nulls last, games_rank;
