// Custom Action ggMyGames. Returns List<GamesRow>: the signed-in user's games
// of the current environment (same filter as the former page query:
// creator_user_id = me, test = environment). Guest -> empty list, no request.
// Parameter test Boolean required. Keep FF automatic imports above this code.
import '/backend/supabase/supabase.dart';

Future<List<GamesRow>> ggMyGames(bool test) async {
  final uid = SupaFlow.client.auth.currentUser?.id;
  if (uid == null || uid.isEmpty) return [];
  final rows = await SupaFlow.client
      .from('games')
      .select()
      .eq('creator_user_id', uid)
      .eq('test', test);
  return (rows as List)
      .map((r) => GamesRow(Map<String, dynamic>.from(r as Map)))
      .toList();
}
