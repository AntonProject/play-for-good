bool ggFiltersChanged(String? selectedPeriod, String? appliedPeriod,
    String? selectedCategory, String? appliedCategory) {
  const aliases = {
    'gesamt': 'all_time',
    'all-time': 'all_time',
    'monat': 'this_month',
    'dieser_monat': 'this_month',
    'letzter_monat': 'last_month',
    'season_26_27': 'season_2026_27',
    'season_25_26': 'season_2025_26',
    'saison': 'auto',
  };
  final selected = aliases[selectedPeriod] ?? selectedPeriod;
  final applied = aliases[appliedPeriod] ?? appliedPeriod;
  return selected != applied || selectedCategory != appliedCategory;
}
