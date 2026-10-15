bool ggHasGames(dynamic stats) {
  // Signed-in user has completed games (all time), from ggV2ProfileStats.
  if (stats is! Map || stats['all_time'] is! Map) return false;
  final n = (stats['all_time'] as Map)['games_count'];
  return (n is num ? n : num.tryParse('$n') ?? 0) > 0;
}
