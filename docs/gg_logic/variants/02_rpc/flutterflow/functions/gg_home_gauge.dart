double ggHomeGauge(dynamic ranking, String part) {
  // Home gauge from the ranking RPC, same formulas as totalSumMAX/totalSumAVG:
  //  max  - the largest period total among users (0 without activity);
  //  mine - the signed-in user's period total (guest 0);
  //  avg  - (sum of all totals - mine) / (all users - 1), 0 if max is 0
  //         or there are no other users (inactive users count as 0).
  if (ranking is! Map) return 0;
  double toD(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
  final top = ranking['top_players'];
  final max = ranking.containsKey('max_good_power')
      ? toD(ranking['max_good_power'])
      : (top is List && top.isNotEmpty && top.first is Map)
          ? toD((top.first as Map)['good_power'])
          : 0.0;
  final me = ranking['current_user'];
  final mine = me is Map ? toD(me['good_power']) : 0.0;
  switch (part) {
    case 'max':
      return max;
    case 'mine':
      return mine;
    case 'avg':
      if (max == 0) return 0;
      final others = toD(ranking['legacy_bonus_users_count']) - 1;
      if (others <= 0) return 0;
      return (toD(ranking['total_good_power']) - mine) / others;
  }
  return 0;
}
