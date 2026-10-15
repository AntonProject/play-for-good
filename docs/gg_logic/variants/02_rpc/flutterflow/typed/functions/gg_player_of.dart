import '/backend/schema/structs/index.dart';

GgPlayerStruct ggPlayerOf(
  GgRankingStruct? ranking,
  String? userId,
) {
  // Ranking row of this user (current user, page or top); empty when absent.
  if (ranking == null || userId == null || userId.isEmpty) return GgPlayerStruct();
  if (ranking.hasCurrentUser() && ranking.currentUser.userId == userId) {
    return ranking.currentUser;
  }
  for (final p in [...ranking.players, ...ranking.topPlayers]) {
    if (p.userId == userId) return p;
  }
  return GgPlayerStruct();
}
