bool ggShowMeRow(dynamic ranking) {
  // Pinned "me" row: the signed-in user has a place but is not on this page.
  if (ranking is! Map) return false;
  final me = ranking['current_user'];
  if (me is! Map || me['user_id'] == null || me['rank'] == null) return false;
  final players = ranking['players'];
  if (players is! List) return true;
  return !players.whereType<Map>().any((p) => p['user_id'] == me['user_id']);
}
