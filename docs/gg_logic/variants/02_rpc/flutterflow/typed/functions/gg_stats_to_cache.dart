import '/backend/schema/structs/index.dart';

List<GgStatsEntryStruct> ggStatsToCache(
  List<GgStatsEntryStruct>? cache,
  String key,
  GgProfileStatsStruct? data,
) {
  // Puts the statistics first (replacing the same key); keeps the last 30.
  final rest = [
    for (final e in cache ?? <GgStatsEntryStruct>[])
      if (e.key != key && e.version == 1) e
  ];
  if (data == null) return rest.take(30).toList();
  return [
    GgStatsEntryStruct(key: key, savedAt: DateTime.now(), version: 1, data: data),
    ...rest,
  ].take(30).toList();
}
