String ggPlaceLabel(dynamic ranking) {
  // "#5", or "#–" when there is no place yet (no points in the period).
  if (ranking is! Map) return '#–';
  int? asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v');
  final me = ranking['current_user'];
  final place = me is Map
      ? asInt(me['rank'])
      : asInt(ranking['guest_rank']);
  return place != null && place > 0 ? '#$place' : '#–';
}
