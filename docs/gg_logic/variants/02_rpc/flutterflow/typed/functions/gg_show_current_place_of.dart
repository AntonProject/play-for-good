import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

bool ggShowCurrentPlaceOf(
  GgRankingStruct? ranking,
  GgPlayerStruct? player,
  String category,
  int place,
) {
  // Place badge of a top player in the current layout of this category.
  if (ranking == null || player == null || place < 1 || place > 3) return false;
  final isFinal = ranking.layoutMode == GgLayoutMode.finished;
  final wanted = category == 'mvp'
      ? 'valuable'
      : category == 'map'
          ? 'active'
          : category;
  return !isFinal &&
      ranking.category?.name == wanted &&
      player.hasRank() &&
      player.rank == place;
}
