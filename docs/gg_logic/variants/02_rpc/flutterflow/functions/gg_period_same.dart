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
