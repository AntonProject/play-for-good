-- READ-ONLY: why the stored prod results of season_2025_26 differ (09 check 4).
-- Hypothesis: the season was closed (13.10.2026 19:51 UTC) while the 53
-- retroactive +100 rows were still in gg_v2.point_awards and counted, so the
-- frozen good_power contains +100 that was removed later (07_cleanup.sql).
-- Nothing is changed.

-- 1) The difference per user: expected only 0 or 100.
select good_power - game_power - invite_power as bonus_in_results, count(*) as users
from gg_v2.season_results
where season_key = 'season_2025_26' and test = false
group by 1 order by 1;

-- 2) Top 3 MVP (Good Power) and MAP (games) now vs without the bonus.
--    Ties: more games / later activity are not stored, so equal sums are
--    marked "tie" for a manual look.
with r as (
  select user_id, coalesce(display_name, first_name, user_id::text) as name,
         good_power, game_power + invite_power as without_bonus, games_count,
         power_rank, games_rank
  from gg_v2.season_results
  where season_key = 'season_2025_26' and test = false
),
n as (
  select r.*, rank() over (order by without_bonus desc) as new_power_rank,
         count(*) over (partition by without_bonus) > 1 and without_bonus > 0 as tie
  from r
)
select name, good_power as stored_power, power_rank as stored_mvp_place,
       without_bonus, case when without_bonus > 0 then new_power_rank end as mvp_place_without_bonus,
       tie, games_count, games_rank as map_place
from n
where power_rank <= 5 or (without_bonus > 0 and new_power_rank <= 5)
order by coalesce(new_power_rank, 99), power_rank;
