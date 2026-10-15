// Optional REPLACEMENT of gamesForPeriod; same three arguments.
// Keep FF automatic imports above this code.
import '/backend/supabase/supabase.dart';
import '/flutter_flow/custom_functions.dart' as functions;

List<GamesRow>? gamesForPeriod(
  String? period,
  List<GamesRow>? games,
  String? userId,
) {
  if (games == null) return null;
  final bounds = functions.ggPeriodBounds(period ?? 'all_time', null) as Map;
  final start = bounds['period_start'] == null
      ? null
      : DateTime.parse(bounds['period_start'] as String);
  final end = bounds['period_end_exclusive'] == null
      ? null
      : DateTime.parse(bounds['period_end_exclusive'] as String);
  return games.where((g) {
    if (userId != null && userId.isNotEmpty && g.creatorUserId != userId)
      return false;
    if (start == null && end == null) return true;
    final d = g.gameDate;
    return d != null &&
        (start == null || !d.isBefore(start)) &&
        (end == null || d.isBefore(end));
  }).toList();
}
