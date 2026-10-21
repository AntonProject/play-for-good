import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

String ggRowStyleOf(
  GgRankingStruct? ranking,
  GgPlayerStruct? player,
) {
  // Row look of places 1-3: final_first .. current_third; 'none' otherwise.
  if (ranking == null || player == null || !player.hasRank()) return 'none';
  // The demo guest row is not a real place 1-3 (no podium look).
  if (player.userId == 'guest') return 'none';
  // Own row without points (place after all ranked players): no podium look.
  if (ranking.hasCurrentUser() &&
      ranking.currentUser.userId == player.userId &&
      !(ranking.currentUser.hasRank() && ranking.currentUser.rank > 0)) {
    return 'none';
  }
  final rank = player.rank;
  if (rank < 1 || rank > 3) return 'none';
  final isFinal = ranking.layoutMode == GgLayoutMode.finished;
  final ordinal = {1: 'first', 2: 'second', 3: 'third'}[rank];
  return '${isFinal ? 'final' : 'current'}_$ordinal';
}
