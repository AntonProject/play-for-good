import '/backend/schema/structs/index.dart';

List<GgGamesEntryStruct> ggGamesToCache(
  List<GgGamesEntryStruct>? cache,
  String key,
  GgGamesEntryStruct? entry,
) {
  // Puts the games page first under this key (replacing it); keeps the last 30.
  final rest = [
    for (final e in cache ?? <GgGamesEntryStruct>[])
      if (e.key != key && e.version == 1) e
  ];
  if (entry == null) return rest.take(30).toList();
  return [
    GgGamesEntryStruct(
      key: key,
      savedAt: DateTime.now(),
      version: 1,
      meta: entry.meta,
      games: entry.games,
    ),
    ...rest,
  ].take(30).toList();
}
