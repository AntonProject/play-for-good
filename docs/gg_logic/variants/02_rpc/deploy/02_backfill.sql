-- PHASE 2: owner-authorized writes to the NEW bonus table only.
-- Must precede final ranking verification and season finalization.
-- Existing accounts are prod by default; confirmed email required.
begin;
select gg_v2.ensure_signup_bonus(u.id,u.signup_test) from public.users u;
commit;
