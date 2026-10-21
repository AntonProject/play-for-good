import '/backend/schema/structs/index.dart';

bool ggShowGamesListOf(GgProfileStatsStruct? stats, GgGamesEntryStruct? history) {
  // Meine Games: the list frame, or (false) the "no games" picture.
  // A loaded page decides by itself: no games in the selected period -> the
  // picture (before: any game ever -> an empty frame for e.g. a past season).
  // While the page is still loading the frame stays for a user with games, so
  // the picture does not flash.
  if ((history?.games ?? const []).isNotEmpty) return true;
  if (history != null && history.hasMeta()) return false;
  return (stats?.allTimeGamesCount ?? 0) > 0;
}
