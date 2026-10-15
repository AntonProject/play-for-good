import '/backend/schema/structs/index.dart';

bool ggPlayerLoaded(GgPlayerStruct? player) {
  // A real ranking row (not the empty placeholder).
  return player != null && player.userId.isNotEmpty;
}
