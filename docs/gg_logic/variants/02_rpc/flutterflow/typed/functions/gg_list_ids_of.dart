import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

List<String> ggListIdsOf(GgRankingStruct? ranking) {
  // Rows of the Good Games list: user ids in order (the list shows 10).
  // Guest viewer, Good Power, period that includes today: the demo guest
  // ('guest', ggPlayerOf) stands at its place, like the own row of a signed-in
  // user (22.10.2026: it was only under the list, e.g. #1 after places 1-3).
  // The players from that place on move one place down (ggPlayerOf); the 10th
  // leaves the list. Guest place 11 and more: under the list (ggShowMeRowOf).
  if (ranking == null) return [];
  final ids = [
    for (final p in ranking.players)
      if (p.userId.isNotEmpty) p.userId
  ];
  if (ranking.hasCurrentUser() || !ranking.hasPeriod()) return ids;
  if (ranking.category != null && ranking.category != GgCategory.valuable) return ids;
  final now = DateTime.now().toUtc();
  final from = ranking.period.start;
  final to = ranking.period.endExclusive;
  final guestNow = (from == null || !from.isAfter(now)) && (to == null || to.isAfter(now));
  if (!guestNow) return ids;
  final places = ranking.guestPlaces;
  final place = places.goodPower > 0 ? places.goodPower : ranking.guestRank;
  if (place < 1 || place > 10 || place > ids.length + 1) return ids;
  return [...ids]..insert(place - 1, 'guest');
}
