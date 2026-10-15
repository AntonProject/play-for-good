-- LOCAL PACKAGE. Apply only on owner's command, after 00_seasons.sql.
begin;
alter table public.games add column if not exists test boolean not null default false;
alter table public.invites add column if not exists test boolean not null default false;
alter table public.users add column if not exists signup_test boolean not null default false;

create table if not exists gg_v2.point_awards (
  user_id uuid not null references public.users(id) on delete cascade,
  test boolean not null default false,
  reason text not null check(reason='signup_bonus'),
  amount numeric not null check(amount=100),
  awarded_at timestamp not null,
  primary key(user_id,test,reason)
);
alter table gg_v2.point_awards enable row level security;
revoke all on gg_v2.point_awards from public,anon,authenticated;

-- Uses the authenticated account, never a client-provided user/amount/date.
-- Registration date: Auth.created_at in UTC, not the deployment/backfill date.
create or replace function gg_v2.ensure_signup_bonus(p_user uuid,p_test boolean)
returns boolean language plpgsql volatile security definer set search_path='' as $$
declare d timestamp; n integer;
begin
  select a.created_at at time zone 'UTC' into d from auth.users a
  join public.users u on u.id=a.id
  where a.id=p_user and nullif(a.email,'') is not null
    and a.email_confirmed_at is not null;
  if d is null then return false; end if;
  insert into gg_v2.point_awards(user_id,test,reason,amount,awarded_at)
    values(p_user,p_test,'signup_bonus',100,d) on conflict do nothing;
  get diagnostics n=row_count;
  return n>0;
end; $$;
revoke all on function gg_v2.ensure_signup_bonus(uuid,boolean) from public,anon,authenticated;

create or replace function gg_v2.claim_signup_bonus(p_test boolean default false)
returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare u uuid:=auth.uid(); added boolean;
begin
  if u is null then raise exception 'Sign in required' using errcode='42501'; end if;
  added:=gg_v2.ensure_signup_bonus(u,p_test);
  return jsonb_build_object('created',added,'test',p_test,
    'awarded',exists(select 1 from gg_v2.point_awards a where a.user_id=u and a.test=p_test));
end; $$;
revoke all on function gg_v2.claim_signup_bonus(boolean) from public,anon,authenticated;
grant execute on function gg_v2.claim_signup_bonus(boolean) to authenticated;
create or replace function public.gg_v2_claim_signup_bonus(p_test boolean default false)
returns jsonb language sql volatile security invoker set search_path='' as $$
  select gg_v2.claim_signup_bonus(p_test);
$$;
revoke all on function public.gg_v2_claim_signup_bonus(boolean) from public,anon,authenticated;
grant execute on function public.gg_v2_claim_signup_bonus(boolean) to authenticated;

-- Old clients do not send signup_test => false => production bonus.
-- New test signup must put signup_test=true into the profile INSERT.
create or replace function gg_v2.bonus_on_profile() returns trigger
language plpgsql volatile security definer set search_path='' as $$
begin
  perform gg_v2.ensure_signup_bonus(new.id,new.signup_test);
  return new;
end; $$;
revoke all on function gg_v2.bonus_on_profile() from public,anon,authenticated;
create or replace trigger gg_v2_profile_signup_bonus after insert
  on public.users for each row execute function gg_v2.bonus_on_profile();
commit;

-- Historical backfill is EXPLICIT, before the first season finalization:
-- select gg_v2.ensure_signup_bonus(u.id,u.signup_test) from public.users u;
-- Rehearse this against the project schema; unconfirmed Auth accounts get no bonus.
-- This changes no games/invites and does not double-count in old app versions.
