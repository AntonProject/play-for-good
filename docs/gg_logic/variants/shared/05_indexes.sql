-- Optional, outside a transaction. Inspect existing indexes before applying.
create index concurrently if not exists gg_v2_games_user_date
  on public.games(test,creator_user_id,game_date desc nulls last,id) where status='completed';
create index concurrently if not exists gg_v2_invites_user_date
  on public.invites(test,inviter_user_id,used_at) include(lichtwatt) where was_used=true;
create index concurrently if not exists gg_v2_bonus_date
  on gg_v2.point_awards(test,awarded_at) include(user_id,amount);
