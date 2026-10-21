-- Checks after 18_close_otp_codes.sql and 19_protect_users.sql (19.10.2026).

-- 1) READ-ONLY. Expected:
--    otp anon_select / auth_select = false, otp policies = 0,
--    trigger gg_v2_users_protect enabled ('O'), function security invoker.
select 'user_otp_codes anon_select' as check, has_table_privilege('anon', 'public.user_otp_codes', 'SELECT')::text as value
union all select 'user_otp_codes auth_select', has_table_privilege('authenticated', 'public.user_otp_codes', 'SELECT')::text
union all select 'user_otp_codes policies', (select count(*) from pg_policies where schemaname = 'public' and tablename = 'user_otp_codes')::text
union all select 'users trigger gg_v2_users_protect', coalesce((select tgenabled::text from pg_trigger
           where tgrelid = 'public.users'::regclass and tgname = 'gg_v2_users_protect'), 'missing')
union all select 'gg_users_protect security definer', coalesce((select prosecdef::text from pg_proc
           where proname = 'gg_users_protect' and pronamespace = 'public'::regnamespace), 'missing')
union all select 'gg_v2 schema usage for anon', has_schema_privilege('anon', 'gg_v2', 'USAGE')::text;

-- 2) OPTIONAL, run separately. A signed-in user (test user antontest22) tries
--    to make themselves admin and rich. The block ends with an error on purpose:
--    the error text is the result, and the error rolls everything back.
--    Expected: role=user, balance_money / good_power as before,
--    display_name=probe_rollback (allowed field; also rolled back).
do $$
declare
  r record;
  uid constant text := '7ace4cbb-0c8c-4308-a157-16810f2b442c'; -- antontest22
begin
  perform set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', uid, true);
  execute 'set local role authenticated';
  update public.users
     set role = 'admin', balance_money = 999999, good_power = 999999, display_name = 'probe_rollback'
   where id = uid::uuid;
  select role, balance_money, good_power, display_name into r from public.users where id = uid::uuid;
  raise exception 'PROBE (everything rolled back): role=%, balance_money=%, good_power=%, display_name=%',
    r.role, r.balance_money, r.good_power, r.display_name;
end $$;
