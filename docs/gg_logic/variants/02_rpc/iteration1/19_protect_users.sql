-- Protect server-owned columns of public.users (19.10.2026). HIGH.
-- RLS lets a signed-in user UPDATE their own row with any values
-- (with_check = true) and lets anyone INSERT a row: a user could set
-- role = 'admin', balance_money, good_power, counters or Stripe ids.
-- The app itself writes only profile fields (names, address, links, photo,
-- chosen_org, emails, payment_method, receipt, show_username, gender) and, on
-- sign-up, id / email / created_at / signup_test.
--
-- Trigger gg_v2_users_protect (BEFORE INSERT OR UPDATE on public.users):
--   applies only to a DIRECT write by anon / authenticated that is not an admin
--   (service_role, SECURITY DEFINER functions, other triggers such as
--   unified_game_processing / counters (pg_trigger_depth() > 1) and admins are
--   not limited);
--   UPDATE: protected columns silently keep their old values (other fields
--   are saved as usual, so app requests do not fail);
--   INSERT: id must be the signed-in user; protected columns get defaults.
-- Protected: role, balance_energy, balance_money, good_power, games_count,
--   gp_ring_percentage, avg_ring_percentage, followers_count, following_count,
--   invites, stripe_customer_id, stripe_customer_id_live, guest_signup_bonus,
--   id, created_at.
-- Run the WHOLE file in the Supabase SQL editor (owner); one transaction.
--
-- What it changes: one new trigger function public.gg_users_protect() and one
-- new trigger on public.users. No row is changed now. Policies and grants are
-- not changed.
-- Undo: drop trigger gg_v2_users_protect on public.users;

begin;

create or replace function public.gg_users_protect() returns trigger
language plpgsql security invoker set search_path = '' as $$
declare
  v_admin boolean;
begin
  -- Only direct app writes are limited.
  if current_user not in ('anon', 'authenticated') or pg_trigger_depth() > 1 then
    return new;
  end if;
  select exists (select 1 from public.users u
                 where u.id = auth.uid() and u.role = 'admin') into v_admin;
  if v_admin then
    return new;
  end if;

  if tg_op = 'INSERT' then
    if auth.uid() is null or new.id is distinct from auth.uid() then
      raise exception 'users: a profile can only be created for the signed-in user'
        using errcode = '42501';
    end if;
    new.role := 'user';
    new.balance_energy := 0;
    new.balance_money := 0;
    new.good_power := 0;
    new.games_count := 0;
    new.gp_ring_percentage := 0;
    new.avg_ring_percentage := 0;
    new.followers_count := 0;
    new.following_count := 0;
    new.invites := 0;
    new.stripe_customer_id := null;
    new.stripe_customer_id_live := null;
    new.guest_signup_bonus := 0;
    return new;
  end if;

  -- UPDATE: server-owned columns keep their values.
  new.id := old.id;
  new.created_at := old.created_at;
  new.role := old.role;
  new.balance_energy := old.balance_energy;
  new.balance_money := old.balance_money;
  new.good_power := old.good_power;
  new.games_count := old.games_count;
  new.gp_ring_percentage := old.gp_ring_percentage;
  new.avg_ring_percentage := old.avg_ring_percentage;
  new.followers_count := old.followers_count;
  new.following_count := old.following_count;
  new.invites := old.invites;
  new.stripe_customer_id := old.stripe_customer_id;
  new.stripe_customer_id_live := old.stripe_customer_id_live;
  new.guest_signup_bonus := old.guest_signup_bonus;
  return new;
end;
$$;
-- Runs as the caller (SECURITY INVOKER): current_user is the real role of the
-- write (anon / authenticated / service_role / a definer function owner).
-- In schema public: no new grant is needed; a trigger function cannot be called
-- through the API. (Schema gg_v2 already has USAGE for anon / authenticated from
-- 01_install.sql for the public RPCs; its tables and admin functions are revoked
-- one by one.)

drop trigger if exists gg_v2_users_protect on public.users;
create trigger gg_v2_users_protect before insert or update on public.users
  for each row execute function public.gg_users_protect();

commit;

-- Check (read-only): the trigger exists.
-- select tgname, tgenabled from pg_trigger
-- where tgrelid = 'public.users'::regclass and tgname = 'gg_v2_users_protect';
