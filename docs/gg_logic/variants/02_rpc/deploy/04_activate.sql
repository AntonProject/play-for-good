-- PHASE 4: after signup/RLS/environment checks and frontend preparation.
-- Existing game/profile writes will now invoke the additional triggers.
begin;
grant execute on function gg_v2.claim_signup_bonus(boolean) to authenticated;
grant execute on function public.gg_v2_claim_signup_bonus(boolean) to authenticated;
create or replace trigger gg_v2_profile_signup_bonus after insert
  on public.users for each row execute function gg_v2.bonus_on_profile();
commit;

-- Optional realtime updates for the RPC variant, transactional with the write.
begin;
create or replace function gg_v2.notify_changed() returns trigger
language plpgsql volatile security definer set search_path='' as $$
begin
  if tg_op='UPDATE' and to_jsonb(new)=to_jsonb(old) then return new; end if;
  perform realtime.send(jsonb_build_object('changed_at',clock_timestamp()),'changed','gg:v2:stats',false);
  if tg_op='DELETE' then return old; end if;
  return new;
end; $$;
revoke all on function gg_v2.notify_changed() from public,anon,authenticated;
create or replace trigger gg_v2_games_changed after insert or update or delete on public.games
  for each row execute function gg_v2.notify_changed();
create or replace trigger gg_v2_invites_changed after insert or update or delete on public.invites
  for each row execute function gg_v2.notify_changed();
create or replace trigger gg_v2_bonus_changed after insert or update or delete on gg_v2.point_awards
  for each row execute function gg_v2.notify_changed();
create or replace trigger gg_v2_users_changed after insert or update or delete on public.users
  for each row execute function gg_v2.notify_changed();
create or replace trigger gg_v2_seasons_changed after insert or update on gg_v2.seasons
  for each row execute function gg_v2.notify_changed();
commit;

notify pgrst, 'reload schema';
