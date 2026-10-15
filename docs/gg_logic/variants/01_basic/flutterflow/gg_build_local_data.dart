// FF Custom Action: games List<games rows>, users List<users rows>, context JSON,
// category String, page/pageSize Integer, userId optional String; return JSON.
import '/backend/supabase/supabase.dart';
import '/flutter_flow/custom_functions.dart' as functions;

Future<dynamic> ggBuildLocalData(
  List<GamesRow> games,
  List<UsersRow> users,
  dynamic context,
  String category,
  int page,
  int pageSize,
  String? userId,
) async {
  return functions.ggLocalCalculations(
    games.map((g) => g.data).toList(),
    users.map((u) => u.data).toList(),
    context,
    category,
    page,
    pageSize,
    userId,
  );
}
