import '/backend/schema/structs/index.dart';

double ggTotalPowerOf(GgRankingStruct? ranking) {
  // "LW / Total Good Power" of Good Games: the server total of the period.
  // A guest viewer sees the demo guest with 100 in the list in periods that
  // include today (ggListIdsOf), so the 100 is added there too (26.10.2026:
  // the list summed to 300, the header said 200).
  if (ranking == null) return 0;
  final total = ranking.totalGoodPower;
  if (ranking.hasCurrentUser() || !ranking.hasPeriod()) return total;
  final now = DateTime.now().toUtc();
  final from = ranking.period.start;
  final to = ranking.period.endExclusive;
  final guestNow = (from == null || !from.isAfter(now)) && (to == null || to.isAfter(now));
  return guestNow ? total + 100 : total;
}
