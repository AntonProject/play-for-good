import '/backend/schema/structs/index.dart';

bool ggHasGamesOf(GgProfileStatsStruct? stats) {
  // The user has completed games (all time).
  return (stats?.allTimeGamesCount ?? 0) > 0;
}
