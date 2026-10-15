List<String> ggTopPlayerIds(dynamic ranking) {
  // Podium user ids (places 1..3) independent of the list page.
  if (ranking is! Map || ranking['top_players'] is! List) return [];
  return (ranking['top_players'] as List)
      .whereType<Map>()
      .map((p) => '${p['user_id'] ?? ''}')
      .where((id) => id.isNotEmpty)
      .toList();
}
