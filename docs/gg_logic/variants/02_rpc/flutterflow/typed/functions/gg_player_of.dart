import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

GgPlayerStruct ggPlayerOf(
  GgRankingStruct? ranking,
  String? userId,
) {
  // Ranking row of this user (current user, page or top); empty when absent.
  // Guest (no user id, no signed-in user in the ranking): the demo guest row -
  // name as in the guest profile (playerforgood_N), 100 Good Power and nothing
  // else, place in the ranking's category (ggRankingPlace). userId 'guest'
  // marks it as loaded (ggPlayerLoaded) and opens the guest profile
  // (21.10.2026: the guest row showed "unnamed", 0 and a wrong place).
  // The guest has its 100 only in periods that include today; in a closed
  // season or last month: 0, place after all players (22.10.2026).
  // For a guest viewer the guest stands in the Good Power list at its place
  // (ggListIdsOf; 22.10.2026: it was under the list, e.g. a second #1), so the
  // players from that place on show one place lower.
  // Guest profile before its ranking arrives: the demo 100 (no place yet).
  if (userId == 'guest' && (ranking == null || !ranking.hasPeriod())) {
    return GgPlayerStruct(userId: 'guest', score: 100, goodPower: 100, gamesCount: 0);
  }
  if (ranking == null || userId == null) return GgPlayerStruct();
  final viewerIsGuest = !ranking.hasCurrentUser();
  final now = DateTime.now().toUtc();
  final from = ranking.period.start;
  final to = ranking.period.endExclusive;
  final guestNow = (from == null || !from.isAfter(now)) && (to == null || to.isAfter(now));
  final valuable = ranking.category == null || ranking.category == GgCategory.valuable;
  final places = ranking.guestPlaces;
  final guestPlace = places.goodPower > 0 ? places.goodPower : ranking.guestRank;
  if (userId.isEmpty || userId == 'guest') {
    if (!viewerIsGuest) return GgPlayerStruct();
    int place;
    double score = 0;
    switch (ranking.category) {
      case GgCategory.active:
        place = places.games > 0 ? places.games : ranking.totalCount + 1;
        break;
      case GgCategory.generous:
        place = places.goodEnergy > 0 ? places.goodEnergy : ranking.totalCount + 1;
        break;
      case GgCategory.social:
        place = places.sponsoredGames > 0 ? places.sponsoredGames : ranking.totalCount + 1;
        break;
      default:
        place = guestNow ? guestPlace : ranking.totalCount + 1;
        score = guestNow ? 100 : 0;
    }
    return GgPlayerStruct(
      userId: 'guest',
      rank: place,
      score: score,
      displayName: 'playerforgood_${ranking.legacyBonusUsersCount + 1}',
      goodPower: guestNow ? 100 : 0,
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
    if (p.userId != userId) continue;
    if (viewerIsGuest && valuable && guestNow && p.hasRank() && p.rank >= guestPlace) {
      return GgPlayerStruct.fromMap(p.toMap())..rank = p.rank + 1;
    }
    return p;
  }
  return GgPlayerStruct();
}
