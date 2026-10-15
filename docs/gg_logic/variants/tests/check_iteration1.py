"""Current iteration checks on a FRESH local fixture; never live Supabase."""
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
def load(path):
    subprocess.run(base + ['-f', str(path)], check=True, capture_output=True, text=True)
def data(q):
    return json.loads(sql(q))

load(root.parent / 'tests/fixture_schema.sql')
sql('create table auth.users(id uuid primary key,email text,created_at timestamptz,email_confirmed_at timestamptz);')
# Shared fixture keeps the old 20.11 boundary game; TZ start is now 01.11.2025.
sql("update public.games set game_date='2025-10-31 23:59:59.999999' where id='10000000-0000-0000-0000-000000000021';")
deploy = root / '02_rpc/iteration1'
load(deploy / '01_install.sql')
load(deploy / '01_install.sql')
assert sql("select count(*) from pg_trigger where not tgisinternal and tgname like 'gg_v2_%';") == '0'
assert sql("select has_function_privilege('authenticated','public.gg_v2_claim_signup_bonus(boolean)','EXECUTE');") == 'f'
assert sql("select has_table_privilege('authenticated','gg_v2.rollout','UPDATE');") == 'f'
assert sql('select count(*) from gg_v2.point_awards;') == '0'
assert sql('select count(*) from public.games where test;') == '0'
print('PASS install: repeatable, no bonus grants/triggers/backfill; old games prod')

expected = {'valuable': (2,110), 'active': (4,5), 'generous': (2,30), 'social': (2,1)}
for category, (user, score) in expected.items():
    result = data(f"set role anon; select public.gg_v2_rankings('season_2025_26','{category}',1,10,null,false);")
    assert result['top_players'][0]['user_id'].endswith(str(user).zfill(12)), result
    assert result['top_players'][0]['score'] == score
    assert result['total_good_power'] == 257
    assert result['total_good_power_all_time'] == 414
    assert result['signup_bonus_migrated'] is False
    assert result['legacy_bonus_users_count'] == 6
    assert result['layout_mode'] == 'final' and not result['results_finalized']
    assert all(row['awards'] == [] for row in result['players'])
for period in ['all_time','this_month','last_month','season_2026_27']:
    result = data(f"set role anon; select public.gg_v2_rankings('{period}','valuable',1,10,null,false);")
    assert result['layout_mode'] == 'current'
assert data("set role anon; select public.gg_v2_rankings('season_26_27','valuable',1,10,null,false);")['period']['key'] == 'season_2026_27'
assert data("set role anon; select public.gg_v2_profile_stats('00000000-0000-0000-0000-000000000001','season_25_26',false);")['period']['key'] == 'season_2025_26'
print('PASS categories: all four formulas/ranks, layout current/final independent of category')

# Test games cannot affect prod and all old invites stay prod by default.
sql("insert into public.games(id,creator_user_id,game_date,lichtwatt,status,test) values('50000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000006','2026-10-01',17,'completed',true);")
assert data("set role anon; select public.gg_v2_rankings('all_time','valuable',1,10,null,false);")['total_good_power_all_time'] == 414
assert data("set role anon; select public.gg_v2_rankings('all_time','valuable',1,10,null,true);")['total_good_power_all_time'] == 17
sql("insert into gg_v2.point_awards(user_id,test,reason,amount,awarded_at) values('00000000-0000-0000-0000-000000000001',false,'signup_bonus',100,'2025-12-01');")
assert data("set role anon; select public.gg_v2_rankings('all_time','valuable',1,10,null,false);")['total_good_power_all_time'] == 414
guard = subprocess.run(base + ['-c', "select gg_v2.finalize_season('season_2025_26',false);"],capture_output=True,text=True)
assert guard.returncode != 0 and 'paused' in guard.stderr, guard.stderr
assert sql('select count(*) from gg_v2.season_closures;') == '0'
print('PASS environment and rollout guard: test isolated, stored bonus ignored, finalization paused')

assert data("select gg_v2.finalize_due_seasons('2027-06-30T23:59:59Z');")['planned'] == []
run = data("select gg_v2.finalize_due_seasons('2027-07-01T00:00:00Z');")
assert run['planned'] == ['season_2027_07_01'] and run['finalized'] == []
next_season = data("select gg_v2.period_info('season_2027_07_01','2027-07-01T00:00:00Z');")
assert next_season['period_start'] == '2027-07-01T00:00:00'
assert next_season['period_end_exclusive'] == '2028-05-01T00:00:00'
assert data("select gg_v2.finalize_due_seasons('2027-07-01T00:00:00Z');")['planned'] == []
assert data("select gg_v2.period_info('auto','2027-07-01T00:00:00Z');")['key'] == 'season_2027_07_01'
catchup = data("select gg_v2.finalize_due_seasons('2029-07-01T00:00:00Z');")
assert len(catchup['planned']) == 2 and catchup['finalized'] == []
assert sql("select count(*) from gg_v2.seasons a join gg_v2.seasons b on a.starts_at<b.starts_at and a.ends_at>b.starts_at;") == '0'
print('PASS calendar: next day, ten months, inclusive last day, repeat/catch-up, no overlap')

sql('create table if not exists public.posts(id uuid primary key, created_at timestamptz default now());')
load(deploy / '02_listener.sql')
sql("update public.games set lichtwatt=18 where id='50000000-0000-0000-0000-000000000001';")
assert sql("select count(*) from realtime.test_events where topic='gg:v2:stats';") == '1'
assert '"table": "games"' in sql("select payload::text from realtime.test_events where topic='gg:v2:stats';")
print('PASS listener: isolated local write sends refresh event without bonus posting')

# Ties: equal score -> more recent activity ranks higher. Guest = 100, newest.
sql("insert into public.games(id,creator_user_id,game_date,lichtwatt,status,test) values"
    "('50000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000001','2026-10-03',18,'completed',true),"
    "('50000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000002','2026-09-20',18,'completed',true);")
tied = data("set role anon; select public.gg_v2_rankings('all_time','valuable',1,10,null,true);")
order = [row['user_id'][-1] for row in tied['players']]
assert order == ['1','6','2'], order
assert [row['rank'] for row in tied['players']] == [1,2,3]
assert tied['guest_rank'] == 1  # nobody has more than the guest's demo 100 here
week = data("select gg_v2.period_info('woche','2026-10-14T10:00:00Z');")
assert week['key'] == 'this_week' and week['period_start'] == '2026-10-12T00:00:00'
assert week['period_end_exclusive'] == '2026-10-19T00:00:00'
print('PASS ties/guest/week: recent activity wins ties, guest vs server score, Home week period')

# Season template: first/last day inclusive, overlaps rejected.
added = data("select gg_v2.add_season('2030-01-01','2030-10-31');")
assert added['season_key'] == 'season_2030_01_01' and added['label'] == 'Saison 2030'
assert data("select gg_v2.period_info('season_2030_01_01','2031-01-01T00:00:00Z');")['period_end_exclusive'] == '2030-11-01T00:00:00'
clash = subprocess.run(base + ['-c', "select gg_v2.add_season('2030-10-01','2031-06-30');"],capture_output=True,text=True)
assert clash.returncode != 0 and 'overlaps' in clash.stderr
moved = subprocess.run(base + ['-c', "update gg_v2.seasons set ends_at='2026-10-01' where season_key='season_2025_26';"],capture_output=True,text=True)
assert moved.returncode != 0 and 'overlaps' in moved.stderr
print('PASS season template: TZ seed 01.11.2025, inclusive last day, overlap guard')

# Close now on raw scores (bonus not migrated), recompute after the +100 ledger.
sql('update gg_v2.rollout set finalization_enabled=true;')
assert sql("select gg_v2.finalize_season('season_2025_26',false);") == 't'
assert sql("select gg_v2.finalize_season('season_2025_26',false);") == 'f'
power = "select good_power from gg_v2.season_results where season_key='season_2025_26' and not test and user_id='00000000-0000-0000-0000-000000000001';"
early = float(sql(power))
ranking = data("set role anon; select public.gg_v2_rankings('season_2025_26','valuable',1,10,null,false);")
assert ranking['results_finalized'] and ranking['layout_mode'] == 'final'
assert any(row['awards'] for row in ranking['top_players'])
assert ranking['awards_season'] == 'season_2025_26'
# Row medals come from the last closed season whatever the period filter.
for period in ['this_month','all_time','season_2026_27']:
    other = data(f"set role anon; select public.gg_v2_rankings('{period}','valuable',1,10,null,false);")
    medals = [a for row in other['players'] for a in row['awards']]
    assert other['awards_season'] == 'season_2025_26'
    assert all(a['season'] == 'season_2025_26' for a in medals)
assert sql("select count(*) from gg_v2.season_results where test;") == '0'
sql('update gg_v2.rollout set signup_bonus_migrated=true;')
assert sql("select gg_v2.refinalize_season('season_2025_26',false);") == 't'
assert float(sql(power)) == early + 100
early_fail = subprocess.run(base + ['-c', "select gg_v2.refinalize_season('season_2026_27',false,'2026-10-14T00:00:00Z');"],capture_output=True,text=True)
assert early_fail.returncode != 0
assert sql("select gg_v2.is_finalized('season_2025_26',false);") == 't'
profile = data("set role anon; select public.gg_v2_profile_stats('00000000-0000-0000-0000-000000000001','all_time',false);")
assert profile['signup_bonus_migrated'] is True
assert profile['all_time']['good_power'] == 240
assert profile['awards'][0]['category'] == 'valuable' and profile['awards'][0]['place'] == 1
assert profile['awards'][0]['season_label'] == 'Saison 2025/26'
assert profile['awards'][0]['period_start'] == '2025-11-01T00:00:00'
print('PASS closure: closed before bonus migration, recomputed with database bonus once')
