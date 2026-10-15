import '/backend/schema/structs/index.dart';

GgGamesEntryStruct? ggGamesFromCache(
  List<GgGamesEntryStruct>? cache,
  String key,
) {
  // Cached games page for this key; other schema versions are ignored.
  for (final e in cache ?? <GgGamesEntryStruct>[]) {
    if (e.key == key && e.version == 1) return e;
  }
  return null;
}
