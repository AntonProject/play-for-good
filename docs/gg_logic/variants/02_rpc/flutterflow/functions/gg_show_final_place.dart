bool ggShowFinalPlace(
    dynamic ranking, dynamic player, String category, int place) {
  // Podium of a completed season: medal/flame by the player's place in the
  // selected season and category. Row medals use ggHasAward instead.
  if (ranking is! Map || player is! Map || place < 1 || place > 3) return false;
  final period = ranking['period'];
  final isFinal = ranking['layout_mode'] != null
      ? ranking['layout_mode'] == 'final'
      : period is Map &&
          period['season_year'] != null &&
          period['is_completed'] == true;
  final wanted = category == 'mvp'
      ? 'valuable'
      : category == 'map'
          ? 'active'
          : category;
  final rank = player['rank'] is num
      ? (player['rank'] as num).toInt()
      : int.tryParse('${player['rank']}');
  return isFinal && ranking['category'] == wanted && rank == place;
}
