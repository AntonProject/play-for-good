// Custom Action ggLoadGames. Returns the Data Type GgGamesEntry.
// Keep FF automatic imports above this code.
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';

Future<GgGamesEntryStruct> ggLoadGames(
  String userId,
  String period,
  String category,
  int page,
  int pageSize,
  bool test,
) async {
  // gg_v2_games: meta parsed into GgGamesPage; games stay rows of the games
  // table (read with ggGamesOf as GamesRow). key is set by ggGamesToCache.
  if (userId == 'guest' || userId.isEmpty) {
    throw ArgumentError('A registered userId is required');
  }
  if (page < 1 || pageSize < 1 || pageSize > 100) {
    throw ArgumentError('page >= 1 and pageSize 1..100 required');
  }
  final result = await SupaFlow.client.rpc(
    'gg_v2_games',
    params: {
      'p_user_id': userId,
      'p_period': period,
      'p_test': test,
      'p_category': category,
      'p_page': page,
      'p_page_size': pageSize,
    },
  );
  if (result is! Map) throw StateError('Invalid games response');
  return GgGamesEntryStruct(
    key: '',
    savedAt: DateTime.now(),
    version: 1,
    meta: _gamesPage(result),
    games: [
      for (final g in _l(result['games']))
        if (g is Map) Map<String, dynamic>.from(g)
    ],
  );
}

// --- JSON -> Data Types (gg_v2 RPC response, see docs/gg_logic/TYPED_SCHEMA.md)
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

GgGamesPageStruct _gamesPage(Map m) {
  final pagination = _m(m['pagination']);
  return GgGamesPageStruct(
    userId: _s(m['user_id']),
    requestedPeriod: _s(m['requested_period']),
    requestedCategory: _s(m['requested_category']),
    period: _period(m['period']),
    availablePeriods: _periods(m['available_periods']),
    category: _e(GgCategory.values, m['category']),
    layoutMode: _layout(m['layout_mode']),
    resultsFinalized: _b(m['results_finalized']),
    awardsSeason: _s(m['awards_season']),
    page: _i(pagination['page']),
    pageSize: _i(pagination['page_size']),
    hasMore: _b(pagination['has_more']),
    test: _b(m['test']),
    signupBonusMigrated: _b(m['signup_bonus_migrated']),
    legacyBonusUsersCount: _i(m['legacy_bonus_users_count']),
  );
}
