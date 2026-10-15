"""Build the isolated local GG v2 packages from the previously tested draft.

No network, Git or database operations. Run from any directory.
Handwritten variant additions live alongside this generator.
"""
from pathlib import Path

root = Path(__file__).resolve().parent
old = root.parent / 'supabase'
shared = root / 'shared'
shared.mkdir(exist_ok=True)

def replace_once(source, before, after):
    assert source.count(before) == 1, before[:100]
    return source.replace(before, after)

schema = (old / '00_season_tables.sql').read_text().replace('gg_internal', 'gg_v2')
schema = schema.replace('  finalized_at timestamptz,\n', '')
schema = schema.replace('  user_id uuid not null,', '  test boolean not null default false,\n  user_id uuid not null,')
schema = schema.replace('primary key(season_key,user_id)', 'primary key(season_key,test,user_id)')
schema = schema.replace('(season_key,power_rank)', '(season_key,test,power_rank)')
schema = schema.replace('(season_key,games_rank)', '(season_key,test,games_rank)')
schema = schema.replace('gg_season_results_', 'gg_v2_season_results_')
schema = schema.replace('commit;', '''
create table if not exists gg_v2.season_closures (
  season_key text not null references gg_v2.seasons(season_key),
  test boolean not null, finalized_at timestamptz,
  primary key(season_key,test)
);
alter table gg_v2.season_closures enable row level security;
revoke all on gg_v2.season_closures from public,anon,authenticated;
insert into gg_v2.seasons(season_key,label,season_year,starts_at,ends_at) values
  ('season_2025_26','Saison 2025/26',2026,'2025-11-20','2026-09-01'),
  ('season_2026_27','Saison 2026/27',2027,'2026-09-01','2027-07-01')
on conflict(season_key) do nothing;
commit;''')
(shared / '00_seasons.sql').write_text(schema)

s = (old / '01_functions.sql').read_text().replace('gg_internal', 'gg_v2')
s = s.replace('public.gg_rankings', 'public.gg_v2_rankings').replace('public.gg_profile_stats', 'public.gg_v2_profile_stats').replace('public.gg_games', 'public.gg_v2_games')
start = s.index('create or replace function gg_v2.period_info(')
end = s.index('create or replace function gg_v2.category_key(')
s = s[:start] + '''-- Dates come from the table. The basic/RPC packages seed only the two
-- specified seasons; only the admin package can plan subsequent seasons.
create or replace function gg_v2.period_info(
  p_period text,p_now timestamptz default transaction_timestamp()
) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare
  k text := lower(btrim(coalesce(p_period,'auto')));
  c timestamp := p_now at time zone (gg_v2.config()->>'timezone');
  s gg_v2.seasons%rowtype; a timestamp; b timestamp; label text;
begin
  k := case k when 'gesamt' then 'all_time' when 'all-time' then 'all_time'
    when 'saison' then 'auto' when 'saison_2025_26' then 'season_2025_26'
    when 'saison_2026_27' then 'season_2026_27' when 'letzter_monat' then 'last_month'
    when 'dieser_monat' then 'this_month' when 'monat' then 'this_month' else k end;
  if k='auto' then
    select t.season_key into k from gg_v2.seasons t where t.starts_at<=c
      order by t.starts_at desc limit 1;
    k := coalesce(k,'all_time');
  end if;
  select * into s from gg_v2.seasons t where t.season_key=k;
  if found then
    return jsonb_build_object('key',k,'label',s.label,'season_year',s.season_year,
      'period_start',s.starts_at,'period_end_exclusive',s.ends_at,
      'timezone',gg_v2.config()->>'timezone','is_completed',c>=s.ends_at);
  end if;
  case k
    when 'last_month' then b:=date_trunc('month',c); a:=b-interval '1 month'; label:='Letzten Monat';
    when 'this_month' then a:=date_trunc('month',c); b:=a+interval '1 month'; label:='Diesen Monat';
    when 'all_time' then label:='All-Time';
    else raise exception 'Unknown GG period: %',p_period using errcode='22023';
  end case;
  return jsonb_build_object('key',k,'label',label,'season_year',null,
    'period_start',a,'period_end_exclusive',b,'timezone',gg_v2.config()->>'timezone',
    'is_completed',false);
end; $$;

create or replace function gg_v2.season_periods(
  p_now timestamptz default transaction_timestamp()
) returns table(period jsonb) language sql stable security definer set search_path='' as $$
  select gg_v2.period_info(t.season_key,p_now) from gg_v2.seasons t;
$$;

create or replace function gg_v2.available_periods() returns jsonb
language sql stable security definer set search_path='' as $$
  select coalesce(jsonb_agg(p.period order by p.period->>'period_start' desc),'[]'::jsonb)
    ||jsonb_build_array(gg_v2.period_info('last_month'),gg_v2.period_info('this_month'),gg_v2.period_info('all_time'))
  from gg_v2.season_periods() p;
$$;

''' + s[end:]
s = s.replace('score_sets(p_period text)', 'score_sets(p_period text,p_test boolean default false)')
s = replace_once(s, "select 1 from gg_v2.seasons t\n    where t.season_key=v_info->>'key' and t.finalized_at is not null", "select 1 from gg_v2.season_closures t\n    where t.season_key=v_info->>'key' and t.test=p_test and t.finalized_at is not null")
s = s.replace("where g.status='completed'", "where g.status='completed' and g.test=p_test")
s = s.replace('where i.was_used=true', 'where i.was_used=true and i.test=p_test')
s = replace_once(s, '  ), scores as (', '''  ), bonus_totals as (
    select a.user_id,coalesce(sum(a.amount) filter(where not v_frozen
      and (v_start is null or a.awarded_at>=v_start)
      and (v_end is null or a.awarded_at<v_end)),0) as sel_gp,
      sum(a.amount) as all_gp
    from gg_v2.point_awards a where a.test=p_test group by a.user_id
  ), scores as (''')
s = s.replace('b.gp+b.invite_gp as good_power', 'b.gp+b.invite_gp+b.bonus_gp as good_power')
s = replace_once(s, '    left join invite_totals i on i.inviter_user_id=u.id\n    cross join lateral (values', '    left join invite_totals i on i.inviter_user_id=u.id\n    left join bonus_totals a on a.user_id=u.id\n    cross join lateral (values')
s = s.replace("('selected',coalesce(g.sel_gp,0),coalesce(i.sel_gp,0),", "('selected',coalesce(g.sel_gp,0),coalesce(i.sel_gp,0),coalesce(a.sel_gp,0),")
s = s.replace("('all_time',coalesce(g.all_gp,0),coalesce(i.all_gp,0),", "('all_time',coalesce(g.all_gp,0),coalesce(i.all_gp,0),coalesce(a.all_gp,0),")
s = s.replace('b(bucket,gp,invite_gp,game_count,energy,sponsored)', 'b(bucket,gp,invite_gp,bonus_gp,game_count,energy,sponsored)')
s = s.replace("where sr.season_key=v_info->>'key'", "where sr.season_key=v_info->>'key' and sr.test=p_test")
s = s.replace('join gg_v2.seasons t using(season_key)', 'join gg_v2.season_closures t using(season_key,test)')
s = s.replace('where t.finalized_at is not null and (r.power_rank', 'where r.test=p_test and t.finalized_at is not null and (r.power_rank')
s = s.replace("'invite_power',p_score->'invite_power',", "'invite_power',p_score->'invite_power',\n    'bonus_power',(p_score->>'good_power')::numeric-(p_score->>'game_power')::numeric-(p_score->>'invite_power')::numeric,")
s = s.replace('p_page_size integer default 10, p_user_id uuid default null', 'p_page_size integer default 10, p_user_id uuid default null,p_test boolean default false')
s = s.replace("p_user_id uuid,p_period text default 'auto'\n", "p_user_id uuid,p_period text default 'auto',p_test boolean default false\n")
s = s.replace('p_page integer default 1,p_page_size integer default 10\n', 'p_page integer default 1,p_page_size integer default 10,p_test boolean default false\n')
s = s.replace('gg_v2.score_sets(p_period)', 'gg_v2.score_sets(p_period,p_test)')
s = s.replace("'period',v_period,'available_periods'", "'test',p_test,'period',v_period,'available_periods'")
s = s.replace('gg_v2.score_sets(text)', 'gg_v2.score_sets(text,boolean)')
s = s.replace('public.gg_v2_rankings(text,text,integer,integer,uuid)', 'public.gg_v2_rankings(text,text,integer,integer,uuid,boolean)')
s = s.replace('public.gg_v2_profile_stats(uuid,text)', 'public.gg_v2_profile_stats(uuid,text,boolean)')
s = s.replace('public.gg_v2_games(uuid,text,text,integer,integer)', 'public.gg_v2_games(uuid,text,text,integer,integer,boolean)')
# The common core is used by finalization and basic context but is not exposed
# as live rankings until variant 02 is installed.
public_start = s.index('-- Public RPC #1:')
priv_start = s.index('-- Restrict default EXECUTE grants.')
core = s[:public_start] + s[priv_start:]
core = core[:core.index('revoke all on function public.gg_v2_rankings')] + 'commit;\n'
(shared / '02_scoring.sql').write_text(core)
rpc = 'begin;\n' + s[public_start:priv_start] + s[s.index('revoke all on function public.gg_v2_rankings'):]
(root / '02_rpc').mkdir(exist_ok=True)
(root / '02_rpc' / '10_rpc.sql').write_text(rpc)

for folder in ('01_basic', '02_rpc', '03_seasons_admin'):
    (root / folder / 'flutterflow').mkdir(parents=True, exist_ok=True)
for name in ('gg_rankings', 'gg_profile_stats', 'gg_games'):
    d = (root.parent / 'flutterflow/actions' / f'{name}.dart').read_text()
    d = d.replace('ggRankings(', 'ggV2Rankings(').replace('ggProfileStats(', 'ggV2ProfileStats(').replace('ggGames(', 'ggV2Games(')
    d = d.replace("'gg_rankings'", "'gg_v2_rankings'").replace("'gg_profile_stats'", "'gg_v2_profile_stats'").replace("'gg_games'", "'gg_v2_games'")
    d = d.replace('  String? userId,\n', '  String? userId,\n  bool test,\n').replace('String userId, String period)', 'String userId, String period, bool test)')
    if name == 'gg_games': d = d.replace('  int pageSize,\n', '  int pageSize,\n  bool test,\n')
    d = d.replace("'p_period': period,", "'p_period': period, 'p_test': test,")
    d = d.replace("'p_period': period}", "'p_period': period, 'p_test': test}")
    (root / '02_rpc/flutterflow' / f'gg_v2_{name[3:]}.dart').write_text(d)

(shared / 'gg_scroll_boundary.dart').write_text((root.parent / 'flutterflow/gg_scroll_boundary.dart').read_text())
(root / '02_rpc/flutterflow/gg_stats_listener.dart').write_text((root.parent / 'flutterflow/gg_stats_listener.dart').read_text().replace("channel('gg:stats')", "channel('gg:v2:stats')"))
(root / '02_rpc/flutterflow/gg_games_rows.dart').write_text((root.parent / 'flutterflow/functions/gg_games_rows.dart').read_text())
print('Prepared isolated packages: shared, 01_basic, 02_rpc, 03_seasons_admin')
