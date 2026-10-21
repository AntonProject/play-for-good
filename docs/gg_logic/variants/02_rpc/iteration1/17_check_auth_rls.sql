-- READ-ONLY: who may read / write the auth-related tables. Nothing is changed.
-- Shows RLS, grants and policies of user_otp_codes and users
-- (closed by 18_close_otp_codes.sql; check with 20_check_security.sql).

-- 1) RLS on/off and table grants for anon / authenticated.
select c.relname as table_name,
       c.relrowsecurity as rls_enabled,
       c.relforcerowsecurity as rls_forced,
       has_table_privilege('anon', c.oid, 'SELECT') as anon_select,
       has_table_privilege('anon', c.oid, 'UPDATE') as anon_update,
       has_table_privilege('authenticated', c.oid, 'SELECT') as auth_select,
       has_table_privilege('authenticated', c.oid, 'UPDATE') as auth_update
from pg_class c join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relname in ('user_otp_codes', 'users')
order by 1;

-- 2) The policies themselves.
-- select tablename, policyname, cmd, roles, qual, with_check
-- from pg_policies
-- where schemaname = 'public' and tablename in ('user_otp_codes', 'users')
-- order by tablename, cmd, policyname;
