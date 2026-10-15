import '/backend/schema/structs/index.dart';

GgPlayerStruct ggTopPlayerAt(
  GgRankingStruct? ranking,
  int index,
) {
  // Top player at index 0..2; empty when there is none.
  final top = ranking?.topPlayers ?? <GgPlayerStruct>[];
  if (index < 0 || index >= top.length) return GgPlayerStruct();
  return top[index];
}
