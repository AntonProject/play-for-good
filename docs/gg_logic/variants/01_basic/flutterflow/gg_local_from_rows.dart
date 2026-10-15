// FF Custom Function; games/users Supabase row lists nullable; context JSON nullable.
// Return JSON. Allows native widgets to recalculate as Backend Queries arrive.
import '/backend/supabase/supabase.dart';
import '/flutter_flow/custom_functions.dart';

dynamic ggLocalFromRows(
  List<GamesRow>? games,
  List<UsersRow>? users,
  dynamic context,
  String category,
  int page,
  int pageSize,
  String? userId,
) {
  if (games == null || users == null || context is! Map || context['period'] is! Map) {
    return <String, dynamic>{};
  }
  return ggLocalCalculations(
    games.map((g) => g.data).toList(),
    users.map((u) => u.data).toList(),
    context,
    category,
    page,
    pageSize,
    userId,
  );
}
