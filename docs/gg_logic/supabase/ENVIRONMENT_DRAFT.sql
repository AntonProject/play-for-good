-- Local DRAFT: only the compatible column addition, not a complete isolation rollout.
-- Do not apply to the live project without the owner's command.
-- All existing games are production according to the owner (1 October 2026).
-- New FF inserts must explicitly pass FFDevEnvironmentValues().test.
-- Old builds omit the field and continue creating production games.
begin;
alter table public.games add column if not exists test boolean not null default false;
commit;
-- This does NOT filter old clients' reads. Current SELECT policy permits all games.
-- Every new-build game query and RPC must explicitly filter the chosen environment.
-- Source rows, invitations/bonus awards and frozen season results need matching
-- environment handling before test competition data is added to the shared DB.
