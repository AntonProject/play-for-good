// Custom Function ggGamesRows. response JSON optional. Return List<GamesRow>
// (Supabase row type games). Converts only the already paginated response.
import '/backend/supabase/supabase.dart';

List<GamesRow> ggGamesRows(dynamic response) {
  if (response is! Map || response['games'] is! List) return [];
  return (response['games'] as List)
      .map((row) => GamesRow(Map<String, dynamic>.from(row as Map)))
      .toList();
}
