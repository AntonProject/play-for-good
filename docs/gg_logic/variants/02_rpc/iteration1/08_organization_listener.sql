-- Realtime event for organization changes (name, image, energy, ...), so screens
-- with cached organization lists refresh at once (GgStatsListener, table
-- 'organization'). Same function and channel as 02_listener.sql.
-- Run the WHOLE file in the Supabase SQL editor (owner).
--
-- What it changes:
--   public.organization   + trigger gg_v2_organization_changed (AFTER INSERT/UPDATE/DELETE)
-- No data is changed. The trigger only sends a broadcast; a broadcast problem
-- never fails the write (see gg_v2.notify_changed).
-- Note: unified_game_processing updates organization.energy when a game is
-- paid, so a paid game sends a 'games' and an 'organization' event.

create or replace trigger gg_v2_organization_changed after insert or update or delete on public.organization
  for each row execute function gg_v2.notify_changed();

-- Check: expected 1 row.
select tgname from pg_trigger
where tgrelid='public.organization'::regclass and tgname='gg_v2_organization_changed';
