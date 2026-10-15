-- Local preparation only. Execute before 01_functions.sql, on owner's command.
begin;
create schema if not exists gg_v2;
revoke all on schema gg_v2 from public;

create table if not exists gg_v2.seasons (
  season_key text primary key,
  label text not null,
  season_year integer not null,
  starts_at timestamp not null,
  ends_at timestamp not null,
  check (ends_at > starts_at)
);

-- Public profile fields only. No FK to users: account deletion must not cascade
-- into a finalized competition result. RPC can use current name/photo if available.
create table if not exists gg_v2.season_results (
  season_key text not null references gg_v2.seasons(season_key),
  test boolean not null default false,
  user_id uuid not null,
  display_name text, first_name text, surname text, photo_url text,
  good_power numeric not null, game_power numeric not null, invite_power numeric not null,
  games_count bigint not null, good_energy numeric not null,
  good_power_per_game numeric not null, good_energy_per_game numeric not null,
  sponsored_games bigint not null,
  power_rank bigint, games_rank bigint, power_per_game_rank bigint,
  energy_rank bigint, energy_per_game_rank bigint, sponsored_games_rank bigint,
  primary key(season_key,test,user_id)
);

alter table gg_v2.seasons enable row level security;
alter table gg_v2.season_results enable row level security;
revoke all on gg_v2.seasons,gg_v2.season_results from public,anon,authenticated;
create index if not exists gg_v2_season_results_power_rank
  on gg_v2.season_results(season_key,test,power_rank) where power_rank is not null;
create index if not exists gg_v2_season_results_games_rank
  on gg_v2.season_results(season_key,test,games_rank) where games_rank is not null;

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
commit;
