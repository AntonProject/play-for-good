String ggTopPlayerPhoto(dynamic ranking, int index) {
  // Podium avatar (index 0..2) straight from the ranking RPC; '' -> default image.
  if (ranking is! Map || ranking['top_players'] is! List) return '';
  final top = (ranking['top_players'] as List).whereType<Map>().toList();
  if (index < 0 || index >= top.length) return '';
  return '${top[index]['photo_url'] ?? ''}';
}
