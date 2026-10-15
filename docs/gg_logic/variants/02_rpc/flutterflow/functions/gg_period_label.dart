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
