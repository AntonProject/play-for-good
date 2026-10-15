import '/backend/schema/structs/index.dart';

List<GgRankingEntryStruct> ggRankingToCache(
  List<GgRankingEntryStruct>? cache,
  String key,
  GgRankingStruct? data,
) {
  // Puts the ranking first (replacing the same key); keeps the last 30.
  final rest = [
    for (final e in cache ?? <GgRankingEntryStruct>[])
      if (e.key != key && e.version == 1) e
  ];
  if (data == null) return rest.take(30).toList();
  return [
    GgRankingEntryStruct(key: key, savedAt: DateTime.now(), version: 1, data: data),
    ...rest,
  ].take(30).toList();
}
