-- LOCAL ONLY. Review existing indexes and EXPLAIN first to avoid duplicates.
-- Run individually outside a transaction. CONCURRENTLY limits writer blocking.
create index concurrently if not exists gg_games_completed_user_date_idx
  on public.games(creator_user_id,game_date desc nulls last,id)
  where status='completed';
create index concurrently if not exists gg_games_completed_user_power_idx
  on public.games(creator_user_id,(coalesce(lichtwatt,0)) desc,game_date desc nulls last,id)
  where status='completed';
create index concurrently if not exists gg_invites_used_user_date_idx
  on public.invites(inviter_user_id,used_at) include(lichtwatt)
  where was_used=true;
