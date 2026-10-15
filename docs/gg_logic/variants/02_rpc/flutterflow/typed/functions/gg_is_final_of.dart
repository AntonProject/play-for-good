import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

bool ggIsFinalOf(GgRankingStruct? ranking) {
  // A closed season is shown (frozen results, medals).
  return ranking?.layoutMode == GgLayoutMode.finished;
}
