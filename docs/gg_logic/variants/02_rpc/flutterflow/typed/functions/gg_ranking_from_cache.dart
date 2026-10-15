import '/backend/schema/structs/index.dart';

GgRankingStruct? ggRankingFromCache(
  List<GgRankingEntryStruct>? cache,
  String key,
) {
  // Cached ranking for this key; entries of another schema version are ignored.
  for (final e in cache ?? <GgRankingEntryStruct>[]) {
    if (e.key == key && e.version == 1 && e.hasData()) return e.data;
  }
  return null;
}
