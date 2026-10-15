-- +100 for a registration that started as a guest (new build only).
-- Run in the Supabase SQL editor (owner), after 01_install.sql.
--
-- Rule: the app calls gg_v2_claim_signup_bonus(p_test, p_from_guest => true)
-- right after the first sign-in of a registration made from the guest dialog.
-- The server grants 100 once per account and environment, only when
--   * the caller is signed in (the account is auth.uid(), never a parameter),
--   * p_from_guest is true (old builds and the regular signup never send it),
--   * the Auth account is confirmed and was created less than 24 hours ago
--     (existing accounts cannot claim it later; no backfill).
-- The ledger is gg_v2.point_awards: one row per user/environment
-- (primary key user_id, test, reason) = who got it and when (awarded_at =
-- Auth registration time). A second call is a no-op.
--
-- public.users.guest_signup_bonus mirrors the ledger for reading/admin:
-- 100 = got the guest registration bonus, 0 = did not (everyone existing: 0).
-- Only the server writes it: app requests (anon/authenticated) cannot set or
-- change it (trigger keeps the stored value); the claim RPC sets 100.
--
-- What it changes:
--   public.users                                + column guest_signup_bonus integer not null default 0
--                                                 + trigger gg_v2_users_guest_bonus_guard (BEFORE INSERT/UPDATE)
--   gg_v2.claim_signup_bonus(boolean)           dropped, replaced by (boolean, boolean)
--   public.gg_v2_claim_signup_bonus(boolean)    dropped, replaced by (boolean, boolean)
--   grant execute on the new RPC to authenticated
--   gg_v2.rollout.signup_bonus_migrated = true  (rankings start counting the ledger;
--                                                with an empty ledger no score changes)
-- Not touched: existing users' data (the new column is 0 for all), games, invites,
-- season_results, closed seasons.

-- 0. Precheck: expected 0 rows in the ledger (no backfill was run).
select test, count(*) from gg_v2.point_awards group by test;

begin;

alter table public.users add column if not exists guest_signup_bonus integer not null default 0;

create or replace function gg_v2.users_guest_bonus_guard() returns trigger
language plpgsql set search_path='' as $$
begin
  if current_user in ('anon','authenticated') then
    if tg_op='INSERT' then new.guest_signup_bonus:=0;
    else new.guest_signup_bonus:=old.guest_signup_bonus; end if;
  end if;
  return new;
end; $$;
revoke all on function gg_v2.users_guest_bonus_guard() from public,anon,authenticated;
drop trigger if exists gg_v2_users_guest_bonus_guard on public.users;
create trigger gg_v2_users_guest_bonus_guard before insert or update on public.users
  for each row execute function gg_v2.users_guest_bonus_guard();

drop function if exists public.gg_v2_claim_signup_bonus(boolean);
drop function if exists gg_v2.claim_signup_bonus(boolean);

create or replace function gg_v2.claim_signup_bonus(
  p_test boolean default false,
  p_from_guest boolean default false
) returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare u uuid:=auth.uid(); added boolean:=false;
begin
  if u is null then raise exception 'Sign in required' using errcode='42501'; end if;
  if coalesce(p_from_guest,false) and exists(
    select 1 from auth.users a
    where a.id=u and a.created_at > now()-interval '24 hours'
  ) then
    added:=gg_v2.ensure_signup_bonus(u,p_test);
    if added then
      update public.users set guest_signup_bonus=100 where id=u;
    end if;
  end if;
  return jsonb_build_object('created',added,'test',p_test,
    'awarded',exists(select 1 from gg_v2.point_awards a where a.user_id=u and a.test=p_test));
end; $$;
revoke all on function gg_v2.claim_signup_bonus(boolean,boolean) from public,anon,authenticated;
grant execute on function gg_v2.claim_signup_bonus(boolean,boolean) to authenticated;

create or replace function public.gg_v2_claim_signup_bonus(
  p_test boolean default false,
  p_from_guest boolean default false
) returns jsonb language sql volatile security invoker set search_path='' as $$
  select gg_v2.claim_signup_bonus(p_test,p_from_guest);
$$;
revoke all on function public.gg_v2_claim_signup_bonus(boolean,boolean) from public,anon,authenticated;
grant execute on function public.gg_v2_claim_signup_bonus(boolean,boolean) to authenticated;

update gg_v2.rollout set signup_bonus_migrated=true where singleton;

commit;

-- Check: the flag and the ledger.
select signup_bonus_migrated from gg_v2.rollout;
-- Later, who got the bonus:
-- select id, display_name, guest_signup_bonus from public.users where guest_signup_bonus>0;
-- select a.user_id, u.display_name, a.test, a.awarded_at
--   from gg_v2.point_awards a join public.users u on u.id=a.user_id order by a.awarded_at desc;
