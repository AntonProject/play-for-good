import '/backend/schema/structs/index.dart';

bool ggRankingLoaded(GgRankingStruct? ranking) {
  // Ranking arrived (from the server or the cache).
  return ranking != null && ranking.hasPeriod();
}
