"""Build local SQL phases; never connects to a database or FlutterFlow."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
out = root / '02_rpc' / 'deploy'
out.mkdir(exist_ok=True)
bonus = (root / 'shared/01_environment_bonus.sql').read_text()
trigger = '''create or replace trigger gg_v2_profile_signup_bonus after insert
  on public.users for each row execute function gg_v2.bonus_on_profile();'''
assert bonus.count(trigger) == 1
passive_bonus = bonus.replace(trigger, '-- Activation is a separate explicit phase.')
sources = [
    ('shared/00_seasons.sql', None),
    ('shared/01_environment_bonus.sql', passive_bonus),
    ('shared/02_scoring.sql', None),
    ('shared/03_finalize.sql', None),
    ('shared/04_context.sql', None),
    ('02_rpc/10_rpc.sql', None),
]
passive = '''-- PHASE 1: additional schema/functions only. No business triggers or Cron.
-- Owner authorization required. Does not backfill bonuses or finalize seasons.
-- Existing gg_v2 activation must be inspected instead of silently disabled.
do $$ begin
  if exists(select 1 from pg_trigger where not tgisinternal and tgname like 'gg_v2_%') then
    raise exception 'gg_v2 triggers already active: inspect the deployed state before passive installation';
  end if;
end $$;
'''
for name, replacement in sources:
    passive += '\n-- SOURCE: ' + name + '\n' + (replacement if replacement is not None else (root / name).read_text())
passive += '''
-- Keep write RPC unavailable to application clients during read-only comparison.
revoke all on function gg_v2.claim_signup_bonus(boolean) from authenticated;
revoke all on function public.gg_v2_claim_signup_bonus(boolean) from authenticated;
notify pgrst, 'reload schema';
'''
(out / '01_passive.sql').write_text(passive)
(out / '02_backfill.sql').write_text('''-- PHASE 2: owner-authorized writes to the NEW bonus table only.
-- Must precede final ranking verification and season finalization.
-- Existing accounts are prod by default; confirmed email required.
begin;
select gg_v2.ensure_signup_bonus(u.id,u.signup_test) from public.users u;
commit;
''')
(out / '03_finalize_2025_26.sql').write_text('''-- PHASE 3: only after checking the MVP/MAP totals, dates and timezone.
-- Freeze completed 2025/26. Never finalize the ongoing 2026/27 here.
begin;
select gg_v2.finalize_season('season_2025_26',false);
commit;
''')
(out / '04_activate.sql').write_text('''-- PHASE 4: after signup/RLS/environment checks and frontend preparation.
-- Existing game/profile writes will now invoke the additional triggers.
begin;
grant execute on function gg_v2.claim_signup_bonus(boolean) to authenticated;
grant execute on function public.gg_v2_claim_signup_bonus(boolean) to authenticated;
''' + trigger + '\ncommit;\n\n' + (root / '02_rpc/11_notifications.sql').read_text()
    + "\nnotify pgrst, 'reload schema';\n")
(out / '05_schedule.sql').write_text((root / 'shared/06_schedule.sql').read_text())
print('Prepared 5 SQL phases locally. No database operations performed.')
