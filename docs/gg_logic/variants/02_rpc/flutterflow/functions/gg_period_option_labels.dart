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
