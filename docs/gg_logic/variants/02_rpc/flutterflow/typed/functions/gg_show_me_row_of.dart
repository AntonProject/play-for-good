import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

bool ggShowMeRowOf(GgRankingStruct? ranking) {
  // Own / guest row under the divider: only when it is not in the list
  // (ggListIdsOf: the list is full and the row is not in it). Signed in: also
  // without points (21.10.2026). Guest: not in a closed season or last month -
  // the guest did not play then (22.10.2026).
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
  if (ranking == null || !ranking.hasPeriod()) return false;
  if (ranking.hasCurrentUser()) {
    final me = ranking.currentUser.userId;
    return me.isNotEmpty && !listIds(ranking).take(10).contains(me);
  }
  final now = DateTime.now().toUtc();
  final from = ranking.period.start;
  final to = ranking.period.endExclusive;
  final guestNow = (from == null || !from.isAfter(now)) && (to == null || to.isAfter(now));
  return guestNow && !listIds(ranking).take(10).contains('guest');
}
