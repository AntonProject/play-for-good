// Equivalence test (15.10.2026): the removed JSON helpers vs the typed ones on
// real gg_v2 RPC responses (old_vs_typed_responses.json, local fixture DB).
// Run inside a FlutterFlow export: copy to test/, set GG_EQ_DATA to the JSON.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:players_for_good/backend/schema/structs/index.dart';
import 'package:players_for_good/backend/schema/enums/enums.dart';
import 'package:players_for_good/backend/supabase/supabase.dart';
double ggHomeGauge(dynamic ranking, String part) {
  // Home gauge from the ranking RPC, same formulas as totalSumMAX/totalSumAVG:
  //  max  - the largest period total among users (0 without activity);
  //  mine - the signed-in user's period total (guest 0);
  //  avg  - (sum of all totals - mine) / (all users - 1), 0 if max is 0
  //         or there are no other users (inactive users count as 0).
  if (ranking is! Map) return 0;
  double toD(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
  final top = ranking['top_players'];
  final max = ranking.containsKey('max_good_power')
      ? toD(ranking['max_good_power'])
      : (top is List && top.isNotEmpty && top.first is Map)
          ? toD((top.first as Map)['good_power'])
          : 0.0;
  final me = ranking['current_user'];
  final mine = me is Map ? toD(me['good_power']) : 0.0;
  switch (part) {
    case 'max':
      return max;
    case 'mine':
      return mine;
    case 'avg':
      if (max == 0) return 0;
      final others = toD(ranking['legacy_bonus_users_count']) - 1;
      if (others <= 0) return 0;
      return (toD(ranking['total_good_power']) - mine) / others;
  }
  return 0;
}
int ggPlace(dynamic ranking) {
  // One place for Home, profile and Good Games.
  // Signed-in: own rank; with no points yet - right after all ranked players.
  // Guest (no current_user): the place of the demo 100 points (guest_rank).
  if (ranking is! Map) return 0;
  int? asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v');
  final me = ranking['current_user'];
  if (me is Map) {
    final rank = asInt(me['rank']);
    if (rank != null && rank > 0) return rank;
    final page = ranking['pagination'];
    final total = page is Map ? asInt(page['total_count']) : null;
    return (total ?? 0) + 1;
  }
  return asInt(ranking['guest_rank']) ?? 0;
}
List<String> ggRankingPlayerIds(dynamic ranking) {
  if (ranking is! Map) return [];
  return (ranking['players'] as List? ?? [])
      .whereType<Map>()
      .map((p) => p['user_id'])
      .whereType<String>()
      .toList();
}
List<String> ggTopPlayerIds(dynamic ranking) {
  // Podium user ids (places 1..3) independent of the list page.
  if (ranking is! Map || ranking['top_players'] is! List) return [];
  return (ranking['top_players'] as List)
      .whereType<Map>()
      .map((p) => '${p['user_id'] ?? ''}')
      .where((id) => id.isNotEmpty)
      .toList();
}
dynamic ggPlayerRow(dynamic ranking, String? userId) {
  if (ranking is! Map || userId == null || userId.isEmpty) {
    return <String, dynamic>{};
  }
  if (ranking['user_id'] == userId) return Map<String, dynamic>.from(ranking);
  final selected = ranking['current_user'];
  if (selected is Map && selected['user_id'] == userId) {
    return Map<String, dynamic>.from(selected);
  }
  for (final key in ['players', 'top_players']) {
    for (final row in ranking[key] as List? ?? []) {
      if (row is Map && row['user_id'] == userId) {
        return Map<String, dynamic>.from(row);
      }
    }
  }
  return <String, dynamic>{};
}
int ggMetricRank(dynamic response, String metric, bool allTime) {
  if (response is! Map) return 0;
  dynamic value;
  if (allTime) {
    final header = response['all_time'];
    if (header is Map) value = header['rank'];
  } else if (response['stats'] is Map) {
    final item = (response['stats'] as Map)[metric];
    if (item is Map) value = item['rank'];
  } else {
    value = response['rank'];
  }
  return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
double ggMetricValue(dynamic response, String metric, bool allTime) {
  if (response is! Map) return 0;
  dynamic value;
  if (allTime) {
    final header = response['all_time'];
    if (header is Map) value = header[metric];
  } else if (response['stats'] is Map) {
    final item = (response['stats'] as Map)[metric];
    if (item is Map) value = item['value'];
  } else {
    value = response[metric];
  }
  return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}
bool ggShowMeRow(dynamic ranking) {
  // Pinned "me" row: the signed-in user has a place but is not on this page.
  if (ranking is! Map) return false;
  final me = ranking['current_user'];
  if (me is! Map || me['user_id'] == null || me['rank'] == null) return false;
  final players = ranking['players'];
  if (players is! List) return true;
  return !players.whereType<Map>().any((p) => p['user_id'] == me['user_id']);
}
bool ggShowFinalPlace(
    dynamic ranking, dynamic player, String category, int place) {
  // Podium of a completed season: medal/flame by the player's place in the
  // selected season and category. Row medals use ggHasAward instead.
  if (ranking is! Map || player is! Map || place < 1 || place > 3) return false;
  final period = ranking['period'];
  final isFinal = ranking['layout_mode'] != null
      ? ranking['layout_mode'] == 'final'
      : period is Map &&
          period['season_year'] != null &&
          period['is_completed'] == true;
  final wanted = category == 'mvp'
      ? 'valuable'
      : category == 'map'
          ? 'active'
          : category;
  final rank = player['rank'] is num
      ? (player['rank'] as num).toInt()
      : int.tryParse('${player['rank']}');
  return isFinal && ranking['category'] == wanted && rank == place;
}
bool ggShowCurrentPlace(
    dynamic ranking, dynamic player, String category, int place) {
  if (ranking is! Map || player is! Map || place < 1 || place > 3) return false;
  final period = ranking['period'];
  final isFinal = ranking['layout_mode'] != null
      ? ranking['layout_mode'] == 'final'
      : period is Map &&
          period['season_year'] != null &&
          period['is_completed'] == true;
  final wanted = category == 'mvp'
      ? 'valuable'
      : category == 'map'
          ? 'active'
          : category;
  final rank = player['rank'] is num
      ? (player['rank'] as num).toInt()
      : int.tryParse('${player['rank']}');
  return !isFinal && ranking['category'] == wanted && rank == place;
}
bool ggIsFinalSeason(dynamic ranking) {
  if (ranking is! Map) return false;
  if (ranking['layout_mode'] != null) return ranking['layout_mode'] == 'final';
  final period = ranking['period'];
  return period is Map &&
      period['season_year'] != null &&
      period['is_completed'] == true;
}
bool ggIsLastPlayer(dynamic ranking, dynamic player) {
  // True for the last row of the loaded ranking page: no divider under it.
  if (ranking is! Map || player is! Map) return false;
  final players = ranking['players'];
  if (players is! List || players.isEmpty) return false;
  final last = players.last;
  return last is Map && last['user_id'] != null && last['user_id'] == player['user_id'];
}
String ggRowStyle(dynamic ranking, dynamic player) {
  if (ranking is! Map || player is! Map) return 'none';
  final rank = player['rank'] is num
      ? (player['rank'] as num).toInt()
      : int.tryParse('${player['rank']}');
  if (rank == null || rank < 1 || rank > 3) return 'none';
  final period = ranking['period'];
  final isFinal = ranking['layout_mode'] != null
      ? ranking['layout_mode'] == 'final'
      : period is Map &&
          period['season_year'] != null &&
          period['is_completed'] == true;
  final ordinal = {1: 'first', 2: 'second', 3: 'third'}[rank];
  return '${isFinal ? 'final' : 'current'}_$ordinal';
}
bool ggHasAward(dynamic player, String category, int place, String? season) {
  if (player is! Map || place < 1 || place > 3) return false;
  final wantedCategory = category == 'mvp'
      ? 'valuable'
      : category == 'map'
          ? 'active'
          : category;
  const aliases = {
    'season_25_26': 'season_2025_26',
    'season_26_27': 'season_2026_27'
  };
  final wantedSeason = aliases[season] ?? season;
  final awards = player['awards'] is List ? player['awards'] as List : player.containsKey('category') ? [player] : [];
  for (final award in awards) {
    if (award is! Map) continue;
    final rank = award['place'] is num
        ? (award['place'] as num).toInt()
        : int.tryParse('${award['place']}');
    if (award['category'] == wantedCategory &&
        rank == place &&
        (wantedSeason == null ||
            wantedSeason.isEmpty ||
            award['season'] == wantedSeason)) {
      return true;
    }
  }
  return false;
}
String ggTopPlayerPhoto(dynamic ranking, int index) {
  // Podium avatar (index 0..2) straight from the ranking RPC; '' -> default image.
  if (ranking is! Map || ranking['top_players'] is! List) return '';
  final top = (ranking['top_players'] as List).whereType<Map>().toList();
  if (index < 0 || index >= top.length) return '';
  return '${top[index]['photo_url'] ?? ''}';
}
String ggMyPhoto(dynamic ranking) {
  // Signed-in user's avatar from the ranking RPC; guest/no photo -> '' (default image).
  if (ranking is! Map) return '';
  final me = ranking['current_user'];
  if (me is! Map) return '';
  return '${me['photo_url'] ?? ''}';
}
double ggTotalPower(dynamic response) {
  if (response is! Map) return 0;
  final value = response['total_good_power_all_time'];
  return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}
bool ggHasGames(dynamic stats) {
  // Signed-in user has completed games (all time), from ggV2ProfileStats.
  if (stats is! Map || stats['all_time'] is! Map) return false;
  final n = (stats['all_time'] as Map)['games_count'];
  return (n is num ? n : num.tryParse('$n') ?? 0) > 0;
}
bool ggHasMore(dynamic response) {
  // Next page exists for a paginated v2 response (ranking or games history).
  if (response is! Map) return false;
  final page = response['pagination'];
  return page is Map && page['has_more'] == true;
}
List<String> ggPeriodOptions(
  dynamic response,
  bool withWeek,
) {
  // Period filter options. Seasons come from the server calendar
  // (response.available_periods = gg_v2.seasons): 'auto' = the current season,
  // then the seasons that already started, newest first; then the fixed periods.
  final now = DateTime.now().toUtc();
  DateTime? at(dynamic v) {
    if (v is! String || v.isEmpty) return null;
    final s = v.endsWith('Z') || v.contains('+') ? v : '${v}Z';
    return DateTime.tryParse(s)?.toUtc();
  }
  final started = <Map>[];
  var hasCurrent = false;
  final periods = response is Map ? response['available_periods'] : null;
  for (final p in (periods is List ? periods : const [])) {
    if (p is! Map || p['key'] is! String) continue;
    // available_periods also lists last_month / this_month / all_time.
    if (!(p['key'] as String).startsWith('season_')) continue;
    final start = at(p['period_start']);
    final end = at(p['period_end_exclusive']);
    if (start == null || start.isAfter(now)) continue;
    if (end != null && now.isBefore(end)) {
      hasCurrent = true;
    } else {
      started.add(p);
    }
  }
  started.sort((a, b) => '${b['period_start']}'.compareTo('${a['period_start']}'));
  return [
    if (hasCurrent || started.isEmpty) 'auto',
    for (final p in started) p['key'] as String,
    'last_month',
    'this_month',
    if (withWeek) 'this_week',
    'all_time',
  ];
}
List<String> ggPeriodOptionLabels(
  dynamic response,
  bool withWeek,
) {
  // Labels for ggPeriodOptions (same order). Season names come from
  // gg_v2.seasons.label; 'auto' shows the current season's name.
  final now = DateTime.now().toUtc();
  DateTime? at(dynamic v) {
    if (v is! String || v.isEmpty) return null;
    final s = v.endsWith('Z') || v.contains('+') ? v : '${v}Z';
    return DateTime.tryParse(s)?.toUtc();
  }
  String? current;
  final started = <Map>[];
  final periods = response is Map ? response['available_periods'] : null;
  for (final p in (periods is List ? periods : const [])) {
    if (p is! Map || p['key'] is! String) continue;
    // available_periods also lists last_month / this_month / all_time.
    if (!(p['key'] as String).startsWith('season_')) continue;
    final start = at(p['period_start']);
    final end = at(p['period_end_exclusive']);
    if (start == null || start.isAfter(now)) continue;
    if (end != null && now.isBefore(end)) {
      current = '${p['label'] ?? 'Saison'}';
    } else {
      started.add(p);
    }
  }
  started.sort((a, b) => '${b['period_start']}'.compareTo('${a['period_start']}'));
  return [
    if (current != null || started.isEmpty) current ?? 'Saison',
    for (final p in started) '${p['label'] ?? p['key']}',
    'Letzten Monat',
    'Diesen Monat',
    if (withWeek) 'Diese Woche',
    'All-Time',
  ];
}
List<String> ggSeasonOptions(dynamic response) {
  // Seasons for the Good Games filter: the current season, then the seasons
  // that already started, newest first (gg_v2.seasons via the RPC). Real keys,
  // so they compare with the key GoodGamesPage keeps after loading.
  final now = DateTime.now().toUtc();
  DateTime? at(dynamic v) {
    if (v is! String || v.isEmpty) return null;
    final s = v.endsWith('Z') || v.contains('+') ? v : '${v}Z';
    return DateTime.tryParse(s)?.toUtc();
  }
  final started = <Map>[];
  String? current;
  final periods = response is Map ? response['available_periods'] : null;
  for (final p in (periods is List ? periods : const [])) {
    if (p is! Map || p['key'] is! String) continue;
    // available_periods also lists last_month / this_month / all_time.
    if (!(p['key'] as String).startsWith('season_')) continue;
    final start = at(p['period_start']);
    final end = at(p['period_end_exclusive']);
    if (start == null || start.isAfter(now)) continue;
    if (end != null && now.isBefore(end)) {
      current = p['key'] as String;
    } else {
      started.add(p);
    }
  }
  started.sort((a, b) => '${b['period_start']}'.compareTo('${a['period_start']}'));
  return [
    if (current != null) current else if (started.isEmpty) 'auto',
    for (final p in started) p['key'] as String,
  ];
}
String ggPeriodName(
  String? value,
  dynamic response,
) {
  // Display name of a period option: seasons from gg_v2.seasons.label
  // ('auto' = the current season), fixed periods by their German names.
  var key = (value ?? 'auto').trim().toLowerCase().replaceFirst('period.', '');
  const aliases = {
    '': 'auto',
    'saison': 'auto',
    'gesamt': 'all_time',
    'all-time': 'all_time',
    'monat': 'this_month',
    'woche': 'this_week',
    'diese_woche': 'this_week',
    'dieser_monat': 'this_month',
    'letzter_monat': 'last_month',
    'season_26_27': 'season_2026_27',
    'season_25_26': 'season_2025_26',
  };
  key = aliases[key] ?? key;
  final now = DateTime.now().toUtc();
  DateTime? at(dynamic v) {
    if (v is! String || v.isEmpty) return null;
    final s = v.endsWith('Z') || v.contains('+') ? v : '${v}Z';
    return DateTime.tryParse(s)?.toUtc();
  }
  final periods = response is Map ? response['available_periods'] : null;
  for (final p in (periods is List ? periods : const [])) {
    if (p is! Map || p['label'] is! String) continue;
    if (key == 'auto') {
      // available_periods also lists last_month / this_month / all_time.
      if (!'${p['key']}'.startsWith('season_')) continue;
      final start = at(p['period_start']);
      final end = at(p['period_end_exclusive']);
      if (start != null && end != null && !start.isAfter(now) && now.isBefore(end)) {
        return p['label'] as String;
      }
    } else if (p['key'] == key) {
      return p['label'] as String;
    }
  }
  const labels = {
    'auto': 'Saison',
    'all_time': 'All-Time',
    'this_month': 'Diesen Monat',
    'this_week': 'Diese Woche',
    'last_month': 'Letzten Monat',
  };
  return labels[key] ?? key;
}
bool ggPeriodSame(
  String? a,
  String? b,
  dynamic response,
) {
  // True when two period values mean the same period: old app keys
  // (season_26_27, gesamt, ...) are normalized and 'auto' is the current
  // season from response.available_periods.
  final now = DateTime.now().toUtc();
  DateTime? at(dynamic v) {
    if (v is! String || v.isEmpty) return null;
    final s = v.endsWith('Z') || v.contains('+') ? v : '${v}Z';
    return DateTime.tryParse(s)?.toUtc();
  }
  String norm(String? value) {
    var key = (value ?? 'auto').trim().toLowerCase().replaceFirst('period.', '');
    const aliases = {
      '': 'auto',
      'saison': 'auto',
      'gesamt': 'all_time',
      'all-time': 'all_time',
      'monat': 'this_month',
      'woche': 'this_week',
      'diese_woche': 'this_week',
      'dieser_monat': 'this_month',
      'letzter_monat': 'last_month',
      'season_26_27': 'season_2026_27',
      'season_25_26': 'season_2025_26',
    };
    key = aliases[key] ?? key;
    if (key != 'auto') return key;
    final periods = response is Map ? response['available_periods'] : null;
    for (final p in (periods is List ? periods : const [])) {
      if (p is! Map || p['key'] is! String) continue;
      // available_periods also lists last_month / this_month / all_time.
      if (!(p['key'] as String).startsWith('season_')) continue;
      final start = at(p['period_start']);
      final end = at(p['period_end_exclusive']);
      if (start != null && end != null && !start.isAfter(now) && now.isBefore(end)) {
        return p['key'] as String;
      }
    }
    return 'auto';
  }
  return norm(a) == norm(b);
}
String ggPeriodLabel(String? value, dynamic response) {
  var key = (value ?? 'auto').trim().toLowerCase().replaceFirst('period.', '');
  const aliases = {
    '': 'auto',
    'saison': 'auto',
    'gesamt': 'all_time',
    'all-time': 'all_time',
    'monat': 'this_month',
    'woche': 'this_week',
    'diese_woche': 'this_week',
    'dieser_monat': 'this_month',
    'letzter_monat': 'last_month',
    'season_26_27': 'season_2026_27',
    'season_25_26': 'season_2025_26',
    'saison_2026_27': 'season_2026_27',
    'saison_2025_26': 'season_2025_26',
  };
  key = aliases[key] ?? key;
  if (response is Map) {
    final selected = response['period'];
    if (selected is Map && (key == 'auto' || selected['key'] == key)) {
      final label = selected['label'];
      if (label is String && label.isNotEmpty) return label;
    }
    for (final period in response['available_periods'] as List? ?? []) {
      if (period is Map && period['key'] == key && period['label'] is String) {
        return period['label'] as String;
      }
    }
  }
  const labels = {
    'auto': 'Saison',
    'season_2026_27': 'Saison 2026/27',
    'season_2025_26': 'Saison 2025/26',
    'all_time': 'All-Time',
    'this_month': 'Diesen Monat',
    'this_week': 'Diese Woche',
    'last_month': 'Letzten Monat',
  };
  return labels[key] ?? key;
}
bool ggHasData(dynamic response) {
  return response is Map && (response['period'] is Map ||
      response['user_id'] is String && (response['user_id'] as String).isNotEmpty);
}
// Custom Function ggGamesRows. response JSON optional. Return List<GamesRow>
// (Supabase row type games). Converts only the already paginated response.

List<GamesRow> ggGamesRows(dynamic response) {
  if (response is! Map || response['games'] is! List) return [];
  return (response['games'] as List)
      .map((row) => GamesRow(Map<String, dynamic>.from(row as Map)))
      .toList();
}

GgGamesEntryStruct? ggGamesFromCache(
  List<GgGamesEntryStruct>? cache,
  String key,
) {
  // Cached games page for this key; other schema versions are ignored.
  for (final e in cache ?? <GgGamesEntryStruct>[]) {
    if (e.key == key && e.version == 1) return e;
  }
  return null;
}

bool ggGamesLoaded(GgGamesEntryStruct? entry) {
  // A games page arrived (from the server or the cache).
  return entry != null && entry.hasMeta();
}

List<GamesRow> ggGamesOf(GgGamesEntryStruct? entry) {
  // Games of a loaded / cached page as rows of the games table.
  return [
    for (final g in entry?.games ?? <dynamic>[])
      if (g is Map) GamesRow(Map<String, dynamic>.from(g))
  ];
}

GgGamesEntryStruct ggGamesOrEmpty(GgGamesEntryStruct? entry) {
  // Not loaded yet -> an empty value (0 / '' / false), so a field can be read
  // without a null check on the first frame.
  return entry ?? GgGamesEntryStruct();
}

List<GgGamesEntryStruct> ggGamesToCache(
  List<GgGamesEntryStruct>? cache,
  String key,
  GgGamesEntryStruct? entry,
) {
  // Puts the games page first under this key (replacing it); keeps the last 30.
  final rest = [
    for (final e in cache ?? <GgGamesEntryStruct>[])
      if (e.key != key && e.version == 1) e
  ];
  if (entry == null) return rest.take(30).toList();
  return [
    GgGamesEntryStruct(
      key: key,
      savedAt: DateTime.now(),
      version: 1,
      meta: entry.meta,
      games: entry.games,
    ),
    ...rest,
  ].take(30).toList();
}

bool ggHasAwardOf(
  List<GgAwardStruct>? awards,
  String category,
  int place,
  String? season,
) {
  // The awards contain this category / place (of one season, or any).
  if (place < 1 || place > 3) return false;
  final wantedCategory = category == 'mvp'
      ? 'valuable'
      : category == 'map'
          ? 'active'
          : category;
  const aliases = {
    'season_25_26': 'season_2025_26',
    'season_26_27': 'season_2026_27'
  };
  final wantedSeason = aliases[season] ?? season;
  return (awards ?? <GgAwardStruct>[]).any((a) =>
      a.category?.name == wantedCategory &&
      a.place == place &&
      (wantedSeason == null || wantedSeason.isEmpty || a.season == wantedSeason));
}

bool ggHasGamesOf(GgProfileStatsStruct? stats) {
  // The user has completed games (all time).
  return (stats?.allTimeGamesCount ?? 0) > 0;
}

double ggHomeGaugeOf(
  GgRankingStruct? ranking,
  String part,
) {
  // Home gauge, same formulas as totalSumMAX/totalSumAVG:
  //  max  - the largest period total among users (0 without activity);
  //  mine - the signed-in user's period total (guest 0);
  //  avg  - (sum of all totals - mine) / (all users - 1), 0 if max is 0
  //         or there are no other users (inactive users count as 0).
  if (ranking == null) return 0;
  final max = ranking.hasMaxGoodPower()
      ? ranking.maxGoodPower
      : ranking.topPlayers.isNotEmpty
          ? ranking.topPlayers.first.goodPower
          : 0.0;
  final mine = ranking.hasCurrentUser() ? ranking.currentUser.goodPower : 0.0;
  switch (part) {
    case 'max':
      return max;
    case 'mine':
      return mine;
    case 'avg':
      if (max == 0) return 0;
      final others = ranking.legacyBonusUsersCount - 1;
      if (others <= 0) return 0;
      return (ranking.totalGoodPower - mine) / others;
  }
  return 0;
}

bool ggIsFinalOf(GgRankingStruct? ranking) {
  // A closed season is shown (frozen results, medals).
  return ranking?.layoutMode == GgLayoutMode.finished;
}

bool ggIsLastPlayerOf(
  GgRankingStruct? ranking,
  GgPlayerStruct? player,
) {
  // True for the last row of the loaded ranking page: no divider under it.
  if (ranking == null || player == null || ranking.players.isEmpty) return false;
  final last = ranking.players.last;
  return last.userId.isNotEmpty && last.userId == player.userId;
}

String ggPeriodLabelOf(
  String? value,
  GgPeriodStruct? period,
  List<GgPeriodStruct>? available,
) {
  // Name of the selected period: the loaded period when it matches,
  // otherwise from the available periods, otherwise a fixed German name.
  var key = (value ?? 'auto').trim().toLowerCase().replaceFirst('period.', '');
  const aliases = {
    '': 'auto',
    'saison': 'auto',
    'gesamt': 'all_time',
    'all-time': 'all_time',
    'monat': 'this_month',
    'woche': 'this_week',
    'diese_woche': 'this_week',
    'dieser_monat': 'this_month',
    'letzter_monat': 'last_month',
    'season_26_27': 'season_2026_27',
    'season_25_26': 'season_2025_26',
    'saison_2026_27': 'season_2026_27',
    'saison_2025_26': 'season_2025_26',
  };
  key = aliases[key] ?? key;
  if (period != null && (key == 'auto' || period.key == key) && period.label.isNotEmpty) {
    return period.label;
  }
  for (final p in available ?? <GgPeriodStruct>[]) {
    if (p.key == key && p.label.isNotEmpty) return p.label;
  }
  const labels = {
    'auto': 'Saison',
    'all_time': 'All-Time',
    'this_month': 'Diesen Monat',
    'this_week': 'Diese Woche',
    'last_month': 'Letzten Monat',
  };
  return labels[key] ?? key;
}

String ggPeriodNameOf(
  String? value,
  List<GgPeriodStruct>? periods,
) {
  // Display name of a period option: seasons from gg_v2.seasons.label
  // ('auto' = the current season), fixed periods by their German names.
  var key = (value ?? 'auto').trim().toLowerCase().replaceFirst('period.', '');
  const aliases = {
    '': 'auto',
    'saison': 'auto',
    'gesamt': 'all_time',
    'all-time': 'all_time',
    'monat': 'this_month',
    'woche': 'this_week',
    'diese_woche': 'this_week',
    'dieser_monat': 'this_month',
    'letzter_monat': 'last_month',
    'season_26_27': 'season_2026_27',
    'season_25_26': 'season_2025_26',
  };
  key = aliases[key] ?? key;
  final now = DateTime.now().toUtc();
  for (final p in periods ?? <GgPeriodStruct>[]) {
    if (p.label.isEmpty) continue;
    if (key == 'auto') {
      if (!p.key.startsWith('season_')) continue;
      if (p.start != null && p.endExclusive != null && !p.start!.isAfter(now) && now.isBefore(p.endExclusive!)) {
        return p.label;
      }
    } else if (p.key == key) {
      return p.label;
    }
  }
  const labels = {
    'auto': 'Saison',
    'all_time': 'All-Time',
    'this_month': 'Diesen Monat',
    'this_week': 'Diese Woche',
    'last_month': 'Letzten Monat',
  };
  return labels[key] ?? key;
}

List<String> ggPeriodOptionLabelsOf(
  List<GgPeriodStruct>? periods,
  bool withWeek,
) {
  // Labels for ggPeriodOptionsOf (same order); season names from
  // gg_v2.seasons.label, 'auto' shows the current season's name.
  final now = DateTime.now().toUtc();
  String? current;
  final started = <GgPeriodStruct>[];
  for (final p in periods ?? <GgPeriodStruct>[]) {
    // available periods also list last_month / this_month / all_time.
    if (!p.key.startsWith('season_') || p.start == null) continue;
    if (p.start!.isAfter(now)) continue;
    if (p.endExclusive != null && now.isBefore(p.endExclusive!)) {
      current = p.label;
    } else {
      started.add(p);
    }
  }
  started.sort((a, b) => b.start!.compareTo(a.start!));
  return [
    if (current != null || started.isEmpty) current ?? 'Saison',
    for (final p in started) p.label.isNotEmpty ? p.label : p.key,
    'Letzten Monat',
    'Diesen Monat',
    if (withWeek) 'Diese Woche',
    'All-Time',
  ];
}

List<String> ggPeriodOptionsOf(
  List<GgPeriodStruct>? periods,
  bool withWeek,
) {
  // Period filter options: 'auto' = the current season, then the seasons
  // that already started, newest first (gg_v2.seasons); then the fixed periods.
  final now = DateTime.now().toUtc();
  String? current;
  final started = <GgPeriodStruct>[];
  for (final p in periods ?? <GgPeriodStruct>[]) {
    // available periods also list last_month / this_month / all_time.
    if (!p.key.startsWith('season_') || p.start == null) continue;
    if (p.start!.isAfter(now)) continue;
    if (p.endExclusive != null && now.isBefore(p.endExclusive!)) {
      current = p.label;
    } else {
      started.add(p);
    }
  }
  started.sort((a, b) => b.start!.compareTo(a.start!));
  return [
    if (current != null || started.isEmpty) 'auto',
    for (final p in started) p.key,
    'last_month',
    'this_month',
    if (withWeek) 'this_week',
    'all_time',
  ];
}

bool ggPeriodSameOf(
  String? a,
  String? b,
  List<GgPeriodStruct>? periods,
) {
  // True when two period values mean the same period: old app keys are
  // normalized and 'auto' is the current season.
  final now = DateTime.now().toUtc();
  String norm(String? value) {
    var key = (value ?? 'auto').trim().toLowerCase().replaceFirst('period.', '');
    const aliases = {
      '': 'auto',
      'saison': 'auto',
      'gesamt': 'all_time',
      'all-time': 'all_time',
      'monat': 'this_month',
      'woche': 'this_week',
      'diese_woche': 'this_week',
      'dieser_monat': 'this_month',
      'letzter_monat': 'last_month',
      'season_26_27': 'season_2026_27',
      'season_25_26': 'season_2025_26',
    };
    key = aliases[key] ?? key;
    if (key != 'auto') return key;
    for (final p in periods ?? <GgPeriodStruct>[]) {
      if (!p.key.startsWith('season_')) continue;
      if (p.start != null && p.endExclusive != null && !p.start!.isAfter(now) && now.isBefore(p.endExclusive!)) {
        return p.key;
      }
    }
    return 'auto';
  }
  return norm(a) == norm(b);
}

List<String> ggPlayerIdsOf(List<GgPlayerStruct>? players) {
  // User ids of ranking rows (players or topPlayers), in order.
  return [
    for (final p in players ?? <GgPlayerStruct>[])
      if (p.userId.isNotEmpty) p.userId
  ];
}

bool ggPlayerLoaded(GgPlayerStruct? player) {
  // A real ranking row (not the empty placeholder).
  return player != null && player.userId.isNotEmpty;
}

GgPlayerStruct ggPlayerOf(
  GgRankingStruct? ranking,
  String? userId,
) {
  // Ranking row of this user (current user, page or top); empty when absent.
  if (ranking == null || userId == null || userId.isEmpty) return GgPlayerStruct();
  if (ranking.hasCurrentUser() && ranking.currentUser.userId == userId) {
    return ranking.currentUser;
  }
  for (final p in [...ranking.players, ...ranking.topPlayers]) {
    if (p.userId == userId) return p;
  }
  return GgPlayerStruct();
}

GgPlayerStruct ggPlayerOrEmpty(GgPlayerStruct? player) {
  // Not loaded yet -> an empty value (0 / '' / false), so a field can be read
  // without a null check on the first frame.
  return player ?? GgPlayerStruct();
}

GgRankingStruct? ggRankingFromCache(
  List<GgRankingEntryStruct>? cache,
  String key,
) {
  // Cached ranking for this key; entries of another schema version are ignored.
  for (final e in cache ?? <GgRankingEntryStruct>[]) {
    if (e.key == key && e.version == 1 && e.hasData()) return e.data;
  }
  return null;
}

bool ggRankingLoaded(GgRankingStruct? ranking) {
  // Ranking arrived (from the server or the cache).
  return ranking != null && ranking.hasPeriod();
}

GgRankingStruct ggRankingOrEmpty(GgRankingStruct? ranking) {
  // Not loaded yet -> an empty value (0 / '' / false), so a field can be read
  // without a null check on the first frame.
  return ranking ?? GgRankingStruct();
}

int ggRankingPlace(GgRankingStruct? ranking) {
  // One place for Home, profile and Good Games.
  // Signed-in: own rank; with no points yet - right after all ranked players.
  // Guest (no currentUser): the place of the demo 100 points (guestRank).
  if (ranking == null) return 0;
  if (ranking.hasCurrentUser()) {
    final me = ranking.currentUser;
    if (me.hasRank() && me.rank > 0) return me.rank;
    return ranking.totalCount + 1;
  }
  return ranking.guestRank;
}

List<GgRankingEntryStruct> ggRankingToCache(
  List<GgRankingEntryStruct>? cache,
  String key,
  GgRankingStruct? data,
) {
  // Puts the ranking first (replacing the same key); keeps the last 30.
  final rest = [
    for (final e in cache ?? <GgRankingEntryStruct>[])
      if (e.key != key && e.version == 1) e
  ];
  if (data == null) return rest.take(30).toList();
  return [
    GgRankingEntryStruct(key: key, savedAt: DateTime.now(), version: 1, data: data),
    ...rest,
  ].take(30).toList();
}

String ggRowStyleOf(
  GgRankingStruct? ranking,
  GgPlayerStruct? player,
) {
  // Row look of places 1-3: final_first .. current_third; 'none' otherwise.
  if (ranking == null || player == null || !player.hasRank()) return 'none';
  final rank = player.rank;
  if (rank < 1 || rank > 3) return 'none';
  final isFinal = ranking.layoutMode == GgLayoutMode.finished;
  final ordinal = {1: 'first', 2: 'second', 3: 'third'}[rank];
  return '${isFinal ? 'final' : 'current'}_$ordinal';
}

List<String> ggSeasonOptionsOf(List<GgPeriodStruct>? periods) {
  // Seasons for the Good Games filter: the current season, then the seasons
  // that already started, newest first (gg_v2.seasons). Real keys.
  final now = DateTime.now().toUtc();
  String? current;
  final started = <GgPeriodStruct>[];
  for (final p in periods ?? <GgPeriodStruct>[]) {
    // available periods also list last_month / this_month / all_time.
    if (!p.key.startsWith('season_') || p.start == null) continue;
    if (p.start!.isAfter(now)) continue;
    if (p.endExclusive != null && now.isBefore(p.endExclusive!)) {
      current = p.key;
    } else {
      started.add(p);
    }
  }
  started.sort((a, b) => b.start!.compareTo(a.start!));
  return [
    if (current != null) current else if (started.isEmpty) 'auto',
    for (final p in started) p.key,
  ];
}

bool ggShowCurrentPlaceOf(
  GgRankingStruct? ranking,
  GgPlayerStruct? player,
  String category,
  int place,
) {
  // Place badge of a top player in the current layout of this category.
  if (ranking == null || player == null || place < 1 || place > 3) return false;
  final isFinal = ranking.layoutMode == GgLayoutMode.finished;
  final wanted = category == 'mvp'
      ? 'valuable'
      : category == 'map'
          ? 'active'
          : category;
  return !isFinal &&
      ranking.category?.name == wanted &&
      player.hasRank() &&
      player.rank == place;
}

bool ggShowFinalPlaceOf(
  GgRankingStruct? ranking,
  GgPlayerStruct? player,
  String category,
  int place,
) {
  // Place badge of a top player in the final layout of this category.
  if (ranking == null || player == null || place < 1 || place > 3) return false;
  final isFinal = ranking.layoutMode == GgLayoutMode.finished;
  final wanted = category == 'mvp'
      ? 'valuable'
      : category == 'map'
          ? 'active'
          : category;
  return isFinal &&
      ranking.category?.name == wanted &&
      player.hasRank() &&
      player.rank == place;
}

bool ggShowMeRowOf(GgRankingStruct? ranking) {
  // Own row under the list: signed in, ranked and not on the loaded page.
  if (ranking == null || !ranking.hasCurrentUser()) return false;
  final me = ranking.currentUser;
  if (me.userId.isEmpty || !me.hasRank()) return false;
  return !ranking.players.any((p) => p.userId == me.userId);
}

List<GgAwardStruct> ggSortAwards(
  List<GgAwardStruct>? awards,
  String? season,
) {
  // Awards of one season (all when season is empty): MVP first, then MAP,
  // newest season first, then by badge.
  const aliases = {
    'season_25_26': 'season_2025_26',
    'season_26_27': 'season_2026_27'
  };
  final wanted = aliases[season] ?? season;
  int order(GgCategory? c) => c == GgCategory.valuable
      ? 0
      : c == GgCategory.active
          ? 1
          : 2;
  final result = [
    for (final a in awards ?? <GgAwardStruct>[])
      if (wanted == null || wanted.isEmpty || a.season == wanted) a
  ];
  result.sort((a, b) {
    final category = order(a.category).compareTo(order(b.category));
    if (category != 0) return category;
    final start = (b.seasonStart ?? DateTime(b.seasonYear))
        .compareTo(a.seasonStart ?? DateTime(a.seasonYear));
    if (start != 0) return start;
    return '${a.badge?.name}'.compareTo('${b.badge?.name}');
  });
  return result;
}

GgProfileStatsStruct? ggStatsFromCache(
  List<GgStatsEntryStruct>? cache,
  String key,
) {
  // Cached profile statistics for this key; other schema versions are ignored.
  for (final e in cache ?? <GgStatsEntryStruct>[]) {
    if (e.key == key && e.version == 1 && e.hasData()) return e.data;
  }
  return null;
}

bool ggStatsLoaded(GgProfileStatsStruct? stats) {
  // Profile statistics arrived (from the server or the cache).
  return stats != null && (stats.hasPeriod() || stats.userId.isNotEmpty);
}

GgProfileStatsStruct ggStatsOrEmpty(GgProfileStatsStruct? stats) {
  // Not loaded yet -> an empty value (0 / '' / false), so a field can be read
  // without a null check on the first frame.
  return stats ?? GgProfileStatsStruct();
}

List<GgStatsEntryStruct> ggStatsToCache(
  List<GgStatsEntryStruct>? cache,
  String key,
  GgProfileStatsStruct? data,
) {
  // Puts the statistics first (replacing the same key); keeps the last 30.
  final rest = [
    for (final e in cache ?? <GgStatsEntryStruct>[])
      if (e.key != key && e.version == 1) e
  ];
  if (data == null) return rest.take(30).toList();
  return [
    GgStatsEntryStruct(key: key, savedAt: DateTime.now(), version: 1, data: data),
    ...rest,
  ].take(30).toList();
}

GgPlayerStruct ggTopPlayerAt(
  GgRankingStruct? ranking,
  int index,
) {
  // Top player at index 0..2; empty when there is none.
  final top = ranking?.topPlayers ?? <GgPlayerStruct>[];
  if (index < 0 || index >= top.length) return GgPlayerStruct();
  return top[index];
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

void main() {
  final data = jsonDecode(File(Platform.environment['GG_EQ_DATA'] ?? 'old_vs_typed_responses.json').readAsStringSync()) as Map;
  final ranks = (data['rank'] as List).cast<Map>();
  final stats = (data['stats'] as List).cast<Map>();
  final games = (data['games'] as List).cast<Map>();
  var checks = 0;
  void eq(Object? a, Object? b, String what) {
    checks++;
    expect(b, a, reason: what);
  }
  test('rankings: old JSON functions == typed', () {
    for (final j in ranks) {
      final r = _ranking(j);
      final tag = '${j['requested_period']}/${j['requested_category']}/${j['requested_user_id']}/p${j['pagination']['page']}';
      for (final part in ['max', 'mine', 'avg']) eq(ggHomeGauge(j, part), ggHomeGaugeOf(r, part), '$tag gauge $part');
      eq(ggPlace(j), ggRankingPlace(r), '$tag place');
      eq(ggRankingPlayerIds(j), ggPlayerIdsOf(r.players), '$tag player ids');
      eq(ggTopPlayerIds(j), ggPlayerIdsOf(r.topPlayers), '$tag top ids');
      eq(ggShowMeRow(j), ggShowMeRowOf(r), '$tag me row');
      eq(ggIsFinalSeason(j), ggIsFinalOf(r), '$tag final');
      eq(ggTotalPower(j), r.totalGoodPowerAllTime, '$tag total all time');
      eq(ggMyPhoto(j), ggRankingOrEmpty(r).currentUser.photoUrl, '$tag my photo');
      eq(ggHasData(j), ggRankingLoaded(r), '$tag loaded');
      for (final withWeek in [true, false]) {
        eq(ggPeriodOptions(j, withWeek), ggPeriodOptionsOf(r.availablePeriods, withWeek), '$tag options');
        eq(ggPeriodOptionLabels(j, withWeek), ggPeriodOptionLabelsOf(r.availablePeriods, withWeek), '$tag labels');
      }
      eq(ggSeasonOptions(j), ggSeasonOptionsOf(r.availablePeriods), '$tag seasons');
      for (final v in ['auto', 'season_26_27', 'season_2025_26', 'gesamt', 'this_month', 'letzter_monat']) {
        eq(ggPeriodName(v, j), ggPeriodNameOf(v, r.availablePeriods), '$tag name $v');
        eq(ggPeriodSame(v, 'season_2026_27', j), ggPeriodSameOf(v, 'season_2026_27', r.availablePeriods), '$tag same $v');
      }
      for (var i = 0; i < 4; i++) {
        final tj = (j['top_players'] as List).length > i ? (j['top_players'] as List)[i] : null;
        final tt = ggTopPlayerAt(r, i);
        eq(ggTopPlayerPhoto(j, i), tt.photoUrl, '$tag top$i photo');
        eq(ggHasData(tj), ggPlayerLoaded(tt), '$tag top$i loaded');
        for (final c in ['valuable', 'active']) {
          for (var place = 1; place <= 3; place++) {
            eq(ggShowFinalPlace(j, tj, c, place), ggShowFinalPlaceOf(r, tt, c, place), '$tag top$i final $c $place');
            eq(ggShowCurrentPlace(j, tj, c, place), ggShowCurrentPlaceOf(r, tt, c, place), '$tag top$i current $c $place');
          }
        }
      }
      final ids = {...ggRankingPlayerIds(j), ...ggTopPlayerIds(j), if (j['current_user'] is Map) '${j['current_user']['user_id']}'};
      for (final id in ids) {
        final pj = ggPlayerRow(j, id);
        final pt = ggPlayerOf(r, id);
        eq(ggMetricRank(pj, 'score', false), pt.rank, '$tag $id rank');
        eq(ggMetricValue(pj, 'score', false), pt.score, '$tag $id score');
        eq(ggRowStyle(j, pj), ggRowStyleOf(r, pt), '$tag $id style');
        eq(ggIsLastPlayer(j, pj), ggIsLastPlayerOf(r, pt), '$tag $id last');
        eq('${pj['display_name'] ?? ''}', pt.displayName, '$tag $id name');
        for (final c in ['valuable', 'active']) {
          for (var place = 1; place <= 3; place++) {
            eq(ggHasAward(pj, c, place, ''), ggHasAwardOf(pt.awards, c, place, ''), '$tag $id award $c $place');
          }
        }
      }
    }
  });
  test('profile stats: old JSON functions == typed', () {
    for (final j in stats) {
      final s = _stats(j);
      final tag = '${j['user_id']}/${j['requested_period']}';
      for (final m in ['good_power', 'games', 'good_energy', 'sponsored_games', 'good_power_per_game', 'good_energy_per_game']) {
        final metric = {
          'good_power': s.goodPower, 'games': s.games, 'good_energy': s.goodEnergy,
          'sponsored_games': s.sponsoredGames, 'good_power_per_game': s.goodPowerPerGame,
          'good_energy_per_game': s.goodEnergyPerGame,
        }[m]!;
        eq(ggMetricValue(j, m, false), metric.value, '$tag $m value');
        eq(ggMetricRank(j, m, false), metric.rank, '$tag $m rank');
      }
      eq(ggMetricValue(j, 'good_power', true), s.allTimeGoodPower, '$tag all-time power');
      eq(ggMetricRank(j, 'good_power', true), s.allTimeRank, '$tag all-time rank');
      eq(ggHasGames(j), ggHasGamesOf(s), '$tag has games');
      eq(ggHasData(j), ggStatsLoaded(s), '$tag loaded');
      for (final v in ['auto', 'all_time', 'season_25_26', 'this_week']) {
        eq(ggPeriodLabel(v, j), ggPeriodLabelOf(v, s.period, s.availablePeriods), '$tag label $v');
      }
      for (final c in ['valuable', 'active']) {
        for (var place = 1; place <= 3; place++) {
          eq(ggHasAward(j, c, place, ''), ggHasAwardOf(s.awards, c, place, ''), '$tag award $c $place');
        }
      }
      // profile images now use the flags: same answer as the awards list
      eq(ggHasAward(j, 'valuable', 1, ''), s.awardFlags.mvpGold, '$tag flag mvpGold');
      eq(ggHasAward(j, 'valuable', 2, ''), s.awardFlags.mvpSilver, '$tag flag mvpSilver');
      eq(ggHasAward(j, 'valuable', 3, ''), s.awardFlags.mvpBronze, '$tag flag mvpBronze');
      eq(ggHasAward(j, 'active', 1, ''), s.awardFlags.activeFire, '$tag flag activeFire');
    }
  });
  test('games pages: old JSON functions == typed', () {
    for (final j in games) {
      final e = GgGamesEntryStruct(meta: _gamesPage(j), games: [for (final g in (j['games'] as List)) Map<String, dynamic>.from(g as Map)]);
      eq(ggHasMore(j), ggGamesOrEmpty(e).meta.hasMore, 'has more');
      eq(ggGamesRows(j).map((g) => g.id).toList(), ggGamesOf(e).map((g) => g.id).toList(), 'game ids');
      eq(ggGamesRows(j).map((g) => g.lichtwatt).toList(), ggGamesOf(e).map((g) => g.lichtwatt).toList(), 'lichtwatt');
    }
    print('equal checks: $checks');
  });
}
