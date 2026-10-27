import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

String ggRowStyleOf(
  GgRankingStruct? ranking,
  GgPlayerStruct? player,
) {
  // Row look of places 1-3: final_first .. current_third; 'none' otherwise.
  if (ranking == null || player == null || !player.hasRank()) return 'none';
  // The demo guest in the list at places 1-3 looks like any player there
  // (22.10.2026); without points (closed season, other categories) - none.
  if (player.userId == 'guest' && player.score <= 0) return 'none';
  // Own row without points (place after all ranked players, even #1-3 in a
  // short list): no podium look.
  if (ranking.hasCurrentUser() &&
      ranking.currentUser.userId == player.userId &&
      !(ranking.currentUser.hasRank() && ranking.currentUser.rank > 0 && ranking.currentUser.score > 0)) {
    return 'none';
  }
  final rank = player.rank;
  if (rank < 1 || rank > 3) return 'none';
  final isFinal = ranking.layoutMode == GgLayoutMode.finished;
  final ordinal = {1: 'first', 2: 'second', 3: 'third'}[rank];
  return '${isFinal ? 'final' : 'current'}_$ordinal';
}
