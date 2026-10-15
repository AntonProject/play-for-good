int ggMetricRank(dynamic response, String metric, bool allTime) {
  if (response is! Map) return 0;
  dynamic value;
  if (allTime) {
    final header = response['all_time'];
    if (header is Map) value = header['rank'];
  } else if (response['stats'] is Map) {
    final item = (response['stats'] as Map)[metric];
    if (item is Map) value = item['rank'];
  } else {
    value = response['rank'];
  }
  return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
