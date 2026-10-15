import '/backend/schema/structs/index.dart';

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
