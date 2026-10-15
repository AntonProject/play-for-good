import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

String ggRowStyleOf(
  GgRankingStruct? ranking,
  GgPlayerStruct? player,
) {
  // Row look of places 1-3: final_first .. current_third; 'none' otherwise.
  if (ranking == null || player == null || !player.hasRank()) return 'none';
  final rank = player.rank;
  if (rank < 1 || rank > 3) return 'none';
  final isFinal = ranking.layoutMode == GgLayoutMode.finished;
  final ordinal = {1: 'first', 2: 'second', 3: 'third'}[rank];
  return '${isFinal ? 'final' : 'current'}_$ordinal';
}
