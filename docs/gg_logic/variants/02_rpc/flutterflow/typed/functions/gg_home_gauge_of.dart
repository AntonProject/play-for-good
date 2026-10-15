import '/backend/schema/structs/index.dart';

double ggHomeGaugeOf(
  GgRankingStruct? ranking,
  String part,
) {
  // Home gauge, same formulas as totalSumMAX/totalSumAVG:
  //  max  - the largest period total among users (0 without activity);
  //  mine - the signed-in user's period total (guest 0);
  //  avg  - (sum of all totals - mine) / (all users - 1), 0 if max is 0
  //         or there are no other users (inactive users count as 0).
  if (ranking == null) return 0;
  final max = ranking.hasMaxGoodPower()
      ? ranking.maxGoodPower
      : ranking.topPlayers.isNotEmpty
          ? ranking.topPlayers.first.goodPower
          : 0.0;
  final mine = ranking.hasCurrentUser() ? ranking.currentUser.goodPower : 0.0;
  switch (part) {
    case 'max':
      return max;
    case 'mine':
      return mine;
    case 'avg':
      if (max == 0) return 0;
      final others = ranking.legacyBonusUsersCount - 1;
      if (others <= 0) return 0;
      return (ranking.totalGoodPower - mine) / others;
  }
  return 0;
}
