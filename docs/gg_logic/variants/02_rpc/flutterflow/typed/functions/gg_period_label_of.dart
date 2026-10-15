import '/backend/schema/structs/index.dart';

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
