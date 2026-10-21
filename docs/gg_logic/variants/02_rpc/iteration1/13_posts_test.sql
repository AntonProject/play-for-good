-- Posts split into test / prod (16.10.2026), like games.test and invites.test.
-- Good News showed prod posts in test builds: posts had no test flag.
-- Posts are written by public.unified_game_processing (AFTER trigger on games,
-- when a game becomes completed) with game_id; the game row already exists then,
-- so the post takes the flag of its game.
-- Run the WHOLE file in the Supabase SQL editor (owner); one transaction.
--
-- What it changes in existing tables:
--   public.posts  new column test boolean NOT NULL DEFAULT false
--                 (every existing row = prod, false);
--                 then test = true ONLY for posts whose game has games.test = true;
--                 no other column or row is changed, nothing is deleted
--   new index     posts_test_created_at (test, created_at desc) for the feed
--   new trigger   gg_v2_posts_test on posts: BEFORE INSERT / UPDATE OF game_id
--                 sets test from the game (posts without a game keep the value given,
--                 default false = prod)
-- Not touched: unified_game_processing, games, users, organization, the other
-- posts triggers (gg_v2_posts_changed keeps sending refresh events), RLS.

begin;

alter table public.posts add column if not exists test boolean not null default false;

-- Existing posts of test games (expected: as many as completed test games with a post).
update public.posts p set test = true
from public.games g
where g.id = p.game_id and g.test and not p.test;

create index if not exists posts_test_created_at on public.posts(test, created_at desc);

create or replace function gg_v2.posts_test_from_game() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.game_id is not null then
    new.test := coalesce((select g.test from public.games g where g.id = new.game_id), new.test);
  end if;
  return new;
end;
$$;
revoke all on function gg_v2.posts_test_from_game() from public, anon, authenticated;

drop trigger if exists gg_v2_posts_test on public.posts;
create trigger gg_v2_posts_test before insert or update of game_id on public.posts
  for each row execute function gg_v2.posts_test_from_game();

notify pgrst, 'reload schema';
commit;

-- Check (read-only): posts per environment; mismatches with their game (expected 0).
-- select test, count(*) from public.posts group by test order by test;
-- select count(*) from public.posts p join public.games g on g.id = p.game_id where p.test <> g.test;
