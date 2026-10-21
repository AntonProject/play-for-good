import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

GgPlayerStruct ggPlayerOf(
  GgRankingStruct? ranking,
  String? userId,
) {
  // Ranking row of this user (current user, page or top); empty when absent.
  // Guest (no user id, no signed-in user in the ranking): the demo guest row
  // under the list - name as in the guest profile (playerforgood_N), 100 Good
  // Power and nothing else, place in the ranking's category (ggRankingPlace).
  // userId 'guest' marks it as loaded (ggPlayerLoaded) and opens the guest
  // profile (21.10.2026: the guest row showed "unnamed", 0 and a wrong place).
  if (ranking == null || userId == null) return GgPlayerStruct();
  if (userId.isEmpty) {
    if (ranking.hasCurrentUser()) return GgPlayerStruct();
    final places = ranking.guestPlaces;
    final category = ranking.category;
    int place;
    double score;
    switch (category) {
      case GgCategory.active:
        place = places.games > 0 ? places.games : ranking.totalCount + 1;
        score = 0;
        break;
      case GgCategory.generous:
        place = places.goodEnergy > 0 ? places.goodEnergy : ranking.totalCount + 1;
        score = 0;
        break;
      case GgCategory.social:
        place = places.sponsoredGames > 0 ? places.sponsoredGames : ranking.totalCount + 1;
        score = 0;
        break;
      default:
        place = places.goodPower > 0 ? places.goodPower : ranking.guestRank;
        score = 100;
    }
    return GgPlayerStruct(
      userId: 'guest',
      rank: place,
      score: score,
      displayName: 'playerforgood_${ranking.legacyBonusUsersCount + 1}',
      goodPower: 100,
      gamesCount: 0,
    );
  }
  if (ranking.hasCurrentUser() && ranking.currentUser.userId == userId) {
    final me = ranking.currentUser;
    // No points in this category / period: no rank from the server; the row
    // shows the place after all ranked players (as ggRankingPlace / Home),
    // not "0".
    if (me.hasRank() && me.rank > 0) return me;
    return GgPlayerStruct.fromMap(me.toMap())..rank = ranking.totalCount + 1;
  }
  for (final p in [...ranking.players, ...ranking.topPlayers]) {
    if (p.userId == userId) return p;
  }
  return GgPlayerStruct();
}
