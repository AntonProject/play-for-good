-- Separate opt-in step after Supabase Cron is enabled. Database owner only.
-- Basic/RPC closes only configured seasons; admin variant extends this function.
select cron.schedule('gg-v2-close-seasons','0 * * * *',
  $job$select gg_v2.finalize_due_seasons();$job$);
