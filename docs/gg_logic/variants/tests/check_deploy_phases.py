"""Validate phased rollout on a FRESH LOCAL fixture DB. Never use live Supabase."""
import argparse
import json
import subprocess
from pathlib import Path

p = argparse.ArgumentParser()
for name in ['psql', 'socket', 'port', 'user', 'database']:
    p.add_argument('--' + name, required=True)
a = p.parse_args()
assert a.socket.startswith('/private/tmp/')
root = Path(__file__).resolve().parents[1]
base = [a.psql, '-X', '-v', 'ON_ERROR_STOP=1', '-At', '-h', a.socket,
        '-p', a.port, '-U', a.user, '-d', a.database]


def sql(q):
    return subprocess.check_output(base + ['-c', q], text=True).strip()


def load(path, success=True):
    result = subprocess.run(base + ['-f', str(path)], text=True, capture_output=True)
    assert (result.returncode == 0) == success, result.stdout + result.stderr


def data(q):
    return json.loads(sql(q))


load(root.parent / 'tests/fixture_schema.sql')
sql('''create table auth.users(id uuid primary key,email text,created_at timestamptz,email_confirmed_at timestamptz);
insert into auth.users select id,email,case
 when display_name='Player 1' then '2025-11-19T12:00:00Z'::timestamptz
 when display_name='Player 6' then '2026-09-01T00:00:00Z'::timestamptz
 else '2025-12-01T12:00:00Z'::timestamptz end,'2026-09-30'::timestamptz from public.users;''')
raw_before = sql('select sum(lichtwatt) from public.games;')
deploy = root / '02_rpc/deploy'
load(deploy / '01_passive.sql')
assert sql("select count(*) from pg_trigger where not tgisinternal and tgname like 'gg_v2_%';") == '0'
assert sql("select has_function_privilege('authenticated','public.gg_v2_claim_signup_bonus(boolean)','EXECUTE');") == 'f'
assert sql('select count(*) from gg_v2.point_awards;') == '0'
assert sql('select count(*) from public.games where test;') == '0'
assert sql("select column_default from information_schema.columns where table_schema='public' and table_name='games' and column_name='test';") == 'false'
load(deploy / '01_passive.sql')  # Retry before activation remains passive.
ranking = data("set role anon; select public.gg_v2_rankings('all_time','valuable',1,10,null,false);")
assert ranking['total_good_power_all_time'] == 414
assert all(row['awards'] == [] for row in ranking['players'])
assert sql('select count(*) from realtime.test_events;') == '0'
print('PASS passive: prod defaults, public read RPC, no automatic bonus, no write RPC grants/triggers')

load(deploy / '02_backfill.sql')
load(deploy / '02_backfill.sql')
assert sql('select count(*) from gg_v2.point_awards;') == '6'
ranking = data("set role anon; select public.gg_v2_rankings('all_time','valuable',1,10,null,false);")
assert ranking['total_good_power_all_time'] == 1014
assert sql('select sum(lichtwatt) from public.games;') == raw_before
assert sql('select count(*) from realtime.test_events;') == '0'
print('PASS backfill: bonus exactly once; original games unchanged')

load(deploy / '03_finalize_2025_26.sql')
load(deploy / '03_finalize_2025_26.sql')
assert sql("select count(*) from gg_v2.season_closures where season_key='season_2025_26' and not test and finalized_at is not null;") == '1'
assert sql("select count(*) from gg_v2.season_closures where season_key='season_2026_27' and finalized_at is not null;") == '0'
profile = data("set role anon; select public.gg_v2_profile_stats('00000000-0000-0000-0000-000000000004','all_time',false);")
assert [award['category'] for award in profile['awards']] == ['valuable', 'active']
print('PASS finalization: past season medals only; ongoing season remains open')

load(deploy / '04_activate.sql')
assert sql("select has_function_privilege('authenticated','public.gg_v2_claim_signup_bonus(boolean)','EXECUTE');") == 't'
assert int(sql("select count(*) from pg_trigger where not tgisinternal and tgname like 'gg_v2_%';")) >= 6
load(deploy / '01_passive.sql', success=False)
assert sql("select has_function_privilege('authenticated','public.gg_v2_claim_signup_bonus(boolean)','EXECUTE');") == 't'
print('PASS activation: triggers/write grant opt in; passive reinstall refuses active state')
