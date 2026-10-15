bool ggIsLastPlayer(dynamic ranking, dynamic player) {
  // True for the last row of the loaded ranking page: no divider under it.
  if (ranking is! Map || player is! Map) return false;
  final players = ranking['players'];
  if (players is! List || players.isEmpty) return false;
  final last = players.last;
  return last is Map && last['user_id'] != null && last['user_id'] == player['user_id'];
}
