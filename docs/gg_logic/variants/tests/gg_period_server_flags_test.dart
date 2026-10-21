import 'package:flutter_test/flutter_test.dart';
import 'package:players_for_good/backend/schema/structs/index.dart';
import 'package:players_for_good/flutter_flow/custom_functions.dart' as f;
GgPeriodStruct s(String key, String label, DateTime start, DateTime end, bool done) =>
    GgPeriodStruct(key: key, label: label, start: start, endExclusive: end, isCompleted: done);
void main() {
  final periods = [
    s('season_2027_28', 'Saison 2027/28', DateTime.utc(2027, 7, 1), DateTime.utc(2028, 5, 1), false),
    s('season_2026_27', 'Saison 2026/27', DateTime.utc(2026, 9, 1), DateTime.utc(2027, 7, 1), false),
    s('season_2025_26', 'Saison 2025/26', DateTime.utc(2025, 11, 1), DateTime.utc(2026, 9, 1), true),
    GgPeriodStruct(key: 'all_time', label: 'All-Time'),
  ];
  test('options do not depend on the phone clock', () {
    expect(f.ggSeasonOptionsOf(periods), ['season_2026_27', 'season_2025_26']);
    expect(f.ggPeriodOptionsOf(periods, false), ['auto', 'season_2025_26', 'last_month', 'this_month', 'all_time']);
    expect(f.ggPeriodOptionLabelsOf(periods, false).take(2), ['Saison 2026/27', 'Saison 2025/26']);
    expect(f.ggPeriodNameOf('auto', periods), 'Saison 2026/27');
    expect(f.ggPeriodNameOf('season_2025_26', periods), 'Saison 2025/26');
    expect(f.ggPeriodSameOf('auto', 'season_2026_27', periods), true);
    expect(f.ggPeriodSameOf('auto', 'season_2025_26', periods), false);
  });
  test('without server data the two seasons are still offered', () {
    final none = <GgPeriodStruct>[];
    expect(f.ggSeasonOptionsOf(none), ['season_2026_27', 'season_2025_26']);
    expect(f.ggPeriodOptionLabelsOf(none, false).take(2), ['Saison 2026/27', 'Saison 2025/26']);
    expect(f.ggPeriodOptionLabelsOf(null, true).take(2), ['Saison 2026/27', 'Saison 2025/26']);
    expect(f.ggPeriodNameOf('auto', none), 'Saison 2026/27');
    expect(f.ggPeriodSameOf('auto', 'season_2026_27', null), true);
  });
}
