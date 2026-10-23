import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

bool ggIsLastPlayerOf(
  GgRankingStruct? ranking,
  GgPlayerStruct? player,
) {
  // True for the last row of the shown list: no divider under it. The list is
  // the first 10 of ggListIdsOf (with the demo guest for a guest viewer).
  if (ranking == null || player == null || player.userId.isEmpty) return false;
  final ids = [
    for (final p in ranking.players)
      if (p.userId.isNotEmpty) p.userId
  ];
  if (!ranking.hasCurrentUser() &&
      ranking.hasPeriod() &&
      (ranking.category == null || ranking.category == GgCategory.valuable)) {
    final now = DateTime.now().toUtc();
    final from = ranking.period.start;
    final to = ranking.period.endExclusive;
    final guestNow = (from == null || !from.isAfter(now)) && (to == null || to.isAfter(now));
    final places = ranking.guestPlaces;
    final place = places.goodPower > 0 ? places.goodPower : ranking.guestRank;
    if (guestNow && place >= 1 && place <= 10 && place <= ids.length + 1) {
      ids.insert(place - 1, 'guest');
    }
  }
  if (ids.isEmpty) return false;
  final last = ids.length > 10 ? ids[9] : ids.last;
  return last == player.userId;
}
