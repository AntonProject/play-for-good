import '/backend/schema/structs/index.dart';

List<String> ggPlayerIdsOf(List<GgPlayerStruct>? players) {
  // User ids of ranking rows (players or topPlayers), in order.
  return [
    for (final p in players ?? <GgPlayerStruct>[])
      if (p.userId.isNotEmpty) p.userId
  ];
}
