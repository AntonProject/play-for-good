bool ggHasActivity(dynamic stats) {
  // Any activity (games or used invites) of all time, from ggV2ProfileStats.
  if (stats is! Map || stats['all_time'] is! Map) return false;
  final all = stats['all_time'] as Map;
  num asNum(dynamic v) => v is num ? v : num.tryParse('$v') ?? 0;
  return asNum(all['games_count']) > 0 || asNum(all['good_power']) > 0;
}
