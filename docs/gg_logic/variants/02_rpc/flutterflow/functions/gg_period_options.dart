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
