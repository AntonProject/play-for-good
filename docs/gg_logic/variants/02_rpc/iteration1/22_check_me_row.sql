-- READ-ONLY (21.10.2026). Good Games: a user ranked 8 sees the list 1-10 and
-- then their own row "8" again under it. The own row is shown only when the
-- loaded page (players) has no row with current_user.user_id.
-- Put the user's display name (nick) and run; one row per period / category
-- of the Good Games filter, test and prod.

with u as (
  select id, display_name from public.users where display_name = 'NICK_HERE'
), q as (
  select u.display_name, e.test, per.p, cat.c,
         public.gg_v2_rankings(per.p, cat.c, 1, 10, u.id, e.test) as r
  from u
  cross join (values (false), (true)) e(test)
  cross join (values ('auto'), ('season_2025_26'), ('season_2026_27'), ('all_time')) per(p)
  cross join (values ('valuable'), ('active'), ('generous'), ('social')) cat(c)
)
select display_name, test, p as period, c as category,
       r->'current_user'->>'rank' as my_rank,
       (r->'current_user'->>'user_id') is not null as has_current_user,
       exists (select 1 from jsonb_array_elements(r->'players') x
               where x->>'user_id' = r->'current_user'->>'user_id') as in_page,
       (select string_agg(x->>'rank', ',') from jsonb_array_elements(r->'players') x) as page_ranks,
       r->'pagination'->>'total_count' as total_count
from q
order by test, period, category;
