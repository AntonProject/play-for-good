// Custom Action ggMyCompletedGames. Returns List<GamesRow>: the signed-in
// user's completed games of the current environment. Replaces Home's query of
// ALL completed games: every Home use filtered it to creator = me anyway.
// Guest -> empty list, no request. Keep FF automatic imports above this code.
import '/backend/supabase/supabase.dart';

Future<List<GamesRow>> ggMyCompletedGames(bool test) async {
  final uid = SupaFlow.client.auth.currentUser?.id;
  if (uid == null || uid.isEmpty) return [];
  final rows = await SupaFlow.client
      .from('games')
      .select()
      .eq('creator_user_id', uid)
      .eq('status', 'completed')
      .eq('test', test);
  return (rows as List)
      .map((r) => GamesRow(Map<String, dynamic>.from(r as Map)))
      .toList();
}
