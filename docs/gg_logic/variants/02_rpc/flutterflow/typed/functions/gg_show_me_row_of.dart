import '/backend/schema/structs/index.dart';

bool ggShowMeRowOf(GgRankingStruct? ranking) {
  // Own row under the list: signed in and not on the loaded page. Also without
  // points in this category / period (21.10.2026: it was hidden then, while
  // Home showed the place after all ranked players, e.g. #4 / #16).
  if (ranking == null || !ranking.hasCurrentUser()) return false;
  final me = ranking.currentUser;
  if (me.userId.isEmpty) return false;
  return !ranking.players.any((p) => p.userId == me.userId);
}
