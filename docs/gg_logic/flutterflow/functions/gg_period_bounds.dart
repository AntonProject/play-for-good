// Optional local filtering compatibility. Custom Function ggPeriodBounds.
// period String optional, now DateTime optional. Return JSON.
// Keep FF automatic imports including /flutter_flow/custom_functions.dart.
import '/flutter_flow/custom_functions.dart' as functions;

dynamic ggPeriodBounds(String? period, DateTime? now) {
  final clock = (now ?? DateTime.now()).toUtc();
  var key = (period ?? 'auto').trim().toLowerCase();
  const aliases = {
    'gesamt': 'all_time',
    'all-time': 'all_time',
    'saison': 'auto',
    'saison_2025_26': 'season_2025_26',
    'saison_2026_27': 'season_2026_27',
    'letzter_monat': 'last_month',
    'dieser_monat': 'this_month',
    'monat': 'this_month',
  };
  key = aliases[key] ?? key;
  if (key == 'auto') key = functions.ggDefaultPeriod(clock);
  DateTime? start;
  DateTime? end;
  final season = RegExp(r'^season_([0-9]{4})_([0-9]{2})$').firstMatch(key);
  if (season != null && key != 'season_2025_26') {
    final year = int.parse(season.group(1)!);
    if (year < 2026 ||
        year > 9998 ||
        int.parse(season.group(2)!) != (year + 1) % 100) {
      throw ArgumentError.value(period, 'period', 'Unknown GG period');
    }
    return {
      'key': key,
      'period_start': DateTime(year, 9, 1).toIso8601String(),
      'period_end_exclusive': DateTime(year + 1, 7, 1).toIso8601String(),
    };
  }
  switch (key) {
    case 'season_2025_26':
      start = DateTime(2025, 11, 20);
      end = DateTime(2026, 9, 1);
      break;
    case 'season_2026_27':
      start = DateTime(2026, 9, 1);
      end = DateTime(2027, 7, 1);
      break;
    case 'last_month':
      start = DateTime(clock.year, clock.month - 1, 1);
      end = DateTime(clock.year, clock.month, 1);
      break;
    case 'this_month':
      start = DateTime(clock.year, clock.month, 1);
      end = DateTime(clock.year, clock.month + 1, 1);
      break;
    case 'woche': // Preserve old callers outside this GG task.
      start = DateTime(
        clock.year,
        clock.month,
        clock.day,
      ).subtract(Duration(days: clock.weekday - 1));
      end = start.add(const Duration(days: 7));
      break;
    case 'all_time':
      break;
    default:
      throw ArgumentError.value(period, 'period', 'Unknown GG period');
  }
  // Naive calendar timestamps match the existing timestamp columns/GamesRow.
  return {
    'key': key,
    'period_start': start?.toIso8601String(),
    'period_end_exclusive': end?.toIso8601String(),
  };
}
