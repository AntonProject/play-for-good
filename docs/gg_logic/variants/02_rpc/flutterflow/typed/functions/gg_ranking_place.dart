import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

int ggRankingPlace(GgRankingStruct? ranking) {
  // One place for Home, profile and Good Games.
  // Signed-in: own rank; with no points yet - right after all ranked players.
  // Guest (no currentUser): the place of the demo guest (100 points, no games)
  // in the ranking's category: Good Power -> by points, the others by games /
  // Energy / sponsored games (guest_places; 21.10.2026: "Most active" showed
  // the Good Power place, e.g. #1, instead of the place after all players).
  // The guest has its 100 only in periods that include today: in a closed
  // season or last month it has 0 and the place after all players (22.10.2026:
  // 2025/26 showed the guest at #8).
  if (ranking == null) return 0;
  // 0 in the category = place 0 (26.10.2026, owner; before: the place after
  // all players with points, e.g. "0 games, #1").
  if (ranking.hasCurrentUser()) {
    final me = ranking.currentUser;
    if (me.hasRank() && me.rank > 0 && me.score > 0) return me.rank;
    return 0;
  }
  final places = ranking.guestPlaces;
  switch (ranking.category) {
    case GgCategory.active:
    case GgCategory.generous:
    case GgCategory.social:
      return 0;
    default:
      final now = DateTime.now().toUtc();
      final from = ranking.period.start;
      final to = ranking.period.endExclusive;
      final guestNow = (from == null || !from.isAfter(now)) && (to == null || to.isAfter(now));
      if (!guestNow) return 0;
      return places.goodPower > 0 ? places.goodPower : ranking.guestRank;
  }
}
