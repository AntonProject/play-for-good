// Custom Action ggLoadRanking. Returns the Data Type GgRanking.
// Keep FF automatic imports above this code.
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';

Future<GgRankingStruct> ggLoadRanking(
  String period,
  String category,
  int page,
  int pageSize,
  String? userId,
  bool test,
) async {
  // gg_v2_rankings, parsed into GgRanking (all response fields).
  if (page < 1 || pageSize < 1 || pageSize > 100) {
    throw ArgumentError('page >= 1 and pageSize 1..100 required');
  }
  final result = await SupaFlow.client.rpc(
    'gg_v2_rankings',
    params: {
      'p_period': period,
      'p_test': test,
      'p_category': category,
      'p_page': page,
      'p_page_size': pageSize,
      'p_user_id':
          userId == null || userId.isEmpty || userId == 'guest' ? null : userId,
    },
  );
  if (result is! Map) throw StateError('Invalid ranking response');
  return _ranking(result);
}

// --- JSON -> Data Types (gg_v2 RPC response, see docs/gg_logic/TYPED_SCHEMA.md)
double? _d(dynamic v) => v is num ? v.toDouble() : (v is String ? double.tryParse(v) : null);
int? _i(dynamic v) => v is num ? v.toInt() : (v is String ? int.tryParse(v) : null);
String? _s(dynamic v) => v == null ? null : '$v';
bool _b(dynamic v) => v == true;
Map _m(dynamic v) => v is Map ? v : const {};
List _l(dynamic v) => v is List ? v : const [];
DateTime? _t(dynamic v) {
  if (v is! String || v.isEmpty) return null;
  // Server timestamps are UTC without an offset.
  final s = v.endsWith('Z') || v.contains('+') ? v : '${v}Z';
  return DateTime.tryParse(s)?.toUtc();
}
T? _e<T extends Enum>(List<T> values, dynamic v) {
  for (final x in values) {
    if (x.name == v) return x;
  }
  return null;
}
GgLayoutMode _layout(dynamic v) => v == 'final' ? GgLayoutMode.finished : GgLayoutMode.current;

GgPeriodStruct _period(dynamic raw) {
  final m = _m(raw);
  return GgPeriodStruct(
    key: _s(m['key']),
    label: _s(m['label']),
    seasonYear: _i(m['season_year']),
    isCompleted: _b(m['is_completed']),
    start: _t(m['period_start']),
    endExclusive: _t(m['period_end_exclusive']),
    timezone: _s(m['timezone']),
  );
}

List<GgPeriodStruct> _periods(dynamic raw) => [for (final p in _l(raw)) _period(p)];

GgAwardStruct _award(dynamic raw) {
  final m = _m(raw);
  return GgAwardStruct(
    badge: _e(GgBadge.values, m['badge']),
    place: _i(m['place']),
    category: _e(GgCategory.values, m['category']),
    season: _s(m['season']),
    seasonLabel: _s(m['season_label']),
    seasonYear: _i(m['season_year']),
    seasonStart: _t(m['period_start']),
  );
}

List<GgAwardStruct> _awards(dynamic raw) => [for (final a in _l(raw)) _award(a)];

GgAwardFlagsStruct _flags(dynamic raw) {
  final m = _m(raw);
  return GgAwardFlagsStruct(
    mvpGold: _b(m['mvp_gold']),
    mvpSilver: _b(m['mvp_silver']),
    mvpBronze: _b(m['mvp_bronze']),
    activeFire: _b(m['active_fire']),
    mapSilver: _b(m['map_silver']),
    mapBronze: _b(m['map_bronze']),
  );
}

GgPlayerStruct? _player(dynamic raw) {
  if (raw is! Map) return null;
  final m = raw;
  return GgPlayerStruct(
    userId: _s(m['user_id']),
    rank: _i(m['rank']),
    score: _d(m['score']),
    displayName: _s(m['display_name']),
    firstName: _s(m['first_name']),
    surname: _s(m['surname']),
    photoUrl: _s(m['photo_url']),
    goodPower: _d(m['good_power']),
    gamePower: _d(m['game_power']),
    invitePower: _d(m['invite_power']),
    bonusPower: _d(m['bonus_power']),
    gamesCount: _i(m['games_count']),
    awards: _awards(m['awards']),
    awardFlags: _flags(m['award_flags']),
  );
}

List<GgPlayerStruct> _players(dynamic raw) =>
    [for (final p in _l(raw)) _player(p)].whereType<GgPlayerStruct>().toList();

GgGuestPlacesStruct _guestPlaces(dynamic raw) {
  final m = _m(raw);
  return GgGuestPlacesStruct(
    goodPower: _i(m['good_power']),
    games: _i(m['games']),
    goodPowerPerGame: _i(m['good_power_per_game']),
    goodEnergy: _i(m['good_energy']),
    goodEnergyPerGame: _i(m['good_energy_per_game']),
    sponsoredGames: _i(m['sponsored_games']),
    allTimeGoodPower: _i(m['all_time_good_power']),
  );
}

GgRankingStruct _ranking(Map m) {
  final pagination = _m(m['pagination']);
  return GgRankingStruct(
    requestedPeriod: _s(m['requested_period']),
    requestedCategory: _s(m['requested_category']),
    requestedUserId: _s(m['requested_user_id']),
    period: _period(m['period']),
    availablePeriods: _periods(m['available_periods']),
    category: _e(GgCategory.values, m['category']),
    layoutMode: _layout(m['layout_mode']),
    resultsFinalized: _b(m['results_finalized']),
    awardsSeason: _s(m['awards_season']),
    topPlayers: _players(m['top_players']),
    players: _players(m['players']),
    currentUser: _player(m['current_user']),
    guestRank: _i(m['guest_rank']),
    guestPlaces: _guestPlaces(m['guest_places']),
    page: _i(pagination['page']),
    pageSize: _i(pagination['page_size']),
    totalCount: _i(pagination['total_count']),
    hasMore: _b(pagination['has_more']),
    totalGoodPower: _d(m['total_good_power']),
    totalGoodPowerAllTime: _d(m['total_good_power_all_time']),
    maxGoodPower: _d(m['max_good_power']),
    test: _b(m['test']),
    signupBonusMigrated: _b(m['signup_bonus_migrated']),
    legacyBonusUsersCount: _i(m['legacy_bonus_users_count']),
    envOtherUsersCount: _i(m['env_other_users_count']),
  );
}
