"""Produce one LOCAL SQL installation file for the selected option.

Does not connect to a database. Indexes, historical backfill and Cron are
separate explicit steps; see START.md. Existing gg_internal draft is untouched.
"""
import argparse
from pathlib import Path

p=argparse.ArgumentParser()
p.add_argument('variant',choices=['basic','rpc','admin'])
p.add_argument('--output',required=True)
a=p.parse_args()
r=Path(__file__).resolve().parent
files=[r/'shared'/f for f in ['00_seasons.sql','01_environment_bonus.sql','02_scoring.sql','03_finalize.sql','04_context.sql']]
if a.variant in ('rpc','admin'):
    files += [r/'02_rpc/10_rpc.sql',r/'02_rpc/11_notifications.sql']
if a.variant=='admin': files += [r/'03_seasons_admin/20_admin.sql']
Path(a.output).write_text('-- LOCAL PREPARATION ONLY: '+a.variant+'\n'+
    '\n'.join('-- SOURCE: '+str(f.relative_to(r))+'\n'+f.read_text() for f in files))
print(f'Prepared {a.variant}: {a.output}. No database operations performed.')
