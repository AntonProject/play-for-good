import '/backend/schema/structs/index.dart';

bool ggIsLastPlayerOf(
  GgRankingStruct? ranking,
  GgPlayerStruct? player,
) {
  // True for the last row of the loaded ranking page: no divider under it.
  if (ranking == null || player == null || ranking.players.isEmpty) return false;
  final last = ranking.players.last;
  return last.userId.isNotEmpty && last.userId == player.userId;
}
