// Optional REPLACEMENT of filterAllGames; not installed in the app yet.
// Same existing five arguments; optional userId appended for old callers.
// Keep FF automatic imports above this code.
import '/backend/supabase/supabase.dart';
import '/flutter_flow/custom_functions.dart' as functions;

List<GamesRow>? filterAllGames(
  List<GamesRow>? games,
  String? period,
  String? valueType,
  int? limit,
  int? page, [
  String? userId,
]) {
  if (games == null) return null;
  final bounds = functions.ggPeriodBounds(period ?? 'all_time', null) as Map;
  final start = bounds['period_start'] == null
      ? null
      : DateTime.parse(bounds['period_start'] as String);
  final end = bounds['period_end_exclusive'] == null
      ? null
      : DateTime.parse(bounds['period_end_exclusive'] as String);
  final result = games.where((g) {
    if (userId != null && userId.isNotEmpty && g.creatorUserId != userId)
      return false;
    if (start == null && end == null) return true;
    final d = g.gameDate;
    return d != null &&
        (start == null || !d.isBefore(start)) &&
        (end == null || d.isBefore(end));
  }).toList();
  final category = valueType ?? 'valuable';
  result.sort((a, b) {
    int order = 0;
    if (category == 'valuable' || category == 'social') {
      order = (b.lichtwatt ?? 0).compareTo(a.lichtwatt ?? 0);
    } else if (category == 'generous') {
      double energy(GamesRow g) =>
          (g.userMoney ?? 0) +
          (g.teamMoney ?? 0) +
          (g.siegMoney ?? 0) +
          (g.additionalDonationMoney ?? 0);
      order = energy(b).compareTo(energy(a));
    } // active/recent: own game list ordered by newest game.
    if (order != 0) return order;
    if (a.gameDate == null && b.gameDate != null) return 1;
    if (b.gameDate == null && a.gameDate != null) return -1;
    order = (b.gameDate ?? DateTime(1970)).compareTo(
      a.gameDate ?? DateTime(1970),
    );
    return order != 0 ? order : a.id.compareTo(b.id);
  });
  final size = limit ?? 10;
  final current = page ?? 1;
  if (size < 1 || current < 1)
    throw ArgumentError('Positive limit/page required');
  return result.skip((current - 1) * size).take(size).toList();
}
