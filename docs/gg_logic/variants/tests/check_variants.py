"""Disposable LOCAL Postgres validation. Never connects to Supabase.

Use a fresh database: the fixture intentionally creates its tables without IF NOT EXISTS.
"""
import argparse
import json
import subprocess
from pathlib import Path

p=argparse.ArgumentParser()
p.add_argument('--psql',required=True)
p.add_argument('--socket',required=True)
p.add_argument('--port',required=True)
p.add_argument('--user',required=True)
p.add_argument('--database',required=True)
p.add_argument('--export',required=True)
a=p.parse_args()
assert a.socket.startswith('/private/tmp/')
r=Path(__file__).resolve().parents[1]
base=[a.psql,'-X','-v','ON_ERROR_STOP=1','-At','-h',a.socket,'-p',a.port,'-U',a.user,'-d',a.database]

def sql(q):
    return subprocess.check_output(base+['-c',q],text=True).strip()
def data(q):
    return json.loads(next(line for line in sql(q).splitlines() if line.startswith(('{','['))))
def load(f):
    result=subprocess.run(base+['-f',str(f)],text=True,capture_output=True)
    if result.returncode: raise RuntimeError(result.stdout+result.stderr)
def fails(q):
    result=subprocess.run(base+['-c',q],text=True,capture_output=True)
    assert result.returncode, q
def uid(n): return f'00000000-0000-0000-0000-{n:012d}'
def ranking(period='season_2025_26',category='valuable',test=False):
    return data(f"set role anon; select public.gg_v2_rankings('{period}','{category}',1,100,'{uid(3)}',{str(test).lower()});")

load(r.parent/'tests/fixture_schema.sql')
sql('''create table auth.users(id uuid primary key,email text,created_at timestamptz,email_confirmed_at timestamptz);
insert into auth.users select id,email,case
 when display_name='Player 1' then '2025-11-19T12:00:00Z'::timestamptz
 when display_name='Player 6' then '2026-09-01T00:00:00Z'::timestamptz
 else '2025-12-01T12:00:00Z'::timestamptz end,'2026-09-30'::timestamptz from public.users;''')
for f in ['00_seasons.sql','01_environment_bonus.sql','02_scoring.sql','03_finalize.sql','04_context.sql']:
    load(r/'shared'/f)
assert sql("select to_regprocedure('public.gg_v2_rankings(text,text,integer,integer,uuid,boolean)') is null;")=='t'
sql('select gg_v2.ensure_signup_bonus(u.id,false) from public.users u;')
assert sql('select count(*) from gg_v2.point_awards;')=='6'
sql('select gg_v2.ensure_signup_bonus(u.id,false) from public.users u;')
assert sql('select count(*) from gg_v2.point_awards;')=='6'
fails('set role anon; select public.gg_v2_claim_signup_bonus(false);')
fails('set role authenticated; select public.gg_v2_claim_signup_bonus(false);')
claimed=data(f"set role authenticated; set request.jwt.claim.sub='{uid(2)}'; select public.gg_v2_claim_signup_bonus(true);")
assert claimed=={'created':True,'test':True,'awarded':True}
assert data(f"set role authenticated; set request.jwt.claim.sub='{uid(2)}'; select public.gg_v2_claim_signup_bonus(true);")['created'] is False
assert sql("select min(awarded_at)::date from gg_v2.point_awards;")=='2025-11-19'
assert sql("select has_table_privilege('authenticated','gg_v2.point_awards','INSERT');")=='f'
# Existing game writes without a test flag remain production.
assert sql('select count(*) from public.games where test;')=='0'
sql(f"insert into public.games(id,creator_user_id,game_date,lichtwatt,status,test) values('40000000-0000-0000-0000-000000000001','{uid(6)}','2026-08-20',10000,'completed',true);")
context=data("set role anon; select public.gg_v2_context('season_2025_26',false);")
assert context['total_good_power_all_time']==1014
assert context['is_finalized'] is False
assert len(context['available_periods'])==5
assert sql("select gg_v2.period_info('auto','2027-08-01')->>'key';")=='season_2026_27'
fails("select gg_v2.period_info('season_2027_28');")
fails("select gg_v2.finalize_season('season_2026_27',false,'2027-06-30T23:59:59.999999Z');")
print('PASS common/basic: test defaults, exactly-once bonus, date attribution, public context, two fixed seasons')

load(r/'02_rpc/10_rpc.sql')
load(r/'02_rpc/11_notifications.sql')
rr=ranking()
assert rr['total_good_power']==657
assert rr['total_good_power_all_time']==1014
assert [x['user_id'] for x in rr['top_players']]==[uid(2),uid(3),uid(4)]
assert rr['players'][0]['bonus_power']==100
assert rr['players'][0]['invite_power']==30
assert ranking(category='active')['players'][0]['user_id']==uid(4)
assert ranking(test=True)['players'][0]['user_id']==uid(6)
assert ranking(test=True)['total_good_power']==10100
assert all(x['awards']==[] for x in rr['players'])
history=data(f"set role anon; select public.gg_v2_games('{uid(6)}','all_time','valuable',1,10,false);")
assert history['games']==[]
assert data(f"set role anon; select public.gg_v2_games('{uid(6)}','all_time','valuable',1,10,true);")['games'][0]['test'] is True
live_fixture={'games':data('select jsonb_agg(to_jsonb(g)) from public.games g;'),
 'users':data('select jsonb_agg(to_jsonb(u)) from public.users u;'),
 'context':context,'ranking':rr,
 'profile':data(f"select public.gg_v2_profile_stats('{uid(3)}','season_2025_26',false);")}
events_before_close=int(sql("select count(*) from realtime.test_events where topic='gg:v2:stats';"))
closed=data("select gg_v2.finalize_due_seasons('2026-09-01T00:00:00Z');")
assert len(closed['finalized'])==2
events_after_close=int(sql("select count(*) from realtime.test_events where topic='gg:v2:stats';"))
assert events_after_close>events_before_close
assert data("select gg_v2.finalize_due_seasons('2026-09-01T00:00:00Z');")['finalized']==[]
assert int(sql("select count(*) from realtime.test_events where topic='gg:v2:stats';"))==events_after_close
rr=ranking()
assert any(x['category']=='valuable' and x['place']==1 for x in rr['players'][0]['awards'])
assert all(x['season_year']==2026 for x in rr['players'][0]['awards'])
frozen_value=rr['total_good_power']
sql("update public.games set lichtwatt=5000 where id='10000000-0000-0000-0000-000000000001';")
sql(f"update public.users set display_name='Updated Player 3' where id='{uid(3)}';")
assert ranking()['total_good_power']==frozen_value
assert ranking('all_time')['total_good_power']==5914
assert ranking(test=True)['total_good_power']==10100
frozen_fixture={'games':data('select jsonb_agg(to_jsonb(g)) from public.games g;'),
 'users':data('select jsonb_agg(to_jsonb(u)) from public.users u;'),'context':data("select public.gg_v2_context('season_2025_26',false);"),
 'ranking':ranking(),'profile':data(f"select public.gg_v2_profile_stats('{uid(3)}','season_2025_26',false);")}
Path(a.export).write_text(json.dumps({'live':live_fixture,'frozen':frozen_fixture}))
assert sql("select count(*) from realtime.test_events where topic='gg:v2:stats';")!='0'
print('PASS RPC: accurate game/invite/bonus totals, env isolation, independent MVP/MAP, bounded history, frozen results')

load(r/'03_seasons_admin/20_admin.sql')
fails("set role authenticated; select public.gg_v2_seasons_admin('list');")
sql(f"insert into gg_v2.season_admins values('{uid(1)}');")
prefix=f"set role authenticated; set request.jwt.claim.sub='{uid(1)}'; "
def save(fields):
    return "select public.gg_v2_seasons_admin('save','"+json.dumps(fields)+"'::jsonb,false);"
changed={'season_key':'season_2026_27','label':'Custom Saison 2026/27','season_year':2027,
 'starts_on':'2026-09-01','last_day':'2027-06-29'}
assert data(prefix+save(changed))['saved']=='season_2026_27'
assert ranking('season_2026_27')['period']['period_end_exclusive']=='2027-06-30T00:00:00'
overlap={**changed,'season_key':'season_overlap','starts_on':'2027-06-20','last_day':'2028-06-30'}
fails(prefix+save(overlap))
fails(prefix+save({**changed,'season_key':'season_2025_26'}))
preview=data(prefix+"select public.gg_v2_seasons_admin('preview','{\"season_key\":\"season_2026_27\"}',false);")
assert len(preview['top_players'])==3 and 'map' in preview
assert sql("select count(*) from gg_v2.season_closures where season_key='season_2026_27' and finalized_at is not null;")=='0'
result=data("select gg_v2.finalize_due_seasons('2027-07-01T00:00:00Z');")
assert result['planned']==['season_2027_28']
assert data("select gg_v2.finalize_due_seasons('2027-07-01T00:00:00Z');")['planned']==[]
assert sql("select gg_v2.period_info('auto','2027-08-31')->>'key';")=='season_2026_27'
assert sql("select gg_v2.period_info('auto','2027-09-01T00:00:00Z')->>'key';")=='season_2027_28'
assert sql("select count(*) from gg_v2.seasons;")=='3'
# Award display contract: category-first order, season-only ranking badges,
# all history in profiles/All-Time/months, independent of the MVP/MAP sort.
all_badges=data(
    f"select public.gg_v2_rankings('all_time','valuable',1,100,'{uid(4)}',false);")['current_user']['awards']
assert len(all_badges)==4
assert [(b['category'],b['season_year']) for b in all_badges]==[
    ('valuable',2027),('valuable',2026),('active',2027),('active',2026)]
for period,year in [('season_2025_26',2026),('season_2026_27',2027)]:
    for category in ['valuable','active']:
        response=data(f"select public.gg_v2_rankings('{period}','{category}',1,100,'{uid(4)}',false);")
        badges=response['current_user']['awards']
        assert len(badges)==2 and all(b['season_year']==year for b in badges)
        assert [b['category'] for b in badges]==['valuable','active']
    assert data(f"select public.gg_v2_profile_stats('{uid(4)}','{period}',false);")['awards']==all_badges
for period in ['this_month','last_month']:
    assert data(f"select public.gg_v2_rankings('{period}','valuable',1,100,'{uid(4)}',false);")['current_user']['awards']==all_badges
context=data("select public.gg_v2_context('season_2025_26',false);")
assert context['awards_by_user'][uid(4)]==all_badges
assert ranking('season_2027_28')['current_user']['awards']==[]
print('PASS badges: MVP before MAP, all history in profiles/months/All-Time, selected season only in ranking')
# Future dates created by admin must survive later cron runs.
future={'season_key':'season_2027_28','label':'Adjusted next','season_year':2028,'starts_on':'2027-09-03','last_day':'2028-06-25'}
assert data(prefix+save(future))['saved']=='season_2027_28'
data("select gg_v2.finalize_due_seasons('2027-08-01T00:00:00Z');")
assert sql("select starts_at::date from gg_v2.seasons where season_key='season_2027_28';")=='2027-09-03'
print('PASS admin: access control, editable dates, overlaps, frozen edit rejection, read-only preview, next season, cron idempotency')
# Reapply SQL files to detect replacement/signature/grant errors.
for f in ['00_seasons.sql','01_environment_bonus.sql','02_scoring.sql','03_finalize.sql','04_context.sql']:
    load(r/'shared'/f)
load(r/'02_rpc/10_rpc.sql')
load(r/'02_rpc/11_notifications.sql')
load(r/'03_seasons_admin/20_admin.sql')
assert sql("select has_function_privilege('anon','gg_v2.finalize_due_seasons(timestamptz)','EXECUTE');")=='f'
assert sql("select has_function_privilege('authenticated','gg_v2.ensure_signup_bonus(uuid,boolean)','EXECUTE');")=='f'
print('PASS idempotent local install; private owner writes remain inaccessible to clients')
sql(f"delete from public.games where creator_user_id='{uid(6)}'; delete from public.users where id='{uid(6)}';")
assert sql(f"select count(*) from gg_v2.point_awards where user_id='{uid(6)}';")=='0'
assert ranking(test=True)['players'][0]['user_id']==uid(6)
print('PASS account removal: bonus does not block deletion; stored season medals/results survive')
sql(f"insert into auth.users values('{uid(7)}','legacy-signup@example.invalid','2026-09-11T10:00:00Z','2026-09-11T10:01:00Z'); insert into public.users(id,email,display_name) values('{uid(7)}','legacy-signup@example.invalid','Legacy signup');")
assert sql(f"select test::text||':'||amount::text from gg_v2.point_awards where user_id='{uid(7)}';")=='false:100'
sql(f"insert into auth.users values('{uid(8)}','pending@example.invalid','2026-09-12T10:00:00Z',null); insert into public.users(id,email,display_name,signup_test) values('{uid(8)}','pending@example.invalid','Test signup',true);")
assert sql(f"select count(*) from gg_v2.point_awards where user_id='{uid(8)}';")=='0'
sql(f"update auth.users set email_confirmed_at='2026-09-12T10:01:00Z' where id='{uid(8)}';")
assert data(f"set role authenticated; set request.jwt.claim.sub='{uid(8)}'; select public.gg_v2_claim_signup_bonus(true);")['created'] is True
assert sql(f"select test::text||':'||awarded_at::date::text from gg_v2.point_awards where user_id='{uid(8)}';")=='true:2026-09-12'
print('PASS old signup defaults and test signup: verified accounts only; late confirmation claim preserves registration date')
