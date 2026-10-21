-- Close public.user_otp_codes to the app (19.10.2026). CRITICAL.
-- The policy "select" let anon / authenticated read EVERY row (qual = true):
-- live sign-up, sign-in and password-reset codes. Anyone could request a reset
-- for any email, read the code here, confirm it via verify-otp and take the
-- account over.
-- Who still works:
--   edge functions (send-otp, verify-otp, admin-update-password, ...) use the
--   service_role key, which bypasses RLS and grants;
--   the app reads this table only in resendOtp (user_id by email) and falls back
--   to public.users when nothing is returned, so "resend code" keeps working.
-- Run the WHOLE file in the Supabase SQL editor (owner); one transaction.
--
-- What it changes:
--   policy "select" on public.user_otp_codes  dropped
--   table privileges of anon / authenticated  revoked (nothing for the app)
-- Not touched: the rows, other tables, edge functions, RLS stays enabled.
-- Undo (not recommended):
--   grant select on public.user_otp_codes to anon, authenticated;
--   create policy "select" on public.user_otp_codes for select
--     to anon, authenticated, service_role using (true);

begin;
drop policy if exists "select" on public.user_otp_codes;
revoke all on table public.user_otp_codes from anon, authenticated;
commit;

-- Check (read-only): expected anon_select = false, auth_select = false, no policy rows.
-- select has_table_privilege('anon', 'public.user_otp_codes', 'SELECT') as anon_select,
--        has_table_privilege('authenticated', 'public.user_otp_codes', 'SELECT') as auth_select;
-- select policyname, cmd, roles from pg_policies
-- where schemaname = 'public' and tablename = 'user_otp_codes';
