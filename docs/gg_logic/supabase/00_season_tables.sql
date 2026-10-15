-- Local preparation only. Execute before 01_functions.sql, on owner's command.
begin;
create schema if not exists gg_internal;
revoke all on schema gg_internal from public;

create table if not exists gg_internal.seasons (
  season_key text primary key,
  label text not null,
  season_year integer not null,
  starts_at timestamp not null,
  ends_at timestamp not null,
  finalized_at timestamptz,
  check (ends_at > starts_at)
);

-- Public profile fields only. No FK to users: account deletion must not cascade
-- into a finalized competition result. RPC can use current name/photo if available.
create table if not exists gg_internal.season_results (
  season_key text not null references gg_internal.seasons(season_key),
  user_id uuid not null,
  display_name text, first_name text, surname text, photo_url text,
  good_power numeric not null, game_power numeric not null, invite_power numeric not null,
  games_count bigint not null, good_energy numeric not null,
  good_power_per_game numeric not null, good_energy_per_game numeric not null,
  sponsored_games bigint not null,
  power_rank bigint, games_rank bigint, power_per_game_rank bigint,
  energy_rank bigint, energy_per_game_rank bigint, sponsored_games_rank bigint,
  primary key(season_key,user_id)
);

alter table gg_internal.seasons enable row level security;
alter table gg_internal.season_results enable row level security;
revoke all on gg_internal.seasons,gg_internal.season_results from public,anon,authenticated;
create index if not exists gg_season_results_power_rank
  on gg_internal.season_results(season_key,power_rank) where power_rank is not null;
create index if not exists gg_season_results_games_rank
  on gg_internal.season_results(season_key,games_rank) where games_rank is not null;
commit;
