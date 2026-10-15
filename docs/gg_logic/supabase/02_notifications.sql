-- Optional live updates. LOCAL ONLY until the owner requests applying it.
begin;
create or replace function gg_internal.notify_stats_changed() returns trigger
language plpgsql security definer set search_path='' as $$
begin
  if tg_table_name='games' then
    if tg_op='INSERT' then
      if new.status is distinct from 'completed' then return new; end if;
    elsif tg_op='DELETE' then
      if old.status is distinct from 'completed' then return old; end if;
    else
      if new.status is distinct from 'completed' and old.status is distinct from 'completed'
        then return new; end if;
      -- Refresh both statistics and the visible game history on a real update.
      if to_jsonb(new) is not distinct from to_jsonb(old) then return new; end if;
    end if;
  elsif tg_table_name='invites' then
    if tg_op='INSERT' then
      if new.was_used is distinct from true then return new; end if;
    elsif tg_op='DELETE' then
      if old.was_used is distinct from true then return old; end if;
    else
      if new.was_used is distinct from true and old.was_used is distinct from true
        then return new; end if;
      if row(new.was_used,new.inviter_user_id,new.used_at,new.lichtwatt)
        is not distinct from row(old.was_used,old.inviter_user_id,old.used_at,old.lichtwatt)
        then return new; end if;
    end if;
  elsif tg_table_name='users' and tg_op='UPDATE' then
    if row(new.id,new.display_name,new.first_name,new.surname,new.photo_url)
      is not distinct from row(old.id,old.display_name,old.first_name,old.surname,old.photo_url)
      then return new; end if;
  end if;
  perform realtime.send(jsonb_build_object('changed_at',clock_timestamp()),
    'changed','gg:stats',false);
  if tg_op='DELETE' then return old; end if;
  return new;
end;
$$;
revoke all on function gg_internal.notify_stats_changed() from public,anon,authenticated;
create or replace trigger gg_stats_games_changed after insert or update or delete
  on public.games for each row execute function gg_internal.notify_stats_changed();
create or replace trigger gg_stats_invites_changed after insert or update or delete
  on public.invites for each row execute function gg_internal.notify_stats_changed();
create or replace trigger gg_stats_users_changed after insert or update or delete
  on public.users for each row execute function gg_internal.notify_stats_changed();
commit;
