int ggPlace(dynamic ranking) {
  // One place for Home, profile and Good Games.
  // Signed-in: own rank; with no points yet - right after all ranked players.
  // Guest (no current_user): the place of the demo 100 points (guest_rank).
  if (ranking is! Map) return 0;
  int? asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v');
  final me = ranking['current_user'];
  if (me is Map) {
    final rank = asInt(me['rank']);
    if (rank != null && rank > 0) return rank;
    final page = ranking['pagination'];
    final total = page is Map ? asInt(page['total_count']) : null;
    return (total ?? 0) + 1;
  }
  return asInt(ranking['guest_rank']) ?? 0;
}
