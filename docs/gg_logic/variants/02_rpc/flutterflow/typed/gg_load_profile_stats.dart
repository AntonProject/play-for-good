// Custom Action ggLoadProfileStats. Returns the Data Type GgProfileStats.
// Keep FF automatic imports above this code.
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';

Future<GgProfileStatsStruct> ggLoadProfileStats(
  String userId,
  String period,
  bool test,
) async {
  // gg_v2_profile_stats, parsed into GgProfileStats (all response fields).
  // Guest ('' / 'guest', 21.10.2026): the demo guest of the same period - 100
  // Good Power, nothing else - with the guest places the server counts for the
  // ranking (guest_places), so Energy, Meine Games, profile and Good Games
  // show one guest place (before: #0 on Energy / Meine Games).
  if (userId == 'guest' || userId.isEmpty) {
    final ranking = await SupaFlow.client.rpc(
      'gg_v2_rankings',
      params: {
        'p_period': period,
        'p_category': 'valuable',
        'p_page': 1,
        'p_page_size': 1,
        'p_user_id': null,
        'p_test': test,
      },
    );
    if (ranking is! Map) throw StateError('Invalid ranking response');
    return _guestStats(ranking);
  }
  final result = await SupaFlow.client.rpc(
    'gg_v2_profile_stats',
    params: {'p_user_id': userId, 'p_period': period, 'p_test': test},
  );
  if (result is! Map) throw StateError('Invalid profile response');
  return _stats(result);
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

GgMetricStruct _metric(dynamic raw) {
  final m = _m(raw);
  return GgMetricStruct(value: _d(m['value']), rank: _i(m['rank']));
}

GgProfileStatsStruct _stats(Map m) {
  final stats = _m(m['stats']);
  final allTime = _m(m['all_time']);
  return GgProfileStatsStruct(
    userId: _s(m['user_id']),
    displayName: _s(m['display_name']),
    photoUrl: _s(m['photo_url']),
    requestedPeriod: _s(m['requested_period']),
    period: _period(m['period']),
    availablePeriods: _periods(m['available_periods']),
    layoutMode: _layout(m['layout_mode']),
    resultsFinalized: _b(m['results_finalized']),
    awardsSeason: _s(m['awards_season']),
    goodPower: _metric(stats['good_power']),
    games: _metric(stats['games']),
    goodPowerPerGame: _metric(stats['good_power_per_game']),
    goodEnergy: _metric(stats['good_energy']),
    goodEnergyPerGame: _metric(stats['good_energy_per_game']),
    sponsoredGames: _metric(stats['sponsored_games']),
    allTimeRank: _i(allTime['rank']),
    allTimeGoodPower: _d(allTime['good_power']),
    allTimeGamesCount: _i(allTime['games_count']),
    awards: _awards(m['awards']),
    awardFlags: _flags(m['award_flags']),
    totalGoodPower: _d(m['total_good_power']),
    totalGoodPowerAllTime: _d(m['total_good_power_all_time']),
    test: _b(m['test']),
    signupBonusMigrated: _b(m['signup_bonus_migrated']),
    legacyBonusUsersCount: _i(m['legacy_bonus_users_count']),
  );
}

GgProfileStatsStruct _guestStats(Map m) {
  final places = _m(m['guest_places']);
  GgMetricStruct metric(double value, String key) =>
      GgMetricStruct(value: value, rank: _i(places[key]));
  return GgProfileStatsStruct(
    userId: 'guest',
    requestedPeriod: _s(m['requested_period']),
    period: _period(m['period']),
    availablePeriods: _periods(m['available_periods']),
    layoutMode: _layout(m['layout_mode']),
    resultsFinalized: _b(m['results_finalized']),
    awardsSeason: _s(m['awards_season']),
    goodPower: metric(100, 'good_power'),
    games: metric(0, 'games'),
    goodPowerPerGame: metric(0, 'good_power_per_game'),
    goodEnergy: metric(0, 'good_energy'),
    goodEnergyPerGame: metric(0, 'good_energy_per_game'),
    sponsoredGames: metric(0, 'sponsored_games'),
    allTimeRank: _i(places['all_time_good_power']),
    allTimeGoodPower: 100,
    allTimeGamesCount: 0,
    awards: const [],
    awardFlags: GgAwardFlagsStruct(),
    totalGoodPower: _d(m['total_good_power']),
    totalGoodPowerAllTime: _d(m['total_good_power_all_time']),
    test: _b(m['test']),
    signupBonusMigrated: _b(m['signup_bonus_migrated']),
    legacyBonusUsersCount: _i(m['legacy_bonus_users_count']),
  );
}
