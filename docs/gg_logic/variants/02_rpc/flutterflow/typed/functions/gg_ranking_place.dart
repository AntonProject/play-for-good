import '/backend/schema/structs/index.dart';

int ggRankingPlace(GgRankingStruct? ranking) {
  // One place for Home, profile and Good Games.
  // Signed-in: own rank; with no points yet - right after all ranked players.
  // Guest (no currentUser): the place of the demo 100 points (guestRank).
  if (ranking == null) return 0;
  if (ranking.hasCurrentUser()) {
    final me = ranking.currentUser;
    if (me.hasRank() && me.rank > 0) return me.rank;
    return ranking.totalCount + 1;
  }
  return ranking.guestRank;
}
