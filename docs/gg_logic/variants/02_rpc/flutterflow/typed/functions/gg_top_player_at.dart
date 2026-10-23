import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

GgPlayerStruct ggTopPlayerAt(
  GgRankingStruct? ranking,
  int index,
) {
  // Top player at index 0..2; empty when there is none.
  // Guest viewer, Good Power, period that includes today, guest place 1-3:
  // the demo guest is on the podium at its place and the players after it
  // move one place down, as in the list (ggListIdsOf / ggPlayerOf, 22.10.2026).
  final top = ranking?.topPlayers ?? <GgPlayerStruct>[];
  var rows = top;
  if (ranking != null &&
      !ranking.hasCurrentUser() &&
      ranking.hasPeriod() &&
      (ranking.category == null || ranking.category == GgCategory.valuable)) {
    final now = DateTime.now().toUtc();
    final from = ranking.period.start;
    final to = ranking.period.endExclusive;
    final guestNow = (from == null || !from.isAfter(now)) && (to == null || to.isAfter(now));
    final places = ranking.guestPlaces;
    final place = places.goodPower > 0 ? places.goodPower : ranking.guestRank;
    if (guestNow && place >= 1 && place <= 3 && place <= top.length + 1) {
      rows = [
        for (final p in top)
          p.hasRank() && p.rank >= place ? (GgPlayerStruct.fromMap(p.toMap())..rank = p.rank + 1) : p
      ]..insert(
          place - 1,
          GgPlayerStruct(
            userId: 'guest',
            rank: place,
            score: 100,
            displayName: 'playerforgood_${ranking.legacyBonusUsersCount + 1}',
            goodPower: 100,
            gamesCount: 0,
          ),
        );
    }
  }
  if (index < 0 || index >= rows.length) return GgPlayerStruct();
  return rows[index];
}
