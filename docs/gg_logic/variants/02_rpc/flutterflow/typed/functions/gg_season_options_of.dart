import '/backend/schema/structs/index.dart';

List<String> ggSeasonOptionsOf(List<GgPeriodStruct>? periods) {
  // Seasons for the Good Games filter: the current season, then the seasons
  // that already started, newest first (gg_v2.seasons). Real keys.
  final now = DateTime.now().toUtc();
  String? current;
  final started = <GgPeriodStruct>[];
  for (final p in periods ?? <GgPeriodStruct>[]) {
    // available periods also list last_month / this_month / all_time.
    if (!p.key.startsWith('season_') || p.start == null) continue;
    if (p.start!.isAfter(now)) continue;
    if (p.endExclusive != null && now.isBefore(p.endExclusive!)) {
      current = p.key;
    } else {
      started.add(p);
    }
  }
  started.sort((a, b) => b.start!.compareTo(a.start!));
  return [
    if (current != null) current else if (started.isEmpty) 'auto',
    for (final p in started) p.key,
  ];
}
