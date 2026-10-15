import '/backend/schema/structs/index.dart';

bool ggStatsLoaded(GgProfileStatsStruct? stats) {
  // Profile statistics arrived (from the server or the cache).
  return stats != null && (stats.hasPeriod() || stats.userId.isNotEmpty);
}
