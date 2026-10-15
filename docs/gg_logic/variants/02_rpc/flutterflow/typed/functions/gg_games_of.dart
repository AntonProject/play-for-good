import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';

List<GamesRow> ggGamesOf(GgGamesEntryStruct? entry) {
  // Games of a loaded / cached page as rows of the games table.
  return [
    for (final g in entry?.games ?? <dynamic>[])
      if (g is Map) GamesRow(Map<String, dynamic>.from(g))
  ];
}
