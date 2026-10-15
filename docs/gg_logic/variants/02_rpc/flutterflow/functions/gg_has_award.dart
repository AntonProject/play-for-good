bool ggHasAward(dynamic player, String category, int place, String? season) {
  if (player is! Map || place < 1 || place > 3) return false;
  final wantedCategory = category == 'mvp'
      ? 'valuable'
      : category == 'map'
          ? 'active'
          : category;
  const aliases = {
    'season_25_26': 'season_2025_26',
    'season_26_27': 'season_2026_27'
  };
  final wantedSeason = aliases[season] ?? season;
  final awards = player['awards'] is List ? player['awards'] as List : player.containsKey('category') ? [player] : [];
  for (final award in awards) {
    if (award is! Map) continue;
    final rank = award['place'] is num
        ? (award['place'] as num).toInt()
        : int.tryParse('${award['place']}');
    if (award['category'] == wantedCategory &&
        rank == place &&
        (wantedSeason == null ||
            wantedSeason.isEmpty ||
            award['season'] == wantedSeason)) {
      return true;
    }
  }
  return false;
}
