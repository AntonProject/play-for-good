import '/backend/schema/structs/index.dart';

double ggHomeGaugeOf(
  GgRankingStruct? ranking,
  String part,
) {
  // Home gauge, same formulas as totalSumMAX/totalSumAVG:
  //  max  - the largest period total among users (0 without activity);
  //  mine - the signed-in user's period total;
  //  avg  - (sum of all totals - mine) / other users of this environment,
  //         0 if max is 0 or there are no other users (inactive count as 0).
  // Guest (ranking requested without a user; Home shows the gauge to a guest
  // only after the demo 100): mine = 100, max at least 100, avg = the average
  // of the users of this environment - the same 100 that gives the guest place.
  // The guest has the 100 only in periods that include today; in a closed
  // season or last month mine = 0 (22.10.2026).
  if (ranking == null) return 0;
  final now = DateTime.now().toUtc();
  final from = ranking.period.start;
  final to = ranking.period.endExclusive;
  final guestNow = (from == null || !from.isAfter(now)) && (to == null || to.isAfter(now));
  final guest = ranking.requestedUserId.isEmpty && !ranking.hasCurrentUser();
  final top = ranking.hasMaxGoodPower()
      ? ranking.maxGoodPower
      : ranking.topPlayers.isNotEmpty
          ? ranking.topPlayers.first.goodPower
          : 0.0;
  final max = guest && guestNow && top < 100 ? 100.0 : top;
  final mine = guest
      ? (guestNow ? 100.0 : 0.0)
      : ranking.hasCurrentUser()
          ? ranking.currentUser.goodPower
          : 0.0;
  switch (part) {
    case 'max':
      return max;
    case 'mine':
      return mine;
    case 'avg':
      if (max == 0) return 0;
      // Users of this environment except the viewer (server, 15_env_users.sql);
      // without it (older server) all registered users, as before.
      final others = ranking.hasEnvOtherUsersCount()
          ? ranking.envOtherUsersCount
          : guest
              ? ranking.legacyBonusUsersCount
              : ranking.legacyBonusUsersCount - 1;
      if (others <= 0) return 0;
      return (ranking.totalGoodPower - (guest ? 0 : mine)) / others;
  }
  return 0;
}
