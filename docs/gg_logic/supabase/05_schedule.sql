-- Local preparation only. Owner must enable Supabase Cron (pg_cron) first.
-- Run after 00..04. Named schedule is updated on repeat, no duplicate jobs.
-- pg_cron runs in UTC. :00 every hour catches the season-end boundary and
-- retries an unsuccessful closure; row lock + finalized_at makes this idempotent.
select cron.schedule(
  'gg-finalize-seasons',
  '0 * * * *',
  $job$select gg_internal.finalize_due_seasons();$job$
);
-- For inspection: select * from cron.job where jobname='gg-finalize-seasons';
-- For job history: select * from cron.job_run_details order by start_time desc limit 20;
