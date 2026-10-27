import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

List<String> ggListIdsOf(GgRankingStruct? ranking) {
  // Rows of the Good Games list: user ids in order (the list shows 10).
  // Guest viewer, Good Power, period that includes today: the demo guest
  // ('guest', ggPlayerOf) stands at its place, like the own row of a signed-in
  // user (22.10.2026: it was only under the list, e.g. #1 after places 1-3).
  // The players from that place on move one place down (ggPlayerOf); the 10th
  // leaves the list. Own row / guest without points: the last row while the
  // list has fewer than 10 rows (26.10.2026: it stood under a divider after a
  // single player). Otherwise under the list (ggShowMeRowOf).
  // Rows of the list (same in ggListIdsOf / ggShowMeRowOf / ggIsLastPlayerOf).
  List<String> listIds(GgRankingStruct r) {
    final ids = [
      for (final p in r.players)
        if (p.userId.isNotEmpty) p.userId
    ];
    if (!r.hasPeriod()) return ids;
    if (r.hasCurrentUser()) {
      // Own row without points: in the list while it has room (26.10.2026).
      final me = r.currentUser.userId;
      if (me.isNotEmpty && !ids.contains(me) && ids.length < 10) ids.add(me);
      return ids;
    }
    final now = DateTime.now().toUtc();
    final from = r.period.start;
    final to = r.period.endExclusive;
    final guestNow = (from == null || !from.isAfter(now)) && (to == null || to.isAfter(now));
    if (!guestNow) return ids;
    if (r.category == null || r.category == GgCategory.valuable) {
      final place = r.guestPlaces.goodPower > 0 ? r.guestPlaces.goodPower : r.guestRank;
      if (place >= 1 && place <= 10 && place <= ids.length + 1) {
        ids.insert(place - 1, 'guest');
        return ids;
      }
    }
    // Guest with 0 in this category: last row while the list has room.
    if (ids.length < 10) ids.add('guest');
    return ids;
  }
  if (ranking == null) return [];
  return listIds(ranking);
}
