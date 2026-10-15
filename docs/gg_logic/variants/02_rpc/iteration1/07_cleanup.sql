-- Owner decision (14.10.2026): remove the retroactive +100 and the test seasons.
-- Run the WHOLE file in the Supabase SQL editor (owner); one transaction.
--
-- What it deletes:
--   gg_v2.point_awards   signup_bonus rows of users WITHOUT the guest
--                        registration bonus (users.guest_signup_bonus <> 100):
--                        the 53 retroactive rows (none from the guest flow yet).
--   gg_v2.season_results / season_closures / seasons
--                        only season_2023_24_test and season_2024_25_test
--                        (test_badges_simulation.sql).
-- Not touched: users, games, invites, posts, the real seasons 2025/26 and
-- 2026/27 and their results, rollout switches.
-- Effect: those 53 users lose +100 in All-Time and the current season (the
-- closed 2025/26 results never had it); anton's 4 test badges disappear.

-- 0. Preview (read-only).
select count(*) as bonus_rows_to_delete
from gg_v2.point_awards a
where a.reason='signup_bonus'
  and not exists (select 1 from public.users u where u.id=a.user_id and u.guest_signup_bonus=100);
select 'season_results' as tbl, count(*) from gg_v2.season_results where season_key in ('season_2023_24_test','season_2024_25_test')
union all
select 'season_closures', count(*) from gg_v2.season_closures where season_key in ('season_2023_24_test','season_2024_25_test')
union all
select 'seasons', count(*) from gg_v2.seasons where season_key in ('season_2023_24_test','season_2024_25_test');

begin;

delete from gg_v2.point_awards a
where a.reason='signup_bonus'
  and not exists (select 1 from public.users u where u.id=a.user_id and u.guest_signup_bonus=100);

delete from gg_v2.season_results  where season_key in ('season_2023_24_test','season_2024_25_test');
delete from gg_v2.season_closures where season_key in ('season_2023_24_test','season_2024_25_test');
delete from gg_v2.seasons         where season_key in ('season_2023_24_test','season_2024_25_test');

commit;

-- Check: expected 0 and 0.
select (select count(*) from gg_v2.point_awards) as bonus_rows_left,
       (select count(*) from gg_v2.seasons where season_key like '%\_test' escape '\') as test_seasons_left;
