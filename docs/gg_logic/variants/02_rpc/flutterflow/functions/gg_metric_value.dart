double ggMetricValue(dynamic response, String metric, bool allTime) {
  if (response is! Map) return 0;
  dynamic value;
  if (allTime) {
    final header = response['all_time'];
    if (header is Map) value = header[metric];
  } else if (response['stats'] is Map) {
    final item = (response['stats'] as Map)[metric];
    if (item is Map) value = item['value'];
  } else {
    value = response[metric];
  }
  return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}
