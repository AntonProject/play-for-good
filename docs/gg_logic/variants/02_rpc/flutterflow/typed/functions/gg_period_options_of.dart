import '/backend/schema/structs/index.dart';

List<String> ggPeriodOptionsOf(
  List<GgPeriodStruct>? periods,
  bool withWeek,
) {
  // Period filter options: 'auto' = the current season, then the past seasons,
  // newest first (gg_v2.seasons); then the fixed periods.
  // Current season = the earliest season the SERVER has not completed yet
  // (is_completed from gg_v2, server time; seasons follow each other), past
  // seasons = completed ones. The phone clock is not used: a wrong device date
  // showed only "Saison" without a year and no past seasons.
  // Seasons 2025/26 and 2026/27 are always offered: from the server when it
  // sent them, otherwise these fixed ones (data not loaded yet / missing).
  final all = <GgPeriodStruct>[...?periods];
  bool has(String key) => all.any((p) => p.key == key);
  if (!has('season_2025_26')) {
    all.add(GgPeriodStruct(
        key: 'season_2025_26',
        label: 'Saison 2025/26',
        seasonYear: 2026,
        start: DateTime.utc(2025, 11, 1),
        endExclusive: DateTime.utc(2026, 9, 1),
        isCompleted: true));
  }
  if (!has('season_2026_27')) {
    all.add(GgPeriodStruct(
        key: 'season_2026_27',
        label: 'Saison 2026/27',
        seasonYear: 2027,
        start: DateTime.utc(2026, 9, 1),
        endExclusive: DateTime.utc(2027, 7, 1),
        isCompleted: false));
  }
  GgPeriodStruct? current;
  final started = <GgPeriodStruct>[];
  for (final p in all) {
    // available periods also list last_month / this_month / all_time.
    if (!p.key.startsWith('season_')) continue;
    if (p.isCompleted) {
      started.add(p);
    } else if (current == null ||
        (p.start != null && current.start != null && p.start!.isBefore(current.start!))) {
      current = p;
    }
  }
  started.sort((a, b) => (b.start ?? DateTime(0)).compareTo(a.start ?? DateTime(0)));
  return [
    if (current != null || started.isEmpty) 'auto',
    for (final p in started) p.key,
    'last_month',
    'this_month',
    if (withWeek) 'this_week',
    'all_time',
  ];
}
