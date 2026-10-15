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
