"""Prepare the current RPC-first iteration locally; never connects to cloud."""
from pathlib import Path
import re
import shutil

root = Path(__file__).resolve().parents[2]
out = Path(__file__).resolve().parent

def function(source, name):
    match = re.search(r'create or replace function ' + re.escape(name) + r'\([\s\S]*?\$\$;', source)
    assert match, name
    return match.group()

base = (root / '02_rpc/deploy/01_passive.sql').read_text()
# One transaction: no half-installed first iteration if an override fails.
base = re.sub(r'(?m)^(begin;|commit;)$', '', base)
base = base.replace("notify pgrst, 'reload schema';", '')
# LISTENER GUARD (13 Oct): the listener triggers are now installed on purpose,
# so the passive-install guard would block every later re-run of this file.
guard_start = base.index('do $$ begin')
guard_end = base.index('end $$;', guard_start) + len('end $$;')
assert 'gg_v2 triggers already active' in base[guard_start:guard_end]
base = base[:guard_start] + base[guard_end:]
# TZ (14 Oct): 2025/26 starts 01.11.2025, not 20.11.2025 as in earlier drafts.
seed = "('season_2025_26','Saison 2025/26',2026,'2025-11-20','2026-09-01')"
assert seed in base
base = base.replace(seed, "('season_2025_26','Saison 2025/26',2026,'2025-11-01','2026-09-01')")
scoring = (root / 'shared/02_scoring.sql').read_text()
category = function(scoring, 'gg_v2.category_key').replace(
    "  raise exception 'Unknown GG category:",
    "  if v_key in ('generous','most_generous_player') then return 'generous'; end if;\n"
    "  if v_key in ('social','most_social_player') then return 'social'; end if;\n"
    "  raise exception 'Unknown GG category:")
period_info = function(scoring, 'gg_v2.period_info').replace(
    "when 'saison' then 'auto'",
    "when 'season_26_27' then 'season_2026_27' when 'season_25_26' then 'season_2025_26' when 'saison' then 'auto'")
scores = function(scoring, 'gg_v2.score_sets').replace(
    'a.test=p_test group by a.user_id',
    "a.test=p_test and (gg_v2.config()->>'signup_bonus_migrated')::boolean group by a.user_id")
score_case = "case v_category when 'active' then s.games_count when 'generous' then s.good_energy when 'social' then s.sponsored_games else s.good_power end"
payload = function(scoring, 'gg_v2.player_payload').replace(
    "case when p_category='active' then p_score->'games_count' else p_score->'good_power' end",
    "case p_category when 'active' then p_score->'games_count' when 'generous' then p_score->'good_energy' when 'social' then p_score->'sponsored_games' else p_score->'good_power' end").replace(
    "case when p_category='active' then p_score->'games_rank' else p_score->'power_rank' end",
    "case p_category when 'active' then p_score->'games_rank' when 'generous' then p_score->'energy_rank' when 'social' then p_score->'sponsored_games_rank' else p_score->'power_rank' end")

# TIES (14 Oct): equal score -> more recent activity in the period ranks higher.
# Return type of score_sets stays identical so the install can be re-run.
def sub(text, old, new, count=1):
    assert text.count(old) == count, (old, text.count(old))
    return text.replace(old, new)
scores = sub(scores, "      coalesce(g.sponsor_money,0)>0 as sponsored,\n", "      coalesce(g.sponsor_money,0)>0 as sponsored,g.game_date as at,\n")
scores = sub(scores, "    select i.inviter_user_id,coalesce(i.lichtwatt::numeric,0) as gp,\n", "    select i.inviter_user_id,coalesce(i.lichtwatt::numeric,0) as gp,i.used_at as at,\n")
scores = sub(scores, "      sum(e.energy) as all_energy,count(*) filter(where e.sponsored) as all_sponsored\n",
    "      sum(e.energy) as all_energy,count(*) filter(where e.sponsored) as all_sponsored,\n      max(e.at) filter(where e.selected) as sel_at,max(e.at) as all_at\n")
scores = sub(scores, "      coalesce(sum(e.gp) filter(where e.selected),0) as sel_gp,sum(e.gp) as all_gp\n",
    "      coalesce(sum(e.gp) filter(where e.selected),0) as sel_gp,sum(e.gp) as all_gp,\n      max(e.at) filter(where e.selected) as sel_at,max(e.at) as all_at\n")
scores = sub(scores, "      b.sponsored as sponsored_games\n    from public.users u", "      b.sponsored as sponsored_games,b.last_at\n    from public.users u")
scores = sub(scores, "coalesce(g.sel_count,0),coalesce(g.sel_energy,0),coalesce(g.sel_sponsored,0)),",
    "coalesce(g.sel_count,0),coalesce(g.sel_energy,0),coalesce(g.sel_sponsored,0),greatest(g.sel_at,i.sel_at)),")
scores = sub(scores, "coalesce(g.all_count,0),coalesce(g.all_energy,0),coalesce(g.all_sponsored,0))\n",
    "coalesce(g.all_count,0),coalesce(g.all_energy,0),coalesce(g.all_sponsored,0),greatest(g.all_at,i.all_at))\n")
scores = sub(scores, "as b(bucket,gp,invite_gp,bonus_gp,game_count,energy,sponsored)", "as b(bucket,gp,invite_gp,bonus_gp,game_count,energy,sponsored,last_at)")
scores = sub(scores, "  select s.*,\n    case when s.good_power>0",
    "  select s.bucket,s.user_id,s.display_name,s.first_name,s.surname,s.photo_url,\n    s.good_power,s.game_power,s.invite_power,s.games_count,s.good_energy,\n    s.good_power_per_game,s.good_energy_per_game,s.sponsored_games,\n    case when s.good_power>0")
scores = sub(scores, " desc,s.user_id)", " desc,s.last_at desc nulls last,s.user_id)", 6)
# Home keeps its week filter (woche).
period_info = sub(period_info, "when 'monat' then 'this_month' else k end;", "when 'monat' then 'this_month' when 'woche' then 'this_week' when 'diese_woche' then 'this_week' else k end;")
period_info = sub(period_info, "    when 'all_time' then label:='All-Time';",
    "    when 'this_week' then a:=date_trunc('week',c); b:=a+interval '7 days'; label:='Diese Woche';\n    when 'all_time' then label:='All-Time';")

rpc = (root / '02_rpc/10_rpc.sql').read_text()
rpc = re.sub(r'(?m)^(begin;|commit;)$', '', rpc)
rpc = rpc.replace("case when v_category='active' then s.games_count else s.good_power end", score_case)
# Social game history used the same lichtwatt order as valuable in existing FF.
rpc = rpc.replace("when v_category='valuable' then coalesce(g.lichtwatt,0)",
                  "when v_category in ('valuable','social') then coalesce(g.lichtwatt,0)")
rpc = rpc.replace("      g.game_date desc nulls last,g.id", "      case when v_category='generous' then coalesce(g.user_money,0)+coalesce(g.team_money,0)+coalesce(g.sieg_money,0)+coalesce(g.additional_donation_money,0) end desc nulls last,\n      g.game_date desc nulls last,g.id")
extra = """'awards_season',gg_v2.last_finalized_season(p_test),
    'signup_bonus_migrated',(gg_v2.config()->>'signup_bonus_migrated')::boolean,
    'legacy_bonus_users_count',(select count(*) from public.users),
    'layout_mode',case when v_period->>'season_year' is not null and (v_period->>'is_completed')::boolean then 'final' else 'current' end,
    'results_finalized',exists(select 1 from gg_v2.season_closures c where c.season_key=v_period->>'key' and c.test=p_test and c.finalized_at is not null),
    """
# Count is aggregated in a private definer to respect inviter/private table RLS.
rpc = rpc.replace("(select count(*) from public.users)", 'gg_v2.registered_users_count()')
extra = extra.replace("(select count(*) from public.users)", 'gg_v2.registered_users_count()').replace(
    "exists(select 1 from gg_v2.season_closures c where c.season_key=v_period->>'key' and c.test=p_test and c.finalized_at is not null)",
    "gg_v2.is_finalized(v_period->>'key',p_test)")
rpc = rpc.replace("'season_year',(p.period->>'season_year')::integer,", "'season_year',(p.period->>'season_year')::integer,'season_label',p.period->>'label','period_start',p.period->>'period_start',")
rpc = rpc.replace("(a.award->>'season_year')::integer desc,a.award->>'season',", "a.award->>'period_start' desc,a.award->>'season',")
rpc = rpc.replace("'test',p_test,'period',v_period", extra + "'test',p_test,'period',v_period")
# Ranking order follows the stored/computed place, not the raw score (ties).
rpc = sub(rpc, "      gg_v2.player_payload(to_jsonb(s),v_category,a.items) as payload\n",
    "      case v_category when 'active' then s.games_rank when 'generous' then s.energy_rank when 'social' then s.sponsored_games_rank else s.power_rank end as place,\n      gg_v2.player_payload(to_jsonb(s),v_category,a.items) as payload\n")
rpc = sub(rpc, "select * from eligible order by score desc,user_id", "select * from eligible order by place,user_id", 2)
rpc = sub(rpc, "order by t.score desc,t.user_id", "order by t.place,t.user_id")
rpc = sub(rpc, "order by p.score desc,p.user_id", "order by p.place,p.user_id")
# Guest: demo 100 points and newest "registration", so ties go to the guest.
# Registered users are compared by their server MVP score (no client +100 since 14 Oct).
rpc = sub(rpc, "    'top_players',coalesce(",
    "    'guest_rank',(select count(*)+1 from scores s where s.bucket='selected' and s.good_power>100),\n"
    "    'guest_places',jsonb_build_object(\n"
    "      'good_power',(select count(*)+1 from scores s where s.bucket='selected' and s.good_power>100),\n"
    "      'games',(select count(*)+1 from scores s where s.bucket='selected' and s.games_count>0),\n"
    "      'good_power_per_game',(select count(*)+1 from scores s where s.bucket='selected' and s.games_count>0),\n"
    "      'good_energy',(select count(*)+1 from scores s where s.bucket='selected' and s.good_energy>0),\n"
    "      'good_energy_per_game',(select count(*)+1 from scores s where s.bucket='selected' and s.games_count>0),\n"
    "      'sponsored_games',(select count(*)+1 from scores s where s.bucket='selected' and s.sponsored_games>0),\n"
    "      'all_time_good_power',(select count(*)+1 from scores s where s.bucket='all_time' and s.good_power>100)),\n"
    "    'env_other_users_count',gg_v2.env_users_count(p_test,p_user_id),\n"
    "    'top_players',coalesce(")
# GUEST PLACES (16 Oct): the guest profile Stats rows. Demo 100 points, nothing
# else, so every other metric is the last place (as for a zero in the profile).
# all_time_good_power: the profile header (All-Time), from the same call.
# PROFILE ZERO RANKS (13 Oct): every Stats row shows a place. A zero value has
# no computed rank; it gets "after everyone with a value > 0" (as on Home).
def after_all(metric, cond, bucket='selected'):
    return f"(select count(*)+1 from scores x where x.bucket='{bucket}' and x.{cond})"
for key, rank, cond in [
    ('good_power', 'power_rank', 'good_power>0'),
    ('games', 'games_rank', 'games_count>0'),
    ('good_power_per_game', 'power_per_game_rank', 'games_count>0'),
    ('good_energy', 'energy_rank', 'good_energy>0'),
    ('good_energy_per_game', 'energy_per_game_rank', 'games_count>0'),
    ('sponsored_games', 'sponsored_games_rank', 'sponsored_games>0'),
]:
    old = f"'rank',s.{rank})"
    assert rpc.count(old) >= 1, old
    rpc = rpc.replace(f"'{key}',jsonb_build_object('value',", f"'{key}',jsonb_build_object('value',", 1)
    rpc = rpc.replace(old, f"'rank',coalesce(s.{rank},{after_all(key, cond)}))", 1)
rpc = sub(rpc, "'all_time',jsonb_build_object('good_power',a.good_power,'rank',a.power_rank,",
    "'all_time',jsonb_build_object('good_power',a.good_power,'rank',coalesce(a.power_rank,(select count(*)+1 from scores x where x.bucket='all_time' and x.good_power>0)),")
# Row medals: last closed season regardless of the selected period (14 Oct).
row_filter = "and (v_period->>'season_year' is null or p.period->>'key'=v_period->>'key')"
assert rpc.count(row_filter) == 1
rpc = rpc.replace(row_filter, "and p.period->>'key'=gg_v2.last_finalized_season(p_test)")

# HOME GAUGE (14 Oct): Home shows my total, the period maximum and the average
# of the others; the maximum was the only figure missing from the ranking JSON.
total_line = "'total_good_power',coalesce((select sum(s.good_power) from scores s where s.bucket='selected'),0),"
assert total_line in rpc, 'total_good_power line moved'
rpc = rpc.replace(total_line, total_line + "\n    'max_good_power',coalesce((select max(s.good_power) from scores s where s.bucket='selected'),0),", 1)

finalize = function((root / 'shared/03_finalize.sql').read_text(), 'gg_v2.finalize_season')
# Finalization no longer waits for the bonus migration: results can be closed now
# and recomputed with gg_v2.refinalize_season once the +100 ledger is live.
finalize = finalize.replace('begin\n', "begin\n  if not (gg_v2.config()->>'finalization_enabled')::boolean then\n    raise exception 'Season finalization paused: enable gg_v2.rollout.finalization_enabled' using errcode='55000';\n  end if;\n", 1)

overlay = (out / 'settings_calendar.sql').read_text()
sql = 'begin;\n' + base + '\n-- CURRENT ITERATION OVERRIDES\n' + overlay
# ENV USERS (16 Oct): users of one environment for the Home gauge average:
# signed up from this build (signup_test) or with points in this environment,
# without p_exclude (the requested user; null for a guest).
env_users = """create or replace function gg_v2.env_users_count(p_test boolean,p_exclude uuid default null) returns bigint
language sql stable security definer set search_path='' as $$
  select count(*) from public.users u
  where u.id is distinct from p_exclude
    and (u.signup_test = p_test
     or exists (select 1 from public.games g where g.creator_user_id = u.id and g.status = 'completed' and g.test = p_test)
     or exists (select 1 from public.invites i where i.inviter_user_id = u.id and i.was_used and i.test = p_test)
     or exists (select 1 from gg_v2.point_awards a where a.user_id = u.id and a.test = p_test));
$$;
revoke all on function gg_v2.env_users_count(boolean,uuid) from public,anon,authenticated;
grant execute on function gg_v2.env_users_count(boolean,uuid) to anon,authenticated;"""
sql += '\n' + '\n'.join([env_users, period_info, category, scores, payload, finalize, rpc])
sql += "\nnotify pgrst, 'reload schema';\ncommit;\n"
(out / '01_install.sql').write_text(sql)
shutil.copyfile(root / '02_rpc/11_notifications.sql', out / '02_listener.sql')
(out / '03_schedule.sql').write_text("""-- Separate owner-authorized step after Supabase Cron is enabled.
-- Calendar planning works now; closing results follows gg_v2.rollout.finalization_enabled.
-- Daily at 00:05 UTC: seasons end at midnight; a no-op when nothing ended.
select cron.schedule('gg-v2-close-seasons','5 0 * * *',
  $job$select gg_v2.finalize_due_seasons();$job$);
""")
print('Prepared iteration1 locally: install, listener, schedule. No cloud writes.')
