-- Separate owner-authorized step after Supabase Cron is enabled.
-- Calendar planning works now; closing results follows gg_v2.rollout.finalization_enabled.
-- Daily at 00:05 UTC: seasons end at midnight; a no-op when nothing ended.
select cron.schedule('gg-v2-close-seasons','5 0 * * *',
  $job$select gg_v2.finalize_due_seasons();$job$);
