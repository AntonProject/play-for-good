import '/backend/schema/structs/index.dart';

bool ggGamesLoaded(GgGamesEntryStruct? entry) {
  // A games page arrived (from the server or the cache).
  return entry != null && entry.hasMeta();
}
