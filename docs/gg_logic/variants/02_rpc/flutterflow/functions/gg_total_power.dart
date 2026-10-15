double ggTotalPower(dynamic response) {
  if (response is! Map) return 0;
  final value = response['total_good_power_all_time'];
  return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}
