dynamic ggPlayerRow(dynamic ranking, String? userId) {
  if (ranking is! Map || userId == null || userId.isEmpty) {
    return <String, dynamic>{};
  }
  if (ranking['user_id'] == userId) return Map<String, dynamic>.from(ranking);
  final selected = ranking['current_user'];
  if (selected is Map && selected['user_id'] == userId) {
    return Map<String, dynamic>.from(selected);
  }
  for (final key in ['players', 'top_players']) {
    for (final row in ranking[key] as List? ?? []) {
      if (row is Map && row['user_id'] == userId) {
        return Map<String, dynamic>.from(row);
      }
    }
  }
  return <String, dynamic>{};
}
