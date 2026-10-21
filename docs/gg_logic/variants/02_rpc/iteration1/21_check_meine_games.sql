-- READ-ONLY (20.10.2026). Tester, iPhone: Good Games -> Meine Games, filter
-- "Saison 2025/26": the stats show 1 game (#4), the list below is an empty box.
-- For an ended (finalized) season the stats come from the stored results
-- (gg_v2.season_results), the list comes from the live games table
-- (completed games of the user with game_date inside the season).
-- This lists every user whose stored games_count differs from the live count.

with s as (
  select season_key, starts_at, ends_at from gg_v2.seasons where season_key = 'season_2025_26'
), stored as (
  select r.test, r.user_id, r.games_count as stored_games
  from gg_v2.season_results r join s using (season_key)
  where r.games_count > 0
), live as (
  select g.test, g.creator_user_id as user_id, count(*) as live_games
  from public.games g, s
  where g.status = 'completed' and g.game_date >= s.starts_at and g.game_date < s.ends_at
  group by 1, 2
)
select coalesce(st.test, l.test) as test, coalesce(st.user_id, l.user_id) as user_id,
       u.display_name, st.stored_games, l.live_games
from stored st
full join live l on l.user_id = st.user_id and l.test = st.test
left join public.users u on u.id = coalesce(st.user_id, l.user_id)
where coalesce(st.stored_games, 0) <> coalesce(l.live_games, 0)
order by 1, 2;

-- Details for the users the list returns (paste the user_id):
-- select id, test, status, game_date, created_at, lichtwatt
-- from public.games where creator_user_id = '<user_id>' order by game_date;
