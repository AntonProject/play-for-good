List<dynamic> ggAwards(dynamic player, String? season) {
  if (player is! Map) return [];
  const aliases = {
    'season_25_26': 'season_2025_26',
    'season_26_27': 'season_2026_27'
  };
  final wanted = aliases[season] ?? season;
  final result = (player['awards'] as List? ?? [])
      .whereType<Map>()
      .where((a) => wanted == null || wanted.isEmpty || a['season'] == wanted)
      .map((a) => Map<String, dynamic>.from(a))
      .toList();
  result.sort((a, b) {
    final categoryA = a['category'] == 'valuable'
        ? 0
        : a['category'] == 'active'
            ? 1
            : 2;
    final categoryB = b['category'] == 'valuable'
        ? 0
        : b['category'] == 'active'
            ? 1
            : 2;
    final category = categoryA.compareTo(categoryB);
    if (category != 0) return category;
    final start = '${b['period_start'] ?? b['season_year'] ?? ''}'
        .compareTo('${a['period_start'] ?? a['season_year'] ?? ''}');
    if (start != 0) return start;
    return '${a['badge']}'.compareTo('${b['badge']}');
  });
  return result;
}
