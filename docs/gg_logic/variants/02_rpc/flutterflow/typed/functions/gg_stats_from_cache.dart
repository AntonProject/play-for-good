import '/backend/schema/structs/index.dart';

GgProfileStatsStruct? ggStatsFromCache(
  List<GgStatsEntryStruct>? cache,
  String key,
) {
  // Cached profile statistics for this key; other schema versions are ignored.
  for (final e in cache ?? <GgStatsEntryStruct>[]) {
    if (e.key == key && e.version == 1 && e.hasData()) return e.data;
  }
  return null;
}
