-- PHASE 3: only after checking the MVP/MAP totals, dates and timezone.
-- Freeze completed 2025/26. Never finalize the ongoing 2026/27 here.
begin;
select gg_v2.finalize_season('season_2025_26',false);
commit;
