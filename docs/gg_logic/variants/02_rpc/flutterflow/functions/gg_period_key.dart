String ggPeriodKey(String? value) {
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
  return aliases[key] ?? key;
}
