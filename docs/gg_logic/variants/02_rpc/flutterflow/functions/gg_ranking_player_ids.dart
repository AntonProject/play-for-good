List<String> ggRankingPlayerIds(dynamic ranking) {
  if (ranking is! Map) return [];
  return (ranking['players'] as List? ?? [])
      .whereType<Map>()
      .map((p) => p['user_id'])
      .whereType<String>()
      .toList();
}
