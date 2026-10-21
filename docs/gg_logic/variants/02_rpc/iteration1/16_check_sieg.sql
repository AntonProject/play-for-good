-- READ-ONLY: are sieg_money / sieg_points swapped in stored games? Nothing is changed.
-- The payment page inserts 'sieg_money' <- win POINTS and 'sieg_points' <- win MONEY
-- (swapped; money = points * rate, rate 0 or 1). With rate 1 both are equal;
-- with rate 0 and points > 0 sieg_money holds the points, and
-- unified_game_processing then adds them to total_user_amount, organization
-- energy and lichtwatt (x10).
-- Signs of a swapped row: sieg_points_to_euro_rate = 0 and sieg_money > 0
-- (correct would be sieg_money = 0), or sieg_money <> sieg_points * rate.

-- 1) Overview per environment and status.
select case when g.test then 'test' else 'prod' end as env, g.status,
       count(*) as games,
       count(*) filter (where coalesce(g.sieg_points_to_euro_rate, 1) = 0 and coalesce(g.sieg_money, 0) > 0) as rate0_with_sieg_money,
       count(*) filter (where coalesce(g.sieg_money, 0) <> coalesce(g.sieg_points, 0)) as money_ne_points,
       coalesce(sum(g.sieg_money) filter (where coalesce(g.sieg_points_to_euro_rate, 1) = 0), 0) as wrong_sieg_euro_total,
       coalesce(sum(g.sieg_money) filter (where coalesce(g.sieg_points_to_euro_rate, 1) = 0), 0) * 10 as wrong_lichtwatt_total
from public.games g
group by 1, 2
order by 1, 2;

-- 2) The affected completed games (run separately): what they hold and what
--    they should hold.
-- select g.id, g.test, g.game_date, g.creator_user_id, g.organization_id,
--        g.sieg_points, g.sieg_money, g.sieg_points_to_euro_rate as rate,
--        g.user_money, g.team_money, g.additional_donation_money, g.sponsor_money,
--        g.lichtwatt, g.total_user_amount,
--        g.sieg_money * 10 as lichtwatt_too_much
-- from public.games g
-- where g.status = 'completed'
--   and coalesce(g.sieg_points_to_euro_rate, 1) = 0 and coalesce(g.sieg_money, 0) > 0
-- order by g.game_date;
