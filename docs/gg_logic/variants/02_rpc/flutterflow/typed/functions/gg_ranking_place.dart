import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

int ggRankingPlace(GgRankingStruct? ranking) {
  // One place for Home, profile and Good Games.
  // Signed-in: own rank; with no points yet - right after all ranked players.
  // Guest (no currentUser): the place of the demo guest (100 points, no games)
  // in the ranking's category: Good Power -> by points, the others by games /
  // Energy / sponsored games (guest_places; 21.10.2026: "Most active" showed
  // the Good Power place, e.g. #1, instead of the place after all players).
  if (ranking == null) return 0;
  if (ranking.hasCurrentUser()) {
    final me = ranking.currentUser;
    if (me.hasRank() && me.rank > 0) return me.rank;
    return ranking.totalCount + 1;
  }
  final places = ranking.guestPlaces;
  switch (ranking.category) {
    case GgCategory.active:
      return places.games > 0 ? places.games : ranking.totalCount + 1;
    case GgCategory.generous:
      return places.goodEnergy > 0 ? places.goodEnergy : ranking.totalCount + 1;
    case GgCategory.social:
      return places.sponsoredGames > 0 ? places.sponsoredGames : ranking.totalCount + 1;
    default:
      return places.goodPower > 0 ? places.goodPower : ranking.guestRank;
  }
}
