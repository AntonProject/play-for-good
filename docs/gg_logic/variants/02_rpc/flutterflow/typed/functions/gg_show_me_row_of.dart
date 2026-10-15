import '/backend/schema/structs/index.dart';

bool ggShowMeRowOf(GgRankingStruct? ranking) {
  // Own row under the list: signed in, ranked and not on the loaded page.
  if (ranking == null || !ranking.hasCurrentUser()) return false;
  final me = ranking.currentUser;
  if (me.userId.isEmpty || !me.hasRank()) return false;
  return !ranking.players.any((p) => p.userId == me.userId);
}
