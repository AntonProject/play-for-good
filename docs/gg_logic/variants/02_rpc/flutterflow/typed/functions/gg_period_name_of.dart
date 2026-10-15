import '/backend/schema/structs/index.dart';

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
