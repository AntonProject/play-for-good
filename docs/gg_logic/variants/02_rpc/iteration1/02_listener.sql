-- Optional realtime updates for the RPC variant, transactional with the write.
begin;
create or replace function gg_v2.notify_changed() returns trigger
language plpgsql volatile security definer set search_path='' as $$
begin
  if tg_op='UPDATE' and to_jsonb(new)=to_jsonb(old) then return new; end if;
  -- The table lets each screen listen only to what it shows (posts vs stats).
  -- A broadcast problem must never fail the user's write.
  begin
    perform realtime.send(jsonb_build_object('changed_at',clock_timestamp(),'table',tg_table_name),'changed','gg:v2:stats',false);
  exception when others then
    raise warning 'gg_v2 broadcast skipped: %', sqlerrm;
  end;
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
create or replace trigger gg_v2_posts_changed after insert or update or delete on public.posts
  for each row execute function gg_v2.notify_changed();
commit;
