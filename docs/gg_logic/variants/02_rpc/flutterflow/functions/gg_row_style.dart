String ggRowStyle(dynamic ranking, dynamic player) {
  if (ranking is! Map || player is! Map) return 'none';
  final rank = player['rank'] is num
      ? (player['rank'] as num).toInt()
      : int.tryParse('${player['rank']}');
  if (rank == null || rank < 1 || rank > 3) return 'none';
  final period = ranking['period'];
  final isFinal = ranking['layout_mode'] != null
      ? ranking['layout_mode'] == 'final'
      : period is Map &&
          period['season_year'] != null &&
          period['is_completed'] == true;
  final ordinal = {1: 'first', 2: 'second', 3: 'third'}[rank];
  return '${isFinal ? 'final' : 'current'}_$ordinal';
}
