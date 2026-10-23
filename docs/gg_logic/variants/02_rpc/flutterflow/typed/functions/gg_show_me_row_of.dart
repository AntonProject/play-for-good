import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

bool ggShowMeRowOf(GgRankingStruct? ranking) {
  // Own row under the list: signed in and not on the loaded page. Also without
  // points in this category / period (21.10.2026: it was hidden then, while
  // Home showed the place after all ranked players, e.g. #4 / #16).
  // Guest (22.10.2026; before, the page showed it for every guest): only when
  // the demo guest is not in the list (ggListIdsOf), and not in a closed
  // season or last month - the guest did not play then.
  if (ranking == null || !ranking.hasPeriod()) return false;
  if (!ranking.hasCurrentUser()) {
    final now = DateTime.now().toUtc();
    final from = ranking.period.start;
    final to = ranking.period.endExclusive;
    final guestNow = (from == null || !from.isAfter(now)) && (to == null || to.isAfter(now));
    if (!guestNow) return false;
    if (ranking.category != null && ranking.category != GgCategory.valuable) return true;
    final places = ranking.guestPlaces;
    final place = places.goodPower > 0 ? places.goodPower : ranking.guestRank;
    final shown = ranking.players.where((p) => p.userId.isNotEmpty).length;
    return !(place >= 1 && place <= 10 && place <= shown + 1);
  }
  final me = ranking.currentUser;
  if (me.userId.isEmpty) return false;
  return !ranking.players.any((p) => p.userId == me.userId);
}
