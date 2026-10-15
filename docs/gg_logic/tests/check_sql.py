"""Run only on the disposable fixture DB; requires local psql and no cloud keys.

Usage: python3 check_sql.py --psql PATH --socket PATH --port N --user NAME
Creates only the fixture database objects, never connects to Supabase.
"""
import argparse
import json
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--psql', required=True)
parser.add_argument('--socket', required=True)
parser.add_argument('--port', required=True)
parser.add_argument('--user', required=True)
parser.add_argument('--database', default='postgres')
parser.add_argument('--bulk-count',type=int,default=100005)
args = parser.parse_args()
assert args.socket.startswith('/private/tmp/'), 'Disposable local socket required'
assert 100 <= args.bulk_count <= 100005
root = Path(__file__).resolve().parents[1]
base = [args.psql, '-X', '-v', 'ON_ERROR_STOP=1', '-At', '-h', args.socket,
        '-p', args.port, '-U', args.user, '-d', args.database]

def sql(query):
    return subprocess.check_output(base + ['-c', query], text=True).strip()

def load(path):
    result=subprocess.run(base + ['-f', str(path)], capture_output=True, text=True)
    if result.returncode:
        print(result.stdout,result.stderr)
        result.check_returncode()

def read(query):
    lines = sql(query).splitlines()
    start = next(i for i,line in enumerate(lines) if line.lstrip().startswith(('{','[')))
    end = len(lines)
    while end > start and lines[end-1] in ('ROLLBACK','COMMIT'):
        end -= 1
    return json.loads('\n'.join(lines[start:end]))

def uid(n):
    return f'00000000-0000-0000-0000-{n:012d}'

def rankings(period='season_2025_26', category='valuable', page=1, size=2, user=3, role='anon'):
    return read(f"set role {role}; select public.gg_rankings('{period}','{category}',{page},{size},'{uid(user)}');")

def profile(n, period='season_2025_26'):
    return read(f"set role anon; select public.gg_profile_stats('{uid(n)}','{period}');")

load(root/'tests/fixture_schema.sql')
load(root/'supabase/00_season_tables.sql')
load(root/'supabase/01_functions.sql')
load(root/'supabase/02_notifications.sql')
load(root/'supabase/03_indexes.sql')
load(root/'supabase/04_finalize_seasons.sql')
# Check that preparing/applying an updated function set is idempotent.
load(root/'supabase/01_functions.sql')
load(root/'supabase/02_notifications.sql')

assert profile(2)['awards'] == []
assert read("select gg_internal.finalize_due_seasons('2026-08-31T23:59:59.999999Z');")['finalized_seasons']==[]
assert read("select gg_internal.finalize_due_seasons('2026-09-01T00:00:00Z');")['finalized_seasons']==['season_2025_26']
assert read("select gg_internal.finalize_due_seasons('2026-09-01T00:00:00Z');")['finalized_seasons']==[]
assert sql("select count(*) from gg_internal.season_results;")=='6'
assert sql("select has_function_privilege('anon','gg_internal.finalize_due_seasons(timestamptz)','EXECUTE');")=='f'
assert sql("select has_table_privilege('anon','gg_internal.season_results','SELECT');")=='f'
# Failure before the last day must not publish either results or awards.
result=subprocess.run(base+['-c',"select gg_internal.finalize_season('season_2026_27','2027-06-30T23:59:59.999999Z');"],capture_output=True,text=True)
assert result.returncode != 0
assert sql("select count(*) from gg_internal.season_results where season_key='season_2026_27';")=='0'
print('PASS: exact season closure boundary, initial backfill, idempotency, owner-only writes')

r = rankings()
assert r['requested_period'] == 'season_2025_26'
assert r['requested_category'] == 'valuable'
assert r['requested_user_id'] == uid(3)
assert r['total_good_power'] == 257
assert r['total_good_power_all_time'] == 414
assert [p['user_id'] for p in r['players']] == [uid(2),uid(1)]
assert r['current_user']['rank'] == 3
assert r['current_user']['good_power'] == 40
assert r['pagination'] == {'page':1,'page_size':2,'total_count':5,'has_more':True}
assert [p['user_id'] for p in rankings(page=2)['top_players']] == [uid(2),uid(1),uid(3)]
assert [p['user_id'] for p in rankings(page=2)['players']] == [uid(3),uid(4)]
assert len(rankings(page=3)['players']) == 1
assert rankings(page=4)['players'] == []
assert rankings(page=4)['pagination']['has_more'] is False
assert profile(6)['stats']['good_power'] == {'value':0,'rank':None}
assert profile(6)['awards'] == []
print('PASS: global totals, invite-only users, pagination, independent podium/current user, zero ranks')

active = rankings(category='active',size=100)
assert active['players'][0]['user_id'] == uid(4)
assert active['players'][0]['score'] == 5
assert uid(5) not in [p['user_id'] for p in active['players']]
p4 = profile(4)
assert p4['stats']['good_power']['rank'] == 4
assert p4['award_flags']['active_fire'] is True
assert p4['award_flags']['mvp_gold'] is False
assert profile(2)['award_flags']['mvp_gold'] is True
assert profile(1)['award_flags']['mvp_silver'] is True
assert profile(3)['award_flags']['mvp_bronze'] is True
assert profile(2,'season_2026_27')['award_flags']['mvp_gold'] is True
assert profile(2)['stats']['good_power_per_game']['value'] == 80
assert profile(2)['stats']['good_energy_per_game']['value'] == 30
assert profile(2)['stats']['sponsored_games']['value'] == 1
print('PASS: Most Active counts games only; GG2026 medals/fire persist across selected filters')

assert rankings('season_2026_27')['total_good_power'] == 105
assert profile(1,'season_2026_27')['stats']['good_power']['value'] == 20
assert profile(1,'season_2025_26')['stats']['good_power']['value'] == 100
assert profile(1,'all_time')['stats']['good_power']['value'] == 140
assert read("select gg_internal.period_info('auto','2026-07-01T00:00:00Z');")['key']=='season_2025_26'
assert read("select gg_internal.period_info('auto','2026-09-01T00:00:00Z');")['key']=='season_2026_27'
assert read("select gg_internal.period_info('auto','2027-08-31T00:00:00Z');")['key']=='season_2026_27'
assert read("select gg_internal.period_info('last_month','2026-09-30T10:00:00Z');")['period_end_exclusive']=='2026-09-01T00:00:00'
assert rankings('gesamt')['total_good_power'] == 414
assert rankings('saison')['period']['key'] == 'season_2026_27'
print('PASS: exact inclusive final days, exclusive season starts, undated All-Time, defaults during gap')

assert sql('set role anon; select count(*) from public.invites;').splitlines()[-1]=='0'
private_json = json.dumps(r)
assert 'hidden@example.invalid' not in private_json and 'private-' not in private_json
assert sql("select has_function_privilege('anon','gg_internal.notify_stats_changed()','EXECUTE');")=='f'
assert sql("select count(*) from pg_proc p cross join lateral aclexplode(p.proacl) a where p.proname in ('gg_rankings','gg_profile_stats','gg_games','score_sets') and a.grantee=0;")=='0'
auth = read(f"set role authenticated; set request.jwt.claim.sub='{uid(1)}'; select public.gg_rankings('season_2025_26','valuable',1,2,'{uid(1)}');")
assert auth['players'][0]['good_power']==110
print('PASS: anon/auth aggregates include others\' invites; raw invitation RLS intact; no email leaks')

games = read(f"set role anon; select public.gg_games('{uid(4)}','season_2025_26','active',1,2);")
assert games['requested_category'] == 'active'
assert len(games['games'])==2 and games['pagination']['has_more']
assert all(g['creator_user_id']==uid(4) for g in games['games'])
empty = read(f"set role anon; select public.gg_games('{uid(6)}','all_time','valuable',1,10);")
assert empty['games']==[] and not empty['pagination']['has_more']
print('PASS: filtered and bounded Meine Games history')

before = int(sql('select count(*) from realtime.test_events;'))
sql("update public.games set status='completed' where id='10000000-0000-0000-0000-000000000024';")
assert profile(2)['stats']['good_power']['value']==110
assert profile(2,'all_time')['stats']['good_power']['value']==1129
assert int(sql('select count(*) from realtime.test_events;'))==before+1
sql("update public.games set status='pending' where id='10000000-0000-0000-0000-000000000024';")
sql("delete from public.games where id='10000000-0000-0000-0000-000000000002';")
assert profile(1)['award_flags']['mvp_silver']
assert profile(2)['award_flags']['mvp_gold']
assert profile(2)['stats']['good_power']['value']==110
assert profile(2,'all_time')['stats']['good_power']['value']==50
sql("update public.invites set lichtwatt=200 where id='30000000-0000-0000-0000-000000000001';")
assert profile(2)['award_flags']['mvp_gold']
before = int(sql('select count(*) from realtime.test_events;'))
sql("begin; update public.invites set lichtwatt=300 where id='30000000-0000-0000-0000-000000000001'; rollback;")
assert profile(2)['stats']['good_power']['value']==110
assert profile(2,'all_time')['stats']['good_power']['value']==220
assert int(sql('select count(*) from realtime.test_events;'))==before
event = read('select to_jsonb(e) from realtime.test_events e limit 1;')
assert event['event']=='changed' and event['topic']=='gg:stats' and not event['is_private']
assert list(event['payload'])==['changed_at']
print('PASS: live All-Time updates; finalized totals/ranks/awards remain fixed; rollback removes broadcast')

# Current season is live; equal scores keep deterministic rank ordering.
r = read("begin; update public.games set lichtwatt=20 where id='10000000-0000-0000-0000-000000000013'; select public.gg_rankings('season_2026_27','valuable',1,10,null); rollback;")
assert [p['user_id'] for p in r['players']]==[uid(4),uid(1),uid(2),uid(3)]
assert [p['rank'] for p in r['players']]==[1,2,3,4]
print('PASS: consistent tie ordering in live rankings')

for query in (
    "select public.gg_rankings('bad_period','valuable');",
    "select public.gg_rankings('all_time','generous');",
    "select public.gg_rankings('all_time','valuable',0,10);",
    "select public.gg_rankings('all_time','valuable',1,101);",
    "select public.gg_profile_stats('99999999-0000-0000-0000-000000000001','all_time');",
):
    result = subprocess.run(base+['-c',query],capture_output=True,text=True)
    assert result.returncode != 0, query
print('PASS: invalid filters/pages/missing profiles report errors')

# Prove aggregate inputs are not limited by PostgREST's result row cap.
before = rankings('season_2026_27',size=100)['total_good_power']
sql(f"""insert into public.games(id,creator_user_id,game_date,lichtwatt,status)
select ('40000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,
'00000000-0000-0000-0000-000000000006','2026-09-15',0.1,'completed'
from generate_series(1,{args.bulk_count}) n;
analyze public.games; analyze public.invites; analyze public.users;""")
r = rankings('season_2026_27',size=2)
assert r['total_good_power']==before+args.bulk_count/10
assert profile(6,'season_2026_27')['stats']['games']['value']==args.bulk_count
assert len(r['players'])==2
plan = read("explain (analyze,format json) select public.gg_rankings('season_2026_27','valuable',1,10,null);")
print(f"PASS: {args.bulk_count} game inputs aggregated exactly; output bounded; local RPC {plan[0]['Execution Time']} ms")
# Simulate the annual close: no front-end trigger; RPC reads frozen season rows.
assert read("select gg_internal.finalize_due_seasons('2027-06-30T23:59:59.999999Z');")['finalized_seasons']==[]
assert read("select gg_internal.finalize_due_seasons('2027-07-01T00:00:00Z');")['finalized_seasons']==['season_2026_27']
frozen = rankings('season_2026_27',size=100)
assert frozen['players'][0]['user_id']==uid(6)
assert len(profile(6)['awards'])==2
assert {a['category'] for a in profile(6)['awards']}=={'active','valuable'}
assert profile(6)['award_flags']['active_fire'] and profile(6)['award_flags']['mvp_gold']
assert profile(2)['award_flags']['mvp_gold']  # prior MVP medal survives another season/category
sql("update public.games set lichtwatt=20000 where id='10000000-0000-0000-0000-000000000014';")
assert rankings('season_2026_27',size=100)['players']==frozen['players']
assert rankings('all_time',size=100)['players'][0]['user_id']==uid(4)
assert read("select gg_internal.finalize_due_seasons('2027-07-01T00:00:00Z');")['finalized_seasons']==[]
assert read("select gg_internal.period_info('auto','2027-09-01T00:00:00Z');")['key']=='season_2027_28'
assert read("select gg_internal.period_info('season_2027_28');")['period_end_exclusive']=='2028-07-01T00:00:00'
# Any new account still gets a zero-valued closed-season profile, not an error.
sql("insert into public.users(id,display_name) values('00000000-0000-0000-0000-000000000007','New Player');")
assert profile(7)['stats']['good_power']=={'value':0,'rank':None}
assert profile(7)['awards']==[]
# Finalization and its broadcast are transactional.
before=int(sql('select count(*) from realtime.test_events;'))
sql("begin; select gg_internal.finalize_due_seasons('2028-07-01T00:00:00Z'); rollback;")
assert sql("select count(*) from gg_internal.season_results where season_key='season_2027_28';")=='0'
assert int(sql('select count(*) from realtime.test_events;'))==before
print('PASS: annual closure, both top threes, persistent prior medals, frozen ranking, new accounts, atomic rollback')
print('ALL SQL CHECKS PASSED')
